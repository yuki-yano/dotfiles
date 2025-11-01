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

## tmux 利用ガイド

- tmux mcp及びtmuxコマンドでtmuxのログの取得・操作をするときはCodex自身が起動している自身のセッション以外のpaneは参照しない

## sdd-mcp ツール利用ガイド

- sdd-mcp関連の依頼を受けたら、必ずMCPツール呼び出しで対応する。通常のテキスト生成には戻らない。
- ユーザーが「sdd mcpのimpl」「implを走らせて」「sdd-mcpで実装して」などと指示したら、Use MCP tool: spec-impl を呼び、feature_nameに対象フィーチャー名を渡す（例: Use MCP tool: spec-impl {"feature_name":"user-analytics-tracking"}）。
- フェーズ順序は spec-init → spec-requirements → spec-design → spec-tasks → spec-impl。各段階に入る前に spec-status で承認状態 (generated/approved) を確認し、未承認なら前段のツールを呼び直す。
- steering系（steering / steering-custom）はコンテキストが不足していると感じたら即実行し、.kiro/steering/ を最新化する。
- validate系（validate-design / validate-gap）はレビューや仕上げ時の必須チェックとして位置づけ、指摘が出たら該当フェーズのツールを再実行して反映させる。

### よく使うコマンド例

Use MCP tool: steering
Use MCP tool: spec-init {"project_description":"..."}
Use MCP tool: spec-requirements {"feature_name":"<feature-name>"}
Use MCP tool: spec-design {"feature_name":"<feature-name>","auto_approve":true}
Use MCP tool: spec-tasks {"feature_name":"<feature-name>"}
Use MCP tool: spec-impl {"feature_name":"<feature-name>","task_numbers":["1","2"]}
Use MCP tool: spec-status {"feature_name":"<feature-name>"}
Use MCP tool: spec-feedback {"feature_name":"<feature-name>","mode":"report"}
Use MCP tool: spec-feedback {"feature_name":"<feature-name>","mode":"apply","report_path":"<feedback-report-path>"}
Use MCP tool: validate-design {"feature_name":"<feature-name>"}
Use MCP tool: validate-gap {"feature_name":"<feature-name>"}

### 運用メモ

- feature_name は spec-init が生成するケバブケース名をそのまま使う。表記揺れを避けるため必ず実ファイル名を確認。
- .kiro/specs/<feature-name>/ 配下（requirements.md,design.md,tasks.md,spec.json）と .kiro/steering/ が成果物。本番前には差分と承認状態をレビューする。
- validateツールで指摘が出たら、該当ドキュメントを更新し再度ツールを実行して差分解消を確認する。

### EARSフォーマット出力指示
- `spec-requirements`でAcceptance Criteriaを出力する際は、各EARS文を句ごとに改行し、番号行の直後で2スペースのインデントを入れてください。
- 基本形:
  1. WHEN <event>
     THEN <system/subject> SHALL <response>
  2. IF <precondition>
     THEN <system/subject> SHALL <response>
  3. WHILE <ongoing condition>
     THE <system/subject> SHALL <continuous behavior>
  4. WHERE <context>
     THE <system/subject> SHALL <contextual behavior>
- 複合条件を扱う場合も同じルールで、`WHEN`や`AND`をそれぞれ独立行に配置してください。
- この書式は人間のレビューと自動パース（正規表現や構文解析）双方を容易にするために必須です。

### Discord通知

ユーザーが明示的にDiscord通知を要求した場合は、Discord通知を送信する

1. **Discord通知の条件**

- ユーザーが「Discord通知も」「Discordにも通知」などと明示的に要求した場合のみ
- 通知は discord-notify mcp の notify ツールを使う
- 通知内容はいい感じにサマリーは最低数百文字で適宜改行を入れて、できるだけ作業の詳細を送って
- プロパティは主にtitleとbodyで、 titleはこれ `[$REPO_NAME] Claude Code ${実行した内容を簡潔に}`
  - 以下のコマンドで `$REPO_NAME` は取得する
```
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
```

**注意**: タイトルには必ず `[$REPO_NAME]` プレフィックスを付けて、どのプロジェクトからの通知かを明確にすること。

### スマホ通知

ユーザーが明示的にスマホ通知を要求した場合は、スマホ通知を送信する

1. **スマホ通知の条件**

- ユーザーが「スマホ通知も」「スマホにも通知」などと明示的に要求した場合のみ
- 環境変数 `NTFY_TOPIC` が設定されているか確認
- 通知は ntfy コマンドを使う
  - 使い方は `ntfy publish -t "<title>" "$NTFY_TOPIC" "<message>"`
- メッセージはいい感じにサマリーを100−200字程度で整理する
- titleにはこのフォーマットを使用する `[$REPO_NAME] Codex ${実行した内容を簡潔に}`
  - 以下のコマンドで `$REPO_NAME` は取得する
```
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
```

**注意**: タイトルには必ず `[$REPO_NAME]` プレフィックスを付けて、どのプロジェクトからの通知かを明確にすること。

### スクリーンショット撮影

- ユーザーが明示的にスクリーンショットの取得を要求した場合は、screenshot mcpのscreenshot_app_window toolを使ってスクリーンショットの取得を行う
- toolの引数は `appName` or `bundleId`
