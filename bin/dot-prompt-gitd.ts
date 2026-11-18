#!/usr/bin/env -S deno run -A

import watchmanModule from "fb-watchman";
import { basename, isAbsolute, join, relative, resolve } from "node:path";

const DEBOUNCE_MS = 300;
const MAX_DEBOUNCE_MS = 2_000;
export const MAX_CONCURRENT_GIT = 4;
// A shell connects right after its command ends, and Watchman reports that
// command's last writes 22-43 ms after they happen (measured). Events inside
// this window skip the debounce.
const EXPEDITE_MS = 150;
const IDLE_FORGET_MS = 60 * 60_000;
const MAX_HELLO_BYTES = 4_096;
// Sent before a close the shell must not retry; any other close means "the
// daemon went away, connect again".
const REFUSAL = "refused\n";

class TopRefused extends Error {}

type WatchmanResponse = Record<string, unknown>;

export interface WatchmanClient {
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
  untrackedPaths: string[];
  unmerged: number;
  stash: number;
}

interface Client {
  readonly conn: Deno.Conn;
  readonly top: string;
  latest: string | null;
  writing: boolean;
}

export interface PendingChanges {
  worktreePaths: Set<string>;
  metadataChanged: boolean;
  mayHaveMissedWorktreeEvents: boolean;
}

const UNKNOWN_CHANGES: PendingChanges = {
  worktreePaths: new Set(),
  metadataChanged: true,
  mayHaveMissedWorktreeEvents: true,
};
const METADATA_CHANGES: PendingChanges = {
  worktreePaths: new Set(),
  metadataChanged: true,
  mayHaveMissedWorktreeEvents: false,
};

interface RepoState {
  id: string;
  top: string;
  gitDir: string;
  commonDir: string;
  line: string | null;
  expediteUntil: number;
  idleTimer: ReturnType<typeof setTimeout> | null;
  subscriptions: Set<string>;
  pending: PendingChanges | null;
  pendingSince: number | null;
  running: boolean;
  queued: boolean;
  timer: ReturnType<typeof setTimeout> | null;
  untrackedLines: UntrackedLineCache;
  worktreeTops: string[];
  worktreeTopsStale: boolean;
}

interface SubscriptionTarget {
  repo: RepoState;
  metadataOnly: boolean;
  watchRoot: string;
  namesRelativeTo: string;
  lastWarning: string | null;
}

export function isInsideNestedWorktree(base: string, name: string, worktrees: string[]): boolean {
  const path = join(base, name);
  return worktrees.some((worktree) =>
    worktree !== base && pathContains(base, worktree) && pathContains(worktree, path)
  );
}

export function parseHello(text: string): string | null {
  let value: unknown;
  try {
    value = JSON.parse(text);
  } catch {
    return null;
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;
  const top = (value as Record<string, unknown>).top;
  if (Object.keys(value).length !== 1 || typeof top !== "string" || !isAbsolute(top)) return null;
  return resolve(top);
}

export function refreshDelay(now: number, pendingSince: number, expediteUntil: number, immediate: boolean): number {
  if (immediate || now < expediteUntil) return 0;
  return Math.min(DEBOUNCE_MS, Math.max(0, MAX_DEBOUNCE_MS - (now - pendingSince)));
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
    untrackedPaths: [],
    unmerged: 0,
    stash: 0,
    added: 0,
    deleted: 0,
  };

  const records = output.split("\0");
  for (let index = 0; index < records.length; index++) {
    const line = records[index];
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
      status.untrackedPaths.push(line.slice("? ".length));
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
      // A rename or copy carries its original path in the next record.
      if (line.startsWith("2 ")) index++;
    }
  }

  if (status.detached) status.branch = status.oid.slice(0, 7);
  return status;
}

// -uall lists each untracked file, so the count matches `git status` and the
// line counter reads the same list instead of walking the tree again.
export async function readGitStatus(top: string): Promise<GitStatus> {
  return parsePorcelainV2(
    await gitOutput(top, ["status", "--show-stash", "--branch", "--porcelain=v2", "-z", "--untracked-files=all"]),
  );
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
  { tracked = true, untrackedPaths = [], untrackedLines = new Map(), changedPaths = "all" }: {
    tracked?: boolean;
    // From readGitStatus, relative to top.
    untrackedPaths?: string[];
    untrackedLines?: UntrackedLineCache;
    // Paths that changed since the cache was filled; their stat may still match.
    changedPaths?: Set<string> | "all";
  } = {},
): Promise<GitLineStats> {
  const readHeadToWorktreeNumstat = async () => {
    if (!tracked) return "";
    // An unborn branch compares against the empty tree, using the repository's
    // object format. hash-object without -w does not write any objects.
    const base = oid === "(initial)" ? (await gitOutput(top, ["hash-object", "-t", "tree", "--stdin"])).trim() : oid;
    return gitOutput(top, ["diff", "--numstat", "-z", "--no-ext-diff", "--no-textconv", base, "--"]);
  };
  // macOS keeps names as written (often NFD) while Git with core.precomposeUnicode
  // reports NFC, so cache keys and reported paths are compared in NFC.
  const changedKeys = changedPaths === "all" ? "all" : new Set([...changedPaths].map((path) => path.normalize("NFC")));
  const counted: UntrackedLineCache = new Map();
  let untrackedAdded = 0;
  let next = 0;
  const countUntracked = Array.from({ length: Math.min(4, untrackedPaths.length) }, async () => {
    while (next < untrackedPaths.length) {
      const path = untrackedPaths[next++];
      const key = path.normalize("NFC");
      const previous = changedKeys === "all" || changedKeys.has(key) ? undefined : untrackedLines.get(key);
      const entry = await countUntrackedLines(join(top, path), previous);
      if (!entry) continue;
      counted.set(key, entry);
      untrackedAdded += entry.lines;
    }
  });
  const numstat = readHeadToWorktreeNumstat();
  // Wait for every read, so a failed diff does not free its refresh slot while files are still being read.
  for (const result of await Promise.allSettled([numstat, ...countUntracked])) {
    if (result.status === "rejected") throw result.reason;
  }
  const stats = parseNumstat(await numstat);
  stats.added += untrackedAdded;
  untrackedLines.clear();
  for (const [path, entry] of counted) untrackedLines.set(path, entry);
  return stats;
}

export function zshQuote(value: string): string {
  return `'${value.replaceAll("'", "'\\''")}'`;
}

export function formatState(status: GitStatus, action: string): string {
  const pairs: Array<[string, string | number]> = [
    ["branch", status.branch],
    ["detached", status.detached ? "1" : ""],
    ["upstream", status.upstream],
    ["action", action],
    ["ahead", status.ahead],
    ["behind", status.behind],
    ["staged", status.staged],
    ["unstaged", status.unstaged],
    ["untracked", status.untrackedPaths.length],
    ["unmerged", status.unmerged],
    ["stash", status.stash],
    ["added", status.added],
    ["deleted", status.deleted],
  ];
  return pairs.flatMap(([key, value]) => [key, zshQuote(String(value))]).join(" ");
}

type GitActionProbe = (gitDir: string) => Promise<string | null>;

const marker = (path: string, label: string): GitActionProbe => async (gitDir) =>
  await exists(join(gitDir, path)) ? label : null;

// A multi-commit cherry-pick or revert is still in progress after its HEAD
// file is gone, as long as the sequencer has commands left.
const sequencerAction: GitActionProbe = async (gitDir) => {
  const todo = await readTextIfExists(join(gitDir, "sequencer", "todo"));
  const command = todo?.trimStart().split(/\s/, 1)[0];
  if (command === "p" || command === "pick") return "Cherry-picking";
  if (command === "revert") return "Reverting";
  return null;
};

const GIT_ACTIONS_BY_PRECEDENCE: GitActionProbe[] = [
  marker("rebase-merge", "Rebasing"),
  marker("rebase-apply/applying", "Applying"),
  marker("rebase-apply", "Rebasing"),
  marker("MERGE_HEAD", "Merging"),
  marker("CHERRY_PICK_HEAD", "Cherry-picking"),
  marker("REVERT_HEAD", "Reverting"),
  sequencerAction,
  marker("BISECT_LOG", "Bisecting"),
];

export async function detectGitAction(gitDir: string): Promise<string> {
  for (const probe of GIT_ACTIONS_BY_PRECEDENCE) {
    const label = await probe(gitDir);
    if (label) return label;
  }
  return "";
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

const WORKTREE_MARKER = /^worktrees\/[^/]+\/gitdir$/;

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
    ["not", ["anyof", ["dirname", "objects"], ["dirname", "lfs"]]],
    ["not", otherWorktreeState],
  ];
}

export async function listWorktreeTops(top: string): Promise<string[]> {
  const output = await gitOutput(top, ["worktree", "list", "--porcelain", "-z"]);
  const tops = output.split("\0").filter((field) => field.startsWith("worktree ")).map((field) => field.slice(9));
  const resolved = await Promise.all(tops.map((path) => Deno.realPath(path).catch(() => null)));
  return resolved.filter((path) => path !== null);
}

function mergePendingChanges(current: PendingChanges | null, change: PendingChanges): PendingChanges {
  const merged = current ??
    { worktreePaths: new Set<string>(), metadataChanged: false, mayHaveMissedWorktreeEvents: false };
  for (const path of change.worktreePaths) merged.worktreePaths.add(path);
  merged.metadataChanged ||= change.metadataChanged;
  merged.mayHaveMissedWorktreeEvents ||= change.mayHaveMissedWorktreeEvents;
  return merged;
}

// These files change how other paths are classified, even when they are ignored themselves.
const GIT_RULE_FILES = new Set([".gitignore", ".gitattributes", ".gitmodules"]);

export async function canSkipRefresh(top: string, paths: Set<string>): Promise<boolean> {
  if (paths.size === 0 || [...paths].some((path) => GIT_RULE_FILES.has(basename(path)))) return false;
  const inputs = [...paths];
  const child = new Deno.Command("git", {
    args: ["-C", top, "check-ignore", "--stdin", "-z", "--verbose", "--non-matching"],
    env: { GIT_OPTIONAL_LOCKS: "0" },
    stdin: "piped",
    stdout: "piped",
    stderr: "null",
  }).spawn();
  const stdout = new Response(child.stdout).arrayBuffer();
  const writer = child.stdin.getWriter();
  const inputWritten = writer.write(new TextEncoder().encode(inputs.map((path) => `${path}\0`).join("")))
    .then(() => writer.close())
    .then(() => true, () => false);
  const [{ code }, output, written] = await Promise.all([child.status, stdout, inputWritten]);
  if (!written || code !== 0) return false;
  // Four fields per input path, in input order. Matching by position avoids
  // comparing path spellings that Git may have precomposed. A pattern starting
  // with "!" re-includes the path.
  const fields = new TextDecoder().decode(output).split("\0");
  if (fields.length < inputs.length * 4) return false;
  return inputs.every((_, index) => {
    const pattern = fields[index * 4 + 2];
    return pattern !== "" && !pattern.startsWith("!");
  });
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

export class GitPromptDaemon {
  #client: WatchmanClient | null = null;
  #repos = new Map<string, RepoState>();
  #pendingRegistrations = new Map<string, Promise<RepoState>>();
  #clients = new Set<Client>();
  #subscriptionRepos = new Map<string, SubscriptionTarget>();
  #subscriptionSequence = 0;
  #queue: RepoState[] = [];
  #activeGit = 0;
  #reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  #shuttingDown = false;
  #logPath: string;
  // osUptime has second precision. Exclude that boundary second so a lock
  // created during this boot is never classified as belonging to an older boot.
  #bootTimeMs = Date.now() - (Deno.osUptime() + 1) * 1_000;

  #newClient: () => WatchmanClient;

  constructor(logPath: string, newClient: () => WatchmanClient = () => new watchman.Client()) {
    this.#logPath = logPath;
    this.#newClient = newClient;
    this.#createClient();
  }

  log(message: string): void {
    try {
      Deno.writeTextFileSync(this.#logPath, `${new Date().toISOString()} ${message}\n`, { append: true });
    } catch {
      // The prompt must stay quiet even when diagnostics cannot be written.
    }
  }

  async serve(conn: Deno.Conn): Promise<void> {
    const top = parseHello(await readLine(conn, MAX_HELLO_BYTES).catch(() => null) ?? "");
    if (this.#shuttingDown) return closeQuietly(conn);
    if (top === null) {
      await refuse(conn);
      return closeQuietly(conn);
    }
    const client: Client = { conn, top, latest: null, writing: false };
    this.#clients.add(client);
    // Watched from the start: a shell that leaves while the repository is being
    // registered or its worktree list reloaded must stop counting as observing.
    const peerClosed = conn.read(new Uint8Array(1)).catch(() => null).then(() => {
      this.#clients.delete(client);
      this.#detach(top);
    });
    try {
      const repo = await this.register(top);
      if (repo.worktreeTopsStale) {
        repo.worktreeTopsStale = false;
        await this.#reloadNestedWorktrees(repo);
      }
      if (this.#clients.has(client) && this.#isCurrent(repo)) this.#attach(repo, client);
      await peerClosed;
    } catch (error) {
      this.log(`subscription for ${top} failed: ${error}`);
      if (error instanceof TopRefused) await refuse(conn);
    } finally {
      this.#clients.delete(client);
      closeQuietly(conn);
      this.#detach(top);
    }
  }

  register(top: string): Promise<RepoState> {
    const existing = this.#repos.get(top);
    if (existing) return Promise.resolve(existing);
    const pending = this.#pendingRegistrations.get(top);
    if (pending) return pending;

    const registration = this.#registerNew(top).finally(() => {
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
      if (repo.idleTimer !== null) clearTimeout(repo.idleTimer);
    }
    // Their pending reads would keep the process alive.
    for (const client of this.#clients) closeQuietly(client.conn);
    this.#client?.end();
    this.#client = null;
  }

  #observed(repo: RepoState): boolean {
    for (const client of this.#clients) if (client.top === repo.top) return true;
    return false;
  }

  #attach(repo: RepoState, client: Client): void {
    if (repo.idleTimer !== null) clearTimeout(repo.idleTimer);
    repo.idleTimer = null;
    repo.expediteUntil = Date.now() + EXPEDITE_MS;
    if (repo.running || repo.queued) return;
    if (repo.pending !== null) this.#scheduleRefresh(repo, true);
    else if (repo.line === null) this.#markDirty(repo, UNKNOWN_CHANGES, true);
    else this.#send(client, repo.line);
  }

  #detach(top: string): void {
    const repo = this.#repos.get(top);
    // After shutdown() a new timer would keep the process alive.
    if (!repo || this.#shuttingDown || this.#observed(repo)) return;
    if (repo.timer !== null) clearTimeout(repo.timer);
    repo.timer = null;
    repo.idleTimer ??= setTimeout(() => this.#forget(repo), IDLE_FORGET_MS);
  }

  #publish(repo: RepoState): void {
    if (repo.line === null || !this.#isCurrent(repo)) return;
    for (const client of this.#clients) if (client.top === repo.top) this.#send(client, repo.line);
  }

  #send(client: Client, line: string): void {
    if (line === client.latest) return;
    client.latest = line;
    if (client.writing) return;
    client.writing = true;
    void (async () => {
      try {
        let sent: string | null = null;
        while (sent !== client.latest) {
          sent = client.latest;
          await writeAll(client.conn, new TextEncoder().encode(`${sent}\n`));
        }
      } catch {
        closeQuietly(client.conn);
      } finally {
        client.writing = false;
      }
    })();
  }

  async #registerNew(top: string): Promise<RepoState> {
    const metadata = await this.#resolveGitMetadata(top);
    if (metadata.top !== top) {
      throw new TopRefused(`${top} is not the top of a work tree (Git reports ${metadata.top})`);
    }
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
      line: null,
      expediteUntil: 0,
      idleTimer: null,
      subscriptions: new Set(),
      pending: null,
      pendingSince: null,
      running: false,
      queued: false,
      timer: null,
      untrackedLines: new Map(),
      worktreeTops: await listWorktreeTops(top).catch(() => []),
      worktreeTopsStale: false,
    };
    this.#repos.set(top, repo);
    try {
      await this.#subscribeRepo(repo);
    } catch (error) {
      this.#forget(repo);
      throw error;
    }
    this.log(`registered ${top} with ${repo.subscriptions.size} subscription(s)`);
    this.#markDirty(repo, UNKNOWN_CHANGES, true);
    return repo;
  }

  async #resolveGitMetadata(top: string): Promise<{ top: string; gitDir: string; commonDir: string }> {
    const result = await new Deno.Command("git", {
      args: ["-C", top, "rev-parse", "--path-format=absolute", "--show-toplevel", "--git-dir", "--git-common-dir"],
      stdout: "piped",
      stderr: "null",
    }).output();
    if (!result.success) throw new TopRefused(`git metadata resolution failed for ${top}`);
    const [gitTop, gitDir, commonDir] = new TextDecoder().decode(result.stdout).trimEnd().split("\n");
    if (!gitTop || !gitDir || !commonDir) throw new Error(`git metadata response was incomplete for ${top}`);
    return { top: resolve(gitTop), gitDir: resolve(gitDir), commonDir: resolve(commonDir) };
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
      // Starting from the current clock keeps the first notification from being
      // a fresh instance, so a later fresh instance means events were lost.
      const clock = await command(client, ["clock", watchRoot]);
      if (typeof clock.clock === "string") options.since = clock.clock;
      await command(client, ["subscribe", watchRoot, name, options]);
      if (!this.#isCurrent(repo)) {
        // The repository was forgotten while this subscription was being set up.
        void command(client, ["unsubscribe", watchRoot, name]).catch(() => undefined);
        return;
      }
      repo.subscriptions.add(name);
      this.#subscriptionRepos.set(name, {
        repo,
        metadataOnly: target.metadataOnly,
        watchRoot,
        lastWarning: null,
        namesRelativeTo: relativeRoot ? join(watchRoot, relativeRoot) : watchRoot,
      });
    }
  }

  #createClient(): void {
    const client = this.#newClient();
    this.#client = client;
    client.on("subscription", (response) => {
      const subscription = typeof response.subscription === "string" ? response.subscription : "";
      const target = this.#subscriptionRepos.get(subscription);
      const repo = target?.repo;
      if (!target || !repo || !this.#isCurrent(repo)) return;
      // Watchman cancels a subscription when its root goes away, for example a removed worktree.
      if (response.canceled === true) {
        this.#forget(repo);
        return;
      }
      // Watchman repeats a recrawl warning on every later notification, so only
      // a new warning means that events may have been lost.
      const warning = typeof response.warning === "string" ? response.warning : null;
      const recrawled = warning !== null && warning !== target.lastWarning;
      target.lastWarning = warning;
      if (response.is_fresh_instance === true || recrawled) {
        this.#markDirty(repo, UNKNOWN_CHANGES, false);
        return;
      }
      if (!Array.isArray(response.files) || response.files.length === 0) return;
      const names = response.files.filter((name): name is string => typeof name === "string");
      if (target.metadataOnly) {
        if (names.some((name) => WORKTREE_MARKER.test(name))) {
          if (this.#observed(repo)) void this.#reloadNestedWorktrees(repo);
          else repo.worktreeTopsStale = true;
        }
        const changesStatus = (name: string) =>
          !WORKTREE_MARKER.test(name) && !isInsideNestedWorktree(target.namesRelativeTo, name, repo.worktreeTops);
        if (names.some(changesStatus)) {
          this.#markDirty(repo, METADATA_CHANGES, false);
        }
        return;
      }
      if (names.length > 0) {
        this.#markDirty(repo, {
          worktreePaths: new Set(names),
          metadataChanged: false,
          mayHaveMissedWorktreeEvents: false,
        }, false);
      }
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
        this.#markDirty(repo, UNKNOWN_CHANGES, true);
      } catch (error) {
        this.log(`subscription restore failed for ${repo.top}: ${error}`);
        this.#forget(repo);
      }
    }
  }

  #isCurrent(repo: RepoState): boolean {
    return this.#repos.get(repo.id) === repo;
  }

  #forget(repo: RepoState): void {
    const current = this.#isCurrent(repo);
    if (current) this.#repos.delete(repo.id);
    if (repo.timer !== null) clearTimeout(repo.timer);
    repo.timer = null;
    if (repo.idleTimer !== null) clearTimeout(repo.idleTimer);
    repo.idleTimer = null;
    const client = this.#client;
    for (const name of repo.subscriptions) {
      const target = this.#subscriptionRepos.get(name);
      this.#subscriptionRepos.delete(name);
      if (client && target) void command(client, ["unsubscribe", target.watchRoot, name]).catch(() => undefined);
    }
    repo.subscriptions.clear();
    if (current) { for (const client of this.#clients) if (client.top === repo.top) closeQuietly(client.conn); }
    this.log(`forgot ${repo.top}`);
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
    if (!this.#isCurrent(repo)) return;
    const now = Date.now();
    repo.pendingSince ??= now;
    if (repo.running || repo.queued || !this.#observed(repo)) return;
    if (repo.timer !== null) clearTimeout(repo.timer);
    const delay = refreshDelay(now, repo.pendingSince, repo.expediteUntil, immediate);
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
      // Unobserved now: the changes stay pending, and #attach refreshes when a shell returns.
      if (!this.#isCurrent(repo) || !this.#observed(repo)) continue;
      const pending = repo.pending ?? UNKNOWN_CHANGES;
      repo.running = true;
      repo.pending = null;
      repo.pendingSince = null;
      this.#activeGit++;
      void this.#refresh(repo, pending).finally(() => {
        this.#activeGit--;
        repo.running = false;
        this.#publish(repo);
        if (repo.pending !== null) this.#scheduleRefresh(repo, false);
        this.#pumpQueue();
      });
    }
  }

  async #refresh(repo: RepoState, pending: PendingChanges): Promise<void> {
    try {
      if (
        !pending.metadataChanged && !pending.mayHaveMissedWorktreeEvents &&
        await canSkipRefresh(repo.top, pending.worktreePaths).catch(() => false)
      ) return;
      const status = await readGitStatus(repo.top);
      Object.assign(
        status,
        await readGitLineStats(repo.top, status.oid, {
          tracked: status.staged + status.unstaged + status.unmerged > 0,
          untrackedPaths: status.untrackedPaths,
          untrackedLines: repo.untrackedLines,
          changedPaths: pending.mayHaveMissedWorktreeEvents ? "all" : pending.worktreePaths,
        }),
      );
      repo.line = formatState(status, await detectGitAction(repo.gitDir));
    } catch (error) {
      this.log(`refresh failed for ${repo.top}: ${error}`);
      if (!await exists(repo.top).catch(() => true)) this.#forget(repo);
    }
  }
}

async function readLine(conn: Deno.Conn, maxBytes: number): Promise<string | null> {
  const bytes = new Uint8Array(maxBytes);
  let length = 0;
  while (length < maxBytes) {
    const count = await conn.read(bytes.subarray(length));
    if (count === null) return null;
    const newline = bytes.subarray(length, length + count).indexOf(10);
    if (newline >= 0) return new TextDecoder().decode(bytes.subarray(0, length + newline));
    length += count;
  }
  return null;
}

async function writeAll(conn: Deno.Conn, data: Uint8Array): Promise<void> {
  for (let written = 0; written < data.length;) written += await conn.write(data.subarray(written));
}

async function refuse(conn: Deno.Conn): Promise<void> {
  await writeAll(conn, new TextEncoder().encode(REFUSAL)).catch(() => undefined);
}

function closeQuietly(conn: Deno.Conn): void {
  try {
    conn.close();
  } catch {
    // Already closed.
  }
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
  let peerClosedRun = 0;
  try {
    while (!stopping) {
      let connection: Deno.Conn;
      try {
        connection = await listener.accept();
        acceptRetryMs = 25;
        peerClosedRun = 0;
      } catch (error) {
        if (stopping || error instanceof Deno.errors.BadResource) break;
        // A shell ran its next command before its connection was accepted.
        if ((error as { code?: string }).code === "EINVAL" && ++peerClosedRun <= 128) continue;
        daemon.log(`accept failed, retrying in ${acceptRetryMs}ms: ${error}`);
        await new Promise((resolvePromise) => setTimeout(resolvePromise, acceptRetryMs));
        acceptRetryMs = Math.min(acceptRetryMs * 2, 1_000);
        continue;
      }

      void daemon.serve(connection);
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
