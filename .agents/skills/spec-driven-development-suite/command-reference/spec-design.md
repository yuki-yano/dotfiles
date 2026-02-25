# spec-design

## 目的

`<feature-name>` の要件から、実装前レビューに耐える技術設計書を作成する。

## 入力

- 必須: `feature_name`
- 任意: `auto_approve`（`-y` 相当）

## 前提確認とファイル処理

1. 要件承認を確認する。
   - `auto_approve=true` の場合のみ自動承認して進行する。
   - それ以外で未承認なら停止し、要件レビューを案内する。
2. `design.md` の扱いを決める。
   - 未存在: 新規作成
   - 既存: 上書き / 統合 / 中止
3. 読み込み対象:
   - `./docs/sdd/specs/<feature-name>/requirements.md`
   - `./docs/sdd/specs/<feature-name>/design.md`（存在時）
   - `./docs/sdd/specs/<feature-name>/research.md`（存在時）
   - `./docs/sdd/steering/product.md`, `tech.md`, `structure.md`
   - `./docs/sdd/steering/*.md`（カスタム）

## 調査・分析フェーズ（必須）

1. 機能分類
   - New Feature / Extension / Simple Addition / Complex Integration
2. 要件マッピング
   - EARS要件を技術要素へ対応付ける
   - 非機能要件（性能・セキュリティ・拡張性）を抽出する
3. 既存実装分析（既存拡張時は必須）
   - 再利用候補、境界、依存、統合点を特定する
4. 技術調査
   - 外部依存の契約、互換、制約、既知課題を確認する
5. リスク評価
   - 性能、セキュリティ、保守性、統合複雑性、技術的負債

## 調査ログ永続化（必須）

`./docs/sdd/specs/<feature-name>/research.md` を作成または更新し、以下を記録する。

1. 調査スコープと主要所見
2. 調査ソースと含意
3. 設計判断（採用案・代替案・トレードオフ）
4. リスクと緩和策

## 設計書構成ガイド

### コア原則

1. 実装コードを書かず、構成・契約・責務を記述する。
2. 要件IDは数値IDを正として統一する。
3. 図は必要箇所のみ追加し、Mermaid基本構文を使う。
4. 型安全前提で曖昧表現を避ける。

### 推奨セクション

- Overview
- Architecture
- System Flows（必要時）
- Requirements Traceability（必要時）
- Components and Interfaces
- Data Models（必要時）
- Error Handling（必要時）
- Testing Strategy
- Security / Performance / Migration（必要時）

## `spec.json` 更新

1. `phase = "design-generated"`
2. `approvals.design = { "generated": true, "approved": false }`
3. `approvals.requirements.approved = true`（`auto_approve` 時または承認済み時）
4. `approvals.tasks.approved = false`
5. `ready_for_implementation = false`
6. `updated_at` を更新

## 出力

- `./docs/sdd/specs/<feature-name>/design.md`
- `./docs/sdd/specs/<feature-name>/research.md`

## 実行ルール

1. 承認運用は `workflow-playbook.md` の「2.1 承認記録（自然言語）」を適用する。
2. 要件IDが数値でない場合は停止し、要件修正を案内する。
3. 設計更新後は `spec-status <feature-name>` を実行して次アクションを確認する。
