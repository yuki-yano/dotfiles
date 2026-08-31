# Codex durable API transport

公開APIでprompt dispatch、Run state待ち、Response Artifact回収を一つのstable-reference chainとして扱う。

## 選択条件

[api-state.md](api-state.md)でschema取得とexact target resolveを行い、次をすべて満たす場合だけ選ぶ。

- targetの`identity == exact`、`agent_ref`あり。
- 対象kindの`.capabilities.prompt_dispatch == "durable"`、`.prompt_confirmation == "provider_digest"`、`.response == "artifact"`。
- targetが`idle`または`done`で、`usage_limit`、permission、active runではない。

`agent_session_id`が未登録でも、exactなCodex processが同一なら`vt agent request`が最初の`UserPromptSubmit`でprovider sessionを確定する。bridge側でraw送信、sleep、SessionStartの捏造を行わない。

durable provider contractが無効なら停止する。guarded terminalへfallbackしない。

## dispatch

target JSONから`agent_ref`、`pane_ref`、`pane_id`、`state_id`を保存する。新しいprompt intentごとに、privateな作業ディレクトリ内の未使用`request.json` pathを一つ選ぶ。prompt bodyは初回だけstdinで渡し、bridgeがretry用`prompt.txt`を作成・保持しない。ユーザーが既存fileを入力sourceとして明示した場合だけ`--prompt-file`を使う。

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent.json")"
vt agent request "$agent_ref" \
  --state-file "<作業ディレクトリ>/request.json" \
  --stdin \
  --json \
  > "<作業ディレクトリ>/prompt-result.json" \
  2> "<作業ディレクトリ>/prompt-error.json" <<'VDE_PROMPT'
<送信するprompt本文>
VDE_PROMPT

operation_ref="$(jq -er '.result.operation_ref' "<作業ディレクトリ>/prompt-result.json")"
run_ref="$(jq -er '.result.run_ref' "<作業ディレクトリ>/prompt-result.json")"
```

prompt本文に`VDE_PROMPT`だけの行が含まれる場合は、本文と衝突しないheredoc delimiterへ変更する。

APIはstdin末尾のLFまたはCRLFを一つtext-record terminatorとして除去する。vtはdaemon mutation前にOperation ID、exact target、normalized digest、retry bodyをrequest-stateへ保存する。bridgeはstateをopaqueとして扱い、内容を読取・編集・複製しない。

CLI response loss後のresumeは、同じexact targetとrequest-state pathだけを渡す。prompt bodyやOperation IDを再構成しない。

```bash
agent_ref="$(jq -er '.result.agent.summary.agent_ref' "<作業ディレクトリ>/agent.json")"
vt agent request "$agent_ref" \
  --state-file "<作業ディレクトリ>/request.json" \
  --json \
  > "<作業ディレクトリ>/prompt-result.json" \
  2> "<作業ディレクトリ>/prompt-error.json"
```

同じpathは同じlogical requestを表す。新しい依頼や別targetへ流用しない。task終了時は作業ディレクトリごとcleanupする。

`agent request`はOperationがterminalになるまで待つ。成功時の`.result.operation.dispatch_state == "prompt_confirmed"`とnon-null `.result.run_ref`を`ACCEPTED`とする。成功後に`operation wait/get`を重ねない。

- typed `retry_same_request`: 同じexact targetとrequest-state pathだけでresumeする。
- receiptなし`delivery_unknown` / `inspect_manually`: stateは同じID/bodyを保持する。新path、body再指定、別transportへ進まない。同じpathの再呼出しは元Operationの明示的なidempotent replayなので、曖昧結果を確認した上で同じ依頼を継続すると判断した場合だけ使う。
- Operation receipt付き`delivery_unknown` / `inspect_manually`: vtはstateへ`operation_ref`を保存してbodyを削除する。request-state resumeはOperation queryだけを行う。late confirmationを継続待機する明示判断時はerror receiptの同じ`operation_ref`へ`operation wait --follow-unknown`を使う。
- `rejected`: receiptを保存して停止する。新targetや別transportへ自動切替しない。
- `request_state_busy`: 先行processを待ち、同じpathで再実行する。`request_state_mismatch` / `request_state_invalid`: 停止し、stateを手修正しない。

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
