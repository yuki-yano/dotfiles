---
name: oss-implementation-research
description: GitHub リポジトリや既存 OSS の実装調査を行うスキル。通常は opensrc で参照コードを取得し、git 履歴が必要な場合のみ clone/fetch に切り替える。参照元 spec・解決された version/ref・根拠ファイルを紐づけて調査報告する。
---

# OSS Implementation Research

## Overview

- デフォルトは `opensrc path` で参照コードの絶対パスを取得し、必要なファイルだけ調査する。
- `opensrc` は取得済みソースを `~/.opensrc/` にグローバルキャッシュする。置き場を変える場合は `OPENSRC_HOME` を使う。
- `--cwd` は npm パッケージの lockfile / `node_modules` から使用バージョンを解決するための作業ディレクトリ指定であり、キャッシュ置き場の指定ではない。
- `git log` / `git blame` / commit 単位比較など、履歴が必要な調査のみ clone/fetch に昇格する。
- 調査結果は必ず「入力 spec・解決された version/ref・根拠ファイル（必要に応じて行番号）」に紐づける。

## Workflow

1. 調査要件を固定する

- 対象 spec（例: `owner/repo`、`pypi:package`、`crates:crate`）と調査テーマを明示する。
- 履歴が必要か（`git log`/`blame`/bisect/PR 追跡）を判定する。判断が曖昧ならユーザーへ確認する。

2. 取得経路を決定する

- 基本は opensrc 経路を選ぶ。
- 次のいずれかに当てはまる場合のみ clone/fetch 経路へ昇格する。
- commit SHA を根拠として固定したい。
- `git log` / `git blame` / 差分追跡が必要。
- opensrc が指定 ref を解決できずデフォルトブランチへフォールバックした。
- ユーザーが明示的に clone を要求した。

3. opensrc 経路で参照コードを取得する（デフォルト）

- `opensrc path <spec>` を使う。cache miss 時は自動で fetch され、stdout には絶対パスだけが出る。
- 進捗や警告を確認したい場合は `--verbose` を使う。特に ref/tag の fallback を検知したい調査では `--verbose` を付ける。
- npm パッケージで対象プロジェクトの lockfile からバージョンを合わせたい場合だけ、`--cwd "$repo_root"` または対象 package の project root を指定する。
- 取得だけを明示したい場合は `opensrc fetch <spec>` を使ってもよいが、調査では後続コマンドに渡しやすい `opensrc path` を優先する。
- 実行例:

```bash
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
ref_path="$(npx -y opensrc@latest path honojs/hono --verbose)"
rg "pattern" "$ref_path"

ref_path="$(npx -y opensrc@latest path vercel/ai#main --verbose)"
rg "streamText" "$ref_path"

request_path="$(npx -y opensrc@latest path pypi:requests --verbose)"
serde_path="$(npx -y opensrc@latest path crates:serde --verbose)"

# npm package only: resolve the version from this repo's lockfile/node_modules.
zod_path="$(npx -y opensrc@latest path zod --cwd "$repo_root" --verbose)"
```

- 実行後は `opensrc list --json` または `${OPENSRC_HOME:-$HOME/.opensrc}/sources.json` を読み、対象の `name`・`version`・`path`・`fetchedAt` を記録する。
- `sources.json` の `path` は `OPENSRC_HOME` からの相対パスである。根拠ファイルには `opensrc path` が返した絶対パスを使う。
- リポジトリ参照は主に `${OPENSRC_HOME:-$HOME/.opensrc}/repos/<host>/<owner>/<repo>/<ref>` 配下になる。パッケージ参照も `sources.json` の `path` を正とする。
- `--verbose` 出力に「指定 ref/tag が見つからず default branch を clone」等の警告がある場合、厳密な ref 固定が必要なら clone/fetch 経路に昇格する。

4. clone/fetch 経路で参照コードを取得する（履歴調査時のみ）

- `scripts/prepare_oss_reference.sh` を使い、repo ルート相対の `--target-dir` を明示して実行する。
- 実行例:

```bash
bash .agents/skills/oss-implementation-research/scripts/prepare_oss_reference.sh honojs/hono --target-dir z-ai/references/git-clones
bash .agents/skills/oss-implementation-research/scripts/prepare_oss_reference.sh honojs/hono --target-dir z-ai/references/git-clones --ref v4.9.7
```

- スクリプト出力の `CLONE_DIR`、`HEAD_COMMIT`、`IGNORE_STATUS` を記録する。
- 既存 clone の `origin` が要求 repo と不一致なら停止し、ユーザーへ確認する。
- `IGNORE_STATUS=not_ignored` の場合は、差分汚染リスクを説明して続行可否を確認する。

5. 実装を調査する

- `rg` でエントリポイントと関連モジュールを絞る。
- 関連箇所を読み、事実（コード根拠）と推測（解釈）を分けて整理する。
- 必要なら同一テーマで複数 OSS を同じ手順で比較する。

6. 調査結果を報告する

- 次を必ず含める。
- 入力 spec（ユーザーが指定した識別子）
- 取得経路（opensrc / clone-fallback）
- 解決された version/ref（`opensrc list --json` / `sources.json` または clone の checkout 結果）
- 根拠ファイルパス（必要に応じて行番号）
- 結論と未確定事項
- clone/fetch 経路を使った場合は `REPO_URL` と `HEAD_COMMIT` を必ず含める。
- opensrc 経路では `.git` が除去されるため commit 不明になりうる。必要なら clone/fetch 経路へ切り替える。

7. 後処理を管理する

- 取得済み参照ディレクトリは再利用のため残す（削除はユーザー指示時のみ）。
- `~/.opensrc/`、`OPENSRC_HOME`、clone fallback 用ディレクトリを `git add` しない。
- opensrc の整理が必要な場合のみ `opensrc remove` / `opensrc clean` を使う。

## Directory Policy

- 置き場の探索・選定基準は `references/storage-policy.md` に従う。
- opensrc のキャッシュ置き場を変更する場合は `OPENSRC_HOME` で指定する。
- `--cwd` は npm バージョン解決用であり、cache 置き場の制御には使わない。
- `OPENSRC_HOME` や `--target-dir`（clone fallback）が曖昧なときは、実行前に必ずユーザーへ確認する。

## Resources

- `opensrc` CLI: デフォルト取得経路。`opensrc path` で参照コードの絶対パスを取得する。
- `scripts/prepare_oss_reference.sh`: 履歴調査が必要なときの clone/fetch fallback を実行する。
- `references/storage-policy.md`: `OPENSRC_HOME` / `--target-dir` の選定ルールと安全運用ポリシーを定義する。
