---
description: Create Markdown log for features implemented in current HEAD commit and save to ai/log/features/
---

# 機能のログファイルを作成、機能の説明: $ARGUMENTS

あなたは細心の注意を払うリリースエンジニアです。

## 目標

現在のコミット（HEAD）で実装された機能の Markdown ログエントリを生成し、`ai/log/features/` に保存する。

## 動作仕様（順番に従う）

ステップ 1. `$ARGUMENTS` を解析: 存在する場合は明示的な機能説明の上書きとして扱う。そうでない場合は HEAD コミットメッセージから説明を導出する。
ステップ 2. `git log -1 --pretty=format:"%h|%an|%ad|%s" --date=short` でコミットメタデータを収集して以下を取得:
   * 短縮ハッシュ *作成者* *日付* *件名*
ステップ 3. `git diff-tree --no-commit-id --name-only -r HEAD` で変更されたファイルを特定。
ステップ 4. フォルダ `ai/log/features/` が存在することを確認（存在しない場合は作成）。
ステップ 5. ログファイル `ai/log/features/<date>-<feature>.md` を作成（例: `2025-06-18-create-button.md`）。
同名のファイルが既に存在する場合は、上書きを避けるために `-1`、`-2`、… を追加。`<feature>` は 20 文字未満にする。
6. 以下の Markdown コンテンツを書き込む:

   ```markdown
   # <件名または $ARGUMENTS>

   コミット: `<ハッシュ>`
   作成者: <作成者>
   日付: <日付>

   ## 説明
   <詳細に分析した機能の説明リストまたは $ARGUMENTS>

   ## 変更されたファイル
   - file/path/one
   - file/path/two
   ...
   ```

7. 書き込み後、ユーザーが確認できるように作成したファイルへの相対パスを出力。