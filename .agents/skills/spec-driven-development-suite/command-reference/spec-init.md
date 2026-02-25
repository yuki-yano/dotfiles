# spec-init

## 目的

詳細なプロジェクト説明から、新規仕様の初期構造とメタデータを作成する。

## 入力

- 必須: `project_description`

## スコープ

このモードは「仕様の初期化」までを担当する。  
`design.md` と `tasks.md` は後続モードで作成する。

## 前提確認と準備

1. `./docs/sdd/specs/` が存在しない場合は作成する。
2. `project_description` から `feature_name` をケバブケースで生成する。
3. 同名がある場合は数値サフィックスを付与して衝突回避する。
4. 生成した `feature_name` を以後の全フェーズで固定利用する。

## 実行手順

1. `./docs/sdd/specs/<feature-name>/` を作成する。
2. `spec.json` を以下方針で初期化する。
   - `phase = "initialized"`
   - `language = "ja"`（必要に応じて変更可）
   - `approvals.requirements/design/tasks` は全て `generated=false`, `approved=false`
   - `ready_for_implementation = false`
   - `approval_log = []`
3. `requirements.md` 雛形を作成する。
   - 入力説明（`project_description`）を残す
   - 要件本体は後続で生成する前提コメントを置く
4. ステータス追跡のため `created_at` と `updated_at` をISO8601で設定する。

## 出力

- `./docs/sdd/specs/<feature-name>/spec.json`
- `./docs/sdd/specs/<feature-name>/requirements.md`

## 更新ルール

- `spec.json.phase` は `initialized`。
- `approvals.requirements/design/tasks` は全て `generated=false`, `approved=false`。
- `approval_log` は空配列で初期化する。

## 初期化後の次アクション

厳密なフェーズ順序で進める。

1. `spec-requirements <feature-name>`（要件生成）
2. `spec-design <feature-name>`（要件承認後）
3. `spec-tasks <feature-name>`（設計承認後）

## 出力報告フォーマット

初期化完了時は以下を提示する。

1. 生成した `feature_name` と命名理由
2. プロジェクト概要（短く）
3. 生成した `spec.json` のパス
4. 明確な次ステップ（`spec-requirements <feature-name>`）
5. 段階的開発方針（初期化時点では設計/タスク未生成）である旨
