---
name: discord-notify
description: Discord への通知を送信する。ユーザーが「Discord通知も」「Discordにも通知」など明示的に要求したときに使う。
---

# Discord Notify

## 概要

Discord 通知の運用ルールを守りつつ、`~/.agents/skills/discord-notify/scripts/send_discord_notification.ts` を直接実行して通知を送信する。

## 通知ポリシー

1. ユーザーが「Discord通知も」「Discordにも通知」など、明示的に要求した場合のみ通知する。
2. 通知は Deno スクリプトで Webhook 送信する。

## タイトル規約

タイトルは必ず `[$REPO_NAME] Codex ${実行内容の要約}` 形式にする。

`REPO_NAME` は次のコマンドで取得する。

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
```

## 本文規約

- 本文は最低でも数百文字で作成する。
- 作業内容、変更点、確認結果、未実施項目を具体的に書く。
- 読みやすさのため、適宜改行を入れる。

## 送信者名の切替

- スクリプトは実行主体を自動判定し、既定 username を切り替える。
- Codex と判定した場合は `Codex notification`。
- Claude と判定した場合は `Claude Code notification`。
- 手動で固定したい場合は `--agent codex|claude` または `DISCORD_NOTIFY_AGENT` を使う。
- 既定と異なる名前にしたい場合は `--username` または `DISCORD_NOTIFY_USER_NAME` を使う。Claude 判定時は文字列中の `Codex` を `Claude Code` に置換する。
- アバターは既定で `https://avatars.githubusercontent.com/u/14957082` を使う。変更する場合は `--avatar-url` または `DISCORD_NOTIFY_AVATAR_URL` を使う。

## 実行手順

1. 環境変数を設定するか、同等の CLI オプションを指定する。
2. Deno の `--allow-env` と `--allow-net` を付けて実行する。
3. `--title` と `--body` を指定し、必要に応じてメンション・embeds・送信者情報を追加する。
4. Discord から 2xx 以外が返った場合は、エラー本文を確認して再実行する。

## 環境変数

- `DISCORD_WEBHOOK_URL`: 必須。`--webhook-url` 指定時は不要。
- `DISCORD_USER_ID`: 任意。`--user-id` 指定時は不要。
- `DISCORD_NOTIFY_AGENT`: 任意。`codex` または `claude` を指定して自動判定を上書きする。
- `DISCORD_NOTIFY_USER_NAME`: 任意。送信者名を指定する（詳細は「送信者名の切替」を参照）。
- `DISCORD_NOTIFY_AVATAR_URL`: 任意。アバター URL を指定する（詳細は「送信者名の切替」を参照）。

## 実行例

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
SKILL_SCRIPT="$HOME/.agents/skills/discord-notify/scripts/send_discord_notification.ts"

deno run --allow-env --allow-net \
  "$SKILL_SCRIPT" \
  --title "[$REPO_NAME] Codex 依存更新完了" \
  --body $'今回の作業では依存更新と通知フローの検証を実施しました。\n\n変更対象は3ファイルで、lint/typecheck/testを順に実行し、すべて成功しています。\n\n補足として、通知はDenoスクリプト経由で送信し、Discord側のレスポンスも正常を確認しました。'
```

## 対応オプション

- `--title`: 必須。
- `--body`: 必須。
- `--webhook-url`: 環境変数の Webhook URL を上書きする。
- `--user-id`: 環境変数のユーザー ID を上書きする。
- `--agent`: 実行主体を `codex` または `claude` に固定する。
- `--username`: 送信者名を指定する。
- `--avatar-url`: アバター URL を指定する。
- `--chunk-size`: 分割サイズを指定する。最大 2000 に丸める。
- `--embeds-json`: embeds を JSON 配列文字列で指定する。
- `--dry-run`: 送信せずにリクエスト payload を表示する。
- `--help`: 使い方を表示する。

## 挙動メモ

- 先頭行は `**title**` または `<@userId> **title**` の形式で生成する。
- ユーザーメンション時は最初のチャンクだけ `allowed_mentions.users` を設定する。
- Discord の上限を超える本文はチャンク分割し、順番に送信する。
- HTTP エラー時はレスポンス本文を含めてエラーを返す。
