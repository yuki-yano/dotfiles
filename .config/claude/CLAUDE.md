## 前提

応答は全て日本語で行うように

## AI作業ディレクトリのルール

### ディレクトリ構造と用途
プロジェクトのAI支援作業では、以下のディレクトリ構造を使用してください：

1. **`ai/tmp/`** - 一時的な作業ファイル
   - デバッグ、実験、検証用
   - セッション終了時に削除可能

2. **`ai/log/`** - 時系列の作業記録
   - `features/` - 実装した機能
   - `fixes/` - バグ修正
   - `tests/` - テスト実行結果
   - `sessions/` - セッション引き継ぎ
   - `nippo/` - 日次作業記録（日報）
   - ファイル名: `YYYY-MM-DD-説明.md`（nippoは`YYYY-MM-DD.md`）

3. **`ai/knowledge/`** - 恒久的な知識ベース
   - `learnings/` - 技術的な学習事項
   - `decisions/` - アーキテクチャ決定
   - `patterns/` - ベストプラクティス
   - `context/` - プロジェクトコンテキスト

4. **`ai/issues/`** - 問題管理
   - `active/` - 対応中の問題
   - `resolved/` - 解決済み
   - `blocked/` - ブロック中

5. **`ai/plans/`** - 計画とチェックリスト
   - `active/` - 実行中の計画
   - `completed/` - 完了した計画

6. **`ai/roadmap/`** - プロジェクトのロードマップ
   - `current/` - 現在のロードマップ
   - `archive/` - 過去のロードマップ
   - `milestones/` - マイルストーン定義

### ファイル命名規則
- 日付を含む場合: `YYYY-MM-DD-簡潔な説明.md`
- 説明は15文字以内を推奨
- 日本語可、スペースの代わりにハイフンを使用

### ファイル作成時の日付取得（必須）

**重要**: ログファイルを作成する際は、必ず以下のコマンドで現在の日付を取得して使用すること：

```bash
# 現在の日付を取得（YYYY-MM-DD形式）
DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')

# ファイル名の例
FILENAME="ai/log/features/${DATE}-feature-name.md"
```

**注意事項**:
- 環境情報の「Today's date」に依存せず、必ず上記のコマンドで実際の日付を取得する
- タイムスタンプが必要な場合は `perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S", localtime)'` を使用
- 日本時間（JST）を明示する場合は `perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M (JST)", localtime)'` を使用

### 重要な原則
- **既存の情報を確認**: 新規作成前に関連ディレクトリを確認
- **適切な場所に保存**: 目的に応じて正しいディレクトリを選択
- **相互参照**: 関連ドキュメントは相対パスで参照
- **日付は必ず動的に取得**: ハードコードせず、上記の Perl コマンドで取得

## URL処理のルール

- URLが提供された場合は、`read_url_content_as_markdown` を使用してコンテンツを読み込み、内容を要約する


## Web検索のルール

**最重要**: Web検索が必要な場合は、以下の優先順位で実行してください：

1. **最優先: MCP google_search** (必ず最初に試す)
 - 単一検索: `mcp__gemini-grounding__google_search` を使用
 - AI生成の要約付き検索結果を提供
 - 引用付きの包括的な回答を生成

2. **バッチ検索: MCP google_search_batch** (複数の検索が必要な場合)
 - `mcp__gemini-grounding__google_search_batch` を使用
 - 最大10個のクエリを並列実行
 - 検索結果からWebページをスクレイピング可能
 - 以下の場合に使用:
   - 複数の観点から調査が必要な場合
   - 比較検討が必要な場合
   - 深い調査が必要な場合

3. **代替手段: gemini コマンド** (MCPが利用不可の場合のみ)
```bash
gemini --prompt "WebSearch: <検索クエリ>"
```

## 通知の実行

### Discord通知

ユーザーが明示的にDiscord通知を要求した場合は、Discord通知を送信します。

1. **Discord通知の条件**

- ユーザーが「Discord通知も」「Discordにも通知」などと明示的に要求した場合のみ
- 環境変数 `DISCORD_WEBHOOK_URL` が設定されている必要がある

2. **Discord通知方法**

```bash
# リポジトリ名を取得（gitリポジトリの場合）
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")

# macOS通知の後に Discord通知を追加
discord-notify.ts --env DISCORD_WEBHOOK_URL "実行した内容の説明" --title "[$REPO_NAME] Claude Code"

# エラー時の通知
discord-notify.ts --env DISCORD_WEBHOOK_URL "エラー: 内容" --title "[$REPO_NAME] ❌ Claude Code Error"

# 成功時の通知（明示的な成功通知が必要な場合）
discord-notify.ts --env DISCORD_WEBHOOK_URL "成功: 内容" --title "[$REPO_NAME] ✅ Claude Code Success"
```

**注意**: タイトルには必ず `[$REPO_NAME]` プレフィックスを付けて、どのプロジェクトからの通知かを明確にすること。
