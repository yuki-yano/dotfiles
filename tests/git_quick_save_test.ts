import { assertEquals, assertStringIncludes } from "@std/assert";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const script = join(resolve(dirname(fileURLToPath(import.meta.url)), ".."), "bin/git-quick-save");

async function git(cwd: string, ...args: string[]): Promise<string> {
  const result = await new Deno.Command("git", {
    args: ["-c", "user.name=t", "-c", "user.email=t@example.invalid", ...args],
    cwd,
    stdout: "piped",
    stderr: "piped",
  }).output();
  if (!result.success) throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout).trim();
}

async function quickSave(cwd: string): Promise<{ code: number; output: string }> {
  const result = await new Deno.Command(script, { cwd, stdout: "piped", stderr: "piped" }).output();
  const decoder = new TextDecoder();
  return { code: result.code, output: decoder.decode(result.stdout) + decoder.decode(result.stderr) };
}

async function repoWithLinkedWorktree(): Promise<{ root: string; worktree: string }> {
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
  return { root, worktree };
}

Deno.test("linked worktree で rebase が衝突なしで止まっている間は、スナップショットを作らずに中止する", async () => {
  const { root, worktree } = await repoWithLinkedWorktree();
  try {
    // The exec step fails after the commit is applied, so the rebase stops with a clean index.
    const stopped = await new Deno.Command("git", {
      args: ["rebase", "-q", "--exec", "false", "main"],
      cwd: worktree,
      stdout: "null",
      stderr: "null",
    }).output();
    assertEquals(stopped.success, false);
    const headBefore = await git(worktree, "rev-parse", "HEAD");

    const result = await quickSave(worktree);
    assertEquals(result.code, 0);
    assertStringIncludes(result.output, "Skipped: rebase in progress.");
    assertEquals(await git(worktree, "rev-parse", "HEAD"), headBefore);
    assertEquals((await git(worktree, "reflog", "--format=%gs")).includes("Git quick save"), false);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("作業ツリーの変更をスナップショットとして reflog に残し、HEAD と作業ツリーは変えない", async () => {
  const { root, worktree } = await repoWithLinkedWorktree();
  try {
    await Deno.writeTextFile(join(worktree, "side.txt"), "edited\n");
    const headBefore = await git(worktree, "rev-parse", "HEAD");

    const result = await quickSave(worktree);
    assertEquals(result.code, 0);
    assertEquals(await git(worktree, "rev-parse", "HEAD"), headBefore);
    assertEquals(await Deno.readTextFile(join(worktree, "side.txt")), "edited\n");
    assertStringIncludes(await git(worktree, "reflog", "-2", "--format=%gs"), "Git quick save");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});
