# spec-impl

## 目的

Kent Beck流TDD（RED/GREEN/REFACTOR）で仕様タスクを実装する。

## 入力

- 必須: `feature_name`
- 任意: `task_numbers`（対象タスク番号配列）

## 前提確認

1. `requirements.md`, `design.md`, `tasks.md`, `spec.json` が存在すること。
2. 対象タスクの実行条件を満たすこと。
   - `task_numbers` 未指定: 未完了タスクが少なくとも1件あること。
   - `task_numbers` 指定: 指定タスクが `tasks.md` に存在すること（完了済み/未完了は問わない）。
3. `spec.json` で以下を満たすこと。
   - `approvals.tasks.approved = true`
   - `ready_for_implementation = true`

## コンテキスト読み込み

### コアステアリング

- `./docs/sdd/steering/structure.md`
- `./docs/sdd/steering/tech.md`
- `./docs/sdd/steering/product.md`

### カスタムステアリング

- 上記3ファイル以外の `./docs/sdd/steering/*.md`

### 仕様文書

- `./docs/sdd/specs/<feature-name>/spec.json`
- `./docs/sdd/specs/<feature-name>/requirements.md`
- `./docs/sdd/specs/<feature-name>/design.md`
- `./docs/sdd/specs/<feature-name>/tasks.md`

## 実行手順

1. 実装開始可否を確認する。
   - 承認条件を満たさない場合は停止し、`spec-status <feature-name>` とタスク承認を案内する。
2. 実装対象を確定する。
   - `task_numbers` 未指定: 未完了全件
   - `task_numbers` 指定: 該当タスクのみ（完了済みタスクの修正実装を含む）
3. すべての文脈（ステアリング + 仕様文書）を読み込む。
4. 各タスクでTDDを実施する。
   - RED: 失敗するテストを先に書く
   - GREEN: テストを通す最小実装を行う
   - REFACTOR: 構造改善し、テストを維持する
5. 検証を実施する。
   - 対象テストが全て成功
   - 既存テストに回帰がない
   - 品質とカバレッジを維持
6. `tasks.md` の該当チェックを `- [x]` へ更新する。

## 出力

- 実装コードとテストコード
- 更新済み `tasks.md`

## 実装ノート

1. `feature_name` は固定識別子として扱う。
2. `task_numbers` は部分実装モードとして扱う。
3. 仕様外の機能追加は行わない。
4. 実装はタスク要件に限定する。
5. `approvals.tasks.approved=true` になるまで実装へ進まない。
6. 完了済みタスクを再実装した場合も `tasks.md` の `- [x]` を維持し、修正内容に対応するテストを更新する。
