# 実行と部分適用

## 実行前の安全対策

バックアップブランチは現在の `HEAD` を保存するためのものであり、未コミット差分そのものは保存しない。未コミット差分の保護は、Phase 1 の計画、staged diff の確認、必要に応じた patch 作成で担保する。

```bash
BACKUP_BRANCH="backup/commit-plan-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
echo "バックアップブランチを作成しました: $BACKUP_BRANCH"

git status --short
```

## 実行方針

- 実行前に `git diff --cached` を確認し、既存 staged diff が計画対象と混ざっていないことを確認する
- Phase 1 の `y` 承認後は、計画した全コミットを順次実行する
- 各コミット前の追加確認は行わない
- 通常は `git add -- <file...>` でステージング
- `--file <path>` 指定時は、すべての `git add` と diff 確認に同じ pathspec を使う
- 同一ファイル内の混在差分はパッチで部分適用
- 失敗時は停止し、状態を報告
- ignore されているファイルは `git add -f` しない

## 部分適用コマンド

部分適用では、入れたい差分だけを含む patch ファイルを作ってから index に適用する。
patch ファイルは `.git/commit-plan/` 配下に置き、作業ツリーの通常ファイルとして残さない。

```bash
mkdir -p .git/commit-plan

# 入れたい差分のみ適用
git apply --check --cached .git/commit-plan/<name>.patch
git apply --cached .git/commit-plan/<name>.patch

# 除外したい差分を逆適用
git apply -R --cached .git/commit-plan/<name>.patch

# 状態確認
git diff --cached
```

`git apply --check --cached` が失敗した場合は、その場で停止して `git status --short` と失敗した patch 名を報告する。

## コミット後の確認

```bash
git log -1 --stat
git status --short
```

各コミット後に、次のコミットへ進む前に `git diff --cached` が空であることを確認する。空でなければ停止して報告する。
計画との差分不一致、patch 適用失敗、コミット失敗、検証失敗があれば停止する。
