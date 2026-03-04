# Storage Policy

このスキルは、外部 OSS 調査で `opensrc` を第一選択として使い、必要時のみ clone fallback を使う。

## 目的

- 参照コードを作業リポジトリの構造から分離する。
- `--cwd` 指定で `opensrc/` の置き場を制御し、調査手順を再現可能にする。
- 履歴調査が必要なケースだけ clone を追加し、通常調査のオーバーヘッドを下げる。

## opensrc 置き場（`--cwd`）の探索方針

置き場の探索と判断は agent が行う。opensrc モードでは `npx opensrc ... --cwd <base-dir>` の `<base-dir>` を決める。
`<base-dir>` は repo ルート相対パスで扱い、repo 外へ解決されるパスは使わない。
コマンド実行時は `cd "$(git rev-parse --show-toplevel)"` で repo ルートへ移動してから `--cwd <base-dir>` を指定する。

判断時の着眼点:

- 候補の命名意図: `reference` / `research` / `external` / `tmp` / `scratch`
- 実装本体との分離: `apps` / `packages` / `src` / `lib` 直下を避ける
- 追跡方針との整合: `<base-dir>/opensrc/` が `.gitignore` または `.git/info/exclude` で除外されているか
- 既存運用との整合: 既に参照用に使われているディレクトリがあるか

推奨の確認コマンド例:

```bash
repo_root="$(git rev-parse --show-toplevel)"
candidate_base_dir="z-ai/references"
find . -maxdepth 4 -type d
git check-ignore -v "$candidate_base_dir/opensrc/.codex-ignore-probe"
real_base="$(cd "$repo_root/$candidate_base_dir" && pwd -P)"
case "$real_base" in "$repo_root"|"$repo_root"/*) : ;; *) echo "outside-repo";; esac
```

## clone fallback 置き場（`--target-dir`）の探索方針

履歴調査で clone が必要なときだけ `scripts/prepare_oss_reference.sh` を使う。`--target-dir` は repo ルート相対で指定する。

推奨:

- opensrc の base dir が決まっている場合は `<base-dir>/git-clones` を優先する。
- opensrc と clone fallback を近い場所に置き、調査ログとの対応を取りやすくする。
- 例: `target_dir="z-ai/references/git-clones"; git check-ignore -v "$target_dir/.codex-ignore-probe"` で追跡対象外を確認する。

## 曖昧時の扱い

- 候補を1つに絞れない場合は、取得実行前にユーザーへ確認する。
- ユーザー確認時は候補パスと各候補の理由を短く提示する。
- ユーザー指定がある場合はそれを最優先する。
- `--cwd` は repo ルート相対パスのみ許可する（絶対パス禁止）。
- `--target-dir` は repo ルート相対パスのみ許可する（絶対パス禁止）。

## 運用ルール

- opensrc 実行は原則 `--modify=false` を付与し、`.gitignore` / `tsconfig.json` / `AGENTS.md` の暗黙更新を避ける。
- `--cwd` は repo ルート配下であることを実行前に検証し、検証後に repo ルートでコマンドを実行する。
- opensrc 取得後は `opensrc/sources.json` から `name`、`version/ref`、`path`、`fetchedAt` を記録する。
- opensrc は取得後に `.git` を除去するため、commit 履歴が必要な調査は clone fallback に昇格する。
- clone fallback 実行時は `CLONE_DIR`、`REPO_URL`、`HEAD_COMMIT`、`IGNORE_STATUS` を記録する。
- `IGNORE_STATUS=not_ignored` の場合、ワークツリー汚染リスクを説明してから続行する。
- `opensrc/` と clone fallback 用ディレクトリは `git add` しない。
