# 実行と部分適用

## 実行前の安全対策

```bash
BACKUP_BRANCH="backup/commit-plan-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
echo "バックアップブランチを作成しました: $BACKUP_BRANCH"

git stash create > .git/commit-plan-stash-ref
git status
```

## 実行方針

- 通常は `git add <file...>` でステージング
- 同一ファイル内の混在差分はパッチで部分適用
- 失敗時は停止し、状態を報告

## 部分適用コマンド

```bash
# 入れたい差分のみ適用
git apply --check --cached <patch>
git apply --cached <patch>

# 除外したい差分を逆適用
git apply -R --cached <patch>

# 状態確認
git diff --cached
```

## コミット後の確認

```bash
git log -1 --stat
git status --short
```

## AUTO 実行時の扱い

`AUTO_EXECUTE=true`（または `--auto`）では、承認後は各コミット前の再確認を省略して順次実行する。
