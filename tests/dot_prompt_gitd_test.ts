import { assertEquals } from "@std/assert";
import {
  createWatchExpression,
  formatCache,
  minimizeWatchPaths,
  parsePorcelainV2,
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
