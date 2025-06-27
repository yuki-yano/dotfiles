---
description: Run project test suite, collect coverage metrics, and save report to ai/log/tests/
---

# テスト実行とレポート作成: $ARGUMENTS

## 目標

プロジェクトのテストを実行し、結果とカバレッジを`ai/log/tests/`に保存する

## 実行手順

### ステップ 1: テストフレームワークの検出

package.json、pyproject.toml、go.mod等から使用中のテストツールを特定

### ステップ 2: テスト実行

```bash
# 例（プロジェクトに応じて自動選択）
npm test -- --coverage --watchAll=false     # Jest/Vitest
pytest --cov --cov-report=term-missing     # Python
go test -v -cover ./...                     # Go
bundle exec rspec --format documentation    # Ruby
```

**重要な設定**:
- CI=true（対話モード無効化）
- 監視モード無効
- カバレッジ収集有効

### ステップ 3: レポート生成

#### ファイル構成
- `ai/log/tests/YYYY-MM-DD-{hash}.txt` - 生のコンソール出力
- `ai/log/tests/YYYY-MM-DD-{hash}.md` - 構造化されたサマリー

#### Markdownレポートのフォーマット

```markdown
# テストレポート (YYYY-MM-DD)

## 結果
- 合計: X個（成功: Y, 失敗: Z, スキップ: N）
- 実行時間: XXs

## カバレッジ
| 種別 | % |
|-----|---|
| 行 | XX.X |
| ブランチ | XX.X |

## 失敗したテスト
（失敗がある場合のみ、エラー内容を記載）

## 推奨アクション
- カバレッジ低下箇所の改善
- 失敗テストの修正
```

### ステップ 4: 結果の報告

生成したファイルパスを表示し、重要な指標（テスト成功率、カバレッジ率）をハイライト

## ARGUMENTSの活用

- 特定のテストファイル指定: `/test-report "src/**/*.test.ts"`
- カバレッジ閾値チェック: `/test-report "--min-coverage=80"`
- 特定のテストスイート: `/test-report "unit"` または `"integration"`

## 注意事項

- テスト失敗時もレポートは必ず生成
- 長時間実行の場合は適切なタイムアウト設定
- カバレッジが利用できない場合はその旨を記載