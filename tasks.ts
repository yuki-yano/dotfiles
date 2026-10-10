#!/usr/bin/env bun

import { $ } from "bun";
import { lstat, mkdir, readdir, readFile, stat, writeFile } from "node:fs/promises";
import { applyCodexTemplate, CodexTemplateApplyError, formatCodexTemplateApplyError } from "./lib/codex-template.ts";

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

const SRC_DIR = process.cwd();
const HOME = process.env.HOME;
if (!HOME) {
  console.error("ERROR: HOME environment variable is not set");
  process.exit(1);
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
let OVERWRITE_MANAGED = false;

async function readLines(filename: string): Promise<string[]> {
  const content = await readFile(filename, "utf8");
  return content.split("\n").filter((line) => line && !line.startsWith("#"));
}

async function readRawLines(filename: string): Promise<string[]> {
  const content = await readFile(filename, "utf8");
  return content.split("\n");
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await stat(path);
    return true;
  } catch {
    return false;
  }
}

async function isSymlink(path: string): Promise<boolean> {
  try {
    const stat = await lstat(path);
    return stat.isSymbolicLink();
  } catch {
    return false;
  }
}

async function ensureCommandAvailable(command: string): Promise<void> {
  try {
    if ((await runCommand(command, ["--version"])).code === 0) return;
  } catch {
    // handled below
  }
  console.error(`ERROR: ${command} command not found`);
  process.exit(1);
}

async function ensureCommandOnPath(command: string): Promise<void> {
  if (Bun.which(command)) return;
  console.error(`ERROR: ${command} command not found`);
  process.exit(1);
}

async function runSheldon(args: string[], profile?: string): Promise<string> {
  const result = await runCommand(
    "sheldon",
    ["--config-file", SHELDON_CONFIG_FILE, "--data-dir", SHELDON_DATA_DIR, ...args],
    profile ? { SHELDON_PROFILE: profile } : undefined,
  );
  if (result.code !== 0) throw new Error(result.stderr.trim() || `sheldon ${args.join(" ")} failed`);
  return result.stdout;
}

async function zcompileIfExists(path: string): Promise<void> {
  if (!(await fileExists(path))) return;
  const result = await runCommand("zsh", ["-dfc", `zcompile ${JSON.stringify(path)}`]);
  if (result.code !== 0) throw new Error(result.stderr.trim() || `zcompile failed for ${path}`);
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

async function runCommand(
  command: string,
  args: string[],
  env?: Record<string, string>,
): Promise<CommandResult> {
  const child = Bun.spawn([command, ...args], {
    env: { ...process.env, ...env },
    stdin: "ignore",
    stdout: "pipe",
    stderr: "pipe",
  });
  const [code, stdout, stderr] = await Promise.all([
    child.exited,
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
  ]);
  return { code, stdout, stderr };
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

export async function loadBrewCommands(filename: string): Promise<string[]> {
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
      process.exit(1);
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

export function buildBrewCommandOptions(command: string) {
  const args = command.trim().split(/\s+/);
  return {
    args,
    env: {
      HOMEBREW_NO_ASK: "1",
    },
    stdout: "inherit" as const,
    stderr: "inherit" as const,
  };
}

async function runBrewCommand(command: string): Promise<void> {
  const { args, env, stdout, stderr } = buildBrewCommandOptions(command);
  const child = Bun.spawn(["brew", ...args], {
    env: { ...process.env, ...env },
    stdin: "ignore",
    stdout,
    stderr,
  });
  const code = await child.exited;
  if (code !== 0) throw new Error(`brew ${command} failed with exit code ${code}`);
}

async function runBrewCommands(commands: string[]): Promise<void> {
  for (const command of commands) {
    if (DRY_RUN) {
      console.log(`[DRY RUN] Would run: brew ${command}`);
    } else {
      console.log(`Running: brew ${command}`);
      await runBrewCommand(command);
    }
  }
}

async function listDirectoryEntries(path: string): Promise<string[]> {
  try {
    const entries: string[] = [];
    entries.push(...await readdir(path));
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
      process.exit(1);
    }

    for (const target of AGENT_LINK_TARGETS) {
      if (!(await fileExists(target.dir))) {
        if (DRY_RUN) {
          console.log(`[DRY RUN] Would create directory: ${target.dir}`);
        } else {
          await mkdir(target.dir, { recursive: true });
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
      overwriteManaged: OVERWRITE_MANAGED,
      copyTargets: CODEX_TEMPLATE_COPY_TARGETS,
    });

    if (dryRun) {
      if (changed) {
        console.log("");
        console.log("Dry-run passed.");
        console.log("To apply changes, run: bun run codex:template --apply");
      } else {
        console.log("");
        console.log("Dry-run passed. No changes to apply.");
      }
    }
  },

  async "zsh:sheldon:sync"() {
    if (!(await fileExists(SHELDON_CONFIG_FILE))) {
      console.error(`ERROR: ${SHELDON_CONFIG_FILE} not found`);
      process.exit(1);
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

    await mkdir(SHELDON_CACHE_DIR, { recursive: true });
    for (const phase of SHELDON_PHASES) {
      console.log(`Running: sheldon lock (${phase.profile})`);
      await runSheldon(["lock"], phase.profile);
      console.log(`Generating sheldon source: ${phase.profile}`);
      const content = await runSheldon(["source"], phase.profile);
      const outputPath = `${SHELDON_CACHE_DIR}/${phase.filename}`;
      await writeFile(outputPath, content);
      await zcompileIfExists(outputPath);
    }
  },

  async "zsh:sheldon:update"() {
    if (!(await fileExists(SHELDON_CONFIG_FILE))) {
      console.error(`ERROR: ${SHELDON_CONFIG_FILE} not found`);
      process.exit(1);
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

    await mkdir(SHELDON_CACHE_DIR, { recursive: true });
    for (const phase of SHELDON_PHASES) {
      console.log(`Running: sheldon lock --update (${phase.profile})`);
      await runSheldon(["lock", "--update"], phase.profile);
      console.log(`Generating sheldon source: ${phase.profile}`);
      const content = await runSheldon(["source"], phase.profile);
      const outputPath = `${SHELDON_CACHE_DIR}/${phase.filename}`;
      await writeFile(outputPath, content);
      await zcompileIfExists(outputPath);
    }
  },

  async "brew:bundle"() {
    if (!(await fileExists("Brewfile"))) {
      console.error("ERROR: Brewfile not found");
      process.exit(1);
    }

    await runBrewCommands(await loadBrewCommands("Brewfile"));
  },

  async "brew:cask"() {
    if (!(await fileExists("Caskfile"))) {
      console.error("ERROR: Caskfile not found");
      process.exit(1);
    }

    await runBrewCommands(await loadBrewCommands("Caskfile"));
  },

  async "brew:update"() {
    await runBrewCommands(["update"]);
  },

  async "brew:upgrade"() {
    await runBrewCommands(["upgrade --formula", "upgrade --cask"]);
  },

  async "brew:cleanup"() {
    await runBrewCommands(["cleanup"]);
  },

  async "duti:apply"() {
    if (DRY_RUN) {
      console.log(`[DRY RUN] Would run: duti ${DUTI_CONFIG_FILE}`);
      return;
    }

    if (!(await fileExists(DUTI_CONFIG_FILE))) {
      console.error(`ERROR: ${DUTI_CONFIG_FILE} not found`);
      console.error("Run 'bun run dotfiles:install' before applying duti settings");
      process.exit(1);
    }

    await ensureCommandOnPath("duti");

    await $`duti ${DUTI_CONFIG_FILE}`;
    console.log(`Applied duti settings from ${DUTI_CONFIG_FILE}`);
  },

  async "mas:install"() {
    if (!(await fileExists("Masfile"))) {
      console.error("ERROR: Masfile not found");
      process.exit(1);
    }

    const masfile = await readLines("Masfile");
    const appIds = masfile
      .map((line) => {
        const parts = line.trim().split(/\s+/);
        return parts.length >= 2 ? parts[1] : null;
      })
      .filter((id): id is string => id !== null);

    // インストール済みのアプリを取得
    const installedList = (await $`mas list`.text()).trim().split("\n").filter(Boolean);
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
    console.log("    bun run dotfiles:install    - Install dotfiles symlinks");
    console.log(
      "    bun run agent:link          - Link Claude/Copilot skills to ~/.agents/skills",
    );
    console.log(
      "    bun run agent:codex-plugins - Install all configured Codex plugins",
    );
    console.log(
      "    bun run agent:claude-plugins - Install all configured Claude Code plugins",
    );
    console.log(
      "    bun run codex:template      - Dry-run apply codex template (use --apply to write)",
    );
    console.log("");
    console.log("  Zsh:");
    console.log("    bun run zsh:sheldon:sync    - Lock plugins and generate sheldon source cache");
    console.log("    bun run zsh:sheldon:update  - Update plugins and regenerate sheldon source cache");
    console.log("");
    console.log("  Homebrew:");
    console.log("    bun run brew:bundle         - Install Homebrew packages");
    console.log("    bun run brew:cask           - Install Homebrew Cask apps");
    console.log("    bun run brew:update         - Update Homebrew package metadata");
    console.log("    bun run brew:upgrade        - Upgrade installed formulae and casks");
    console.log("    bun run brew:cleanup        - Remove stale Homebrew versions and caches");
    console.log("    bun run duti:apply          - Apply default app handlers from ~/.duti");
    console.log("");
    console.log("  Mac App Store:");
    console.log("    bun run mas:install         - Install App Store apps");
    console.log("");
    console.log("Options:");
    console.log("    --dry-run                     - Show what would be done without making changes");
    console.log("    --apply                       - Execute codex:template write (default is dry-run)");
    console.log(
      "    --overwrite-managed           - Replace existing managed Codex settings after reviewing the diff",
    );
  },
};

if (import.meta.main) {
  // Check for --dry-run flag
  const args = [...process.argv.slice(2)];
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

  const overwriteManagedIndex = args.indexOf("--overwrite-managed");
  if (overwriteManagedIndex !== -1) {
    if (taskName !== "codex:template") {
      console.error("--overwrite-managed is only supported for codex:template");
      process.exit(1);
    }
    OVERWRITE_MANAGED = true;
    args.splice(overwriteManagedIndex, 1);
  }

  if (!taskName) {
    console.error("Usage: bun run <task-name>");
    console.error("Run 'bun run help' to see available tasks");
    process.exit(1);
  }

  const task = tasks[taskName];
  if (!task) {
    console.error(`Unknown task: ${taskName}`);
    console.error("Run 'bun run help' to see available tasks");
    process.exit(1);
  }

  try {
    await task();
  } catch (error) {
    if (error instanceof CodexTemplateApplyError) {
      console.error(formatCodexTemplateApplyError(error));
      process.exit(1);
    }

    console.error(`Task failed: ${taskName}`);
    console.error(error);
    process.exit(1);
  }
}
