#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

import { $ } from "@david/dax";
import {
  applyCodexTemplate,
  CodexTemplateApplyError,
  formatCodexTemplateApplyError,
} from "./bin/codex-template-apply.ts";

const DOTFILES_SRCS = [
  ".agents",
  ".bashrc",
  ".config",
  ".ctags.d",
  ".duti",
  ".finicky.js",
  ".gitattributes_global",
  ".gitconfig",
  ".gitignore_global",
  ".tigrc",
  ".tmux.conf",
  ".zsh",
  ".zshenv",
  ".zshrc",
  ".zprofile",
];

const SRC_DIR = Deno.cwd();
const HOME = Deno.env.get("HOME");
if (!HOME) {
  console.error("ERROR: HOME environment variable is not set");
  Deno.exit(1);
}
const CLAUDE_DIR = `${SRC_DIR}/.config/claude`;
const COPILOT_DIR = `${HOME}/.copilot`;
const AGENTS_SKILLS_DIR = `${HOME}/.agents/skills`;
const CLAUDE_SKILLS_DIR = `${CLAUDE_DIR}/skills`;
const COPILOT_SKILLS_DIR = `${COPILOT_DIR}/skills`;
const CODEX_TEMPLATE_COPY_TARGETS = ["AGENTS.md", "agents", "hooks.json"];
type CodexPluginId = "superpowers";

type CodexPluginDefinition = {
  id: CodexPluginId;
  plugin: string;
  marketplace?: {
    name: string;
    source: string;
  };
};

const CODEX_PLUGIN_DEFINITIONS: readonly CodexPluginDefinition[] = [
  {
    id: "superpowers",
    plugin: "superpowers@openai-curated",
  },
];

export type ClaudePluginId = "superpowers";

export type ClaudePluginDefinition = {
  id: ClaudePluginId;
  marketplaceName: string;
  marketplaceSource: string;
  plugin: string;
  enabled: boolean;
};

export const CLAUDE_PLUGIN_DEFINITIONS: readonly ClaudePluginDefinition[] = [
  {
    id: "superpowers",
    marketplaceName: "superpowers-marketplace",
    marketplaceSource: "obra/superpowers-marketplace",
    plugin: "superpowers@superpowers-marketplace",
    enabled: false,
  },
];
const SHELDON_CONFIG_FILE = `${SRC_DIR}/.config/sheldon/plugins.toml`;
const SHELDON_DATA_DIR = `${HOME}/.local/share/sheldon`;
const SHELDON_CACHE_DIR = `${HOME}/.cache/sheldon`;
const SHELDON_PHASES = [
  { profile: "pre", filename: "pre.zsh" },
  { profile: "post", filename: "post.zsh" },
];
const AGENT_LINK_TARGETS = [
  { dir: CLAUDE_DIR, link: CLAUDE_SKILLS_DIR },
  { dir: COPILOT_DIR, link: COPILOT_SKILLS_DIR },
];
const DUTI_CONFIG_FILE = `${HOME}/.duti`;

let DRY_RUN = false;
let APPLY = false;

async function readLines(filename: string): Promise<string[]> {
  const content = await Deno.readTextFile(filename);
  return content.split("\n").filter((line) => line && !line.startsWith("#"));
}

async function readRawLines(filename: string): Promise<string[]> {
  const content = await Deno.readTextFile(filename);
  return content.split("\n");
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch {
    return false;
  }
}

async function isSymlink(path: string): Promise<boolean> {
  try {
    const stat = await Deno.lstat(path);
    return stat.isSymlink;
  } catch {
    return false;
  }
}

async function ensureCommandAvailable(command: string): Promise<void> {
  try {
    const process = new Deno.Command(command, {
      args: ["--version"],
      stdout: "null",
      stderr: "null",
    });
    const { code } = await process.output();
    if (code === 0) {
      return;
    }
  } catch {
    // handled below
  }

  console.error(`ERROR: ${command} command not found`);
  Deno.exit(1);
}

async function ensureCommandOnPath(command: string): Promise<void> {
  try {
    const process = new Deno.Command("which", {
      args: [command],
      stdout: "null",
      stderr: "null",
    });
    const { code } = await process.output();
    if (code === 0) {
      return;
    }
  } catch {
    // handled below
  }

  console.error(`ERROR: ${command} command not found`);
  Deno.exit(1);
}

async function runSheldon(args: string[], profile?: string): Promise<string> {
  const command = new Deno.Command("sheldon", {
    args: ["--config-file", SHELDON_CONFIG_FILE, "--data-dir", SHELDON_DATA_DIR, ...args],
    env: profile ? { SHELDON_PROFILE: profile } : undefined,
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await command.output();
  if (code !== 0) {
    const message = new TextDecoder().decode(stderr).trim();
    throw new Error(message || `sheldon ${args.join(" ")} failed`);
  }
  return new TextDecoder().decode(stdout);
}

async function zcompileIfExists(path: string): Promise<void> {
  if (!(await fileExists(path))) {
    return;
  }

  const process = new Deno.Command("zsh", {
    args: ["-dfc", `zcompile ${JSON.stringify(path)}`],
    stdout: "null",
    stderr: "piped",
  });
  const { code, stderr } = await process.output();
  if (code !== 0) {
    const message = new TextDecoder().decode(stderr).trim();
    throw new Error(message || `zcompile failed for ${path}`);
  }
}

function promptYesNo(message: string): boolean {
  const answer = prompt(`${message} (y/N)`);
  return answer?.toLowerCase() === "y";
}

const ALLOWED_BREW_COMMANDS = new Set(["install", "tap", "cask", "update", "upgrade", "cleanup"]);

export function validateBrewCommand(command: string): boolean {
  const parts = command.trim().split(/\s+/);
  return parts.length > 0 && ALLOWED_BREW_COMMANDS.has(parts[0]);
}

type InstallCommand = {
  leadingOptions: string[];
  packages: string[];
  trailingOptions: string[];
};

type CommandResult = {
  code: number;
  stdout: string;
  stderr: string;
};

async function runCommand(command: string, args: string[]): Promise<CommandResult> {
  const process = new Deno.Command(command, {
    args,
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await process.output();
  const decoder = new TextDecoder();
  return {
    code,
    stdout: decoder.decode(stdout),
    stderr: decoder.decode(stderr),
  };
}

function commandDisplay(command: string, args: string[]): string {
  return [command, ...args].join(" ");
}

async function readCommandOutput(command: string, args: string[]): Promise<string> {
  const result = await runCommand(command, args);
  if (result.code !== 0) {
    throw new Error(result.stderr.trim() || `${commandDisplay(command, args)} failed`);
  }
  return result.stdout;
}

async function runRequiredCommand(command: string, args: string[]): Promise<void> {
  const result = await runCommand(command, args);
  if (result.code !== 0) {
    throw new Error(result.stderr.trim() || `${commandDisplay(command, args)} failed`);
  }
  const output = result.stdout.trim();
  if (output.length > 0) {
    console.log(output);
  }
}

type CodexPluginStatus = {
  known: boolean;
  installed: boolean;
  enabled: boolean;
};

function getCodexPluginStatus(pluginList: string, selector: string): CodexPluginStatus {
  const line = pluginList.split("\n").find((line) => line.trimStart().startsWith(selector));
  if (!line) {
    return { known: false, installed: false, enabled: false };
  }

  const status = line.trimStart().slice(selector.length).trim();
  return {
    known: true,
    installed: status.startsWith("installed"),
    enabled: /^installed,\s*enabled\b/.test(status),
  };
}

function isCodexMarketplaceConfigured(marketplaceList: string, marketplaceName: string): boolean {
  return marketplaceList
    .split("\n")
    .some((line) => line.trimStart().startsWith(`${marketplaceName} `));
}

function isCodexMarketplaceSourceConflict(error: unknown, marketplaceName: string): boolean {
  return error instanceof Error &&
    error.message.includes(`marketplace '${marketplaceName}' is already added from a different source`);
}

function isCodexMarketplaceLoadFailure(error: unknown, marketplaceName: string): boolean {
  return error instanceof Error &&
    error.message.includes(`\`${marketplaceName}\``) &&
    error.message.includes("marketplace root does not contain a supported manifest");
}

function isClaudeMarketplaceConfigured(
  marketplaceList: string,
  marketplaceName: string,
  marketplaceSource: string,
): boolean {
  return marketplaceList
    .split("\n")
    .some((line) =>
      line.includes(marketplaceName) ||
      line.includes(marketplaceSource)
    );
}

type ClaudePluginStatus = {
  installed: boolean;
  enabled: boolean;
};

function getClaudePluginStatus(pluginList: string, pluginSelector: string): ClaudePluginStatus {
  const plugins: unknown = JSON.parse(pluginList);
  if (!Array.isArray(plugins)) {
    throw new Error("Claude plugin list JSON must be an array");
  }

  const plugin = plugins.find((entry) =>
    typeof entry === "object" && entry !== null && "id" in entry && entry.id === pluginSelector
  );
  if (!plugin) {
    return { installed: false, enabled: false };
  }
  if (!("enabled" in plugin) || typeof plugin.enabled !== "boolean") {
    throw new Error(`Claude plugin '${pluginSelector}' has no boolean enabled state`);
  }

  return {
    installed: true,
    enabled: plugin.enabled,
  };
}

function parseInstallCommand(command: string): InstallCommand | null {
  const parts = command.trim().split(/\s+/);
  if (parts[0] !== "install" || parts.length < 2) {
    return null;
  }

  const tokens = parts.slice(1);
  const leadingOptions: string[] = [];
  const packages: string[] = [];
  const trailingOptions: string[] = [];

  let seenPackage = false;
  let inTrailingOptions = false;

  for (const token of tokens) {
    const isOption = token.startsWith("-");

    if (!seenPackage) {
      if (isOption) {
        leadingOptions.push(token);
        continue;
      }

      packages.push(token);
      seenPackage = true;
      continue;
    }

    if (inTrailingOptions) {
      if (!isOption) {
        return null;
      }

      trailingOptions.push(token);
      continue;
    }

    if (isOption) {
      trailingOptions.push(token);
      inTrailingOptions = true;
      continue;
    }

    packages.push(token);
  }

  if (packages.length === 0) {
    return null;
  }

  return { leadingOptions, packages, trailingOptions };
}

function canMergeInstallCommands(left: InstallCommand, right: InstallCommand): boolean {
  return (
    left.leadingOptions.join("\0") === right.leadingOptions.join("\0") &&
    left.trailingOptions.join("\0") === right.trailingOptions.join("\0")
  );
}

function formatInstallCommand(command: InstallCommand): string {
  return [
    "install",
    ...command.leadingOptions,
    ...command.packages,
    ...command.trailingOptions,
  ].join(" ");
}

async function loadBrewCommands(filename: string): Promise<string[]> {
  const lines = await readRawLines(filename);
  const commands: string[] = [];
  let pendingInstall: InstallCommand | null = null;

  const flushPendingInstall = () => {
    if (!pendingInstall) {
      return;
    }

    commands.push(formatInstallCommand(pendingInstall));
    pendingInstall = null;
  };

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (!line || line.startsWith("#")) {
      continue;
    }

    if (!validateBrewCommand(line)) {
      console.error(`ERROR: Invalid brew command: ${line}`);
      console.error("Only 'install', 'tap', 'cask', 'update', 'upgrade', and 'cleanup' commands are allowed");
      Deno.exit(1);
    }

    const installCommand = parseInstallCommand(line);
    if (!installCommand) {
      flushPendingInstall();
      commands.push(line);
      continue;
    }

    if (pendingInstall && canMergeInstallCommands(pendingInstall, installCommand)) {
      pendingInstall.packages.push(...installCommand.packages);
      continue;
    }

    flushPendingInstall();
    pendingInstall = installCommand;
  }

  flushPendingInstall();
  return commands;
}

async function runBrewCommand(command: string): Promise<void> {
  const args = command.trim().split(/\s+/);
  const process = new Deno.Command("brew", {
    args,
    stdout: "inherit",
    stderr: "inherit",
  });
  const { code } = await process.output();
  if (code !== 0) {
    throw new Error(`brew ${command} failed with exit code ${code}`);
  }
}

async function listDirectoryEntries(path: string): Promise<string[]> {
  try {
    const entries: string[] = [];
    for await (const entry of Deno.readDir(path)) {
      entries.push(entry.name);
    }
    return entries.sort();
  } catch {
    return [];
  }
}

async function describeAgentLinkTarget(link: string): Promise<string[]> {
  if (!(await fileExists(link))) {
    return [];
  }

  if (await isSymlink(link)) {
    return [`${link} is already a symlink`];
  }

  const entries = await listDirectoryEntries(link);
  if (entries.length === 0) {
    return [`${link} is an empty directory and will be replaced`];
  }

  return [
    `${link} is a directory and will be replaced; current entries:`,
    ...entries.map((entry) => `  - ${entry}`),
  ];
}

async function ensureCodexMarketplace(definition: CodexPluginDefinition): Promise<void> {
  if (!definition.marketplace) {
    return;
  }

  await ensureCommandOnPath("codex");

  try {
    const marketplaceList = await readCommandOutput("codex", ["plugin", "marketplace", "list"]);
    if (isCodexMarketplaceConfigured(marketplaceList, definition.marketplace.name)) {
      console.log(`Codex: ${definition.marketplace.name} marketplace is already configured`);
      return;
    }
  } catch (error) {
    if (!isCodexMarketplaceLoadFailure(error, definition.marketplace.name)) {
      throw error;
    }
  }

  const args = ["plugin", "marketplace", "add", definition.marketplace.source];
  if (DRY_RUN) {
    console.log(`[DRY RUN] Codex: would run: ${commandDisplay("codex", args)}`);
    return;
  }

  console.log(`Codex: adding ${definition.marketplace.name} marketplace`);
  try {
    await runRequiredCommand("codex", args);
  } catch (error) {
    if (!isCodexMarketplaceSourceConflict(error, definition.marketplace.name)) {
      throw error;
    }

    console.log(`Codex: repairing ${definition.marketplace.name} marketplace source`);
    await runRequiredCommand("codex", [
      "plugin",
      "marketplace",
      "remove",
      definition.marketplace.name,
    ]);
    await runRequiredCommand("codex", args);
  }
}

async function ensureCodexPlugin(definition: CodexPluginDefinition): Promise<void> {
  await ensureCommandOnPath("codex");

  const pluginList = await readCommandOutput("codex", ["plugin", "list"]);
  const status = getCodexPluginStatus(pluginList, definition.plugin);
  if (status.installed && status.enabled) {
    console.log(`Codex: ${definition.plugin} is already installed and enabled`);
    return;
  }

  const args = ["plugin", "add", definition.plugin];
  if (DRY_RUN) {
    const reason = status.installed
      ? "installed but not enabled"
      : status.known
      ? "available but not installed"
      : "not found";
    console.log(`[DRY RUN] Codex: ${reason}; would run: ${commandDisplay("codex", args)}`);
    return;
  }

  console.log(`Codex: installing ${definition.plugin}`);
  await runRequiredCommand("codex", args);
}

async function ensureCodexPlugins(): Promise<void> {
  for (const definition of CODEX_PLUGIN_DEFINITIONS) {
    await ensureCodexMarketplace(definition);
    await ensureCodexPlugin(definition);
  }
}

async function ensureClaudeMarketplace(definition: ClaudePluginDefinition): Promise<void> {
  await ensureCommandOnPath("claude");

  const marketplaceList = await readCommandOutput("claude", ["plugin", "marketplace", "list"]);
  if (
    isClaudeMarketplaceConfigured(
      marketplaceList,
      definition.marketplaceName,
      definition.marketplaceSource,
    )
  ) {
    console.log(`Claude: ${definition.marketplaceName} marketplace is already configured`);
    return;
  }

  const args = [
    "plugin",
    "marketplace",
    "add",
    "--scope",
    "user",
    definition.marketplaceSource,
  ];
  if (DRY_RUN) {
    console.log(`[DRY RUN] Claude: would run: ${commandDisplay("claude", args)}`);
    return;
  }

  console.log(`Claude: adding ${definition.marketplaceName} marketplace`);
  await runRequiredCommand("claude", args);
}

async function ensureClaudePlugin(definition: ClaudePluginDefinition): Promise<void> {
  await ensureCommandOnPath("claude");

  const pluginList = await readCommandOutput("claude", ["plugin", "list", "--json"]);
  const status = getClaudePluginStatus(pluginList, definition.plugin);
  const desiredState = definition.enabled ? "enabled" : "disabled";
  if (status.installed && status.enabled === definition.enabled) {
    console.log(`Claude: ${definition.plugin} is already installed and ${desiredState}`);
    return;
  }

  if (!status.installed) {
    const installArgs = ["plugin", "install", "--scope", "user", definition.plugin];
    if (DRY_RUN) {
      console.log(`[DRY RUN] Claude: would run: ${commandDisplay("claude", installArgs)}`);
      if (!definition.enabled) {
        const disableArgs = ["plugin", "disable", "--scope", "user", definition.plugin];
        console.log(`[DRY RUN] Claude: would run: ${commandDisplay("claude", disableArgs)}`);
      }
      return;
    }

    console.log(`Claude: installing ${definition.plugin}`);
    await runRequiredCommand("claude", installArgs);
    if (definition.enabled) return;
  }

  const action = definition.enabled ? "enable" : "disable";
  const args = ["plugin", action, "--scope", "user", definition.plugin];
  if (DRY_RUN) {
    console.log(`[DRY RUN] Claude: would run: ${commandDisplay("claude", args)}`);
    return;
  }

  console.log(`Claude: ${action === "enable" ? "enabling" : "disabling"} ${definition.plugin}`);
  await runRequiredCommand("claude", args);
}

async function ensureClaudePlugins(): Promise<void> {
  for (const definition of CLAUDE_PLUGIN_DEFINITIONS) {
    await ensureClaudeMarketplace(definition);
    await ensureClaudePlugin(definition);
  }
}

// タスク定義
const tasks: Record<string, () => Promise<void> | void> = {
  async "dotfiles:install"() {
    console.log("Installing dotfiles...");

    // Check for existing files that are not symlinks
    const existingFiles = [];
    for (const file of DOTFILES_SRCS) {
      const dest = `${HOME}/${file}`;
      if (await fileExists(dest) && !(await isSymlink(dest))) {
        existingFiles.push(file);
      }
    }

    if (existingFiles.length > 0 && !DRY_RUN) {
      console.log("\nWarning: The following files exist and are not symlinks:");
      existingFiles.forEach((f) => console.log(`  - ${f}`));
      const proceed = promptYesNo("\nDo you want to replace them?");
      if (!proceed) {
        console.log("Aborted.");
        return;
      }
    }

    for (const file of DOTFILES_SRCS) {
      const src = `${SRC_DIR}/${file}`;
      const dest = `${HOME}/${file}`;

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would remove ${dest} and link to ${src}`);
      } else {
        // Only remove if it exists and is a symlink, or user confirmed
        if (await fileExists(dest)) {
          await $`rm -rf ${dest}`;
        }
        await $`ln -sfn ${src} ${dest}`;
        console.log(`  ✓ ${file}`);
      }
    }
    console.log(DRY_RUN ? "[DRY RUN] Done!" : "Done!");
  },

  async "agent:link"() {
    if (!(await fileExists(AGENTS_SKILLS_DIR))) {
      console.error(`ERROR: ${AGENTS_SKILLS_DIR} does not exist`);
      Deno.exit(1);
    }

    for (const target of AGENT_LINK_TARGETS) {
      if (!(await fileExists(target.dir))) {
        if (DRY_RUN) {
          console.log(`[DRY RUN] Would create directory: ${target.dir}`);
        } else {
          await Deno.mkdir(target.dir, { recursive: true });
        }
      }
    }

    for (const target of AGENT_LINK_TARGETS) {
      const descriptions = await describeAgentLinkTarget(target.link);
      for (const description of descriptions) {
        console.log(DRY_RUN ? `[DRY RUN] ${description}` : description);
      }

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would remove ${target.link} and link ${AGENTS_SKILLS_DIR} to it`);
      } else {
        if (await fileExists(target.link)) {
          await $`rm -rf ${target.link}`;
        }
        await $`ln -sfn ${AGENTS_SKILLS_DIR} ${target.link}`;
        console.log(`Linked ${target.link} -> ${AGENTS_SKILLS_DIR}`);
      }
    }
  },

  async "agent:codex-plugins"() {
    await ensureCodexPlugins();
  },

  async "agent:claude-plugins"() {
    await ensureClaudePlugins();
  },

  async "codex:template"() {
    const dryRun = DRY_RUN || !APPLY;
    const changed = await applyCodexTemplate({
      dryRun,
      copyTargets: CODEX_TEMPLATE_COPY_TARGETS,
    });

    if (dryRun) {
      if (changed) {
        console.log("");
        console.log("Dry-run passed.");
        console.log("To apply changes, run: deno task codex:template -- --apply");
      } else {
        console.log("");
        console.log("Dry-run passed. No changes to apply.");
      }
    }
  },

  async "zsh:sheldon:sync"() {
    if (!(await fileExists(SHELDON_CONFIG_FILE))) {
      console.error(`ERROR: ${SHELDON_CONFIG_FILE} not found`);
      Deno.exit(1);
    }

    await ensureCommandAvailable("sheldon");

    if (DRY_RUN) {
      console.log(
        `[DRY RUN] Would run: sheldon --config-file ${SHELDON_CONFIG_FILE} --data-dir ${SHELDON_DATA_DIR} lock`,
      );
      for (const phase of SHELDON_PHASES) {
        console.log(
          `[DRY RUN] Would generate profile '${phase.profile}' to ${SHELDON_CACHE_DIR}/${phase.filename}`,
        );
      }
      return;
    }

    await Deno.mkdir(SHELDON_CACHE_DIR, { recursive: true });
    for (const phase of SHELDON_PHASES) {
      console.log(`Running: sheldon lock (${phase.profile})`);
      await runSheldon(["lock"], phase.profile);
      console.log(`Generating sheldon source: ${phase.profile}`);
      const content = await runSheldon(["source"], phase.profile);
      const outputPath = `${SHELDON_CACHE_DIR}/${phase.filename}`;
      await Deno.writeTextFile(outputPath, content);
      await zcompileIfExists(outputPath);
    }
  },

  async "zsh:sheldon:update"() {
    if (!(await fileExists(SHELDON_CONFIG_FILE))) {
      console.error(`ERROR: ${SHELDON_CONFIG_FILE} not found`);
      Deno.exit(1);
    }

    await ensureCommandAvailable("sheldon");

    if (DRY_RUN) {
      console.log(
        `[DRY RUN] Would run: sheldon --config-file ${SHELDON_CONFIG_FILE} --data-dir ${SHELDON_DATA_DIR} lock --update`,
      );
      for (const phase of SHELDON_PHASES) {
        console.log(
          `[DRY RUN] Would generate profile '${phase.profile}' to ${SHELDON_CACHE_DIR}/${phase.filename}`,
        );
      }
      return;
    }

    await Deno.mkdir(SHELDON_CACHE_DIR, { recursive: true });
    for (const phase of SHELDON_PHASES) {
      console.log(`Running: sheldon lock --update (${phase.profile})`);
      await runSheldon(["lock", "--update"], phase.profile);
      console.log(`Generating sheldon source: ${phase.profile}`);
      const content = await runSheldon(["source"], phase.profile);
      const outputPath = `${SHELDON_CACHE_DIR}/${phase.filename}`;
      await Deno.writeTextFile(outputPath, content);
      await zcompileIfExists(outputPath);
    }
  },

  async "brew:bundle"() {
    if (!(await fileExists("Brewfile"))) {
      console.error("ERROR: Brewfile not found");
      Deno.exit(1);
    }

    const commands = await loadBrewCommands("Brewfile");
    for (const cmd of commands) {
      if (DRY_RUN) {
        console.log(`[DRY RUN] Would run: brew ${cmd}`);
      } else {
        console.log(`Running: brew ${cmd}`);
        await runBrewCommand(cmd);
      }
    }
  },

  async "brew:cask"() {
    if (!(await fileExists("Caskfile"))) {
      console.error("ERROR: Caskfile not found");
      Deno.exit(1);
    }

    const commands = await loadBrewCommands("Caskfile");
    for (const cmd of commands) {
      if (DRY_RUN) {
        console.log(`[DRY RUN] Would run: brew ${cmd}`);
      } else {
        console.log(`Running: brew ${cmd}`);
        await runBrewCommand(cmd);
      }
    }
  },

  async "duti:apply"() {
    if (DRY_RUN) {
      console.log(`[DRY RUN] Would run: duti ${DUTI_CONFIG_FILE}`);
      return;
    }

    if (!(await fileExists(DUTI_CONFIG_FILE))) {
      console.error(`ERROR: ${DUTI_CONFIG_FILE} not found`);
      console.error("Run 'deno task dotfiles:install' before applying duti settings");
      Deno.exit(1);
    }

    await ensureCommandOnPath("duti");

    await $`duti ${DUTI_CONFIG_FILE}`;
    console.log(`Applied duti settings from ${DUTI_CONFIG_FILE}`);
  },

  async "mas:install"() {
    if (!(await fileExists("Masfile"))) {
      console.error("ERROR: Masfile not found");
      Deno.exit(1);
    }

    const masfile = await readLines("Masfile");
    const appIds = masfile
      .map((line) => {
        const parts = line.trim().split(/\s+/);
        return parts.length >= 2 ? parts[1] : null;
      })
      .filter((id): id is string => id !== null);

    // インストール済みのアプリを取得
    const installedList = await $`mas list`.lines();
    const installedIds = installedList.map((line) => line.split(" ")[0]);

    // 未インストールのアプリのみインストール
    const toInstall = appIds.filter((id) => !installedIds.includes(id));

    if (DRY_RUN) {
      if (toInstall.length > 0) {
        console.log("[DRY RUN] Would install the following apps:");
        toInstall.forEach((id) => console.log(`  - ${id}`));
      } else {
        console.log("[DRY RUN] All apps are already installed");
      }
    } else {
      for (const appId of toInstall) {
        console.log(`Installing app: ${appId}`);
        await $`mas install ${appId}`;
      }

      if (toInstall.length === 0) {
        console.log("All apps are already installed");
      }
    }
  },

  help() {
    console.log("Available tasks:");
    console.log("");
    console.log("  Dotfiles:");
    console.log("    deno task dotfiles:install    - Install dotfiles symlinks");
    console.log(
      "    deno task agent:link          - Link Claude/Copilot skills to ~/.agents/skills",
    );
    console.log(
      "    deno task agent:codex-plugins - Install all configured Codex plugins",
    );
    console.log(
      "    deno task agent:claude-plugins - Install all configured Claude Code plugins",
    );
    console.log(
      "    deno task codex:template      - Dry-run apply codex template (use -- --apply to write)",
    );
    console.log("");
    console.log("  Zsh:");
    console.log("    deno task zsh:sheldon:sync    - Lock plugins and generate sheldon source cache");
    console.log("    deno task zsh:sheldon:update  - Update plugins and regenerate sheldon source cache");
    console.log("");
    console.log("  Homebrew:");
    console.log("    deno task brew:bundle         - Install Homebrew packages");
    console.log("    deno task brew:cask           - Install Homebrew Cask apps");
    console.log("    deno task duti:apply          - Apply default app handlers from ~/.duti");
    console.log("");
    console.log("  Mac App Store:");
    console.log("    deno task mas:install         - Install App Store apps");
    console.log("");
    console.log("Options:");
    console.log("    --dry-run                     - Show what would be done without making changes");
    console.log("    --apply                       - Execute codex:template write (default is dry-run)");
  },
};

if (import.meta.main) {
  // Check for --dry-run flag
  const args = [...Deno.args];
  const dryRunIndex = args.indexOf("--dry-run");
  if (dryRunIndex !== -1) {
    DRY_RUN = true;
    args.splice(dryRunIndex, 1);
  }

  const applyIndex = args.indexOf("--apply");
  if (applyIndex !== -1) {
    APPLY = true;
    args.splice(applyIndex, 1);
  }

  const taskName = args[0];

  if (!taskName) {
    console.error("Usage: deno task <task-name>");
    console.error("Run 'deno task help' to see available tasks");
    Deno.exit(1);
  }

  const task = tasks[taskName];
  if (!task) {
    console.error(`Unknown task: ${taskName}`);
    console.error("Run 'deno task help' to see available tasks");
    Deno.exit(1);
  }

  try {
    await task();
  } catch (error) {
    if (error instanceof CodexTemplateApplyError) {
      console.error(formatCodexTemplateApplyError(error));
      Deno.exit(1);
    }

    console.error(`Task failed: ${taskName}`);
    console.error(error);
    Deno.exit(1);
  }
}
