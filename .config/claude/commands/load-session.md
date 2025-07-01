---
description: Load a session handoff document to understand previous work context
---

# セッション引き継ぎ情報の読み込み: $ARGUMENTS

## 引数（ARGUMENTS）

セッションの指定方法：

```bash
# 引数なし - 直近のセッションを読み込む
load-session

# 日付指定
load-session 2025-01-01
load-session "2025-01-01"

# 相対指定
load-session latest    # 最新のセッション
load-session yesterday # 昨日のセッション
load-session 2         # 2番目に新しいセッション
```

## 目標

以前のセッションの作業内容を読み込み、現在のコンテキストを理解して作業を継続できるようにする

## 実行手順

### 1. セッションファイルの特定

```bash
# 引数の解析
if [ -z "$ARGUMENTS" ] || [ "$ARGUMENTS" = "latest" ]; then
    # 最新のセッションファイルを検索
    ls -t ai/log/sessions/*-handoff.md 2>/dev/null | head -1
elif [ "$ARGUMENTS" = "yesterday" ]; then
    # 昨日の日付を取得
    YESTERDAY=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime(time - 86400))')
    echo "ai/log/sessions/${YESTERDAY}-handoff.md"
elif [[ "$ARGUMENTS" =~ ^[0-9]+$ ]]; then
    # N番目に新しいファイルを取得
    ls -t ai/log/sessions/*-handoff.md 2>/dev/null | sed -n "${ARGUMENTS}p"
else
    # 日付として解釈（YYYY-MM-DD形式に正規化）
    if [[ "$ARGUMENTS" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "ai/log/sessions/${ARGUMENTS}-handoff.md"
    else
        # 日付のフォーマット変換を試みる
        date -j -f "%Y%m%d" "$ARGUMENTS" "+ai/log/sessions/%Y-%m-%d-handoff.md" 2>/dev/null
    fi
fi
```

### 2. ファイルの存在確認と読み込み

```bash
# セッションファイルが存在するか確認
if [ ! -f "$SESSION_FILE" ]; then
    echo "セッションファイルが見つかりません: $SESSION_FILE"
    
    # 利用可能なセッションをリスト表示
    echo -e "\n利用可能なセッション:"
    ls -t ai/log/sessions/*-handoff.md 2>/dev/null | head -10 | while read file; do
        basename "$file" .md
    done
    exit 1
fi

# ファイルを読み込んで表示
cat "$SESSION_FILE"
```

### 3. セッション情報の解析と表示

読み込んだセッションファイルから以下の情報を抽出して整理：

1. **セッション概要**
   - 作業日時
   - 使用していたブランチ
   - 主な作業内容

2. **完了した作業**
   - 実装された機能
   - 修正されたバグ
   - 作成されたファイル

3. **未完了の作業**
   - 進行中だったタスク
   - 発見された課題
   - 次のステップ

4. **技術的な情報**
   - 重要な決定事項
   - 採用されたアプローチ
   - 注意すべき点

### 4. 現在の状態との比較

```bash
# 現在のブランチを確認
CURRENT_BRANCH=$(git branch --show-current)

# セッションのブランチと比較
if [ "$CURRENT_BRANCH" != "$SESSION_BRANCH" ]; then
    echo "注意: セッションのブランチ($SESSION_BRANCH)と現在のブランチ($CURRENT_BRANCH)が異なります"
fi

# 該当期間のコミットを確認
git log --oneline --since="$SESSION_DATE" --until="$SESSION_DATE 23:59:59"
```

### 5. TodoListとの統合

セッションファイルに記載された未完了タスクを現在のTodoListに反映するか確認：

```
前回のセッションから以下の未完了タスクがあります：
1. [タスク1]
2. [タスク2]

これらをTodoListに追加しますか？ [y/N]
```

### 6. 関連ファイルの確認

セッションファイルで言及されている関連ログやドキュメントも確認：

```bash
# 関連ログファイルの存在確認
grep -E "ai/log|関連ログ" "$SESSION_FILE" | while read -r line; do
    # パスを抽出して存在確認
    if [[ "$line" =~ (ai/log/[^ ]+) ]]; then
        FILE="${BASH_REMATCH[1]}"
        if [ -f "$FILE" ]; then
            echo "関連ファイル: $FILE (存在)"
        else
            echo "関連ファイル: $FILE (見つかりません)"
        fi
    fi
done
```

## 出力形式

```
================================================================================
セッション引き継ぎ情報: 2025-01-01
================================================================================

【セッション概要】
- 日時: 2025-01-01 10:00 - 18:00 (JST)
- ブランチ: feature/new-functionality
- 主な作業: 新機能の実装とテスト

【完了した作業】
✓ 基本的な機能の実装
✓ ユニットテストの作成
✓ ドキュメントの更新

【未完了タスク】
□ インテグレーションテスト
□ パフォーマンス最適化
□ エラーハンドリングの改善

【技術的な注意点】
- APIの制限により、並列処理は最大5まで
- メモリ使用量に注意が必要

【推奨される次のアクション】
1. インテグレーションテストの実装から開始
2. パフォーマンスボトルネックの特定
3. エラーケースの網羅的なテスト

================================================================================

現在のブランチ: main (※セッションと異なります)
TodoListへの未完了タスクの追加を推奨します。
```

## エラーハンドリング

1. **ファイルが見つからない場合**
   - 利用可能なセッションファイルをリスト表示
   - 日付フォーマットのヒントを提供

2. **セッションディレクトリが存在しない場合**
   - ディレクトリの作成を提案
   - session-handoffコマンドの使用を促す

3. **読み込みエラー**
   - ファイルの権限を確認
   - 破損の可能性を警告

## 使用例

```bash
# 最新のセッションを読み込む
load-session

# 特定の日付のセッションを読み込む
load-session 2025-01-01

# 2番目に新しいセッションを読み込む
load-session 2

# 昨日のセッションを読み込む
load-session yesterday
```

## 関連コマンド

- `session-handoff`: セッション引き継ぎ情報を作成
- `todo`: TodoListの管理
- `git log`: コミット履歴の確認