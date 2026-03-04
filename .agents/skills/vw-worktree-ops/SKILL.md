---
name: vw-worktree-ops
description: vw エイリアス経由で vde-worktree を安全かつ一貫した手順で運用するためのスキル。worktree の作成・切替・確認・ロック・掃除・コマンド実行を行うときに使う。
---

# VW Worktree 運用

このスキルは `vw`（`vde-worktree`）を安全に、かつ再現性高く実行するために使う。

## 基本ルール

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

## コマンドプレイブック

### Worktree を作成または再利用する

既存ブランチの有無が不明なときに使う。

```bash
vw init
vw switch feature/foo --json
```

期待値:
- 既存 worktree があれば `status: "existing"`。
- 新規作成なら `status: "created"`。

### 新しい WIP ブランチを作る

```bash
vw new --json
```

期待値:
- `wip-xxxxxx` ブランチと対応 worktree パスが作成される。

### Worktree を選んで移動する

```bash
cd "$(vw cd)"
```

補足:
- `fzf` が必要。
- セレクタ挙動は `--prompt` と `--fzf-arg` で調整可能。

### Worktree の状態を確認する

```bash
vw list --json
vw status feature/foo --json
vw path feature/foo --json
```

確認観点:
- dirty 状態
- lock 状態
- merged 判定（`byAncestry`, `byPR`, `overall`）
- PR 状態（`pr.status`: `none` / `open` / `merged` / `closed_unmerged` / `unknown`）
- PR URL（`pr.url`）
- upstream の ahead/behind

人間向けに表を確認するときに path が省略される場合は、`vw list --full-path` を使う。

### Cleanup から保護する

```bash
vw lock feature/foo --owner codex --reason "agent in progress" --json
vw unlock feature/foo --owner codex --json
```

長時間タスクでは lock して誤削除を防ぐ。

### Worktree を安全に削除する

```bash
vw del feature/foo --json
```

安全チェックで拒否された場合のみ、明示的に override を付ける:

```bash
vw del feature/foo --force-unmerged --allow-unpushed --allow-unsafe --json
```

### まとめて掃除する

```bash
vw gone --json
vw gone --apply --json
```

最初に dry-run を実行し、候補確認後に `--apply` する。

### リモートブランチを取得して worktree 化する

```bash
vw get origin/feature/foo --json
```

期待値:
- リモートブランチを fetch する。
- ローカル追跡ブランチが無ければ作る。
- worktree を作成または再利用する。

### 指定 worktree でコマンドを実行する

```bash
vw exec feature/foo -- pnpm test
vw exec feature/foo --json -- pnpm test
```

終了コード:
- 成功時は `0`。
- 子プロセス失敗時は `21`。

### 現在 worktree のブランチ名を変更する

```bash
vw mv feature/new-name --json
```

対象の非 primary worktree ディレクトリ内で実行する。

### primary 作業ツリーの現在ブランチを退避する

```bash
vw extract --current --json
```

primary worktree が dirty な場合は `--stash` を使う。

### 非 primary worktree の変更を primary に取り込む

```bash
vw absorb feature/foo --allow-agent --allow-unsafe --json
vw absorb feature/foo --from feature/foo --keep-stash --allow-agent --allow-unsafe --json
```

補足:
- primary worktree は clean である必要がある。
- source worktree が dirty の場合は自動で stash して apply する。
- `--from` は vw 管理 worktree 名のみ指定可能（`vde-worktree` 設定の `paths.worktreeRoot` 配下の実体パスを直接指定しない）。
- `--keep-stash` を指定しない場合、適用後に stash エントリは drop される。
- 非 TTY 実行では `--allow-agent` と `--allow-unsafe` を両方要求する。

### primary の変更を非 primary worktree に戻す

```bash
vw unabsorb feature/foo --allow-agent --allow-unsafe --json
vw unabsorb feature/foo --to feature/foo --keep-stash --allow-agent --allow-unsafe --json
```

補足:
- primary worktree は対象 branch に checkout されている必要がある。
- primary worktree は dirty である必要がある。
- target worktree は clean である必要がある。
- `--to` は vw 管理 worktree 名のみ指定可能（`vde-worktree` 設定の `paths.worktreeRoot` 配下の実体パスを直接指定しない）。
- `--keep-stash` を指定しない場合、適用後に stash エントリは drop される。
- 非 TTY 実行では `--allow-agent` と `--allow-unsafe` を両方要求する。

### primary 作業ツリーのブランチを切り替える

```bash
vw use feature/foo --allow-agent --allow-unsafe --json
```

非 TTY 実行では `--allow-agent` と `--allow-unsafe` を両方要求する。

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
