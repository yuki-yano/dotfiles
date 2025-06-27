---
description: Analyze git changes and create an organized commit plan with logical grouping
---

# コミット計画作成: $ARGUMENTS

## 目標

現在のGit変更を分析し、論理的にグループ化された整理されたコミット計画を作成する

## ARGUMENTSの活用

`$ARGUMENTS`は以下のような用途で使用する：

### 1. 特定のパスやパターンに限定
```bash
/commit-plan "src/"  # srcディレクトリの変更のみ対象
/commit-plan "*.ts"  # TypeScriptファイルのみ対象
/commit-plan "frontend/ backend/"  # 複数ディレクトリを指定
```

### 2. コミット戦略の指定
```bash
/commit-plan "細かく分割"  # より詳細な分割を要求
/commit-plan "機能ごとにまとめる"  # 機能単位でグループ化
/commit-plan "ファイルタイプ別"  # 拡張子でグループ化
```

### 3. 実行モードの事前指定
```bash
/commit-plan "--auto"  # 自動実行モード
/commit-plan "--dry-run"  # ドライランモード
/commit-plan "--interactive"  # インタラクティブモード
```

### 4. 特定の要件やコンテキスト
```bash
/commit-plan "PRレビュー用に整理"  # レビューしやすい単位で分割
/commit-plan "リリースノート生成を考慮"  # リリースノートに記載しやすい形式
/commit-plan "依存関係を重視"  # ビルドが壊れない順序を優先
```

## 実行手順

### ステップ 1: 現在の状態を分析
```bash
# 並行実行で情報収集
git status --porcelain
git diff --cached --stat
git diff --stat
git log --oneline -20  # 過去のコミットメッセージフォーマットを参考にする

# ARGUMENTSに基づいてフィルタリング
if [ -n "$ARGUMENTS" ]; then
    # パスパターンが指定されている場合は該当ファイルのみを対象にする
    # 例: "src/" や "*.ts" が指定された場合
fi
```

### ステップ 2: 過去のコミットパターン分析

**重要**: プロジェクトの過去のコミットメッセージを分析して、以下を確認する：
- 使用されているプレフィックス（feat/fix/docs等）の傾向
- 日本語/英語の使い分けルール
- メッセージの長さや詳細度
- 箇条書きの使用有無
- スコープの記載方法（例: `feat(cli):` vs `feat:`）

### ステップ 3: 変更の分類と関連性分析

1. **ファイルタイプ別分類**
   - ソースコード（.ts, .js, .py等）
   - 設定ファイル（.json, .yaml, .toml等）
   - ドキュメント（.md, .txt等）
   - テストファイル（test/spec含む）

2. **ディレクトリ構造による関連性**
   - 同一ディレクトリ内の変更
   - 関連するコンポーネント（例: componentとそのtest）
   - 依存関係のあるファイル

3. **変更内容による分類**
   - feat: 新機能
   - fix: バグ修正
   - docs: ドキュメントのみ
   - style: フォーマット変更
   - refactor: リファクタリング
   - test: テスト追加・修正
   - chore: その他の変更

### ステップ 4: コミット計画の作成

**注意**: コミットメッセージは過去のログから抽出したパターンに従って作成する

#### 出力フォーマット例
```markdown
## 📋 コミット計画

### コミット 1: feat: 新機能の追加
**タイプ**: feat
**影響範囲**: 機能追加
**ファイル**:
- `path/to/new-feature.ts` (新規)
- `path/to/new-feature.test.ts` (新規)
- `path/to/index.ts` (修正: import追加)

**コミットメッセージ案**:
```
feat: Add new feature for handling user preferences

- Implement preference storage module
- Add unit tests for preference handling
- Export new module from index
```

### コミット 2: fix: エラー処理の修正
**タイプ**: fix
**影響範囲**: バグ修正
**ファイル**:
- `path/to/error-handler.ts` (修正)
- `path/to/error-handler.test.ts` (修正)

**コミットメッセージ案**:
```
fix: Correct error handling in async operations

- Fix uncaught promise rejection
- Add proper error logging
- Update tests for error cases
```

### コミット 3: docs: READMEの更新
**タイプ**: docs
**影響範囲**: ドキュメント
**ファイル**:
- `README.md` (修正)
- `docs/api.md` (修正)

**コミットメッセージ案**:
```
docs: Update README with new feature documentation

- Add usage examples for new feature
- Update API documentation
- Fix outdated information
```

## 📊 サマリー
- 総変更ファイル数: X
- 推奨コミット数: Y
- 依存関係: コミット1を先に実行（他が依存）

## 💡 推奨事項
- 大きな変更は更に分割を検討
- テストは対応する機能と同じコミットに含める
- Breaking changesがある場合は明記
```

### ステップ 5: 実行方法の選択提示

**ユーザーに以下の選択肢を提示する：**

```
💡 実行方法を選択してください:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[a] すべて自動実行 - 計画通りに全コミットを実行
[i] インタラクティブ - 各コミット前に確認
[e] 計画を編集 - 計画の修正や調整
[d] ドライラン - 実際のコミットは行わず確認のみ
[s] スクリプトとして保存 - 後で実行するためのスクリプト生成
[q] キャンセル - 計画を破棄

選択: 
```

### ステップ 6: 選択に応じた実行

#### [a] 自動実行の場合
- すべてのコミットを順番に実行
- 各コミット後にgit statusで確認
- エラーがあれば停止

#### [i] インタラクティブの場合
- 各コミット前に変更内容を表示
- ユーザーの確認を待つ
- スキップやメッセージ編集も可能

#### [e] 計画編集の場合
- テキストエディタで計画を開く
- ファイルの移動、コミットの分割・統合が可能
- 編集後、再度実行方法を選択

#### [d] ドライランの場合
- 実行予定のコマンドを表示のみ
- 実際のgit操作は行わない
- 最終確認用

#### [s] スクリプト保存の場合
```bash
#!/bin/bash
# コミット計画実行スクリプト
# 生成日時: $(date)

# コミット 1
git add path/to/files...
git commit -m "feat: ..."

# コミット 2
git add path/to/other/files...
git commit -m "fix: ..."
```
- 実行可能なシェルスクリプトとして保存
- ファイル名: `commit-plan-YYYY-MM-DD-HHmmss.sh`

### ステップ 7: 計画の保存（オプション）

```bash
# 計画を ai/plans/active/ に保存
echo "$COMMIT_PLAN" > "ai/plans/active/$(date +%Y-%m-%d)-commit-plan.md"
```

## 注意事項

- **依存関係の考慮**: ビルドが壊れないような順序で計画
- **コミットサイズ**: 1つのコミットは1つの論理的変更に限定
- **メッセージ規約**: プロジェクトの過去のコミットパターンを優先し、Conventional Commitsを補助的に使用
- **一貫性の維持**: 過去のコミットメッセージのスタイルと整合性を保つ
- **レビューの容易さ**: レビュアーが理解しやすい単位で分割

## 実装のポイント

### 対話的な選択の実装
- 選択肢の入力を待つ際は、明確なプロンプトを表示
- 無効な入力の場合は再度選択を促す
- 各オプションの動作を事前に説明

### エラーハンドリング
- gitコマンドの実行エラーをキャッチ
- コンフリクトや未ステージの変更を検出
- エラー時は適切なリカバリー方法を提案

## 高度なオプション

- `--auto`: 選択プロンプトをスキップして自動実行
- `--interactive`: デフォルトでインタラクティブモードを選択
- `--dry-run`: デフォルトでドライランモードを選択
- `--squash-related`: 関連する小さな変更をまとめる
- `--split-large`: 大きな変更を自動分割