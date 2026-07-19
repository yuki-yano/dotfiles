import { assert, assertEquals, assertStringIncludes } from "@std/assert";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const daemonScript = join(repositoryRoot, "bin/dot-prompt-gitd.ts");
const gitPromptScript = join(repositoryRoot, ".zsh/prompt/git.zsh");

async function commandSucceeds(command: string, args: string[]): Promise<boolean> {
  try {
    return (await new Deno.Command(command, { args, stdout: "null", stderr: "null" }).output()).success;
  } catch {
    return false;
  }
}

async function run(command: string, args: string[], cwd?: string): Promise<Deno.CommandOutput> {
  const output = await new Deno.Command(command, { args, cwd, stdout: "piped", stderr: "piped" }).output();
  if (!output.success) {
    throw new Error(`${command} failed: ${new TextDecoder().decode(output.stderr)}`);
  }
  return output;
}

async function waitFor(predicate: () => boolean | Promise<boolean>, timeoutMs = 7_000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 50));
  }
  throw new Error(`condition was not met within ${timeoutMs}ms`);
}

function readText(path: string): string {
  try {
    return Deno.readTextFileSync(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return "";
    throw error;
  }
}

function refreshCount(logPath: string, repoPath: string): number {
  return readText(logPath).split(`refresh ok ${repoPath}`).length - 1;
}

async function register(socketPath: string, top: string, cachePath: string): Promise<void> {
  const connection = await Deno.connect({ transport: "unix", path: socketPath });
  await connection.write(new TextEncoder().encode(`${JSON.stringify({ top, cachePath })}\n`));
  connection.close();
}

async function cacheSignature(repoPath: string, cachePath: string): Promise<string> {
  const script = [
    'source "$1"',
    'cd "$2"',
    'output=$(dot_prompt_git_status_from_cache "$3")',
    "typeset -A info",
    "typeset -a items",
    'items=("${(Q@)${(z)output}}")',
    'info=("${items[@]}")',
    'print -r -- "$info[signature]"',
  ].join("; ");
  const output = await run("zsh", ["-f", "-c", script, "--", gitPromptScript, repoPath, cachePath]);
  return new TextDecoder().decode(output.stdout).trim();
}

Deno.test("Deno が PATH にない場合は Git 表示を無音で空にする", async () => {
  const output = await new Deno.Command("/bin/zsh", {
    args: ["-f", "-c", 'source "$1"; dot_prompt_git_status cached', "--", gitPromptScript],
    cwd: repositoryRoot,
    env: { PATH: "/usr/bin:/bin" },
    stdout: "piped",
    stderr: "piped",
  }).output();

  assert(output.success);
  assertEquals(new TextDecoder().decode(output.stderr), "");
  assertStringIncludes(new TextDecoder().decode(output.stdout), "top ''");
});

const watchmanAvailable = await commandSucceeds("watchman", ["--version"]);

Deno.test({
  name: "100回の連続変更を1回の Git 更新にまとめ、同一秒内のキャッシュ置換も検知する",
  ignore: !watchmanAvailable,
  async fn() {
    // macOS limits Unix-domain socket paths to roughly 100 bytes.
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-" });
    const repoPath = join(integrationRoot, "repo");
    const runtimePath = join(integrationRoot, "runtime");
    const socketPath = join(runtimePath, "daemon.sock");
    const logPath = join(runtimePath, "daemon.log");
    const cachePath = join(integrationRoot, "cache", "status");
    let daemon: Deno.ChildProcess | null = null;

    try {
      await run("git", ["init", "-q", repoPath]);
      await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
      await run("git", ["config", "user.name", "prompt-test"], repoPath);
      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await run("git", ["add", "tracked.txt"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);

      daemon = new Deno.Command("deno", {
        args: ["run", "--quiet", "-A", daemonScript],
        cwd: repositoryRoot,
        env: {
          DOT_PROMPT_GITD_RUNTIME_BASE: runtimePath,
          DOT_PROMPT_GITD_SOCKET_PATH: socketPath,
        },
        stdout: "null",
        stderr: "null",
      }).spawn();

      await waitFor(() => {
        try {
          return Deno.statSync(socketPath).isSocket === true;
        } catch {
          return false;
        }
      });
      await register(socketPath, repoPath, cachePath);
      await waitFor(() => refreshCount(logPath, repoPath) >= 1 && readText(cachePath).includes("unstaged '0'"));
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 400));

      const refreshesBeforeCookie = refreshCount(logPath, repoPath);
      await run("watchman", ["clock", repoPath]);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 500));
      assertEquals(refreshCount(logPath, repoPath), refreshesBeforeCookie);

      const initialRefreshes = refreshesBeforeCookie;
      const signatureBefore = await cacheSignature(repoPath, cachePath);
      const isolatedBin = join(integrationRoot, "bin");
      await Deno.mkdir(isolatedBin);
      await Deno.symlink(Deno.execPath(), join(isolatedBin, "deno"));
      const watchmanPath = new TextDecoder().decode(
        (await run("/bin/zsh", ["-f", "-c", "command -v watchman"])).stdout,
      ).trim();
      await Deno.symlink(watchmanPath, join(isolatedBin, "watchman"));
      const knownStatus = await new Deno.Command("/bin/zsh", {
        args: [
          "-f",
          "-c",
          'source "$1"; cd "$2"; dot_prompt_git_status known "$2" "$3"',
          "--",
          gitPromptScript,
          repoPath,
          cachePath,
        ],
        env: {
          PATH: isolatedBin,
          DOT_PROMPT_GITD_RUNTIME_BASE: runtimePath,
          DOT_PROMPT_GITD_SOCKET_PATH: socketPath,
          DOT_PROMPT_GITD_SCRIPT: daemonScript,
        },
        stdout: "piped",
        stderr: "piped",
      }).output();
      assert(knownStatus.success);
      assertEquals(new TextDecoder().decode(knownStatus.stderr), "");
      assertStringIncludes(new TextDecoder().decode(knownStatus.stdout), `top ${repoPath}`);

      for (let index = 0; index < 100; index++) {
        Deno.writeTextFileSync(join(repoPath, "tracked.txt"), `change-${index}\n`);
      }

      try {
        await waitFor(() =>
          refreshCount(logPath, repoPath) >= initialRefreshes + 1 && readText(cachePath).includes("unstaged '1'")
        );
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ncache:\n${readText(cachePath)}`);
      }
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 700));

      const signatureAfter = await cacheSignature(repoPath, cachePath);
      assertEquals(refreshCount(logPath, repoPath) - initialRefreshes, 1);
      assert(signatureBefore !== signatureAfter);
      assertStringIncludes(readText(cachePath), "unstaged '1'");
    } finally {
      if (daemon) {
        try {
          daemon.kill("SIGTERM");
        } catch {
          // The daemon may already have exited after a startup failure.
        }
        await daemon.status;
      }
      await new Deno.Command("watchman", {
        args: ["watch-del", repoPath],
        stdout: "null",
        stderr: "null",
      }).output().catch(() => undefined);
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});
