---
name: vw-worktree-ops
description: vw エイリアス経由で vde-worktree を安全かつ一貫した手順で運用するためのスキル。worktree の作成・切替・確認・ロック・掃除・コマンド実行を行うときに使う。
---

# VW Worktree 運用

このスキルは `vw`（`vde-worktree`）を安全に、かつ再現性高く実行するために使う。

## Overview

- 例示・実行ともに `vde-worktree` より `vw` を優先する。
- 最初にリポジトリルートを解決する: `git rev-parse --show-toplevel`。
- 書き込み系操作の前に、リポジトリごとに一度 `vw init` を実行する。
- worktree を作成するときは、可能な限り作業意図に即した名前（例: `feature/<機能名>`, `fix/<不具合名>`, `chore/<作業名>`）を明示指定する。
- 自動化やエージェント連携では `--json` を優先する。
- 人間向けログは stderr、判定に使うデータは stdout の JSON を正とする。
- 明示要求がない限り unsafe 系フラグは使わない。

## 安全な実行順序

1. 現在状態を確認する: `vw status --json` または `vw list --json`。
2. JSON 出力から対象ブランチ/パスを解決する。
3. 意図した操作を実行する。
4. `vw status --json` または `vw list --json` で再確認する。

## merge 判定ポリシー

JSON の merge 状態を読む:
- `merged.byAncestry`: ローカル Git の祖先関係判定
- `merged.byPR`: `gh` による PR merged 判定（nullable）
- `merged.overall`: 安全ロジックで使う最終判定
- `pr.status`: PR 状態（`none` / `open` / `merged` / `closed_unmerged` / `unknown`）
- `pr.url`: branch の最新 PR URL（取得不可時は `null`）

解釈:
- `byPR === true` の場合は `overall = true`（squash / rebase merge を含む）。
- `byAncestry === false` の場合は `overall = false`。
- `byAncestry === true` でも、分岐証跡（lifecycle / reflog）がない限り merged 扱いにしない。
- `byPR === false` または lifecycle が未取り込みを示す場合は `overall = false`。
- 分岐証跡が `baseBranch` に取り込まれている場合は `overall = true`。
- 上記で判断できない場合は `overall = null`。

注意:
- 自動化での削除判定は `merged.overall` を正とし、`merged.byPR` 単独では判定しない。
- `gh` 判定が使えない場合（`--no-gh`, `gh` 未導入/未認証, API エラー, `vde-worktree.enableGh=false`）は `pr.status = "unknown"` かつ `merged.byPR = null` になりうる。

## エラーハンドリング

JSON エラー応答の `code` ごとに処理する:

- `NOT_INITIALIZED`: `vw init` を実行する。
- `UNSAFE_FLAG_REQUIRED`: 意図した操作なら unsafe 同意フラグを明示する。
- `DEPENDENCY_MISSING`: 依存（`fzf`/`gh`）を導入するか、コマンド利用を避ける。
- `WORKTREE_NOT_FOUND`: `vw list --json` で再取得し、有効なブランチで再試行する。
- `LOCK_CONFLICT` または lock 状態: 正しい owner の `vw unlock` か `--force` を使う。

## 最小チェックリスト

1. 書き込み系コマンドの前に `vw init` を実行する。
2. 読み取り・判定は `--json` を使う。
3. 安全チェック拒否はデフォルトで尊重する。
4. override フラグは明示意図があるときのみ使う。
5. 状態変更後は必ず再確認する。

## コマンド用例

コマンドごとの用例は `references/commands.md` を参照。
