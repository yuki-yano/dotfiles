---
description: Generate cleanup report for AI work directories to identify old files and suggest organization
---

# 作業ディレクトリのクリーンアップレポート生成: $ARGUMENTS

## 目標

AIディレクトリ構造を整理し、古いファイルのクリーンアップと現在の作業状況をレポートする

## 手順（順番に実行）

ステップ 1. **現在のAIディレクトリ構造の確認**
- `ai/` ディレクトリ配下の全ディレクトリをスキャン
- 各ディレクトリのファイル数と最終更新日を確認
- 存在しないディレクトリはスキップ

ステップ 2. **現在の使用状況を分析**
各ディレクトリの内容を確認:
- ファイル数とサイズ
- 最終更新日時
- TodoListとの関連性

ステップ 3. **整理対象の特定**
以下の基準で整理対象を判定:
- `ai/tmp/`: 7日以上前のファイル → 削除
- `ai/log/sessions/`: 30日以上前 → アーカイブ
- `ai/issues/resolved/`: 60日以上前 → アーカイブ提案
- `ai/plans/completed/`: 90日以上前 → アーカイブ提案
- 空のディレクトリ: 削除提案

ステップ 4. **整理提案の生成**
- 削除対象ファイルのリスト表示
- アーカイブ推奨ファイルのリスト表示
- 各ファイルの最終更新日と経過日数を表示

ステップ 5. **整理レポートの生成**
`ai/log/analysis/YYYY-MM-DD-organize-report.md` を作成:
```markdown
# AIディレクトリ整理レポート

日時: <実行日時>

## 現在の状況
### ディレクトリ別統計
| ディレクトリ | ファイル数 | 合計サイズ | 最古ファイル |
|-------------|-----------|-----------|-------------|
| ai/tmp      | X         | X MB      | YYYY-MM-DD  |
...

## 整理対象
### 削除対象
- ai/tmp/old-file.txt (7日前)
...

### アーカイブ対象
- ai/log/sessions/2024-12-01-14-handoff.md (30日前)
...

## 整理実行コマンド例
```bash
# 削除対象の一括削除
rm ai/tmp/old-file1.txt ai/tmp/old-file2.txt

# アーカイブ対象の移動
mkdir -p ai/archive/2025-06
mv ai/log/sessions/2024-12-01-14-handoff.md ai/archive/2025-06/
```

## 推奨事項
- 定期的な整理の実行（週1回）
- 重要な決定事項はknowledge/に移動

ステップ 6. **TodoListへの反映提案**
整理で発見した未完了タスクや課題をTodoListに追加提案
