# Storage Policy

このスキルは、外部 OSS 調査で `opensrc` を第一選択として使い、必要時のみ clone fallback を使う。

## 目的

- 参照コードを作業リポジトリの構造から分離する。
- `opensrc path` で取得された絶対パスと `sources.json` の metadata を対応づけ、調査手順を再現可能にする。
- cache 置き場はデフォルトの `~/.opensrc/` を使う。必要な場合のみ `OPENSRC_HOME` で明示的に変更する。
- 履歴調査が必要なケースだけ clone を追加し、通常調査のオーバーヘッドを下げる。

## opensrc cache 置き場（`OPENSRC_HOME`）の方針

現行 `opensrc` は `~/.opensrc/` にグローバルキャッシュする。作業 repo 配下に取得物を置かないため、通常は置き場探索を行わない。
cache 置き場を変更する必要がある場合だけ `OPENSRC_HOME` を指定する。

`--cwd` は cache 置き場ではない。npm package のバージョンを `node_modules` / lockfile / `package.json` から検出するための作業ディレクトリ指定としてだけ使う。

判断時の着眼点:

- デフォルトの `~/.opensrc/` で問題ないか
- repo 配下へ置く必要がある場合、`z-ai/references/opensrc-home` など実装本体から分離された ignored path か
- `OPENSRC_HOME` と clone fallback 置き場の対応が調査ログ上で追いやすいか

推奨の確認コマンド例:

```bash
repo_root="$(git rev-parse --show-toplevel)"
opensrc_home="${OPENSRC_HOME:-$HOME/.opensrc}"
printf "OPENSRC_HOME=%s\n" "$opensrc_home"
npx -y opensrc@latest list --json

# repo-local OPENSRC_HOME が必要な場合のみ:
candidate_home="z-ai/references/opensrc-home"
git check-ignore -v "$candidate_home/.codex-ignore-probe"
mkdir -p "$repo_root/$candidate_home"
real_home="$(cd "$repo_root/$candidate_home" && pwd -P)"
case "$real_home" in "$repo_root"|"$repo_root"/*) : ;; *) echo "outside-repo";; esac
```

## clone fallback 置き場（`--target-dir`）の探索方針

履歴調査で clone が必要なときだけ `scripts/prepare_oss_reference.sh` を使う。`--target-dir` は repo ルート相対で指定する。

推奨:

- repo-local `OPENSRC_HOME` を使っている場合は、その近くの `z-ai/references/git-clones` を優先する。
- デフォルトの `~/.opensrc/` を使っている場合でも、clone fallback は repo ルート相対の ignored path に置き、調査ログとの対応を取りやすくする。
- 例: `target_dir="z-ai/references/git-clones"; git check-ignore -v "$target_dir/.codex-ignore-probe"` で追跡対象外を確認する。

## 曖昧時の扱い

- `OPENSRC_HOME` をデフォルトから変更する必要性や候補を1つに絞れない場合は、取得実行前にユーザーへ確認する。
- ユーザー確認時は候補パスと各候補の理由を短く提示する。
- ユーザー指定がある場合はそれを最優先する。
- `--cwd` は npm バージョン解決用であり、通常は repo root または対象 package の project root を指定する。
- `--target-dir` は repo ルート相対パスのみ許可する（絶対パス禁止）。

## 運用ルール

- opensrc 実行は `opensrc path <spec>` を優先する。cache miss 時は自動取得され、stdout に絶対パスが出る。
- `--verbose` は ref/tag fallback の警告確認が必要なときに使う。
- opensrc 取得後は `opensrc list --json` または `${OPENSRC_HOME:-$HOME/.opensrc}/sources.json` から `name`、`version/ref`、`path`、`fetchedAt` を記録する。
- `sources.json` の `path` は `OPENSRC_HOME` からの相対パスなので、根拠ファイルには `opensrc path` が返した絶対パスを使う。
- opensrc は取得後に `.git` を除去するため、commit 履歴が必要な調査は clone fallback に昇格する。
- clone fallback 実行時は `CLONE_DIR`、`REPO_URL`、`HEAD_COMMIT`、`IGNORE_STATUS` を記録する。
- `IGNORE_STATUS=not_ignored` の場合、ワークツリー汚染リスクを説明してから続行する。
- `~/.opensrc/`、`OPENSRC_HOME`、clone fallback 用ディレクトリは `git add` しない。
