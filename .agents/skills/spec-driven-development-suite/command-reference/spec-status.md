# spec-status

## 目的

仕様の現在地を可視化する。  
`feature_name` 指定時は詳細、未指定時は仕様一覧を返す。

## 入力

- 任意: `feature_name`

## 前提確認

1. `feature_name` 指定時:
   - `./docs/sdd/specs/<feature-name>/spec.json` が存在すること。
2. `feature_name` 未指定時:
   - `./docs/sdd/specs/` を列挙できること。
3. `./docs/sdd/steering/` を参照可能であること（存在しない場合は警告を出して継続）。

## 読み込み対象

1. `feature_name` 指定時:
   - `./docs/sdd/specs/<feature-name>/spec.json`
   - `./docs/sdd/specs/<feature-name>/requirements.md`（存在時）
   - `./docs/sdd/specs/<feature-name>/design.md`（存在時）
   - `./docs/sdd/specs/<feature-name>/research.md`（存在時）
   - `./docs/sdd/specs/<feature-name>/tasks.md`（存在時）
2. `feature_name` 未指定時:
   - `./docs/sdd/specs/*/spec.json`
   - `./docs/sdd/specs/*/tasks.md`（存在時）
3. 共通:
   - `./docs/sdd/steering/product.md`, `tech.md`, `structure.md`（存在時）
   - `./docs/sdd/steering/*.md`（コア3ファイル以外を全件）

## 実行手順

1. `feature_name` 指定時（詳細モード）:
   - `feature_name`, `phase`, `updated_at` を抽出する。
   - `approvals.requirements/design/tasks` と `ready_for_implementation` を抽出する。
   - `tasks.md` の `- [x]` / `- [ ]` を集計する。
   - ブロッカー（未承認フェーズ、欠落成果物）を明示する。
   - 次アクションを1つ提示する。
2. `feature_name` 未指定時（一覧モード）:
   - `./docs/sdd/specs/` 配下の仕様を列挙する。
   - 各仕様について `feature_name`, `phase`, `updated_at`, 承認状態、タスク進捗を集計する。
   - 停滞中・未承認・未着手をブロッカーとして抽出する。
   - 優先度付きの次アクションを最大3件提示する。
3. steering 文脈との差分があれば注記する。
   - 例: 技術方針の未反映、構成ルールとの乖離候補

## 出力フォーマット

1. 詳細モード（`feature_name` 指定時）
   - 仕様概要
   - 承認状態
   - タスク進捗
   - ブロッカー
   - 次アクション
2. 一覧モード（`feature_name` 未指定時）
   - 仕様一覧（`feature_name`, `phase`, 承認, 進捗, 更新時刻）
   - 要対応項目
   - 次アクション（最大3件）

## 実行ルール

1. 詳細モードの表示言語は `spec.json.language` を優先する。
2. 一覧モードはユーザー発話言語（既定: `ja`）で返す。
3. 数値は実ファイルから再計算し、推定値を使わない。
4. ブロッカーは曖昧語で隠さず明示する。
5. 一覧モードで仕様が0件なら `spec-init` 実行を案内する。
6. steering が未整備の場合は、`steering` / `steering-custom` の実行を次アクションに含める。
