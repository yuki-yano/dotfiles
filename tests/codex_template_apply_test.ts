import { assertEquals, assertRejects } from "@std/assert";
import { dirname, join } from "@std/path";
import { applyCodexTemplate, CodexTemplateApplyError, END_MARKER, START_MARKER } from "../bin/codex-template-apply.ts";

Deno.test("codex template expands home paths while preserving sources and unmanaged config", async () => {
  const root = await Deno.makeTempDir();
  const home = Deno.env.get("HOME")!;
  const templateDir = join(root, "template");
  const outputDir = join(root, "output");
  const configTemplate = [
    "# @nvim.on_save deno task codex:template -- --apply",
    'config_file = "~/.codex/agents/explorer.toml"',
    "source = '~/.cache/plugins'",
    'home = "~"',
    '[projects."~/dotfiles"]',
    'url = "https://example.com/~/docs"',
    'other_user = "~someone/config"',
    'relative = "nested/~/config"',
    'absolute = "/tmp/config"',
    "",
  ].join("\n");
  const existingConfig = `personal = "~/keep"\n${START_MARKER}\nold = true\n${END_MARKER}\n`;
  const copyFiles = [
    {
      path: "AGENTS.md",
      source: "# @nvim.on_save ignored\nRead `~/notes` and ~/.codex/config.toml.\n",
      expected: `Read \`${home}/notes\` and ${home}/.codex/config.toml.\n`,
    },
    {
      path: "agents/explorer.toml",
      source: 'config_file = "~/.codex/shared.toml"\n',
      expected: `config_file = "${home}/.codex/shared.toml"\n`,
    },
    {
      path: "hooks.json",
      source: '{ "cwd": "~/dotfiles", "command": "echo $HOME" }\n',
      expected: `{ "cwd": "${home}/dotfiles", "command": "echo $HOME" }\n`,
    },
  ];

  try {
    await Deno.mkdir(join(templateDir, "agents"), { recursive: true });
    await Deno.mkdir(join(outputDir, "agents"), { recursive: true });
    await Deno.writeTextFile(join(templateDir, "config.toml"), configTemplate);
    await Deno.writeTextFile(join(outputDir, "config.toml"), existingConfig);
    for (const file of copyFiles) {
      await Deno.writeTextFile(join(templateDir, file.path), file.source);
      await Deno.writeTextFile(join(outputDir, file.path), "existing\n");
    }

    const options = { templateDir, outputDir, copyTargets: ["AGENTS.md", "agents", "hooks.json"] };

    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
    assertEquals(await Deno.readTextFile(join(outputDir, "config.toml")), existingConfig);
    for (const file of copyFiles) {
      assertEquals(await Deno.readTextFile(join(outputDir, file.path)), "existing\n");
    }

    assertEquals(await applyCodexTemplate(options), true);
    assertEquals(
      await Deno.readTextFile(join(outputDir, "config.toml")),
      [
        'personal = "~/keep"',
        START_MARKER,
        `config_file = "${home}/.codex/agents/explorer.toml"`,
        `source = '${home}/.cache/plugins'`,
        `home = "${home}"`,
        `[projects."${home}/dotfiles"]`,
        'url = "https://example.com/~/docs"',
        'other_user = "~someone/config"',
        'relative = "nested/~/config"',
        'absolute = "/tmp/config"',
        END_MARKER,
        "",
      ].join("\n"),
    );
    assertEquals(await Deno.readTextFile(join(templateDir, "config.toml")), configTemplate);
    for (const file of copyFiles) {
      assertEquals(await Deno.readTextFile(join(outputDir, file.path)), file.expected);
      assertEquals(await Deno.readTextFile(join(templateDir, file.path)), file.source);
    }
    assertEquals(await applyCodexTemplate(options), false);
    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), false);
  } finally {
    await Deno.remove(root, { recursive: true });
  }
});

function appInfoPlist(version: string): string {
  return `<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleShortVersionString</key><string>${version}</string>
<key>CFBundleVersion</key><string>9647</string>
</dict></plist>`;
}

async function createChatgptTemplateFixture() {
  const root = await Deno.makeTempDir();
  const templateDir = join(root, "template");
  const outputDir = join(root, "output");
  const chatgptAppPath = join(root, "ChatGPT.app");
  const infoPath = join(chatgptAppPath, "Contents", "Info.plist");
  const servicePath = (version: string) => join(root, "browser cache", version, "scripts", "browser-service.mjs");
  const version = "26.911.61220";
  const configTemplate = [
    "[mcp_servers.node_repl.env]",
    'BROWSER_USE_CODEX_APP_VERSION = "{{CHATGPT_APP_VERSION}}"',
    `NODE_REPL_TRUSTED_SERVICES = '{"browser":"${servicePath("{{CHATGPT_APP_VERSION}}")}","sky":"@oai/sky/service"}'`,
    'unchanged_version = "26.911.61220"',
    "",
  ].join("\n");
  const existingConfig = `personal = "~/keep"\n${START_MARKER}\nold = true\n${END_MARKER}\n`;
  await Deno.mkdir(templateDir);
  await Deno.mkdir(outputDir);
  await Deno.mkdir(dirname(infoPath), { recursive: true });
  await Deno.mkdir(dirname(servicePath(version)), { recursive: true });
  await Deno.writeTextFile(infoPath, appInfoPlist(version));
  await Deno.writeTextFile(servicePath(version), "export {};\n");
  await Deno.writeTextFile(join(templateDir, "config.toml"), configTemplate);
  await Deno.writeTextFile(join(templateDir, "AGENTS.md"), "new instructions\n");
  await Deno.writeTextFile(join(outputDir, "config.toml"), existingConfig);
  await Deno.writeTextFile(join(outputDir, "AGENTS.md"), "existing instructions\n");
  return {
    root,
    infoPath,
    servicePath,
    version,
    configTemplate,
    existingConfig,
    options: { templateDir, outputDir, chatgptAppPath },
  };
}

Deno.test({
  name: "codex template reads the app release version on each apply and validates the referenced browser service",
  ignore: Deno.build.os !== "darwin",
  async fn() {
    const fixture = await createChatgptTemplateFixture();
    const { options, version, configTemplate, existingConfig } = fixture;
    const configPath = join(options.outputDir, "config.toml");
    try {
      assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
      assertEquals(await Deno.readTextFile(configPath), existingConfig);
      assertEquals(await Deno.readTextFile(join(options.outputDir, "AGENTS.md")), "existing instructions\n");

      assertEquals(await applyCodexTemplate(options), true);
      const expectedConfig = (appVersion: string) =>
        [
          'personal = "~/keep"',
          START_MARKER,
          configTemplate.replaceAll("{{CHATGPT_APP_VERSION}}", appVersion).trimEnd(),
          END_MARKER,
          "",
        ].join("\n");
      assertEquals(await Deno.readTextFile(configPath), expectedConfig(version));
      assertEquals(await Deno.readTextFile(join(options.outputDir, "AGENTS.md")), "new instructions\n");
      assertEquals(await Deno.readTextFile(join(options.templateDir, "config.toml")), configTemplate);
      assertEquals(await applyCodexTemplate(options), false);

      const updatedVersion = "26.918.70000";
      await Deno.writeTextFile(fixture.infoPath, appInfoPlist(updatedVersion));
      await assertRejects(
        () => applyCodexTemplate(options),
        CodexTemplateApplyError,
        "browser service for the ChatGPT app version is unavailable",
      );
      assertEquals(await Deno.readTextFile(configPath), expectedConfig(version));

      await Deno.mkdir(dirname(fixture.servicePath(updatedVersion)), { recursive: true });
      await Deno.writeTextFile(fixture.servicePath(updatedVersion), "export {};\n");
      assertEquals(await applyCodexTemplate(options), true);
      assertEquals(await Deno.readTextFile(configPath), expectedConfig(updatedVersion));
      assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), false);
      assertEquals(await Deno.readTextFile(join(options.templateDir, "config.toml")), configTemplate);
    } finally {
      await Deno.remove(fixture.root, { recursive: true });
    }
  },
});

const chatgptFailureCases = [
  {
    name: "missing app Info.plist",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) => Deno.remove(fixture.infoPath),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "malformed app Info.plist",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      Deno.writeTextFile(fixture.infoPath, "not a plist"),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "missing app release version",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      Deno.writeTextFile(fixture.infoPath, '<plist version="1.0"><dict></dict></plist>'),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "invalid app release version",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      Deno.writeTextFile(fixture.infoPath, appInfoPlist("26.invalid.123")),
    message: "The ChatGPT app version is invalid",
  },
  {
    name: "missing browser service",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      Deno.remove(fixture.servicePath(fixture.version)),
    message: "browser service for the ChatGPT app version is unavailable",
  },
  {
    name: "browser service is a directory",
    async prepare(fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) {
      await Deno.remove(fixture.servicePath(fixture.version));
      await Deno.mkdir(fixture.servicePath(fixture.version));
    },
    message: "browser service for the ChatGPT app version is unavailable",
  },
  {
    name: "invalid trusted services JSON",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      Deno.writeTextFile(
        join(fixture.options.templateDir, "config.toml"),
        fixture.configTemplate.replace('{"browser":', "{browser:"),
      ),
    message: "The browser service configuration is invalid",
  },
];

for (const failureCase of chatgptFailureCases) {
  Deno.test({
    name: `codex template leaves all output files unchanged for ${failureCase.name}`,
    ignore: Deno.build.os !== "darwin",
    async fn() {
      const fixture = await createChatgptTemplateFixture();
      try {
        await failureCase.prepare(fixture);
        const templatePath = join(fixture.options.templateDir, "config.toml");
        const configTemplate = await Deno.readTextFile(templatePath);
        for (const dryRun of [true, false]) {
          await assertRejects(
            () => applyCodexTemplate({ ...fixture.options, dryRun }),
            CodexTemplateApplyError,
            failureCase.message,
          );
          assertEquals(
            await Deno.readTextFile(join(fixture.options.outputDir, "config.toml")),
            fixture.existingConfig,
          );
          assertEquals(
            await Deno.readTextFile(join(fixture.options.outputDir, "AGENTS.md")),
            "existing instructions\n",
          );
          assertEquals(await Deno.readTextFile(templatePath), configTemplate);
        }
      } finally {
        await Deno.remove(fixture.root, { recursive: true });
      }
    },
  });
}
