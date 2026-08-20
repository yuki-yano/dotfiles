---
name: tmux-agent-bridge
description: tmux paneのAIエージェント（Claude Code / Codex / opencode等）の一覧・状態確認、指示やレビュー依頼の送信、実行中agentへの追加指示、完了待ちと応答回収、他paneのログ取得、レビュー往復、または明示されたpaneでのagent起動に使う。「agent一覧を確認して」「%Nに送って」「実行中の%Nへ追加で伝えて」「隣のCodexにレビューを依頼して」「終わったら回収して」「右paneを読んで」「このpaneを分割してClaudeを起動して」のような依頼で発動する。文面生成はagent-review-request / agent-handoff-planに任せ、tmuxを介さないsubagent起動には使わない。
---

# tmux Agent Bridge

## 概要

tmux paneを介したエージェント間連携の輸送層。
対象解決、prompt入力、logical key入力、state待ち、利用上限判定、terminal read、明示的な起動をvde-tmux Agent APIで行う。
raw tmux入力やtopology pollingをtransportとして使わない。

## 責務分担

- 文面生成は `agent-review-request`（レビュー）または `agent-handoff-plan`（実装引き継ぎ）に任せる。
- 回収した指摘の判断は `agent-review-request` の受け入れ検証・結果解釈モードに任せる。
- worktree操作は `vw-worktree-ops` に任せる。
- ユーザーが明示した場合だけ`pane split`と`agent start`で新規agentを起動する。worktree・sessionの自動作成、再起動、killは行わない。

## 共通契約

1. 最初に [references/api-state.md](references/api-state.md) を読み、公開schemaを取得する。取得失敗時は停止し、旧raw監視へfallbackしない。
2. `%N`は最初の対象解決だけに使う。取得後は`agent_ref`、`pane_ref`、`run_ref`、`operation_ref`を用途どおり固定し、occupant replacement後に読み替えない。
3. prompt、steer、logical key、split、startを必ず公開APIで実行する。`tmux send-keys`、`paste-buffer`、`split-window`をbridgeから直接実行しない。
4. API errorは`code`、`stage`、`side_effect`、`retry_action`で扱う。`delivery_unknown`、`inspect_manually`、side effectが`possible`の結果からpromptを再送しない。
5. durable Runはprovider completionと完全なResponse Artifactを完了条件とする。guarded terminalはprovider lifecycle completionと連結済み完了マーカーの両方を要求する。
6. 待機時間や画面無変化を完了・失敗・催促の根拠にしない。待機中の追加送信はユーザーが実行中agentへの追加指示を明示した場合だけ`agent steer`で行う。
7. pane/agent全体の一覧・診断は`vt api snapshot --json`を一度だけ使う。raw `tmux list-panes`と複数のlist APIを連結せず、同じ`meta.snapshot_revision`のpane、agent、diagnosticsを扱う。

## transport選択

対象を`vt agent get %N --json`でexact resolveし、`.result.agent.summary.agent`をそのままschemaの`.result.contract.providers[$agent]`へ使う。provider名の変換表をbridgeへ持たない。

| capability | prompt入力 | state待ち | 応答回収 |
|---|---|---|---|
| `prompt_dispatch=durable` | [references/durable-api.md](references/durable-api.md) | stable `run_ref` | Response Artifact |
| `prompt_dispatch=guarded_terminal`かつ`prompt_confirmation=lifecycle_cursor` | [references/send.md](references/send.md) | exact `agent_ref`とcompletion cursor | `agent read` / pinned `pane read` |
| `prompt_confirmation=none`または`prompt_dispatch=disabled` | 送信しない | - | - |

選択したtransportが失敗しても別transportへ切り替えない。
実行中agentへの明示的な追加指示は通常prompt routingと分離し、schemaの`steer=guarded_terminal_best_effort`を要求して[references/send.md](references/send.md)のsteer手順を使う。

## モード判定

| 依頼の形 | モード | 手順 |
|---|---|---|
| 「pane/agent一覧を確認して」「bridgeの状態を診断して」 | inspect | [references/api-state.md](references/api-state.md) のcanonical inventory |
| 「%Nに送って着手させて」「この計画を渡して」 | send | providerに応じて `durable-api.md` または `send.md` |
| 「実行中の%Nへ追加で伝えて」「%Nをsteerして」 | steer | [references/send.md](references/send.md) のbest-effort steer |
| 「%Nが終わったら〜して」「応答を監視して」 | wait | [references/wait-collect.md](references/wait-collect.md) またはdurable Run wait |
| 「%Nの出力・作業ログを読んで報告して」 | collect | [references/wait-collect.md](references/wait-collect.md) |
| 「%Nにレビューを依頼して指摘対応まで」 | loop | [references/review-loop.md](references/review-loop.md) |
| 「paneを分割してagentを起動して」 | spawn | [references/spawn.md](references/spawn.md) |
| 「permissionへy/Enterを送って」 | keys | [references/send.md](references/send.md) のlogical keys |

相談・レビューのsendは自動的にwait → collectまで続ける。ハンドオフはprompt受理をAPI stateで確認するまで続ける。

## prompt受理契約

- durable CodexはOperationの`prompt_confirmed`だけを受理とする。CLI終了コードやtmux入力成功では判定しない。
- guarded terminal providerは`agent send` receiptの`baseline_completed_seq`を使い、exact `agent wait`で新しい`working`、`blocked`、またはcursorより新しい`done`を確認して受理とする。API成功だけでは受理済みと報告しない。
- best-effort steerの成功はtmux input適用だけを示す。current turnへの受理・割り込み・応答帰属は報告せず、完了競合では次turnになり得ることを明記する。
- guarded terminal sendのtyped timeoutや`delivery_unknown`からpromptを再送しない。

## 待機契約

- Codex durable Runは`vt agent run wait RUN_REF`のdefault matchを使い、`completed`だけでなく`waiting`、`error`、`ended_unconfirmed`も直ちに扱う。`--until completed`で利用上限やpermission待ちを隠さない。
- guarded terminal providerは`vt agent wait AGENT_REF --until done --until blocked --after-completed-seq N`を一つのsubscriptionとして使う。
- CLI/toolのyieldは同じprocessを待つ。24時間のAPI timeout時だけ同じstable referenceとcursorでwaitを再開し、promptを再送しない。
- `event_history_lost`やdaemon restartでは`retry_action`に従ってstateを再観測する。別occupantへreferenceを更新して同じ依頼を継続しない。

## 利用上限到達

`lifecycle.state == "waiting"`かつ`lifecycle.reason == "usage_limit"`を`LIMIT-REACHED`の正とする。vde-tmuxはClaude Codeのrate-limit hookと、Claude Code/Codexの厳密なprovider文言をdaemon側で検証するため、bridge自身でscreen文字列をbaseline比較しない。

- 利用上限はsemantic completionではない。待機・回収・レビュー往復を停止し、同じpromptの再送、時計ベースの自動再開、別transportへのfallbackを行わない。
- reset原文が必要な場合だけ、固定済み`pane_ref`へ`vt pane read --source latest --lines 30`を実行する。
- pane、provider state、原文中のreset時刻を報告し、「相手paneの応答は利用上限到達により未回収」と明記する。
- 回復は後続の`SessionStart`または`UserPromptSubmit`でAPI stateが更新された事実から判断し、表示時刻の経過だけでは推測しない。

## 完了マーカー規約

- guarded terminal transportで応答を回収する通常prompt末尾にだけtask固有マーカーの出力指示を付ける。durable Response Artifactとbest-effort steerではマーカーを要求しない。
- 完全なマーカー文字列を依頼文へ書かない。次の分割形式を使う。

  ```text
  応答の最後に、`===BRIDGE-DONE-R1` と `===` を連結した1行を出力してください。
  ```

- 連結済み`===BRIDGE-DONE-R1===`だけを`grep -F`で判定する。bounded terminal readにマーカーがなければprotocol異常として停止する。

## ハング・state drift

- exact process absence、terminal静止、ready表示だけでcompletionとしない。
- Codexのcurrent durable Runでprovider completion欠落が疑われる場合だけ、`durable-api.md`の`run check` → operator確認 → `run resolve`を使う。自動wait loopへresolveを組み込まない。
- historical Run、active subagent、permission/user-input待ち、stale preconditionはresolveしない。
- guarded terminal providerのstate driftはAPI state、pinned read、typed errorを記録して報告し、raw `ps`診断や追加キー送信へ拡張しない。

## よくある失敗

| 兆候・言い訳 | 実際 |
|---|---|
| 「state確認だけtmux captureでよい」 | API revision subscriptionとcanonical lifecycleを迂回し、古いscrollbackやreplacementを誤認する |
| 「limit文をgrepすればよい」 | daemonが`usage_limit`を厳密検出・保持する。bridgeはAPI reasonを使い、原文はreset時刻確認時だけ読む |
| 「Run waitはcompletedだけ待てばよい」 | usage limit、permission、error、`ended_unconfirmed`を隠して待ち続ける。default matchを使う |
| 「delivery_unknownなのでraw送信する」 | side effect済みの可能性がある。同じOperationをinspectし、再送しない |
| 「agentが交代したので新しいrefへ続ける」 | 別occupantへの誤配送になる。元の依頼を停止して報告する |
| 「Response Artifactがないのでpaneを読む」 | durable Codexではfallback禁止。artifact unavailable/expired/truncatedを未回収として報告する |
| 「timeoutしたので打ち切る」 | 24時間上限はAPI呼び出しの期限。stable referenceでwaitを再開する |
| 「steer成功後に最初のdoneを応答として回収する」 | steerはcurrent/next turn帰属を証明しない。receiptを通常sendのacceptance/waitへ接続しない |
| 「pane一覧とagent一覧をまとめてshellで取ればよい」 | `vt api snapshot --json`が同一revisionのcanonical inventoryを返す。raw tmuxとの連結は観測競合と不要な出力を増やす |
| 「送信後もprompt fileがあるので受理済み」 | prompt fileはcaller-owned inputにすぎない。Operation、Run、send receiptとprovider stateで受理を判定する |
