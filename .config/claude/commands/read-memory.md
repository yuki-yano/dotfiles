---
description: Read and review project memory bank including learnings, decisions, issues, and work logs
---

# プロジェクトメモリーバンクの読み込み

## 目標

プロジェクトのメモリーバンク（学習事項、決定事項、問題、作業ログ）を読み込み、現在の状態と過去の知識を総合的に確認する

## 実行モード

```bash
# 標準モード（すべてのメモリーを確認）
read-memory

# カテゴリ指定モード（特定の情報のみ）
read-memory --learning    # 学習事項のみ
read-memory --issues      # 問題のみ
read-memory --decisions   # 決定事項のみ
read-memory --logs        # 作業ログのみ

# 期間指定モード
read-memory --recent      # 直近7日間
read-memory --today       # 本日のみ
read-memory --since "2025-01-01"  # 特定日以降

# 検索モード
read-memory --search "TypeScript"  # キーワード検索
read-memory --tag "learning"       # タグ検索
```

## 読み込みプロセス

### 1. メモリーバンク構造の確認

以下のディレクトリから情報を並列で収集：

```bash
# メモリーバンクのディレクトリ構造
MEMORY_DIRS=(
    "ai/knowledge/learnings"    # 学習事項
    "ai/knowledge/decisions"    # 決定事項
    "ai/knowledge/patterns"     # パターン
    "ai/knowledge/context"      # コンテキスト
    "ai/issues/active"          # アクティブな問題
    "ai/issues/resolved"        # 解決済みの問題
    "ai/issues/blocked"         # ブロック中の問題
    "ai/log/features"           # 機能実装ログ
    "ai/log/fixes"              # 修正ログ
    "ai/log/tests"              # テストログ
    "ai/log/sessions"           # セッションログ
    "ai/log/nippo"              # 日報
    "ai/plans/active"           # アクティブな計画
    "ai/plans/completed"        # 完了した計画
)

# 日付の取得
DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
WEEK_AGO=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime(time-604800))')
```

### 2. プロジェクト固有設定の確認

```bash
# CLAUDE.md ファイルを確認
if [ -f "CLAUDE.md" ]; then
    echo "プロジェクト固有の指示を確認"
    head -20 CLAUDE.md
fi

if [ -f ".config/claude/CLAUDE.md" ]; then
    echo "追加のClaude設定を確認"
    head -20 .config/claude/CLAUDE.md
fi
```

### 3. 構造化されたメモリー出力

```markdown
================================================================================
📚 プロジェクトメモリーバンク
================================================================================

## 📊 メモリー統計
- **総ドキュメント数**: [総数]
- **最終更新**: [日時]
- **今週の追加**: [件数]
- **アクティブな問題**: [件数]

## 🧠 知識ベース

### 学習事項 ([件数])
最新の学習:
- **[日付]** [タイトル]: [概要]
- **[日付]** [タイトル]: [概要]
- **[日付]** [タイトル]: [概要]

### アーキテクチャ決定 ([件数])
重要な決定:
- **[日付]** [決定内容]: [理由]
- **[日付]** [決定内容]: [理由]

### パターン・ベストプラクティス ([件数])
- [パターン名]: [説明]
- [パターン名]: [説明]

## 🔧 作業ログ

### 最近の機能実装 ([件数])
- **[日付]** [機能名]: [概要]
- **[日付]** [機能名]: [概要]

### 最近の修正 ([件数])
- **[日付]** [修正内容]: [対象問題]
- **[日付]** [修正内容]: [対象問題]

### 本日の活動（日報より）
[日報の内容サマリー]

## ⚠️ 問題管理

### アクティブな問題 ([件数])
- 🔴 **Critical**: [問題名] - [概要]
- 🟡 **High**: [問題名] - [概要]
- 🟢 **Medium**: [問題名] - [概要]

### ブロッカー ([件数])
- [ブロッカー内容]: [影響範囲]

### 最近解決した問題 ([件数])
- ✅ **[日付]** [問題名]: [解決方法]
- ✅ **[日付]** [問題名]: [解決方法]

## 📋 計画とタスク

### アクティブな計画 ([件数])
- [計画名]: [進捗状況]
- [計画名]: [進捗状況]

### 完了した計画（直近）
- ✓ **[日付]** [計画名]: [成果]

## 🔍 推奨参照

### 今のコンテキストで重要な文書
1. [ドキュメント名]: [理由]
2. [ドキュメント名]: [理由]
3. [ドキュメント名]: [理由]

================================================================================
```

### 4. カテゴリ別読み込み機能

特定のカテゴリに絞って効率的に情報を取得：

#### 学習事項の読み込み（--learning）
```bash
if [ "$MODE" = "learning" ]; then
    echo "================================================================================
    🧠 学習事項メモリー
    ================================================================================"
    
    # 最新の学習事項を表示
    for file in $(ls -t ai/knowledge/learnings/*.md | head -10); do
        echo "### $(basename $file .md)"
        grep -A 3 "## 概要" "$file" | tail -n 3
        echo ""
    done
    
    # タグ別集計
    echo "### タグ別分類"
    grep -h "タグ:" ai/knowledge/learnings/*.md | sort | uniq -c | sort -nr
fi
```

#### 問題の読み込み（--issues）
```bash
if [ "$MODE" = "issues" ]; then
    echo "================================================================================
    ⚠️ 問題メモリー
    ================================================================================"
    
    echo "### アクティブな問題"
    for file in $(ls ai/issues/active/*.md 2>/dev/null); do
        SEVERITY=$(grep "重要度:" "$file" | cut -d' ' -f2)
        TITLE=$(head -1 "$file" | sed 's/# //')
        echo "- [$SEVERITY] $TITLE"
    done
    
    echo -e "\n### ブロッカー"
    for file in $(ls ai/issues/blocked/*.md 2>/dev/null); do
        TITLE=$(head -1 "$file" | sed 's/# //')
        BLOCKER=$(grep -A 1 "## ブロッカー" "$file" | tail -1)
        echo "- $TITLE: $BLOCKER"
    done
fi
```

#### 決定事項の読み込み（--decisions）
```bash
if [ "$MODE" = "decisions" ]; then
    echo "================================================================================
    📋 アーキテクチャ決定メモリー
    ================================================================================"
    
    for file in $(ls -t ai/knowledge/decisions/*.md | head -10); do
        TITLE=$(head -1 "$file" | sed 's/# //')
        DECISION=$(grep -A 2 "## 決定内容" "$file" | tail -n 2)
        echo "### $TITLE"
        echo "$DECISION"
        echo ""
    done
fi
```

### 5. 検索機能（--search）

キーワードやタグでメモリーバンク全体を検索：

```bash
if [ "$MODE" = "search" ]; then
    KEYWORD="$SEARCH_TERM"
    echo "================================================================================
    🔍 検索結果: '$KEYWORD'
    ================================================================================"
    
    # ファイル名での検索
    echo "### ファイル名にマッチ"
    find ai/ -name "*$KEYWORD*.md" -type f | while read file; do
        echo "- $file"
    done
    
    # 内容での検索
    echo -e "\n### 内容にマッチ"
    rg -l "$KEYWORD" ai/ --type md | while read file; do
        echo -e "\n📄 $file"
        rg -C 2 "$KEYWORD" "$file" | head -10
    done
    
    # タグ検索
    if [[ "$KEYWORD" =~ ^#.* ]]; then
        echo -e "\n### タグ検索結果"
        grep -l "タグ:.*$KEYWORD" ai/**/*.md | while read file; do
            echo "- $file"
        done
    fi
fi
```

### 6. 期間指定読み込み（--recent, --today, --since）

```bash
# 直近7日間
if [ "$MODE" = "recent" ]; then
    echo "================================================================================
    📅 直近7日間のメモリー
    ================================================================================"
    
    find ai/ -name "*.md" -mtime -7 -type f | sort -t/ -k3,3r -k4,4r | while read file; do
        CATEGORY=$(echo $file | cut -d'/' -f2-3)
        DATE=$(basename $file | cut -d'-' -f1-3)
        TITLE=$(head -1 "$file" 2>/dev/null | sed 's/# //')
        echo "[$DATE] [$CATEGORY] $TITLE"
    done
fi

# 本日のみ
if [ "$MODE" = "today" ]; then
    echo "================================================================================
    📅 本日のメモリー
    ================================================================================"
    
    find ai/ -name "${DATE}-*.md" -type f | while read file; do
        CATEGORY=$(echo $file | cut -d'/' -f2-3)
        TIME=$(stat -f "%Sm" -t "%H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)
        TITLE=$(head -1 "$file" 2>/dev/null | sed 's/# //')
        echo "[$TIME] [$CATEGORY] $TITLE"
    done
fi

# 特定日以降
if [ "$MODE" = "since" ]; then
    SINCE_DATE="$SINCE_VALUE"
    echo "================================================================================
    📅 ${SINCE_DATE} 以降のメモリー
    ================================================================================"
    
    find ai/ -name "*.md" -newermt "$SINCE_DATE" -type f | sort | while read file; do
        FILE_DATE=$(basename $file | cut -d'-' -f1-3)
        CATEGORY=$(echo $file | cut -d'/' -f2-3)
        TITLE=$(head -1 "$file" 2>/dev/null | sed 's/# //')
        echo "[$FILE_DATE] [$CATEGORY] $TITLE"
    done
fi
```

### 7. インテリジェントサマリー

収集した情報を基に、現在のコンテキストで最も重要な情報を要約：

```markdown
## 💡 メモリーインサイト

### 知識の蓄積状況
- **総知識数**: [学習事項 + 決定事項 + パターンの合計]
- **今週の学習**: [今週追加された学習事項数]
- **活用頻度の高い知識**: [参照が多いドキュメント]

### 問題解決の傾向
- **平均解決時間**: [active → resolved の平均日数]
- **未解決期間が長い問題**: [最も古いアクティブ問題]
- **頻出する問題パターン**: [類似問題の傾向]

### 作業パターン分析
- **最も活発な時間帯**: [コミット時間から分析]
- **得意分野**: [学習事項のタグから分析]
- **改善が必要な領域**: [問題が多い領域]

### 推奨アクション
1. **すぐに参照すべき知識**
   - [関連する学習事項へのリンク]
   - [適用可能なパターンへのリンク]

2. **注意が必要な問題**
   - [長期未解決の問題]
   - [ブロッカーとなっている問題]

3. **次の学習機会**
   - [問題から見えてくる学習必要領域]
   - [決定事項に基づく深堀りポイント]
```

## エラーハンドリング

1. **メモリーバンクが存在しない場合**
   ```bash
   if [ ! -d "ai/" ]; then
       echo "⚠️ メモリーバンクが見つかりません"
       echo "以下のコマンドで初期化してください:"
       echo "mkdir -p ai/{knowledge/{learnings,decisions,patterns,context},issues/{active,resolved,blocked},log/{features,fixes,tests,sessions,nippo},plans/{active,completed}}"
   fi
   ```

2. **メモリーが空の場合**
   ```bash
   if [ $(find ai/ -name "*.md" | wc -l) -eq 0 ]; then
       echo "💭 メモリーバンクは空です"
       echo "update-memory コマンドで記録を開始してください"
   fi
   ```

3. **検索結果が見つからない場合**
   ```bash
   if [ -z "$SEARCH_RESULTS" ]; then
       echo "🔍 '$KEYWORD' に一致する結果が見つかりませんでした"
       echo "類似キーワードで再検索することをお勧めします"
   fi
   ```

## 使用例

```bash
# すべてのメモリーを読み込み
read-memory

# 学習事項のみ確認
read-memory --learning

# アクティブな問題を確認
read-memory --issues

# 最近の決定事項を確認
read-memory --decisions

# 今日の作業ログを確認
read-memory --today

# 直近1週間のメモリー
read-memory --recent

# 特定日以降のメモリー
read-memory --since "2025-01-01"

# キーワード検索
read-memory --search "TypeScript"

# タグ検索
read-memory --tag "#learning"

# 組み合わせ使用
read-memory --learning --recent
read-memory --issues --search "error"
```

## パフォーマンス最適化

- 並列読み込みによる高速化
- カテゴリ別フィルタリングで必要な情報のみ取得
- インデックスファイルによる検索の高速化
- 日付ベースのファイル名による効率的なソート

## メモリーバンクの活用ベストプラクティス

1. **定期的な読み込み**
   - 作業開始時に `read-memory --recent` で最近の活動を確認
   - 問題解決前に `read-memory --learning --search "関連キーワード"` で過去の知識を確認

2. **カテゴリの使い分け**
   - 学習事項: 新しく理解した技術や仕組み
   - 決定事項: プロジェクトの方針やルール
   - パターン: 繰り返し使える解決策
   - 問題: 未解決の課題やバグ

3. **効果的な検索**
   - タグを活用した分類（#frontend, #backend, #testing など）
   - キーワードは具体的に（"エラー" より "TypeScript 型エラー"）
   - 期間指定で関連性の高い情報に絞る
