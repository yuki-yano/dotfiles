---
name: compact-state
description: Claude Code の /compact 前に、セッション状態の checkpoint を手動で保存するときに使う。「/compact-state」「compact 前に状態を保存して」「checkpoint を保存して」と依頼されたときに発動する。圧縮後の復旧作業、通常の進捗報告、plan 作成では使わない。
---

# compact-state

60/75/90% の自動 nudge (compact-guard.sh) と同じ state file を、任意のタイミングで agent 自身が書く手動経路。閾値到達前に /compact したい場合や、復旧メモを厚く残したい場合に使う。

## 手順

1. `~/.config/claude/scripts/get-session-id.sh` を実行して session id を取得する。取得できない場合は推測でファイル名を作らず、準備未完了であることを報告して停止する。
2. `~/.config/claude/compact-state` を作成して権限を `0700` に固定し、保存先を `~/.config/claude/compact-state/${SESSION_ID}.md` に固定する。
3. TaskList、`~/.config/claude/plans` 配下の active plan、編集中ファイル、セッション中の決定事項を確認する。
4. `references/state-format.md` の見出しと記載方針に従って state file を書く。既存ファイルがあれば全置換ではなく更新する (新事実の追加、変化した事実の改訂、他は保持)。
5. 保存した state file の権限を `0600` に固定する。
6. 保存後にファイルを読み直し、必須見出しがすべて存在することを確認する。
7. 完了受領として以下を報告する。
   - state file のパス
   - 保存した主な項目
   - 未検証の項目と理由
   - 「いつでも /compact を実行できます」

## 備考

- state file は compaction 後に SessionStart(compact) hook (compact-recovery.sh) の recovery 注入が参照する。
- PreCompact hook (compact-precompact.sh) が `## Machine Facts (PreCompact)` 節を自動で追記・差し替えるため、この節は手で書かない。
