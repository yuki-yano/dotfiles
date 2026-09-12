# 実行と部分適用

## 実行前

開始時のHEADとstaged / unstaged diffを確認する。
通常の追加コミットのためにバックアップブランチを一律作成しない。
HEADへの参照だけでは未コミット差分のバックアップにならない。

## コミット

- 実行指示または承認済みの計画に含まれる差分だけをstageする。
- ファイル単位なら`git add -- <file...>`、混在するファイルは下記の部分適用を使う。
- `--file <path>`指定時は、addとdiff確認に同じpathspecを使う。
- 各コミット直前に`git diff --cached`で対象を確認する。対象外のstaged差分はそのままcommitしない。
- 複数行のメッセージは1つの`-m`に渡す。

```bash
git commit -m "$(cat <<'EOF'
<type>: <サマリ>

- 作業内容
EOF
)"
```

## 部分適用

worktreeでは`.git`がディレクトリとは限らないため、`git rev-parse --git-path`で保存先を解決する。
今回作成したpatchだけを扱い、他の実行が作ったファイルを削除しない。

```bash
commit_plan_root="$(git rev-parse --git-path commit-plan)"
mkdir -p "$commit_plan_root"
commit_plan_dir="$(mktemp -d "$commit_plan_root/run.XXXXXX")"
```

入れたい差分だけのpatchを`$commit_plan_dir/<name>.patch`に保存し、適用する。

```bash
git apply --check --cached "$commit_plan_dir/<name>.patch"
git apply --cached "$commit_plan_dir/<name>.patch"
git diff --cached
```

自分がstageした差分を除外する場合は、同じpatchの`git apply -R --check --cached`後に`git apply -R --cached`を使う。
check失敗や計画との差分不一致ではindexをさらに変更せず、現在状態を確認する。

## コミット後

`git log -1 --stat`と`git status --short`で内容・残差分を確認する。
予期しないstaged差分が残る場合は次のcommitへ進めない。
部分適用でpatchを作った場合は、全コミットの成功後に[クリーンアップ](recovery-and-cleanup.md#クリーンアップ)を読み、今回作成したファイルだけを片付ける。
失敗時は[復旧手順](recovery-and-cleanup.md)へ進む。
