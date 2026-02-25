---
name: detect-code-duplication
description: similarity-ts を使って TypeScript/JavaScript の重複コードを検知し、優先度付きのリファクタリング計画を作成する。ユーザーが「重複を検出したい」「類似コードを整理したい」「リファクタリング計画を作りたい」と依頼したときに使う。
---

# Detect Code Duplication

## Overview

重複コード検知を再現可能な手順で実行し、`docs/plans/active/` に優先度付きの計画を出力する。
生ログは `docs/tmp/duplication/runs/<run-id>/` に保存し、計画書と分離する。

## Output Policy

- 生ログ: `docs/tmp/duplication/runs/<run-id>/similarity-report.txt`
- 実行メタ情報: `docs/tmp/duplication/runs/<run-id>/scan-meta.env`
- 計画（作成時）: `docs/plans/active/refactor-duplications-<run-id>.md`
- 計画（完了時）: `docs/plans/completed/`
- 計画（中止時）: `docs/plans/cancelled/`
- 常に `mkdir -p` で出力先を作成する。
- `ai/tmp` や `tmp/ai` には書き込まない。

## Plan States

- `active`: 新規作成または進行中の計画
- `completed`: 実施完了した計画
- `cancelled`: 中止した計画

状態変更はファイル内容の編集よりも、ディレクトリ移動を優先する。

## Workflow

1. 前提を確認する
- `similarity-ts` の有無を確認する。
- 未導入なら次を案内する。
  - `mise` がある場合: `mise use -g cargo:similarity-ts@latest`
  - `mise` がない場合: `cargo install similarity-ts`

2. スキャンを実行する
- `scripts/run_scan.sh [target_path]` を実行する。
- 既定値:
  - `--threshold 0.60` 相当（環境変数 `SIMILARITY_THRESHOLD` で上書き可）
  - 拡張子 `ts,tsx,js,jsx`
  - 最小行数 `3`
- 除外: `node_modules`, `dist`, `build`, `coverage`, `.git`, `docs/tmp`
- 除外ディレクトリ配下を `target_path` で直接指定した場合もエラー終了する。
- 除外ディレクトリを意図的に対象にする場合のみ `SIMILARITY_ALLOW_EXCLUDED_TARGET=1` を指定する。
- スクリプト出力の `REPORT_PATH` と `PLAN_PATH` を控える。
- 対象に TS/JS ファイルが 0 件の場合、スクリプトはエラー終了する。

3. 結果を分析する
- `REPORT_PATH` を読み、重複候補を優先度分類する。
- 分類基準は `references/priority-policy.md` を使う。
- 意図的重複（テストデータ、型定義の互換維持、生成コードなど）は「維持理由付き」で除外候補として記録する。

4. 計画を作成する
- `references/plan-template.md` を元に `PLAN_PATH` へ計画を書く。
- 計画には必ず以下を含める。
  - 実行日時、対象、閾値
  - 高/中/低優先度の候補一覧
  - 実装順序（フェーズ）
  - 実行可能なタスクチェックリスト
- TodoList ツール前提にはしない。計画書内のタスクとして完結させる。

5. 計画の状態を更新する
- 実施開始後も `active/` のまま管理する。
- 完了したら `状態: completed` に更新して同名ファイルを `completed/` へ移動する。
- 中止したら `状態: cancelled` に更新して同名ファイルを `cancelled/` へ移動する。

6. 結果を報告する
- ユーザーには次を簡潔に返す。
  - スキャン概要（検出件数、優先度別件数）
  - `REPORT_PATH`
  - `PLAN_PATH`
  - 実施前の注意点（テスト影響、API互換性など）

## Priority Rules

優先度の標準判定は次を使う。

- 高: 類似度 `>= 0.80` かつ 3 箇所以上に波及、またはクリティカル経路に存在
- 中: 類似度 `0.70 - 0.79` で 2 箇所以上に波及
- 低: 類似度 `0.60 - 0.69` の重複

より広く候補を拾う必要がある場合のみ `SIMILARITY_THRESHOLD=0.40` を使う。
その場合はノイズ増加を明記する。

## Resources

- `scripts/run_scan.sh`: スキャン実行、出力先作成、パス通知を行う。
- `references/priority-policy.md`: 優先度判定基準の詳細。
- `references/plan-template.md`: 計画書テンプレート。
