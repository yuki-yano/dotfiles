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
  ".finicky.js",
  ".gitattributes_global",
  ".gitconfig",
  ".gitignore_global",
  ".hammerspoon",
  ".tigrc",
  ".tmux.conf",
  ".vim",
  ".vimrc",
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
const ZINIT_DIR = `${HOME}/.zinit`;
const CLAUDE_DIR = `${SRC_DIR}/.config/claude`;
const AGENTS_SKILLS_DIR = `${HOME}/.agents/skills`;
const CLAUDE_SKILLS_DIR = `${CLAUDE_DIR}/skills`;
const CODEX_TEMPLATE_COPY_TARGETS = ["AGENTS.md", "agents"];

let DRY_RUN = false;
let APPLY = false;

async function readLines(filename: string): Promise<string[]> {
  const content = await Deno.readTextFile(filename);
  return content.split("\n").filter((line) => line && !line.startsWith("#"));
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

function promptYesNo(message: string): boolean {
  const answer = prompt(`${message} (y/N)`);
  return answer?.toLowerCase() === "y";
}

function validateBrewCommand(command: string): boolean {
  const allowedCommands = ["install", "tap", "cask"];
  const parts = command.trim().split(/\s+/);
  return parts.length > 0 && allowedCommands.includes(parts[0]);
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

  async "claude:link"() {
    if (!(await fileExists(AGENTS_SKILLS_DIR))) {
      console.error(`ERROR: ${AGENTS_SKILLS_DIR} does not exist`);
      Deno.exit(1);
    }

    if (!(await fileExists(CLAUDE_DIR))) {
      if (DRY_RUN) {
        console.log(`[DRY RUN] Would create directory: ${CLAUDE_DIR}`);
      } else {
        await Deno.mkdir(CLAUDE_DIR, { recursive: true });
      }
    }

    if (await fileExists(CLAUDE_SKILLS_DIR)) {
      if (!(await isSymlink(CLAUDE_SKILLS_DIR))) {
        console.error(`ERROR: ${CLAUDE_SKILLS_DIR} already exists and is not a symlink`);
        console.error("Move or back up it before linking");
        Deno.exit(1);
      }
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would link ${AGENTS_SKILLS_DIR} to ${CLAUDE_SKILLS_DIR}`);
    } else {
      await $`ln -sfn ${AGENTS_SKILLS_DIR} ${CLAUDE_SKILLS_DIR}`;
      console.log(`Linked ${CLAUDE_SKILLS_DIR} -> ${AGENTS_SKILLS_DIR}`);
    }
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

  async "zsh:zinit:install"() {
    if (await fileExists(ZINIT_DIR)) {
      console.error("Zinit directory already exists");
      Deno.exit(1);
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would create directory: ${ZINIT_DIR}`);
      console.log(`[DRY RUN] Would clone zinit to ${ZINIT_DIR}/bin`);
    } else {
      await Deno.mkdir(ZINIT_DIR);
      console.log(`>>> Downloading zinit to ${ZINIT_DIR}/bin`);
      await $`git clone --depth 10 https://github.com/zdharma-continuum/zinit.git ${ZINIT_DIR}/bin`;
      console.log(">>> Done");
    }
  },

  async "zsh:zinit:uninstall"() {
    if (!(await fileExists(ZINIT_DIR))) {
      console.error(`${ZINIT_DIR} does not exist`);
      Deno.exit(1);
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would remove directory: ${ZINIT_DIR}`);
    } else {
      await $`rm -rf ${ZINIT_DIR}`;
      console.log(`Remove directory ${ZINIT_DIR}`);
    }
  },

  async "brew:bundle"() {
    if (!(await fileExists("Brewfile"))) {
      console.error("ERROR: Brewfile not found");
      Deno.exit(1);
    }

    const commands = await readLines("Brewfile");
    for (const cmd of commands) {
      if (!validateBrewCommand(cmd)) {
        console.error(`ERROR: Invalid brew command: ${cmd}`);
        console.error("Only 'install', 'tap', and 'cask' commands are allowed");
        Deno.exit(1);
      }

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would run: brew ${cmd}`);
      } else {
        console.log(`Running: brew ${cmd}`);
        await $`brew ${cmd}`;
      }
    }
  },

  async "brew:cask"() {
    if (!(await fileExists("Caskfile"))) {
      console.error("ERROR: Caskfile not found");
      Deno.exit(1);
    }

    const commands = await readLines("Caskfile");
    for (const cmd of commands) {
      if (!validateBrewCommand(cmd)) {
        console.error(`ERROR: Invalid brew command: ${cmd}`);
        console.error("Only 'install', 'tap', and 'cask' commands are allowed");
        Deno.exit(1);
      }

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would run: brew ${cmd}`);
      } else {
        console.log(`Running: brew ${cmd}`);
        await $`brew ${cmd}`;
      }
    }
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
      "    deno task claude:link         - Link .config/claude/skills to ~/.agents/skills",
    );
    console.log(
      "    deno task codex:template      - Dry-run apply codex template (use -- --apply to write)",
    );
    console.log("");
    console.log("  Zsh:");
    console.log("    deno task zsh:zinit:install   - Install zinit plugin manager");
    console.log("    deno task zsh:zinit:uninstall - Uninstall zinit");
    console.log("");
    console.log("  Homebrew:");
    console.log("    deno task brew:bundle         - Install Homebrew packages");
    console.log("    deno task brew:cask           - Install Homebrew Cask apps");
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
