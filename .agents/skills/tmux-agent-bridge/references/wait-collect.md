# API wait / collect

guarded terminal transportで送った依頼のstate待ちとterminal response回収、およびcollect-onlyを扱う。Codex durable transportは`durable-api.md`を使う。
`agent steer` receiptはcurrent/next turnの帰属を確定しないため、このwait/collect手順へ接続しない。

## wait

guarded sendの続きでは`agent send` receiptのexact `agent_ref`と`baseline_completed_seq`を使い、一つのAPI subscriptionで新しいcompletionまたはblockedを待つ。

```bash
agent_ref="$(jq -er '.result.send.target.agent_ref' "<作業ディレクトリ>/send.json")"
baseline_completed_seq="$(jq -er '.result.send.baseline_completed_seq' "<作業ディレクトリ>/send.json")"
vt agent wait "$agent_ref" \
  --until done \
  --until blocked \
  --after-completed-seq "$baseline_completed_seq" \
  --timeout-ms 86400000 \
  --json \
  > "<作業ディレクトリ>/wait.json" \
  2> "<作業ディレクトリ>/wait-error.json"
```

送信せずに既存agentの次の完了を待つ依頼では、preflightの`agent get`から同じ二値を固定する。すでにworkingなら`--after-completed-seq`なしでもcurrent run completionを待てるが、idle/doneから次の依頼を外部入力に任せる場合はcursorを明示する。

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent-before.json")"
baseline_completed_seq="$(jq -er '.result.agent.completed_seq' "<作業ディレクトリ>/agent-before.json")"
```

状態ごとの対応:

- `matched_status == done`: collectへ進む。`matched_completed_seq`を次のcursorとして保存する。
- `matched_status == blocked`: [api-state.md](api-state.md)で同じ`state_id`のlifecycleを確認する。`usage_limit`なら`LIMIT-REACHED`、permission/user-input/errorなら表示して停止する。
- API timeout: promptを再送せず、同じ`agent_ref`とcursorでwaitを再開する。
- `stale_reference` / `target_replaced`: 別occupantへ読み替えず停止する。
- `event_history_lost` / `stale_daemon`: `retry_action`に従い同じidentityのcurrent stateを再観測する。cursorより新しいcompletionまたはpersistent blockedを確認できなければ、応答済みと推測しない。

shell toolがyieldした場合は同じprocessを待つ。wait中にEnter、催促、progress確認を送らない。

## collect

exact occupantが残っている場合は`agent read`を使う。

```bash
agent_ref="$(jq -er '.result.target.agent_ref' "<作業ディレクトリ>/wait.json")"
vt agent read "$agent_ref" --source latest --lines 2000 --json \
  > "<作業ディレクトリ>/collect.json" \
  2> "<作業ディレクトリ>/collect-error.json"
jq -er '.result.read.text' "<作業ディレクトリ>/collect.json" \
  > "<作業ディレクトリ>/collect.txt"
```

wait後にexact agent processが終了して`agent read`が使えない場合だけ、wait resultの`target.pane_ref`を使う。pane IDを再解決しない。

```bash
wait_pane_ref="$(jq -er '.result.target.pane_ref' "<作業ディレクトリ>/wait.json")"
vt pane read "$wait_pane_ref" --source latest --lines 2000 --json \
  > "<作業ディレクトリ>/collect.json" \
  2> "<作業ディレクトリ>/collect-error.json"
jq -er '.result.read.text' "<作業ディレクトリ>/collect.json" \
  > "<作業ディレクトリ>/collect.txt"
```

- `.result.read.truncated == true`なら完全回収とみなさない。
- `grep -nF '===BRIDGE-DONE-R1===' "<作業ディレクトリ>/collect.txt"`で連結済みマーカーを探す。
- 依頼文の特徴的な行と最初のマーカーの間だけを読む。2回目以降のマーカーは重複実行として報告する。
- 2000行/API上限でマーカーが見つからなければraw `capture-pane -S`へfallbackせず、未回収として停止する。

## collect-only

送信を伴わない読取では、まず`vt pane get %N --json`で`pane_ref`とoptional `agent_ref`を取得する。

- exact `agent_ref`があれば`vt agent read AGENT_REF --source latest --lines 2000`を使う。
- exact agent identityがなければ、固定した`pane_ref`へ`vt pane read PANE_REF --source latest --lines 2000`を使う。
- `.result.read.text`をfileへ保存し、キーワードで範囲を絞ってから読む。
- `.result.read.truncated`を報告する。相手paneへ何も送信しない。

current stateが`usage_limit`の場合、応答本文を回収済みとは扱わない。reset原文だけを30行のpinned `pane read`で確認して報告する。
