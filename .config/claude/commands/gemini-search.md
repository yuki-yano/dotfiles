---
description: Execute web search using Google Gemini CLI to get latest information and solutions
---

# Gemini Web検索: $ARGUMENTS

## 目標

Google Gemini CLIを使用してWeb検索を実行し、最新の情報や解決策を取得する

## 手順（順番に実行）

ステップ 1. **検索クエリの準備**
- 検索内容: $ARGUMENTS
- 必要に応じてクエリを最適化（キーワードの追加、言語指定など）

ステップ 2. **検索の実行**
- Task Toolを使用してGemini検索を実行:
```bash
gemini -p "WebSearch: $ARGUMENTS"
```

ステップ 3. **結果の分析**
- 返された検索結果を評価
- 信頼できる情報源を優先
- 最新の情報かどうかを確認

ステップ 4. **情報の活用**
- 得られた情報を現在のタスクに適用
- 必要に応じて追加の検索を実行
- 重要な発見は `ai/knowledge/learnings/` に記録

## 使用例
- エラーメッセージの検索
- ライブラリの使用方法
- ベストプラクティスの調査
- 最新の技術動向の確認