import { test } from "bun:test";
import { mkdtempSync } from "node:fs";
import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { assertEquals, assertStringIncludes } from "./assertions.ts";

const ANSI_PATTERN = new RegExp(`${String.fromCharCode(27)}\\[[0-9;]*m`, "g");

async function renderStatusLine(configDir: string, overrides: Record<string, unknown> = {}): Promise<string[]> {
  const now = Date.now();
  const payload = {
    model: { display_name: "Fable 5" },
    workspace: { current_dir: configDir },
    rate_limits: {
      five_hour: {
        used_percentage: 25,
        resets_at: (now + 4 * 60 * 60 * 1000) / 1000,
      },
      seven_day: {
        used_percentage: 50,
        resets_at: (now + 4 * 24 * 60 * 60 * 1000) / 1000,
      },
    },
    ...overrides,
  };
  const statusLinePath = decodeURIComponent(new URL("../bin/cc-statusline.ts", import.meta.url).pathname);
  const child = Bun.spawn([statusLinePath], {
    cwd: process.cwd(),
    env: { ...process.env, CLAUDE_CONFIG_DIR: configDir, HOME: configDir, TMPDIR: configDir },
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
  });
  child.stdin.write(JSON.stringify(payload));
  child.stdin.end();
  const [code, output, errorOutput] = await Promise.all([
    child.exited,
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
  ]);
  const stdout = new TextEncoder().encode(output);
  const stderr = new TextEncoder().encode(errorOutput);

  assertEquals(code, 0, new TextDecoder().decode(stderr));
  assertEquals(new TextDecoder().decode(stderr), "");

  const lines = new TextDecoder().decode(stdout).trimEnd().replaceAll(ANSI_PATTERN, "").split("\n");
  assertEquals(lines.length, 4);
  assertStringIncludes(lines[1], "├ 5h");
  assertStringIncludes(lines[2], "├ 1w");
  assertStringIncludes(lines[3], "└ Fable");
  return lines;
}

async function configureVdeMonitor(
  configDir: string,
  port: number,
  token = "test-token",
): Promise<void> {
  const runtimeDir = `${configDir}/.vde-monitor/server-runtimes`;
  await mkdir(runtimeDir, { recursive: true });
  await writeFile(
    `${configDir}/.vde-monitor/token.json`,
    JSON.stringify({ token }),
  );
  await writeFile(
    `${runtimeDir}/server-runtime.${port}.aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.json`,
    JSON.stringify({
      version: 1,
      endpoint: { host: "127.0.0.1", port },
    }),
  );
}

function createVdeMonitorUsageResponse(resetAt: string) {
  return {
    provider: {
      status: "ok",
      windows: [
        {
          id: "session",
          title: "Session",
          utilizationPercent: 10,
          resetsAt: resetAt,
        },
        {
          id: "weekly",
          title: "Weekly",
          utilizationPercent: 20,
          resetsAt: resetAt,
        },
        {
          id: "model",
          title: "Fable Weekly",
          utilizationPercent: 74,
          resetsAt: resetAt,
        },
      ],
    },
  };
}

test("cc-statusline displays all three vde-monitor limits", async () => {
  const configDir = mkdtempSync(join(tmpdir(), "cc-statusline-test-"));
  const resetAt = new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString();
  const server = Bun.serve({
    hostname: "127.0.0.1",
    port: 0,
    fetch(request) {
      if (request.headers.get("Authorization") !== "Bearer test-token") {
        return new Response(null, { status: 401 });
      }
      return Response.json(createVdeMonitorUsageResponse(resetAt));
    },
  });
  await configureVdeMonitor(configDir, server.port!);

  try {
    const lines = await renderStatusLine(configDir);

    assertEquals(lines.length, 4);
    assertStringIncludes(lines[1], "5h");
    assertStringIncludes(lines[1], "● 90%");
    assertStringIncludes(lines[2], "1w");
    assertStringIncludes(lines[2], "● 80%");
    assertStringIncludes(lines[3], "Fable");
    assertStringIncludes(lines[3], "● 26%");
  } finally {
    server.stop(true);
    await rm(configDir, { recursive: true });
  }
});

test("cc-statusline reads the current vde-monitor token on every render", async () => {
  const configDir = mkdtempSync(join(tmpdir(), "cc-statusline-test-"));
  const resetAt = new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString();
  let expectedToken = "first-token";
  const server = Bun.serve({
    hostname: "127.0.0.1",
    port: 0,
    fetch(request) {
      if (request.headers.get("Authorization") !== `Bearer ${expectedToken}`) {
        return new Response(null, { status: 401 });
      }
      return Response.json(createVdeMonitorUsageResponse(resetAt));
    },
  });
  const port = server.port!;
  await configureVdeMonitor(configDir, port, expectedToken);

  try {
    assertStringIncludes((await renderStatusLine(configDir))[3], "● 26%");

    expectedToken = "rotated-token";
    await configureVdeMonitor(configDir, port, expectedToken);

    assertStringIncludes((await renderStatusLine(configDir))[3], "● 26%");
  } finally {
    server.stop(true);
    await rm(configDir, { recursive: true });
  }
});

test("cc-statusline does not fall back to the Claude cache without the vde-monitor API", async () => {
  const configDir = mkdtempSync(join(tmpdir(), "cc-statusline-test-"));
  const resetAt = new Date(Date.now() + 5 * 60 * 60 * 1000).toISOString();
  await writeFile(
    `${configDir}/.claude.json`,
    JSON.stringify({
      cachedUsageUtilization: {
        fetchedAtMs: Date.now(),
        utilization: {
          limits: [
            {
              kind: "weekly_scoped",
              percent: 74,
              resets_at: resetAt,
              scope: { model: { display_name: "Fable" } },
            },
          ],
        },
      },
    }),
  );

  try {
    const lines = await renderStatusLine(configDir);
    assertStringIncludes(lines[1], "● 75%");
    assertStringIncludes(lines[2], "● 50%");
    assertStringIncludes(lines[3], "● --% | unavailable");
  } finally {
    await rm(configDir, { recursive: true });
  }
});

test("cc-statusline keeps all rows without vde-monitor or native limits", async () => {
  const configDir = mkdtempSync(join(tmpdir(), "cc-statusline-test-"));
  try {
    const lines = await renderStatusLine(configDir, { rate_limits: undefined });
    for (const line of lines.slice(1)) {
      assertStringIncludes(line, "● --% | unavailable");
    }
  } finally {
    await rm(configDir, { recursive: true });
  }
});

async function withVdeMonitor(
  handler: (request: Request) => Response | Promise<Response>,
  check: (configDir: string) => Promise<void>,
): Promise<void> {
  const configDir = await mkdtemp(join(tmpdir(), "cc-statusline-test-"));
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, fetch: handler });
  try {
    await configureVdeMonitor(configDir, server.port!);
    await check(configDir);
  } finally {
    server.stop(true);
    await rm(configDir, { recursive: true });
  }
}

test("cc-statusline displays degraded data as stale without pace scores", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  response.provider.status = "degraded";
  await withVdeMonitor(() => Response.json(response), async (configDir) => {
    const lines = await renderStatusLine(configDir, { rate_limits: undefined });
    for (const [index, percentage] of ["90", "80", "26"].entries()) {
      assertStringIncludes(lines[index + 1], `● ${percentage}%`);
      assertStringIncludes(lines[index + 1], " | stale");
      assertEquals(lines[index + 1].includes("pt"), false);
      assertEquals(lines[index + 1].includes("⌛"), false);
    }
  });
});

test("cc-statusline preserves independent windows and unknown reset times", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  const [session, weekly, fable] = response.provider.windows;
  const body = {
    provider: {
      status: "ok",
      windows: [null, { ...session, resetsAt: null }, { ...weekly, utilizationPercent: null }, fable],
    },
  };
  await withVdeMonitor(() => Response.json(body), async (configDir) => {
    const lines = await renderStatusLine(configDir, { rate_limits: undefined });
    assertStringIncludes(lines[1], "● 90% | reset unknown");
    assertStringIncludes(lines[2], "● --% | unavailable");
    assertStringIncludes(lines[3], "● 26%");

    const withNative = await renderStatusLine(configDir);
    assertStringIncludes(withNative[1], "● 90% | reset unknown");
    assertStringIncludes(withNative[2], "● 50%");
    assertStringIncludes(withNative[3], "● 26%");
  });
});

test("cc-statusline keeps the Fable row when the model window is absent", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  response.provider.windows.pop();
  await withVdeMonitor(() => Response.json(response), async (configDir) => {
    const lines = await renderStatusLine(configDir);
    assertStringIncludes(lines[1], "● 90%");
    assertStringIncludes(lines[2], "● 80%");
    assertStringIncludes(lines[3], "● --% | unavailable");
  });
});

test("cc-statusline does not present expired usage as a current budget", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() - 1000).toISOString());
  await withVdeMonitor(() => Response.json(response), async (configDir) => {
    const lines = await renderStatusLine(configDir);
    for (const line of lines.slice(1)) {
      assertStringIncludes(line, "● --% | reset pending");
      assertEquals(line.includes("pt"), false);
    }
  });
});

for (
  const [name, respond] of [
    ["HTTP failure", () => new Response(null, { status: 503 })],
    ["invalid JSON", () => new Response("{")],
    ["invalid windows", () => Response.json({ provider: { status: "ok", windows: {} } })],
    ["provider error", () => Response.json({ provider: { status: "error", windows: [] } })],
    ["timeout", async () => {
      await new Promise((resolve) => setTimeout(resolve, 1200));
      return Response.json(createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString()));
    }],
  ] as const
) {
  test(`cc-statusline keeps all rows on ${name}`, async () => {
    await withVdeMonitor(respond, async (configDir) => {
      const lines = await renderStatusLine(configDir, { rate_limits: {} });
      for (const line of lines.slice(1)) {
        assertStringIncludes(line, "● --% | unavailable");
      }
    });
  });
}

test("cc-statusline selects current windows across multiple monitors", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  const stale = structuredClone(response);
  stale.provider.status = "degraded";
  stale.provider.windows[0].utilizationPercent = 99;
  const current = structuredClone(response);
  current.provider.windows = current.provider.windows.slice(0, 2);
  await withVdeMonitor(() => Response.json(stale), async (configDir) => {
    const second = Bun.serve({ hostname: "127.0.0.1", port: 0, fetch: () => Response.json(current) });
    try {
      await configureVdeMonitor(configDir, second.port!);
      const lines = await renderStatusLine(configDir, { rate_limits: undefined });
      assertStringIncludes(lines[1], "● 90%");
      assertEquals(lines[1].includes("stale"), false);
      assertStringIncludes(lines[2], "● 80%");
      assertStringIncludes(lines[3], "● 26%");
      assertStringIncludes(lines[3], " | stale");
    } finally {
      second.stop(true);
    }
  });
});
