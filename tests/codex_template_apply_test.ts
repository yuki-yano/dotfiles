import { test } from "bun:test";
import { mkdir, mkdtemp, readFile, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { assertEquals, assertRejects, assertStringIncludes } from "./assertions.ts";
import { dirname, join } from "node:path";
import {
  applyCodexTemplate,
  CodexTemplateApplyError,
  END_MARKER,
  formatCodexTemplateApplyError,
  START_MARKER,
} from "../lib/codex-template.ts";

test("codex template expands home paths while preserving sources and unmanaged config", async () => {
  const root = await mkdtemp(join(tmpdir(), "codex-template-test-"));
  const home = process.env.HOME!;
  const templateDir = join(root, "template");
  const outputDir = join(root, "output");
  const configTemplate = [
    "# @nvim.on_save bun run codex:template --apply",
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
    await mkdir(join(templateDir, "agents"), { recursive: true });
    await mkdir(join(outputDir, "agents"), { recursive: true });
    await writeFile(join(templateDir, "config.toml"), configTemplate);
    await writeFile(join(outputDir, "config.toml"), existingConfig);
    for (const file of copyFiles) {
      await writeFile(join(templateDir, file.path), file.source);
      await writeFile(join(outputDir, file.path), "existing\n");
    }

    const options = { templateDir, outputDir, copyTargets: ["AGENTS.md", "agents", "hooks.json"] };

    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
    assertEquals(await readFile(join(outputDir, "config.toml"), "utf8"), existingConfig);
    for (const file of copyFiles) {
      assertEquals(await readFile(join(outputDir, file.path), "utf8"), "existing\n");
    }

    assertEquals(await applyCodexTemplate(options), true);
    assertEquals(
      await readFile(join(outputDir, "config.toml"), "utf8"),
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
    assertEquals(await readFile(join(templateDir, "config.toml"), "utf8"), configTemplate);
    for (const file of copyFiles) {
      assertEquals(await readFile(join(outputDir, file.path), "utf8"), file.expected);
      assertEquals(await readFile(join(templateDir, file.path), "utf8"), file.source);
    }
    assertEquals(await applyCodexTemplate(options), false);
    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), false);
  } finally {
    await rm(root, { recursive: true });
  }
});

async function createManagedSettingsFixture(templateBody: string, managedBody: string) {
  const root = await mkdtemp(join(tmpdir(), "codex-template-test-"));
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
  await mkdir(join(templateDir, "agents"), { recursive: true });
  await mkdir(join(outputDir, "agents"), { recursive: true });
  await writeFile(join(templateDir, "config.toml"), templateBody);
  await writeFile(configPath, existingConfig);
  for (const path of copyFiles) {
    await writeFile(join(templateDir, path), "new contents\n");
    await writeFile(join(outputDir, path), "existing contents\n");
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
  assertEquals(await readFile(fixture.configPath, "utf8"), fixture.existingConfig);
  for (const path of fixture.copyFiles) {
    assertEquals(await readFile(join(fixture.options.outputDir, path), "utf8"), "existing contents\n");
  }
}

const managedSettingsTemplate = 'notify = ["vde-notifier"]\n[tui]\nfullscreen_transcript = false';

test("codex template leaves every output unchanged when a later copy source is missing", async () => {
  const fixture = await createManagedSettingsFixture('model = "new-model"', "");
  try {
    await rm(join(fixture.options.templateDir, "hooks.json"));
    await assertRejects(
      () => applyCodexTemplate(fixture.options),
      CodexTemplateApplyError,
      "copy target was not found",
    );
    await assertManagedSettingsFixtureUnchanged(fixture);
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});

test("codex template rejects unsupported directory entries before writing any outputs", async () => {
  const fixture = await createManagedSettingsFixture('model = "new-model"', "");
  try {
    await symlink("explorer.toml", join(fixture.options.templateDir, "agents", "linked.toml"));
    await assertRejects(
      () => applyCodexTemplate(fixture.options),
      CodexTemplateApplyError,
      "unsupported entry type",
    );
    await assertManagedSettingsFixtureUnchanged(fixture);
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});

for (
  const [kind, current, next] of [
    ["offset datetime", "1979-05-27T07:32:00Z", "1980-05-27T07:32:00Z"],
    ["local datetime", "1979-05-27T07:32:00", "1980-05-27T07:32:00"],
    ["local date", "1979-05-27", "1980-05-27"],
    ["local time", "07:32:00", "08:32:00"],
    ["datetime in an array", "[1979-05-27T07:32:00Z]", "[1980-05-27T07:32:00Z]"],
  ]
) {
  test(`codex template detects changes to ${kind} before writing`, async () => {
    const fixture = await createManagedSettingsFixture(`date = ${next}`, `date = ${current}`);
    try {
      for (const dryRun of [true, false]) {
        await assertRejects(
          () => applyCodexTemplate({ ...fixture.options, dryRun }),
          CodexTemplateApplyError,
          "would remove or change existing managed settings",
        );
        await assertManagedSettingsFixtureUnchanged(fixture);
      }
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });
}

test("codex template accepts equivalent datetime offsets", async () => {
  const fixture = await createManagedSettingsFixture(
    "date = 1979-05-27T07:32:00Z",
    "date = 1979-05-27T00:32:00-07:00",
  );
  try {
    assertEquals(await applyCodexTemplate({ ...fixture.options, dryRun: true }), true);
    await assertManagedSettingsFixtureUnchanged(fixture);
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});
const managedSettingsWithAppAdditions = [
  'notify = ["app-turn-ended", "vde-notifier"]',
  "[tui]",
  "fullscreen_transcript = false",
  "screen_reader_detection_done = true",
  '[plugins."browser@openai-bundled"]',
  "enabled = true",
].join("\n");

test("codex template stops before all writes and displays target-only settings and the complete diff", async () => {
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
    await rm(fixture.root, { recursive: true });
  }
});

test("codex template requires an explicit overwrite flag and keeps unmanaged settings", async () => {
  const fixture = await createManagedSettingsFixture(managedSettingsTemplate, managedSettingsWithAppAdditions);
  const options = { ...fixture.options, overwriteManaged: true };
  try {
    assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
    await assertManagedSettingsFixtureUnchanged(fixture);
    assertEquals(await applyCodexTemplate(options), true);
    assertEquals(
      await readFile(fixture.configPath, "utf8"),
      fixture.existingConfig.replace(managedSettingsWithAppAdditions, managedSettingsTemplate),
    );
    for (const path of fixture.copyFiles) {
      assertEquals(await readFile(join(fixture.options.outputDir, path), "utf8"), "new contents\n");
    }
    assertEquals(await applyCodexTemplate(fixture.options), false);
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});

test("codex template stops for known-key value changes until an overwrite is requested", async () => {
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
      await readFile(fixture.configPath, "utf8"),
      fixture.existingConfig.replace(existing, template),
    );
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});

test("codex template allows new settings and equivalent TOML values despite formatting changes", async () => {
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
      await readFile(fixture.configPath, "utf8"),
      fixture.existingConfig.replace(existing, template),
    );
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});

test("codex template checks quoted keys, inline tables and empty target-only tables", async () => {
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
    await rm(fixture.root, { recursive: true });
  }
});

for (const invalidSource of ["template", "target"]) {
  test(`codex template stops before all writes for invalid ${invalidSource} TOML even with an overwrite flag`, async () => {
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
      await rm(fixture.root, { recursive: true });
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
  const root = await mkdtemp(join(tmpdir(), "codex-template-test-"));
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
  await mkdir(templateDir);
  await mkdir(outputDir);
  await mkdir(dirname(infoPath), { recursive: true });
  await mkdir(dirname(servicePath(version)), { recursive: true });
  await writeFile(infoPath, appInfoPlist(version));
  await writeFile(servicePath(version), "export {};\n");
  await writeFile(join(templateDir, "config.toml"), configTemplate);
  await writeFile(join(templateDir, "AGENTS.md"), "new instructions\n");
  await writeFile(join(outputDir, "config.toml"), existingConfig);
  await writeFile(join(outputDir, "AGENTS.md"), "existing instructions\n");
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

test.skipIf(process.platform !== "darwin")(
  "codex template reads the app release version on each apply and validates the referenced browser service",
  async () => {
    const fixture = await createChatgptTemplateFixture();
    const { options, version, configTemplate, existingConfig } = fixture;
    const configPath = join(options.outputDir, "config.toml");
    try {
      assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), true);
      assertEquals(await readFile(configPath, "utf8"), existingConfig);
      assertEquals(await readFile(join(options.outputDir, "AGENTS.md"), "utf8"), "existing instructions\n");

      assertEquals(await applyCodexTemplate(options), true);
      const expectedConfig = (appVersion: string) =>
        [
          'personal = "~/keep"',
          START_MARKER,
          configTemplate.replaceAll("{{CHATGPT_APP_VERSION}}", appVersion).trimEnd(),
          END_MARKER,
          "",
        ].join("\n");
      assertEquals(await readFile(configPath, "utf8"), expectedConfig(version));
      assertEquals(await readFile(join(options.outputDir, "AGENTS.md"), "utf8"), "new instructions\n");
      assertEquals(await readFile(join(options.templateDir, "config.toml"), "utf8"), configTemplate);
      assertEquals(await applyCodexTemplate(options), false);

      const updatedVersion = "26.918.70000";
      await writeFile(fixture.infoPath, appInfoPlist(updatedVersion));
      await assertRejects(
        () => applyCodexTemplate(options),
        CodexTemplateApplyError,
        "browser service for the ChatGPT app version is unavailable",
      );
      assertEquals(await readFile(configPath, "utf8"), expectedConfig(version));

      await mkdir(dirname(fixture.servicePath(updatedVersion)), { recursive: true });
      await writeFile(fixture.servicePath(updatedVersion), "export {};\n");
      await assertRejects(
        () => applyCodexTemplate(options),
        CodexTemplateApplyError,
        "would remove or change existing managed settings",
      );
      assertEquals(await readFile(configPath, "utf8"), expectedConfig(version));
      assertEquals(await applyCodexTemplate({ ...options, overwriteManaged: true }), true);
      assertEquals(await readFile(configPath, "utf8"), expectedConfig(updatedVersion));
      assertEquals(await applyCodexTemplate({ ...options, dryRun: true }), false);
      assertEquals(await readFile(join(options.templateDir, "config.toml"), "utf8"), configTemplate);
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  },
);

const chatgptFailureCases = [
  {
    name: "missing app Info.plist",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) => rm(fixture.infoPath),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "malformed app Info.plist",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      writeFile(fixture.infoPath, "not a plist"),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "missing app release version",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      writeFile(fixture.infoPath, '<plist version="1.0"><dict></dict></plist>'),
    message: "Could not read the ChatGPT app version",
  },
  {
    name: "invalid app release version",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      writeFile(fixture.infoPath, appInfoPlist("26.invalid.123")),
    message: "The ChatGPT app version is invalid",
  },
  {
    name: "missing browser service",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      rm(fixture.servicePath(fixture.version)),
    message: "browser service for the ChatGPT app version is unavailable",
  },
  {
    name: "browser service is a directory",
    async prepare(fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) {
      await rm(fixture.servicePath(fixture.version));
      await mkdir(fixture.servicePath(fixture.version));
    },
    message: "browser service for the ChatGPT app version is unavailable",
  },
  {
    name: "invalid trusted services JSON",
    prepare: (fixture: Awaited<ReturnType<typeof createChatgptTemplateFixture>>) =>
      writeFile(
        join(fixture.options.templateDir, "config.toml"),
        fixture.configTemplate.replace('{"browser":', "{browser:"),
      ),
    message: "The browser service configuration is invalid",
  },
];

for (const failureCase of chatgptFailureCases) {
  test.skipIf(process.platform !== "darwin")(
    `codex template leaves all output files unchanged for ${failureCase.name}`,
    async () => {
      const fixture = await createChatgptTemplateFixture();
      try {
        await failureCase.prepare(fixture);
        const templatePath = join(fixture.options.templateDir, "config.toml");
        const configTemplate = await readFile(templatePath, "utf8");
        for (const dryRun of [true, false]) {
          await assertRejects(
            () => applyCodexTemplate({ ...fixture.options, dryRun }),
            CodexTemplateApplyError,
            failureCase.message,
          );
          assertEquals(
            await readFile(join(fixture.options.outputDir, "config.toml"), "utf8"),
            fixture.existingConfig,
          );
          assertEquals(
            await readFile(join(fixture.options.outputDir, "AGENTS.md"), "utf8"),
            "existing instructions\n",
          );
          assertEquals(await readFile(templatePath, "utf8"), configTemplate);
        }
      } finally {
        await rm(fixture.root, { recursive: true });
      }
    },
  );
}
