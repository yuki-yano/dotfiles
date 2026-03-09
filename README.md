# Yuki Yano's dotfiles

Modern macOS dotfiles that combine a Deno-powered automation layer, a deeply customized terminal/editor stack, extensive
desktop automation, and AI-first tooling for day-to-day development.

## Table of Contents

- [Highlights](#highlights)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Task Automation](#task-automation)
- [Repository Overview](#repository-overview)
- [Shell & Terminal Stack](#shell--terminal-stack)
- [Editor & LSP](#editor--lsp)
- [tmux & Session Tools](#tmux--session-tools)
- [Window & Input Automation](#window--input-automation)
- [AI & Workflow Tooling](#ai--workflow-tooling)
- [Package Definitions](#package-definitions)
- [Validation & Maintenance](#validation--maintenance)
- [License](#license)
- [Author](#author)

## Highlights

- 🦕 **TypeScript + Deno automation** – `deno.json` tasks call `tasks.ts`, which runs with explicit `--allow-*`
  permissions, validates Homebrew commands, and offers a `--dry-run` mode before touching system files.
- 🔒 **Security-first bootstrapping** – `.bashrc` pre-sets `HOMEBREW_PATH` for sandboxed agent environments, macOS
  keychain tools (`op`, `mas`) are isolated under `.config`, and destructive operations prompt for confirmation.
- 🖥️ **Modern terminal stack** – zsh with sheldon, Atuin, Zeno, direnv, mise, and an Alacritty-first setup tuned to
  Catppuccin aesthetics and Japanese/English IME-friendly shortcuts, with WezTerm reserved for the quick-ime flow.
- 📝 **Neovim power setup** – `.vim/` contains a lazy.nvim-based Lua config, dual native LSP + CoC support,
  LuaSnip/tsnip snippets, transparency/theme toggles, and efm-langserver integration.
- 🧭 **tmux-first workflow** – prefix on `Ctrl-y`, smart pane routing for Neovim/Claude panes, tmux status extensions
  (battery, wifi, Claude usage), and helper binaries under `bin/`.
- 🪟 **Desktop automation** – Shitsurae-managed window layouts/shortcuts, Karabiner IME helpers, and Finicky browser
  routing keep the keyboard and window workflow cohesive.
- 🤖 **AI-native tooling** – `.config/claude/settings.json` hooks, cage/ccusage helpers, and `vde-*` workflows keep
  Claude/Codex operations integrated with tmux and shell tooling.
- 📦 **Unified manifests** – `Brewfile`, `Caskfile`, `Masfile`, and `mise` runtime definitions document every CLI, GUI,
  and runtime dependency.
- 🧰 **Script library** – `bin/` hosts tmux automation, Shitsurae helpers, git utilities, quick IME toggles, and
  monitoring commands that the rest of the dotfiles rely on.

## Requirements

- macOS 13+ (Sonoma/Ventura tested) with administrator rights for Homebrew/MAS installs and Accessibility permissions
  for window/input automation apps.
- [Homebrew](https://brew.sh) with `brew` and `mas` available.
- [Deno](https://deno.land) ≥ 1.42 for running `deno task`.
- Node.js + yarn (managed via [`mise`](https://github.com/jdx/mise) in `.config/mise/config.toml`).
- Mac App Store sign-in (`mas signin`) if you plan to run `mas:install`.
- Optional but recommended: [direnv](https://direnv.net) to auto-load `.envrc`, `mise` to sync language runtimes,
  Alacritty, WezTerm for `quick-ime`, and 1Password CLI (`op`) for secrets-backed commands.

## Quick Start

```bash
git clone https://github.com/yuki-yano/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Optional: trust direnv + sync runtimes
direnv allow .
mise install

# Install runtimes & tools
deno task brew:bundle
deno task brew:cask
deno task mas:install         # requires `mas signin`

# Link dotfiles (prompts before replacing non-symlinks)
deno task dotfiles:install
deno task zsh:sheldon:sync

deno task codex:template      # dry-run
deno task codex:template -- --apply

deno task help                # list all tasks
```

Put `~/dotfiles/bin` on your `PATH` (zsh does this automatically) so helper scripts such as `tmux-smart-switch-pane`,
`tmux-list-sessions`, `shitsurae-resize.ts`, `wifi`, and `battery` are available everywhere.

## Task Automation

`deno task help` prints all commands. Every task respects `--dry-run` (pass it after `--` so Deno forwards the flag),
and `tasks.ts` validates input before it shells out.

| Task                                                  | Purpose                                                                                                                                                                                       |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deno task dotfiles:install [-- --dry-run]`           | Symlinks the files listed in `DOTFILES_SRCS` to `$HOME`, warning if a non-symlink already exists.                                                                                             |
| `deno task codex:template [-- --apply]`               | Dry-run by default. Applies `.config/codex-template/config.toml` (managed section merge) and copy targets (`AGENTS.md`, `agents/**`) to `~/.codex` only with `--apply` (`template` has no markers; `~/.codex/config.toml` must contain marker block). |
| `deno task zsh:sheldon:sync` / `zsh:sheldon:update`   | Generate the `sheldon` lock/cache for the `pre` and `post` shell phases under `~/.cache/sheldon`.                                                                                            |
| `deno task brew:bundle`                               | Executes curated commands in `Brewfile`, allowing only `install`, `tap`, `cask`, `update`, `upgrade`, and `cleanup`.                                                                         |
| `deno task brew:cask`                                 | Installs GUI apps from `Caskfile`.                                                                                                                                                            |
| `deno task mas:install`                               | Installs missing Mac App Store apps using IDs from `Masfile`.                                                                                                                                 |
| `deno task help`                                      | Prints grouped help text with descriptions of every task.                                                                                                                                     |

This repository uses Deno tasks as the single automation entrypoint (`deno task ...`).

## Repository Overview

- `deno.json`, `tasks.ts` – automation entrypoints controlling symlinks, Codex template apply, Homebrew/MAS
  installations, and dry-run behavior.
- `Brewfile`, `Caskfile`, `Masfile` – declarative manifests for CLI formulae, casks, and App Store apps.
- `.envrc` – placeholder for direnv; add secrets or environment-specific exports locally.
- `.bashrc`, `.zshenv`, `.zprofile`, `.zshrc`, `.zsh/` – shell bootstrap; zsh is the primary shell, bash is still
  configured for sandboxed Homebrew calls.
- `.config/` – app-level configs for Alacritty, WezTerm (`quick-ime` 用), Atuin, Bat themes, cage presets, Claude
  tasks, efm-langserver, Karabiner, mise, Neovim, ripgrep, shitsurae, tabtab, VDE layouts, vivid color themes, and
  zeno snippets.
- `.vim/`, `.vimrc` – Neovim/Lua configuration (lazy.nvim, rc modules, LuaSnip + tsnip, sessions, docs) synced with
  `.config/nvim` runtime files.
- `.tmux.conf`, `.tmux/` – tmux settings and related local assets.
- `.finicky.js`, `.config/shitsurae/config.yml`, `.config/karabiner/karabiner.json` – macOS automation suite (window
  layout/shortcuts, IME helpers, URL routing). `karabiner.json` is generated from
  `.config/karabiner/karabiner.ts` via Deno (`deno task karabiner:build` / `karabiner:watch`).
- `.ctags.d/config.ctags`, `.tigrc`, `.config/ripgrep/rc`, `.config/vivid/themes/catppuccin.yml` – CLI defaults for
  tags, tig, search, and colors.
- `.config/claude/{CLAUDE.md,settings.json}` and `.config/cage/presets.yml` – Claude Code settings and Warashi cage
  layouts that integrate AI tooling with tmux.
- `z-ai/` – repository-scoped AI working directory. Agent outputs are centralized here (for example:
  `z-ai/plans/`, `z-ai/tmp/`, and `z-ai/references/`), and the Neovim AI picker (`<Plug>(ff)i`) is scoped to `z-ai/`.
- `bin/` – helper scripts (tmux status widgets, git utilities like `git-quick-save`, tmux session manager, ghq selector,
  wifi/battery monitors, Claude hooks, Shitsurae resize helpers, quick IME toggles). Every script is intended to run
  from PATH.
- `stylua.toml` and `cspell.json` – formatting/spell-check rules for Lua and docs.
- `deno.json` imports `@david/dax` for ergonomic shelling inside TypeScript tasks.

## Shell & Terminal Stack

- **zsh + sheldon** – `.zshrc` bootstraps `sheldon`-generated `pre`/`post` source caches (Powerlevel10k prompt,
  zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, ni.zsh, handy snippets, local `zeno.zsh`). `fzf` is
  installed by Homebrew, and `.zshenv` / `.zprofile` keep PATH/runtime order sane for login shells.
- **Aliases & completions** – eza replaces `ls`, dust/lazygit replacements are wired, `~/.zsh/completions` and
  `.config/tabtab/zsh` host generated completions, and `~/.safe-chain` is sourced when available.
- **direnv & mise** – `.envrc` and `.config/mise/config.toml` manage per-project env vars plus runtime installs (`bun`,
  `node`, `python`, `uv`, AI CLI packages such as `@anthropic-ai/claude-code`, `@google/gemini-cli`, `sdd-mcp`,
  `safe-chain`, `vde-*`). Run `mise install` after cloning to sync tool versions.
- **Shell history & snippets** – `.config/atuin/config.toml` tunes Atuin (fuzzy search with previews).
  `.config/zeno/config.yml` defines CLI snippets (git helpers, tmux commands, redirection shorthands).
- **Color & search defaults** – `ripgrep`, `vivid`, and `bat` configs standardize palette and output.
- **Terminals** – `.config/alacritty/*.toml` is the primary terminal setup and carries the day-to-day key bindings,
  colors, and IME-friendly behavior. `.config/wezterm/wezterm.lua` is currently maintained for the narrow `quick-ime`
  workflow: spawning a centered temporary window that attaches to an isolated tmux-backed Neovim session. Alacritty
  maps `Command+1` through `Command+9` to tmux-friendly escape sequences for direct session switching. The
  `quick-ime.sh` script plus `quick-ime.toml` defines instant Japanese/English toggles that interact with Karabiner
  rules.

## Editor & LSP

- `.vim/init.lua` flips on `vim.loader`, sets `vim.env.LSP` (`nvim` or `coc`), toggles transparency/colours via env
  vars, and calls the Lua module loader under `rc/`.
- `rc/modules/plugin_manager` wires lazy.nvim; plugin configs live in `lua/plugins`, `lua/rc/setup`, `lua/rc/modules`,
  etc.
- `lua/` hosts UI, options, keymaps, highlight, ext UI, glancing statusline, session helpers, etc.
- `coc-settings.json`, `lua/rc/*` provide dual LSP support (native `nvim-lspconfig` + `coc.nvim`) with TypeScript/Deno
  auto-detection, Lua tooling, markdown preview, grammar/lint integrations, and snippet engines (LuaSnip, tsnip,
  UltiSnips compatibility).
- `efm-langserver/config.yaml` defines external formatter/diagnostic commands, aligning with `Brewfile` packages.
- `stylua.toml` configures Lua formatting and is used by CI or `stylua` local runs.
- Spell checking is centralized in `cspell.json` so long AI/Neovim words stay whitelisted.

## tmux & Session Tools

- `.tmux.conf` moves the prefix to `Ctrl-y`, sets `default-terminal` to `tmux-256color`, configures vi-style copy-mode
  bindings, uses mouse mode, and integrates with `reattach-to-user-namespace` for clipboard access.
- Smart pane navigation uses helper scripts (`bin/tmux-smart-switch-pane`) and process detection to seamlessly move
  between Neovim, Claude panes, zsh shells, or fzf prompts.
- Key bindings trigger scripts: `M-r` launches `bunx --bun vtm session-manager`, `M-t` runs `ghq-project-selector.zsh`,
  `M-u` toggles transparent panes, `M-i` opens `editprompt`, `M-c` spawns cwd windows, and `M-1` through `M-9`
  switch to the corresponding tmux session entry.
- Status line widgets call binaries in `bin/` and external tools: `tmux-list-sessions`, `tmux-status-ccusage`,
  `tmux-pwd`, `wifi`, `battery`, plus `tmux-auto-rename-session` keeps session names fresh.

## Window & Input Automation

- **Shitsurae** – `.config/shitsurae/config.yml` defines the default multi-space layout, thumbnail overlay cycle mode,
  and `cmd+ctrl` global actions for common floating placements (`1`/`2`/`3`, `h`, `l`, `f`). The current layout seeds
  browser/chat/terminal spaces and replaces the previous `yabai`/`skhd` window-management layer.
- **Karabiner-Elements** – `.config/karabiner/karabiner.json` is tuned for Alacritty/Claude workflows:
  Command/Shift+Return becomes backslash+Enter, IME toggles are inserted around shortcuts, and delayed actions ensure
  Japanese/English mode toggles fire correctly. Edit `.config/karabiner/karabiner.ts` and run
  `deno task karabiner:build` to apply (or `karabiner:watch` to auto-rebuild).
- **Finicky** – `.finicky.js` routes specific sites (TypeScript docs, Google Docs) to Chrome while Firefox stays
  default.
- **Quick IME helpers** – `bin/quick-ime.sh` uses a dedicated WezTerm window as a temporary IME editor, captures the
  previously focused window via `shitsurae window current --json`, and restores focus by window ID or bundle ID when
  the isolated tmux-backed editor detaches. Karabiner rules keep text entry stable.

## AI & Workflow Tooling

- `.config/claude/` stores Claude settings in-repo (`CLAUDE.md`, `settings.json`), while Claude runtime state
  (history/snapshots/cache) is managed locally on each machine. Repository-scoped agent artifacts are managed under
  `z-ai/` (`z-ai/plans/`, `z-ai/tmp/`, `z-ai/references/`).
- `.config/cage/presets.yml` captures Warashi cage (multi-agent) layout presets that pair with tmux automation.
- `.config/claude/settings.json` hooks (`vde-monitor-hook`, `vde-monitor-summary`, `vde-notifier`) provide monitoring and
  notifications around Claude sessions.
- `mise` installs AI CLIs (`@anthropic-ai/claude-code`, `@google/gemini-cli`, `@openai/codex`, `editprompt`,
  `@aikidosec/safe-chain`, `sdd-mcp`, `vde-layout`, `vde-notifier`) so they can be invoked anywhere.
- `Brewfile` includes `claude-code`, `ccusage`, and the Warashi `cage` cask to round out the local agent suite.

## Package Definitions

- **`Brewfile`** – grouped installs (shells, editors, languages, container tooling, services/CLIs, fonts, AI helpers,
  display tooling, ntfy). Commands are constrained to `install/tap/cask/update/upgrade/cleanup` for safety.
- **`Caskfile`** – GUI apps (1Password CLI, Bartender, Claude Code, CleanShot, Default Folder X, Docker,
  browsers, JetBrains Toolbox, Karabiner, Keka, OBS, TablePlus, `shitsurae`, etc.) alongside the notifier app casks
  used by the local agent workflow.
- **`Masfile`** – Mac App Store IDs for CotEditor, Bear, Spark, MenubarX, Transmit, Evernote, DaisyDisk, PopClip, Yoink,
  Sip, Due, LINE, Unclutter, Slack, Paste, Fantastical, plus a commented history of previous installs.
- **`deno.json`** – defines every task alias and pins `@david/dax` for shell helpers; run `deno fmt` or `deno task help`
  for ergonomics.
- **`stylua.toml` & `cspell.json`** – keep Lua and documentation formatting consistent before committing changes.

## Validation & Maintenance

- **Dry runs first** – append `-- --dry-run` when testing `dotfiles:install`, `brew:*`, or other tasks to confirm the
  plan before touching the real system.
- **Formatters** – run `deno fmt tasks.ts`, `stylua --config-path stylua.toml .vim` (or target specific Lua files), and
  `cspell lint README.md` to keep tooling happy.
- **Runtime sync** – `mise doctor` reveals missing runtimes defined in `.config/mise/config.toml`; re-run `mise install`
  after manifest changes.
- **Package refresh** – periodically `deno task brew:bundle`, `brew update && brew upgrade`, and review `Masfile` when
  new apps are added or removed.
- **Local overrides** – place host-specific adjustments in `.gitconfig.local`, `.tmux.conf.local`, or `~/.zshrc.local`
  (sourced from the main configs) to keep git history clean.
- **App permissions** – `shitsurae` and Karabiner depend on macOS Accessibility permissions; re-authorize them after OS
  upgrades.

## License

MIT

## Author

Yuki Yano ([@yuki-yano](https://github.com/yuki-yano))
