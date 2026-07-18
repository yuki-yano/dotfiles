---
name: tmux-agent-bridge
description: 別のtmux paneで動いているAIエージェント（Claude Code / Codex / opencode等）へ指示やレビュー依頼を送信する、応答の完了を待って回収する、他paneのエージェントの出力や作業ログを読む、レビュー往復ループを回すときに使う。「%Nのpaneに送って」「隣のpaneのCodexにレビューを依頼して」「あのpaneが終わったら続きをやって」「右のpaneの作業を読んでまとめて」のような依頼で発動する。送る文面の作成自体（レビュー依頼文・handoffプロンプト）では使わず、agent-review-request / agent-handoff-plan に任せる。tmuxを介さないsubagent起動や並列化にも使わない。
---

# tmux Agent Bridge

## 概要

tmux paneを介したエージェント間連携の輸送層。
「どのpaneへ・どう送り・どう待ち・どう読むか」だけを所有し、文面の中身と品質には関与しない。

## 責務分担

- 送る文面の生成は `agent-review-request`（レビュー依頼）と `agent-handoff-plan`（実装引き継ぎ）に任せる。
- 回収した指摘の妥当性判断は `agent-review-request` の受け入れ検証・結果解釈モードに任せる。
- worktreeの操作が必要になったら `vw-worktree-ops` に任せる。
- 相手paneのエージェントの新規起動・再起動・killはこのスキルの責務外。既存paneへの送受信のみを扱う。

## 制約

1. 操作前に毎回、対象paneの生存と `pane_current_command` を確認する。pane消失時は即中断してユーザーに報告する。
2. 対象pane以外のpane・window・sessionに触らない。tmuxサーバーのkill・detachをしない。
3. プロンプト本文を `send-keys` の引数に直接渡さない。必ずファイル → `load-buffer` → `paste-buffer -p` 経由で送る。
4. Enterは独立した `send-keys` で送り、送る前に貼り付け内容をcaptureで確認する。
5. 応答の完了判定は完了マーカーまたは機械的基準で行う。「それらしい出力が見えた」という目視ヒューリスティックで完了扱いしない。
6. スクロールバックの大量captureを直接読まない。ファイルへダンプし、マーカーをgrepしてから必要範囲だけ読む。

## モード判定

| 依頼の形 | モード | 手順 |
|---|---|---|
| 「%Nに送って着手させて」「この計画を渡して」 | send | [references/send.md](references/send.md) |
| 「%Nが終わったら〜して」「応答を監視して」 | wait | [references/wait-collect.md](references/wait-collect.md) |
| 「%Nの出力・作業ログを読んで報告して」 | collect | [references/wait-collect.md](references/wait-collect.md) |
| 「%Nにレビューを依頼して指摘対応まで」「must-fixゼロまで往復して」 | loop | [references/review-loop.md](references/review-loop.md) |

sendで送った後に応答が必要な依頼（相談・レビュー依頼）は、自動的に wait → collect まで続ける。
ハンドオフのように「渡して終わり」の依頼は、相手が作業を開始したことの確認（受理確認）までで止める。

## 完了マーカー規約

- 応答を回収する送信では、文面の末尾に完了マーカーの出力指示を必ず付ける。識別子はタスクごとに変える（例: `BRIDGE-DONE-R1`）。
- **依頼文の中に完全なマーカー文字列を書かない。** pane上に残る依頼文のエコーにgrepがマッチし、応答前に完了と誤判定するため。指示は分割形式で書く:

  ```
  応答の最後に、`===BRIDGE-DONE-R1` と `===` を連結した1行を出力してください。
  ```

  受信側が連結した `===BRIDGE-DONE-R1===` だけが完了判定の対象になる。
- マーカーは `===[A-Z0-9-]+===` の形式に限る。待機・回収時は連結済み文字列の `grep -F` で判定する。
- 相手がマーカー指示を無視した場合のfallbackは wait-collect.md の停滞判定に従い、fallbackで完了扱いしたことを報告に明記する。

## 前提条件

- tmuxコマンドが `error connecting to ... (Operation not permitted)` で失敗する場合、sandboxがtmuxソケットへのアクセスを遮断している。`.claude/settings.json` のsandbox設定にtmuxソケット（`/private/tmp/tmux-*` など）への許可を追加してから再開する。勝手に設定を書き換えず、変更内容をユーザーに確認する。
- 対象paneがデフォルト以外のtmuxサーバー（`-L` / `-S` 指定）で動いている場合、全コマンドに同じソケット指定を付ける。

## よくある失敗

| 兆候・言い訳 | 実際 |
|---|---|
| 「短い文面だからsend-keys直渡しでよい」 | 直渡しは約16KBで `command too long` になる実測があるうえ、`"$(cat file)"` は末尾改行を落とすため最終行が未送信のまま残る。長さに関係なくbuffer経由にする |
| 「Enterは改行が含まれているから不要」 | paste-bufferは入力欄に貼るだけで送信されない。Enterの別送が常に必要 |
| 「送信できたはずなので待つ」 | 送信が無反応になる事例がある。受理確認（入力欄の変化）まで見てから待ちに入る |
| 「sleepを数回入れれば応答は揃う」 | 応答時間は数秒〜60分超まで幅がある。固定sleepではなくマーカー検出+停滞判定で待つ |
| 「capture -S -10000 で全部読めばよい」 | 1回で数万トークンを消費した実測がある。ファイルへダンプして必要範囲だけ読む |
| 「起動直後だがそのまま送る」 | 起動バナー表示中の送信は取りこぼす。プロンプト（入力受付表示）を確認してから送る |

## 将来の拡張（未実装）

vde-monitorのHTTP API（pane状態JSON・テキスト送信・SSE）が利用可能な環境では、画面スクレイピングをAPIへ置き換える構想がある。現時点では素のtmuxのみを使う。
