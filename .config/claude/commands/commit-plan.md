---
description: Analyze git changes and create an organized commit plan with logical grouping
---

# コミット計画作成: $ARGUMENTS

## 引数（ARGUMENTS）

自然言語で指示を与えることができます：

```bash
# 例
"機能追加だけまとめて"
"テストとコードを分けて"
"自動で実行"
```

**キーワード**：
- タイプ指定: "機能追加"(feat)、"修正"(fix)、"リファクタリング"(refactor)、"ドキュメント"(docs)、"テスト"(test)、"設定"(chore)
- グルーピング: "まとめて"（統合）、"分けて"（分割）
- 実行: "自動で"（自動実行モード）

**フラグ**: `--file <path>`、`--type <type>`、`--auto`

## 目標

Git変更を分析し、意図別に論理的なコミット計画を作成する。

## 実行手順

### 0. 引数の解析

自然言語とフラグオプションを解析：

**自然言語からの意図抽出**：
- "機能追加" / "新機能" → COMMIT_TYPE="feat"
- "バグ修正" / "修正" → COMMIT_TYPE="fix"
- "リファクタリング" / "整理" → COMMIT_TYPE="refactor"
- "ドキュメント" → COMMIT_TYPE="docs"
- "テスト" → COMMIT_TYPE="test"
- "設定" / "依存関係" → COMMIT_TYPE="chore"
- "自動で" / "自動実行" → AUTO_EXECUTE=true
- "まとめて" → GROUPING="merge"
- "分けて" / "ファイルごと" → GROUPING="split"

### 1. 変更内容の分析

引数に応じて分析対象を変更：

```bash
# デフォルト（引数なし）
git status --porcelain
git diff --stat
git diff  # 全体の変更を確認

# --file <path> が指定された場合
git diff --stat -- <path>
git diff -- <path>
```

### 2. 意図の識別と分類

- **feat**: 新機能、新しいコンポーネント
- **fix**: バグ修正、エラーハンドリング
- **refactor**: コード整理、リネーム
- **docs**: ドキュメント、コメント
- **test**: テストの追加・修正
- **chore**: 設定、依存関係

`--type` 引数が指定された場合は、そのタイプの変更のみを抽出して計画を作成。

### 3. 意図別コミット計画

以下のフォーマットで出力（句読点や空行も含めて再現）:

```
コミット計画

[1] <type>: <サマリ>
- <file1>
- <file2> [部分] Lxx-Lyy

実行コマンド:
git add <file...>
git commit

コミットメッセージ:
<type>: <サマリ>

- 箇条書き1
- 箇条書き2
```

自然言語指示による調整：
- GROUPING="merge" の場合：同じタイプの変更をできるだけまとめる
- GROUPING="split" の場合：ファイル単位で細かく分割
- COMMIT_TYPE が指定された場合：そのタイプの変更のみを計画に含める

### 4. 実行モード選択

- **[a] 自動実行**: 順次実行（部分的変更は編集済みパッチ→`git apply --cached`/逆パッチ。手動介入できる場合のみ add -p）
  - パッチ適用でエラーが発生した場合は停止し、手動での対処を促す
- **[i] インタラクティブ**: 各コミット前に確認
- **[e] 計画を編集**: コミットの統合・分割・順序変更
  - `1,2を統合` / `3を分割` / `1と3を入れ替え` / `2のメッセージ: 新内容`
- **[d] ドライラン**: コマンド確認のみ

## git add --patch 操作（手動時のみ・非推奨）

非対話エージェントでは `git apply --cached` / 逆パッチを優先し、ここは人手で対話できる場合のリファレンス。可能な限りパッチ編集で対応する。

- `y` - ステージング / `n` - スキップ
- `s` - 分割（可能な場合）
- `e` - 編集モード（行単位での選択が可能）
- `?` - ヘルプ / `q` - 終了

### コミットメッセージの作成

`git commit` 実行時のメッセージ作成ガイドライン:

- **形式**: Conventional Commits形式を使用
- **1行目**: `型: 簡潔な要約` (50文字以内推奨)
- **本文**: 空行を挟んで、変更内容を箇条書きで詳細に記述
- **Why**: 変更の理由や背景を含める
- **影響**: 影響範囲や注意点があれば記載

### 部分適用の基本（非対話エージェント優先度）

- 非対話: パッチ編集＋`git apply --cached`/`git apply -R --cached`
- 手動のみ: `git add -p`（最終手段）
- 詳細な注意は「diffパッチアプローチ使用時の注意」を参照

#### 逆パッチ例（残す差分が多い場合）
```bash
git add package.json
git diff --cached package.json > staged.patch
# staged.patch を編集し、除外したい変更だけを残す
git apply -R --cached staged.patch
git diff --cached package.json
rm -f staged.patch
```

#### 正方向パッチ例（入れたい差分だけを明示）
```bash
git diff package.json > package.patch
cp package.json package.json.working
cp package.patch package.only.patch
# package.only.patch を「入れたい差分だけ」に編集
git apply --check --cached package.only.patch
git apply --cached package.only.patch
git diff --cached package.json
diff package.json package.json.working
rm -f package.json.working package.patch package.only.patch
```

#### 手動フォールバック（対話可能な場合のみ）
```bash
git add <file>
git reset --patch <file>
```

## 重要な注意事項

### add --patch での段階的コミット（手動時のみ）

- apply/逆パッチで対処できない場合の備忘
- 前のコミットで選択済みの部分は表示されないので、各コミット開始前に `git diff` を確認
- `s` で分割できない場合は `e` で編集、どうしても難しいときだけ使う

### diffパッチアプローチ使用時の注意（共通の基本）

- **ファイル単位での操作**: `git checkout HEAD -- <file>` で特定ファイルのみリセット（他のファイルに影響なし）
- **バックアップの作成**: 作業前に必ず `.working` ファイルとしてバックアップ
- **パッチ編集の基本**: ハンクヘッダー、末尾改行を整えた上で `git apply --check` で検証
- **エラー時の復旧**: エラーが出たら即バックアップから戻す
- **逆パッチアプローチ**: 「残す方が多い」ケースでは行数調整不要で安全

### エラー時の対処

```bash
git reset HEAD <file>  # ステージングを取り消し
git checkout HEAD -- <file>  # 最後のコミットの状態に戻す
git reset --hard $BACKUP_BRANCH  # 完全にやり直し（破壊的なので要確認）
```

### 実行時の原則

- **自動修正の禁止**: パッチ適用（apply --cached / 逆パッチ・add -p）が失敗しても、ファイルを書き換えて力技で解決しようとしない
- **確認優先**: 不安な場合は`git diff --cached`でステージング内容を確認
- **段階的実行**: 各コミット後に`git log -1 --stat`で結果を確認

## ベストプラクティス

1. 全体の変更から異なる意図を識別
2. 1コミット = 1つの意図
3. 同一ファイルでも意図別に`git apply --cached`/逆パッチで分割（手動時のみ`git add -p`）
4. ビルドが壊れない順序で実行
5. コミットメッセージは以下の形式で詳細に記述：
   - 1行目: 簡潔な要約（型: 内容）
   - 空行
   - 具体的な変更内容を箇条書きで列挙
   - 変更の理由や背景（必要に応じて）

## 完了後のクリーンアップ

```bash
# すべてのコミットが成功した場合
git branch -d $BACKUP_BRANCH
rm -f .git/commit-plan-stash-ref
```

## 計画完了の報告（必須）

コミット計画作成完了時に、以下の情報を簡潔に日本語で報告する：

1. **自然言語指示の解釈**（指示があった場合）
2. **計画した総コミット数**
3. **各コミットの内容**（番号順に簡潔に列挙）
4. **意図別の内訳**（例：feat: 2件、fix: 1件、refactor: 1件）
5. **特に注意が必要な点**（例：部分的ステージングが必要なファイル数）

例：
```
【指示の解釈】
"機能追加の変更だけをまとめて自動実行" → feat タイプのみ抽出、まとめてコミット、自動実行モード

5つのコミットに分割する計画を作成しました。

【コミット内容】
1. feat: ユーザー認証機能の追加
2. feat: APIエンドポイントの実装
3. fix: バリデーションエラーの修正
4. refactor: 共通処理の抽出
5. docs: API仕様書の更新

【内訳】
- 新機能追加(feat): 2件
- バグ修正(fix): 1件
- リファクタリング(refactor): 1件
- ドキュメント(docs): 1件

【注意点】
3つのファイルで部分的なステージング（git add -p）が必要です。
```

## 実行モード選択（必須）

計画完了の報告後、必ず以下の実行モードの選択肢を表示する：

```
【実行モードを選択してください】
- [a] 自動実行: 順次実行（部分的変更では git add --patch 起動）
- [i] インタラクティブ: 各コミット前に確認
- [e] 計画を編集: コミットの統合・分割・順序変更
- [d] ドライラン: コマンド確認のみ
- [q] 終了: 計画を保存して終了

選択: 
```

**注意**: `--auto` 引数が指定された場合は、この選択画面をスキップして自動的に [a] モードで実行を開始する。

## 実行前の安全対策

実行モードが選択され、実際にコミット作業を開始する直前に以下を実行：

```bash
# バックアップブランチを作成
BACKUP_BRANCH="backup/commit-plan-$(perl -MPOSIX -le 'print strftime("%Y%m%d-%H%M%S", localtime)')"
git branch $BACKUP_BRANCH
echo "バックアップブランチを作成しました: $BACKUP_BRANCH"

# 現在のステージング状態を保存
git stash create > .git/commit-plan-stash-ref

# 実行前の最終状態確認
git status
```
