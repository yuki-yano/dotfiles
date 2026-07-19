#!/usr/bin/env -S deno run -A

import watchmanModule from "fb-watchman";
import { dirname, isAbsolute, join, relative, resolve } from "node:path";

const LEGACY_TRIGGER_NAMES = new Set([
  "dot-prompt-git-worktree",
  "dot-prompt-git-gitdir",
]);
const DEBOUNCE_MS = 300;
const MAX_DEBOUNCE_MS = 2_000;
const MAX_CONCURRENT_GIT = 4;

type WatchmanResponse = Record<string, unknown>;

interface WatchmanClient {
  command(
    args: unknown[],
    callback: (error: Error | null, response: WatchmanResponse) => void,
  ): void;
  on(event: "subscription", callback: (response: WatchmanResponse) => void): void;
  on(event: "error" | "end", callback: (error?: Error) => void): void;
  end(): void;
}

interface WatchmanConstructor {
  Client: new () => WatchmanClient;
}

const watchman = watchmanModule as unknown as WatchmanConstructor;

export interface GitStatus {
  oid: string;
  branch: string;
  detached: boolean;
  upstream: string;
  ahead: number;
  behind: number;
  staged: number;
  unstaged: number;
  untracked: number;
  unmerged: number;
  stash: number;
}

interface RegistrationRequest {
  top: string;
  cachePath: string;
}

interface RepoState {
  id: string;
  top: string;
  gitDir: string;
  commonDir: string;
  cachePath: string;
  subscriptions: Set<string>;
  dirty: boolean;
  dirtySince: number | null;
  running: boolean;
  queued: boolean;
  timer: ReturnType<typeof setTimeout> | null;
  legacyCleanupAt: number;
}

function isRegistrationRequest(value: unknown): value is RegistrationRequest {
  if (!value || typeof value !== "object") return false;
  const request = value as Record<string, unknown>;
  return typeof request.top === "string" && request.top.length > 0 &&
    typeof request.cachePath === "string" && request.cachePath.length > 0 &&
    isAbsolute(request.top) && isAbsolute(request.cachePath);
}

function parseCount(value: string | undefined, prefix = ""): number {
  if (!value) return 0;
  const parsed = Number.parseInt(prefix && value.startsWith(prefix) ? value.slice(prefix.length) : value, 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

export function parsePorcelainV2(output: string): GitStatus {
  const status: GitStatus = {
    oid: "",
    branch: "",
    detached: false,
    upstream: "",
    ahead: 0,
    behind: 0,
    staged: 0,
    unstaged: 0,
    untracked: 0,
    unmerged: 0,
    stash: 0,
  };

  for (const line of output.split("\n")) {
    if (line.startsWith("# branch.oid ")) {
      status.oid = line.slice("# branch.oid ".length);
      continue;
    }
    if (line.startsWith("# branch.head ")) {
      const head = line.slice("# branch.head ".length);
      status.detached = head === "(detached)";
      status.branch = status.detached ? "" : head;
      continue;
    }
    if (line.startsWith("# branch.upstream ")) {
      status.upstream = line.slice("# branch.upstream ".length);
      continue;
    }
    if (line.startsWith("# branch.ab ")) {
      const [ahead, behind] = line.slice("# branch.ab ".length).split(" ");
      status.ahead = parseCount(ahead, "+");
      status.behind = parseCount(behind, "-");
      continue;
    }
    if (line.startsWith("# stash ")) {
      status.stash = parseCount(line.slice("# stash ".length));
      continue;
    }
    if (line.startsWith("? ")) {
      status.untracked++;
      continue;
    }
    if (line.startsWith("u ")) {
      status.unmerged++;
      continue;
    }
    if (line.startsWith("1 ") || line.startsWith("2 ")) {
      const xy = line.split(" ", 3)[1] ?? "..";
      if (xy[0] !== ".") status.staged++;
      if (xy[1] !== ".") status.unstaged++;
    }
  }

  if (status.detached) status.branch = status.oid.slice(0, 7);
  return status;
}

export function zshQuote(value: string): string {
  return `'${value.replaceAll("'", "'\\''")}'`;
}

export function formatCache(
  top: string,
  cachePath: string,
  status: GitStatus,
  action: string,
  conflict: boolean,
): string {
  const pairs: Array<[string, string | number]> = [
    ["pwd", top],
    ["top", top],
    ["cache", cachePath],
    ["branch", status.branch],
    ["detached", status.detached ? "1" : ""],
    ["upstream", status.upstream],
    ["action", action],
    ["conflict", conflict ? "1" : ""],
    ["ahead", status.ahead],
    ["behind", status.behind],
    ["staged", status.staged],
    ["unstaged", status.unstaged],
    ["untracked", status.untracked],
    ["unmerged", status.unmerged],
    ["stash", status.stash],
  ];
  return `${pairs.flatMap(([key, value]) => [key, zshQuote(String(value))]).join(" ")}\n`;
}

function pathContains(parent: string, child: string): boolean {
  const rel = relative(parent, child);
  return rel === "" || (!rel.startsWith("..") && !isAbsolute(rel));
}

export function minimizeWatchPaths(paths: string[]): string[] {
  const unique = [...new Set(paths.map((path) => resolve(path)))].sort((a, b) => a.length - b.length);
  const result: string[] = [];
  for (const candidate of unique) {
    if (!result.some((parent) => pathContains(parent, candidate))) result.push(candidate);
  }
  return result;
}

export function createWatchExpression(metadataOnly: boolean): unknown[] {
  const indexLock = metadataOnly ? ["name", "index.lock"] : ["name", ".git/index.lock", "wholename"];
  return ["allof", ["not", ["type", "d"]], ["not", indexLock]];
}

function command(client: WatchmanClient, args: unknown[]): Promise<WatchmanResponse> {
  return new Promise((resolvePromise, reject) => {
    client.command(args, (error, response) => {
      if (error) reject(error);
      else resolvePromise(response);
    });
  });
}

async function exists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

class GitPromptDaemon {
  #client: WatchmanClient | null = null;
  #repos = new Map<string, RepoState>();
  #pendingRegistrations = new Map<string, Promise<void>>();
  #subscriptionRepos = new Map<string, string>();
  #subscriptionSequence = 0;
  #queue: RepoState[] = [];
  #activeGit = 0;
  #reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  #shuttingDown = false;
  #cacheWriteSequence = 0;
  #logPath: string;

  constructor(logPath: string) {
    this.#logPath = logPath;
    this.#createClient();
  }

  log(message: string): void {
    try {
      Deno.writeTextFileSync(this.#logPath, `${new Date().toISOString()} ${message}\n`, { append: true });
    } catch {
      // The prompt must stay quiet even when diagnostics cannot be written.
    }
  }

  async cleanupLegacyTriggers(): Promise<void> {
    const client = this.#client;
    if (!client) return;
    try {
      const watchList = await command(client, ["watch-list"]);
      const roots = Array.isArray(watchList.roots)
        ? watchList.roots.filter((root): root is string => typeof root === "string")
        : [];
      for (const root of roots) {
        try {
          const triggerList = await command(client, ["trigger-list", root]);
          const triggers = Array.isArray(triggerList.triggers) ? triggerList.triggers : [];
          for (const trigger of triggers) {
            const name = trigger && typeof trigger === "object" ? (trigger as Record<string, unknown>).name : undefined;
            if (typeof name === "string" && LEGACY_TRIGGER_NAMES.has(name)) {
              await command(client, ["trigger-del", root, name]);
            }
          }
        } catch (error) {
          this.log(`legacy trigger cleanup failed for ${root}: ${error}`);
        }
      }
    } catch (error) {
      this.log(`watch-list failed during legacy cleanup: ${error}`);
    }
  }

  register(request: RegistrationRequest): Promise<void> {
    const top = resolve(request.top);
    const existing = this.#repos.get(top);
    if (existing) {
      existing.cachePath = request.cachePath;
      void this.#cleanupLegacyTriggersForRepo(existing);
      return Promise.resolve();
    }
    const pending = this.#pendingRegistrations.get(top);
    if (pending) return pending;

    const registration = this.#registerNew(top, request.cachePath).finally(() => {
      this.#pendingRegistrations.delete(top);
    });
    this.#pendingRegistrations.set(top, registration);
    return registration;
  }

  shutdown(): void {
    this.#shuttingDown = true;
    if (this.#reconnectTimer !== null) clearTimeout(this.#reconnectTimer);
    for (const repo of this.#repos.values()) {
      if (repo.timer !== null) clearTimeout(repo.timer);
    }
    this.#client?.end();
    this.#client = null;
  }

  async #registerNew(top: string, cachePath: string): Promise<void> {
    const metadata = await this.#resolveGitMetadata(top);
    const repo: RepoState = {
      id: top,
      top,
      gitDir: metadata.gitDir,
      commonDir: metadata.commonDir,
      cachePath,
      subscriptions: new Set(),
      dirty: false,
      dirtySince: null,
      running: false,
      queued: false,
      timer: null,
      legacyCleanupAt: 0,
    };
    this.#repos.set(top, repo);
    await this.#subscribeRepo(repo);
    void this.#cleanupLegacyTriggersForRepo(repo);
    this.log(`registered ${top} with ${repo.subscriptions.size} subscription(s)`);
    this.#markDirty(repo, true);
  }

  async #resolveGitMetadata(top: string): Promise<{ gitDir: string; commonDir: string }> {
    const result = await new Deno.Command("git", {
      args: ["-C", top, "rev-parse", "--path-format=absolute", "--git-dir", "--git-common-dir"],
      stdout: "piped",
      stderr: "null",
    }).output();
    if (!result.success) throw new Error(`git metadata resolution failed for ${top}`);
    const [gitDir, commonDir] = new TextDecoder().decode(result.stdout).trimEnd().split("\n");
    if (!gitDir || !commonDir) throw new Error(`git metadata response was incomplete for ${top}`);
    return { gitDir: resolve(gitDir), commonDir: resolve(commonDir) };
  }

  async #subscribeRepo(repo: RepoState): Promise<void> {
    const client = this.#client;
    if (!client) return;
    repo.subscriptions.clear();

    const watchTargets = [
      { path: repo.top, metadataOnly: false, exact: false },
      ...minimizeWatchPaths([repo.gitDir, repo.commonDir]).map((path) => ({
        path,
        metadataOnly: true,
        exact: true,
      })),
    ];
    const targets = new Set<string>();
    for (const target of watchTargets) {
      // Watchman applies shallow ignore_vcs handling to .git below a project
      // root, so refs are only reliable when the metadata directory itself is
      // an exact watch root. This adds subscriptions, not daemon processes.
      const watched = await command(client, [target.exact ? "watch" : "watch-project", target.path]);
      const watchRoot = typeof watched.watch === "string" ? watched.watch : "";
      const relativeRoot = typeof watched.relative_path === "string" ? watched.relative_path : undefined;
      if (!watchRoot) throw new Error(`Watchman returned no watch root for ${target.path}`);
      const targetKey = `${watchRoot}\0${relativeRoot ?? ""}`;
      if (targets.has(targetKey)) continue;
      targets.add(targetKey);

      const name = `dot-prompt-gitd-${Deno.pid}-${++this.#subscriptionSequence}`;
      const options: Record<string, unknown> = {
        // Watchman synchronization cookies live under .git on macOS. Their
        // create/remove cycle changes the parent directory mtime; directories
        // themselves cannot affect Git status, so do not feed those events
        // back into another status refresh.
        expression: createWatchExpression(target.metadataOnly),
        fields: ["name"],
        defer_vcs: true,
        empty_on_fresh_instance: true,
      };
      if (relativeRoot) options.relative_root = relativeRoot;
      await command(client, ["subscribe", watchRoot, name, options]);
      repo.subscriptions.add(name);
      this.#subscriptionRepos.set(name, repo.id);
    }
  }

  async #cleanupLegacyTriggersForRepo(repo: RepoState): Promise<void> {
    const client = this.#client;
    const now = Date.now();
    if (!client || now - repo.legacyCleanupAt < 60_000) return;
    repo.legacyCleanupAt = now;

    const triggers: Array<[string, string]> = [
      [repo.top, "dot-prompt-git-worktree"],
      [repo.gitDir, "dot-prompt-git-gitdir"],
    ];
    for (const [root, name] of triggers) {
      try {
        await command(client, ["trigger-del", root, name]);
      } catch {
        // The root or trigger may already have been removed.
      }
    }
  }

  #createClient(): void {
    const client = new watchman.Client();
    this.#client = client;
    client.on("subscription", (response) => {
      if (!Array.isArray(response.files) || response.files.length === 0) return;
      const subscription = typeof response.subscription === "string" ? response.subscription : "";
      const repoId = this.#subscriptionRepos.get(subscription);
      const repo = repoId ? this.#repos.get(repoId) : undefined;
      if (repo) this.#markDirty(repo, false);
    });
    client.on("error", (error) => {
      if (error) this.log(`Watchman client error: ${error}`);
    });
    client.on("end", () => this.#scheduleReconnect());
  }

  #scheduleReconnect(): void {
    if (this.#shuttingDown || this.#reconnectTimer !== null) return;
    this.#client = null;
    this.#subscriptionRepos.clear();
    for (const repo of this.#repos.values()) repo.subscriptions.clear();
    this.#reconnectTimer = setTimeout(() => {
      this.#reconnectTimer = null;
      this.#createClient();
      void this.#restoreSubscriptions();
    }, 1_000);
  }

  async #restoreSubscriptions(): Promise<void> {
    await this.cleanupLegacyTriggers();
    for (const repo of this.#repos.values()) {
      try {
        await this.#subscribeRepo(repo);
        this.#markDirty(repo, true);
      } catch (error) {
        this.log(`subscription restore failed for ${repo.top}: ${error}`);
      }
    }
  }

  #markDirty(repo: RepoState, immediate: boolean): void {
    const now = Date.now();
    repo.dirty = true;
    repo.dirtySince ??= now;
    if (repo.running || repo.queued) return;
    if (repo.timer !== null) clearTimeout(repo.timer);
    const maxRemaining = Math.max(0, MAX_DEBOUNCE_MS - (now - repo.dirtySince));
    const delay = immediate ? 0 : Math.min(DEBOUNCE_MS, maxRemaining);
    repo.timer = setTimeout(() => {
      repo.timer = null;
      this.#enqueue(repo);
    }, delay);
  }

  #enqueue(repo: RepoState): void {
    if (repo.running || repo.queued) return;
    repo.queued = true;
    this.#queue.push(repo);
    this.#pumpQueue();
  }

  #pumpQueue(): void {
    while (this.#activeGit < MAX_CONCURRENT_GIT && this.#queue.length > 0) {
      const repo = this.#queue.shift();
      if (!repo) return;
      repo.queued = false;
      repo.running = true;
      repo.dirty = false;
      repo.dirtySince = null;
      this.#activeGit++;
      void this.#refresh(repo).finally(() => {
        this.#activeGit--;
        repo.running = false;
        if (repo.dirty) this.#markDirty(repo, false);
        this.#pumpQueue();
      });
    }
  }

  async #refresh(repo: RepoState): Promise<void> {
    try {
      const result = await new Deno.Command("git", {
        args: ["-C", repo.top, "status", "--show-stash", "--branch", "--porcelain=v2"],
        env: { GIT_OPTIONAL_LOCKS: "0" },
        stdout: "piped",
        stderr: "null",
      }).output();
      if (!result.success) throw new Error(`git status exited with ${result.code}`);

      const status = parsePorcelainV2(new TextDecoder().decode(result.stdout));
      const rebasing = await exists(join(repo.gitDir, "rebase-merge")) ||
        await exists(join(repo.gitDir, "rebase-apply"));
      const conflict = await exists(join(repo.gitDir, "MERGE_HEAD"));
      const content = formatCache(repo.top, repo.cachePath, status, rebasing ? "Rebasing" : "", conflict);
      await Deno.mkdir(dirname(repo.cachePath), { recursive: true });
      const temporary = `${repo.cachePath}.${Deno.pid}.${++this.#cacheWriteSequence}.tmp`;
      await Deno.writeTextFile(temporary, content);
      await Deno.rename(temporary, repo.cachePath);
      this.log(`refresh ok ${repo.top}`);
    } catch (error) {
      this.log(`refresh failed for ${repo.top}: ${error}`);
    }
  }
}

async function readRequest(connection: Deno.Conn): Promise<unknown> {
  const decoder = new TextDecoder();
  const buffer = new Uint8Array(4_096);
  let input = "";
  while (input.length < 65_536) {
    const count = await connection.read(buffer);
    if (count === null) break;
    input += decoder.decode(buffer.subarray(0, count), { stream: true });
    const newline = input.indexOf("\n");
    if (newline >= 0) {
      input = input.slice(0, newline);
      break;
    }
  }
  return JSON.parse(input);
}

async function acquireSingleton(
  runtimeDir: string,
): Promise<{ lockPath: string; lockFile: Deno.FsFile } | null> {
  await Deno.mkdir(runtimeDir, { recursive: true, mode: 0o700 });
  await Deno.chmod(runtimeDir, 0o700);
  const lockPath = join(runtimeDir, "daemon.pid");
  const lockFile = await Deno.open(lockPath, { create: true, read: true, write: true, mode: 0o600 });
  await Deno.chmod(lockPath, 0o600);
  try {
    if (!await lockFile.tryLock(true)) {
      lockFile.close();
      return null;
    }
    await lockFile.truncate(0);
    await lockFile.write(new TextEncoder().encode(`${Deno.pid}\n`));
    return { lockPath, lockFile };
  } catch (error) {
    lockFile.close();
    throw error;
  }
}

async function main(): Promise<void> {
  const uid = typeof Deno.uid === "function" ? Deno.uid() : Deno.env.get("UID") ?? "user";
  const temporaryRoot = (Deno.env.get("TMPDIR") ?? "/tmp").replace(/\/$/, "");
  const runtimeDir = Deno.env.get("DOT_PROMPT_GITD_RUNTIME_BASE") ?? join(temporaryRoot, `dot-prompt-gitd-${uid}`);
  const singleton = await acquireSingleton(runtimeDir);
  if (!singleton) return;

  const socketPath = Deno.env.get("DOT_PROMPT_GITD_SOCKET_PATH") ?? join(runtimeDir, "daemon.sock");
  const logPath = join(runtimeDir, "daemon.log");
  try {
    await Deno.remove(socketPath);
  } catch (error) {
    if (!(error instanceof Deno.errors.NotFound)) throw error;
  }

  const daemon = new GitPromptDaemon(logPath);
  const listener = Deno.listen({ transport: "unix", path: socketPath });
  await Deno.chmod(socketPath, 0o600);
  void daemon.cleanupLegacyTriggers();

  let stopping = false;
  let stopPromise: Promise<void> | null = null;
  const stop = (): Promise<void> => {
    if (stopPromise) return stopPromise;
    stopping = true;
    stopPromise = (async () => {
      listener.close();
      daemon.shutdown();
      try {
        await Deno.remove(socketPath);
      } catch {
        // The socket may already have been removed during shutdown.
      }
      try {
        await Deno.remove(singleton.lockPath);
      } catch {
        // The lock file may already have been removed during shutdown.
      }
      try {
        await singleton.lockFile.unlock();
      } catch {
        // Closing the descriptor below still releases the operating-system lock.
      }
      singleton.lockFile.close();
    })();
    return stopPromise;
  };

  Deno.addSignalListener("SIGTERM", () => void stop());
  Deno.addSignalListener("SIGINT", () => void stop());

  let acceptRetryMs = 25;
  try {
    while (!stopping) {
      let connection: Deno.Conn;
      try {
        connection = await listener.accept();
        acceptRetryMs = 25;
      } catch (error) {
        if (stopping || error instanceof Deno.errors.BadResource) break;
        daemon.log(`accept failed, retrying in ${acceptRetryMs}ms: ${error}`);
        await new Promise((resolvePromise) => setTimeout(resolvePromise, acceptRetryMs));
        acceptRetryMs = Math.min(acceptRetryMs * 2, 1_000);
        continue;
      }

      void (async () => {
        try {
          const request = await readRequest(connection);
          if (isRegistrationRequest(request)) await daemon.register(request);
        } catch (error) {
          daemon.log(`invalid registration request: ${error}`);
        } finally {
          connection.close();
        }
      })();
    }
  } finally {
    await stop();
  }
}

if (import.meta.main) {
  try {
    await main();
  } catch {
    // Prompt infrastructure must never leak startup errors into the shell.
    Deno.exit(0);
  }
}
