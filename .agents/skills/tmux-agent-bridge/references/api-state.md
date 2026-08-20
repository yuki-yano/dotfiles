# API state

対象解決、transport選択、state分類、limit判定、typed error処理の共通手順。

## working directory

最初に`mktemp -d "${TMPDIR:-/tmp}/tmux-agent-bridge.XXXXXX"`を実行し、出力された絶対パスを記録する。以降はtool call間の環境変数へ依存せず、`<作業ディレクトリ>`をその絶対パスへ置換する。

## schema取得

```bash
vt api schema --json \
  > "<作業ディレクトリ>/schema.json" \
  2> "<作業ディレクトリ>/schema-error.json"
```

schema取得失敗、daemon not Ready、`state_uninitialized`では停止する。raw tmux state監視へfallbackしない。

## canonical inventory

pane、agent、daemon diagnosticsをまとめて確認するときは一つのcanonical snapshotを保存する。

```bash
vt api snapshot --json \
  > "<作業ディレクトリ>/snapshot.json" \
  2> "<作業ディレクトリ>/snapshot-error.json"
jq -e '
  .result.type == "snapshot" and
  (.meta.snapshot_revision | type == "number") and
  (.result.panes | type == "array") and
  (.result.agents | type == "array") and
  (.result.diagnostics | type == "array")
' "<作業ディレクトリ>/snapshot.json"
```

- `.result.panes`はcanonical topology上でliveなpaneだけを返す。`pane_dead`を別途raw tmuxで補わない。
- paneとagentは`pane_ref`で対応付ける。対象操作へ進む場合だけ`agent get %N`でexact identityを解決する。
- `meta.diagnostic_count != 0`なら同じ応答の`.result.diagnostics`を読む。
- `tmux list-panes`、`vt pane list`、`vt agent list`を一つのshell commandへ連結しない。別観測のrevision競合を避けるため、全体確認にはこのsnapshotだけを使う。
- prompt fileはcaller-ownedなrequest inputであり、一覧APIの対象ではない。作成直後に必要ならreadable/sizeをローカル確認できるが、dispatch後の存在やmtimeを受理・配送の証拠にしない。Operation、Run、send receiptを使う。

## exact target resolve

```bash
vt agent get %N --json \
  > "<作業ディレクトリ>/agent.json" \
  2> "<作業ディレクトリ>/agent-error.json"
if jq -e '
  .result.agent.summary.lifecycle.state == "waiting" and
  .result.agent.summary.lifecycle.reason == "usage_limit"
' "<作業ディレクトリ>/agent.json" > /dev/null; then
  echo 'LIMIT-REACHED'
  exit 3
fi
jq -e '
  .result.agent.summary.identity == "exact" and
  (.result.agent.summary.agent_ref | type == "string")
' "<作業ディレクトリ>/agent.json"
```

最初の`jq`がtrueならexact identityがなくても`LIMIT-REACHED`として停止し、`pane_ref`でreset原文を読む。falseならstatusをmode別に分類してからexact identityを要求する。通常sendは`idle|done`、明示的なsteerは`working`だけを続行条件とする。`blocked`はどちらも停止する。

次を保存する。

- `.result.agent.summary.agent_ref`
- `.result.agent.summary.pane_ref` / `pane_id` / `pane_pid`
- `.result.agent.summary.agent` / `status` / `lifecycle`
- `.result.agent.state_id` / `agent_epoch` / `run_seq` / `completed_seq`
- optional `.result.agent.summary.current_run.run_ref`

process scan中の`identity=inferred`は送信・exact wait・agent readへ使わない。exactになるまでstate更新を待つか、停止して報告する。

## provider routing

schemaのpathは`.result.contract.providers`。provider keyはagent kindと同じ値であり、変換しない。

```bash
agent_kind="$(jq -er '.result.agent.summary.agent' "<作業ディレクトリ>/agent.json")"
jq -e --arg provider "$agent_kind" '
  .result.contract.providers[$provider].agent_kind == $provider
' "<作業ディレクトリ>/schema.json"
jq -er --arg provider "$agent_kind" '
  .result.contract.providers[$provider].capabilities.prompt_dispatch
' "<作業ディレクトリ>/schema.json"
jq -er --arg provider "$agent_kind" '
  .result.contract.providers[$provider].capabilities.prompt_confirmation
' "<作業ディレクトリ>/schema.json"
jq -er --arg provider "$agent_kind" '
  .result.contract.providers[$provider].capabilities.steer
' "<作業ディレクトリ>/schema.json"
```

- `prompt_dispatch=durable`: durable API transport。
- `prompt_dispatch=guarded_terminal`かつ`prompt_confirmation=lifecycle_cursor`: guarded terminal API transport。
- `prompt_confirmation=none`または`prompt_dispatch=disabled`: 停止。raw promptへfallbackしない。
- 明示的な実行中追加指示は`steer=guarded_terminal_best_effort`だけを受け付ける。`disabled`なら停止し、通常sendやraw入力へ切り替えない。

## state classification

`agent get`のcanonical summaryを次の順で判定する。

1. `lifecycle.state == waiting && lifecycle.reason == usage_limit`: `LIMIT-REACHED`。
2. `status == blocked`: permission/user-input/errorとして停止し、reasonを報告する。
3. `status == working`: 通常promptを送らない。ユーザーが実行中追加指示を明示し、provider capabilityが許可する場合だけbest-effort steerへ進む。
4. `status == idle || status == done`: 送信preflightを続けられる。

absent usage-limited agentは`present=false`かつ`agent_ref`なしでもpane IDからqueryできる。同じtaskの判定では`state_id`と`agent_epoch`が送信前と一致することを確認し、replacementを誤認しない。

## usage-limit detail

API stateが`usage_limit`の場合だけ、providerのreset原文を読む。

```bash
vt pane read "$pane_ref" --source latest --lines 30 --json \
  > "<作業ディレクトリ>/usage-limit.json" \
  2> "<作業ディレクトリ>/usage-limit-error.json"
jq -er '.result.read.text' "<作業ディレクトリ>/usage-limit.json"
```

一般的なrate-limit文、statusline残量、古いscrollbackをbridge側のstate根拠にしない。時計到達で自動解除せず、後続`SessionStart`または`UserPromptSubmit`後のcanonical stateを再観測する。

## typed errors

API commandのnon-zero時もJSON error envelopeを保存し、`error.retry_action`で分岐する。

| retry_action | bridgeの扱い |
|---|---|
| `retry_same_request` | side effectなしを確認し、同じoperation ID / target / bodyだけを再要求できる |
| `wait_then_retry` | capacity/state変化後に同じqueryまたはwaitを再実行する。promptは勝手に再送しない |
| `restart_observation` | current stateを再取得し、元のstable identityと一致する場合だけwait/readを再開する |
| `refresh_target` | 現依頼を停止する。新targetへの同じprompt再送はユーザー指示が必要 |
| `inspect_manually` | side effectの可能性を報告し、再送しない |
| `never` | request/configurationを直すまで停止する |

`delivery_unknown`は常にmanual inspectionとし、別operation ID、raw tmux、空Enterで補完しない。
