---
description: Execute web search using Google Gemini CLI to get latest information and solutions
---

# Gemini Web検索: $ARGUMENTS

## 概要

Google Gemini CLIを使用してWeb検索を実行します。**Web検索が必要な場合は、必ず組み込みの `Web_Search` ツールではなく、Task Tool経由でこのコマンドを使用してください。**

## 使用方法

### 基本構文
```bash
gemini --prompt "WebSearch: <検索クエリ>"
```

### 実行手順

1. **検索クエリの最適化**
   - 検索内容: $ARGUMENTS
   - 必要に応じてキーワードを追加（エラーコード、バージョン番号など）
   - 言語指定が必要な場合は明示的に含める

2. **Task Toolでの実行**
   ```bash
   gemini --prompt "WebSearch: $ARGUMENTS"
   ```

3. **結果の活用**
   - 信頼できる情報源（公式ドキュメント、Stack Overflow等）を優先
   - 情報の新しさを確認（特に技術仕様は変更が多い）
   - 重要な発見は `ai/knowledge/learnings/` に記録

## 重要な注意事項

- **必須**: Task Toolを使用してgeminiコマンドを実行する
- **必須**: `--prompt` フラグと "WebSearch: " プレフィックスを使用
- **推奨**: 検索クエリには具体的なエラーメッセージやバージョン情報を含める
- **推奨**: 技術的な検索では英語のキーワードも併用する
- **記録**: 有用な情報は適切なAI作業ディレクトリに保存する
