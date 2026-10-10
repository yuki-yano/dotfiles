import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

const root = new URL("../", import.meta.url).pathname;
const reader = join(root, ".config/claude/hooks/read-hook-json.ts");

async function readOpenPipe(chunks: Uint8Array[]): Promise<string> {
  const child = Bun.spawn([process.execPath, reader], {
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
  });
  const timeout = setTimeout(() => child.kill(), 2_000);
  try {
    for (const chunk of chunks) {
      child.stdin.write(chunk);
      await child.stdin.flush();
    }
    // Keep stdin open: complete JSON or the deadline must end the process.
    const [code, output, error] = await Promise.all([
      child.exited,
      new Response(child.stdout).text(),
      new Response(child.stderr).text(),
    ]);
    expect(error).toBe("");
    expect(code).toBe(0);
    return output;
  } finally {
    clearTimeout(timeout);
    child.stdin.end();
    child.kill();
  }
}

test("hook reader preserves UTF-8 split across chunks without waiting for EOF", async () => {
  const text = '{"session_id":"日本語"}';
  const bytes = Buffer.from(text);
  const split = bytes.indexOf(Buffer.from("日")) + 1;
  expect(await readOpenPipe([bytes.subarray(0, split), bytes.subarray(split)])).toBe(text);
});

test("hook reader drains large output before exiting with stdin open", async () => {
  const text = JSON.stringify({ text: "x".repeat(1024 * 1024) });
  expect(await readOpenPipe([Buffer.from(text)])).toBe(text);
});

for (const input of ["", "{", "[]", "null"]) {
  test(`hook reader discards incomplete or non-object input ${JSON.stringify(input)}`, async () => {
    expect(await readOpenPipe([Buffer.from(input)])).toBe("");
  });
}

test("hook reader rejects input exceeding 8 MiB", async () => {
  expect(await readOpenPipe([Buffer.from(JSON.stringify({ text: "x".repeat(8 * 1024 * 1024) }))])).toBe("");
});

test("agent-note hook resolves a home-relative directory and emits SessionStart context", async () => {
  const home = await mkdtemp(join(tmpdir(), "agent-note-test-"));
  try {
    const result = Bun.spawnSync([process.execPath, join(root, "bin/codex-session-start-agent-note.ts")], {
      env: { ...process.env, HOME: home, AGENT_NOTE_DIR: "~" },
      stdin: Buffer.from("{}"),
      stdout: "pipe",
      stderr: "pipe",
    });
    expect(result.exitCode).toBe(0);
    expect(result.stderr.toString()).toBe("");
    const context = JSON.parse(result.stdout.toString()).hookSpecificOutput;
    expect(context.hookEventName).toBe("SessionStart");
    expect(context.additionalContext).toContain(home);
  } finally {
    await rm(home, { recursive: true });
  }
});

const mockTool = `#!/usr/bin/env bun
import { appendFileSync } from "node:fs";
import { basename } from "node:path";
const bin = basename(process.argv[1]);
const args = process.argv.slice(2);
appendFileSync(process.env.MOCK_LOG, JSON.stringify({ bin, args, key: process.env.PANEPILOT_API_KEY ?? null }) + "\\n");
if (bin === "shitsurae" && args[0] === "display") console.log(JSON.stringify({ display: { frame: { x: -1000, y: 0, width: 1000, height: 800 }, visibleFrame: { x: -1000, y: 25, width: 1000, height: 775 } } }));
if (bin === "editprompt") process.exit(Number(process.env.MOCK_RESUME_CODE ?? 1));
if (bin === "tmux") {
  const field = args.at(-1);
  if (args[0] === "display-message") {
    if (field === "#{@vde_category}") console.log("work");
    if (field === "#{pane_unzoomed_height}") console.log("30");
    if (field === "#{window_layout}") console.log(JSON.stringify({ V: 2, L: { t: "v", w: 80, h: 50, x: 0, y: 0, c: [{ t: "p", I: "%1", w: 80, h: 30, x: 0, y: 0 }, { t: "p", I: "%2", w: 80, h: 12, x: 0, y: 31 }, { t: "p", I: "%3", w: 80, h: 6, x: 0, y: 44 }] } }));
  }
  if (args[0] === "split-window") console.log("%2");
  if (args[0] === "if-shell") console.log(process.env.MOCK_LAYOUT_RESULT ?? "layout-applied");
}
`;

type Call = { bin: string; args: string[]; key: string | null };

async function withMockTools(check: (dir: string, log: string) => Promise<void>): Promise<void> {
  const dir = await mkdtemp(join(tmpdir(), "bun-script-tools-"));
  try {
    for (const name of ["displayplacer", "shitsurae", "tmux", "editprompt"]) {
      await writeFile(join(dir, name), mockTool, { mode: 0o700 });
    }
    await check(dir, join(dir, "calls.jsonl"));
  } finally {
    await rm(dir, { recursive: true });
  }
}

async function calls(log: string): Promise<Call[]> {
  return (await readFile(log, "utf8")).trim().split("\n").filter(Boolean).map((line) => JSON.parse(line));
}

test("Raycast scripts preserve argv and centered window coordinates", async () => {
  await withMockTools(async (dir, log) => {
    // Emulate Raycast's minimal PATH; the zsh entrypoint loads Bun and tools.
    await writeFile(
      join(dir, ".zshenv"),
      `export PATH=${
        JSON.stringify(`${dir}:${process.execPath.slice(0, process.execPath.lastIndexOf("/"))}:/usr/bin:/bin`)
      }\n`,
    );
    const env = { ...process.env, PATH: "/usr/bin:/bin", ZDOTDIR: dir, MOCK_LOG: log };
    for (const [script, args] of [["display-layout.ts", ["main"]], ["shitsurae-resize.ts", ["600", "400"]]] as const) {
      const child = Bun.spawn([join(root, "bin", script), ...args], { env, stdout: "pipe", stderr: "pipe" });
      expect(await child.exited).toBe(0);
      expect(await new Response(child.stderr).text()).toBe("");
    }
    const output = await calls(log);
    expect(output[0].args).toHaveLength(2);
    expect(output[0].args[0]).toContain("res:5120x2160");
    expect(output[2].args).toEqual(["window", "set", "-x", "200", "-y", "175", "-w", "600", "-h", "400"]);
  });
});

for (const result of ["layout-applied", "layout-changed"]) {
  test(`tmux editprompt preserves grouping and cleanup on ${result}`, async () => {
    await withMockTools(async (dir, log) => {
      const child = Bun.spawn([process.execPath, join(root, "bin/tmux-editprompt.ts"), "%1"], {
        env: {
          ...process.env,
          PATH: `${dir}:${process.env.PATH}`,
          MOCK_LOG: log,
          MOCK_LAYOUT_RESULT: result,
          PANEPILOT_API_KEY: "test-key",
        },
        stdout: "pipe",
        stderr: "pipe",
      });
      const code = await child.exited;
      const error = await new Response(child.stderr).text();
      const output = await calls(log);
      expect(output.find((call) => call.bin === "editprompt")?.key).toBeNull();
      const tmuxCalls = output.filter((call) => call.bin === "tmux").map((call) => call.args);
      if (result === "layout-applied") {
        expect(code).toBe(0);
        expect(error).toBe("");
        expect(tmuxCalls.some((args) => args[0] === "wait-for" && args[1] === "-S")).toBe(true);
        expect(tmuxCalls.some((args) => args[0] === "kill-pane")).toBe(false);
      } else {
        expect(code).toBe(1);
        expect(error).toContain("layout changed");
        expect(tmuxCalls).toContainEqual(["kill-pane", "-t", "%2"]);
        expect(tmuxCalls).toContainEqual(["resize-pane", "-t", "%1", "-y", "30"]);
        expect(tmuxCalls.some((args) => args[0] === "wait-for" && args[1] === "-S")).toBe(false);
      }
    });
  });
}
