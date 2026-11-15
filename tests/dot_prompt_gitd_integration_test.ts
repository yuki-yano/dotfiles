import { assert, assertEquals, assertStringIncludes } from "@std/assert";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const daemonScript = join(repositoryRoot, "bin/dot-prompt-gitd.ts");
const promptBaseScript = join(repositoryRoot, ".zsh/prompt/base.zsh");
const gitPromptScript = join(repositoryRoot, ".zsh/prompt/git.zsh");
const promptAsyncScript = join(repositoryRoot, ".zsh/prompt/async.zsh");

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

async function createGitShim(dir: string): Promise<{ binPath: string; callLog: string }> {
  const realGit = new TextDecoder().decode((await run("/bin/zsh", ["-f", "-c", "command -v git"])).stdout).trim();
  const binPath = join(dir, "git-shim");
  const callLog = join(dir, "git-calls.log");
  await Deno.mkdir(binPath);
  await Deno.writeTextFile(
    join(binPath, "git"),
    `#!/bin/sh\nprintf '%s\\n' "$*" >> '${callLog}'\nexec '${realGit}' "$@"\n`,
  );
  await Deno.chmod(join(binPath, "git"), 0o755);
  return { binPath, callLog };
}

function gitStatusCount(callLog: string): number {
  return readText(callLog).split("\n").filter((line) => line.split(" ").includes("status")).length;
}

async function register(socketPath: string, top: string, cachePath: string): Promise<void> {
  const connection = await Deno.connect({ transport: "unix", path: socketPath });
  await connection.write(new TextEncoder().encode(`${JSON.stringify({ top, cachePath })}\n`));
  await connection.read(new Uint8Array(16));
  connection.close();
}

async function deleteWatchRoots(...roots: string[]): Promise<void> {
  for (const root of roots) {
    await new Deno.Command("watchman", {
      args: ["watch-del", root],
      stdout: "null",
      stderr: "null",
    }).output().catch(() => undefined);
  }
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

Deno.test("デーモンの受け付けが遅れても zsh からの登録要求を失わない", async () => {
  const root = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-accept-" });
  const socketPath = join(root, "daemon.sock");
  const listener = Deno.listen({ transport: "unix", path: socketPath });
  try {
    const client = new Deno.Command("/bin/zsh", {
      args: ["-f", "-c", 'source "$1"; dot_prompt_git_daemon_register /repo /cache', "--", gitPromptScript],
      env: { DOT_PROMPT_GITD_SOCKET_PATH: socketPath, DOT_PROMPT_GITD_SCRIPT: daemonScript },
      stdout: "null",
      stderr: "piped",
    }).spawn();
    // Longer than the client's one-second wait for a reply.
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 1_300));
    let received = "";
    const deadline = Date.now() + 5_000;
    while (!received && Date.now() < deadline) {
      const timeout = new Promise<null>((resolvePromise) =>
        setTimeout(() => resolvePromise(null), deadline - Date.now())
      );
      const connection = await Promise.race([listener.accept(), timeout]).catch(() => undefined);
      if (connection === null) break;
      if (connection === undefined) continue;
      const buffer = new Uint8Array(4_096);
      const count = await connection.read(buffer) ?? 0;
      received = new TextDecoder().decode(buffer.subarray(0, count));
      await connection.write(new TextEncoder().encode("ok\n"));
      connection.close();
    }
    const result = await client.output();
    assert(result.success);
    assertEquals(new TextDecoder().decode(result.stderr), "");
    assertStringIncludes(received, '"top":"/repo"');
  } finally {
    listener.close();
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("初回キャッシュ待ちを保持し、キャッシュ読込後に Git 表示へ切り替える", async () => {
  const script = [
    'source "$1"',
    'source "$2"',
    'source "$3"',
    'pending_output=$(dot_prompt_git_pending_status "/tmp/repo" "/tmp/cache")',
    'dot_prompt_async_callback dot_prompt_git_status 0 "$pending_output" 0 0 0',
    'print -r -- "pending=${DOT_PROMPT_GIT_PENDING} top=${DOT_PROMPT_GIT_TOP} cache=${DOT_PROMPT_GIT_CACHE_PATH} prompt=${DOT_PROMPT_GIT_PROMPT}"',
    "typeset -A ready_info",
    'ready_info=(pwd "$PWD" top "/tmp/repo" cache "/tmp/cache" branch main)',
    "ready_output=$(print -r -- ${(@kvq)ready_info})",
    'dot_prompt_async_callback dot_prompt_git_status 0 "$ready_output" 0 0 0',
    'print -r -- "ready=${DOT_PROMPT_GIT_PENDING} prompt=${DOT_PROMPT_GIT_PROMPT}"',
  ].join("; ");
  const output = await new Deno.Command("/bin/zsh", {
    args: ["-f", "-c", script, "--", promptBaseScript, gitPromptScript, promptAsyncScript],
    stdout: "piped",
    stderr: "piped",
  }).output();

  assert(output.success);
  assertEquals(new TextDecoder().decode(output.stderr), "");
  const stdout = new TextDecoder().decode(output.stdout);
  assertStringIncludes(stdout, "pending=1 top=/tmp/repo cache=/tmp/cache prompt=");
  assertStringIncludes(stdout, "ready=0 prompt=%B%F{7} main");
});

Deno.test("symlink 経由で repo 内に入っても Git 状態を消さずに known モードで更新する", async () => {
  const root = await Deno.realPath(await Deno.makeTempDir({ prefix: "dp-symlink-" }));
  const top = join(root, "repo");
  const link = join(root, "link");
  try {
    await Deno.mkdir(join(top, "sub"), { recursive: true });
    await Deno.symlink(join(top, "sub"), link);
    const script = [
      'source "$1"',
      'source "$2"',
      'source "$3"',
      "async_start_worker() { :; }",
      "async_register_callback() { :; }",
      "async_worker_eval() { :; }",
      'async_job() { print -r -- "job ${(j: :)@[3,-1]}"; }',
      "DOT_PROMPT_GIT_AUTO_REFRESH_INTERVAL=0",
      'cd "$5"',
      "typeset -A info",
      'info=(pwd "$PWD" top "$4" cache "$4.status" branch main)',
      'dot_prompt_async_callback dot_prompt_git_status 0 "$(print -r -- ${(@kvq)info})" 0 0 0',
      "dot_prompt_async_maybe_reset_for_pwd",
      "dot_prompt_async_tasks cached",
      'print -r -- "top=$DOT_PROMPT_GIT_TOP"',
    ].join("; ");
    const output = await run("/bin/zsh", [
      "-f",
      "-c",
      script,
      "--",
      promptBaseScript,
      gitPromptScript,
      promptAsyncScript,
      top,
      link,
    ]);
    assertEquals(new TextDecoder().decode(output.stderr), "");
    const stdout = new TextDecoder().decode(output.stdout);
    assertStringIncludes(stdout, `job known ${top} ${top}.status`);
    assertStringIncludes(stdout, `top=${top}`);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

const watchmanAvailable = await commandSucceeds("watchman", ["--version"]);

Deno.test("pending の応答より先にキャッシュが完成しても、次の確認でキャッシュを読み込む", async () => {
  const root = await Deno.makeTempDir({ prefix: "dp-pending-race-" });
  try {
    const script = [
      'source "$1"',
      'source "$2"',
      'source "$3"',
      "DOT_PROMPT_GIT_AUTO_REFRESH_INTERVAL=0",
      'top="$4/repo"',
      'cache="$4/cache.status"',
      'pending_output=$(dot_prompt_git_pending_status "$top" "$cache")',
      "typeset -A ready",
      'ready=(pwd "$top" top "$top" cache "$cache" branch main)',
      'print -r -- ${(@kvq)ready} > "$cache"',
      'dot_prompt_async_callback dot_prompt_git_status 0 "$pending_output" 0 0 0',
      "dot_prompt_async_cache_changed && print -r -- changed=yes || print -r -- changed=no",
      'cache_output=$(dot_prompt_git_status cache-only "$cache")',
      'dot_prompt_async_callback dot_prompt_git_status 0 "$cache_output" 0 0 0',
      'print -r -- "pending=$DOT_PROMPT_GIT_PENDING prompt=$DOT_PROMPT_GIT_PROMPT"',
    ].join("; ");
    const output = await run("/bin/zsh", [
      "-f",
      "-c",
      script,
      "--",
      promptBaseScript,
      gitPromptScript,
      promptAsyncScript,
      root,
    ]);
    assertEquals(new TextDecoder().decode(output.stderr), "");
    const stdout = new TextDecoder().decode(output.stdout);
    assertStringIncludes(stdout, "changed=yes");
    assertStringIncludes(stdout, "pending=0 prompt=%B%F{7} main");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("行数だけの更新を色付きで描画し、差分ゼロとリポジトリ移動で表示を消す", async () => {
  const script = [
    'source "$1"',
    'source "$2"',
    'source "$3"',
    "DOT_PROMPT_GIT_AUTO_REFRESH_INTERVAL=0",
    "typeset -A info",
    'info=(pwd "$PWD" top "$PWD" branch main unstaged 1 added 3 deleted 2)',
    'dot_prompt_async_callback dot_prompt_git_status 0 "$(print -r -- ${(@kvq)info})" 0 0 0',
    'print -r -- "$DOT_PROMPT_GIT_PROMPT"',
    "info[added]=8",
    'dot_prompt_async_callback dot_prompt_git_status 0 "$(print -r -- ${(@kvq)info})" 0 0 0',
    'print -r -- "$DOT_PROMPT_GIT_PROMPT"',
    "info[added]=0",
    "info[deleted]=0",
    'dot_prompt_async_callback dot_prompt_git_status 0 "$(print -r -- ${(@kvq)info})" 0 0 0',
    'print -r -- "$DOT_PROMPT_GIT_PROMPT"',
    "DOT_PROMPT_GIT_ADDED=8",
    "DOT_PROMPT_GIT_DELETED=2",
    'dot_prompt_async_callback dot_prompt_git_status 0 "$(dot_prompt_git_empty_status)" 0 0 0',
    'print -r -- "reset=$DOT_PROMPT_GIT_ADDED,$DOT_PROMPT_GIT_DELETED,$DOT_PROMPT_GIT_PROMPT"',
  ].join("; ");
  const output = await run("/bin/zsh", [
    "-f",
    "-c",
    script,
    "--",
    promptBaseScript,
    gitPromptScript,
    promptAsyncScript,
  ]);
  assertEquals(new TextDecoder().decode(output.stderr), "");
  const lines = new TextDecoder().decode(output.stdout).trimEnd().split("\n");
  assertStringIncludes(lines[0], "M:1%f %F{244}│%f %F{2}+3%f %F{1}-2%f");
  assertStringIncludes(lines[1], "M:1%f %F{244}│%f %F{2}+8%f %F{1}-2%f");
  assert(!lines[2].includes("+0"));
  assert(!lines[2].includes("-0"));
  assertEquals(lines[3], "reset=0,0,");
});

Deno.test({
  name: "100回の連続変更を1回の Git 更新にまとめ、同一秒内の置換を検知し、内容が同じなら置き換えない",
  ignore: !watchmanAvailable,
  async fn() {
    // macOS limits Unix-domain socket paths to roughly 100 bytes.
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-" });
    const repoPath = join(integrationRoot, "repo");
    const runtimePath = join(integrationRoot, "runtime");
    const socketPath = join(runtimePath, "daemon.sock");
    const logPath = join(runtimePath, "daemon.log");
    const xdgCachePath = join(integrationRoot, "xdg-cache");
    let canonicalRepoPath = repoPath;
    let cachePath = "";
    let daemon: Deno.ChildProcess | null = null;

    try {
      await run("git", ["init", "-q", repoPath]);
      await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
      await run("git", ["config", "user.name", "prompt-test"], repoPath);
      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await run("git", ["add", "tracked.txt"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);
      canonicalRepoPath = await Deno.realPath(repoPath);
      cachePath = join(
        xdgCachePath,
        "zsh",
        "prompt",
        "git-status",
        `${canonicalRepoPath.replaceAll("/", "%")}.status`,
      );
      const gitShim = await createGitShim(integrationRoot);

      daemon = new Deno.Command("deno", {
        args: ["run", "--quiet", "-A", daemonScript],
        cwd: repositoryRoot,
        env: {
          PATH: `${gitShim.binPath}:${Deno.env.get("PATH") ?? ""}`,
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
      const initialStatus = await new Deno.Command("/bin/zsh", {
        args: ["-f", "-c", 'source "$1"; cd "$2"; dot_prompt_git_status cached', "--", gitPromptScript, repoPath],
        env: {
          DOT_PROMPT_GITD_RUNTIME_BASE: runtimePath,
          DOT_PROMPT_GITD_SOCKET_PATH: socketPath,
          DOT_PROMPT_GITD_SCRIPT: daemonScript,
          XDG_CACHE_HOME: xdgCachePath,
        },
        stdout: "piped",
        stderr: "piped",
      }).output();
      assert(initialStatus.success);
      assertEquals(new TextDecoder().decode(initialStatus.stderr), "");
      const initialOutput = new TextDecoder().decode(initialStatus.stdout);
      assertStringIncludes(initialOutput, "pending 1");
      assertStringIncludes(initialOutput, `top ${canonicalRepoPath}`);
      assertStringIncludes(initialOutput, `cache ${cachePath}`);
      try {
        await waitFor(() => gitStatusCount(gitShim.callLog) >= 1 && readText(cachePath).includes("unstaged '0'"));
      } catch (error) {
        throw new Error(
          `${error}\ndaemon log:\n${readText(logPath)}\ngit calls:\n${readText(gitShim.callLog)}\ncache:\n${
            readText(cachePath)
          }`,
        );
      }
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 400));

      const refreshesBeforeCookie = gitStatusCount(gitShim.callLog);
      await run("watchman", ["clock", repoPath]);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 500));
      assertEquals(gitStatusCount(gitShim.callLog), refreshesBeforeCookie);

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
          canonicalRepoPath,
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
      assertStringIncludes(new TextDecoder().decode(knownStatus.stdout), `top ${canonicalRepoPath}`);

      for (let index = 0; index < 100; index++) {
        Deno.writeTextFileSync(join(repoPath, "tracked.txt"), `change-${index}\n`);
      }

      try {
        await waitFor(() =>
          gitStatusCount(gitShim.callLog) >= initialRefreshes + 1 && readText(cachePath).includes("unstaged '1'")
        );
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ncache:\n${readText(cachePath)}`);
      }
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 700));

      const signatureAfter = await cacheSignature(repoPath, cachePath);
      assertEquals(gitStatusCount(gitShim.callLog) - initialRefreshes, 1);
      assert(signatureBefore !== signatureAfter);
      assertStringIncludes(readText(cachePath), "unstaged '1'");
      assertStringIncludes(readText(cachePath), "added '1' deleted '1'");

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "one\ntwo\nthree\n");
      await waitFor(() => readText(cachePath).includes("added '3' deleted '1'"));
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 700));

      const refreshesBeforeTouch = gitStatusCount(gitShim.callLog);
      const signatureBeforeTouch = await cacheSignature(repoPath, cachePath);
      const touchedAt = new Date();
      await Deno.utime(join(repoPath, "tracked.txt"), touchedAt, touchedAt);
      await waitFor(() => gitStatusCount(gitShim.callLog) > refreshesBeforeTouch);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 700));
      assertEquals(await cacheSignature(repoPath, cachePath), signatureBeforeTouch);
    } finally {
      if (daemon) {
        try {
          daemon.kill("SIGTERM");
        } catch {
          // The daemon may already have exited after a startup failure.
        }
        await daemon.status;
      }
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "index.lock が残っていても変更ファイル数を更新し、zsh のプロンプトへ反映する",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-lock-" });
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
      const indexLockPath = join(repoPath, ".git", "index.lock");
      await Deno.writeTextFile(indexLockPath, "");

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
      await waitFor(() => readText(cachePath).includes("unstaged '0'"));

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "changed\n");
      await Deno.writeTextFile(join(repoPath, "untracked.txt"), "new\n");
      try {
        await waitFor(() =>
          readText(cachePath).includes("unstaged '1'") && readText(cachePath).includes("untracked '1'")
        );
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ncache:\n${readText(cachePath)}`);
      }

      const script = [
        'source "$1"',
        'source "$2"',
        'source "$3"',
        'output=$(dot_prompt_git_status_from_cache "$4")',
        'dot_prompt_async_callback dot_prompt_git_status 0 "$output" 0 0 0',
        'print -r -- "$PROMPT"',
      ].join("; ");
      const output = await run("/bin/zsh", [
        "-f",
        "-c",
        script,
        "--",
        promptBaseScript,
        gitPromptScript,
        promptAsyncScript,
        cachePath,
      ], repoPath);
      const prompt = new TextDecoder().decode(output.stdout);
      assertEquals(new TextDecoder().decode(output.stderr), "");
      assertStringIncludes(prompt, "M:1");
      assertStringIncludes(prompt, "?:1");
      assertStringIncludes(prompt, "%F{2}+2%f %F{1}-1%f");
      assert(Deno.statSync(indexLockPath).isFile);

      await Deno.writeTextFile(join(repoPath, "untracked.txt"), "new\nmore\nlast");
      await waitFor(() => readText(cachePath).includes("added '4' deleted '1'"));

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await Deno.remove(join(repoPath, "untracked.txt"));
      await waitFor(() =>
        readText(cachePath).includes("unstaged '0'") && readText(cachePath).includes("untracked '0'") &&
        readText(cachePath).includes("added '0' deleted '0'")
      );
    } finally {
      if (daemon) {
        try {
          daemon.kill("SIGTERM");
        } catch {
          // The daemon may already have exited after a startup failure.
        }
        await daemon.status;
      }
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "ignore 対象と .git 内に置いた worktree の変更では git status を起動しない",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-noise-" });
    const repoPath = join(integrationRoot, "repo");
    const worktreeBeforeStart = join(repoPath, ".git", "wt", "before");
    const worktreeAfterStart = join(repoPath, ".git", "wt", "after");
    const runtimePath = join(integrationRoot, "runtime");
    const socketPath = join(runtimePath, "daemon.sock");
    const logPath = join(runtimePath, "daemon.log");
    const cachePath = join(integrationRoot, "cache", "status");
    let daemon: Deno.ChildProcess | null = null;

    try {
      await run("git", ["init", "-q", repoPath]);
      await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
      await run("git", ["config", "user.name", "prompt-test"], repoPath);
      await Deno.writeTextFile(join(repoPath, ".gitignore"), "ignored/\n");
      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await run("git", ["add", ".gitignore", "tracked.txt"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);
      await run("git", ["worktree", "add", "-q", worktreeBeforeStart, "-b", "before"], repoPath);
      await Deno.mkdir(join(repoPath, "ignored"));
      const gitShim = await createGitShim(integrationRoot);

      daemon = new Deno.Command("deno", {
        args: ["run", "--quiet", "-A", daemonScript],
        cwd: repositoryRoot,
        env: {
          PATH: `${gitShim.binPath}:${Deno.env.get("PATH") ?? ""}`,
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
      try {
        await waitFor(() => readText(cachePath).includes("unstaged '0'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ngit calls:\n${readText(gitShim.callLog)}`);
      }
      await run("git", ["worktree", "add", "-q", worktreeAfterStart, "-b", "after"], repoPath);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 1_500));

      const refreshesBefore = gitStatusCount(gitShim.callLog);
      await Deno.writeTextFile(join(repoPath, "ignored", "build.log"), "noise\n");
      await Deno.remove(join(repoPath, "ignored", "build.log"));
      await Deno.writeTextFile(join(worktreeBeforeStart, "tracked.txt"), "worktree edit\n");
      await Deno.writeTextFile(join(worktreeAfterStart, "tracked.txt"), "worktree edit\n");
      const touchedAt = new Date();
      await Deno.utime(join(repoPath, ".git", "worktrees", "before", "gitdir"), touchedAt, touchedAt);
      await new Promise((resolvePromise) => setTimeout(resolvePromise, 1_500));
      assertEquals(gitStatusCount(gitShim.callLog), refreshesBefore);
      assertStringIncludes(readText(cachePath), "unstaged '0'");

      await Deno.mkdir(join(repoPath, ".git", "local"));
      await Deno.writeTextFile(join(repoPath, ".git", "local", "included.conf"), "[status]\n");
      await waitFor(() => gitStatusCount(gitShim.callLog) > refreshesBefore);

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "changed\n");
      try {
        await waitFor(() => readText(cachePath).includes("unstaged '1'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ncache:\n${readText(cachePath)}`);
      }
      assert(gitStatusCount(gitShim.callLog) > refreshesBefore);

      await run("git", ["stash", "-q"], repoPath);
      await waitFor(() => readText(cachePath).includes("unstaged '0'") && readText(cachePath).includes("stash '1'"));

      await run("git", ["branch", "objects/topic"], repoPath);
      await run("git", ["branch", "-q", "--set-upstream-to=objects/topic"], repoPath);
      await run("git", ["commit", "--allow-empty", "-qm", "ahead"], repoPath);
      await waitFor(() => readText(cachePath).includes("ahead '1'"));
      await run("git", ["update-ref", "refs/heads/objects/topic", "HEAD"], repoPath);
      await waitFor(() => readText(cachePath).includes("ahead '0'"));
    } finally {
      await daemon?.[Symbol.asyncDispose]();
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "未追跡ファイルを同じサイズで書き換えて mtime を戻しても、行数を数え直す",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-mtime-" });
    const repoPath = join(integrationRoot, "repo");
    const untrackedPath = join(repoPath, "untracked.txt");
    const runtimePath = join(integrationRoot, "runtime");
    const socketPath = join(runtimePath, "daemon.sock");
    const cachePath = join(integrationRoot, "cache", "status");
    let daemon: Deno.ChildProcess | null = null;

    try {
      await run("git", ["init", "-q", repoPath]);
      await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
      await run("git", ["config", "user.name", "prompt-test"], repoPath);
      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await run("git", ["add", "tracked.txt"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);
      await Deno.writeTextFile(untrackedPath, "abcd\n");

      daemon = new Deno.Command("deno", {
        args: ["run", "--quiet", "-A", daemonScript],
        cwd: repositoryRoot,
        env: { DOT_PROMPT_GITD_RUNTIME_BASE: runtimePath, DOT_PROMPT_GITD_SOCKET_PATH: socketPath },
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
      await waitFor(() => readText(cachePath).includes("added '1' deleted '0'"));

      const { atime, mtime } = await Deno.stat(untrackedPath);
      await Deno.writeTextFile(untrackedPath, "a\nb\n\n");
      await Deno.utime(untrackedPath, atime ?? new Date(), mtime ?? new Date());
      await waitFor(() => readText(cachePath).includes("added '3' deleted '0'"));
    } finally {
      await daemon?.[Symbol.asyncDispose]();
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "Git refs の変更を検知し、push 後に ahead をゼロへ戻す",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await Deno.makeTempDir({ dir: "/tmp", prefix: "dp-gitd-refs-" });
    const repoPath = join(integrationRoot, "repo");
    const remotePath = join(integrationRoot, "remote.git");
    const runtimePath = join(integrationRoot, "runtime");
    const socketPath = join(runtimePath, "daemon.sock");
    const logPath = join(runtimePath, "daemon.log");
    const cachePath = join(integrationRoot, "cache", "status");
    let daemon: Deno.ChildProcess | null = null;

    try {
      await run("git", ["init", "-q", "--bare", remotePath]);
      await run("git", ["init", "-q", repoPath]);
      await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
      await run("git", ["config", "user.name", "prompt-test"], repoPath);
      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await run("git", ["add", "tracked.txt"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);
      await run("git", ["remote", "add", "origin", remotePath], repoPath);
      await run("git", ["push", "-qu", "origin", "HEAD:main"], repoPath);

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
      await waitFor(() => readText(cachePath).includes("ahead '0'"));

      await run("git", ["commit", "--allow-empty", "-qm", "ahead"], repoPath);
      await waitFor(() => readText(cachePath).includes("ahead '1'"));

      await run("git", ["push", "-q"], repoPath);
      try {
        await waitFor(() => readText(cachePath).includes("ahead '0'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(logPath)}\ncache:\n${readText(cachePath)}`);
      }
    } finally {
      if (daemon) {
        try {
          daemon.kill("SIGTERM");
        } catch {
          // The daemon may already have exited after a startup failure.
        }
        await daemon.status;
      }
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});
