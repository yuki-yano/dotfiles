# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## リポジトリ概要

これは、Deno タスクランナーを使用してシステム設定、開発ツール、アプリケーションを管理する macOS 向けの包括的な dotfiles リポジトリです。このリポジトリは、モダンな CLI ツールと洗練された Neovim セットアップを重視しています。

2025年12月に Ruby/Rake から Deno/TypeScript へ完全移行し、セキュリティと型安全性が向上しました。

## 必須コマンド

### 初期セットアップ

```bash
deno task dotfiles:install  # すべての設定ファイルのシンボリックリンクを作成
deno task brew:bundle       # Brewfile からコマンドラインツールをインストール
deno task brew:cask         # Caskfile から GUI アプリケーションをインストール
deno task mas:install       # Masfile から Mac App Store アプリをインストール
deno task npm:install       # NpmGlobal から Node.js パッケージをインストール（yarn 使用）
deno task zsh:zinit:install # Zsh プラグインマネージャーをインストール
```

### コード品質コマンド

```bash
deno fmt              # Deno/TypeScript ファイルをフォーマット（行幅: 120）
stylua .              # Lua ファイルをフォーマット（2スペース、120カラム）
cspell "**/*"         # すべてのファイルでスペルチェック
```

### パッケージ管理

```bash
deno task npm:upgrade      # すべてのグローバル Node.js パッケージをアップグレード
deno task npm:uninstall    # グローバル node モジュールを削除
deno task zsh:zinit:uninstall # Zsh プラグインマネージャーを削除
deno task help             # 利用可能なタスクを表示
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

- **パッケージリスト**: `Brewfile`, `Caskfile`, `NpmGlobal`, `Masfile`
- **ビルド自動化**: 
  - `deno.json` - Deno タスク定義
  - `tasks.ts` - TypeScript で実装されたタスクランナー
- **Neovim プラグイン**: `.vim/lua/plugins/` - モジュール化されたプラグイン設定
- **LSP 設定**: `.vim/lua/plugins/lsp/servers/` - 言語固有の LSP 設定

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

- Bun の最新版インストール
- 他の言語ランタイムは必要に応じて追加可能

### パス設定

`.zshenv` で以下のツールパスが設定されています：

- `~/.bun/bin`: Bun JavaScript ランタイム
- `~/.deno/bin`: Deno ランタイム
- `~/.cargo/bin`: Rust ツールチェーン
- その他 mise 管理下のツール

## Deno タスクランナーへの移行

### 移行の背景

2025年12月26日に、Ruby/Rake から Deno/TypeScript へ完全移行しました。この移行により以下のメリットが得られました：

- **型安全性**: TypeScript による静的型付けでエラーを事前に検出
- **セキュリティ**: Deno の権限モデルによる安全な実行環境
- **依存関係の削減**: Ruby と関連 gem の依存を排除
- **パフォーマンス**: Deno の高速な起動時間
- **保守性**: モダンな JavaScript/TypeScript エコシステムの活用

### セキュリティ強化

移行に伴い、以下のセキュリティ対策を実装：

- 限定的な権限設定（`-A` フラグの廃止）
- brew コマンドの検証（ホワイトリスト方式）
- ファイル操作時のユーザー確認
- dry-run モードのサポート
