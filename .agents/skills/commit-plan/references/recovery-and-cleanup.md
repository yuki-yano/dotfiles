# 失敗時復旧とクリーンアップ

## 復旧方針

- エラー時は自動修復せず停止
- 破壊的巻き戻しはしない
- まず現在状態を可視化して報告

## 安全な復旧手順

```bash
# ステージングのみ取り消し
git restore --staged <file>

# 実行前状態に戻したい場合はバックアップブランチへ退避
git switch "$BACKUP_BRANCH"

# 状態確認
git status
git diff --cached
```

## 実行禁止

- `git reset --hard`
- `git checkout .`
- `git restore .`

## 完了後クリーンアップ（成功時のみ）

```bash
rm -f .git/commit-plan-stash-ref
# バックアップブランチ削除はユーザー確認後
# git branch -d "$BACKUP_BRANCH"
```
