import { assertEquals, assertRejects, assertStringIncludes } from "@std/assert";
import { dirname, join } from "@std/path";
import {
  applyCodexTemplate,
  CodexTemplateApplyError,
  END_MARKER,
  formatCodexTemplateApplyError,
  START_MARKER,
} from "../bin/codex-template-apply.ts";

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
    "notify = [",
    '  "~/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient",',
    '  "turn-ended",',
    '  "--previous-notify",',
    '  "[\\"vde-notifier\\",\\"--codex\\",\\"--skip-codex-subagent\\",\\"--skip-codex-non-interactive\\"]"',
    "]",
    '[projects."~/dotfiles"]',
    'url = "https://example.com/~/docs"',
    'other_user = "~someone/config"',
    'relative = "nested/~/config"',
    'absolute = "/tmp/config"',
    "",
  ].join("\n");
  const existingConfig = `personal = "~/keep"\n${START_MARKER}\n# managed by dotfiles\n${END_MARKER}\n`;
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
        "notify = [",
        `  "${home}/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient",`,
        '  "turn-ended",',
        '  "--previous-notify",',
        '  "[\\"vde-notifier\\",\\"--codex\\",\\"--skip-codex-subagent\\",\\"--skip-codex-non-interactive\\"]"',
        "]",
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

async function createManagedSettingsFixture(templateBody: string, managedBody: string) {
  const root = await Deno.makeTempDir();
  const templateDir = join(root, "template");
  const outputDir = join(root, "output");
  const configPath = join(outputDir, "config.toml");
  const existingConfig = [
    'personal = "~/keep"',
    START_MARKER,
    managedBody,
    END_MARKER,
    '[plugins."outside-managed"]',
    "enabled = true",
    "",
  ].join("\n");
  const copyFiles = ["AGENTS.md", "agents/explorer.toml", "hooks.json"];
  await Deno.mkdir(join(templateDir, "agents"), { recursive: true });
  await Deno.mkdir(join(outputDir, "agents"), { recursive: true });
  await Deno.writeTextFile(join(templateDir, "config.toml"), templateBody);
  await Deno.writeTextFile(configPath, existingConfig);
  for (const path of copyFiles) {
    await Deno.writeTextFile(join(templateDir, path), "new contents\n");
    await Deno.writeTextFile(join(outputDir, path), "existing contents\n");
  }
  return {
    root,
    configPath,
    existingConfig,
    copyFiles,
    options: { templateDir, outputDir, copyTargets: ["AGENTS.md", "agents", "hooks.json"] },
  };
}

async function assertManagedSettingsFixtureUnchanged(
  fixture: Awaited<ReturnType<typeof createManagedSettingsFixture>>,
) {
  assertEquals(await Deno.readTextFile(fixture.configPath), fixture.existingConfig);
  for (const path of fixture.copyFiles) {
    assertEquals(await Deno.readTextFile(join(fixture.options.outputDir, path)), "existing contents\n");
  }
}

const managedSettingsTemplate = 'notify = ["vde-notifier"]\n[tui]\nfullscreen_transcript = false';
const managedSettingsWithAppAdditions = [
  'notify = ["app-turn-ended", "vde-notifier"]',
  "[tui]",
  "fullscreen_transcript = false",
  "screen_reader_detection_done = true",
  '[plugins."browser@openai-bundled"]',
  "enabled = true",
].join("\n");

Deno.test("codex template stops before all writes and displays target-only settings and the complete diff", async () => {
  const fixture = await createManagedSettingsFixture(managedSettingsTemplate, managedSettingsWithAppAdditions);
  try {
    for (const dryRun of [true, false]) {
      const error = await assertRejects(
        () => applyCodexTemplate({ ...fixture.options, dryRun }),
        CodexTemplateApplyError,
        "would remove or change existing managed settings",
      );
      const message = formatCodexTemplateApplyError(error);
      assertStringIncludes(message, "No files were written.");
      assertStringIncludes(message, "tui.screen_reader_detection_done");
      assertStringIncludes(message, 'plugins."browser@openai-bundled".enabled');
      assertStringIncludes(message, "--overwrite-managed");
      assertEquals(
        error.managedDiff,
        [
          `--- ${fixture.configPath} (managed section)`,
          `+++ ${join(fixture.options.templateDir, "config.toml")} (rendered)`,
          "@@ -1,6 +1,3 @@",
          '-notify = ["app-turn-ended", "vde-notifier"]',
          '+notify = ["vde-notifier"]',
          " [tui]",
          " fullscreen_transcript = false",
          "-screen_reader_detection_done = true",
          '-[plugins."browser@openai-bundled"]',
          "-enabled = true",
        ].join("\n"),
      );
      await assertManagedSettingsFixtureUnchanged(fixture);
    }
  } finally {
    await Deno.remove(fixture.root, { recursive: true });
  }
});

Deno.test("codex template requires an explicit overwrite flag and keeps unmanaged settings", async () => {
  const fixture = await createManagedSettingsFixture(managedSettingsTemplate, managedSettingsWithAppAdditions);
  const options = { ...fixture.options, overwriteManaged: true };
  try {
    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
    await assertManagedSettingsFixtureUnchanged(fixture);
    assertEquals(await applyCodexTemplate(options), true);
    assertEquals(
      await Deno.readTextFile(fixture.configPath),
      fixture.existingConfig.replace(managedSettingsWithAppAdditions, managedSettingsTemplate),
    );
    for (const path of fixture.copyFiles) {
      assertEquals(await Deno.readTextFile(join(fixture.options.outputDir, path)), "new contents\n");
    }
    assertEquals(await applyCodexTemplate(fixture.options), false);
  } finally {
    await Deno.remove(fixture.root, { recursive: true });
  }
});

Deno.test("codex template stops for known-key value changes until an overwrite is requested", async () => {
  const template = [
    'model = "new-model"',
    'notify = ["new-notifier"]',
    "new_setting = true",
    "[tui]",
    'theme = "new-theme"',
    "[features]",
    "hooks = true",
  ].join("\n");
  const existing = [
    "# Existing comments and multiline values do not introduce settings.",
    "tui.theme = 'old-theme'",
    "features = { hooks = false }",
    'model = "old-model"',
    "notify = [",
    '  "old-notifier",',
    "]",
    "",
  ].join("\n");
  const fixture = await createManagedSettingsFixture(template, existing);
  try {
    for (const dryRun of [true, false]) {
      const error = await assertRejects(
        () => applyCodexTemplate({ ...fixture.options, dryRun }),
        CodexTemplateApplyError,
        "would remove or change existing managed settings",
      );
      assertEquals(error.details.slice(1, 5), ["  features.hooks", "  model", "  notify", "  tui.theme"]);
      await assertManagedSettingsFixtureUnchanged(fixture);
    }
    assertEquals(await applyCodexTemplate({ ...fixture.options, overwriteManaged: true }), true);
    assertEquals(
      await Deno.readTextFile(fixture.configPath),
      fixture.existingConfig.replace(existing, template),
    );
  } finally {
    await Deno.remove(fixture.root, { recursive: true });
  }
});

Deno.test("codex template allows new settings and equivalent TOML values despite formatting changes", async () => {
  const template = [
    'model = "same-model"',
    'notify = ["same-notifier"]',
    "new_setting = true",
    "[tui]",
    'theme = "same-theme"',
    "[features]",
    "hooks = true",
  ].join("\n");
  const existing = [
    "# Existing comments and multiline values do not change settings.",
    "tui.theme = 'same-theme'",
    "features = { hooks = true }",
    'model = "same-model"',
    "notify = [",
    '  "same-notifier",',
    "]",
    "",
  ].join("\n");
  const fixture = await createManagedSettingsFixture(template, existing);
  try {
    assertEquals(await applyCodexTemplate(fixture.options), true);
    assertEquals(
      await Deno.readTextFile(fixture.configPath),
      fixture.existingConfig.replace(existing, template),
    );
  } finally {
    await Deno.remove(fixture.root, { recursive: true });
  }
});

Deno.test("codex template checks quoted keys, inline tables and empty target-only tables", async () => {
  const existing = [
    'model = "same-model"',
    'app = { "setting.with.dots" = true }',
    "[empty_app_table]",
  ].join("\n");
  const fixture = await createManagedSettingsFixture('model = "same-model"', existing);
  try {
    const error = await assertRejects(() => applyCodexTemplate(fixture.options), CodexTemplateApplyError);
    const message = formatCodexTemplateApplyError(error);
    assertStringIncludes(message, 'app."setting.with.dots"');
    assertStringIncludes(message, "empty_app_table");
    await assertManagedSettingsFixtureUnchanged(fixture);
  } finally {
    await Deno.remove(fixture.root, { recursive: true });
  }
});

for (const invalidSource of ["template", "target"]) {
  Deno.test(`codex template stops before all writes for invalid ${invalidSource} TOML even with an overwrite flag`, async () => {
    const invalidToml = 'model = "unterminated';
    const validToml = 'model = "valid-model"';
    const fixture = await createManagedSettingsFixture(
      invalidSource === "template" ? invalidToml : validToml,
      invalidSource === "target" ? invalidToml : validToml,
    );
    try {
      for (const dryRun of [true, false]) {
        await assertRejects(
          () => applyCodexTemplate({ ...fixture.options, dryRun, overwriteManaged: true }),
          CodexTemplateApplyError,
          "Could not compare the managed Codex settings",
        );
        await assertManagedSettingsFixtureUnchanged(fixture);
      }
    } finally {
      await Deno.remove(fixture.root, { recursive: true });
    }
  });
}

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
  const existingConfig = [
    'personal = "~/keep"',
    START_MARKER,
    "# managed by dotfiles",
    END_MARKER,
    "",
  ].join("\n");
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
      await assertRejects(
        () => applyCodexTemplate(options),
        CodexTemplateApplyError,
        "would remove or change existing managed settings",
      );
      assertEquals(await Deno.readTextFile(configPath), expectedConfig(version));
      assertEquals(await applyCodexTemplate({ ...options, overwriteManaged: true }), true);
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
