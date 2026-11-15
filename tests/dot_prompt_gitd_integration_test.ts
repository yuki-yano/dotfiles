import { assert, assertEquals, assertMatch, assertStringIncludes } from "@std/assert";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { formatState, type GitStatus } from "../bin/dot-prompt-gitd.ts";

const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const daemonScript = join(repositoryRoot, "bin/dot-prompt-gitd.ts");
const promptDir = join(repositoryRoot, ".zsh/prompt");

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

async function waitFor(
  predicate: () => boolean | Promise<boolean>,
  timeoutMs = 7_000,
  intervalMs = 50,
): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await new Promise((resolvePromise) => setTimeout(resolvePromise, intervalMs));
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

const pause = (ms: number) => new Promise((resolvePromise) => setTimeout(resolvePromise, ms));

function readText(path: string): string {
  try {
    return Deno.readTextFileSync(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return "";
    throw error;
  }
}

// macOS limits Unix-domain socket paths to roughly 100 bytes, and the daemon
// only accepts the physical path of a work tree.
async function makeRoot(prefix: string): Promise<string> {
  return await Deno.realPath(await Deno.makeTempDir({ dir: "/tmp", prefix }));
}

async function initRepo(repoPath: string): Promise<void> {
  await run("git", ["init", "-q", "-b", "main", repoPath]);
  await run("git", ["config", "user.email", "prompt-test@example.invalid"], repoPath);
  await run("git", ["config", "user.name", "prompt-test"], repoPath);
}

async function commitTrackedFile(repoPath: string, ...extraFiles: string[]): Promise<void> {
  await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
  await run("git", ["add", "tracked.txt", ...extraFiles], repoPath);
  await run("git", ["commit", "-qm", "initial"], repoPath);
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

async function deleteWatchRoots(...roots: string[]): Promise<void> {
  for (const root of roots) {
    await new Deno.Command("watchman", {
      args: ["watch-del", root],
      stdout: "null",
      stderr: "null",
    }).output().catch(() => undefined);
  }
}

function stateLine(fields: Partial<GitStatus> = {}, action = ""): string {
  return formatState({
    oid: "",
    branch: "main",
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
    ...fields,
  }, action);
}

interface Daemon extends AsyncDisposable {
  socketPath: string;
  logPath: string;
  /** Sends SIGTERM and waits for the process to exit. */
  stop(): Promise<void>;
}

// Every daemon started here has its own runtime directory under the test's root.
async function startDaemon(root: string, pathPrefix?: string): Promise<Daemon> {
  const runtimePath = join(root, "runtime");
  const socketPath = join(runtimePath, "daemon.sock");
  const child = new Deno.Command("deno", {
    args: ["run", "--quiet", "-A", daemonScript],
    cwd: repositoryRoot,
    env: {
      PATH: pathPrefix ? `${pathPrefix}:${Deno.env.get("PATH") ?? ""}` : Deno.env.get("PATH") ?? "",
      DOT_PROMPT_GITD_RUNTIME_BASE: runtimePath,
      DOT_PROMPT_GITD_SOCKET_PATH: socketPath,
    },
    stdout: "null",
    stderr: "null",
  }).spawn();
  let stopping: Promise<void> | null = null;
  const stop = () => stopping ??= terminate();
  const terminate = async () => {
    try {
      child.kill("SIGTERM");
    } catch {
      // The daemon may already have exited after a startup failure.
    }
    try {
      await within(child.status, "the daemon exiting after SIGTERM");
    } catch (error) {
      child.kill("SIGKILL");
      await child.status;
      throw error;
    }
  };
  try {
    await waitFor(() => {
      try {
        return Deno.statSync(socketPath).isSocket === true;
      } catch {
        return false;
      }
    });
  } catch (error) {
    await stop();
    throw error;
  }
  return { socketPath, logPath: join(runtimePath, "daemon.log"), stop, [Symbol.asyncDispose]: stop };
}

interface Subscription extends AsyncDisposable {
  lines: string[];
  closed: Promise<void>;
  latest(): string;
}

// What a shell does at a prompt: one connection, one hello, then only reading.
async function subscribe(socketPath: string, top: string): Promise<Subscription> {
  const connection = await Deno.connect({ transport: "unix", path: socketPath });
  await connection.write(new TextEncoder().encode(`${JSON.stringify({ top })}\n`));
  const lines: string[] = [];
  const closed = (async () => {
    const buffer = new Uint8Array(4_096);
    let text = "";
    while (true) {
      const count = await connection.read(buffer).catch(() => null);
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
        connection.close();
      } catch {
        // The daemon closed it first.
      }
      await closed;
    },
  };
}

interface FakeConnection {
  top: string;
  send(text: string): Promise<void>;
  close(): void;
  /** Resolves with the milliseconds between the hello and the shell closing the connection. */
  ended: Promise<number>;
}

interface FakeDaemon extends AsyncDisposable {
  socketPath: string;
  hellos: string[];
  /** The next connection that has sent its hello. */
  next(timeoutMs?: number): Promise<FakeConnection>;
}

// Stands in for the daemon so that a test decides what a shell receives and when.
function fakeDaemon(root: string, acceptDelayMs = 0): FakeDaemon {
  const socketPath = join(root, "fake.sock");
  const listener = Deno.listen({ transport: "unix", path: socketPath });
  const hellos: string[] = [];
  const waiting: FakeConnection[] = [];
  const connections: Deno.Conn[] = [];
  const sessions: Promise<void>[] = [];
  let stopped = false;

  const serve = async (connection: Deno.Conn) => {
    const buffer = new Uint8Array(4_096);
    let text = "";
    while (!text.includes("\n")) {
      const count = await connection.read(buffer).catch(() => null);
      if (count === null) return;
      text += new TextDecoder().decode(buffer.subarray(0, count));
    }
    const helloAt = performance.now();
    let reportEnd = (_ms: number) => {};
    const ended = new Promise<number>((resolvePromise) => reportEnd = resolvePromise);
    const top = String(JSON.parse(text.slice(0, text.indexOf("\n"))).top);
    hellos.push(top);
    waiting.push({
      top,
      ended,
      send: async (data) => {
        await connection.write(new TextEncoder().encode(data));
      },
      close: () => {
        try {
          connection.close();
        } catch {
          // Already closed.
        }
      },
    });
    while (await connection.read(buffer).catch(() => null) !== null);
    reportEnd(performance.now() - helloAt);
  };
  const accepting = (async () => {
    if (acceptDelayMs > 0) await pause(acceptDelayMs);
    while (!stopped) {
      try {
        const connection = await listener.accept();
        connections.push(connection);
        sessions.push(serve(connection));
      } catch {
        // Closed listener, or a client that left before being accepted.
      }
    }
  })();

  return {
    socketPath,
    hellos,
    async next(timeoutMs = 7_000) {
      await waitFor(() => waiting.length > 0, timeoutMs, 10);
      return waiting.shift()!;
    },
    async [Symbol.asyncDispose]() {
      stopped = true;
      listener.close();
      for (const connection of connections) {
        try {
          connection.close();
        } catch {
          // Already closed.
        }
      }
      await Promise.all([accepting, ...sessions]);
    },
  };
}

interface ZshResult {
  stdout: string;
  stderr: string;
  code: number;
}

// The only way these tests run prompt code in zsh. The socket path is required
// so that no test can reach the daemon of the person running the tests, and the
// daemon script defaults to a missing file so that no test starts one by accident.
async function zshPrompt(
  lines: string[],
  args: string[],
  options: { socketPath: string; cwd?: string; env?: Record<string, string> },
): Promise<ZshResult> {
  const script = [`source "${promptDir}/base.zsh"`, `source "${promptDir}/git.zsh"`, ...lines].join("\n");
  const output = await new Deno.Command("zsh", {
    args: ["-f", "-c", script, "--", ...args],
    cwd: options.cwd,
    env: {
      DOT_PROMPT_GITD_RUNTIME_BASE: dirname(options.socketPath),
      DOT_PROMPT_GITD_SOCKET_PATH: options.socketPath,
      DOT_PROMPT_GITD_SCRIPT: "/nonexistent/dot-prompt-gitd.ts",
      ...options.env,
    },
    stdout: "piped",
    stderr: "piped",
  }).output();
  return {
    stdout: new TextDecoder().decode(output.stdout),
    stderr: new TextDecoder().decode(output.stderr),
    code: output.code,
  };
}

// zsh -c has no line editor, so nothing calls the zle -F handler: wait for the
// descriptor and call the function behind the handler.
const RECEIVE = [
  "zmodload zsh/zselect",
  'zselect -t 500 -r "$DOT_PROMPT_GITD_FD"',
  'dot_prompt_git_receive "$DOT_PROMPT_GITD_FD"',
].join("; ");

// Runs an interactive zsh in a pty, forwards stdin to it and its output to
// stdout, and stops by itself after $1 seconds.
const PTY_BRIDGE = `
zmodload zsh/zpty zsh/zselect zsh/system zsh/datetime
zpty -b shell zsh -f -i
master=$REPLY
typeset -F deadline=$(( EPOCHREALTIME + $1 ))
typeset -A ready
while (( EPOCHREALTIME < deadline )); do
  zselect -A ready -t 20 -r 0 -r $master || continue
  if (( \${+ready[$master]} )); then
    sysread -i $master -t 0 chunk && print -rn -- "$chunk"
  fi
  if (( \${+ready[0]} )); then
    sysread -i 0 -t 0 chunk
    case $? in
      0) syswrite -o $master -- "$chunk" ;;
      5) break ;;
    esac
  fi
done
zpty -d shell
`;

interface PromptShell extends AsyncDisposable {
  send(text: string): Promise<void>;
  output(): string;
  waitFor(text: string, from?: number, timeoutMs?: number): Promise<void>;
  /** Presses a key bound to a widget that reports the shell's state, without running a command. */
  probe(): Promise<string>;
}

// An interactive zsh with the real hooks installed (base, git, init), driven through a pty.
async function openPromptShell(
  root: string,
  socketPath: string,
  env: Record<string, string> = {},
): Promise<PromptShell> {
  const probePath = join(root, `probe-${crypto.randomUUID().slice(0, 8)}`);
  const setupPath = `${probePath}.zsh`;
  await Deno.writeTextFile(
    setupPath,
    [
      // The options in .zshrc that change how code is parsed or expanded.
      "setopt extended_glob brace_ccl magic_equal_subst mark_dirs multios no_no_match numeric_glob_sort",
      `source "${promptDir}/base.zsh"`,
      `source "${promptDir}/git.zsh"`,
      `source "${promptDir}/init.zsh"`,
      "dp_probe() {",
      '  print -r -- "sched=${#zsh_scheduled_events} fd=${DOT_PROMPT_GITD_FD:+open} prompt=${DOT_PROMPT_GIT_PROMPT}" >> "$DP_PROBE"',
      "}",
      "zle -N dp_probe",
      "bindkey '^X^P' dp_probe",
      "",
    ].join("\n"),
  );
  const child = new Deno.Command("zsh", {
    args: ["-f", "-c", PTY_BRIDGE, "--", "90"],
    // Not inside a repository, so the shell connects only after the test changes directory.
    cwd: root,
    env: {
      TERM: "xterm",
      DOT_PROMPT_ENABLE_TRANSIENT: "1",
      DP_PROBE: probePath,
      DOT_PROMPT_GITD_RUNTIME_BASE: dirname(socketPath),
      DOT_PROMPT_GITD_SOCKET_PATH: socketPath,
      DOT_PROMPT_GITD_SCRIPT: "/nonexistent/dot-prompt-gitd.ts",
      ...env,
    },
    stdin: "piped",
    stdout: "piped",
    stderr: "null",
  }).spawn();
  const stdin = child.stdin.getWriter();
  let output = "";
  const reading = (async () => {
    const decoder = new TextDecoder();
    for await (const chunk of child.stdout) output += decoder.decode(chunk, { stream: true });
  })();
  const shell: PromptShell = {
    send: (text) => stdin.write(new TextEncoder().encode(text)),
    output: () => output,
    async waitFor(text, from = 0, timeoutMs = 7_000) {
      try {
        await waitFor(() => output.indexOf(text, from) >= 0, timeoutMs, 10);
      } catch (error) {
        throw new Error(`${error}: ${JSON.stringify(text)} not in ${JSON.stringify(output.slice(from))}`);
      }
    },
    async probe() {
      const before = readText(probePath);
      await shell.send("\x18\x10");
      await waitFor(() => readText(probePath).length > before.length, 7_000, 10);
      return readText(probePath).slice(before.length).replace(/\n$/, "");
    },
    async [Symbol.asyncDispose]() {
      await stdin.close().catch(() => undefined);
      await Promise.all([child.status, reading]);
    },
  };
  await shell.send(`source ${setupPath}\r`);
  return shell;
}

const watchmanAvailable = await commandSucceeds("watchman", ["--version"]);

Deno.test("Deno が PATH にない場合は、前のプロンプトの Git 表示を無音で消し、daemon の起動も再接続も予約しない", async () => {
  const root = await makeRoot("dp-nodeno-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    const result = await zshPrompt(
      [
        // The state shown by the previous prompt, from before the daemon went away.
        "DOT_PROMPT_GIT_TOP=$PWD",
        "DOT_PROMPT_GIT_LINE=$1",
        "dot_prompt_git_precmd",
        "dot_prompt_build_git_prompt",
        'print -r -- "top=$DOT_PROMPT_GIT_TOP fd=$DOT_PROMPT_GITD_FD prompt=$DOT_PROMPT_GIT_PROMPT" \\',
        '  "spawned=$DOT_PROMPT_GITD_SPAWNED_AT sched=${#zsh_scheduled_events}"',
      ],
      [stateLine()],
      {
        socketPath: join(root, "missing.sock"),
        cwd: join(root, "repo"),
        env: { PATH: "/usr/bin:/bin", DOT_PROMPT_GITD_SCRIPT: daemonScript },
      },
    );
    assertEquals(result.stderr, "");
    assertEquals(result.stdout, `top=${join(root, "repo")} fd= prompt= spawned=0 sched=0\n`);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("デーモンの受け付けが遅れても precmd は待たず、接続を保ったまま hello を届ける", async () => {
  const root = await makeRoot("dp-accept-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    await using fake = fakeDaemon(root, 1_300);
    const client = zshPrompt(
      [
        "zmodload zsh/datetime",
        "started=$EPOCHREALTIME",
        "dot_prompt_git_precmd",
        'printf "precmd_ms=%.0f\\n" $(( (EPOCHREALTIME - started) * 1000 ))',
        RECEIVE,
        'print -r -- "line=$DOT_PROMPT_GIT_LINE"',
      ],
      [],
      { socketPath: fake.socketPath, cwd: join(root, "repo") },
    );
    const connection = await fake.next();
    assertEquals(connection.top, join(root, "repo"));
    await connection.send(`${stateLine()}\n`);
    const result = await client;
    assertEquals(result.stderr, "");
    const precmdMs = Number(/precmd_ms=(\d+)/.exec(result.stdout)?.[1]);
    assert(precmdMs < 100, `precmd took ${precmdMs} ms`);
    assertStringIncludes(result.stdout, `line=${stateLine()}`);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("prompt_subst のもとで、ディレクトリ名やブランチ名の $(...) をプロンプトの表示で実行しない", async () => {
  const root = await makeRoot("dp-prompt-subst-");
  const directory = join(root, "$(touch from-path)");
  try {
    await Deno.mkdir(directory);
    const result = await zshPrompt(
      [
        "setopt prompt_subst",
        "DOT_PROMPT_GIT_LINE=$1",
        "dot_prompt_build_git_prompt",
        "dot_prompt_build_left 0",
        "dot_prompt_apply_render",
        // ${(e)...} performs the same single expansion pass that prompt_subst applies to PROMPT.
        'print -r -- "${(e)PROMPT}"',
      ],
      [stateLine({ branch: "$(touch from-branch)", upstream: "$(touch from-upstream)" }, "$(touch from-action)")],
      { socketPath: join(root, "missing.sock"), cwd: directory },
    );
    assertEquals(result.stderr, "");
    assertStringIncludes(result.stdout, "$(touch from-path)");
    assertStringIncludes(result.stdout, "$(touch from-branch)");
    assertStringIncludes(result.stdout, "$(touch from-upstream)");
    assertStringIncludes(result.stdout, "$(touch from-action)");
    assertEquals([...Deno.readDirSync(directory)].map((entry) => entry.name), []);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("別の repo に入ると表示を消し、最初の状態行で表示する。repo の外では接続しない", async () => {
  const root = await makeRoot("dp-switch-");
  try {
    await Deno.mkdir(join(root, "one", ".git"), { recursive: true });
    await Deno.mkdir(join(root, "two", ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    const show = 'dot_prompt_build_git_prompt; print -r -- "prompt=$DOT_PROMPT_GIT_PROMPT"';
    const client = zshPrompt(
      [
        'cd "$1/one"; dot_prompt_git_precmd',
        RECEIVE,
        show,
        'cd "$1/two"; dot_prompt_git_precmd',
        show,
        RECEIVE,
        show,
        'cd "$1"; dot_prompt_git_precmd',
        show,
        'print -r -- "fd=$DOT_PROMPT_GITD_FD sched=${#zsh_scheduled_events}"',
      ],
      [root],
      { socketPath: fake.socketPath },
    );
    const first = await fake.next();
    await first.send(`${stateLine({ branch: "one" })}\n`);
    const second = await fake.next();
    await within(first.ended, "closing the connection of the repository left");
    await second.send(`${stateLine({ branch: "two" })}\n`);
    const result = await client;
    await within(second.ended, "closing the connection outside a repository");

    assertEquals(result.stderr, "");
    const prompts = result.stdout.trimEnd().split("\n");
    assertStringIncludes(prompts[0], "%B%F{7} one");
    assertEquals(prompts[1], "prompt=");
    assertStringIncludes(prompts[2], "%B%F{7} two");
    assertEquals(prompts[3], "prompt=");
    assertEquals(prompts[4], "fd= sched=0");
    assertEquals(fake.hellos, [join(root, "one"), join(root, "two")]);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("同じ repo 内の移動（symlink 経由、パターン文字を含む名前）では接続と表示を保つ", async () => {
  const root = await makeRoot("dp-symlink-");
  const top = join(root, "re[p]o*");
  const link = join(root, "link");
  try {
    await Deno.mkdir(join(top, ".git"), { recursive: true });
    await Deno.mkdir(join(top, "sub"));
    await Deno.symlink(join(top, "sub"), link);
    await using fake = fakeDaemon(root);
    const report = 'print -r -- "fd=$DOT_PROMPT_GITD_FD top=$DOT_PROMPT_GIT_TOP line=$DOT_PROMPT_GIT_LINE"';
    const client = zshPrompt(
      [
        // An unquoted comparison is a pattern match only with this option; the code must not depend on it being off.
        "setopt globsubst",
        'cd "$1"; dot_prompt_git_precmd',
        RECEIVE,
        report,
        'cd "$1/sub"; dot_prompt_git_precmd',
        report,
        'cd "$2"; dot_prompt_git_precmd',
        report,
      ],
      [top, link],
      { socketPath: fake.socketPath },
    );
    const connection = await fake.next();
    await connection.send(`${stateLine()}\n`);
    const result = await client;

    assertEquals(result.stderr, "");
    const reports = result.stdout.trimEnd().split("\n");
    assertMatch(reports[0], /^fd=\d+ /);
    assertStringIncludes(reports[0], `top=${top} line=${stateLine()}`);
    assertEquals(reports[1], reports[0]);
    assertEquals(reports[2], reports[0]);
    assertEquals(fake.hellos, [top]);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("行数だけの更新を色付きで描画し、差分ゼロとリポジトリ移動で表示を消す", async () => {
  const root = await makeRoot("dp-render-");
  try {
    const result = await zshPrompt(
      [
        'for line in "$@"; do',
        "  DOT_PROMPT_GIT_LINE=$line",
        "  dot_prompt_build_git_prompt",
        '  print -r -- "$DOT_PROMPT_GIT_PROMPT"',
        "done",
        "DOT_PROMPT_GIT_TOP=/somewhere/else",
        "dot_prompt_git_precmd",
        "dot_prompt_build_git_prompt",
        'print -r -- "reset=$DOT_PROMPT_GIT_LINE,$DOT_PROMPT_GIT_PROMPT"',
      ],
      [
        stateLine({ unstaged: 1, added: 3, deleted: 2 }),
        stateLine({ unstaged: 1, added: 8, deleted: 2 }),
        stateLine({ unstaged: 1 }),
      ],
      { socketPath: join(root, "missing.sock"), cwd: root },
    );
    assertEquals(result.stderr, "");
    const lines = result.stdout.trimEnd().split("\n");
    assertStringIncludes(lines[0], "M:1%f %F{244}│%f %F{2}+3%f %F{1}-2%f");
    assertStringIncludes(lines[1], "M:1%f %F{244}│%f %F{2}+8%f %F{1}-2%f");
    assert(!lines[2].includes("+0"));
    assert(!lines[2].includes("-0"));
    assertEquals(lines[3], "reset=,");
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("repo の最上位を、fork せずに git と同じ規則で見つける", async () => {
  const root = await makeRoot("dp-top-");
  const repo = join(root, "repo");
  try {
    await initRepo(repo);
    await Deno.mkdir(join(repo, "sub", "deep"), { recursive: true });
    await commitTrackedFile(repo);
    await run("git", ["worktree", "add", "-q", join(repo, ".git", "wt", "linked"), "-b", "linked"], repo);
    await Deno.mkdir(join(repo, ".git", "wt", "linked", "inner"));
    await Deno.symlink(join(repo, "sub", "deep"), join(root, "link"));
    const directories = [
      repo,
      join(repo, "sub", "deep"),
      join(repo, ".git", "wt", "linked"),
      join(repo, ".git", "wt", "linked", "inner"),
      join(repo, ".git"),
      join(repo, ".git", "wt"),
      join(repo, ".git", "refs", "heads"),
      join(root, "link"),
      root,
    ];
    const result = await zshPrompt(
      [
        'for directory in "$@"; do',
        '  cd "$directory"',
        "  dot_prompt_git_find_top",
        '  print -r -- "$REPLY|$(git rev-parse --show-toplevel 2>/dev/null)"',
        "done",
      ],
      directories,
      { socketPath: join(root, "missing.sock"), env: { PATH: Deno.env.get("PATH") ?? "" } },
    );
    assertEquals(result.stderr, "");
    const answers = result.stdout.trimEnd().split("\n").map((line) => line.split("|"));
    assertEquals(answers.map(([found]) => found), answers.map(([, expected]) => expected));
    assertEquals(answers.map(([found]) => found), [
      repo,
      repo,
      join(repo, ".git", "wt", "linked"),
      join(repo, ".git", "wt", "linked"),
      "",
      "",
      "",
      repo,
      "",
    ]);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("途中までの行で待たされず、まとめて届いた行は最新だけを使い、同じ行では再描画しない", async () => {
  const root = await makeRoot("dp-receive-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    const receiveTimed = [
      'zselect -t 500 -r "$DOT_PROMPT_GITD_FD"',
      "started=$EPOCHREALTIME",
      'dot_prompt_git_receive "$DOT_PROMPT_GITD_FD"',
      "changed=$?",
      'printf "changed=%d ms=%.0f line=%s\\n" $changed $(( (EPOCHREALTIME - started) * 1000 )) "$DOT_PROMPT_GIT_LINE"',
    ].join("; ");
    const client = zshPrompt(
      [
        "setopt globsubst",
        "zmodload zsh/zselect zsh/datetime",
        "dot_prompt_git_precmd",
        receiveTimed,
        receiveTimed,
        receiveTimed,
      ],
      [],
      { socketPath: fake.socketPath, cwd: join(root, "repo") },
    );
    const connection = await fake.next();
    const older = stateLine({ branch: "older" });
    // With globsubst, "[" and "*" make an unquoted comparison a pattern match.
    const newest = stateLine({ branch: "new[e]st*" });
    await connection.send(`${older}\n${newest.slice(0, 20)}`);
    await pause(400);
    await connection.send(`${newest.slice(20)}\n`);
    await pause(400);
    await connection.send(`${newest}\n`);
    const result = await client;

    assertEquals(result.stderr, "");
    const reports = result.stdout.trimEnd().split("\n");
    assertMatch(reports[0], /^changed=0 ms=\d{1,2} /);
    assertStringIncludes(reports[0], `line=${older}`);
    assertMatch(reports[1], /^changed=0 ms=\d{1,2} /);
    assertStringIncludes(reports[1], `line=${newest}`);
    assertMatch(reports[2], /^changed=1 /);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("デーモンが切断するか不正な行を送ると表示を消す。応答のあった接続だけ再接続を予約し、daemon は起動しない", async () => {
  const root = await makeRoot("dp-eof-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    const report = 'print -r -- "changed=$? fd=$DOT_PROMPT_GITD_FD line=$DOT_PROMPT_GIT_LINE ' +
      'retry=$DOT_PROMPT_GITD_RETRY_DELAY sched=${#zsh_scheduled_events} spawned=$DOT_PROMPT_GITD_SPAWNED_AT"';
    const client = zshPrompt(
      [
        "dot_prompt_git_precmd",
        `${RECEIVE}; ${report}`,
        `${RECEIVE}; ${report}`,
        // What sched runs one second later.
        "dot_prompt_git_retry",
        `${RECEIVE}; ${report}`,
        `${RECEIVE}; ${report}`,
        "dot_prompt_git_retry",
        `${RECEIVE}; ${report}`,
      ],
      [],
      // With deno, watchman and a readable script, only the rule "the receiving side never starts a daemon" stops it.
      { socketPath: fake.socketPath, cwd: join(root, "repo"), env: { DOT_PROMPT_GITD_SCRIPT: daemonScript } },
    );
    const first = await fake.next();
    await first.send(`${stateLine()}\n`);
    await pause(300);
    first.close();
    const second = await fake.next();
    await second.send(`${stateLine({ branch: "again" })}\n`);
    await pause(300);
    await second.send("not a line\n");
    const third = await fake.next();
    // The reply of the daemon from before this protocol.
    await third.send("ok\n");
    const result = await client;

    assertEquals(result.stderr, "");
    const reports = result.stdout.trimEnd().split("\n");
    assertMatch(reports[0], new RegExp(`^changed=0 fd=\\d+ line=${stateLine()} retry=0 sched=0 spawned=0$`));
    assertEquals(reports[1], "changed=0 fd= line= retry=1 sched=1 spawned=0");
    assertMatch(reports[2], /^changed=0 fd=\d+ line=branch 'again' .* retry=0 sched=0 spawned=0$/);
    assertEquals(reports[3], "changed=0 fd= line= retry=1 sched=1 spawned=0");
    // A connection that never answered was refused: asking again every second would be refused again.
    assertEquals(reports[4], "changed=1 fd= line= retry=0 sched=0 spawned=0");
    assertEquals(fake.hellos.length, 3);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("デーモンがいない間の再接続は間隔を倍にしながら上限で続け、daemon を起動しない", async () => {
  const root = await makeRoot("dp-backoff-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    const result = await zshPrompt(
      [
        "DOT_PROMPT_GIT_TOP=$PWD",
        "DOT_PROMPT_GIT_LINE='stale'",
        'dot_prompt_reset_prompt_full() { print -r -- "rendered=$DOT_PROMPT_GIT_LINE" }',
        "dot_prompt_git_schedule_retry 1",
        'repeat 7 { dot_prompt_git_retry; print -r -- "retry=$DOT_PROMPT_GITD_RETRY_DELAY sched=${#zsh_scheduled_events}" }',
        'print -r -- "spawned=$DOT_PROMPT_GITD_SPAWNED_AT"',
      ],
      [],
      {
        socketPath: join(root, "missing.sock"),
        cwd: join(root, "repo"),
        env: { DOT_PROMPT_GITD_SCRIPT: daemonScript },
      },
    );
    assertEquals(result.stderr, "");
    assertEquals(result.stdout.trimEnd().split("\n"), [
      "rendered=",
      "retry=2 sched=1",
      "retry=4 sched=1",
      "retry=8 sched=1",
      "retry=16 sched=1",
      "retry=32 sched=1",
      "retry=32 sched=1",
      "retry=32 sched=1",
      "spawned=0",
    ]);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("接続直後にデーモンが落ちても shell は SIGPIPE で終了しない", async () => {
  const root = await makeRoot("dp-sigpipe-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    const client = zshPrompt(
      [
        "zmodload zsh/zselect",
        "dot_prompt_git_precmd",
        "fd=$DOT_PROMPT_GITD_FD",
        // Readable at end of file: the daemon has closed its side.
        "zselect -t 500 -r $fd",
        'dot_prompt_git_write $fd "first"',
        'dot_prompt_git_write $fd "second"',
        "print -r -- survived",
      ],
      [],
      { socketPath: fake.socketPath, cwd: join(root, "repo") },
    );
    (await fake.next()).close();
    const result = await client;
    assertEquals(result, { stdout: "survived\n", stderr: "", code: 0 });
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("preexec で接続を閉じ、プロンプト表示中に起動した子プロセスにもソケットを渡さない", async () => {
  const root = await makeRoot("dp-inherit-");
  try {
    await Deno.mkdir(join(root, "repo", ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    const client = zshPrompt(
      [
        `source "${promptDir}/init.zsh"`,
        "zmodload zsh/zselect",
        "dot_prompt_git_precmd",
        // Started while the connection is open, like a process started by a zle widget.
        "sleep 3 &",
        "zselect -t 30",
        'dot_prompt_preexec "" "sleep 3"',
        'print -r -- "fd=$DOT_PROMPT_GITD_FD sched=${#zsh_scheduled_events}"',
        "wait",
      ],
      [],
      { socketPath: fake.socketPath, cwd: join(root, "repo"), env: { PATH: Deno.env.get("PATH") ?? "" } },
    );
    const connection = await fake.next();
    const endedAfterMs = await within(connection.ended, "closing the connection");
    const result = await client;
    assertEquals(result.stderr, "");
    assertEquals(result.stdout, "fd= sched=0\n");
    assert(endedAfterMs < 1_500, `the daemon saw the connection end after ${endedAfterMs} ms`);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("対話 shell が、キー入力なしで届いた状態を再描画し、transient prompt と clear-screen でも fork しない", async () => {
  const root = await makeRoot("dp-pty-");
  const repo = join(root, "repo");
  try {
    await Deno.mkdir(join(repo, ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    await using shell = await openPromptShell(root, fake.socketPath);
    // From here on, any fork in this shell fails and prints an error.
    await shell.send(`ulimit -u 1\rcd ${repo}\r`);

    const first = await fake.next();
    assertEquals(first.top, repo);
    let mark = shell.output().length;
    await first.send(`${stateLine({ branch: "pushed-one" })}\n`);
    await shell.waitFor("pushed-one", mark);
    assertEquals(await shell.probe(), "sched=0 fd=open prompt=%B%F{7} pushed-one%f%b| %B%F{2}✔%f%b  ");

    mark = shell.output().length;
    await shell.send("true\r");
    await within(first.ended, "closing the connection before the command");
    const second = await fake.next();
    // The transient prompt replaces the two prompt lines with "$ " and the command.
    await shell.waitFor("\x1b[A", mark);
    const redrawn = shell.output().slice(shell.output().indexOf("\x1b[A", mark));
    assertStringIncludes(redrawn.split("\n")[0], "$\x1b[39m true");
    mark = shell.output().length;
    await second.send(`${stateLine({ branch: "pushed-two", unstaged: 1 })}\n`);
    await shell.waitFor("pushed-two", mark);

    mark = shell.output().length;
    await shell.send("\x0c");
    await shell.waitFor("\x1b[H\x1b[2J", mark);
    await shell.waitFor("pushed-two", shell.output().indexOf("\x1b[H\x1b[2J", mark));

    assert(!shell.output().includes("fork failed"), shell.output());
    assert(!shell.output().includes("zsh:"), shell.output());
    mark = shell.output().length;
    await shell.send("/bin/echo forked\r");
    await shell.waitFor("fork failed", mark);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test("対話 shell が、応答しないデーモンの表示を時間切れで消し、切断後は Enter なしで接続し直す", async () => {
  const root = await makeRoot("dp-pty-retry-");
  const repo = join(root, "repo");
  try {
    await Deno.mkdir(join(repo, ".git"), { recursive: true });
    await using fake = fakeDaemon(root);
    await using shell = await openPromptShell(root, fake.socketPath);
    await shell.send(`cd ${repo}\r`);

    const first = await fake.next();
    let mark = shell.output().length;
    await first.send(`${stateLine({ branch: "pushed-one" })}\n`);
    await shell.waitFor("pushed-one", mark);

    // The next prompt shows the state from before the command, and this daemon never confirms it.
    await shell.send("true\r");
    const silent = await fake.next();
    assertStringIncludes(await shell.probe(), "prompt=%B%F{7} pushed-one");
    assert(await within(silent.ended, "giving up on the silent daemon") < 3_000);
    const third = await fake.next();
    assertEquals(await shell.probe(), "sched=1 fd=open prompt=");
    mark = shell.output().length;
    await third.send(`${stateLine({ branch: "pushed-three" })}\n`);
    await shell.waitFor("pushed-three", mark);
    assertStringIncludes(await shell.probe(), "sched=0 fd=open prompt=%B%F{7} pushed-three");

    // The daemon goes away while the shell idles at its prompt.
    third.close();
    const fourth = await fake.next();
    assertEquals(await shell.probe(), "sched=1 fd=open prompt=");
    mark = shell.output().length;
    await fourth.send(`${stateLine({ branch: "pushed-four" })}\n`);
    await shell.waitFor("pushed-four", mark);
    assert(!shell.output().includes("zsh:"), shell.output());
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

Deno.test({
  name: "デーモンがいなければ最初のプロンプトが起動し、Enter なしで Git 表示が出る",
  ignore: !watchmanAvailable,
  async fn() {
    const root = await makeRoot("dp-pty-spawn-");
    const repo = join(root, "repo");
    const runtimePath = join(root, "runtime");
    const pidPath = join(runtimePath, "daemon.pid");
    try {
      await initRepo(repo);
      await commitTrackedFile(repo);
      {
        await using shell = await openPromptShell(root, join(runtimePath, "daemon.sock"), {
          DOT_PROMPT_GITD_SCRIPT: daemonScript,
        });
        await shell.send(`cd ${repo}\r`);
        await shell.waitFor(" main", 0, 20_000);
        assertStringIncludes(await shell.probe(), "sched=0 fd=open prompt=%B%F{7} main");
      }
      // The daemon serves every shell, so it must outlive the terminal that started it.
      await pause(500);
      assert(await commandSucceeds("kill", ["-0", readText(pidPath).trim()]), "the daemon exited with its shell");
    } finally {
      // The shell is gone, so nothing can start this daemon again.
      const pid = readText(pidPath).trim();
      if (pid) {
        await commandSucceeds("kill", ["-TERM", pid]);
        await waitFor(async () => !await commandSucceeds("kill", ["-0", pid]));
      }
      await deleteWatchRoots(repo, join(repo, ".git"));
      await Deno.remove(root, { recursive: true });
    }
  },
});

Deno.test({
  name: "旧形式の登録要求には何も返さずに接続を閉じ、受け付け前に閉じた接続があっても次の shell を待たせない",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-old-");
    const repoPath = join(integrationRoot, "repo");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      await using daemon = await startDaemon(integrationRoot);

      const old = await Deno.connect({ transport: "unix", path: daemon.socketPath });
      await old.write(new TextEncoder().encode(`${JSON.stringify({ top: repoPath, cachePath: "/tmp/cache" })}\n`));
      assertEquals(await old.read(new Uint8Array(16)), null);
      old.close();

      for (let index = 0; index < 20; index++) {
        (await Deno.connect({ transport: "unix", path: daemon.socketPath })).close();
      }
      const started = performance.now();
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("branch 'main'"), 7_000, 10);
      // The accept loop used to back off up to a second after such connections.
      assert(performance.now() - started < 1_000, readText(daemon.logPath));
      assert(!readText(daemon.logPath).includes("accept failed"), readText(daemon.logPath));
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "分解形や大文字を含む名前の repo に別の表記で入っても、git と同じ最上位を送って登録できる",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-unicode-");
    // The name on disk is decomposed and capitalized; the shell enters it precomposed and in lower case.
    const repoPath = join(integrationRoot, "Cafe\u0301 Repo");
    try {
      await initRepo(repoPath);
      await Deno.mkdir(join(repoPath, "Sub"));
      await commitTrackedFile(repoPath);
      await using daemon = await startDaemon(integrationRoot);
      const result = await zshPrompt(
        [
          "dot_prompt_git_precmd",
          RECEIVE,
          'print -r -- "top=$DOT_PROMPT_GIT_TOP"',
          'print -r -- "git=$(git rev-parse --show-toplevel)"',
          'print -r -- "line=$DOT_PROMPT_GIT_LINE"',
        ],
        [],
        { socketPath: daemon.socketPath, cwd: join(integrationRoot, "caf\u00e9 repo", "sub") },
      );
      assertEquals(result.stderr, "", readText(daemon.logPath));
      const [top, gitTop, line] = result.stdout.trimEnd().split("\n");
      assertEquals(top, `top=${repoPath}`);
      assertEquals(gitTop, `git=${repoPath}`);
      assertStringIncludes(line, "line=branch 'main'");
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "SIGTERM を受けると、プロンプト表示中の shell の接続を閉じて終了する",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-term-");
    const repoPath = join(integrationRoot, "repo");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      await using daemon = await startDaemon(integrationRoot);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("branch 'main'"));
      const stopped = daemon.stop();
      await within(shell.closed, "closing the connected shell");
      await stopped;
      assertEquals([...Deno.readDirSync(join(integrationRoot, "runtime"))].map((entry) => entry.name), ["daemon.log"]);
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "コマンド直後の実ファイル変更が debounce を待たずにプロンプトへ届く",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-latency-");
    const repoPath = join(integrationRoot, "repo");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      await using daemon = await startDaemon(integrationRoot);
      {
        await using shell = await subscribe(daemon.socketPath, repoPath);
        await waitFor(() => shell.latest().includes("unstaged '0'"));
      }

      // The fastest of three tries, so that a busy machine does not fail the
      // test. Without the shortcut every try takes the 300 ms debounce plus Git.
      let fastest = Infinity;
      for (let attempt = 1; attempt <= 3 && fastest >= 300; attempt++) {
        await pause(500);
        await using shell = await subscribe(daemon.socketPath, repoPath);
        await waitFor(() => shell.lines.length > 0, 7_000, 5);
        const started = performance.now();
        await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n" + "more\n".repeat(attempt));
        await waitFor(() => shell.latest().includes(`added '${attempt}'`), 7_000, 5);
        fastest = Math.min(fastest, performance.now() - started);
      }
      assert(fastest < 300, `the update took ${fastest} ms\n${readText(daemon.logPath)}`);
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "100回の連続変更を1回の Git 更新にまとめ、内容が同じなら行を送り直さず、shell 側は git を起動しない",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-");
    const repoPath = join(integrationRoot, "repo");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      const gitShim = await createGitShim(integrationRoot);
      await using daemon = await startDaemon(integrationRoot, gitShim.binPath);

      // Only deno and watchman are on this shell's PATH, so it cannot run git.
      const isolatedBin = join(integrationRoot, "bin");
      await Deno.mkdir(isolatedBin);
      await Deno.symlink(Deno.execPath(), join(isolatedBin, "deno"));
      const watchmanPath = new TextDecoder().decode(
        (await run("/bin/zsh", ["-f", "-c", "command -v watchman"])).stdout,
      ).trim();
      await Deno.symlink(watchmanPath, join(isolatedBin, "watchman"));
      const zshPath = new TextDecoder().decode((await run("/bin/zsh", ["-f", "-c", "command -v zsh"])).stdout).trim();
      await Deno.symlink(zshPath, join(isolatedBin, "zsh"));
      const firstPrompt = await zshPrompt(
        ["dot_prompt_git_precmd", RECEIVE, 'print -r -- "top=$DOT_PROMPT_GIT_TOP line=$DOT_PROMPT_GIT_LINE"'],
        [],
        { socketPath: daemon.socketPath, cwd: repoPath, env: { PATH: isolatedBin } },
      );
      assertEquals(firstPrompt.stderr, "");
      assertStringIncludes(firstPrompt.stdout, `top=${repoPath} line=branch 'main'`);
      assertStringIncludes(firstPrompt.stdout, "unstaged '0'");

      await using shell = await subscribe(daemon.socketPath, repoPath);
      try {
        await waitFor(() => gitStatusCount(gitShim.callLog) >= 1 && shell.latest().includes("unstaged '0'"));
      } catch (error) {
        throw new Error(
          `${error}\ndaemon log:\n${readText(daemon.logPath)}\ngit calls:\n${readText(gitShim.callLog)}\nlines:\n${
            shell.lines.join("\n")
          }`,
        );
      }
      await pause(400);

      const refreshesBeforeCookie = gitStatusCount(gitShim.callLog);
      await run("watchman", ["clock", repoPath]);
      await pause(500);
      assertEquals(gitStatusCount(gitShim.callLog), refreshesBeforeCookie);

      const initialRefreshes = refreshesBeforeCookie;
      for (let index = 0; index < 100; index++) {
        Deno.writeTextFileSync(join(repoPath, "tracked.txt"), `change-${index}\n`);
      }

      try {
        await waitFor(() =>
          gitStatusCount(gitShim.callLog) >= initialRefreshes + 1 && shell.latest().includes("unstaged '1'")
        );
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(daemon.logPath)}\nlines:\n${shell.lines.join("\n")}`);
      }
      await pause(700);

      assertEquals(gitStatusCount(gitShim.callLog) - initialRefreshes, 1);
      assertStringIncludes(shell.latest(), "unstaged '1'");
      assertStringIncludes(shell.latest(), "added '1' deleted '1'");

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "one\ntwo\nthree\n");
      await waitFor(() => shell.latest().includes("added '3' deleted '1'"));
      await pause(700);

      const refreshesBeforeTouch = gitStatusCount(gitShim.callLog);
      const linesBeforeTouch = shell.lines.length;
      const touchedAt = new Date();
      await Deno.utime(join(repoPath, "tracked.txt"), touchedAt, touchedAt);
      await waitFor(() => gitStatusCount(gitShim.callLog) > refreshesBeforeTouch);
      await pause(700);
      assertEquals(shell.lines.length, linesBeforeTouch);
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "index.lock が残っていても変更ファイル数を更新し、zsh のプロンプトへ反映する",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-lock-");
    const repoPath = join(integrationRoot, "repo");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      const indexLockPath = join(repoPath, ".git", "index.lock");
      await Deno.writeTextFile(indexLockPath, "");

      await using daemon = await startDaemon(integrationRoot);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("unstaged '0'"));

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "changed\n");
      await Deno.writeTextFile(join(repoPath, "untracked.txt"), "new\n");
      try {
        await waitFor(() => shell.latest().includes("unstaged '1'") && shell.latest().includes("untracked '1'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(daemon.logPath)}\nlines:\n${shell.lines.join("\n")}`);
      }

      const prompt = await zshPrompt(
        [
          "dot_prompt_git_precmd",
          RECEIVE,
          "dot_prompt_build_git_prompt",
          "dot_prompt_build_left 0",
          "dot_prompt_apply_render",
          'print -r -- "${(e)PROMPT}"',
        ],
        [],
        { socketPath: daemon.socketPath, cwd: repoPath },
      );
      assertEquals(prompt.stderr, "");
      assertStringIncludes(prompt.stdout, "M:1");
      assertStringIncludes(prompt.stdout, "?:1");
      assertStringIncludes(prompt.stdout, "%F{2}+2%f %F{1}-1%f");
      assert(Deno.statSync(indexLockPath).isFile);

      await Deno.writeTextFile(join(repoPath, "untracked.txt"), "new\nmore\nlast");
      await waitFor(() => shell.latest().includes("added '4' deleted '1'"));

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "initial\n");
      await Deno.remove(join(repoPath, "untracked.txt"));
      await waitFor(() =>
        shell.latest().includes("unstaged '0'") && shell.latest().includes("untracked '0'") &&
        shell.latest().includes("added '0' deleted '0'")
      );
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "ignore 対象と .git 内に置いた worktree の変更では git status を起動しない",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-noise-");
    const repoPath = join(integrationRoot, "repo");
    const worktreeBeforeStart = join(repoPath, ".git", "wt", "before");
    const worktreeAfterStart = join(repoPath, ".git", "wt", "after");
    try {
      await initRepo(repoPath);
      await Deno.writeTextFile(join(repoPath, ".gitignore"), "ignored/\n");
      await commitTrackedFile(repoPath, ".gitignore");
      await run("git", ["worktree", "add", "-q", worktreeBeforeStart, "-b", "before"], repoPath);
      await Deno.mkdir(join(repoPath, "ignored"));
      const gitShim = await createGitShim(integrationRoot);

      await using daemon = await startDaemon(integrationRoot, gitShim.binPath);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      try {
        await waitFor(() => shell.latest().includes("unstaged '0'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(daemon.logPath)}\ngit calls:\n${readText(gitShim.callLog)}`);
      }
      await run("git", ["worktree", "add", "-q", worktreeAfterStart, "-b", "after"], repoPath);
      await pause(1_500);

      const refreshesBefore = gitStatusCount(gitShim.callLog);
      await Deno.writeTextFile(join(repoPath, "ignored", "build.log"), "noise\n");
      await Deno.remove(join(repoPath, "ignored", "build.log"));
      await Deno.writeTextFile(join(worktreeBeforeStart, "tracked.txt"), "worktree edit\n");
      await Deno.writeTextFile(join(worktreeAfterStart, "tracked.txt"), "worktree edit\n");
      const touchedAt = new Date();
      await Deno.utime(join(repoPath, ".git", "worktrees", "before", "gitdir"), touchedAt, touchedAt);
      await pause(1_500);
      assertEquals(gitStatusCount(gitShim.callLog), refreshesBefore);
      assertStringIncludes(shell.latest(), "unstaged '0'");

      await Deno.mkdir(join(repoPath, ".git", "local"));
      await Deno.writeTextFile(join(repoPath, ".git", "local", "included.conf"), "[status]\n");
      await waitFor(() => gitStatusCount(gitShim.callLog) > refreshesBefore);

      // A submodule named "objects" keeps its refs under modules/objects/.
      const refreshesBeforeSubmodule = gitStatusCount(gitShim.callLog);
      await Deno.mkdir(join(repoPath, ".git", "modules", "objects", "reftable"), { recursive: true });
      await Deno.writeTextFile(join(repoPath, ".git", "modules", "objects", "reftable", "tables.list"), "table\n");
      await waitFor(() => gitStatusCount(gitShim.callLog) > refreshesBeforeSubmodule);

      await Deno.writeTextFile(join(repoPath, "tracked.txt"), "changed\n");
      try {
        await waitFor(() => shell.latest().includes("unstaged '1'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(daemon.logPath)}\nlines:\n${shell.lines.join("\n")}`);
      }
      assert(gitStatusCount(gitShim.callLog) > refreshesBefore);

      await run("git", ["stash", "-q"], repoPath);
      await waitFor(() => shell.latest().includes("unstaged '0'") && shell.latest().includes("stash '1'"));

      await run("git", ["branch", "objects/topic"], repoPath);
      await run("git", ["branch", "-q", "--set-upstream-to=objects/topic"], repoPath);
      await run("git", ["commit", "--allow-empty", "-qm", "ahead"], repoPath);
      await waitFor(() => shell.latest().includes("ahead '1'"));
      await run("git", ["update-ref", "refs/heads/objects/topic", "HEAD"], repoPath);
      await waitFor(() => shell.latest().includes("ahead '0'"));
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "未追跡ファイルを同じサイズで書き換えて mtime を戻しても、行数を数え直す",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-mtime-");
    const repoPath = join(integrationRoot, "repo");
    const untrackedPath = join(repoPath, "untracked.txt");
    try {
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      await Deno.writeTextFile(untrackedPath, "abcd\n");
      const decomposedPath = join(repoPath, "café.txt");
      await Deno.writeTextFile(decomposedPath, "abcd\n");

      await using daemon = await startDaemon(integrationRoot);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("added '2' deleted '0'"));

      const rewriteKeepingStat = async (path: string) => {
        const { atime, mtime } = await Deno.stat(path);
        await Deno.writeTextFile(path, "a\nb\n\n");
        await Deno.utime(path, atime ?? new Date(), mtime ?? new Date());
      };
      await rewriteKeepingStat(untrackedPath);
      await waitFor(() => shell.latest().includes("added '4' deleted '0'"));
      await rewriteKeepingStat(decomposedPath);
      await waitFor(() => shell.latest().includes("added '6' deleted '0'"));
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "precomposeUnicode が無効な repo で、分解形の名前の未追跡ファイルの変更を ignore と取り違えない",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-nfd-");
    const repoPath = join(integrationRoot, "repo");
    const decomposedPath = join(repoPath, "café.txt");
    try {
      await initRepo(repoPath);
      await run("git", ["config", "core.precomposeUnicode", "false"], repoPath);
      await Deno.writeTextFile(join(repoPath, ".gitignore"), "café.txt\n");
      await run("git", ["add", ".gitignore"], repoPath);
      await run("git", ["commit", "-qm", "initial"], repoPath);
      await Deno.writeTextFile(decomposedPath, "one\n");

      await using daemon = await startDaemon(integrationRoot);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("untracked '1'") && shell.latest().includes("added '1'"));

      await Deno.writeTextFile(decomposedPath, "one\ntwo\nthree\n");
      await waitFor(() => shell.latest().includes("added '3'"));
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "watchman の再クロールで更新し、削除した worktree の監視をやめて、その shell の接続を閉じる",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-lifecycle-");
    const repoPath = join(integrationRoot, "repo");
    const worktreePath = join(integrationRoot, "wt");
    try {
      await initRepo(repoPath);
      await Deno.writeTextFile(join(repoPath, ".gitignore"), "ignored/\n");
      await commitTrackedFile(repoPath, ".gitignore");
      await run("git", ["worktree", "add", "-q", worktreePath, "-b", "wt"], repoPath);
      await Deno.mkdir(join(repoPath, "ignored"));
      const gitShim = await createGitShim(integrationRoot);
      const statusCountFor = (top: string) =>
        readText(gitShim.callLog).split("\n").filter((line) => line.startsWith(`-C ${top} status`)).length;

      await using daemon = await startDaemon(integrationRoot, gitShim.binPath);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await using worktreeShell = await subscribe(daemon.socketPath, worktreePath);
      await waitFor(() => shell.latest().includes("unstaged '0'") && worktreeShell.latest().includes("unstaged '0'"));
      await pause(700);
      assertEquals(statusCountFor(repoPath), 1);

      await run("watchman", ["debug-recrawl", repoPath]);
      await Deno.writeTextFile(join(repoPath, "ignored", "after-recrawl.log"), "noise\n");
      await waitFor(() => statusCountFor(repoPath) > 1);
      await pause(700);
      const refreshesAfterRecrawl = statusCountFor(repoPath);
      await Deno.writeTextFile(join(repoPath, "ignored", "later.log"), "noise\n");
      await pause(1_500);
      assertEquals(statusCountFor(repoPath), refreshesAfterRecrawl);

      await run("git", ["worktree", "remove", "--force", worktreePath], repoPath);
      await within(worktreeShell.closed, "closing the shell of the removed worktree");
      await pause(1_000);
      const refreshesAfterRemoval = statusCountFor(worktreePath);
      await run("git", ["commit", "--allow-empty", "-qm", "first"], repoPath);
      await pause(1_000);
      const refreshesAfterFirstCommit = statusCountFor(worktreePath);
      await run("git", ["commit", "--allow-empty", "-qm", "second"], repoPath);
      await pause(1_000);
      assert(refreshesAfterFirstCommit - refreshesAfterRemoval <= 1);
      assertEquals(statusCountFor(worktreePath), refreshesAfterFirstCommit);
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"), worktreePath);
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});

Deno.test({
  name: "Git refs の変更を検知し、push 後に ahead をゼロへ戻す",
  ignore: !watchmanAvailable,
  async fn() {
    const integrationRoot = await makeRoot("dp-gitd-refs-");
    const repoPath = join(integrationRoot, "repo");
    const remotePath = join(integrationRoot, "remote.git");
    try {
      await run("git", ["init", "-q", "--bare", remotePath]);
      await initRepo(repoPath);
      await commitTrackedFile(repoPath);
      await run("git", ["remote", "add", "origin", remotePath], repoPath);
      await run("git", ["push", "-qu", "origin", "HEAD:main"], repoPath);

      await using daemon = await startDaemon(integrationRoot);
      await using shell = await subscribe(daemon.socketPath, repoPath);
      await waitFor(() => shell.latest().includes("ahead '0'"));

      await run("git", ["commit", "--allow-empty", "-qm", "ahead"], repoPath);
      await waitFor(() => shell.latest().includes("ahead '1'"));

      await run("git", ["push", "-q"], repoPath);
      try {
        await waitFor(() => shell.latest().includes("ahead '0'"));
      } catch (error) {
        throw new Error(`${error}\ndaemon log:\n${readText(daemon.logPath)}\nlines:\n${shell.lines.join("\n")}`);
      }
    } finally {
      await deleteWatchRoots(repoPath, join(repoPath, ".git"));
      await Deno.remove(integrationRoot, { recursive: true });
    }
  },
});
