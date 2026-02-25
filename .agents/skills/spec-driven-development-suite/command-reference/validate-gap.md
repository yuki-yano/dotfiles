# validate-gap

## 目的

要件と現行実装の差分を分析し、実装戦略を示す。

## 入力

- 必須: `feature_name`
- 任意: 分析対象の補足指定

## 前提確認

1. `./docs/sdd/specs/<feature-name>/requirements.md` が存在すること。
2. `./docs/sdd/specs/<feature-name>/spec.json` が存在すること。
3. 現行コードベースを参照できること。
4. ステアリング文書（コア + カスタム全件）を参照できること。

## コンテキスト

- アーキテクチャ文脈: `./docs/sdd/steering/structure.md`
- 技術制約: `./docs/sdd/steering/tech.md`
- プロダクト文脈: `./docs/sdd/steering/product.md`
- カスタム文脈: `./docs/sdd/steering/*.md`（コア3ファイル以外を全件）
- 仕様文書: `requirements.md`, `spec.json`

## 実行手順

### 1. 現状調査

1. 機能領域に関係するファイル・モジュールを特定する。
2. 現行アーキテクチャ、規約、技術スタック利用を整理する。
3. 既存サービス/ユーティリティ/再利用可能部品を列挙する。
4. 現行データモデル・API・統合パターンを把握する。

### 2. 要件実現性分析

1. EARS要件を技術要素へ分解する。
2. 必要コンポーネントと統合点を抽出する。
3. 非機能要件（性能・セキュリティ等）を抽出する。
4. 不足能力、未知技術、PoC必要領域を特定する。

### 3. 実装戦略オプション比較

1. Option A: 既存拡張（Extension）
2. Option B: 新規作成（New）
3. Option C: 併用（Hybrid）

各案で以下を示す。

- 対象ファイル/責務
- 既存整合性
- 保守性影響
- 統合難易度
- リスク低減策

### 4. 技術調査要件

1. 外部依存（ライブラリ/API/サービス）を列挙する。
2. 互換性、認証、設定、レート制限、コスト影響を整理する。
3. 未知領域と追加調査項目を列挙する。

### 5. 複雑度評価

- Small（S）: 1-3日
- Medium（M）: 3-7日
- Large（L）: 1-2週
- Extra Large（XL）: 2週超

リスクも High/Medium/Low で評価する。

## 出力

- ギャップ分析レポート
- 推奨実装戦略

## 出力フォーマット

1. Analysis Summary
2. Existing Codebase Insights
3. Implementation Strategy Options
   - Approach / Rationale / Trade-offs / Complexity
4. Technical Research Needs
5. Recommendations for Design Phase

## 実行ルール

1. これは分析フェーズであり、最終実装決定は行わない。
2. 複数案を提示し、設計フェーズに判断材料を渡す。
3. 言語は `spec.json.language` を優先する。
4. Inclusion Modeタグの有無にかかわらず、`./docs/sdd/steering/*.md` を全件読み込む。

## 次フェーズ

分析結果を使って `spec-design <feature-name>` へ進む。  
必要なら `-y` 相当で要件承認を自動化して連続進行する。
