---
description: Organize and record work progress, learnings, and important decisions in AI work directories
---

# プロジェクトのメモリーバンクを更新: $ARGUMENTS

## 目標

作業の進捗、学習した内容、重要な決定事項をプロジェクトのメモリーバンクに記録し、将来の参照のために整理する

## 実行モード

```bash
# 標準モード（全カテゴリの更新）
update-memory "作業内容の説明"

# 特定カテゴリモード
update-memory --learning "新しい学習事項"
update-memory --issue "発見した問題"
update-memory --decision "アーキテクチャ決定"
update-memory --fix "実装した修正"

# 一括更新モード（複数カテゴリ）
update-memory --bulk "複数の更新内容"

# 日報モード
update-memory --nippo
```

## 更新プロセス

### 1. 並列情報収集フェーズ

```bash
# 現在の状態を並列で収集
parallel_commands=(
    "git status --porcelain"
    "git log --oneline -5"
    "git diff --cached --name-only"
    "ls -t ai/log/**/*.md 2>/dev/null | head -3"
    "ls ai/issues/active/*.md 2>/dev/null | wc -l"
    "find ai/knowledge -name '*.md' -mtime -7 | wc -l"
)

# 現在の日付とタイムスタンプを取得
DATE=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d", localtime)')
TIMESTAMP=$(perl -MPOSIX -le 'print strftime("%Y-%m-%d %H:%M:%S (JST)", localtime)')
```

### 2. カテゴリ分析と自動分類

#### 自動カテゴリ判定ロジック

```bash
# キーワードベースの自動分類
if [[ "$ARGUMENTS" =~ (学んだ|理解した|わかった|発見した仕組み) ]]; then
    CATEGORY="learning"
elif [[ "$ARGUMENTS" =~ (バグ|問題|エラー|不具合|issue) ]]; then
    CATEGORY="issue"
elif [[ "$ARGUMENTS" =~ (修正|改善|解決|fix|resolve) ]]; then
    CATEGORY="fix"
elif [[ "$ARGUMENTS" =~ (決定|決めた|方針|ポリシー|ルール) ]]; then
    CATEGORY="decision"
elif [[ "$ARGUMENTS" =~ (TODO|後で|将来|予定|計画) ]]; then
    CATEGORY="todo"
else
    CATEGORY="general"
fi
```

### 3. ディレクトリ構造の確認と作成

```bash
# 必要なディレクトリ構造
AI_DIRS=(
    "ai/log/features"
    "ai/log/fixes"
    "ai/log/tests"
    "ai/log/sessions"
    "ai/log/nippo"
    "ai/knowledge/learnings"
    "ai/knowledge/decisions"
    "ai/knowledge/patterns"
    "ai/knowledge/context"
    "ai/issues/active"
    "ai/issues/resolved"
    "ai/issues/blocked"
    "ai/plans/active"
    "ai/plans/completed"
)

# ディレクトリ作成（存在しない場合のみ）
for dir in "${AI_DIRS[@]}"; do
    mkdir -p "$dir"
done
```

### 4. カテゴリ別のファイル作成

#### 学習事項（Learning）
```bash
if [ "$CATEGORY" = "learning" ]; then
    FILENAME="ai/knowledge/learnings/${DATE}-${BRIEF_DESC}.md"
    cat > "$FILENAME" << EOF
# ${TITLE}

**日付**: ${TIMESTAMP}
**カテゴリ**: 学習事項
**タグ**: #learning #${PROJECT_AREA}
**関連ファイル**: ${RELATED_FILES}

## 概要
${SUMMARY}

## 学習内容
${DETAILS}

### キーポイント
- ${KEY_POINT_1}
- ${KEY_POINT_2}
- ${KEY_POINT_3}

## 実装例
\`\`\`${LANGUAGE}
${CODE_EXAMPLE}
\`\`\`

## 参考リンク
- ${REFERENCE_1}
- ${REFERENCE_2}

## 今後の活用
${FUTURE_USE}
EOF
fi
```

#### 問題記録（Issue）
```bash
if [ "$CATEGORY" = "issue" ]; then
    FILENAME="ai/issues/active/${DATE}-${BRIEF_DESC}.md"
    cat > "$FILENAME" << EOF
# ${TITLE}

**日付**: ${TIMESTAMP}
**カテゴリ**: 問題
**重要度**: ${SEVERITY} (Critical/High/Medium/Low)
**ステータス**: Active
**関連ファイル**: ${RELATED_FILES}

## 問題の概要
${PROBLEM_SUMMARY}

## 再現手順
1. ${STEP_1}
2. ${STEP_2}
3. ${STEP_3}

## エラー詳細
\`\`\`
${ERROR_MESSAGE}
\`\`\`

## 影響範囲
- ${IMPACT_1}
- ${IMPACT_2}

## 調査内容
${INVESTIGATION}

## 解決案
### オプション1
${SOLUTION_OPTION_1}

### オプション2
${SOLUTION_OPTION_2}

## ブロッカー
${BLOCKERS}

## 次のアクション
- [ ] ${ACTION_1}
- [ ] ${ACTION_2}
EOF
fi
```

#### 修正記録（Fix）
```bash
if [ "$CATEGORY" = "fix" ]; then
    FILENAME="ai/log/fixes/${DATE}-${BRIEF_DESC}.md"
    # 対応する問題を resolved に移動
    if [ -f "ai/issues/active/${ISSUE_FILE}" ]; then
        mv "ai/issues/active/${ISSUE_FILE}" "ai/issues/resolved/"
    fi
    
    cat > "$FILENAME" << EOF
# ${TITLE}

**日付**: ${TIMESTAMP}
**カテゴリ**: 修正
**修正対象問題**: ${ISSUE_REFERENCE}
**関連PR/コミット**: ${COMMIT_HASH}

## 修正内容
${FIX_SUMMARY}

## 変更内容
### 変更前
\`\`\`${LANGUAGE}
${BEFORE_CODE}
\`\`\`

### 変更後
\`\`\`${LANGUAGE}
${AFTER_CODE}
\`\`\`

## 修正理由
${FIX_REASON}

## テスト結果
- [ ] ユニットテスト: ${TEST_RESULT}
- [ ] 統合テスト: ${INTEGRATION_TEST}
- [ ] 手動確認: ${MANUAL_CHECK}

## 影響確認
${IMPACT_CHECK}

## 今後の改善点
${IMPROVEMENT_NOTES}
EOF
fi
```

#### 決定事項（Decision）
```bash
if [ "$CATEGORY" = "decision" ]; then
    FILENAME="ai/knowledge/decisions/${DATE}-${BRIEF_DESC}.md"
    cat > "$FILENAME" << EOF
# ${TITLE}

**日付**: ${TIMESTAMP}
**カテゴリ**: アーキテクチャ決定
**決定者**: Claude Code + User
**ステータス**: Accepted
**影響範囲**: ${SCOPE}

## 背景
${CONTEXT}

## 決定内容
${DECISION}

## 理由
### 採用理由
- ${REASON_1}
- ${REASON_2}

### 却下した代替案
1. **${ALTERNATIVE_1}**
   - 理由: ${REJECTION_REASON_1}
2. **${ALTERNATIVE_2}**
   - 理由: ${REJECTION_REASON_2}

## 実装ガイドライン
\`\`\`${LANGUAGE}
${IMPLEMENTATION_GUIDE}
\`\`\`

## 影響と結果
### ポジティブな影響
- ${POSITIVE_1}
- ${POSITIVE_2}

### トレードオフ
- ${TRADEOFF_1}
- ${TRADEOFF_2}

## 参考資料
- ${REFERENCE_1}
- ${REFERENCE_2}
EOF
fi
```

### 5. 日報モード（--nippo）

```bash
if [ "$MODE" = "nippo" ]; then
    NIPPO_FILE="ai/log/nippo/${DATE}.md"
    
    # 既存の日報があれば追記、なければ新規作成
    if [ ! -f "$NIPPO_FILE" ]; then
        cat > "$NIPPO_FILE" << EOF
# 日報 - ${DATE}

**作成日時**: ${TIMESTAMP}
**プロジェクト**: ${PROJECT_NAME}
**作業者**: Claude Code + User

## 本日の作業概要
EOF
    fi
    
    # 本日の活動を自動収集
    cat >> "$NIPPO_FILE" << EOF

### ${TIMESTAMP} 更新

#### 実施内容
${WORK_SUMMARY}

#### コミット
\`\`\`bash
$(git log --oneline --since="midnight" --until="now")
\`\`\`

#### 作成/更新ファイル
\`\`\`bash
$(git diff --name-only HEAD@{midnight} HEAD)
\`\`\`

#### 解決した問題
$(ls ai/issues/resolved/${DATE}-*.md 2>/dev/null | xargs -I {} basename {} .md)

#### 新規課題
$(ls ai/issues/active/${DATE}-*.md 2>/dev/null | xargs -I {} basename {} .md)

#### 学習事項
$(ls ai/knowledge/learnings/${DATE}-*.md 2>/dev/null | xargs -I {} basename {} .md)

#### 明日への申し送り
- ${HANDOVER_1}
- ${HANDOVER_2}

---
EOF
fi
```

### 6. 相互参照とリンク生成

```bash
# 関連ファイルの自動リンク生成
generate_cross_references() {
    local current_file=$1
    local related_files=$(git grep -l "$(basename $current_file .md)" ai/ | grep -v "$current_file")
    
    if [ -n "$related_files" ]; then
        echo "## 関連ドキュメント" >> "$current_file"
        for file in $related_files; do
            echo "- [$(basename $file .md)](../../$file)" >> "$current_file"
        done
    fi
}
```

### 7. CLAUDE.md 更新チェック

```bash
# 恒久的なルールかどうかを判定
check_claude_update() {
    if [[ "$CATEGORY" = "decision" ]] || [[ "$CONTENT" =~ (必ず|常に|ルール|規約) ]]; then
        echo "================================================================================
🔔 CLAUDE.md 更新推奨
================================================================================

以下の内容をCLAUDE.mdに追加することを推奨します:

\`\`\`markdown
## ${SECTION_TITLE}

${CLAUDE_CONTENT}
\`\`\`

更新する場合: Edit CLAUDE.md
スキップする場合: 続行
"
    fi
}
```

### 8. 統合サマリーの生成

```bash
# 更新完了後のサマリー
generate_summary() {
    echo "================================================================================
📝 メモリーバンク更新完了
================================================================================

## 更新内容
- **カテゴリ**: ${CATEGORY}
- **作成ファイル**: ${CREATED_FILES[@]}
- **更新ファイル**: ${UPDATED_FILES[@]}

## 統計情報
- **総ドキュメント数**: $(find ai/ -name '*.md' | wc -l)
- **アクティブな問題**: $(ls ai/issues/active/*.md 2>/dev/null | wc -l)
- **今週の更新**: $(find ai/ -name '*.md' -mtime -7 | wc -l)

## 推奨アクション
1. ${RECOMMENDED_ACTION_1}
2. ${RECOMMENDED_ACTION_2}

## TodoList 更新提案
- [ ] ${TODO_SUGGESTION_1}
- [ ] ${TODO_SUGGESTION_2}

================================================================================
"
}
```

## エラーハンドリング

1. **ディレクトリ作成失敗**
   ```bash
   if ! mkdir -p "$dir" 2>/dev/null; then
       echo "⚠️ ディレクトリ作成失敗: $dir"
       echo "権限を確認してください"
   fi
   ```

2. **Git リポジトリでない場合**
   ```bash
   if ! git rev-parse --git-dir > /dev/null 2>&1; then
       echo "⚠️ Git リポジトリではありません"
       # Git 関連の処理をスキップ
   fi
   ```

3. **ファイル書き込み失敗**
   ```bash
   if ! echo "$content" > "$filename" 2>/dev/null; then
       echo "⚠️ ファイル書き込み失敗: $filename"
       # 代替パスを提案
   fi
   ```

## パフォーマンス最適化

- テンプレートのプリロードによる高速化
- 並列処理による情報収集の効率化
- インクリメンタルな更新による最小限の処理

## 使用例

```bash
# 学習事項の記録
update-memory --learning "Neovim の LSP 設定方法を理解した"

# 問題の記録
update-memory --issue "TypeScript の型推論でエラーが発生"

# 修正の記録
update-memory --fix "型推論エラーを generics で解決"

# 決定事項の記録
update-memory --decision "コンポーネントは全て関数型で実装する"

# 日報の更新
update-memory --nippo

# 一括更新
update-memory --bulk "今日は認証機能を実装し、JWTトークンの仕組みを学んだ。セッション管理の方針も決定した。"
```
