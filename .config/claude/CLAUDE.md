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
   - `sessions/` - セッション引き継ぎ

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

### 重要な原則
- **既存の情報を確認**: 新規作成前に関連ディレクトリを確認
- **適切な場所に保存**: 目的に応じて正しいディレクトリを選択
- **相互参照**: 関連ドキュメントは相対パスで参照
- **日付は必ず動的に取得**: ハードコードせず、上記の Perl コマンドで取得

## URL処理のルール

- URLが提供された場合は、`read_url_content_as_markdown` を使用してコンテンツを読み込み、内容を要約する

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
