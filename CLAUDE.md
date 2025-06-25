# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## リポジトリ概要

これは、Ruby の Rake ビルド自動化ツールを使用してシステム設定、開発ツール、アプリケーションを管理する macOS 向けの包括的な dotfiles リポジトリです。このリポジトリは、モダンな CLI ツールと洗練された Neovim セットアップを重視しています。

## 必須コマンド

### 初期セットアップ
```bash
rake dotfiles:install  # すべての設定ファイルのシンボリックリンクを作成
rake brew:bundle       # Brewfile からコマンドラインツールをインストール
rake brew:cask        # Caskfile から GUI アプリケーションをインストール
rake mas:install      # Masfile から Mac App Store アプリをインストール
rake gem:install      # GemGlobal から Ruby gem をインストール
rake pip:install      # PipGlobal から Python パッケージをインストール
rake npm:install      # NpmGlobal から Node.js パッケージをインストール
rake zsh:zinit:install # Zsh プラグインマネージャーをインストール
```

### コード品質コマンド
```bash
deno fmt              # Deno/TypeScript ファイルをフォーマット（行幅: 120）
stylua .              # Lua ファイルをフォーマット（2スペース、120カラム）
cspell "**/*"         # すべてのファイルでスペルチェック
```

### パッケージ管理
```bash
rake npm:upgrade      # すべてのグローバル Node.js パッケージをアップグレード
rake gem:uninstall    # デフォルト以外のすべての gem を削除
rake pip:uninstall    # すべての pip パッケージを削除
rake npm:uninstall    # グローバル node モジュールを削除
```

## アーキテクチャ概要

### Neovim 設定構造
`.vim/` ディレクトリには洗練された Neovim セットアップが含まれています：

- **プラグイン管理**: `lua/plugins/` にモジュール化された設定で lazy.nvim を使用
- **LSP セットアップ**: ネイティブ Neovim LSP と CoC.nvim のデュアルサポート（`LSP` 環境変数で制御）
- **言語サポート**: Deno vs Node.js プロジェクトを自動検出するスマートな TypeScript/JavaScript セットアップ
- **設定読み込み順序**:
  1. `init.lua` → プラグインマネージャーの初期化
  2. `rc/preload.lua` → 初期設定（リーダーキー）
  3. lazy.nvim によるプラグイン読み込み
  4. `rc/postload.lua` → 最終設定（カラースキーム）

### 主要な設定ファイル
- **パッケージリスト**: `Brewfile`, `Caskfile`, `GemGlobal`, `PipGlobal`, `NpmGlobal`, `Masfile`
- **ビルド自動化**: `Rakefile` - すべてのインストールと管理タスクを含む
- **Neovim プラグイン**: `.vim/lua/plugins/` - モジュール化されたプラグイン設定
- **LSP 設定**: `.vim/after/lsp/` - 言語固有の LSP 設定

### 開発フォーカスエリア
- TypeScript/JavaScript 開発への重点的な対応（Deno/Node.js/Bun）
- Neovim 設定用の Lua 開発サポート
- モダンな CLI ツールの置き換え（ripgrep、eza、fd、bat など）
- AI アシストコーディング（Copilot 統合、Claude Code 深い統合）
- 高度なテキスト操作と複数カーソルシミュレーション

## Claude Code 統合機能

### tmux 統合
このリポジトリは Claude Code との深い統合を提供します：

- **スマートペイン移動**: カーソル位置を考慮した知的なペイン選択（`bin/tmux-smart-switch-pane`）
- **使用状況モニタリング**: ステータスバーに Claude Code の使用状況を表示（`bin/tmux-status-ccusage`）
- **空プロンプト検出**: Claude Code の空プロンプトを自動検出して通知
- **Neovim 連携**: Neovim から tmux ペインへのシームレスな移動

### Karabiner 統合
Alacritty で Claude Code を使用する際の特殊なキーバインディング：

- `Command+Return` → `\Enter` に変換（Claude Code のプロンプト送信）
- `Command+[` → IME を自動無効化してから Escape を送信
- `Command+H` → `Command+Shift+H` に変換（tmux 統合）

### 関連スクリプト
`bin/` ディレクトリには以下の tmux/Claude Code 関連スクリプトがあります：

- `tmux-smart-switch-pane`: カーソル位置ベースのペイン移動
- `tmux-status-ccusage`: Claude Code 使用状況表示（Node.js）
- `tmux-git-branch`: Git ブランチ情報の表示
- `tmux-swap-pane`: ペインのマークとスワップ
- `tmux-statusline-sessions`: セッション情報の表示
- `tmux-pwd`: 現在のディレクトリ情報

## ツール管理

### mise（旧 rtx）
バージョン管理には mise を使用しています（`.config/mise/config.toml`）：

- Node.js、Deno、Python、Ruby などの言語ランタイム
- Bun の最新版インストール
- 各種開発ツールのバージョン固定

### パス設定
`.zshenv` で以下のツールパスが設定されています：

- `~/.bun/bin`: Bun JavaScript ランタイム
- `~/.deno/bin`: Deno ランタイム
- `~/.cargo/bin`: Rust ツールチェーン
- その他 mise 管理下のツール
