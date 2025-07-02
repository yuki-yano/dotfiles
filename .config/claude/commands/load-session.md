---
description: Load a session handoff document to understand previous work context
---

# セッション引き継ぎ情報の読み込み: $ARGUMENTS

## 引数（ARGUMENTS）

セッションの指定方法：

```bash
# 引数なし - 直近のセッションを読み込む
load-session

# 日付指定（その日のhandoffファイルを読み込む）
load-session 2025-01-01
load-session "2025-01-01"

# 特定のサフィックスを指定
load-session 2025-01-01-morning     # 特定のセッションファイル
load-session morning                # 今日のmorningセッション

# 相対指定
load-session latest    # 最新のセッション（全ファイル対象）
load-session yesterday # 昨日のセッション（handoffのみ）
load-session 2         # 2番目に新しいセッション（全ファイル対象）

# 複数セッション指定
load-session "2025-01-01 2025-01-02"           # 複数の日付
load-session "morning afternoon"                # 今日の複数セッション
load-session "2025-01-01-morning yesterday"    # 混在も可能

# リスト表示
load-session list      # 利用可能なセッション一覧
```

## 目標

以前のセッションの作業内容を読み込み、現在のコンテキストを理解して作業を継続できるようにする

## 実行手順

### 1. セッションファイルの特定

```bash
# セッションファイル解決用の関数
resolve_session_file() {
    local ARG="$1"
    local FILE=""
    
    if [ "$ARG" = "yesterday" ]; then
        YESTERDAY=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime(time - 86400))')
        FILE="ai/log/sessions/${YESTERDAY}-handoff.md"
    elif [[ "$ARG" =~ ^[0-9]+$ ]]; then
        FILE=$(ls -t ai/log/sessions/*.md 2>/dev/null | sed -n "${ARG}p")
    elif [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-(.+)$ ]]; then
        FILE="ai/log/sessions/${ARG}.md"
    elif [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        DATE="$ARG"
        if [ -f "ai/log/sessions/${DATE}-handoff.md" ]; then
            FILE="ai/log/sessions/${DATE}-handoff.md"
        else
            FILE=$(ls -t ai/log/sessions/${DATE}-*.md 2>/dev/null | head -1)
        fi
    else
        TODAY=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
        FILE="ai/log/sessions/${TODAY}-${ARG}.md"
    fi
    
    echo "$FILE"
}

# 引数の解析
if [ "$ARGUMENTS" = "list" ]; then
    # 利用可能なセッション一覧を表示
    echo "利用可能なセッション:"
    echo "===================="
    ls -t ai/log/sessions/*.md 2>/dev/null | head -20 | while read file; do
        BASENAME=$(basename "$file" .md)
        # ファイルの最初の見出しを取得
        TITLE=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //')
        echo "$BASENAME - $TITLE"
    done
    exit 0
fi

# 複数セッションの処理をサポート
SESSION_FILES=()

# 引数がスペースを含む場合は複数指定として処理
if [[ "$ARGUMENTS" =~ " " ]]; then
    # スペースで分割して各要素を処理
    IFS=' ' read -ra ARGS <<< "$ARGUMENTS"
    for ARG in "${ARGS[@]}"; do
        FILE=$(resolve_session_file "$ARG")
        if [ -n "$FILE" ] && [ -f "$FILE" ]; then
            SESSION_FILES+=("$FILE")
        fi
    done
else
    # 単一セッションの処理
    ARG="$ARGUMENTS"
    
    if [ -z "$ARG" ] || [ "$ARG" = "latest" ]; then
        # 最新のセッションファイルを検索（すべての.mdファイル）
        SESSION_FILE=$(ls -t ai/log/sessions/*.md 2>/dev/null | head -1)
    elif [ "$ARG" = "yesterday" ]; then
        # 昨日の日付を取得（handoffファイルのみ）
        YESTERDAY=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime(time - 86400))')
        SESSION_FILE="ai/log/sessions/${YESTERDAY}-handoff.md"
    elif [[ "$ARG" =~ ^[0-9]+$ ]]; then
        # N番目に新しいファイルを取得（すべての.mdファイル）
        SESSION_FILE=$(ls -t ai/log/sessions/*.md 2>/dev/null | sed -n "${ARG}p")
    elif [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-(.+)$ ]]; then
        # 完全なファイル名（日付+サフィックス）が指定された場合
        SESSION_FILE="ai/log/sessions/${ARG}.md"
    elif [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # 日付のみ指定された場合（その日のhandoffファイルを優先）
        DATE="$ARG"
        if [ -f "ai/log/sessions/${DATE}-handoff.md" ]; then
            SESSION_FILE="ai/log/sessions/${DATE}-handoff.md"
        else
            # handoffがない場合は、その日の最初のファイルを選択
            SESSION_FILE=$(ls -t ai/log/sessions/${DATE}-*.md 2>/dev/null | head -1)
        fi
    else
        # サフィックスのみ指定された場合（今日の該当ファイル）
        TODAY=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
        SESSION_FILE="ai/log/sessions/${TODAY}-${ARG}.md"
    fi
    
    if [ -n "$SESSION_FILE" ]; then
        SESSION_FILES=("$SESSION_FILE")
    fi
fi
```

### 2. ファイルの存在確認と読み込み

```bash
# 複数セッションモードの場合
if [ ${#SESSION_FILES[@]} -gt 1 ]; then
    echo "================================================================================
複数セッションを読み込みます: ${#SESSION_FILES[@]}件
================================================================================"
    
    MISSING_FILES=()
    for FILE in "${SESSION_FILES[@]}"; do
        if [ ! -f "$FILE" ]; then
            MISSING_FILES+=("$FILE")
        fi
    done
    
    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        echo "警告: 以下のファイルが見つかりません:"
        for FILE in "${MISSING_FILES[@]}"; do
            echo "- $(basename "$FILE")"
        done
        echo ""
    fi
    
    # 各セッションを順番に表示
    for i in "${!SESSION_FILES[@]}"; do
        FILE="${SESSION_FILES[$i]}"
        if [ -f "$FILE" ]; then
            echo ""
            echo "================================================================================
セッション $((i+1))/${#SESSION_FILES[@]}: $(basename "$FILE" .md)
================================================================================
"
            cat "$FILE"
            
            # 最後のファイルでなければ区切り線を追加
            if [ $i -lt $((${#SESSION_FILES[@]} - 1)) ]; then
                echo -e "\n\n"
            fi
        fi
    done
    
# 単一セッションモードの場合
else
    SESSION_FILE="${SESSION_FILES[0]:-}"
    
    # セッションファイルが存在するか確認
    if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
        echo "セッションファイルが見つかりません: ${SESSION_FILE:-指定されたファイル}"
        
        # 利用可能なセッションをリスト表示
        echo -e "\n利用可能なセッション（最新10件）:"
        echo "=================================="
        ls -t ai/log/sessions/*.md 2>/dev/null | head -10 | while read file; do
            BASENAME=$(basename "$file" .md)
            # ファイルの最初の見出しを取得
            TITLE=$(grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //')
            echo "$BASENAME"
            [ -n "$TITLE" ] && echo "  └─ $TITLE"
        done
        
        echo -e "\n使用方法のヒント:"
        echo "- 最新のセッション: load-session"
        echo "- 日付指定: load-session 2025-01-01"
        echo "- 特定のセッション: load-session 2025-01-01-morning"
        echo "- 複数指定: load-session \"morning afternoon\""
        echo "- 一覧表示: load-session list"
        exit 1
    fi
    
    # ファイル情報を表示
    echo "================================================================================
セッションファイル: $(basename "$SESSION_FILE" .md)
================================================================================
"
    
    # ファイルを読み込んで表示
    cat "$SESSION_FILE"
fi
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
   - save-sessionコマンドの使用を促す

3. **読み込みエラー**
   - ファイルの権限を確認
   - 破損の可能性を警告

## 使用例

```bash
# 最新のセッションを読み込む（すべてのファイル対象）
load-session

# 特定の日付のセッションを読み込む（handoff優先）
load-session 2025-01-01

# 特定のセッションファイルを読み込む
load-session 2025-01-01-morning
load-session 2025-01-01-feature-implementation

# 今日の特定セッションを読み込む
load-session morning
load-session refactoring

# 複数のセッションを一度に読み込む
load-session "2025-01-01 2025-01-02"              # 2日分の日報
load-session "morning afternoon"                   # 今日の朝と午後のセッション
load-session "2025-01-01-morning 2025-01-01-afternoon"  # 特定日の複数セッション
load-session "yesterday 2"                         # 昨日と2番目に新しいセッション

# 2番目に新しいセッションを読み込む
load-session 2

# 昨日のセッションを読み込む
load-session yesterday

# 利用可能なセッション一覧を表示
load-session list
```

## 関連コマンド

- `save-session`: セッション引き継ぎ情報を保存
- `todo`: TodoListの管理
- `git log`: コミット履歴の確認
- `nippo-show`: 日報を表示