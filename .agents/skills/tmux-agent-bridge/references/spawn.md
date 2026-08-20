# pane split / agent start

ユーザーがtmux内での新規agent起動を明示した場合だけ使う。sessionやworktreeを自動作成せず、既存のexact paneを起点にする。

## 1. 起点を固定する

`vt pane get %N --json`または`vt pane current --json`を実行し、返された`pane_ref`、`current_path`、session/windowを保存する。以降のmutationへ`%N`を渡さない。

## 2. splitを作る

既定ではfocusを奪わない。

```bash
vt pane split "$pane_ref" \
  --direction right \
  --size-percent 50 \
  --json \
  > "<作業ディレクトリ>/split.json" \
  2> "<作業ディレクトリ>/split-error.json"
```

- `--direction`は`right`または`down`を明示する。
- `--cwd`を省略すると起点paneのcwdを継承する。別worktreeへ移る場合だけabsolute pathを指定する。
- ユーザーがfocus移動を求めた場合だけ`--focus`を付ける。
- 成功はtmux作成とdaemon canonical topology反映の両方を含む。`.result.split.pane_ref`を次へ渡す。
- `side_effect=possible|confirmed`のerrorからsplitを再実行しない。作成済みpaneを`vt pane list`で確認して報告する。

## 3. agentを起動する

```bash
new_pane_ref="$(jq -er '.result.split.pane_ref' "<作業ディレクトリ>/split.json")"
vt agent start "$new_pane_ref" \
  --agent codex \
  --timeout-ms 120000 \
  --json \
  > "<作業ディレクトリ>/start.json" \
  2> "<作業ディレクトリ>/start-error.json"
```

- `--agent`はschemaの`capabilities.start`が`disabled`でないkindだけを使う。
- provider引数は必要なものだけを`--arg VALUE`として繰り返す。prompt本文を起動引数へ含めない。
- 成功時の`.result.start.agent_ref`はexact occupantであり、`.result.start.readiness`はschemaのstart capabilityと一致する。`provider_session`はprovider session観測後にprocess identityを再検証済み、`durable_initial_prompt`はsession未確定でもdurable first-prompt可能、`input_owner_only`はprovider受理を保証しない。
- `agent_busy`は起動済みか別occupantである。killや再起動を行わない。
- after-dispatch timeout、`delivery_unknown`、`side_effect=confirmed|possible`ではstartを再実行しない。返されたpane_refを`pane get`し、現在のoccupantを報告する。

## 4. promptを送る

起動直後でもexact `agent_ref`が返っていれば通常のprovider routingへ進む。Codexのprovider session未確定はdurable `agent prompt`が最初の`UserPromptSubmit`で確定する。Claude Codeは`agent start`がprovider sessionを観測してから返る。`input_owner_only`かつ`prompt_confirmation=none`では送信しない。raw EnterやSessionStartの捏造を行わない。

## 既定の非対応範囲

- session作成、worktree作成、category割当
- 既存paneのrespawn、agentのkill・再起動
- alias名によるoccupant再解決
- split方向、cwd、focusの推測による追加layout変更
