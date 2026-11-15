import { assertEquals, assertStringIncludes } from "@std/assert";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const script = join(resolve(dirname(fileURLToPath(import.meta.url)), ".."), "bin/git-quick-save");
const snapshotRef = "refs/worktree/quick-save";
const identity = {
  GIT_AUTHOR_NAME: "t",
  GIT_AUTHOR_EMAIL: "t@example.invalid",
  GIT_COMMITTER_NAME: "t",
  GIT_COMMITTER_EMAIL: "t@example.invalid",
};

async function git(cwd: string, ...args: string[]): Promise<string> {
  const result = await new Deno.Command("git", { args, cwd, env: identity, stdout: "piped", stderr: "piped" }).output();
  if (!result.success) throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout).trim();
}

async function gitSucceeds(cwd: string, ...args: string[]): Promise<boolean> {
  return (await new Deno.Command("git", { args, cwd, env: identity, stdout: "null", stderr: "null" }).output()).success;
}

async function quickSave(cwd: string): Promise<{ code: number; output: string }> {
  const result = await new Deno.Command(script, { cwd, env: identity, stdout: "piped", stderr: "piped" }).output();
  const decoder = new TextDecoder();
  return { code: result.code, output: decoder.decode(result.stdout) + decoder.decode(result.stderr) };
}

async function snapshotCount(cwd: string): Promise<number> {
  if (!await gitSucceeds(cwd, "rev-parse", "--verify", "-q", snapshotRef)) return 0;
  return (await git(cwd, "reflog", "show", "--format=%H", snapshotRef)).split("\n").filter(Boolean).length;
}

// The repository state that a snapshot must never disturb.
async function repositoryState(cwd: string): Promise<string[]> {
  // Reading the state must not run hooks or refresh the index itself.
  const read = async (...args: string[]) => {
    const result = await new Deno.Command("git", {
      args: ["-c", "core.hooksPath=/dev/null", "-c", "core.fsmonitor=false", ...args],
      cwd,
      env: { ...identity, GIT_OPTIONAL_LOCKS: "0" },
      stdout: "piped",
      stderr: "null",
    }).output();
    return result.success ? new TextDecoder().decode(result.stdout).trim() : "";
  };
  const gitDir = await read("rev-parse", "--path-format=absolute", "--git-dir");
  return [
    await read("rev-parse", "HEAD"),
    await read("ls-files", "--stage"),
    await read("status", "--porcelain=v2"),
    await read("rev-parse", "--verify", "-q", "ORIG_HEAD"),
    [...Deno.readDirSync(gitDir)].map((entry) => entry.name).filter((name) => name !== "logs").sort().join(","),
  ];
}

async function repoWithLinkedWorktree(): Promise<{ root: string; main: string; worktree: string }> {
  const root = await Deno.makeTempDir({ prefix: "git-quick-save-" });
  const main = join(root, "main");
  await Deno.mkdir(main);
  await git(main, "init", "-q", "-b", "main");
  await Deno.writeTextFile(join(main, "a.txt"), "base\n");
  await git(main, "add", "a.txt");
  await git(main, "commit", "-qm", "base");
  await git(main, "branch", "side");
  await Deno.writeTextFile(join(main, "main.txt"), "main\n");
  await git(main, "add", "main.txt");
  await git(main, "commit", "-qm", "main");
  const worktree = join(root, "wt");
  await git(main, "worktree", "add", "-q", worktree, "side");
  await Deno.writeTextFile(join(worktree, "side.txt"), "side\n");
  await git(worktree, "add", "side.txt");
  await git(worktree, "commit", "-qm", "side");
  return { root, main, worktree };
}

Deno.test("作業ツリーの全体を記録し、HEAD・index・ORIG_HEAD・作業ツリーを変えない", async () => {
  const { root, main, worktree } = await repoWithLinkedWorktree();
  try {
    await git(worktree, "reset", "-q", "HEAD^");
    await git(worktree, "reset", "-q", "ORIG_HEAD");
    await Deno.writeTextFile(join(worktree, "side.txt"), "edited\n");
    await Deno.writeTextFile(join(worktree, "staged.txt"), "staged\n");
    await git(worktree, "add", "staged.txt");
    await Deno.writeTextFile(join(worktree, "untracked.txt"), "untracked\n");
    const before = await repositoryState(worktree);

    const result = await quickSave(worktree);
    assertEquals(result.code, 0, result.output);
    assertEquals(await repositoryState(worktree), before);
    assertEquals(await git(worktree, "show", `${snapshotRef}:side.txt`), "edited");
    assertEquals(await git(worktree, "show", `${snapshotRef}:staged.txt`), "staged");
    assertEquals(await git(worktree, "show", `${snapshotRef}:untracked.txt`), "untracked");
    assertEquals(await git(worktree, "rev-parse", `${snapshotRef}^`), await git(worktree, "rev-parse", "HEAD"));
    assertStringIncludes(await git(worktree, "reflog", "show", "--format=%gs", snapshotRef), "Git quick save");
    assertEquals(await snapshotCount(main), 0);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("rebase が止まっている間や衝突の最中でも、操作の状態を変えずに記録する", async () => {
  const { root, main, worktree } = await repoWithLinkedWorktree();
  try {
    assertEquals(await gitSucceeds(worktree, "rebase", "-q", "--exec", "false", "main"), false);
    const duringRebase = await repositoryState(worktree);
    assertEquals((await quickSave(worktree)).code, 0);
    assertEquals(await repositoryState(worktree), duringRebase);
    await git(worktree, "rebase", "--abort");

    await Deno.writeTextFile(join(main, "side.txt"), "conflicting\n");
    await git(main, "add", "side.txt");
    await git(main, "commit", "-qm", "conflicting");
    assertEquals(await gitSucceeds(worktree, "merge", "-q", "main"), false);
    const duringConflict = await repositoryState(worktree);
    assertEquals((await quickSave(worktree)).code, 0);
    assertEquals(await repositoryState(worktree), duringConflict);
    assertEquals(await git(worktree, "diff", "--name-only", "--diff-filter=U"), "side.txt");
    assertEquals(await snapshotCount(worktree), 2);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("保存先の ref が symbolic ref でも hook があっても、ブランチと作業ツリーを変えない", async () => {
  const { root, main, worktree } = await repoWithLinkedWorktree();
  try {
    await git(worktree, "symbolic-ref", snapshotRef, "refs/heads/main");
    const hooks = join(root, "hooks");
    await Deno.mkdir(hooks);
    for (const hook of ["reference-transaction", "post-index-change", "fsmonitor"]) {
      await Deno.writeTextFile(join(hooks, hook), `#!/bin/sh\ntouch "${join(worktree, `from-${hook}`)}"\n`);
      await Deno.chmod(join(hooks, hook), 0o755);
    }
    await git(main, "config", "core.hooksPath", hooks);
    await git(main, "config", "core.fsmonitor", join(hooks, "fsmonitor"));
    await Deno.writeTextFile(join(worktree, "side.txt"), "edited\n");
    const mainBefore = await git(main, "rev-parse", "refs/heads/main");
    const before = await repositoryState(worktree);

    assertEquals((await quickSave(worktree)).code, 0);
    assertEquals(await git(main, "rev-parse", "refs/heads/main"), mainBefore);
    assertEquals(await repositoryState(worktree), before);
    assertEquals(await git(worktree, "show", `${snapshotRef}:side.txt`), "edited");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("partial clone で親の tree が未取得でも、remote から取得せずに記録する", async () => {
  const root = await Deno.makeTempDir({ prefix: "git-quick-save-partial-" });
  try {
    const origin = join(root, "origin");
    await Deno.mkdir(origin);
    await git(origin, "init", "-q", "-b", "main");
    await Deno.writeTextFile(join(origin, "a.txt"), "a\n");
    await git(origin, "add", "a.txt");
    await git(origin, "commit", "-qm", "base");
    await git(origin, "config", "uploadpack.allowFilter", "true");
    const clone = join(root, "clone");
    await git(root, "clone", "-q", "--filter=tree:0", "--no-checkout", `file://${origin}`, clone);
    const packDir = join(clone, ".git", "objects", "pack");
    const packsBefore = [...Deno.readDirSync(packDir)].map((entry) => entry.name).sort();
    await Deno.writeTextFile(join(clone, "new.txt"), "new\n");

    assertEquals((await quickSave(clone)).code, 0);
    assertEquals([...Deno.readDirSync(packDir)].map((entry) => entry.name).sort(), packsBefore);
    assertEquals(await git(clone, "show", `${snapshotRef}:new.txt`), "new");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("最初の commit がない repo でも記録し、HEAD は作らない", async () => {
  const root = await Deno.makeTempDir({ prefix: "git-quick-save-unborn-" });
  try {
    await git(root, "init", "-q", "-b", "main");
    await Deno.writeTextFile(join(root, "new.txt"), "new\n");

    assertEquals((await quickSave(root)).code, 0);
    assertEquals(await gitSucceeds(root, "rev-parse", "--verify", "-q", "HEAD"), false);
    assertEquals(await git(root, "show", `${snapshotRef}:new.txt`), "new");
    assertEquals(await git(root, "status", "--porcelain"), "?? new.txt");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});
