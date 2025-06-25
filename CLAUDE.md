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
- TypeScript/JavaScript 開発への重点的な対応（Deno/Node.js）
- Neovim 設定用の Lua 開発サポート
- モダンな CLI ツールの置き換え（ripgrep、eza、fd、bat など）
- AI アシストコーディング（Copilot 統合）
- 高度なテキスト操作と複数カーソルシミュレーション
