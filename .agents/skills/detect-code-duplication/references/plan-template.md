# TypeScript/JavaScript コード重複リファクタリング計画

状態: `<active|completed|cancelled>`
生成日: `<YYYY-MM-DD HH:MM>`
分析対象: `<target_path>`
スキャン閾値: `<threshold>`
分析対象規模: `<files_scanned> files / <total_lines> lines`
生ログ: `<docs/tmp/duplication/runs/<run-id>/similarity-report.txt>`
計画ファイル: `<docs/plans/active/refactor-duplications-<run-id>.md>`

## 状態遷移

- 完了時: `状態: completed` に更新し、`docs/plans/completed/` へ移動
- 中止時: `状態: cancelled` に更新し、`docs/plans/cancelled/` へ移動

## 検出概要

- 重複候補ペア数: `<count>`
- 影響ファイル数: `<count>`
- 推定削減行数: `<count>`

## 高優先度

### 1. `<重複パターン名>`

- 類似度: `<xx.xx>%`
- 影響ファイル:
- `<path>:<line>`
- `<path>:<line>`
- 推奨アクション: `<共通関数抽出 / 共通モジュール化 / 維持>`
- 根拠: `<理由>`
- 実装メモ:

```ts
// 必要なら共通化イメージを記載
```

## 中優先度

### 1. `<重複パターン名>`

- 類似度: `<xx.xx>%`
- 影響ファイル:
- `<path>:<line>`
- `<path>:<line>`
- 推奨アクション: `<内容>`
- 根拠: `<理由>`

## 低優先度

### 1. `<重複パターン名>`

- 類似度: `<xx.xx>%`
- 影響ファイル:
- `<path>:<line>`
- 推奨アクション: `<内容>`
- 根拠: `<理由>`

## 除外候補（意図的重複）

### 1. `<重複パターン名>`

- 判定: `維持`
- 理由: `<生成コード / テスト専用 / 互換維持 など>`
- 影響ファイル:
- `<path>:<line>`

## 実施フェーズ

### フェーズ1（高優先度）

- [ ] 共通化対象の API 設計
- [ ] 置換実装
- [ ] 既存テスト修正
- [ ] 回帰確認

### フェーズ2（中優先度）

- [ ] 追加共通化
- [ ] モジュール境界の整理
- [ ] テスト更新

### フェーズ3（低優先度）

- [ ] 小規模重複の解消
- [ ] ドキュメント更新

## 実行前チェック

- [ ] 破壊的変更がないことを確認
- [ ] 公開 API 互換性を確認
- [ ] テスト戦略を明記
