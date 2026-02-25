# spec-requirements

## 目的

仕様の要件定義を確定し、受け入れ条件をEARS形式で記述する。

## 入力

- 必須: `feature_name`

## 前提確認

1. `./docs/sdd/specs/<feature-name>/requirements.md` が存在すること。
2. `./docs/sdd/specs/<feature-name>/spec.json` が存在すること。
3. ステアリング文書（`./docs/sdd/steering/`）を参照可能であること。

## コンテキスト読み込み

1. アーキテクチャ文脈: `./docs/sdd/steering/structure.md`
2. 技術制約: `./docs/sdd/steering/tech.md`
3. プロダクト文脈: `./docs/sdd/steering/product.md`
4. カスタムステアリング: `./docs/sdd/steering/*.md`（コア3ファイル以外を全件）
5. 既存仕様:
   - `./docs/sdd/specs/<feature-name>/requirements.md`
   - `./docs/sdd/specs/<feature-name>/spec.json`

## 実行手順

1. 既存の背景情報を読み、目的を整理する。
2. 最初に初版要件を生成し、その後ユーザーとの対話で改訂する。
3. 要件を機能単位で分割し、各要件にObjectiveを記述する。
4. 受け入れ条件をEARSで記述する。
5. このフェーズでは実装詳細を書かず、振る舞い要件に集中する。

## 要件生成ガイドライン

1. コア機能から始める。
2. EARS構文を必須とする。
3. 最初から逐次質問だけで止まらず、初版を先に出す。
4. レビューで拡張しやすい粒度を保つ。
5. 主語はプロジェクトに適した実体を選ぶ。
   - ソフトウェア: 具体的なシステム/サービス名
   - 非ソフトウェア: プロセス/チーム/成果物など

## 出力

- 更新済み `./docs/sdd/specs/<feature-name>/requirements.md`

## 更新ルール

- `spec.json.phase` を `requirements-generated` に更新する。
- `approvals.requirements.generated=true`, `approved=false` に更新する。
- `approvals.design.approved=false` に更新する。
- `approvals.tasks.approved=false` に更新する。
- `ready_for_implementation=false` に更新する。
- `updated_at` を現在時刻に更新する。
- 他メタデータは保持する。

## 承認反映（自然言語）

ユーザーが自然言語で要件承認を明示したら、`spec.json` を更新する。

受理条件:

1. 発話に `要件` または `requirements` が含まれる。
2. 発話に `承認` / `OK` / `approve` / `進めて` のいずれかが含まれる。
3. 曖昧表現のみの場合は承認扱いにしない。

1. `approvals.requirements.approved=true`
2. `updated_at` 更新
3. `approval_log` に証跡を追記（`phase=requirements`, `action=approve`）
4. 次フェーズ（`spec-design`）へ進行可能

取り消し受理条件:

1. 発話に `要件` または `requirements` が含まれる。
2. 発話に `取り消す` / `差し戻し` / `再レビュー` / `revoke` のいずれかが含まれる。

1. `approvals.requirements.approved=false`
2. `approvals.design.approved=false`
3. `approvals.tasks.approved=false`
4. `ready_for_implementation=false`
5. `updated_at` 更新
6. `approval_log` に証跡を追記（`phase=requirements`, `action=revoke`）
7. 次フェーズへ進まず、要件レビューへ戻す

## EARS形式

1. WHEN 条件
   THEN 対象 SHALL 応答
2. IF 条件
   THEN 対象 SHALL 応答
3. WHILE 条件
   THE 対象 SHALL 継続動作
4. WHERE 条件
   THE 対象 SHALL 文脈動作

## 複合パターン

1. WHEN 条件 AND 追加条件 THEN 対象 SHALL 応答
2. IF 条件 AND 追加条件 THEN 対象 SHALL 応答

## 文書構成テンプレート

```markdown
# Requirements Document

## Introduction
[機能価値の要約]

## Requirements

### Requirement 1: [主要目的領域]
**Objective:** As a [role], I want [capability], so that [benefit]

#### Acceptance Criteria
1. WHEN ...
   THEN ... SHALL ...
2. IF ...
   THEN ... SHALL ...
3. WHILE ...
   THE ... SHALL ...
4. WHERE ...
   THE ... SHALL ...
```

## 重要ルール

1. 生成対象は要件文書本文のみとする。
2. 承認手順そのものを `requirements.md` に混在させない。
3. 各受け入れ条件は検証可能な文にする。

## 次フェーズ誘導

1. 要件が承認されたら `spec-design <feature-name>` へ進む。
2. 自動承認で連続実行する場合は `spec-design <feature-name> -y` 相当を利用する。
