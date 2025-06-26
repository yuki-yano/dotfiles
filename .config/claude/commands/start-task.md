---
description: Review project state, past work, and important information before starting new task to understand context
---

# 新しいタスクの開始時にプロジェクト状態を一括参照

## 目標

新しいタスクを開始する前に、プロジェクトの現在の状態、過去の作業履歴、重要な情報を一括で参照し、コンテキストを把握する

## 手順（順番に実行）

ステップ 1. **プロジェクト固有の指示を確認**
- `CLAUDE.md` を読み込んでプロジェクト固有のルールを確認
- `.config/claude/CLAUDE.md` があれば追加で確認

ステップ 2. **既存のタスクと問題点を確認**
- TodoList を確認して未完了のタスクを把握
- `ai/log/` ディレクトリの最新ファイルを確認（最大5件）
- `ai/issues/active/` の問題を確認
- `ai/plans/active/` の実行中計画を確認
- `ai/knowledge/context/project-context.md` でプロジェクト概要を確認

ステップ 3. **最近の変更履歴を確認**
- `git log --oneline -10` で最近のコミットを確認
- `git status` で現在の作業状態を確認
- `git diff --stat` でステージされていない変更を確認

ステップ 4. **プロジェクト構造の把握**
- プロジェクトのREADMEを確認（存在する場合）
- 主要なディレクトリ構造を `ls -la` で確認
- package.json、Gemfile、requirements.txt などの依存関係ファイルを確認

ステップ 5. **状態サマリーの作成**
以下の形式でサマリーを表示:
- 現在のブランチと作業状態
- 未完了のタスク（TodoList から）
- 最近の主な変更（コミット履歴から）
- 注意すべき問題点や制約事項
- 推奨される次のアクション
