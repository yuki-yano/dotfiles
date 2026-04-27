# 失敗時復旧とクリーンアップ

## 復旧方針

- エラー時は自動修復せず停止
- 破壊的巻き戻しはしない
- まず現在状態を可視化して報告
- 復旧操作は staged diff の取り消しまでを自動で行える範囲とする
- ブランチ移動、コミット取り消し、作業ツリーの巻き戻しはユーザー確認後にだけ行う

## 安全な復旧手順

```bash
# 状態確認
git status --short
git diff --cached

# ステージングのみ取り消し
git restore --staged -- <file>

# 部分適用用 patch の確認
find .git/commit-plan -maxdepth 1 -type f 2>/dev/null

# 状態確認
git status --short
git diff --cached
```

`git restore --staged -- <file>` は index だけを戻す。作業ツリーの内容は戻さない。
実行前の `HEAD` を確認したい場合は、作成済みの `backup/commit-plan-*` ブランチを参照する。自動で `git switch` しない。

## 実行禁止

- `git reset --hard`
- `git checkout .`
- `git restore .`

## 完了後クリーンアップ（成功時のみ）

```bash
rm -rf .git/commit-plan
# バックアップブランチ削除はユーザー確認後
# git branch -d "$BACKUP_BRANCH"
```

## 失敗時の報告項目

失敗時は次を報告して停止する。

1. 失敗した操作
2. 現在の `git status --short`
3. 現在の `git diff --cached --stat`
4. 作成済みバックアップブランチ名
5. ユーザー確認が必要な次の選択肢
