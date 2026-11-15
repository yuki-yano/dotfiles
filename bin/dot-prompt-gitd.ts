#!/usr/bin/env -S deno run -A

import watchmanModule from "fb-watchman";
import { basename, dirname, isAbsolute, join, relative, resolve } from "node:path";

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

export interface GitLineStats {
  added: number;
  deleted: number;
}

export interface GitStatus extends GitLineStats {
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

type PendingChanges = Set<string> | "all";

interface RepoState {
  id: string;
  top: string;
  gitDir: string;
  commonDir: string;
  cachePath: string;
  subscriptions: Set<string>;
  pending: PendingChanges | null;
  pendingSince: number | null;
  running: boolean;
  queued: boolean;
  timer: ReturnType<typeof setTimeout> | null;
  untrackedLines: UntrackedLineCache;
  worktreeTops: string[];
}

interface SubscriptionTarget {
  repoId: string;
  metadataOnly: boolean;
  namesRelativeTo: string;
}

export function isInsideNestedWorktree(base: string, name: string, worktrees: string[]): boolean {
  const path = join(base, name);
  return worktrees.some((worktree) =>
    worktree !== base && pathContains(base, worktree) && pathContains(worktree, path)
  );
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
    added: 0,
    deleted: 0,
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

export function parseNumstat(output: string): GitLineStats {
  const stats = { added: 0, deleted: 0 };
  const records = output.split("\0");
  for (let index = 0; index < records.length; index++) {
    const match = /^(\d+|-)\t(\d+|-)\t/.exec(records[index]);
    if (!match) continue;
    stats.added += parseCount(match[1]);
    stats.deleted += parseCount(match[2]);
    // A rename/copy has an empty path followed by two NUL-delimited paths.
    if (records[index].length === match[0].length) index += 2;
  }
  return stats;
}

async function gitOutput(top: string, args: string[]): Promise<string> {
  const result = await new Deno.Command("git", {
    args: ["-C", top, ...args],
    env: { GIT_OPTIONAL_LOCKS: "0" },
    stdin: "null",
    stdout: "piped",
    stderr: "null",
  }).output();
  if (!result.success) throw new Error(`git ${args[0]} exited with ${result.code}`);
  return new TextDecoder().decode(result.stdout);
}

export interface UntrackedLineCount {
  size: number;
  mtimeMs: number | null;
  ino: number | null;
  lines: number;
}

export type UntrackedLineCache = Map<string, UntrackedLineCount>;

async function countTextLines(path: string): Promise<number> {
  using file = await Deno.open(path, { read: true });
  const buffer = new Uint8Array(64 * 1_024);
  let bytesRead = 0;
  let lines = 0;
  let lastByte = -1;
  while (true) {
    const count = await file.read(buffer);
    if (count === null) break;
    // Match Git's usual binary-content heuristic.
    const probeLength = Math.min(count, Math.max(0, 8_000 - bytesRead));
    if (buffer.subarray(0, probeLength).includes(0)) return 0;
    for (let index = 0; index < count; index++) {
      if (buffer[index] === 10) lines++;
    }
    bytesRead += count;
    if (count > 0) lastByte = buffer[count - 1];
  }
  return lines + (lastByte !== -1 && lastByte !== 10 ? 1 : 0);
}

async function countUntrackedLines(
  path: string,
  previous: UntrackedLineCount | undefined,
): Promise<UntrackedLineCount | null> {
  try {
    const stat = await Deno.lstat(path);
    const key = { size: stat.size, mtimeMs: stat.mtime?.getTime() ?? null, ino: stat.ino };
    if (
      previous && key.mtimeMs !== null && previous.mtimeMs === key.mtimeMs && previous.size === key.size &&
      previous.ino === key.ino
    ) return previous;
    // Git stores the link target itself as one line, never its contents.
    if (stat.isSymlink) return { ...key, lines: 1 };
    // Do not descend into nested repositories.
    if (!stat.isFile) return { ...key, lines: 0 };
    return { ...key, lines: await countTextLines(path) };
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return null;
    throw error;
  }
}

export async function readGitLineStats(
  top: string,
  oid: string,
  { tracked = true, untracked = true, untrackedLines = new Map() }: {
    tracked?: boolean;
    untracked?: boolean;
    untrackedLines?: UntrackedLineCache;
  } = {},
): Promise<GitLineStats> {
  const readHeadToWorktreeNumstat = async () => {
    if (!tracked) return "";
    // An unborn branch compares against the empty tree, using the repository's
    // object format. hash-object without -w does not write any objects.
    const base = oid === "(initial)" ? (await gitOutput(top, ["hash-object", "-t", "tree", "--stdin"])).trim() : oid;
    return gitOutput(top, ["diff", "--numstat", "-z", "--no-ext-diff", "--no-textconv", base, "--"]);
  };
  const [numstat, untrackedOutput] = await Promise.all([
    readHeadToWorktreeNumstat(),
    untracked ? gitOutput(top, ["ls-files", "--others", "--exclude-standard", "-z"]) : "",
  ]);
  const stats = parseNumstat(numstat);
  const paths = untrackedOutput.split("\0").filter(Boolean);
  const counted: UntrackedLineCache = new Map();
  let next = 0;
  await Promise.all(Array.from({ length: Math.min(4, paths.length) }, async () => {
    while (next < paths.length) {
      const path = paths[next++];
      const entry = await countUntrackedLines(join(top, path), untrackedLines.get(path));
      if (!entry) continue;
      counted.set(path, entry);
      stats.added += entry.lines;
    }
  }));
  untrackedLines.clear();
  for (const [path, entry] of counted) untrackedLines.set(path, entry);
  return stats;
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
    ["added", status.added],
    ["deleted", status.deleted],
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

export function createWatchExpression(metadataOnly: boolean, ownStateDir?: string): unknown[] {
  if (!metadataOnly) return ["allof", ["not", ["type", "d"]], ["not", ["dirname", ".git"]]];
  // Other worktrees' private state cannot change this status, but their gitdir
  // files mark worktrees being added or removed.
  const otherWorktreeState: unknown[] = ["allof", ["dirname", "worktrees"], ["not", ["name", "gitdir"]]];
  if (ownStateDir) otherWorktreeState.push(["not", ["dirname", ownStateDir]]);
  return [
    "allof",
    ["not", ["type", "d"]],
    ["not", ["name", "index.lock"]],
    ["not", ["match", "**/objects/**", "wholename"]],
    ["not", otherWorktreeState],
  ];
}

export async function listWorktreeTops(top: string): Promise<string[]> {
  const output = await gitOutput(top, ["worktree", "list", "--porcelain", "-z"]);
  const tops = output.split("\0").filter((field) => field.startsWith("worktree ")).map((field) => field.slice(9));
  const resolved = await Promise.all(tops.map((path) => Deno.realPath(path).catch(() => null)));
  return resolved.filter((path) => path !== null);
}

export function mergePendingChanges(current: PendingChanges | null, change: PendingChanges): PendingChanges {
  if (current === "all" || change === "all") return "all";
  return current ? new Set([...current, ...change]) : new Set(change);
}

// These files change how other paths are classified, even when they are ignored themselves.
const GIT_RULE_FILES = new Set([".gitignore", ".gitattributes", ".gitmodules"]);

export async function canSkipRefresh(top: string, paths: Set<string>): Promise<boolean> {
  if (paths.size === 0 || [...paths].some((path) => GIT_RULE_FILES.has(basename(path)))) return false;
  const child = new Deno.Command("git", {
    args: ["-C", top, "check-ignore", "--stdin", "-z"],
    env: { GIT_OPTIONAL_LOCKS: "0" },
    stdin: "piped",
    stdout: "piped",
    stderr: "null",
  }).spawn();
  const stdout = new Response(child.stdout).arrayBuffer();
  const writer = child.stdin.getWriter();
  const inputWritten = writer.write(new TextEncoder().encode([...paths].map((path) => `${path}\0`).join("")))
    .then(() => writer.close())
    .then(() => true, () => false);
  const [{ code }, output, written] = await Promise.all([child.status, stdout, inputWritten]);
  if (!written || code !== 0) return false;
  const ignored = new Set(new TextDecoder().decode(output).split("\0"));
  return [...paths].every((path) => ignored.has(path));
}

function command(client: WatchmanClient, args: unknown[]): Promise<WatchmanResponse> {
  return new Promise((resolvePromise, reject) => {
    client.command(args, (error, response) => {
      if (error) reject(error);
      else resolvePromise(response);
    });
  });
}

async function readTextIfExists(path: string): Promise<string | null> {
  try {
    return await Deno.readTextFile(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return null;
    throw error;
  }
}

async function writeCacheIfChanged(path: string, content: string, temporary: string): Promise<void> {
  if (await readTextIfExists(path) === content) return;
  await Deno.mkdir(dirname(path), { recursive: true });
  await Deno.writeTextFile(temporary, content);
  await Deno.rename(temporary, path);
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

export function removePreBootIndexLock(gitDir: string, bootTimeMs: number): boolean {
  if (!Number.isFinite(bootTimeMs) || bootTimeMs <= 0) return false;
  const lockPath = join(gitDir, "index.lock");
  try {
    const stat = Deno.lstatSync(lockPath);
    // Git creates index.lock exclusively. A regular file whose contents and
    // metadata both predate this boot cannot belong to a surviving Git process.
    // ctime also protects newly copied files whose mtime was preserved.
    if (
      !stat.isFile || !stat.mtime || !stat.ctime ||
      stat.mtime.getTime() >= bootTimeMs || stat.ctime.getTime() >= bootTimeMs ||
      (stat.birthtime && stat.birthtime.getTime() >= bootTimeMs)
    ) return false;
    Deno.removeSync(lockPath);
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
  #subscriptionRepos = new Map<string, SubscriptionTarget>();
  #subscriptionSequence = 0;
  #queue: RepoState[] = [];
  #activeGit = 0;
  #reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  #shuttingDown = false;
  #cacheWriteSequence = 0;
  #logPath: string;
  // osUptime has second precision. Exclude that boundary second so a lock
  // created during this boot is never classified as belonging to an older boot.
  #bootTimeMs = Date.now() - (Deno.osUptime() + 1) * 1_000;

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

  register(request: RegistrationRequest): Promise<void> {
    const top = resolve(request.top);
    const existing = this.#repos.get(top);
    if (existing) {
      existing.cachePath = request.cachePath;
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
    try {
      if (removePreBootIndexLock(metadata.gitDir, this.#bootTimeMs)) {
        this.log(`removed pre-boot index lock ${join(metadata.gitDir, "index.lock")}`);
      }
    } catch (error) {
      this.log(`index lock recovery failed for ${top}: ${error}`);
    }
    const repo: RepoState = {
      id: top,
      top,
      gitDir: metadata.gitDir,
      commonDir: metadata.commonDir,
      cachePath,
      subscriptions: new Set(),
      pending: null,
      pendingSince: null,
      running: false,
      queued: false,
      timer: null,
      untrackedLines: new Map(),
      worktreeTops: await listWorktreeTops(top).catch(() => []),
    };
    this.#repos.set(top, repo);
    await this.#subscribeRepo(repo);
    this.log(`registered ${top} with ${repo.subscriptions.size} subscription(s)`);
    this.#markDirty(repo, "all", true);
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
      const ownStateDir = target.metadataOnly && target.path !== repo.gitDir && pathContains(target.path, repo.gitDir)
        ? relative(target.path, repo.gitDir)
        : undefined;
      const options: Record<string, unknown> = {
        // Watchman synchronization cookies live under .git on macOS. Their
        // create/remove cycle changes the parent directory mtime; directories
        // themselves cannot affect Git status, so do not feed those events
        // back into another status refresh.
        expression: createWatchExpression(target.metadataOnly, ownStateDir),
        fields: ["name"],
        // Status uses GIT_OPTIONAL_LOCKS=0 and can be read while index.lock
        // exists. Keep events flowing even if a Git process left its lock behind;
        // our debounce and index.lock exclusion already suppress update noise.
        defer_vcs: false,
        empty_on_fresh_instance: true,
      };
      if (relativeRoot) options.relative_root = relativeRoot;
      await command(client, ["subscribe", watchRoot, name, options]);
      repo.subscriptions.add(name);
      this.#subscriptionRepos.set(name, {
        repoId: repo.id,
        metadataOnly: target.metadataOnly,
        namesRelativeTo: relativeRoot ? join(watchRoot, relativeRoot) : watchRoot,
      });
    }
  }

  #createClient(): void {
    const client = new watchman.Client();
    this.#client = client;
    client.on("subscription", (response) => {
      if (!Array.isArray(response.files) || response.files.length === 0) return;
      const subscription = typeof response.subscription === "string" ? response.subscription : "";
      const target = this.#subscriptionRepos.get(subscription);
      const repo = target ? this.#repos.get(target.repoId) : undefined;
      if (!target || !repo) return;
      const names = response.files.filter((name): name is string => typeof name === "string");
      if (target.metadataOnly) {
        if (names.some((name) => /^worktrees\/[^/]+\/gitdir$/.test(name))) void this.#reloadNestedWorktrees(repo);
        if (names.some((name) => !isInsideNestedWorktree(target.namesRelativeTo, name, repo.worktreeTops))) {
          this.#markDirty(repo, "all", false);
        }
        return;
      }
      if (names.length > 0) this.#markDirty(repo, new Set(names), false);
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
    for (const repo of this.#repos.values()) {
      try {
        await this.#subscribeRepo(repo);
        this.#markDirty(repo, "all", true);
      } catch (error) {
        this.log(`subscription restore failed for ${repo.top}: ${error}`);
      }
    }
  }

  async #reloadNestedWorktrees(repo: RepoState): Promise<void> {
    try {
      repo.worktreeTops = await listWorktreeTops(repo.top);
    } catch (error) {
      this.log(`worktree list failed for ${repo.top}: ${error}`);
    }
  }

  #markDirty(repo: RepoState, change: PendingChanges, immediate: boolean): void {
    repo.pending = mergePendingChanges(repo.pending, change);
    this.#scheduleRefresh(repo, immediate);
  }

  #scheduleRefresh(repo: RepoState, immediate: boolean): void {
    const now = Date.now();
    repo.pendingSince ??= now;
    if (repo.running || repo.queued) return;
    if (repo.timer !== null) clearTimeout(repo.timer);
    const maxRemaining = Math.max(0, MAX_DEBOUNCE_MS - (now - repo.pendingSince));
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
      const pending = repo.pending ?? "all";
      repo.queued = false;
      repo.running = true;
      repo.pending = null;
      repo.pendingSince = null;
      this.#activeGit++;
      void this.#refresh(repo, pending).finally(() => {
        this.#activeGit--;
        repo.running = false;
        if (repo.pending !== null) this.#scheduleRefresh(repo, false);
        this.#pumpQueue();
      });
    }
  }

  async #refresh(repo: RepoState, pending: PendingChanges): Promise<void> {
    try {
      if (pending !== "all" && await canSkipRefresh(repo.top, pending).catch(() => false)) return;
      const result = await new Deno.Command("git", {
        args: ["-C", repo.top, "status", "--show-stash", "--branch", "--porcelain=v2", "--untracked-files=normal"],
        env: { GIT_OPTIONAL_LOCKS: "0" },
        stdout: "piped",
        stderr: "null",
      }).output();
      if (!result.success) throw new Error(`git status exited with ${result.code}`);

      const status = parsePorcelainV2(new TextDecoder().decode(result.stdout));
      Object.assign(
        status,
        await readGitLineStats(repo.top, status.oid, {
          tracked: status.staged + status.unstaged + status.unmerged > 0,
          untracked: status.untracked > 0,
          untrackedLines: repo.untrackedLines,
        }),
      );
      const rebasing = await exists(join(repo.gitDir, "rebase-merge")) ||
        await exists(join(repo.gitDir, "rebase-apply"));
      const conflict = await exists(join(repo.gitDir, "MERGE_HEAD"));
      const content = formatCache(repo.top, repo.cachePath, status, rebasing ? "Rebasing" : "", conflict);
      await writeCacheIfChanged(
        repo.cachePath,
        content,
        `${repo.cachePath}.${Deno.pid}.${++this.#cacheWriteSequence}.tmp`,
      );
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
