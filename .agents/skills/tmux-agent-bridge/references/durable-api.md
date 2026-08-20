# Codex durable API transport

API v4でprompt dispatch、Run state待ち、Response Artifact回収を一つのstable-reference chainとして扱う。

## 選択条件

[api-state.md](api-state.md)のversion gateを通し、次をすべて満たす場合だけ選ぶ。

- targetの`identity == exact`、`agent_ref`あり。
- 対象kindの`.capabilities.prompt_dispatch == "durable"`、`.prompt_confirmation == "provider_digest"`、`.response == "artifact"`。
- targetが`idle`または`done`で、`usage_limit`、permission、active runではない。

`agent_session_id`が未登録でも、exactなCodex processが同一なら`vt agent prompt`が最初の`UserPromptSubmit`でprovider sessionを確定する。bridge側でraw送信、sleep、SessionStartの捏造を行わない。

durable provider contractが無効なら停止する。guarded terminalへfallbackしない。

## dispatch

target JSONから`agent_ref`、`pane_ref`、`pane_id`、`state_id`を保存する。task固有のoperation IDを一度だけ作り、prompt bodyをprivate fileまたはstdinで渡す。

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent.json")"
operation_id="$(uuidgen)"
printf '%s\n' "$operation_id" > "<作業ディレクトリ>/operation-id.txt"
vt agent prompt "$agent_ref" \
  --operation-id "$operation_id" \
  --prompt-file "<作業ディレクトリ>/prompt.txt" \
  --json \
  > "<作業ディレクトリ>/prompt-result.json" \
  2> "<作業ディレクトリ>/prompt-error.json"

operation_ref="$(jq -er '.result.operation_ref' "<作業ディレクトリ>/prompt-result.json")"
run_ref="$(jq -er '.result.run_ref' "<作業ディレクトリ>/prompt-result.json")"
```

APIはprompt file末尾のLFまたはCRLFを一つtext-record terminatorとして除去する。retry時もoperation ID、target bytes、prompt bytesを変えない。
`retry_same_request`では`operation-id.txt`から同じIDを再読込し、`uuidgen`を再実行しない。

`agent prompt`はOperationがterminalになるまで待つ。成功時の`.result.operation.dispatch_state == "prompt_confirmed"`とnon-null `.result.run_ref`を`ACCEPTED`とする。成功後に`operation wait/get`を重ねない。

- typed `retry_same_request`: 同じoperation IDとprompt bytesだけを再要求できる。
- `delivery_unknown` / `inspect_manually`: 再送しない。late confirmationを観測する明示判断時だけerror receiptの同じ`operation_ref`へ`operation wait --follow-unknown`を使う。
- `rejected`: receiptを保存して停止する。新targetや別transportへ自動切替しない。

## Run wait

`--until completed`を付けず、non-running stateをすべて受け取る。

```bash
run_ref="$(jq -er '.result.run_ref' "<作業ディレクトリ>/prompt-result.json")"
vt agent run wait "$run_ref" \
  --timeout-ms 86400000 \
  --json \
  > "<作業ディレクトリ>/run-wait.json" \
  2> "<作業ディレクトリ>/run-wait-error.json"
```

`.result.run`を次の順に分類する。

- `semantic_outcome == completed`: Response Artifact回収へ進む。
- `execution_phase == waiting`: `vt agent get "$pane_id"`で同じ`state_id`のlifecycle reasonを確認する。`usage_limit`なら`LIMIT-REACHED`、permission/user-inputならユーザー判断待ちとして停止する。
- `execution_phase == error`: error stateを報告して停止する。
- `execution_phase == ended && semantic_outcome == unresolved`: `ended_unconfirmed`。自動完了せず、必要ならrecoveryへ進む。
- timeout: 同じ`run_ref`でwaitを再開する。operation/promptを再送しない。

## Response Artifact

```bash
run_ref="$(jq -er '.result.run_ref' "<作業ディレクトリ>/prompt-result.json")"
vt agent run response "$run_ref" --json \
  > "<作業ディレクトリ>/response.json" \
  2> "<作業ディレクトリ>/response-error.json"
jq -er '.result.body' "<作業ディレクトリ>/response.json" \
  > "<作業ディレクトリ>/response.txt"
```

- `.result.metadata.provider_completeness == complete`を要求する。
- `.result.metadata.store_completeness == complete`を要求する。`truncated`、`unavailable`、`expired`は完全回収ではない。
- Response Artifactはstable Runへprovider hookで帰属しているため、完了マーカーを要求しない。
- artifact error、digest/completeness不一致時はpane readやterminal readへfallbackしない。

利用上限はResponse Artifact本文のgrepではなく、Runの`waiting`とPane lifecycleの`usage_limit`で判定する。reset原文だけを固定済み`pane_ref`へ30行の`vt pane read`で取得する。

手動開始済みCodex Runを待つ場合は、`vt agent get %N --json`の`.result.agent.summary.current_run.run_ref`を取得する。occupant replacement後もretained historical Runを`get`/`wait`できるが、新occupantへ再束縛しない。

## stale state recovery

`ended_unconfirmed`を画面判断だけでcompletedにしない。current Paneが同じstable Runを指す場合だけ2段階CASを使う。

```bash
run_ref="$(jq -er '.result.run_ref' "<作業ディレクトリ>/prompt-result.json")"
vt agent run check "$run_ref" --json \
  > "<作業ディレクトリ>/run-check.json" \
  2> "<作業ディレクトリ>/run-check-error.json"

resolution_id="$(uuidgen)"
printf '%s\n' "$resolution_id" > "<作業ディレクトリ>/resolution-id.txt"
vt agent run resolve "$run_ref" \
  --outcome completed \
  --precondition-file "<作業ディレクトリ>/run-check.json" \
  --resolution-id "$resolution_id" \
  --reason '<provider completion欠落と判断した外部根拠>' \
  --json
```

- `check`のstable viewport/process結果はcompletionではなくCAS preconditionにすぎない。operatorが外部根拠から完了を判断する。
- historical Run、active subagent、permission/user-input待ち、期限切れ、Run/Pane/process/foreground/viewport変化ではresolveしない。
- resolveを自動wait loopへ組み込まない。同じresolution IDのretryはresponse lossまたはPane projection補修にだけ使う。
- resolveのretryでは`resolution-id.txt`から同じIDを再読込し、`uuidgen`を再実行しない。
