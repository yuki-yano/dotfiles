# ワークフロープレイブック

## 1. モード一覧

| モード | 主な入力 | 主な出力 |
| --- | --- | --- |
| `steering` | プロジェクト全体の文脈、既存ドキュメント | `product.md`, `tech.md`, `structure.md` |
| `steering-custom` | 対象領域（例: API, testing, security） | `./docs/sdd/steering/<topic>.md` |
| `spec-init` | `project_description` | `spec.json`, `requirements.md` |
| `spec-requirements` | `feature_name` | 更新済み `requirements.md`, `spec.json` |
| `spec-design` | `feature_name`, `auto_approve?` | `design.md`, `research.md`, `spec.json` |
| `spec-tasks` | `feature_name`, `auto_approve?`, `sequential?` | `tasks.md`, `spec.json` |
| `spec-impl` | `feature_name`, `task_numbers?` | 実装コード, テスト, 更新済み `tasks.md` |
| `spec-status` | `feature_name?` | ステータスレポート（詳細/一覧） |
| `validate-design` | `feature_name` | クリティカル指摘（最大3件）とGO/NO-GO判定 |
| `validate-gap` | `feature_name` | 要件-実装ギャップ分析 |
| `validate-impl` | `feature_name?`, `task_numbers?` | 実装検証レポート（GO/NO-GO） |

各モードの詳細仕様は `command-reference/` 配下の同名ドキュメントを参照する。

## 2. フェーズ制御

1. `spec-init` 前に `steering` を実行してもよい。
2. 標準順序は `spec-init → spec-requirements → spec-design → spec-tasks → spec-impl`。
3. `spec-*` / `validate-*` / `spec-impl` では `./docs/sdd/steering/*.md` を全件読み込む。
4. `steering-custom` の Inclusion Mode は文書管理タグとして扱い、読み込みフィルタには使わない。
5. `spec-design` 実行時は要件が承認済みであることを確認する。
6. `spec-tasks` 実行時は設計が承認済みであることを確認する。
7. `spec-design` では `research.md` に調査結果と設計判断根拠を保存する。
8. 実装前に `validate-design` と `validate-gap` を実行する。
9. 実装後に `validate-impl` を実行する。
10. 各フェーズ完了時に `spec-status` を実行し、次フェーズ条件を満たしているか確認する。

## 2.1 承認記録（自然言語）

承認はユーザーの自然言語宣言で確定する。  
例: 「要件承認」「設計を承認」「タスク承認で実装へ進める」。

受理条件:

1. フェーズ語（要件/設計/タスク または requirements/design/tasks）を含む。
2. 承認語（承認/OK/approve/進めて）を含む。
3. 曖昧表現のみの発話は承認扱いにせず、確認質問を返す。

取り消し条件:

1. フェーズ語を含む。
2. 取り消し語（取り消す/差し戻し/再レビュー/revoke）を含む。

更新ルール:

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
11. 承認/取り消しを受理した発話は `spec.json.approval_log` に記録する。
   - `phase`, `action`, `at`, `message_summary`

## 3. モード別実行手順

### 3.1 `steering`

1. `./docs/sdd/steering/` の既存文書を確認する。
2. `product.md`, `tech.md`, `structure.md` の不足を補完する。
3. 既存文書がある場合は手動追記を保持しつつ事実情報のみ更新する。

### 3.2 `steering-custom`

1. 対象領域を決める（例: `api-standards`, `testing`, `security`）。
2. `./docs/sdd/steering/<topic>.md` を作成し、適用範囲、必須ルール、例外条件を記載する。
3. Inclusion Mode（Always/Conditional/Manual）を文書管理タグとして明記する。

### 3.3 `spec-init`

1. `project_description` から `feature_name` をケバブケースで生成する。
2. `./docs/sdd/specs/<feature-name>/` を作成する。
3. `spec.json` を初期化する。
4. `requirements.md` の雛形を作成する。

### 3.4 `spec-requirements`

1. 既存 `requirements.md` から入力背景を抽出する。
2. EARS形式で要件を作成する。
3. `spec.json` の `phase` と `approvals.requirements.generated` を更新する。
4. 下流承認を無効化する（`design.approved=false`, `tasks.approved=false`）。
5. `ready_for_implementation=false` を維持する。

### 3.5 `spec-design`

1. 要件承認を確認する。`auto_approve=true` の場合のみ自動承認する。
2. `requirements.md` とステアリング文書を読み、設計を作成する。
3. 調査結果・判断根拠を `research.md` に記録する。
4. `design.md` が既存なら上書き/統合を選んで更新する。
5. `spec.json` の `phase` と `approvals.design.generated` を更新する。
6. 下流承認を無効化する（`tasks.approved=false`）。
7. `ready_for_implementation=false` を維持する。

### 3.6 `spec-tasks`

1. 設計承認を確認する。`auto_approve=true` の場合のみ自動承認する。
2. `design.md` から実装可能な粒度に分解して `tasks.md` を作成する。
3. タスクと要件の対応関係を各サブタスクに明示する。
4. `sequential=false` の場合は並列可能タスクに `(P)` を付与する。
5. `spec.json` の `phase` と `approvals.tasks.generated` を更新する。
6. `ready_for_implementation=false` を維持する（タスク承認まで実装開始しない）。

### 3.7 `spec-impl`

1. `approvals.tasks.approved=true` と `ready_for_implementation=true` を確認する。
2. 実装対象タスクを選ぶ。未指定なら未完了タスク全件、指定時は完了済みタスクも修正対象として選択できる。
3. 各タスクで RED→GREEN→REFACTOR を実施する。
4. テスト成功後に `tasks.md` を `- [x]` へ更新する。
5. 実装後に回帰テストと静的検査を実行する。

### 3.8 `spec-status`

1. `spec.json` を読み、現在フェーズと承認状態を抽出する。
2. `feature_name` 未指定時は全仕様を列挙し、フェーズ・承認・進捗を一覧化する。
3. `tasks.md` の完了率を集計する（詳細/一覧の両モード）。
4. 次アクションとブロッカーを整理して返す。

### 3.9 `validate-design`

1. 設計文書を読み、要件との整合性を確認する。
2. 重大指摘のみ最大3件に絞って提示する。
3. 強みを1-2件示し、GO/NO-GO判定を返す。

### 3.10 `validate-gap`

1. 要件を技術要素へ分解する。
2. 現行コードの責務・再利用可能部品・不足要素を特定する。
3. 実装戦略を Extension/New/Hybrid で比較する。
4. 追加調査項目、難易度、リスクを整理して返す。

### 3.11 `validate-impl`

1. 対象機能と対象タスクを決定する（未指定なら完了済みタスクを自動検出）。
2. 要件・設計・タスク・ステアリングを読み込み、実装と照合する。
3. テスト実行結果、要件トレーサビリティ、設計整合、回帰有無を検証する。
4. 問題の重要度を付けて GO/NO-GO を返す。

## 4. 典型リクエストの解釈

- 「仕様を作って」: `spec-init` から開始する。
- 「要件を固めたい」: `spec-requirements` を実行する。
- 「設計レビューして」: `validate-design` を実行する。
- 「実装との差分を見たい」: `validate-gap` を実行する。
- 「実装が仕様に沿っているか確認して」: `validate-impl` を実行する。
- 「状況を教えて」: `spec-status` を実行する。
- 「全仕様の状況を見たい」: `spec-status` を引数なしで実行する。

## 5. 実行後チェック

1. `spec.json.updated_at` が更新されたか。
2. 承認フラグが実態と一致しているか。
3. `tasks.md` のチェックボックスと実装状態が一致しているか。
4. `spec-design` 実行時に `research.md` が更新されているか。
5. `validate-impl` の判定結果に未解決の blocker が残っていないか。
