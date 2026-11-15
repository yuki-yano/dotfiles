import { assert, assertEquals, assertStringIncludes } from "@std/assert";
import { join } from "node:path";
import {
  canSkipRefresh,
  detectGitAction,
  formatState,
  GitPromptDaemon,
  MAX_CONCURRENT_GIT,
  minimizeWatchPaths,
  parseHello,
  parseNumstat,
  parsePorcelainV2,
  readGitLineStats,
  refreshDelay,
  removePreBootIndexLock,
  type WatchmanClient,
  zshQuote,
} from "../bin/dot-prompt-gitd.ts";

Deno.test("parsePorcelainV2 preserves the existing prompt counters", () => {
  const status = parsePorcelainV2([
    "# branch.oid 0123456789abcdef",
    "# branch.head feature/prompt-daemon",
    "# branch.upstream origin/feature/prompt-daemon",
    "# branch.ab +3 -2",
    "# stash 4",
    "1 M. N... 100644 100644 100644 a b tracked.ts",
    "1 .M N... 100644 100644 100644 a b modified.ts",
    "2 MM N... 100644 100644 100644 a b R100 renamed.ts\toriginal.ts",
    "u UU N... 100644 100644 100644 100644 a b c conflicted.ts",
    "? untracked.ts",
    "",
  ].join("\n"));

  assertEquals(status, {
    oid: "0123456789abcdef",
    branch: "feature/prompt-daemon",
    detached: false,
    upstream: "origin/feature/prompt-daemon",
    ahead: 3,
    behind: 2,
    staged: 2,
    unstaged: 2,
    untracked: 1,
    unmerged: 1,
    stash: 4,
    added: 0,
    deleted: 0,
  });
});

Deno.test("parsePorcelainV2 displays a detached commit using seven characters", () => {
  const status = parsePorcelainV2([
    "# branch.oid abcdef0123456789",
    "# branch.head (detached)",
  ].join("\n"));

  assertEquals(status.branch, "abcdef0");
  assertEquals(status.detached, true);
});

Deno.test("formatState は固定順の zsh クォート済みのキーと値を出す", () => {
  const status = parsePorcelainV2("# branch.oid abcdef0123456789\n# branch.head feature/it's-safe\n");

  assertEquals(zshQuote("feature/it's-safe"), "'feature/it'\\''s-safe'");
  assertEquals(
    formatState(status, "Rebasing"),
    "branch 'feature/it'\\''s-safe' detached '' upstream '' action 'Rebasing' " +
      "ahead '0' behind '0' staged '0' unstaged '0' untracked '0' unmerged '0' stash '0' added '0' deleted '0'",
  );
});

Deno.test("parseHello は top だけを持つ絶対パスの JSON を受け付け、旧形式・相対パス・不正な JSON を拒否する", () => {
  assertEquals(parseHello('{"top":"/repo/with space"}'), "/repo/with space");
  assertEquals(parseHello('{"top":"/repo/"}'), "/repo");
  assertEquals(parseHello('{"top":"/repo","cachePath":"/cache"}'), null);
  assertEquals(parseHello('{"top":"repo"}'), null);
  assertEquals(parseHello('{"top":""}'), null);
  assertEquals(parseHello('{"top":1}'), null);
  assertEquals(parseHello('["/repo"]'), null);
  assertEquals(parseHello("null"), null);
  assertEquals(parseHello('{"top":"/repo"'), null);
  assertEquals(parseHello(""), null);
});

Deno.test("refreshDelay は shell の接続直後だけ debounce を省く", () => {
  const now = 10_000;
  // Inside the window that a connecting shell opens.
  assertEquals(refreshDelay(now, now, now + 1, false), 0);
  // The window has passed: the usual debounce.
  assertEquals(refreshDelay(now, now, now, false), 300);
  assertEquals(refreshDelay(now, now, 0, false), 300);
  // A change that has waited long is not delayed past two seconds in total.
  assertEquals(refreshDelay(now, now - 1_900, 0, false), 100);
  assertEquals(refreshDelay(now, now - 5_000, 0, false), 0);
  assertEquals(refreshDelay(now, now, 0, true), 0);
});

Deno.test("numstat はバイナリを除き、改行・タブを含むパスと rename を集計する", () => {
  assertEquals(
    parseNumstat(
      "3\t2\tfile\nwith\ttabs\0-\t-\tbinary\0" +
        "1\t4\t\0old\0" + "999\t999\tnew\0" +
        "0\t2\tdeleted\0",
    ),
    { added: 4, deleted: 8 },
  );
});

async function git(top: string, ...args: string[]): Promise<string> {
  const result = await new Deno.Command("git", {
    args: ["-C", top, ...args],
    stdout: "piped",
    stderr: "piped",
  }).output();
  if (!result.success) throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout).trim();
}

Deno.test("HEAD からの変更と未追跡ファイルの全行を合算し、部分 stage を二重計上しない", async () => {
  const top = await Deno.makeTempDir({ prefix: "dp-gitd-lines-" });
  try {
    await git(top, "init", "-q");
    await git(top, "config", "user.email", "prompt-test@example.invalid");
    await git(top, "config", "user.name", "prompt-test");
    await Deno.writeTextFile(join(top, ".gitignore"), "ignored/\n");
    await Deno.writeTextFile(join(top, "partial.txt"), "original\n");
    await Deno.writeTextFile(join(top, "deleted.txt"), "one\ntwo\n");
    await Deno.writeTextFile(join(top, "renamed.txt"), "unchanged\n");
    await Deno.writeFile(join(top, "tracked.bin"), new Uint8Array([0, 1, 10]));
    await git(top, "add", ".");
    await git(top, "commit", "-qm", "initial");
    const oid = await git(top, "rev-parse", "HEAD");
    assertEquals(await readGitLineStats(top, oid), { added: 0, deleted: 0 });

    await Deno.writeTextFile(join(top, "partial.txt"), "staged\n");
    await git(top, "add", "partial.txt");
    await Deno.writeTextFile(join(top, "partial.txt"), "final\nextra\n");
    await Deno.remove(join(top, "deleted.txt"));
    await git(top, "mv", "renamed.txt", "renamed\nwith\ttabs.txt");
    await Deno.writeFile(join(top, "tracked.bin"), new Uint8Array([0, 2, 10, 10]));
    await Deno.writeTextFile(join(top, "new-staged.txt"), "new staged\n");
    await git(top, "add", "new-staged.txt");
    await Deno.mkdir(join(top, "untracked dir"));
    await Deno.writeTextFile(join(top, "untracked dir", "new\nwith\ttabs.txt"), "a\nb");
    await Deno.writeTextFile(join(top, "untracked dir", "crlf.txt"), "a\r\nb\r\n");
    await Deno.writeTextFile(join(top, "empty.txt"), "");
    await Deno.writeFile(join(top, "untracked.bin"), new Uint8Array([0, 10, 10]));
    await Deno.mkdir(join(top, "ignored"));
    await Deno.writeTextFile(join(top, "ignored", "skip.txt"), "ignored\n".repeat(100));
    await Deno.symlink("ignored/skip.txt", join(top, "link.txt"));
    await Deno.symlink("missing.txt", join(top, "broken-link.txt"));
    const indexBefore = await Deno.readFile(join(top, ".git", "index"));

    assertEquals(await readGitLineStats(top, oid), { added: 9, deleted: 3 });
    assertEquals(await Deno.readFile(join(top, ".git", "index")), indexBefore);
    // Returning the worktree to HEAD cancels its staged edit in the net total.
    await Deno.writeTextFile(join(top, "partial.txt"), "original\n");
    assertEquals(await readGitLineStats(top, oid), { added: 7, deleted: 2 });
  } finally {
    await Deno.remove(top, { recursive: true });
  }
});

Deno.test("初回 commit 前も stage 済みと未追跡を集計し、大きなテキストを最後まで読む", async () => {
  for (const objectFormat of ["sha1", "sha256"]) {
    const top = await Deno.makeTempDir({ prefix: "dp-gitd-unborn-" });
    try {
      await git(top, "init", "-q", `--object-format=${objectFormat}`);
      await Deno.writeTextFile(join(top, "staged.txt"), "first\n");
      await git(top, "add", "staged.txt");
      await Deno.writeTextFile(join(top, "staged.txt"), "first\nsecond");
      await Deno.writeTextFile(join(top, "large.txt"), "a\n".repeat(40_000) + "last");
      await Deno.writeFile(join(top, "binary"), new Uint8Array([10, 0, 10]));
      assertEquals(await readGitLineStats(top, "(initial)"), { added: 40_003, deleted: 0 });
    } finally {
      await Deno.remove(top, { recursive: true });
    }
  }
});

Deno.test("未追跡ファイルの行数は変わったファイルだけ読み直し、消えたファイルを外す", async () => {
  const top = await Deno.makeTempDir({ prefix: "dp-gitd-line-cache-" });
  try {
    await git(top, "init", "-q");
    await git(top, "config", "user.email", "prompt-test@example.invalid");
    await git(top, "config", "user.name", "prompt-test");
    await Deno.writeTextFile(join(top, "tracked.txt"), "tracked\n");
    await git(top, "add", "tracked.txt");
    await git(top, "commit", "-qm", "initial");
    const oid = await git(top, "rev-parse", "HEAD");
    await Deno.writeTextFile(join(top, "edited.txt"), "a\nb\n");
    await Deno.writeTextFile(join(top, "unchanged-unreadable.txt"), "c\n");
    const untrackedLines = new Map();

    assertEquals(await readGitLineStats(top, oid, { tracked: false, untrackedLines }), { added: 3, deleted: 0 });
    await Deno.chmod(join(top, "unchanged-unreadable.txt"), 0o000);
    await Deno.writeTextFile(join(top, "edited.txt"), "a\nb\nc\n");
    assertEquals(
      await readGitLineStats(top, oid, { tracked: false, untrackedLines, changedPaths: new Set(["edited.txt"]) }),
      { added: 4, deleted: 0 },
    );

    await Deno.remove(join(top, "unchanged-unreadable.txt"));
    assertEquals(
      await readGitLineStats(top, oid, {
        tracked: false,
        untrackedLines,
        changedPaths: new Set(["unchanged-unreadable.txt"]),
      }),
      { added: 3, deleted: 0 },
    );
    assertEquals([...untrackedLines.keys()], ["edited.txt"]);
  } finally {
    await Deno.remove(top, { recursive: true });
  }
});

Deno.test("detectGitAction は衝突を解消して commit した後も、残りのある cherry-pick を進行中とする", async () => {
  const top = await Deno.makeTempDir({ prefix: "dp-gitd-sequencer-" });
  try {
    await git(top, "init", "-q");
    await git(top, "config", "user.email", "prompt-test@example.invalid");
    await git(top, "config", "user.name", "prompt-test");
    await Deno.writeTextFile(join(top, "a.txt"), "base\n");
    await git(top, "add", "a.txt");
    await git(top, "commit", "-qm", "base");
    const main = await git(top, "branch", "--show-current");
    await git(top, "checkout", "-qb", "side");
    await Deno.writeTextFile(join(top, "a.txt"), "side\n");
    await git(top, "commit", "-qam", "conflicting");
    await Deno.writeTextFile(join(top, "b.txt"), "later\n");
    await git(top, "add", "b.txt");
    await git(top, "commit", "-qm", "later");
    await git(top, "checkout", "-q", main);
    await Deno.writeTextFile(join(top, "a.txt"), "main\n");
    await git(top, "commit", "-qam", "main");

    const pick = await new Deno.Command("git", {
      args: ["-C", top, "cherry-pick", "side~1", "side"],
      stdout: "null",
      stderr: "null",
    }).output();
    assertEquals(pick.success, false);
    const gitDir = join(top, ".git");
    assertEquals(await detectGitAction(gitDir), "Cherry-picking");

    await Deno.writeTextFile(join(top, "a.txt"), "resolved\n");
    await git(top, "add", "a.txt");
    await git(top, "commit", "-q", "--no-edit");
    assertEquals(await detectGitAction(gitDir), "Cherry-picking");

    await git(top, "cherry-pick", "--continue");
    assertEquals(await detectGitAction(gitDir), "");
  } finally {
    await Deno.remove(top, { recursive: true });
  }
});

Deno.test("detectGitAction は進行中の Git の操作を優先順に表示名へ変える", async () => {
  const gitDir = await Deno.makeTempDir({ prefix: "dp-gitd-action-" });
  try {
    assertEquals(await detectGitAction(gitDir), "");
    const steps: Array<[string, string]> = [
      ["BISECT_LOG", "Bisecting"],
      ["REVERT_HEAD", "Reverting"],
      ["CHERRY_PICK_HEAD", "Cherry-picking"],
      ["MERGE_HEAD", "Merging"],
    ];
    for (const [file, label] of steps) {
      await Deno.writeTextFile(join(gitDir, file), "");
      assertEquals(await detectGitAction(gitDir), label);
    }
    await Deno.mkdir(join(gitDir, "rebase-apply"));
    assertEquals(await detectGitAction(gitDir), "Rebasing");
    await Deno.writeTextFile(join(gitDir, "rebase-apply", "applying"), "");
    assertEquals(await detectGitAction(gitDir), "Applying");
    await Deno.mkdir(join(gitDir, "rebase-merge"));
    assertEquals(await detectGitAction(gitDir), "Rebasing");
  } finally {
    await Deno.remove(gitDir, { recursive: true });
  }
});

Deno.test("minimizeWatchPaths keeps external linked-worktree metadata only once", () => {
  assertEquals(
    minimizeWatchPaths([
      "/repos/main/.git/worktrees/feature",
      "/repos/feature",
      "/repos/main/.git",
      "/repos/feature",
    ]),
    ["/repos/feature", "/repos/main/.git"],
  );
});

Deno.test("canSkipRefresh は全パスが ignore 対象で、ignore 規則のファイルを含まないときだけ true を返す", async () => {
  const repo = await Deno.makeTempDir({ prefix: "dp-gitd-ignore-" });
  try {
    await git(repo, "init", "-q");
    await Deno.writeTextFile(join(repo, ".gitignore"), "ignored/\n*.log\n!keep.log\n");
    await Deno.mkdir(join(repo, "ignored"));
    await Deno.writeTextFile(join(repo, "ignored", "forced.txt"), "tracked\n");
    await Deno.writeTextFile(join(repo, "ignored", ".gitignore"), "!keep.log\n");
    await git(repo, "add", ".gitignore");
    await git(repo, "add", "-f", "ignored/forced.txt");

    assertEquals(await canSkipRefresh(repo, new Set(["ignored/a.txt", "debug.log"])), true);
    assertEquals(await canSkipRefresh(repo, new Set(["ignored/deleted-before-check.txt"])), true);
    assertEquals(await canSkipRefresh(repo, new Set(["ignored/a.txt", "tracked.txt"])), false);
    assertEquals(await canSkipRefresh(repo, new Set(["ignored/forced.txt"])), false);
    assertEquals(await canSkipRefresh(repo, new Set(["ignored/.gitignore"])), false);
    assertEquals(await canSkipRefresh(repo, new Set(["debug.log", "keep.log"])), false);
    assertEquals(await canSkipRefresh(repo, new Set(["../outside.txt"])), false);
    assertEquals(await canSkipRefresh(repo, new Set()), false);

    const manyIgnored = Array.from({ length: 100_000 }, (_, index) => `ignored/file-${index}.txt`);
    assertEquals(await canSkipRefresh(repo, new Set(["../outside.txt", ...manyIgnored])), false);
  } finally {
    await Deno.remove(repo, { recursive: true });
  }
});

Deno.test("前回起動時の index.lock だけを除去し、index の内容を保持する", async () => {
  const gitDir = await Deno.makeTempDir({ prefix: "dp-gitd-recovery-" });
  try {
    const indexPath = join(gitDir, "index");
    const lockPath = join(gitDir, "index.lock");
    await Deno.writeTextFile(indexPath, "existing index\n");
    await Deno.writeTextFile(lockPath, "interrupted index write\n");
    // Simulate rebooting after these fixture files were created.
    const bootTimeMs = Date.now() + 10_000;
    assertEquals(removePreBootIndexLock(gitDir, bootTimeMs), true);
    assertEquals(await Deno.readTextFile(indexPath), "existing index\n");
    assertEquals(removePreBootIndexLock(gitDir, bootTimeMs), false);
  } finally {
    await Deno.remove(gitDir, { recursive: true });
  }
});

Deno.test("今回起動後のロックは mtime が古くても除去しない", async () => {
  const gitDir = await Deno.makeTempDir({ prefix: "dp-gitd-live-lock-" });
  try {
    const bootTimeMs = Date.now() - (Deno.osUptime() + 1) * 1_000;
    const lockPath = join(gitDir, "index.lock");
    await Deno.writeTextFile(lockPath, "active index write\n");
    assertEquals(removePreBootIndexLock(gitDir, bootTimeMs), false);
    const oldTime = new Date(bootTimeMs - 60_000);
    await Deno.utime(lockPath, oldTime, oldTime);
    assertEquals(removePreBootIndexLock(gitDir, bootTimeMs), false);
    assertEquals(await Deno.readTextFile(lockPath), "active index write\n");
  } finally {
    await Deno.remove(gitDir, { recursive: true });
  }
});

Deno.test("起動時刻の境界にあるロックと不正な起動時刻では除去しない", async () => {
  const gitDir = await Deno.makeTempDir({ prefix: "dp-gitd-lock-boundary-" });
  try {
    const lockPath = join(gitDir, "index.lock");
    await Deno.writeTextFile(lockPath, "lock\n");
    const stat = await Deno.lstat(lockPath);
    assertEquals(removePreBootIndexLock(gitDir, stat.mtime!.getTime()), false);
    assertEquals(removePreBootIndexLock(gitDir, stat.ctime!.getTime()), false);
    for (const bootTimeMs of [0, -1, NaN, Infinity]) {
      assertEquals(removePreBootIndexLock(gitDir, bootTimeMs), false);
    }
    assertEquals(await Deno.readTextFile(lockPath), "lock\n");
  } finally {
    await Deno.remove(gitDir, { recursive: true });
  }
});

Deno.test("index.lock が symlink や directory なら除去しない", async () => {
  const gitDir = await Deno.makeTempDir({ prefix: "dp-gitd-lock-type-" });
  try {
    const indexPath = join(gitDir, "index");
    const lockPath = join(gitDir, "index.lock");
    await Deno.writeTextFile(indexPath, "existing index\n");
    await Deno.symlink(indexPath, lockPath);
    assertEquals(removePreBootIndexLock(gitDir, Date.now() + 10_000), false);
    assertEquals((await Deno.lstat(lockPath)).isSymlink, true);
    assertEquals(await Deno.readTextFile(indexPath), "existing index\n");
    await Deno.remove(lockPath);
    await Deno.mkdir(lockPath);
    assertEquals(removePreBootIndexLock(gitDir, Date.now() + 10_000), false);
    assertEquals((await Deno.lstat(lockPath)).isDirectory, true);
  } finally {
    await Deno.remove(gitDir, { recursive: true });
  }
});

class FakeWatchmanClient implements WatchmanClient {
  readonly commands: unknown[][] = [];
  #listeners = new Map<string, (value: never) => void>();

  command(args: unknown[], callback: (error: Error | null, response: Record<string, unknown>) => void): void {
    this.commands.push(args);
    const response = args[0] === "watch" || args[0] === "watch-project"
      ? { watch: args[1] }
      : args[0] === "clock"
      ? { clock: "c:1:1" }
      : {};
    queueMicrotask(() => callback(null, response));
  }

  on(event: string, callback: (value: never) => void): void {
    this.#listeners.set(event, callback);
  }

  emit(event: string, value: unknown): void {
    this.#listeners.get(event)?.(value as never);
  }

  end(): void {}

  subscriptionNames(): string[] {
    return this.commands.filter((args) => args[0] === "subscribe").map((args) => String(args[2]));
  }
}

async function waitUntil(predicate: () => Promise<boolean>, timeoutMs = 5_000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 20));
  }
  throw new Error(`condition was not met within ${timeoutMs}ms`);
}

// Tests must fail, not hang, when an expected close or reply never comes.
async function within<T>(promise: Promise<T>, what: string, timeoutMs = 7_000): Promise<T> {
  const { promise: timeout, reject } = Promise.withResolvers<never>();
  const timer = setTimeout(() => reject(new Error(`${what} did not happen within ${timeoutMs}ms`)), timeoutMs);
  try {
    return await Promise.race([promise, timeout]);
  } finally {
    clearTimeout(timer);
  }
}

interface AttachedShell extends AsyncDisposable {
  lines: string[];
  closed: Promise<void>;
  latest(): string;
}

// Connects like a shell does: daemon.serve() owns the accepted side.
async function attachShell(daemon: GitPromptDaemon, socketDir: string, top: string): Promise<AttachedShell> {
  const path = join(socketDir, `shell-${crypto.randomUUID().slice(0, 8)}.sock`);
  const listener = Deno.listen({ transport: "unix", path });
  const conn = await Deno.connect({ transport: "unix", path });
  const served = daemon.serve(await listener.accept());
  listener.close();
  await conn.write(new TextEncoder().encode(`${JSON.stringify({ top })}\n`));
  const lines: string[] = [];
  const closed = (async () => {
    const buffer = new Uint8Array(4_096);
    let text = "";
    while (true) {
      const count = await conn.read(buffer).catch(() => null);
      if (count === null) return;
      text += new TextDecoder().decode(buffer.subarray(0, count));
      const complete = text.split("\n");
      text = complete.pop() ?? "";
      lines.push(...complete);
    }
  })();
  return {
    lines,
    closed,
    latest: () => lines.at(-1) ?? "",
    async [Symbol.asyncDispose]() {
      try {
        conn.close();
      } catch {
        // The daemon closed it first.
      }
      await Promise.all([closed, served]);
    },
  };
}

interface DaemonFixture extends AsyncDisposable {
  root: string;
  top: string;
  daemon: GitPromptDaemon;
  watchman: FakeWatchmanClient;
  /** Emits a Watchman notification for the work tree or for the Git directory. */
  notify(kind: "worktree" | "metadata", body: Record<string, unknown>): void;
  /** Every Git invocation for a work tree so far, in order, as its arguments after `-C <top>`. */
  gitCalls(top?: string): string[];
  statusCalls(): number;
  /**
   * Makes the next `git <command>` finish reading and then wait before answering.
   * held() resolves with what that command read, once it has been read.
   */
  holdNext(command: "status" | "worktree"): { held(): Promise<string>; release(): void };
}

// A repository on branch main, a daemon with a fake Watchman, and a Git shim that counts and can hold
// `git status` and `git worktree`.
async function daemonFixture(): Promise<DaemonFixture> {
  const root = await Deno.realPath(await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-unit-" }));
  const top = join(root, "repo");
  const callLog = join(root, "git-calls.log");
  const gate = join(root, "gate");
  const realGit = (await git(root, "--exec-path")) + "/git";
  await Deno.mkdir(join(root, "bin"));
  await Deno.writeTextFile(
    join(root, "bin", "git"),
    [
      "#!/bin/sh",
      `printf '%s\\n' "$*" >> '${callLog}'`,
      "for command in status worktree; do",
      `  case " $* " in *" $command "*)`,
      `    if mv '${gate}'.$command '${gate}'.$$ 2>/dev/null; then`,
      `      hold=$(cat '${gate}'.$$)`,
      `      '${realGit}' "$@" > "$hold.out"; code=$?`,
      // $hold.held appears only after Git has read the state, so held() also waits for the read.
      `      mv '${gate}'.$$ "$hold.held"`,
      `      while [ -e "$hold.held" ]; do sleep 0.02; done`,
      `      cat "$hold.out"; exit $code`,
      "    fi;;",
      "  esac",
      "done",
      `exec '${realGit}' "$@"`,
      "",
    ].join("\n"),
    { mode: 0o755 },
  );
  await Deno.mkdir(top);
  await git(top, "init", "-q", "-b", "main");
  await Deno.writeTextFile(join(top, "tracked.txt"), "initial\n");
  await git(top, "add", "tracked.txt");
  await git(top, "-c", "user.name=t", "-c", "user.email=t@example.invalid", "commit", "-qm", "base");
  const originalPath = Deno.env.get("PATH") ?? "";
  Deno.env.set("PATH", `${join(root, "bin")}:${originalPath}`);
  const watchman = new FakeWatchmanClient();
  const daemon = new GitPromptDaemon(join(root, "daemon.log"), () => watchman);
  const exists = (path: string) => Deno.stat(path).then(() => true, () => false);
  const holds: string[] = [];
  const gitCalls = (of = top) =>
    Deno.readTextFileSync(callLog).split("\n").filter((line) => line.startsWith(`-C ${of} `))
      .map((line) => line.slice(`-C ${of} `.length));
  return {
    root,
    top,
    daemon,
    watchman,
    notify(kind, body) {
      const [worktree, metadata] = watchman.subscriptionNames().slice(-2);
      watchman.emit("subscription", { subscription: kind === "worktree" ? worktree : metadata, ...body });
    },
    gitCalls,
    statusCalls: () => gitCalls().filter((call) => call.startsWith("status ")).length,
    holdNext(command) {
      const hold = `${gate}-${holds.length}`;
      holds.push(hold);
      Deno.writeTextFileSync(`${gate}.${command}`, hold);
      return {
        async held() {
          await waitUntil(() => exists(`${hold}.held`));
          return await Deno.readTextFile(`${hold}.out`);
        },
        release: () => Deno.removeSync(`${hold}.held`),
      };
    },
    async [Symbol.asyncDispose]() {
      for (const hold of holds) await Deno.remove(`${hold}.held`).catch(() => undefined);
      daemon.shutdown();
      Deno.env.set("PATH", originalPath);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
      await Deno.remove(root, { recursive: true });
    },
  };
}

const has = (shell: AttachedShell, text: string) => () => Promise.resolve(shell.latest().includes(text));
const pause = (ms: number) => new Promise((resolvePromise) => setTimeout(resolvePromise, ms));

Deno.test("忘れて登録し直した repo の shell へ、止まっていた古い refresh の状態を送らない", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  await using before = await attachShell(daemon, root, top);
  await waitUntil(has(before, "branch 'main'"));

  await git(top, "checkout", "-qb", "old");
  const hold = fixture.holdNext("status");
  fixture.notify("metadata", { files: ["HEAD"] });
  // The refresh that is about to be overtaken has already read the old branch.
  assertStringIncludes(await hold.held(), "# branch.head old\n");

  fixture.notify("worktree", { canceled: true });
  await within(before.closed, "closing the shell of the forgotten repository");
  await git(top, "checkout", "-qb", "new");
  await using after = await attachShell(daemon, root, top);
  await waitUntil(has(after, "branch 'new'"));

  hold.release();
  await pause(500);
  assertEquals(after.lines.filter((line) => line.includes("branch 'old'")), []);
  assertStringIncludes(after.latest(), "branch 'new'");
});

Deno.test("どの shell もプロンプトにいない repo ではイベントが来ても git を起動せず、shell が戻ったときに1回だけ更新する", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  {
    await using shell = await attachShell(daemon, root, top);
    await waitUntil(has(shell, "unstaged '0'"));
  }
  const callsWhileObserved = fixture.statusCalls();
  const gitCallsWhileObserved = fixture.gitCalls();

  await Deno.writeTextFile(join(top, "tracked.txt"), "changed\n");
  fixture.notify("worktree", { files: ["tracked.txt"] });
  await pause(700);
  fixture.notify("worktree", { files: ["tracked.txt"] });
  await pause(700);
  assertEquals(fixture.gitCalls(), gitCallsWhileObserved);

  await using back = await attachShell(daemon, root, top);
  await waitUntil(() => Promise.resolve(back.lines.length > 0));
  // The state from before the change is never shown to the returning shell.
  assertStringIncludes(back.lines[0], "unstaged '1'");
  await pause(500);
  assertEquals(fixture.statusCalls(), callsWhileObserved + 1);
});

Deno.test("refresh の順番待ちの間に最後の shell が離れた repo では git を起動せず、shell が戻ったときに1回だけ更新する", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  // Held refreshes fill every slot, so the next repository has to wait its turn.
  const holds = [];
  await using stack = new AsyncDisposableStack();
  for (let index = 0; index < MAX_CONCURRENT_GIT; index++) {
    const other = join(root, `other-${index}`);
    await git(root, "init", "-q", "-b", "main", other);
    const hold = fixture.holdNext("status");
    stack.use(await attachShell(daemon, root, other));
    await hold.held();
    holds.push(hold);
  }

  const registered = ["rev-parse ", "worktree list "];
  const startsLike = (calls: string[], prefixes: string[]) =>
    calls.length === prefixes.length && calls.every((call, index) => call.startsWith(prefixes[index]));
  {
    await using shell = await attachShell(daemon, root, top);
    await waitUntil(() => Promise.resolve(startsLike(fixture.gitCalls(), registered)));
    // Long enough for the first refresh to be queued behind the held ones.
    await pause(200);
    assertEquals(shell.lines, []);
  }
  for (const hold of holds) hold.release();
  await pause(700);
  assert(startsLike(fixture.gitCalls(), registered), `git ran with no shell: ${fixture.gitCalls().join(" | ")}`);

  await using back = await attachShell(daemon, root, top);
  await waitUntil(has(back, "branch 'main'"));
  await pause(300);
  assertEquals(fixture.statusCalls(), 1);
});

Deno.test("どの shell もプロンプトにいない間に worktree が増減しても git を起動せず、shell が戻ったときに一覧を読み直してから更新する", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  {
    await using shell = await attachShell(daemon, root, top);
    await waitUntil(has(shell, "unstaged '0'"));
  }
  const before = fixture.gitCalls().length;

  await Deno.writeTextFile(join(top, "tracked.txt"), "changed\n");
  fixture.notify("metadata", { files: ["worktrees/added/gitdir"] });
  fixture.notify("worktree", { files: ["tracked.txt"] });
  await pause(700);
  assertEquals(fixture.gitCalls().slice(before), []);

  await using back = await attachShell(daemon, root, top);
  await waitUntil(has(back, "unstaged '1'"));
  const after = fixture.gitCalls().slice(before).map((call) => call.split(" ")[0]);
  assertEquals(after.filter((name) => name === "worktree").length, 1);
  assert(after.indexOf("worktree") < after.indexOf("status"), `the list was read after the refresh: ${after}`);

  // With a shell at the prompt, the list is read again as soon as it changes.
  const observed = fixture.gitCalls().length;
  fixture.notify("metadata", { files: ["worktrees/added/gitdir"] });
  await waitUntil(() =>
    Promise.resolve(fixture.gitCalls().slice(observed).some((call) => call.startsWith("worktree ")))
  );
});

Deno.test("worktree 一覧の読み直しを待つ間に shell が離れた repo では、その後の通知でも読み直しの後でも git を起動しない", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  {
    await using shell = await attachShell(daemon, root, top);
    await waitUntil(has(shell, "unstaged '0'"));
  }
  fixture.notify("metadata", { files: ["worktrees/added/gitdir"] });
  const reload = fixture.holdNext("worktree");
  const shell = await attachShell(daemon, root, top);
  await reload.held();
  // Starts by closing the connection; the rest waits for the held reload.
  const leaving = shell[Symbol.asyncDispose]();
  await pause(100);
  const before = fixture.gitCalls().length;

  await Deno.writeTextFile(join(top, "tracked.txt"), "changed\n");
  fixture.notify("metadata", { files: ["worktrees/added/gitdir"] });
  fixture.notify("worktree", { files: ["tracked.txt"] });
  reload.release();
  await leaving;
  await pause(700);
  assertEquals(fixture.gitCalls().slice(before), []);
});

Deno.test("refresh 中に接続した shell にも、完了後の状態を送る", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  await using first = await attachShell(daemon, root, top);
  await waitUntil(has(first, "unstaged '0'"));

  await Deno.writeTextFile(join(top, "tracked.txt"), "changed\n");
  const hold = fixture.holdNext("status");
  fixture.notify("worktree", { files: ["tracked.txt"] });
  await hold.held();
  await using second = await attachShell(daemon, root, top);
  await pause(200);
  assertEquals(second.lines, []);

  hold.release();
  await waitUntil(has(second, "unstaged '1'"));
  await waitUntil(has(first, "unstaged '1'"));
});

Deno.test("購読が cancel された repo の接続は何も送らずに閉じ、git が最上位と認めないパスの接続は拒否の行を送ってから閉じる", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  await using shell = await attachShell(daemon, root, top);
  await waitUntil(has(shell, "branch 'main'"));
  fixture.notify("worktree", { canceled: true });
  await within(shell.closed, "closing the shell of the cancelled repository");
  // Only the earlier state line: a cancel sends no refusal, so the shell reconnects.
  assertEquals(shell.lines.length, 1);

  await Deno.mkdir(join(top, "sub", ".git"), { recursive: true });
  await using inSubdirectory = await attachShell(daemon, root, join(top, "sub"));
  await within(inSubdirectory.closed, "rejecting a path that is not the top");
  assertEquals(inSubdirectory.lines, ["refused"]);

  await using notARepository = await attachShell(daemon, root, root);
  await within(notARepository.closed, "rejecting a path outside any repository");
  assertEquals(notARepository.lines, ["refused"]);
});

Deno.test("接続直後のイベントは debounce を待たずに更新し、窓を過ぎたイベントには debounce をかける", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  let generation = 0;
  const changeAndMeasure = async (shell: AttachedShell) => {
    const expected = `added '${++generation}'`;
    await Deno.writeTextFile(join(top, "tracked.txt"), "initial\n" + "more\n".repeat(generation));
    const start = performance.now();
    fixture.notify("worktree", { files: ["tracked.txt"] });
    await waitUntil(has(shell, expected));
    return performance.now() - start;
  };

  await using waiting = await attachShell(daemon, root, top);
  await waitUntil(has(waiting, "unstaged '0'"));
  await pause(400);
  const debounced = await changeAndMeasure(waiting);
  assert(debounced >= 300, `expected the 300 ms debounce, got ${debounced} ms`);

  // The fastest of three tries, so that a busy machine does not fail the test.
  let fastest = Infinity;
  for (let attempt = 0; attempt < 3 && fastest >= 300; attempt++) {
    await pause(400);
    await using returning = await attachShell(daemon, root, top);
    await waitUntil(() => Promise.resolve(returning.lines.length > 0));
    fastest = Math.min(fastest, await changeAndMeasure(returning));
  }
  assert(fastest < 300, `expected an update without the debounce, got ${fastest} ms`);
});

Deno.test("同じ状態の refresh では、同じ接続へ行を送り直さない", async () => {
  await using fixture = await daemonFixture();
  const { top, daemon, root } = fixture;
  await using shell = await attachShell(daemon, root, top);
  await waitUntil(has(shell, "unstaged '0'"));
  const calls = fixture.statusCalls();

  const now = new Date();
  await Deno.utime(join(top, "tracked.txt"), now, now);
  fixture.notify("worktree", { files: ["tracked.txt"] });
  await waitUntil(() => Promise.resolve(fixture.statusCalls() > calls));
  await pause(300);
  assertEquals(shell.lines.length, 1);
});
