---
description: Fetch and analyze PR review comments to identify patterns and prepare responses
---

# PRレビュー分析

## 目標

プルリクエストのレビューコメントを取得し、指摘事項を分析して対応策を検討する

## 手順（厳密に従うこと）

ステップ 1. **PR番号の特定**
- 引数が指定された場合: `$ARGUMENTS` を使用
- 引数が未指定の場合:
  - 現在のブランチ名を取得: `git branch --show-current`
  - 現在のブランチに関連するPRを検索: `gh pr list --head $(git branch --show-current) --json number -q '.[0].number'`
  - PRが見つからない場合はエラーメッセージを表示して終了

ステップ 2. **PR情報の取得**
- `mcp__github__get_pull_request` でPRの基本情報を確認（GitHub MCP優先）
- 代替: `gh pr view [PR番号]`
- PRのステータス、作成者、タイトルを把握

ステップ 3. **レビューコメントの取得**
- `mcp__github__get_pull_request_reviews` でレビューを取得
- `mcp__github__get_pull_request_comments` でコメントを取得
- 代替: `gh pr view [PR番号] --comments`

ステップ 4. **変更内容の確認**
- `mcp__github__get_pull_request_diff` でdiffを取得
- `mcp__github__get_pull_request_files` で変更ファイル一覧を取得
- 代替: `gh pr diff [PR番号]`

ステップ 5. **指摘事項の分析**
以下のカテゴリに分類:
- **コードスタイル**: フォーマット、命名規則など
- **ロジック/バグ**: 潜在的なバグ、エッジケース
- **パフォーマンス**: 効率性の改善提案
- **セキュリティ**: セキュリティ上の懸念
- **設計/アーキテクチャ**: 構造的な改善提案
- **テスト**: テストカバレッジ、テストケース
- **ドキュメント**: コメント、READMEの改善

ステップ 6. **分析レポートの作成**
`ai/log/analysis/YYYY-MM-DD-pr-review-[PR番号].md` に以下を記録:
```markdown
# PR #[PR番号] レビュー分析

## PR概要
- タイトル: [PRタイトル]
- 作成者: [作成者]
- ステータス: [ステータス]
- 変更ファイル数: [数]

## レビュー指摘事項

### 必須対応事項
[ブロッカーとなる指摘]

### 推奨対応事項
[改善が望ましい指摘]

### 検討事項
[議論が必要な指摘]

## 対応計画
[各指摘への具体的な対応方法]

## 学習ポイント
[今後のコーディングに活かせる点]
```

ステップ 7. **対応準備**
- 必須対応事項から優先順位を付ける
- 各指摘に対する具体的な修正案を準備
- 必要に応じて追加の調査や検証を実施

## 注意事項

- レビュアーの意図を正確に理解する
- 建設的な議論を心がける
- 指摘の背景にある理由を理解する
- 同様の問題を将来避けるための学習機会として捉える