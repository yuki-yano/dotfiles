---
name: commit-plan
description: Git差分を意図別に整理し、コミット計画を作成して承認後に安全に実行する。ユーザーが「コミットを分けたい」「変更を論理的に整理したい」「段階的にコミットしたい」「実行前に計画を確認したい」と依頼するときに使う。
---

# Commit Plan

## Overview

Git の変更を意図ごとに分解し、先に計画を提示してから実行する。
計画フェーズと実行フェーズを分離し、必ず 1 文字入力で承認を取る。
ユーザーが「計画だけ」「実行しない」と明示した場合は、計画を提示して終了し、実行確認は出さない。
`--auto` は Phase 2 の各コミット前確認だけを省略する指定であり、Phase 1 後の `y` / `e` / `n` 確認は省略しない。

## Workflow

### Step 1: 依頼を解釈する

次を確認する。

- 対象範囲（全体 / `--file <path>`）
- 対象タイプ（`--type <type>`）
- グルーピング方針（まとめる / 分ける）
- 実行意図（計画のみ / 計画後に実行）

キーワードとタイプ判定は `references/arg-mapping.md` を参照する。

### Step 2: Phase 1（計画のみ）を実行する

以下で変更を把握する。

```bash
git status --porcelain=v1
git diff --stat
git diff
git diff --cached --stat
git diff --cached
git ls-files --others --exclude-standard
git log --oneline -5
```

`--file <path>` が指定されている場合は、差分確認と計画対象をその pathspec に限定する。ただし、対象外に既存の staged 差分や意図不明な差分がある場合は、実行前に必ず報告して確認する。

意図別にコミットを分割し、計画を作成する。
コミットメッセージは直近の commit log の粒度と形式に寄せる。
出力形式は `references/plan-output-template.md` を使う。

### Step 3: 1文字で実行確認して停止する

実行意図がある場合、計画提示後は必ず以下で確認する。

- `y`: Phase 2 を開始
- `e`: 計画を修正
- `n`: 計画のみで終了

`--auto` 指定時でもこの確認は省略しない。
計画のみの依頼では、この確認を出さずに終了する。

### Step 4: Phase 2（実行）を承認後に進める

`y` が来た場合のみ、`references/execution-and-patch.md` の手順で実行する。

- バックアップブランチ作成
- コミットを順次実行
- 各コミット後の検証

### Step 5: 失敗時は停止して安全復旧する

エラー時は自動修復せず停止する。
復旧とクリーンアップは `references/recovery-and-cleanup.md` を使う。

## Safety Rules

- 意図しない差分を見つけたら処理を止めてユーザー確認する
- staged / unstaged / untracked を区別して計画に反映する
- ignore されているファイルは `git add -f` で強制追加しない
- 破壊的操作（`git reset --hard`、`git checkout .`、`git restore .`）を実行しない
- `git add -p` ではなく、部分適用は `git apply --cached` / `git apply -R --cached` を優先する
- 失敗時にファイルを書き換えて力技で合わせない

## Stop Conditions

次を見つけたら、計画または実行を止めてユーザーに確認する。

- ユーザー指定の対象範囲外に staged 差分がある
- secret、credential、token らしき値の追加がある
- 生成物、lockfile、依存更新など、依頼意図と異なる大きな差分がある
- コミット計画に含めるべきか判断できない untracked file がある
- 部分適用で計画した差分と実際の staged diff が一致しない

## Reference Guide

必要なときだけ対応ファイルを読む。

- 引数解釈・分類ルール: `references/arg-mapping.md`
- 計画と報告フォーマット: `references/plan-output-template.md`
- 実行・部分適用手順: `references/execution-and-patch.md`
- 失敗時復旧・完了後整理: `references/recovery-and-cleanup.md`
