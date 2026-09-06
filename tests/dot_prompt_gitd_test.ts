import { assertEquals } from "@std/assert";
import { join } from "node:path";
import {
  createWatchExpression,
  formatCache,
  minimizeWatchPaths,
  parsePorcelainV2,
  removePreBootIndexLock,
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
  const cache = formatCache("/tmp/repo with spaces", "/tmp/cache file", status, "Rebasing", true);

  assertEquals(zshQuote("feature/it's-safe"), "'feature/it'\\''s-safe'");
  assertEquals(
    cache,
    "pwd '/tmp/repo with spaces' top '/tmp/repo with spaces' cache '/tmp/cache file' " +
      "branch 'feature/it'\\''s-safe' detached '' upstream '' action 'Rebasing' conflict '1' " +
      "ahead '0' behind '0' staged '0' unstaged '0' untracked '0' unmerged '0' stash '0'\n",
  );
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

Deno.test("createWatchExpression ignores directory and index lock noise", () => {
  assertEquals(createWatchExpression(false), [
    "allof",
    ["not", ["type", "d"]],
    ["not", ["name", ".git/index.lock", "wholename"]],
  ]);
  assertEquals(createWatchExpression(true), [
    "allof",
    ["not", ["type", "d"]],
    ["not", ["name", "index.lock"]],
  ]);
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
