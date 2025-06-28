---
description: Analyze git changes and create an organized commit plan with logical grouping
---

# コミット計画作成: $ARGUMENTS

## 目標

Git変更を分析し、意図別に論理的なコミット計画を作成する。同一ファイルに複数の意図がある場合は`git add -p`で分割。

## 実行手順

### 1. 変更内容の分析

```bash
git status --porcelain
git diff --stat
git diff  # 全体の変更を確認
```

### 2. 意図の識別と分類

- **feat**: 新機能、新しいコンポーネント
- **fix**: バグ修正、エラーハンドリング
- **refactor**: コード整理、リネーム
- **docs**: ドキュメント、コメント
- **test**: テストの追加・修正
- **chore**: 設定、依存関係

### 3. 意図別コミット計画

以下の形式で出力:

**コミット計画**

**[1] feat: ユーザー認証機能**
- `src/auth.ts` (新規)
- `src/api.ts` [部分] L45-L89
- `src/types.ts` [部分] L12-L25

実行コマンド:
```bash
git add src/auth.ts
git add -p src/api.ts    # L45-L89を選択
git add -p src/types.ts   # L12-L25を選択
git commit -m "feat: Add user authentication"
```

**[2] fix: バリデーション修正**
- `src/utils.ts` [部分] L102-L115
- `src/api.ts` [部分] L15-L18

（各コミットごとに同様の形式で続く）

### 4. 実行モード選択

- **[a] 自動実行**: 順次実行（部分的変更では`git add -p`起動）
- **[i] インタラクティブ**: 各コミット前に確認
- **[e] 計画を編集**: コミットの統合・分割・順序変更
  - `1,2を統合` / `3を分割` / `1と3を入れ替え` / `2のメッセージ: 新内容`
- **[d] ドライラン**: コマンド確認のみ

## git add -p 操作

- `y` - ステージング / `n` - スキップ
- `s` - 分割 / `e` - 編集
- `?` - ヘルプ / `q` - 終了

## ベストプラクティス

1. 全体の変更から異なる意図を識別
2. 1コミット = 1つの意図
3. 同一ファイルでも意図別に`git add -p`で分割
4. ビルドが壊れない順序で実行
