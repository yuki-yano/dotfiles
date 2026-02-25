# validate-impl

## 目的

実装結果が要件・設計・タスクに整合しているかを検証し、GO/NO-GOを判定する。

## 入力

- 任意: `feature_name`
- 任意: `task_numbers`（例: `["1.1", "1.2"]`）

## 前提確認

1. 対象仕様の `spec.json`, `requirements.md`, `design.md`, `tasks.md` が存在すること。
2. 実装済みタスクが少なくとも1件あること（`- [x]`）。

## 対象決定

1. `feature_name` 指定あり:
   - 指定機能のみ検証する。
2. `feature_name` 未指定:
   - `./docs/sdd/specs/` から `tasks.md` に `- [x]` がある機能を抽出する。
3. `task_numbers` 指定あり:
   - 指定タスクのみ検証する。
4. `task_numbers` 未指定:
   - 完了済みタスク（`- [x]`）を対象とする。

## 読み込みコンテキスト

1. `./docs/sdd/specs/<feature-name>/spec.json`
2. `./docs/sdd/specs/<feature-name>/requirements.md`
3. `./docs/sdd/specs/<feature-name>/design.md`
4. `./docs/sdd/specs/<feature-name>/tasks.md`
5. `./docs/sdd/steering/product.md`, `tech.md`, `structure.md`
6. `./docs/sdd/steering/*.md`（カスタム）

## 実行手順

1. タスク完了状態の検証
   - 対象タスクが `- [x]` であるか確認する。
2. テスト検証
   - 対象実装に対応するテストが存在するか確認する。
   - プロジェクトのテストコマンドを実行し、失敗有無を記録する。
3. 要件トレーサビリティ検証
   - 各対象タスクが参照する要件ID（`_Requirements: ..._`）を抽出する。
   - 実装・テストに要件の根拠があるか確認する。
4. 設計整合検証
   - `design.md` の構成要素・インターフェースと実装が一致するか確認する。
5. 回帰検証
   - 既存テストの破壊的失敗がないか確認する。
6. 重大度分類
   - `Critical`: テスト失敗、要件未実装、重大な設計逸脱
   - `Warning`: 軽微な設計差分、追補可能な不足
7. GO/NO-GO判定
   - `Critical` が1件でもあれば NO-GO
   - `Critical` が0件なら GO

## 出力

1. 検証対象（feature / task）
2. 検証サマリー（pass/fail件数）
3. 問題一覧（重要度、該当箇所、修正方針）
4. カバレッジ要約（要件/設計/タスク）
5. 最終判定（GO/NO-GO）

## 実行ルール

1. 判定は `spec.json.language` を優先して記述する。
2. テスト実行不可の場合は理由を明示し、NO-GO相当として扱う。
3. 問題報告には必ず再現手掛かり（ファイルやタスク番号）を含める。
