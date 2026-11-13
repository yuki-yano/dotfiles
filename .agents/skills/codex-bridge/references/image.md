# 画像生成

```sh
codex-bridge image generate --prompt '内容' [--input /絶対パス/元画像.png]... [--out /絶対パス/保存先.png]
```

- Codexのモデルに、画像生成ツールで1枚だけ生成させる。1回に30秒前後かかり、ChatGPTのプランの利用枠（画像生成の上限を含む）を消費する。ユーザーが画像を求めたときだけ使い、作り直しや複数枚の生成は了承を得てから行う。
- `--input`は元にする画像。複数指定できる。
- 成功時の`data.path`が画像のパス。`--out`を指定すればそこへコピーし、指定しなければCodexの保存先（`~/.codex/generated_images/`）のパスを返す。`data.revised_prompt`はモデルが整えたプロンプト。
- `--out`に既存のファイルは指定できない（上書きしない）。
- 利用枠の上限に達すると`tool_error`になり、`data.failure.type`が`usageLimitExceeded`になる。自動で再実行しない。
- 生成された画像は、ユーザーに渡すために必要な場所へだけ置く。
