# guarded terminal send / best-effort steer / logical keys

durable provider adapterを持たないが、API v4で`guarded_terminal`と`lifecycle_cursor`を公開するproviderへ使う。prompt入力、copy-mode解除、pane/process/input-owner fenceは`vt agent send`が担当する。raw tmuxへfallbackしない。

## prompt send

### 1. preflight

[api-state.md](api-state.md)でversion gateとexact target resolveを行い、次を保存する。

```bash
vt agent get %N --json \
  > "<作業ディレクトリ>/agent-before.json" \
  2> "<作業ディレクトリ>/agent-before-error.json"
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent-before.json")"
```

- `identity=exact`、`status=idle|done`、非`usage_limit`を要求する。
- 対象kindのschema capabilityが`prompt_dispatch=guarded_terminal`かつ`prompt_confirmation=lifecycle_cursor`であることを要求する。
- `working`、`blocked`、confirmation `none`では送信しない。

### 2. prompt body

promptをprivate temporary fileへ保存する。応答回収が必要ならSKILL.mdの分割マーカー指示を末尾へ付ける。本文をargvへ含めない。

### 3. guarded dispatch

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent-before.json")"
vt agent send "$agent_ref" \
  --prompt-file "<作業ディレクトリ>/prompt.txt" \
  --json \
  > "<作業ディレクトリ>/send.json" \
  2> "<作業ディレクトリ>/send-error.json"
```

`agent send`は次を一つのguarded tmux commandで行う。

- exact server、pane ID/PID、foreground commandを再検証する。
- exact agent processがforeground input ownerであることを確認する。
- copy-modeを解除し、解除後にpane identityを再検証する。
- private bufferからbracketed pasteし、Enterを送る。
- bufferを削除し、side-effect markerを確認する。

成功receiptの`target.agent_ref`、`target.pane_ref`、`baseline_state_revision`、`baseline_run_seq`、`baseline_completed_seq`を保存する。API成功はtmux input適用であり、provider受理ではない。

### 4. acceptance

```bash
agent_ref="$(jq -er '.result.send.target.agent_ref' "<作業ディレクトリ>/send.json")"
baseline_completed_seq="$(jq -er '.result.send.baseline_completed_seq' "<作業ディレクトリ>/send.json")"
vt agent wait "$agent_ref" \
  --until working \
  --until blocked \
  --until done \
  --after-completed-seq "$baseline_completed_seq" \
  --timeout-ms 10000 \
  --json \
  > "<作業ディレクトリ>/acceptance.json" \
  2> "<作業ディレクトリ>/acceptance-error.json"
```

- `working`: `ACCEPTED`。応答が必要なら[wait-collect.md](wait-collect.md)へ進む。
- cursorより新しい`done`: 高速完了した`ACCEPTED`。collectへ進む。
- `blocked`: lifecycleを再取得する。`usage_limit`なら`LIMIT-REACHED`、permission/user-input/errorなら停止する。
- timeout、`event_history_lost`、`stale_reference`、`delivery_unknown`: promptを再送しない。receiptとtyped errorを報告する。

ハンドオフは`ACCEPTED`確認で終了する。`agent send`のexit 0だけで送信完了と報告しない。

## best-effort steer

ユーザーが実行中agentへの追加指示を明示した場合だけ使う。通常send、催促、進捗確認の代わりには使わない。

### 1. preflight

[api-state.md](api-state.md)でversion gateとexact target resolveを行い、`identity=exact`、`status=working`、非`usage_limit`を要求する。対象kindのschema capabilityは`steer=guarded_terminal_best_effort`でなければならない。

`idle|done`なら通常sendへ自動的に切り替えず停止する。state確認とdispatchの競合で`invalid_target`になった場合も同様に、targetを再解決して送らない。

### 2. guarded steer

本文をprivate temporary fileへ保存し、argvへ含めない。steerは応答帰属を証明できないため、完了マーカー指示を追加しない。

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent-before.json")"
vt agent steer "$agent_ref" \
  --prompt-file "<作業ディレクトリ>/steer.txt" \
  --json \
  > "<作業ディレクトリ>/steer.json" \
  2> "<作業ディレクトリ>/steer-error.json"
jq -e '
  .result.type == "agent_steer" and
  .result.steer.dispatch == "guarded_terminal_best_effort" and
  .result.steer.race_policy == "may_start_next_turn"
' "<作業ディレクトリ>/steer.json"
```

APIがcopy-mode解除、exact pane/process/input-owner fence、private buffer入力を行う。成功はtmux input適用だけを示す。`DISPATCHED-BEST-EFFORT`として報告し、current turnへの受理や割り込みを主張しない。完了との競合では次turnになり得ることを併記する。

receiptの`baseline_completed_seq`を通常sendのacceptanceや応答回収へ接続しない。current turnとnext turnのどちらへ入ったかをAPIが確定しないため、最初の`done`はsteerへの応答完了を意味しない。応答が必要な依頼はagentが`idle|done`になってから、別の通常sendとしてユーザーに依頼し直してもらう。

non-zero、`delivery_unknown`、`side_effect=possible|confirmed`から再送しない。通常send、durable prompt、raw tmuxへのfallbackも行わない。

## logical keys

ユーザーが対象blocked promptと送るlogical keysを明示した場合だけ使う。通常のprompt送信や催促へ使わない。

```bash
vt agent get %N --json > "<作業ディレクトリ>/blocked-agent.json"
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/blocked-agent.json")"
vt agent send-keys "$agent_ref" \
  --key y \
  --key Enter \
  --json \
  > "<作業ディレクトリ>/keys.json" \
  2> "<作業ディレクトリ>/keys-error.json"
```

- exact identity、`status=blocked`、`capabilities.interactive_keys=true`を要求する。
- APIのallowlistにあるlogical keyまたは一文字だけを送る。prompt本文をkey列へ分解しない。
- APIがcopy-mode解除、input-owner確認、pane/process再検証を行う。
- `side_effect=possible|confirmed`のerrorからkeyを再送しない。
- 送信後は同じexact refのstate更新を観測し、別occupantへ続きを送らない。
