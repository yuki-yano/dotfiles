---
name: vw-worktree-ops
description: Git worktree の作成・再利用・状態確認・診断・作業場所の解決・コマンド実行・保護・整理・変更移送を依頼されたときに使う。vw 自体の実装や公開、tmux pane の操作には使わない。
---

# VW Worktree 運用

`vw`（`vde-worktree` と同じ CLI）で依頼された worktree 操作を行う。
引数と応答の詳細は、必要なコマンドの `vw describe <command> --json` または `vw <command> --help` で確認する。
全コマンドの定義を毎回読み込む必要はない。

## 実行起点と対象

- 別ディレクトリの操作は `vw -C "$repo" ...` で起点を明示する。`-C` は設定・hook・相対パスの解決にも使われるため、無条件に primary のルートへ置き換えない。
- 起点や初期化状態が不明なら `vw -C "$repo" context --json` を読む。`data.repository` の `repoRoot` と `currentWorktreeRoot` を区別し、設定値と由来は `data.config`、初期化状態は `data.initialized` で確認する。
- worktree のパスは応答の `path` を使う。ブランチ名から `.worktree/...` などを組み立てない。プロセスから親 shell の cwd は変えられないため、以降のツールの作業ディレクトリをそのパスに設定する。
- ブランチが複数の worktree に存在する場合は、エラーの `details.candidates` を読み、意図したパスを選ぶ。`--worktree "$path"` を使えるのは `status`・`path`・`exec`・`copy`・`link` のみ。ブランチ引数と併用しない。未対応の変更コマンドでは曖昧さを解消するまで実行しない。

## 目的に応じて選ぶ

| 目的 | コマンドと判断 |
|---|---|
| 設定・起点を調べる | `context --json`。初期化や自動 recovery は行わない |
| 設定不正・依存不足を調べる | `doctor --json --no-gh`。非ゼロ終了でも `data.checks` と `data.pendingRecoveries` を読む |
| 変更を伴わず一覧を取得・監視する | `list --json --no-gh --monitor`。GitHub 情報と upstream の ahead/behind 探索を省くため、未 push 判定には使わない |
| PR・merge を含む状態を見る | `list --json` / `status <branch> --json`。通常モードは lifecycle 観測を保存しうる。`--no-gh` だけでは非変更にならない |
| 既存の作業場所を解決する | `path <branch> --json` または `--worktree "$path" path --json` |
| 作業場所を作成または再利用する | `switch <branch> --json`。新規作成だけを求める場合は `new <branch> --json`。名前は依頼の意図に合わせて指定する |
| 変更前に結果・拒否理由を調べる | `check --json -- <command> ...` または `<command> ... --dry-run --json` |

読み取りや `exec` のために `init` は行わない。
`describe` の `requiresInitialization` が true の操作で、未初期化と分かったときだけ `vw -C "$repo" init --json` を実行する。
確認だけの依頼では初期化せず、その必要性を結果として伝える。

## 変更の事前検査

対象・安全性・副作用が未確定の変更は `check` で具体化する。
対応可否は `describe` の `supportsInspection` を見る。`exec`・`copy`・`link`・`invoke` などには使えない。

- `data.allowed`、`target`、`plannedResult`、`rejections`、`pendingRecoveries` を読む。拒否時も `data` を捨てない。
- 検査は hook・stash・ロック取得・metadata 書き込み・自動 recovery を実行しない。GitHub 照会や `get` のリモート調査はネットワークを使い得る。`--no-gh` は GitHub 照会だけを無効にする。
- `allowed: true` は観測時点の判定であり、許可や予約ではない。本実行は状態を再検証する。`pendingRecoveries` があれば内容を調べ、復旧を含む変更が依頼範囲か確認する。journal を削除して検査を通さない。
- 安全チェックの拒否を、force・unlock・hook 無効化で自動解消しない。既存のユーザー指示が具体的な override を許可している場合だけ、必要なフラグを選ぶ。`--allow-unsafe` は許可を得た操作について CLI が要求する付随フラグであり、付けたことを同意の根拠にしない。

作成・整理・保護・実行・変更移送の例は、必要な節だけ [references/commands.md](references/commands.md) を読む。

## JSON と失敗後の判断

機械処理は `--json` を使い、stdout の単一 JSON とプロセス終了コードを保存する。
`--help`・`--version` はテキスト表示なので JSON として解析しない。
完全な応答仕様は `describe` の `envelopeSchema`・`dataSchema` を参照する。本スキルの契約は `schemaVersion: 3`。異なる版や欠損した応答を推測で補わず、`vw --version` と `describe` で相違を確認して報告する。

- 成功は終了コード 0、`status: "ok"`、`error: null`。成功時も `warnings` を読む。
- 失敗は `error.code`・`details` に加え、`error.execution` の `phase`・`state`・`completed`・`recovery` と、残っている `data` を読む。stderr の文言だけで判定しない。
- vw 本体の変更が `state: applied` なら適用済み。`partial`・`recoveryRequired`・`unknown` は完了済み範囲と現在状態を確認するまで再実行しない。`exec` の子失敗は別に、[実行例の判断規則](references/commands.md#worktree-でコマンドを実行する)で扱う。
- `notStarted`・`rolledBack` は本体が未適用、または内部処理を戻した状態。拒否原因を解消し、hook が走った場合は `details.logPath` と実際の結果から副作用を確認したうえで再実行できる。状態名だけを再試行の根拠にしない。
- `phase: lock`・`state: notStarted` の `REPO_LOCK_TIMEOUT` はリポジトリ変更ロックの取得待ち。競合処理の終了後に再試行でき、必要なら `--lock-timeout-ms` で待機時間を延ばす。他の phase で返った同コードは、その実行状態に従う。
- post-hook 失敗は通常 `warnings`、`--strict-post-hooks` 指定時はエラーになり得る。本体の作成・削除・移送をやり直さず、保持された結果と hook の `details.logPath` を確認する。
- `NOT_INITIALIZED` は必要な初期化、対象不在・曖昧さは対象の再確認、設定不正や `LOCK_CONFLICT` は `details` と `doctor` で原因を調べる。依存の自動導入や別実装への切り替えで回避しない。

変更後は応答の結果を確認し、必要な対象だけを `path`・`status`・monitor で再観測する。
報告には対象パス、完了した操作、警告や未完了部分を含める。
