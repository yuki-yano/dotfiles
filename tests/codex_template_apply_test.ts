import { assertEquals } from "@std/assert";
import { join } from "@std/path";
import { applyCodexTemplate, END_MARKER, START_MARKER } from "../bin/codex-template-apply.ts";

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
