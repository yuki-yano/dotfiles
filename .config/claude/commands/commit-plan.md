---
description: Analyze git changes and create an organized commit plan with logical grouping
---

# コミット計画作成

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

Git変更を分析し、意図別に論理的なコミット計画を作成する。同一ファイルに複数の意図がある場合は`git add -p`で分割。

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

以下の形式で出力（コミットメッセージは作業内容を詳細に記述）:

自然言語指示による調整：
- GROUPING="merge" の場合：同じタイプの変更をできるだけまとめる
- GROUPING="split" の場合：ファイル単位で細かく分割
- COMMIT_TYPE が指定された場合：そのタイプの変更のみを計画に含める

**コミット計画**

**[1] feat: ユーザー認証機能**
- `src/auth.ts` (新規)
- `src/api.ts` [部分] L45-L89
- `src/types.ts` [部分] L12-L25

実行コマンド:
```bash
git add src/auth.ts
git add -p src/api.ts    # L45-L89を選択
git add -p src/types.ts   # L12-L25を選択
git commit
```

コミットメッセージ:
```
feat: Add user authentication

- Implement JWT-based authentication system
- Add login/logout API endpoints
- Define authentication types and interfaces
- Handle token validation and refresh
```

**複雑な部分的ステージングが必要な場合**:
```bash
# バックアップを作成
cp src/api.ts src/api.ts.backup

# 該当行以外を一時的に元に戻す
# (エディタで L45-L89 以外を手動で revert するか、
#  パッチを適用して必要な部分のみ残す)
git add src/api.ts
git commit  # エディタでメッセージを記述

# 元のファイルを復元
mv src/api.ts.backup src/api.ts
```

（各コミットごとに同様の形式で続く）

### 4. 実行モード選択

- **[a] 自動実行**: 順次実行（部分的変更では`git add -p`起動）
  - add -pでエラーが発生した場合は停止し、手動での対処を促す
- **[i] インタラクティブ**: 各コミット前に確認
- **[e] 計画を編集**: コミットの統合・分割・順序変更
  - `1,2を統合` / `3を分割` / `1と3を入れ替え` / `2のメッセージ: 新内容`
- **[d] ドライラン**: コマンド確認のみ

## git add -p 操作

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

### 自動的な行単位ステージング

ハンクに複数の意図が混在する場合の対処:

**方法1: git add --patch の代替手段**
```bash
# 一時的にインデックスに追加してから部分的に削除
git add <file>
git reset -p <file>  # 不要な部分を選択的にアンステージ
```

**方法2: diffパッチファイルを使った精密な分割**

`git add -p` で分割できない大きなハンクがあり、意図別に正確に分けたい場合に有効です。

```bash
# 1. 対象ファイルの現在の変更をパッチファイルとして保存
git diff package.json > package.json.full.patch

# 2. 現在のファイルをバックアップ（安全のため）
cp package.json package.json.working

# 3. 対象ファイルの変更を一時的にリセット（他のファイルには影響しない）
git checkout HEAD -- package.json

# 4. 意図別のパッチファイルを作成
cp package.json.full.patch package.json.npm-only.patch

# 5. package.json.npm-only.patch を編集して、特定の意図の変更のみを残す
# （例：npm公開設定の変更行のみ残し、ビルド設定の変更行は削除）
# パッチファイルの編集時の注意:
# - @@で始まるハンクヘッダーの行数情報を修正
# - +で始まる追加行、-で始まる削除行を適切に調整
# - コンテキスト行（スペースで始まる行）は維持

# 6. 編集したパッチを適用（--check で事前確認）
git apply --check package.json.npm-only.patch
if [ $? -eq 0 ]; then
    git apply package.json.npm-only.patch
else
    echo "パッチの適用に失敗しました。パッチファイルを確認してください。"
    # エラー時は元のファイルを復元して終了
    cp package.json.working package.json
    rm -f package.json.working package.json.full.patch package.json.npm-only.patch
    exit 1
fi

# 7. ステージングしてコミット
git add package.json
git commit -m "feat: Add npm package publishing configuration"

# 8. フルパッチを再適用して元の状態に戻す
git apply package.json.full.patch

# 9. 適用済みの変更との差分を確認
diff package.json package.json.working
if [ $? -ne 0 ]; then
    echo "警告: ファイルの内容に差異があります。手動で確認してください。"
    # 必要に応じて: cp package.json.working package.json
fi

# 10. クリーンアップ
rm -f package.json.working package.json.full.patch package.json.npm-only.patch
```

**より簡単な代替方法: 逆パッチアプローチ**

```bash
# 1. ファイル全体をステージング
git add package.json

# 2. ステージングされた内容から不要な部分だけを含む逆パッチを作成
# （git diff --cached で現在のステージング内容を確認しながら）
git diff --cached package.json > staged.patch

# 3. staged.patch を編集して、除外したい変更（ビルド設定など）のみを残す
# 注意: この時、残したい変更（npm設定）の行は削除する

# 4. 逆パッチを適用して不要な部分をアンステージ
git apply -R --cached staged.patch

# 5. 結果を確認
git diff --cached package.json  # ステージングされた内容を確認

# 6. コミット
git commit -m "feat: Add npm package publishing configuration"

# 7. クリーンアップ
rm -f staged.patch
```

**利点**:
- git add -p で分割できない複雑な変更を意図別に正確に分離できる
- 各コミットに含める内容を完全にコントロール可能
- 大きなファイルの多数の変更を論理的に整理できる

**注意点**:
- 必ずバックアップを取ってから実行する
- ファイルの一時的な変更が発生するため、慎重に作業する
- 作業後は必ず元のファイルを復元する

**実際の使用例**:
package.json に以下の変更が混在している場合：
- npm公開設定（main, exports, bin, files）
- ビルド設定（build script, tsdown追加）
- メタ情報（author, repository）

これらを3つの異なるコミットに分けたいが、git add -p では1つのハンクになってしまう場合に、この方法で各変更を個別にステージング・コミットできます。

**推奨**: 複雑な場合はdiffパッチを使用して意図別に正確に分割

## 重要な注意事項

### add -p での段階的コミット

- **警告**: 後のコミットでは、前のコミットで選択した部分が既にコミット済みのため、表示されるハンクが変わります
- **対策**: 各コミットで必要な行番号範囲を明確に記録し、ハンクの内容を確認してから選択
- **例**: 
  - 1回目: L1-100のうちL45-89を選択 → 2つのハンクに分かれる可能性
  - 2回目: 残りのL1-44とL90-100が新しいハンクとして表示される
- **ハンク分割できない場合**: `s`が効かない大きなハンクは`e`で編集

### diffパッチアプローチ使用時の注意

- **ファイル単位での操作**: `git checkout HEAD -- <file>` で特定ファイルのみリセット（他のファイルに影響なし）
- **バックアップの作成**: 作業前に必ず `.working` ファイルとしてバックアップ
- **パッチファイルの編集**: ハンクヘッダーの行数情報（`@@ -行,数 +行,数 @@`）を正確に修正
- **事前検証**: `git apply --check` でパッチが正しく適用できるか確認
- **エラー時の復旧**: エラーが発生した場合は即座にバックアップから復元
- **逆パッチアプローチ**: より簡単で安全な代替方法として推奨

### エラー時の対処

```bash
git reset HEAD <file>  # ステージングを取り消し
git checkout HEAD -- <file>  # 最後のコミットの状態に戻す
git reset --hard $BACKUP_BRANCH  # 完全にやり直し
```

### 実行時の原則

- **自動修正の禁止**: add -pで失敗しても、ファイルを変更して解決しようとしない
- **確認優先**: 不安な場合は`git diff --cached`でステージング内容を確認
- **段階的実行**: 各コミット後に`git log -1 --stat`で結果を確認

## ベストプラクティス

1. 全体の変更から異なる意図を識別
2. 1コミット = 1つの意図
3. 同一ファイルでも意図別に`git add -p`で分割
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
BACKUP_BRANCH="backup/commit-plan-$(date +%Y%m%d-%H%M%S)"
git branch $BACKUP_BRANCH
echo "バックアップブランチを作成しました: $BACKUP_BRANCH"

# 現在のステージング状態を保存
git stash create > .git/commit-plan-stash-ref

# 実行前の最終状態確認
git status
```
