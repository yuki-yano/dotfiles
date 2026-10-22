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
- 📝 **Neovim power setup** – `.config/nvim/` contains a lazy.nvim-based Lua config, dual native LSP + CoC support,
  LuaSnip/tsnip snippets, transparency/theme toggles, and efm-langserver integration.
- 🧭 **tmux-first workflow** – prefix on `Ctrl-y`, smart pane routing for Neovim/Claude panes, tmux status extensions
  (battery, wifi, session context), and helper binaries under `bin/`.
- 🪟 **Desktop automation** – Shitsurae-managed window layouts/shortcuts, Karabiner IME helpers, and Finicky browser
  routing keep the keyboard and window workflow cohesive.
- 🤖 **AI-native tooling** – `.config/claude/settings.json` hooks, Warashi cage presets, and `vde-*` workflows keep
  Claude/Codex operations integrated with tmux and shell tooling.
- 📦 **Unified manifests** – `Brewfile`, `Caskfile`, `Masfile`, and `mise` runtime definitions document every CLI, GUI,
  and runtime dependency.
- 🧰 **Script library** – `bin/` hosts tmux automation, Shitsurae helpers, git utilities, quick IME toggles, and
  monitoring commands that the rest of the dotfiles rely on.

## Requirements

- macOS 13+ (Sonoma/Ventura tested) with administrator rights for Homebrew/MAS installs and Accessibility permissions
  for window/input automation apps.
- [Homebrew](https://brew.sh) with `brew` and `mas` available.
- [Bun](https://bun.com) ≥ 1.4.2 for running scripts and automation tasks.
- [Deno](https://deno.land) for denops plugins, zeno.zsh, and the Git prompt daemon.
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
bun install --frozen-lockfile

bun run brew:bundle
bun run brew:cask
bun run mas:install         # requires `mas signin`

# Link dotfiles (prompts before replacing non-symlinks)
bun run dotfiles:install
bun run agent:link
# agent:link replaces existing Claude/Copilot skill directories with symlinks to ~/.agents/skills.
# Run `bun run agent:link --dry-run` first when checking a new machine.
bun run agent:codex-plugins --dry-run
bun run agent:codex-plugins
bun run agent:claude-plugins --dry-run
bun run agent:claude-plugins
bun run zsh:sheldon:sync

bun run codex:template      # dry-run
bun run codex:template --apply

bun run help                # list all tasks
```

Put `~/dotfiles/bin` on your `PATH` (zsh does this automatically) so helper scripts such as `tmux-smart-switch-pane`,
`tmux-list-sessions`, `shitsurae-resize.ts`, `wifi`, and `battery` are available everywhere.

To inject startup context from your personal notes into Codex, set `AGENT_NOTE_DIR` to an existing directory and then
run `bun run codex:template --apply` so `~/.codex/hooks.json` is refreshed.

The Codex config template expands `{{CHATGPT_APP_VERSION}}` using `CFBundleShortVersionString` from
`/Applications/ChatGPT.app/Contents/Info.plist`. Both dry-run and apply verify that the matching
`~/.codex/plugins/cache/openai-bundled/browser/<version>/scripts/browser-service.mjs` exists before writing any files.
After updating ChatGPT, restart the app to initialize its bundled browser plugin before applying the template.

## Task Automation

`bun run help` prints all commands. Every task respects `--dry-run` (pass it after the script name),
and `tasks.ts` validates input before it shells out.

| Task                                                | Purpose                                                                                                                                                                                                                                                                       |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bun run dotfiles:install [--dry-run]`         | Symlinks the files listed in `DOTFILES_SRCS` to `$HOME`, warning if a non-symlink already exists.                                                                                                                                                                             |
| `bun run agent:link [--dry-run]`               | Replaces Claude (`~/.config/claude/skills` via the dotfiles-managed `.config`) and Copilot (`~/.copilot/skills`) skill targets with symlinks to `~/.agents/skills`. Dry-run reports existing entries that will stop being visible.                                            |
| `bun run agent:codex-plugins [--dry-run]`      | Ensures every Codex plugin declared in `CODEX_PLUGIN_DEFINITIONS` in `tasks.ts` is installed and enabled.                                                                                                                                                                     |
| `bun run agent:claude-plugins [--dry-run]`     | Ensures every Claude Code plugin declared in `CLAUDE_PLUGIN_DEFINITIONS` in `tasks.ts` is installed and matches its declared enabled state.                                                                                                                                   |
| `bun run codex:template [--apply]`             | Dry-run by default. Applies `.config/codex-template/config.toml` (managed section merge) and copy targets (`AGENTS.md`, `agents/**`, `hooks.json`) to `~/.codex` only with `--apply` (`template` has no markers; `~/.codex/config.toml` must contain marker block). |
| `bun run zsh:sheldon:sync` / `zsh:sheldon:update` | Generate the `sheldon` lock/cache for the `pre` and `post` shell phases under `~/.cache/sheldon`.                                                                                                                                                                             |
| `bun run brew:bundle`                             | Installs formulae and command-line tools declared in `Brewfile` without performing a global upgrade or cleanup.                                                                                                                                                              |
| `bun run brew:cask`                               | Installs GUI apps declared in `Caskfile` without performing a global upgrade or cleanup.                                                                                                                                                                                      |
| `bun run brew:update`                             | Updates Homebrew package metadata.                                                                                                                                                                                                                                            |
| `bun run brew:upgrade`                            | Upgrades installed formulae and casks.                                                                                                                                                                                                                                        |
| `bun run brew:cleanup`                            | Removes stale Homebrew versions and caches.                                                                                                                                                                                                                                   |
| `bun run duti:apply [--dry-run]`               | Applies default macOS file handlers from the dotfiles-managed `~/.duti` file.                                                                                                                                                                                                 |
| `bun run mas:install`                             | Installs missing Mac App Store apps using IDs from `Masfile`.                                                                                                                                                                                                                 |
| `bun run help`                                    | Prints grouped help text with descriptions of every task.                                                                                                                                                                                                                     |

This repository uses Bun package scripts as the single automation entrypoint (`bun run ...`).

## Repository Overview

- `package.json`, `tasks.ts` – automation entrypoints controlling symlinks, Codex template apply, Homebrew/MAS
  installations, and dry-run behavior.
- `Brewfile`, `Caskfile`, `Masfile` – declarative manifests for CLI formulae, casks, and App Store apps.
- `.envrc` – placeholder for direnv; add secrets or environment-specific exports locally.
- `.bashrc`, `.zshenv`, `.zprofile`, `.zshrc`, `.zsh/` – shell bootstrap; zsh is the primary shell, bash is still
  configured for sandboxed Homebrew calls.
- `.config/` – app-level configs for Alacritty, WezTerm (`quick-ime` 用), Atuin, Bat themes, cage presets, Claude tasks,
  efm-langserver, Karabiner, mise, Neovim, ripgrep, shitsurae, tabtab, VDE layouts, vivid color themes, and zeno
  snippets.
- `.config/nvim/` – Neovim/Lua configuration (lazy.nvim, rc modules, LuaSnip + tsnip, sessions, docs).
- `.tmux.conf`, `.tmux/` – tmux settings and related local assets.
- `.finicky.js`, `.config/shitsurae/config.yml`, `.config/karabiner/karabiner.json` – macOS automation suite (window
  layout/shortcuts, IME helpers, URL routing). `karabiner.json` is generated from `.config/karabiner/karabiner.ts` via
  Bun (`bun run karabiner:build` / `karabiner:watch`).
- `.ctags.d/config.ctags`, `.tigrc`, `.config/ripgrep/rc`, `.config/vivid/themes/catppuccin.yml` – CLI defaults for
  tags, tig, search, and colors.
- `.config/claude/{CLAUDE.md,settings.json}` and `.config/cage/presets.yml` – Claude Code settings and Warashi cage
  layouts that integrate AI tooling with tmux.
- `z-ai/` – repository-scoped AI working directory. Agent outputs are centralized here (for example: `z-ai/plans/`,
  `z-ai/tmp/`, and `z-ai/references/`), and the Neovim AI picker (`<Plug>(ff)i`) is scoped to `z-ai/`.
- `bin/` – helper scripts (tmux status widgets, git utilities like `git-quick-save`, tmux session manager, ghq selector,
  wifi/battery monitors, Claude hooks, Shitsurae resize helpers, quick IME toggles). Every script is intended to run
  from PATH.
- `stylua.toml` and `cspell.json` – formatting/spell-check rules for Lua and docs.
- `tasks.ts` uses Bun Shell and standard file APIs; `package.json` defines the task aliases.

## Shell & Terminal Stack

- **zsh + sheldon** – `.zshrc` bootstraps `sheldon`-generated `pre`/`post` source caches (Powerlevel10k prompt,
  zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, ni.zsh, handy snippets, local `zeno.zsh`). `fzf` is
  installed by Homebrew, and `.zshenv` / `.zprofile` keep PATH/runtime order sane for login shells.
- **Aliases & completions** – eza replaces `ls`, dust/lazygit replacements are wired, `~/.zsh/completions` and
  `.config/tabtab/zsh` host generated completions, and `~/.safe-chain` is sourced when available.
- **direnv & mise** – direnv loads project `.envrc` files; mise tools use shims without shell activation hooks.
  `.zshenv` preserves inherited absolute environment paths and removes inherited `mise/installs/` paths so shims can select
  the current repo's versions. Run `mise install` to sync tools, `mise exec -- <command>` to apply mise `[env]`,
  and `mise reshim` after adding executables with another package manager. `mise shell` and `mise deactivate`
  require activation and are not used in this setup. The old `~/.cache/zsh/profile/mise.zsh` activation cache is
  no longer used and should not be sourced.
- **Nix** – an existing multi-user installation is initialized explicitly because global zsh startup files are
  disabled. Only `/nix/var/nix/profiles/default/bin` joins the host PATH, after user tools and mise shims but before
  Homebrew. Inherited Nix user profile bins are removed; project environments provide their package paths.
  `.config/nix/nix.conf` enables `nix-command` and `flakes`. After installing Nix, run
  `nix profile add github:NixOS/nixpkgs/nixpkgs-unstable#nix-direnv` once.
  `.config/direnv/direnvrc` loads nix-direnv from that profile; Homebrew's direnv and modern Bash are already in `Brewfile`.
  Each Nix repo tracks its `.envrc`, `flake.nix`, and `flake.lock`, and ignores `.direnv/`.
  Review and run `direnv allow` in each new worktree, then check its runtime before starting Codex or Claude.
  Without an interactive prompt, launch with `direnv exec . codex` or `direnv exec . claude`.
  Approval does not change an already running Agent's environment; use `direnv exec . <command>` when it moves to a different environment.
  Run `bash tests/zsh_env_test.sh` to check inherited
  PATH handling, nested shells, and Nix initialization. Open a new terminal or pane after changing startup files;
  existing shells retain their loaded hooks.
- **Shell history & snippets** – `.config/atuin/config.toml` tunes Atuin (fuzzy search with previews).
  `.config/zeno/config.yml` defines CLI snippets (git helpers, tmux commands, redirection shorthands).
- **Color & search defaults** – `ripgrep`, `vivid`, and `bat` configs standardize palette and output.
- **Terminals** – `.config/alacritty/*.toml` is the primary terminal setup and carries the day-to-day key bindings,
  colors, and IME-friendly behavior. `.config/wezterm/wezterm.lua` is currently maintained for the narrow `quick-ime`
  workflow: spawning a centered temporary window that attaches to an isolated tmux-backed Neovim session. Alacritty maps
  `Command+1` through `Command+9` to tmux-friendly escape sequences for direct session switching. The `quick-ime.sh`
  script plus `quick-ime.toml` defines instant Japanese/English toggles that interact with Karabiner rules.

## Editor & LSP

- `.config/nvim/init.lua` flips on `vim.loader`, sets `vim.env.LSP` (`nvim` or `coc`), toggles transparency/colours via
  env vars, and calls the Lua module loader under `rc/`.
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
  bindings, uses mouse mode, and keeps clipboard actions wired through `pbcopy` / `pbpaste`.
- Smart pane navigation uses helper scripts (`bin/tmux-smart-switch-pane`) and process detection to seamlessly move
  between Neovim, Claude panes, zsh shells, or fzf prompts.
- Key bindings trigger scripts: `M-r` launches `vtm session-manager`, `M-t` runs `ghq-project-selector.zsh`, `M-u`
  toggles transparent panes, `M-i` opens `editprompt`, `M-h` / `M-l` cycle sessions inside the current `vtm` category,
  `Option+Control+1` / `2` / `3` switch `private` / `public` / `work`, and `M-1` through `M-9` switch to the
  corresponding tmux session entry inside the current category.
- Status line widgets call binaries in `bin/` and external tools: `tmux-list-sessions`, `tmux-pwd`, `wifi`, `battery`,
  plus `vtm statusline-category` / `vtm statusline-sessions` render the current category and session list.

## Window & Input Automation

- **Shitsurae** – `.config/shitsurae/config.yml` defines the default multi-space layout, thumbnail overlay cycle mode,
  and `cmd+ctrl` global actions for common floating placements (`1`/`2`/`3`, `h`, `l`, `f`). The current layout seeds
  browser/chat/terminal spaces and replaces the previous `yabai`/`skhd` window-management layer.
- **Karabiner-Elements** – `.config/karabiner/karabiner.json` is tuned for Alacritty/Claude workflows:
  Command/Shift+Return becomes backslash+Enter, IME toggles are inserted around shortcuts, and delayed actions ensure
  Japanese/English mode toggles fire correctly. Edit `.config/karabiner/karabiner.ts` and run
  `bun run karabiner:build` to apply (or `karabiner:watch` to auto-rebuild).
- **Finicky** – `.finicky.js` routes specific sites (TypeScript docs, Google Docs) to Chrome while Firefox stays
  default.
- **Quick IME helpers** – `bin/quick-ime.sh` uses a dedicated WezTerm window as a temporary IME editor, captures the
  previously focused window via `shitsurae window current --json`, and restores focus by window ID or bundle ID when the
  isolated tmux-backed editor detaches. Karabiner rules keep text entry stable.

## AI & Workflow Tooling

- `.config/claude/` stores Claude settings in-repo (`CLAUDE.md`, `settings.json`), while Claude runtime state
  (history/snapshots/cache) is managed locally on each machine. Repository-scoped agent artifacts are managed under
  `z-ai/` (`z-ai/plans/`, `z-ai/tmp/`, `z-ai/references/`).
- Codex plugins are declared once in `CODEX_PLUGIN_DEFINITIONS` in `tasks.ts`. `bun run agent:codex-plugins` installs
  every declared Codex marketplace/plugin pair in one command; individual Codex plugin tasks are not kept.
- Claude Code plugins and their desired enabled state are declared once in `CLAUDE_PLUGIN_DEFINITIONS` in `tasks.ts`.
  `bun run agent:claude-plugins` reconciles every declared Claude marketplace/plugin pair in one command; individual
  Claude plugin tasks are not kept.
- Ponytail is installed as a full plugin for both Codex and Claude Code, using its default `full` level. After installing
  it in Codex, review and trust its hooks in `/hooks`, then start a new thread (restart the desktop app when using it).
  Start a new Claude Code session to run its startup hook. Plugin hooks stay in the plugin; do not copy them into the
  dotfiles hook settings. The Codex AGENTS template contains the Japanese output, audit scope, and verification rules;
  Claude's `CLAUDE.md` imports that same file. `ponytail-audit` and `ponytail-review` replace the local `improve` skill;
  implementation handoffs and acceptance checks remain with `agent-handoff-plan` and `agent-review-request`.
- RTK and context-mode are no longer wired in: the `rtk hook claude` Bash hook, `RTK.md` instruction files, the
  context-mode plugin entries, and the context-mode SessionStart cache-heal hook were removed after a log-based
  cost/benefit review. The installed plugin/marketplace state is kept disabled (`context-mode@context-mode: false`)
  so the setup can be re-enabled if the experiment is reverted.
- `.config/cage/presets.yml` captures Warashi cage (multi-agent) layout presets that pair with tmux automation.
- `.config/claude/settings.json` hooks (`vde-monitor-hook`, `vde-monitor-summary`, `vde-notifier`) provide monitoring
  and notifications around Claude sessions.
- `mise` installs AI CLIs (`@anthropic-ai/claude-code`, `@google/gemini-cli`, `@openai/codex`, `editprompt`,
  `@aikidosec/safe-chain`, `sdd-mcp`, `vde-layout`, `vde-notifier`) so they can be invoked anywhere.
- The package manifests install desktop-side agent tooling such as Claude Code, Warashi `cage`, `shitsurae`, and
  `vde-notifier-app`, alongside the CLI helpers used by the shell and tmux workflow.

## Package Definitions

- **`Brewfile`** – grouped formulae for shell/session tooling, modern CLI utilities, language runtimes, build helpers,
  Git/review tools, cloud/container commands, local data tools, desktop capture helpers, notifications, and fonts.
  Commands are constrained to `install/tap/cask/update/upgrade/cleanup` for safety, while global maintenance is kept in
  explicit Bun tasks.
- **`Caskfile`** – GUI and desktop casks including 1Password, 1Password CLI, Claude Code, CleanShot, Draw.io, Finicky,
  Firefox, Google Chrome, Karabiner-Elements, Obsidian, TablePlus, Visual Studio Code, VLC, Zoom, and local workflow
  apps such as Warashi `cage`, `arto`, `shitsurae`, and `vde-notifier-app`.
- **`Masfile`** – Mac App Store IDs for CotEditor, Spark, Transmit, Evernote, DaisyDisk, PopClip, Yoink, LINE,
  Unclutter, Slack, Paste, and Fantastical, plus a commented history of previous installs.
- **`package.json` / `bun.lock`** – define Bun task aliases and pin the script dependencies.
- **`deno.json`** – retains settings and imports for the Deno-based Git prompt daemon and its tests.
- **`stylua.toml` & `cspell.json`** – keep Lua and documentation formatting consistent before committing changes.

## Validation & Maintenance

- **Dry runs first** – append `--dry-run` when testing `dotfiles:install`, `brew:*`, or other tasks to confirm the
  plan before touching the real system.
- **Non-interactive Homebrew** – Homebrew tasks pass `HOMEBREW_NO_ASK=1` directly so they also work before
  `dotfiles:install`; `.config/homebrew/brew.env` applies the same behavior to manual `brew` commands. macOS
  administrator-password and app-permission prompts remain interactive.
- **Formatters** – run `deno fmt tasks.ts`, `stylua --config-path stylua.toml .config/nvim` (or target specific Lua
  files), and `cspell lint README.md` to keep tooling happy.
- **Runtime sync** – `mise doctor` reveals missing runtimes defined in `.config/mise/config.toml`; re-run `mise install`
  after manifest changes.
- **Package refresh** – periodically run `bun run brew:update`, `bun run brew:upgrade`, and
  `bun run brew:cleanup`. Use `brew:bundle` and `brew:cask` to install newly declared packages, and review `Masfile`
  when App Store apps are added or removed.
- **Local overrides** – place host-specific adjustments in `.gitconfig.local`, `.tmux.conf.local`, or `~/.zshrc.local`
  (sourced from the main configs) to keep git history clean.
- **App permissions** – `shitsurae` and Karabiner depend on macOS Accessibility permissions; re-authorize them after OS
  upgrades.


### Bun scripts

Run `bun install --frozen-lockfile` after cloning or updating dependencies.
`bun run test` checks the migrated scripts; `bun run typecheck` checks TypeScript.
`bun run karabiner:build --dry-run` renders the rules without updating the active profile.

`bun run bundle` writes standalone JavaScript files, including imported libraries, under
`dist/scripts/`. Run them with Bun, for example `bun dist/scripts/tasks.js help`.
The source files remain the normal entrypoints; generated files are ignored by Git.
To include the Bun runtime in an executable as well, use
`bun build tasks.ts --compile --outfile /tmp/dotfiles-tasks`.

## License

MIT

## Author

Yuki Yano ([@yuki-yano](https://github.com/yuki-yano))
