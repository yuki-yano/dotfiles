# 用途別の実行例

`$repo` は選んだ実行起点、`$path` は CLI が返した対象 worktree のパス、`$owner` はこの作業を区別できる session 固有値に置き換える。
共通の対象解決・初期化・JSON・再試行判断は [SKILL.md](../SKILL.md) に従う。

## 作業場所を準備する

既存 worktree を再利用できる作業には `switch` を使う。
`data.disposition` は `created` または `existing`、移動先は `data.path`。
`data.path` が envelope の `repoRoot` と同じなら primary の再利用であり、linked worktree が必要な依頼ではそのまま作業を始めない。
再利用でも hook が動くため、パス確認だけなら `path` を使う。

```bash
vw -C "$repo" switch feature/topic --json
```

用途が異なる作成操作:

| 意図 | コマンド |
|---|---|
| 新規ブランチを作る | `vw -C "$repo" new feature/topic --json` |
| 名前を任せて WIP を作る | `vw -C "$repo" new --json` |
| remote branch を fetch して作業場所を用意する | `vw -C "$repo" get origin/feature/topic --json` |
| 現在の linked worktree のブランチを改名する | `vw -C "$path" mv feature/renamed --json` |

`switch` の新規ブランチと `new` は設定された base から分岐する。現在の HEAD を起点にするつもりで使わない。新規作成では `.worktreeinclude` の自動コピーもあるため、配置済みのファイルを重複して copy しない。
対話選択を人間に提供するときだけ `vw cd`（fzf が必要）を使う。自動実行では JSON から対象を決める。

## 作業中の worktree を保護する

owner は開始時に一度だけ、例えば `owner="vw-agent-$(date -u +%Y%m%dT%H%M%SZ)-$$"` で生成する。得られた値を保存し、別のツール呼び出しでも同じ値を使う。

```bash
vw -C "$repo" lock feature/topic --owner "$owner" --reason "active task" --json
vw -C "$repo" unlock feature/topic --owner "$owner" --json
```

同じ owner を保持する。自分の作業用の lock はその作業の完了時に解除し、保護を依頼された lock は依頼どおり保持する。
lock は削除からの保護であり、ファイル編集の排他制御ではない。
owner 競合を、許可なく他の owner の指定や `unlock --force` で回避しない。

## 削除・一括整理・管理下への移動

単体削除は対象を明示して検査する。

```bash
vw -C "$repo" check --json -- del feature/topic
```

検査結果と依頼範囲を確認し、適用する場合は `vw -C "$repo" del feature/topic --json` を使う。
merge は `merged.overall` を CLI の最終判定として読む。`null` は不明であり、削除可能という意味ではない。
`merged.byPR` や PR の `status: merged` だけから削除可否を再計算しない。
PR の取得不能や HEAD 不一致は `pr.diagnostic` で確認する。dirty・lock・upstream などの拒否理由は事前検査を正とする。

| 操作 | 候補を確認 | 適用 |
|---|---|---|
| stale な merged worktree を整理 | `vw -C "$repo" gone --json` | `vw -C "$repo" gone --apply --json` |
| 管理ルート外の登録済み worktree を取り込む | `vw -C "$repo" adopt --json` | `vw -C "$repo" adopt --apply --json` |

- 適用は削除・移動まで依頼されている場合だけ行う。適用時には候補が再計算されるので、特定の候補だけが対象なら一括適用しない。
- 通常の preview は `data.candidates` を読む。`check -- gone` / `check -- adopt` は共通検査形式になり、`plannedResult`・`evidence`・`rejections` を読む。`--apply` と `--dry-run` は併用しない。
- `gone` は upstream の ahead を削除ガードにしない。未 push commit の有無を条件にする依頼には、単体 `del` の検査を使う。
- 一括処理の失敗時は `deleted` / `moved` と `failed` を併読し、adopt では `skipped` の理由も読む。完了済みの対象を再処理しない。
- gone は共有ブランチを候補から除外する。候補にない worktree の削除可否が必要なら、単体 `del` の検査で確認する。

## worktree でコマンドを実行する

```bash
vw -C "$repo" --worktree "$path" exec --json -- cargo test
vw -C "$repo" exec feature/topic --json --timeout-ms 600000 --max-output-bytes 2097152 -- cargo test
```

`--` より前が vw のオプション、後ろは子プロセスの argv。shell 展開や pipeline は行われない。
shell が必要なら、依頼された内容を確認して明示的に `sh -c` などへ渡す。

- 既定の timeout は 300000 ms。stdin は閉じられ、入力を渡す場合だけ `--stdin inherit` を指定する。
- JSON では stdout / stderr をそれぞれ既定 1048576 bytes まで保持する。`--max-output-bytes` は `--json` と一緒に指定する。
- `data.childExitCode`・`childSignal`・`timedOut` と、`childStdout`・`childStderr` を読む。子の失敗時に vw が返す終了コードは 21 であり、子の終了コードとは異なる。
- `stdoutTruncated` / `stderrTruncated` が true の出力は全ログとして扱わない。ログ不足だけを理由に副作用のある子コマンドを再実行しない。
- 子の失敗は `error.execution.phase: process`・`state: unknown` で返る。これは vw が子の副作用を保証しないためであり、冪等なテストなどの再試行を一律に禁止する意味ではない。timeout や異常終了でも変更は巻き戻らないため、再実行可否は子コマンドの副作用から判断する。

## ファイル共有と変更移送

copy / link は primary のリポジトリルート相対パスを linked worktree へ配置する。primary 自身をコピー先にはできず、絶対パスや `..` による参照は渡さない。
対象は `--worktree`、`WT_WORKTREE_PATH`、現在 worktree の順で決まる。hook 外では対象を明示する。

```bash
vw -C "$repo" --worktree "$path" copy .env.local --json
vw -C "$repo" --worktree "$path" link config/local.yml --json
```

copy と link は別の操作。link 失敗を copy に置き換えない。

primary の checkout や未コミット変更の移送は、依頼に含まれる場合だけ扱う。
必要なコマンドを `describe` / `--help` で確認し、事前検査してから適用する。

| 意図 | コマンドと前提 |
|---|---|
| primary の現在ブランチを linked worktree に退避 | `extract --current`。dirty なら `--stash` が必須で、付けなければ拒否される |
| linked の変更を primary に移す | `absorb <branch>`。primary は clean |
| primary の変更を linked に戻す | `unabsorb <branch>`。primary は対象ブランチかつ dirty、target は clean |
| primary のブランチを切り替える | `use <branch>`。通常の作業場所準備には `switch` を使う |

`absorb`・`unabsorb`・`use` の非 TTY 実行は `--allow-agent` と `--allow-unsafe` が必要。
移送で使う `--from` / `--to` は管理ルート相対の worktree 名（通常はブランチ名と同じ）を指定する。曖昧エラーの `details.candidates` にある名前を選び、実体の絶対パスは渡さない。
`--keep-stash` がなければ適用済み stash は drop される。移送失敗時は応答の復旧情報を確認し、stash を推測で apply / drop しない。

## hook を手動実行する

`invoke` は名前を指定して hook を実行する。post-hook 失敗への対応では、必要な実行起点・引数と副作用を確認し、hook 単独の再実行が妥当な場合だけ使う。

```bash
vw -C "$path" invoke post-new --json
```

この例の `$path` は作成済み worktree。削除済みのパスを使ったり、元の操作の前後で異なる hook context を推測して再現したりしない。
