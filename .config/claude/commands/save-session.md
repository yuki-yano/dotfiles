---
description: Save current session work details for handoff to next session or other developers
---

# セッション引き継ぎ情報の保存: $ARGUMENTS

## 引数（ARGUMENTS）

保存オプション：

```bash
# 引数なし - デフォルトファイル名で保存
save-session

# カスタムサフィックス付きで保存
save-session "feature-implementation"    # → YYYY-MM-DD-feature-implementation.md
save-session "bug-fix"                  # → YYYY-MM-DD-bug-fix.md
save-session "morning"                  # → YYYY-MM-DD-morning.md
```

## 目標

現在のセッションの作業内容を体系的に記録し、次のセッション（または他の開発者）が効率的に作業を継続できるようにする

## 実行手順

### 1. ファイル名の決定

```bash
# 基本の日付と時刻を取得
DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
HOUR=$(perl -MPOSIX -le 'print strftime("%H", localtime)')

# ファイル名の生成と重複チェック
if [ -z "$ARGUMENTS" ]; then
    BASE_NAME="${DATE}-${HOUR}-handoff"
else
    # 引数からサフィックスを生成（スペースをハイフンに変換）
    SUFFIX=$(echo "$ARGUMENTS" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    BASE_NAME="${DATE}-${HOUR}-${SUFFIX}"
fi

# ディレクトリの確認と作成
mkdir -p ai/log/sessions

# 重複チェックと番号付け
FILENAME="ai/log/sessions/${BASE_NAME}.md"
COUNTER=2

while [ -f "$FILENAME" ]; do
    FILENAME="ai/log/sessions/${BASE_NAME}-${COUNTER}.md"
    ((COUNTER++))
done

# 既存ファイルの確認
EXISTING_FILES=$(ls -1 ai/log/sessions/${DATE}-*.md 2>/dev/null | wc -l)
if [ $EXISTING_FILES -gt 0 ]; then
    echo "既存のセッションファイル:"
    ls -1t ai/log/sessions/${DATE}-*.md | head -5 | sed 's|ai/log/sessions/||'
    echo ""
fi
```

### 2. 現在のセッション情報を収集

```bash
# 現在の日時
CURRENT_DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
CURRENT_TIME=$(perl -MPOSIX -le 'print strftime("%H:%M (JST)", localtime)')

# Git情報
CURRENT_BRANCH=$(git branch --show-current)
CHANGED_FILES=$(git diff --name-only | wc -l | tr -d ' ')
STAGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')

# 今日のコミット数
TODAY_COMMITS=$(git log --since="midnight" --oneline | wc -l | tr -d ' ')
```

### 3. TodoList の状態を確認

TodoRead ツールを使用して現在のタスク状態を取得：
- 完了したタスク（completed）
- 進行中のタスク（in_progress）
- 未着手のタスク（pending）

### 4. 実施した作業の要約

```bash
# 今日のコミットログを取得
git log --since="midnight" --oneline

# 変更されたファイルの詳細
git diff --name-status

# 実装・修正内容の確認
git show --stat
```

### 5. 引き継ぎドキュメントの作成

以下の形式でドキュメントを作成し、`$FILENAME` に保存：

```markdown
# セッション引き継ぎ: [日付]

## セッション概要
- 日時: [開始時刻] - [終了時刻] (JST)
- ブランチ: [ブランチ名]
- 主な作業: [1行要約]

## 完了した作業
[TodoListのcompletedタスクと実際の実装内容]

## 進行中の作業
### 現在の状態
[TodoListのin_progressタスクの詳細な説明]

### 次のステップ
[具体的なアクション]

## 未完了タスク
[TodoListのpendingタスクから重要なもの]

## 技術的な情報
### 重要な決定事項
[このセッションでの設計決定]

### 発見した課題
[技術的な制限事項や問題点]

## 推奨される次のアクション
1. [優先度高]
2. [優先度中]
3. [優先度低]

## 参考情報
- 関連ログ: [他のログファイルへのパス]
- 参考URL: [調査したドキュメントなど]
- 作成したファイル: [新規作成・大幅変更したファイル]
```

### 6. 保存確認とサマリー表示

```bash
# ファイルが正常に作成されたか確認
if [ -f "$FILENAME" ]; then
    echo "================================================================================
セッション情報を保存しました: $FILENAME
================================================================================

【保存内容のサマリー】
- 完了タスク: [X]件
- 進行中タスク: [Y]件
- 未完了タスク: [Z]件
- 変更ファイル: ${CHANGED_FILES}個
- ステージ済み: ${STAGED_FILES}個
- 今日のコミット: ${TODAY_COMMITS}個

次回セッション開始時は以下のコマンドで読み込めます:
load-session

特定のセッションを読み込む場合:
load-session $(basename $FILENAME .md)"
else
    echo "エラー: セッション情報の保存に失敗しました"
    exit 1
fi
```

### 7. CLAUDE.md の更新提案

恒久的に記録すべき情報がある場合、以下を確認：

1. **新しい技術的発見**
   - `ai/knowledge/learnings/` への追記を提案

2. **重要な設計決定**
   - `ai/knowledge/decisions/` への記録を提案

3. **繰り返し使えるパターン**
   - `ai/knowledge/patterns/` への追加を提案

4. **プロジェクト固有の制約**
   - CLAUDE.md への追記を提案

## エラーハンドリング

1. **ディレクトリが存在しない場合**
   - 自動的に `ai/log/sessions/` を作成

2. **ファイルが既に存在する場合**
   - 上書き確認プロンプトを表示
   - タイムスタンプ付きの別名を提案

3. **Git リポジトリでない場合**
   - Git 関連情報をスキップ
   - 警告メッセージを表示

## 使用例

```bash
# デフォルトのファイル名で保存（14時の場合）
save-session                        # → 2025-01-01-14-handoff.md
save-session                        # → 2025-01-01-14-handoff-2.md （既存の場合）
save-session                        # → 2025-01-01-14-handoff-3.md （既存の場合）

# 作業内容を示すサフィックス付きで保存（10時の場合）
save-session "refactoring"         # → 2025-01-01-10-refactoring.md
save-session "refactoring"         # → 2025-01-01-10-refactoring-2.md （既存の場合）
save-session "bug fix login"       # → 2025-01-01-10-bug-fix-login.md
save-session "morning session"     # → 2025-01-01-10-morning-session.md
```

## 関連コマンド

- `load-session`: 保存したセッション情報を読み込む
- `todo`: TodoListの管理
- `git log`: コミット履歴の確認
