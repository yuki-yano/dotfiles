# Compact State Format

compact 前 checkpoint の state file 形式の正本。compact-guard.sh の自動 nudge と compact-state skill の両方がこのファイルを参照する。見出しをここで変更すれば両経路に反映される。

## Headings

以下の見出しをこの順で必ず含める。`headings` フェンスブロックは compact-guard.sh が機械的に抽出するため、フェンス内には見出し行以外を書かない。

```headings
# Compact Prep State
## Active Plan
## Current Phase
## TaskList Summary
## Session Decisions
## Constraints and Blockers
## Worker Topology
## Skills Invoked
## Editing Files
## Failed Attempts
## Recovery Notes
```

## Section Assignment

- Active Plan: active plan のパス、タイトル、現在のセクションと進行状態。plan がなければ `Not verified`。
- Current Phase: 直近で完了した作業と残作業を事実として書く。
- TaskList Summary: 見えている task id、件名、状態。
- Session Decisions: 確定した決定、却下した代替案、理由、ユーザーが承認したスコープ。
- Constraints and Blockers: ハード制約、スキップした検証、権限の制限、外部ブロッカー、未検証事項。
- Worker Topology: tmux pane、worker、役割、責務。使っていなければ `Not used`。
- Skills Invoked: セッション中に呼び出した skill と slash command。呼び出し記録であって現在有効な証明ではない。
- Editing Files: 変更中・変更済みファイルと、staged / committed / dirty / 生成物などの注記。
- Failed Attempts: 失敗したコマンド、ツールエラー、却下した実装方針と、その理由。繰り返しを防げる程度に具体的に書く。
- Recovery Notes: session_id、branch、重要コマンド、検証結果、transcript path、再開に必要な事実。

## Writing Policy

- 事実のみを書く。確認できないことは書かず、不明な項目は `Not verified` とする。
- 「次に X をせよ」のような命令形を使わず、未完了作業は事実として表現する。
- パス、URL、コマンド名、commit id、pane id、エラーメッセージは原文のまま保持する。
- 簡潔に書くが、判断理由・失敗した試行・制約は省略しない。
- 言語はセッションの作業言語に合わせる (通常は日本語)。
