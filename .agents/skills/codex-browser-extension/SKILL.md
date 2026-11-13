---
name: codex-browser-extension
description: Codex App以外（Codex CLI、T3 Codeなど）で動くCodexから、ChatGPT公式ブラウザ拡張（Chrome拡張）経由でユーザーのブラウザを直接操作するときに使う。Codex App内のチャットや、App経由の中継（codex-bridge browser run）を明示されたときは使わない。
---

# codex-browser-extension

ChatGPT Appは、Codex CLIやT3 CodeのCodexも読むplugin cacheから公式の`chrome:control-chrome` skillを削除する。Codex App以外ではこのskillから公式手順を読む。

1. `/Applications/ChatGPT.app/Contents/Resources/plugins/openai-bundled/plugins/chrome/skills/control-chrome/SKILL.md`を全文読み、以下の読み替えで従う。
2. `<plugin root>`は`/Users/yuki-yano/.codex/plugins/cache/openai-bundled/chrome/latest`。`browser-client.mjs`はこの絶対パスからimportする。
3. 実行は`mcp__node_repl__js`だけを使う。Codex App以外の`cua_repl`はブラウザ一覧の取得で`The browser access host is unavailable`になる。
4. 「Chrome拡張」「ブラウザ拡張」「公式拡張」は拡張そのものを指す。Google ChromeやBraveなどのブラウザ名を明示されない限り、`agent.browsers.get("extension")`で接続中の拡張を選ぶ。
5. 接続・選択に失敗したらエラー本文を報告し、AGENTS.mdのブラウザ操作の順序に従う。`codex-bridge browser run`へは切り替えない。
