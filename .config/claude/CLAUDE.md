@~/.codex/AGENTS.md
@RTK.md

## RTK の厳密出力

- 正確なパス、件数、JSON、機械可読出力、存在判定が必要な場合は `rtk proxy <cmd>` を使い、`rtk` の要約・整形結果を根拠にしない。
- skill / plugin / file discovery では `rtk find` の compact 出力を根拠にせず、`rtk proxy /usr/bin/find ... -print` か `rg --files` を使う。
