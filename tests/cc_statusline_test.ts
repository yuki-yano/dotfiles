import { assertEquals, assertStringIncludes } from "@std/assert";

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
  await Deno.mkdir(runtimeDir, { recursive: true });
  await Deno.writeTextFile(
    `${configDir}/.vde-monitor/token.json`,
    JSON.stringify({ token }),
  );
  await Deno.writeTextFile(
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
    assertStringIncludes(lines[2], "1w");
    assertStringIncludes(lines[2], "● 80%");
    assertStringIncludes(lines[3], "Fable");
    assertStringIncludes(lines[3], "● 26%");
  } finally {
    await server.shutdown();
    await Deno.remove(configDir, { recursive: true });
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
    assertStringIncludes((await renderStatusLine(configDir))[3], "● 26%");

    expectedToken = "rotated-token";
    await configureVdeMonitor(configDir, port, expectedToken);

    assertStringIncludes((await renderStatusLine(configDir))[3], "● 26%");
  } finally {
    await server.shutdown();
    await Deno.remove(configDir, { recursive: true });
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

  try {
    const lines = await renderStatusLine(configDir);
    assertStringIncludes(lines[1], "● 75%");
    assertStringIncludes(lines[2], "● 50%");
    assertStringIncludes(lines[3], "● --% | unavailable");
  } finally {
    await Deno.remove(configDir, { recursive: true });
  }
});

Deno.test("cc-statusline keeps all rows without vde-monitor or native limits", async () => {
  const configDir = Deno.makeTempDirSync();
  try {
    const lines = await renderStatusLine(configDir, { rate_limits: undefined });
    for (const line of lines.slice(1)) {
      assertStringIncludes(line, "● --% | unavailable");
    }
  } finally {
    await Deno.remove(configDir, { recursive: true });
  }
});

async function withVdeMonitor(
  handler: (request: Request) => Response | Promise<Response>,
  check: (configDir: string) => Promise<void>,
): Promise<void> {
  const configDir = await Deno.makeTempDir();
  const server = Deno.serve({ hostname: "127.0.0.1", port: 0, onListen: () => {} }, handler);
  try {
    await configureVdeMonitor(configDir, server.addr.port);
    await check(configDir);
  } finally {
    await server.shutdown();
    await Deno.remove(configDir, { recursive: true });
  }
}

Deno.test("cc-statusline displays degraded data as stale without pace scores", async () => {
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

Deno.test("cc-statusline preserves independent windows and unknown reset times", async () => {
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

Deno.test("cc-statusline keeps the Fable row when the model window is absent", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  response.provider.windows.pop();
  await withVdeMonitor(() => Response.json(response), async (configDir) => {
    const lines = await renderStatusLine(configDir);
    assertStringIncludes(lines[1], "● 90%");
    assertStringIncludes(lines[2], "● 80%");
    assertStringIncludes(lines[3], "● --% | unavailable");
  });
});

Deno.test("cc-statusline does not present expired usage as a current budget", async () => {
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
  Deno.test(`cc-statusline keeps all rows on ${name}`, async () => {
    await withVdeMonitor(respond, async (configDir) => {
      const lines = await renderStatusLine(configDir, { rate_limits: {} });
      for (const line of lines.slice(1)) {
        assertStringIncludes(line, "● --% | unavailable");
      }
    });
  });
}

Deno.test("cc-statusline selects current windows across multiple monitors", async () => {
  const response = createVdeMonitorUsageResponse(new Date(Date.now() + 86400000).toISOString());
  const stale = structuredClone(response);
  stale.provider.status = "degraded";
  stale.provider.windows[0].utilizationPercent = 99;
  const current = structuredClone(response);
  current.provider.windows = current.provider.windows.slice(0, 2);
  await withVdeMonitor(() => Response.json(stale), async (configDir) => {
    const second = Deno.serve({ hostname: "127.0.0.1", port: 0, onListen: () => {} }, () => Response.json(current));
    try {
      await configureVdeMonitor(configDir, second.addr.port);
      const lines = await renderStatusLine(configDir, { rate_limits: undefined });
      assertStringIncludes(lines[1], "● 90%");
      assertEquals(lines[1].includes("stale"), false);
      assertStringIncludes(lines[2], "● 80%");
      assertStringIncludes(lines[3], "● 26%");
      assertStringIncludes(lines[3], " | stale");
    } finally {
      await second.shutdown();
    }
  });
});
