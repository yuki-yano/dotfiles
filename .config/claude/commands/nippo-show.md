---
description: Show daily report for today or specified date
---

# 日報を表示: $ARGUMENTS

## 引数（ARGUMENTS）

表示オプション：

```bash
# 引数なし - 今日の日報を表示
nippo-show

# 特定の日付を指定
nippo-show 2025-01-01
nippo-show yesterday
nippo-show 3           # 3日前の日報

# 期間指定
nippo-show week        # 今週の日報一覧
nippo-show last-week   # 先週の日報一覧
nippo-show month       # 今月の日報一覧

# フォーマット指定
nippo-show --format slack      # Slack投稿用
nippo-show --format summary    # 要約のみ
```

## 目標

作成した日報を様々な形式で表示し、振り返りや共有を支援する

## 実行手順

### 1. 表示対象の特定

```bash
# 引数の解析
if [ -z "$ARGUMENTS" ]; then
    # 今日の日報
    DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
    MODE="single"
elif [ "$ARGUMENTS" = "yesterday" ]; then
    DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime(time - 86400))')
    MODE="single"
elif [[ "$ARGUMENTS" =~ ^[0-9]+$ ]]; then
    # N日前
    DATE=$(perl -MPOSIX -le "print strftime('%Y-%m-%d', localtime(time - $ARGUMENTS * 86400))")
    MODE="single"
elif [ "$ARGUMENTS" = "week" ]; then
    MODE="week"
elif [ "$ARGUMENTS" = "last-week" ]; then
    MODE="last-week"
elif [ "$ARGUMENTS" = "month" ]; then
    MODE="month"
elif [[ "$ARGUMENTS" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    DATE="$ARGUMENTS"
    MODE="single"
fi
```

### 2. 単一日付の表示（MODE=single）

```bash
FILENAME="ai/log/nippo/${DATE}.md"

# ファイルの存在確認
if [ ! -f "$FILENAME" ]; then
    echo "日報が見つかりません: $DATE"
    
    # 直近の日報を検索
    echo -e "\n利用可能な日報:"
    ls -t ai/log/nippo/*.md 2>/dev/null | head -10 | while read file; do
        basename "$file" .md
    done
    exit 1
fi

# 日報を表示
cat "$FILENAME"
```

### 3. 期間表示（週次・月次）

#### 週次表示（MODE=week/last-week）

```bash
# 今週または先週の日付範囲を計算
if [ "$MODE" = "week" ]; then
    # 今週の月曜日を取得
    START_DATE=$(perl -MPOSIX -le '
        my $t = time;
        my @lt = localtime($t);
        my $wday = $lt[6];
        my $monday = $t - ($wday == 0 ? 6 : $wday - 1) * 86400;
        print strftime("%Y-%m-%d", localtime($monday));
    ')
    END_DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
else
    # 先週の月曜日と日曜日を取得
    START_DATE=$(perl -MPOSIX -le '
        my $t = time;
        my @lt = localtime($t);
        my $wday = $lt[6];
        my $last_monday = $t - ($wday == 0 ? 6 : $wday - 1) * 86400 - 7 * 86400;
        print strftime("%Y-%m-%d", localtime($last_monday));
    ')
    END_DATE=$(perl -MPOSIX -le '
        my $t = time;
        my @lt = localtime($t);
        my $wday = $lt[6];
        my $last_sunday = $t - ($wday == 0 ? 6 : $wday - 1) * 86400 - 86400;
        print strftime("%Y-%m-%d", localtime($last_sunday));
    ')
fi

echo "================================================================================
日報サマリー: $START_DATE 〜 $END_DATE
================================================================================"

# 期間内の日報を一覧表示
for i in {0..6}; do
    CURRENT_DATE=$(perl -MPOSIX -le "use Time::Local; my \@t = split('-', '$START_DATE'); my \$epoch = timelocal(0,0,0,\$t[2],\$t[1]-1,\$t[0]); print strftime('%Y-%m-%d', localtime(\$epoch + $i * 86400))")
    FILENAME="ai/log/nippo/${CURRENT_DATE}.md"
    
    if [ -f "$FILENAME" ]; then
        echo -e "\n📅 $CURRENT_DATE"
        echo "--------------------------------------------------------------------------------"
        # 主要な項目のみ抽出して表示
        grep -E "^### .* - |^- ✅|^- 🔄" "$FILENAME" | head -10
    else
        echo -e "\n📅 $CURRENT_DATE - 日報なし"
    fi
done
```

#### 月次表示（MODE=month）

今月の日報を俯瞰的に表示：

```
2025年1月の日報サマリー
================================================================================

第1週（1/1-1/7）
- 1/1 (水): ✅ 5件完了 | 主要: 新機能実装開始
- 1/2 (木): ✅ 3件完了 | 主要: バグ修正
- 1/3 (金): 日報なし

第2週（1/8-1/14）
...
```

### 4. フォーマット別表示

#### Slack形式（--format slack）

```bash
if [[ "$ARGUMENTS" == *"--format slack"* ]]; then
    # Slack用にフォーマット変換
    echo "\`\`\`"
    echo "【日報】$DATE"
    echo ""
    
    # 主要セクションを抽出
    awk '/^## 📊 進捗状況/,/^##/' "$FILENAME" | grep -E "^- ✅|^- 🔄"
    
    echo ""
    echo "詳細: [日報リンク]"
    echo "\`\`\`"
fi
```

#### サマリー形式（--format summary）

```bash
if [[ "$ARGUMENTS" == *"--format summary"* ]]; then
    echo "【$DATE の概要】"
    echo "- 完了: $(grep -c "^- ✅" "$FILENAME")件"
    echo "- 進行中: $(grep -c "^- 🔄" "$FILENAME")件"
    echo "- 作業時間: $(head -n 50 "$FILENAME" | grep "^###" | head -1 | cut -d' ' -f2) 〜 $(grep "^###" "$FILENAME" | tail -1 | cut -d' ' -f2)"
    
    echo -e "\n主な成果:"
    grep "^- ✅" "$FILENAME" | head -3
fi
```

### 5. 統計情報の表示

日報の最後に統計情報を追加：

```
================================================================================
【統計情報】
- 作業ログ数: X件
- 最初の記録: HH:MM
- 最後の記録: HH:MM
- 主な作業: 実装(40%), レビュー(30%), MTG(20%), その他(10%)
- 関連Issue/PR: #123, #456, PR#789
================================================================================
```

### 6. エクスポート機能

```bash
# オプション: 日報をクリップボードにコピー
if [[ "$ARGUMENTS" == *"--copy"* ]]; then
    cat "$FILENAME" | pbcopy
    echo "日報をクリップボードにコピーしました"
fi

# オプション: 日報をPDFに変換（pandocが必要）
if [[ "$ARGUMENTS" == *"--pdf"* ]]; then
    pandoc "$FILENAME" -o "${FILENAME%.md}.pdf"
    echo "PDFを生成しました: ${FILENAME%.md}.pdf"
fi
```

## 表示のカスタマイズ

### 1. ハイライト表示

重要なキーワードを色付けして表示：
- 🟢 完了項目（✅）
- 🟡 進行中項目（🔄）
- 🔴 課題・ブロッカー（⚠️）

### 2. フィルタリング

特定のカテゴリのみ表示：
```bash
nippo-show --filter implementation  # 実装関連のみ
nippo-show --filter review         # レビュー関連のみ
nippo-show --filter meeting        # ミーティング関連のみ
```

### 3. 検索機能

```bash
# 全日報から検索
nippo-show --search "TypeScript"   # TypeScriptに関する記述を検索
nippo-show --search "#123"         # Issue #123に関する作業を検索
```

## エラーハンドリング

1. **日報が存在しない場合**
   - 直近の利用可能な日報をリスト表示
   - 日付フォーマットのヒントを提供

2. **ディレクトリが存在しない場合**
   - nippo-add の使用を促す
   - ディレクトリ作成を提案

3. **表示エラー**
   - ファイルの破損チェック
   - バックアップからの復元を提案

## 使用例

```bash
# 今日の日報を確認
nippo-show

# 先週の振り返り
nippo-show last-week

# 特定の日の日報をSlack用にコピー
nippo-show 2025-01-01 --format slack --copy

# 今月の作業を俯瞰
nippo-show month

# TypeScript関連の作業を検索
nippo-show --search "TypeScript"
```

## 関連コマンド

- `nippo-add`: 作業記録を追加
- `nippo-finalize`: 日報を完成させる
- `load-session`: セッション情報を読み込む