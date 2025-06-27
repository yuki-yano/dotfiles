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

## 使用例

### エラー解決
```bash
gemini --prompt "WebSearch: TypeError: Cannot read property 'map' of undefined React"
```

### ライブラリの使用方法
```bash
gemini --prompt "WebSearch: Next.js 14 App Router middleware 使い方"
```

### ベストプラクティス調査
```bash
gemini --prompt "WebSearch: TypeScript monorepo 構成 2025 ベストプラクティス"
```

### 最新技術動向
```bash
gemini --prompt "WebSearch: Deno 2.0 新機能 マイグレーションガイド"
```

### トラブルシューティング
```bash
gemini --prompt "WebSearch: npm ERR! ERESOLVE unable to resolve dependency tree"
```

## 重要な注意事項

- **必須**: Task Toolを使用してgeminiコマンドを実行する
- **必須**: `--prompt` フラグと "WebSearch: " プレフィックスを使用
- **推奨**: 検索クエリには具体的なエラーメッセージやバージョン情報を含める
- **推奨**: 技術的な検索では英語のキーワードも併用する
- **記録**: 有用な情報は適切なAI作業ディレクトリに保存する

## 活用のコツ

- エラーメッセージは可能な限り完全な形で検索
- ライブラリ名とバージョンを明記すると精度が向上
- 複数の検索を組み合わせて情報を検証
- 公式ドキュメントへのリンクは特に重要