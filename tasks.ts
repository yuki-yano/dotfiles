#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

import { $ } from "@david/dax";

// 設定
const DOTFILES_SRCS = [
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
];

const SRC_DIR = Deno.cwd();
const HOME = Deno.env.get("HOME");
if (!HOME) {
  console.error("ERROR: HOME environment variable is not set");
  Deno.exit(1);
}
const ZINIT_DIR = `${HOME}/.zinit`;

// グローバル設定
let DRY_RUN = false;

// ユーティリティ関数
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

async function getBrewPrefix(): Promise<string> {
  try {
    const prefix = await $`brew --prefix`.text();
    return prefix.trim();
  } catch {
    // Fallback for common paths
    if (await fileExists("/opt/homebrew/bin/brew")) {
      return "/opt/homebrew";
    }
    return "/usr/local";
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

  async "tmux:install"() {
    const terminfoPath = ".tmux/tmux-256color.terminfo";

    if (!(await fileExists(terminfoPath))) {
      console.error(`ERROR: ${terminfoPath} not found`);
      Deno.exit(1);
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would install terminfo from ${terminfoPath}`);
    } else {
      await $`tic -x ${terminfoPath}`;
      console.log("tmux terminfo installed");
    }
  },

  async "npm:install"() {
    if (!(await fileExists("NpmGlobal"))) {
      console.error("ERROR: NpmGlobal file not found");
      Deno.exit(1);
    }

    const packages = await readLines("NpmGlobal");
    if (packages.length === 0) {
      console.log("No packages to install");
      return;
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would install: ${packages.join(", ")}`);
    } else {
      await $`yarn global add ${packages.join(" ")}`.printCommand();
    }
  },

  async "npm:uninstall"() {
    const globalDir = await $`yarn global dir`.text();
    const dirPath = globalDir.trim();

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would remove: ${dirPath}`);
    } else {
      await $`rm -rf ${dirPath}`;
      console.log("Global node modules removed");
    }
  },

  async "npm:upgrade"() {
    if (DRY_RUN) {
      console.log("[DRY RUN] Would run: yarn global upgrade");
    } else {
      await $`yarn global upgrade`.printCommand();
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

  async "coteditor:install"() {
    const brewPrefix = await getBrewPrefix();
    const cotPath = "/Applications/CotEditor.app/Contents/SharedSupport/bin/cot";
    const destPath = `${brewPrefix}/bin/cot`;

    if (!(await fileExists(cotPath))) {
      console.error("ERROR: CotEditor.app not found");
      Deno.exit(1);
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would link ${cotPath} to ${destPath}`);
    } else {
      await $`ln -sfn ${cotPath} ${destPath}`;
      console.log("CotEditor command line tool installed");
    }
  },

  async "coteditor:uninstall"() {
    const brewPrefix = await getBrewPrefix();
    const destPath = `${brewPrefix}/bin/cot`;

    if (!(await fileExists(destPath))) {
      console.log("CotEditor command line tool not found");
      return;
    }

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would remove ${destPath}`);
    } else {
      await $`rm ${destPath}`;
      console.log("CotEditor command line tool removed");
    }
  },

  help() {
    console.log("Available tasks:");
    console.log("");
    console.log("  Dotfiles:");
    console.log("    deno task dotfiles:install    - Install dotfiles symlinks");
    console.log("");
    console.log("  Zsh:");
    console.log("    deno task zsh:zinit:install   - Install zinit plugin manager");
    console.log("    deno task zsh:zinit:uninstall - Uninstall zinit");
    console.log("");
    console.log("  tmux:");
    console.log("    deno task tmux:install        - Install tmux terminfo");
    console.log("");
    console.log("  Node.js:");
    console.log("    deno task npm:install         - Install global npm packages");
    console.log("    deno task npm:uninstall       - Remove all global packages");
    console.log("    deno task npm:upgrade         - Upgrade global packages");
    console.log("");
    console.log("  Homebrew:");
    console.log("    deno task brew:bundle         - Install Homebrew packages");
    console.log("    deno task brew:cask           - Install Homebrew Cask apps");
    console.log("");
    console.log("  Mac App Store:");
    console.log("    deno task mas:install         - Install App Store apps");
    console.log("");
    console.log("  CotEditor:");
    console.log("    deno task coteditor:install   - Install command line tool");
    console.log("    deno task coteditor:uninstall - Remove command line tool");
    console.log("");
    console.log("Options:");
    console.log("    --dry-run                     - Show what would be done without making changes");
  },
};

// メイン処理
if (import.meta.main) {
  // Check for --dry-run flag
  const args = [...Deno.args];
  const dryRunIndex = args.indexOf("--dry-run");
  if (dryRunIndex !== -1) {
    DRY_RUN = true;
    args.splice(dryRunIndex, 1);
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
    console.error(`Task failed: ${taskName}`);
    console.error(error);
    Deno.exit(1);
  }
}
