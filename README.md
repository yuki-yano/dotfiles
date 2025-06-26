# Yuki Yano's dotfiles

A comprehensive dotfiles repository for macOS featuring Deno task runner automation, modern CLI tools, and a sophisticated Neovim setup.

## Features

- 🦕 **Deno/TypeScript Based**: Type-safe and security-focused task runner
- 🔒 **Security First**: Limited permissions and whitelist-based command execution
- 🚀 **Modern Development Environment**: Neovim, tmux, and cutting-edge CLI tools
- 🤖 **AI Integration**: Deep integration with Claude Code (tmux, Karabiner)
- 📦 **Unified Package Management**: Centralized management of Homebrew, yarn, and Mac App Store apps

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yuki-yano/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Initial setup
deno task dotfiles:install  # Create dotfiles symlinks
deno task brew:bundle       # Install CLI tools
deno task brew:cask         # Install GUI applications
deno task npm:install       # Install Node.js packages
```

## Key Components

### Neovim Configuration

- **Plugin Management**: Modular configuration with lazy.nvim
- **LSP Support**: Dual support for native LSP and CoC.nvim
- **Language Support**: TypeScript/JavaScript (auto-detection of Deno/Node.js), Lua, and many more

### tmux Configuration

- Custom key bindings (prefix: `Ctrl+y`)
- Claude Code integration (usage display, smart pane switching)
- Customized status bar

### Deno Tasks

Check available tasks:

```bash
deno task help
```

Main tasks:
- `dotfiles:install` - Install dotfiles
- `brew:bundle/cask` - Manage Homebrew packages
- `npm:install/upgrade` - Manage Node.js packages
- `zsh:zinit:install` - Manage Zsh plugins

## Directory Structure

```
.
├── .config/         # Application configurations
├── .vim/            # Neovim configuration
├── bin/             # Custom scripts
├── ai/              # AI-assisted work documentation
├── deno.json        # Deno task definitions
├── tasks.ts         # Task runner implementation
├── Brewfile         # Homebrew package list
├── Caskfile         # GUI application list
├── NpmGlobal        # Node.js global packages
└── Masfile          # Mac App Store app list
```

## Development

### Security

- Safe execution with Deno's permission model
- Whitelist validation for brew commands
- User confirmation for file operations

## License

MIT

## Author

Yuki Yano ([@yuki-yano](https://github.com/yuki-yano))
