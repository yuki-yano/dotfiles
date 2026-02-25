# spec-tasks

## 目的

`design.md` を実装可能なタスクへ分解し、`tasks.md` を生成する。

## 入力

- 必須: `feature_name`
- 任意: `auto_approve`（`-y` 相当）
- 任意: `sequential`（`--sequential` 相当、既定は `false`）

## 前提確認

1. 要件・設計が生成済みであること。
2. `auto_approve=false` の場合は要件・設計が承認済みであること。
3. `tasks.md` 既存時は 上書き / 統合 / 中止 を選択すること。

## 読み込み対象

1. `./docs/sdd/specs/<feature-name>/requirements.md`
2. `./docs/sdd/specs/<feature-name>/design.md`
3. `./docs/sdd/specs/<feature-name>/tasks.md`（存在時）
4. `./docs/sdd/steering/product.md`, `tech.md`, `structure.md`
5. `./docs/sdd/steering/*.md`（カスタム）

## タスク生成ルール

1. 階層は最大2段（`1`, `1.1`）までとする。
2. 各サブタスクに `_Requirements: X.X, Y.Y_` を付与する。
3. 全要件IDが少なくとも1つのタスクへ対応することを確認する。
4. タスクは自然言語で成果を記述し、実装詳細の直接記述を避ける。
5. サブタスクの目安は 1〜3時間とする。

## 並列実行ルール（`sequential=false` の場合）

1. 並列可能タスクには番号直後に `(P)` を付与する。
   - 例: `- [ ] 2.1 (P) ...`
2. 並列可能の条件
   - データ依存がない
   - 共有リソース競合がない
   - 他タスクの承認待ちがない
3. `sequential=true` の場合は `(P)` を付与しない。

## `spec.json` 更新

1. `phase = "tasks-generated"`
2. `approvals.tasks = { "generated": true, "approved": false }`
3. `auto_approve=true` の場合:
   - `approvals.requirements.approved = true`
   - `approvals.design.approved = true`
4. `ready_for_implementation = false`
5. `updated_at` を更新する。

## 出力

- `./docs/sdd/specs/<feature-name>/tasks.md`

## 実行ルール

1. 承認運用は `workflow-playbook.md` の「2.1 承認記録（自然言語）」を適用する。
2. 要件未網羅がある場合は確定せず、要件/設計フェーズへの差し戻しを案内する。
3. 生成後は `spec-status <feature-name>` で進行条件を確認する。
