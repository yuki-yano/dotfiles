---
name: spec-driven-development-suite
description: 仕様駆動開発を単体で実行する。ステアリング文書管理、仕様初期化、要件定義（EARS）、設計作成、調査ログ作成、タスク分解、TDD実装進行、状態レポート、設計品質検証、実装ギャップ分析、実装検証をプロジェクト内ファイル操作だけで一貫実行する。ユーザーが「仕様から実装まで進めたい」「設計品質を検証したい」「要件と実装の差分を分析したい」と依頼するときに使う。
---

# 仕様駆動開発スイート

## 概要

外部サーバー連携なしで、仕様駆動開発の全機能を単体で実行する。  
依頼内容を実行モードへマッピングし、`./docs/sdd/` 配下の成果物を直接作成・更新して進める。

## 主要成果物

- `./docs/sdd/steering/product.md`
- `./docs/sdd/steering/tech.md`
- `./docs/sdd/steering/structure.md`
- `./docs/sdd/steering/*.md`（カスタムステアリング）
- `./docs/sdd/specs/<feature-name>/spec.json`
- `./docs/sdd/specs/<feature-name>/requirements.md`
- `./docs/sdd/specs/<feature-name>/design.md`
- `./docs/sdd/specs/<feature-name>/research.md`
- `./docs/sdd/specs/<feature-name>/tasks.md`

## 実行モード

1. `steering`
   - 目的: プロダクト、技術、構造の基礎文書を作成または更新する。
2. `steering-custom`
   - 目的: API、テスト、セキュリティなどの個別方針文書を追加する。
3. `spec-init`
   - 目的: 仕様ディレクトリを初期化し、`spec.json` と `requirements.md` を作る。
4. `spec-requirements`
   - 目的: EARS形式の受け入れ条件を含む要件定義を確定する。
5. `spec-design`
   - 目的: 承認済み要件をもとに設計を作成する。
6. `spec-tasks`
   - 目的: 設計を実装可能なタスクへ分解する。
7. `spec-impl`
   - 目的: TDDでタスク実装を進め、`tasks.md` のチェックボックスを更新する。
8. `spec-status`
   - 目的: 指定仕様の詳細、または全仕様一覧の状態を報告する。
9. `validate-design`
   - 目的: 設計品質をレビューし、GO/NO-GO判定する。
10. `validate-gap`
   - 目的: 要件と実装の差分を分析し、実装戦略を示す。
11. `validate-impl`
   - 目的: 実装結果を要件・設計・タスクに照らして検証する。

## 標準フェーズ順序

`spec-init → spec-requirements → spec-design → spec-tasks → spec-impl`

各フェーズの前後で `spec-status` を実行し、承認済みかどうかを確認する。  
未承認の場合は次フェーズへ進まず、対象ドキュメントを更新して再レビューする。

## 要件記述ルール

`spec-requirements` では、受け入れ条件を必ずEARS形式で記述する。  
各文は句ごとに改行し、番号行の次行は2スペースでインデントする。

1. WHEN 条件
   THEN 対象 SHALL 応答
2. IF 条件
   THEN 対象 SHALL 応答
3. WHILE 条件
   THE 対象 SHALL 継続動作
4. WHERE 条件
   THE 対象 SHALL 文脈動作

複合条件は `WHEN`、`AND` を独立行で記述する。

## 運用ルール

1. `feature_name` は初期化時の値を固定し、表記ゆれを許容しない。
2. 既存文書がある場合は上書き前に差分方針を決める。
3. 仕様文書（requirements/design/tasks）を更新した場合は承認状態を未承認へ戻す。
4. `spec-design` 実行時は `research.md` に調査結果と設計判断の根拠を残す。
5. 実装前に `validate-design` と `validate-gap` を実行し、実装後に `validate-impl` を実行する。
6. コンテキスト不足や方針ドリフトを検知したら `steering` または `steering-custom` を再実行する。
7. `spec-*` / `validate-*` / `spec-impl` は `./docs/sdd/steering/*.md` を全件読み込む（Inclusion Mode は文書管理タグとして扱う）。

## 承認運用（自然言語）

承認はユーザーの自然言語による明示宣言で行う。  
例: 「要件を承認します」「設計OK」「タスク承認で進めて」。

承認として受理する条件:

1. 対象フェーズ語（要件/設計/タスク もしくは requirements/design/tasks）を含む。
2. 承認語（承認/OK/approve/進めて）を含む。
3. 曖昧表現（例:「よさそう」「たぶんOK」）のみの場合は再確認する。

承認取り消しとして受理する条件:

1. 取り消し語（取り消す/差し戻し/再レビュー/revoke）を含む。
2. 対象フェーズ語を含む。

1. 要件承認時:
   - `approvals.requirements.approved=true`
2. 設計承認時:
   - `approvals.design.approved=true`
3. タスク承認時:
   - `approvals.tasks.approved=true`
   - `ready_for_implementation=true`
4. 要件承認取り消し時:
   - `approvals.requirements.approved=false`
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
5. 設計承認取り消し時:
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
6. タスク承認取り消し時:
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
7. `requirements.md` 更新時:
   - `approvals.requirements.approved=false`
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
8. `design.md` 更新時:
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
9. `tasks.md` 更新時:
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
10. いずれも `updated_at` を更新する。
11. 承認/取り消しを受理した発話は、`spec.json` に証跡（時刻と要約）を残す。

## 参照ドキュメント

詳細な実行手順は `workflow-playbook.md` を参照する。  
成果物テンプレートは `artifact-templates.md` を参照する。  
モード別の詳細仕様は `command-reference/` を参照する。
