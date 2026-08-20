import { assertEquals, assertStringIncludes } from "@std/assert";

const ANSI_PATTERN = new RegExp(`${String.fromCharCode(27)}\\[[0-9;]*m`, "g");

async function renderStatusLine(configDir: string): Promise<string[]> {
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
  };
  const statusLinePath = decodeURIComponent(new URL("../bin/cc-statusline", import.meta.url).pathname);
  const command = new Deno.Command(statusLinePath, {
    cwd: Deno.cwd(),
    env: { CLAUDE_CONFIG_DIR: configDir, HOME: configDir },
    stdin: "piped",
    stdout: "piped",
    stderr: "piped",
  });
  const child = command.spawn();
  const writer = child.stdin.getWriter();
  await writer.write(new TextEncoder().encode(JSON.stringify(payload)));
  await writer.close();

  const { code, stdout, stderr } = await child.output();
  assertEquals(code, 0, new TextDecoder().decode(stderr));

  return new TextDecoder().decode(stdout).trimEnd().replaceAll(ANSI_PATTERN, "").split("\n");
}

async function configureVdeMonitor(
  configDir: string,
  port: number,
  token = "test-token",
): Promise<void> {
  const runtimeDir = `${configDir}/.vde-monitor/server-runtimes`;
  await Deno.mkdir(runtimeDir, { recursive: true });
  await Deno.writeTextFile(
    `${configDir}/.vde-monitor/token.json`,
    JSON.stringify({ token }),
  );
  await Deno.writeTextFile(
    `${runtimeDir}/server-runtime.1234.aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.json`,
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

Deno.test("cc-statusline displays all three vde-monitor limits", async () => {
  const configDir = Deno.makeTempDirSync();
  const resetAt = new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString();
  let resolvePort: (port: number) => void;
  const portPromise = new Promise<number>((resolve) => {
    resolvePort = resolve;
  });
  const server = Deno.serve(
    {
      hostname: "127.0.0.1",
      port: 0,
      onListen: ({ port }) => resolvePort(port),
    },
    (request) => {
      if (request.headers.get("Authorization") !== "Bearer test-token") {
        return new Response(null, { status: 401 });
      }
      return Response.json(createVdeMonitorUsageResponse(resetAt));
    },
  );
  await configureVdeMonitor(configDir, await portPromise);

  try {
    const lines = await renderStatusLine(configDir);

    assertEquals(lines.length, 4);
    assertStringIncludes(lines[1], "5h");
    assertStringIncludes(lines[1], "● 90%");
    assertStringIncludes(lines[2], "7d");
    assertStringIncludes(lines[2], "● 80%");
    assertStringIncludes(lines[3], "Fable");
    assertStringIncludes(lines[3], "● 26%");
  } finally {
    await server.shutdown();
  }
});

Deno.test("cc-statusline reads the current vde-monitor token on every render", async () => {
  const configDir = Deno.makeTempDirSync();
  const resetAt = new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString();
  let expectedToken = "first-token";
  let resolvePort: (port: number) => void;
  const portPromise = new Promise<number>((resolve) => {
    resolvePort = resolve;
  });
  const server = Deno.serve(
    {
      hostname: "127.0.0.1",
      port: 0,
      onListen: ({ port }) => resolvePort(port),
    },
    (request) => {
      if (request.headers.get("Authorization") !== `Bearer ${expectedToken}`) {
        return new Response(null, { status: 401 });
      }
      return Response.json(createVdeMonitorUsageResponse(resetAt));
    },
  );
  const port = await portPromise;
  await configureVdeMonitor(configDir, port, expectedToken);

  try {
    assertEquals((await renderStatusLine(configDir)).length, 4);

    expectedToken = "rotated-token";
    await configureVdeMonitor(configDir, port, expectedToken);

    assertEquals((await renderStatusLine(configDir)).length, 4);
  } finally {
    await server.shutdown();
  }
});

Deno.test("cc-statusline does not fall back to the Claude cache without the vde-monitor API", async () => {
  const configDir = Deno.makeTempDirSync();
  const resetAt = new Date(Date.now() + 5 * 60 * 60 * 1000).toISOString();
  await Deno.writeTextFile(
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

  const lines = await renderStatusLine(configDir);

  assertEquals(lines.length, 3);
  assertStringIncludes(lines[1], "5h");
  assertStringIncludes(lines[1], "● 75%");
  assertStringIncludes(lines[2], "7d");
  assertStringIncludes(lines[2], "● 50%");
});

Deno.test("cc-statusline omits the Fable bar when vde-monitor is unavailable", async () => {
  const configDir = Deno.makeTempDirSync();
  await Deno.writeTextFile(`${configDir}/.claude.json`, "{}");

  const lines = await renderStatusLine(configDir);

  assertEquals(lines.length, 3);
  assertStringIncludes(lines[1], "5h");
  assertStringIncludes(lines[2], "7d");
});
