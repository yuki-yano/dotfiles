# コマンドプレイブック

`vw`（`vde-worktree`）のサブコマンドごとの用例集。安全な実行順序・merge 判定ポリシー・エラーハンドリングは `SKILL.md` を参照。

## Worktree を作成または再利用する

既存ブランチの有無が不明なときに使う。

```bash
vw init
vw switch feature/foo --json
```

期待値:
- 既存 worktree があれば `status: "existing"`。
- 新規作成なら `status: "created"`。

## 新しい WIP ブランチを作る

```bash
vw new --json
```

期待値:
- `wip-xxxxxx` ブランチと対応 worktree パスが作成される。

## Worktree を選んで移動する

```bash
cd "$(vw cd)"
```

補足:
- `fzf` が必要。
- セレクタ挙動は `--prompt` と `--fzf-arg` で調整可能。

## Worktree の状態を確認する

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

## Cleanup から保護する

```bash
vw lock feature/foo --owner codex --reason "agent in progress" --json
vw unlock feature/foo --owner codex --json
```

長時間タスクでは lock して誤削除を防ぐ。

## Worktree を安全に削除する

```bash
vw del feature/foo --json
```

安全チェックで拒否された場合のみ、明示的に override を付ける:

```bash
vw del feature/foo --force-unmerged --allow-unpushed --allow-unsafe --json
```

## まとめて掃除する

```bash
vw gone --json
vw gone --apply --json
```

最初に dry-run を実行し、候補確認後に `--apply` する。

## リモートブランチを取得して worktree 化する

```bash
vw get origin/feature/foo --json
```

期待値:
- リモートブランチを fetch する。
- ローカル追跡ブランチが無ければ作る。
- worktree を作成または再利用する。

## 管理外 worktree を取り込む

```bash
vw adopt --json
vw adopt --apply --json
```

補足:
- デフォルトは dry-run。
- `.worktree` 配下で管理されていない非 primary worktree を検出する。
- `--apply` を付けると `git worktree move` で管理下の worktree ルートへ移動する。

## リポジトリルートのファイルを worktree にコピーする

```bash
vw copy .env .env.local
```

補足:
- `<repo-relative-path...>` はリポジトリルート相対で複数指定できる。
- コピー先は対象 worktree（典型的には `WT_WORKTREE_PATH`）。

## リポジトリルートのファイルへ symlink を張る

```bash
vw link .env
vw link .env --no-fallback
```

補足:
- 対象 worktree からリポジトリルートのファイルへ symlink を作る。
- Windows では `--no-fallback` を指定しない限りコピーへフォールバックする。

## 指定 worktree でコマンドを実行する

```bash
vw exec feature/foo -- pnpm test
vw exec feature/foo --json -- pnpm test
```

終了コード:
- 成功時は `0`。
- 子プロセス失敗時は `21`。

## 現在 worktree のブランチ名を変更する

```bash
vw mv feature/new-name --json
```

対象の非 primary worktree ディレクトリ内で実行する。

## primary 作業ツリーの現在ブランチを退避する

```bash
vw extract --current --json
```

primary worktree が dirty な場合は `--stash` を使う。

## 非 primary worktree の変更を primary に取り込む

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

## primary の変更を非 primary worktree に戻す

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

## primary 作業ツリーのブランチを切り替える

```bash
vw use feature/foo --allow-agent --allow-unsafe --json
```

非 TTY 実行では `--allow-agent` と `--allow-unsafe` を両方要求する。

---

対象外コマンド: completion, invoke（agent 運用では使用しない）
