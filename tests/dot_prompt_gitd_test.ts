import { assertEquals, assertStringIncludes } from "@std/assert";
import { join } from "node:path";
import {
  canSkipRefresh,
  detectGitAction,
  formatCache,
  GitPromptDaemon,
  minimizeWatchPaths,
  parseNumstat,
  parsePorcelainV2,
  readGitLineStats,
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

Deno.test("formatCache produces zsh-readable quoted key-value pairs", () => {
  const status = parsePorcelainV2("# branch.oid abcdef0123456789\n# branch.head feature/it's-safe\n");
  const cache = formatCache("/tmp/repo with spaces", "/tmp/cache file", status, "Rebasing");

  assertEquals(zshQuote("feature/it's-safe"), "'feature/it'\\''s-safe'");
  assertEquals(
    cache,
    "pwd '/tmp/repo with spaces' top '/tmp/repo with spaces' cache '/tmp/cache file' " +
      "branch 'feature/it'\\''s-safe' detached '' upstream '' action 'Rebasing' " +
      "ahead '0' behind '0' staged '0' unstaged '0' untracked '0' unmerged '0' stash '0' added '0' deleted '0'\n",
  );
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

for (const heldStep of ["temporary write", "rename"] as const) {
  Deno.test(`忘れて登録し直した repo のキャッシュを、${heldStep}で止まっていた古い refresh が上書きしない`, async () => {
    const root = await Deno.makeTempDir({ prefix: "dp-gitd-stale-" });
    const top = join(root, "repo");
    const cachePath = join(root, "cache", "status");
    const cacheHas = (text: string) => async () => (await Deno.readTextFile(cachePath).catch(() => "")).includes(text);
    const client = new FakeWatchmanClient();
    const daemon = new GitPromptDaemon(join(root, "daemon.log"), () => client);
    const realWriteTextFile = Deno.writeTextFile;
    const realRename = Deno.rename;
    let release = () => {};
    try {
      await Deno.mkdir(top);
      await git(top, "init", "-q", "-b", "main");
      await git(
        top,
        "-c",
        "user.name=t",
        "-c",
        "user.email=t@example.invalid",
        "commit",
        "-q",
        "--allow-empty",
        "-m",
        "base",
      );
      await daemon.register({ top, cachePath });
      await waitUntil(cacheHas("branch 'main'"));

      let holding = true;
      const gate = new Promise<void>((resolvePromise) => release = resolvePromise);
      let reportHeld = () => {};
      const held = new Promise<void>((resolvePromise) => reportHeld = resolvePromise);
      const holdOnce = async (path: string | URL) => {
        if (!holding || !String(path).endsWith(".tmp")) return;
        holding = false;
        reportHeld();
        await gate;
      };
      if (heldStep === "temporary write") {
        Deno.writeTextFile = (async (...args: Parameters<typeof Deno.writeTextFile>) => {
          await realWriteTextFile(...args);
          await holdOnce(args[0]);
        }) as typeof Deno.writeTextFile;
      } else {
        Deno.rename = async (from, to) => {
          await holdOnce(from);
          await realRename(from, to);
        };
      }

      await git(top, "checkout", "-qb", "old");
      const [worktreeSubscription, metadataSubscription] = client.subscriptionNames();
      client.emit("subscription", { subscription: metadataSubscription, files: ["HEAD"] });
      if (heldStep === "temporary write") await held;
      else await Promise.race([held, new Promise((resolvePromise) => setTimeout(resolvePromise, 1_500))]);

      client.emit("subscription", { subscription: worktreeSubscription, canceled: true });
      await git(top, "checkout", "-qb", "new");
      await daemon.register({ top, cachePath });
      await waitUntil(cacheHas("branch 'new'"));
      release();
      await waitUntil(() =>
        Promise.resolve([...Deno.readDirSync(join(root, "cache"))].every((entry) => !entry.name.endsWith(".tmp")))
      );
      assertStringIncludes(await Deno.readTextFile(cachePath), "branch 'new'");
    } finally {
      release();
      Deno.writeTextFile = realWriteTextFile;
      Deno.rename = realRename;
      daemon.shutdown();
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 100));
      await Deno.remove(root, { recursive: true });
    }
  });
}
