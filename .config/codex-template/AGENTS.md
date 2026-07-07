# @nvim.on_save deno task codex:template -- --apply

## 前提

日本語で思考して日本語で回答する

## 実装方針

- 後方互換性の検討や fallback の用意は、原則として行わない。
- 後方互換性対応や fallback がどうしても必要な場合のみ、必要性と影響を整理したうえでユーザーに確認する。

## 作業分担

- タスクに着手する前に、サブエージェントへ分担すべき独立作業があるかを判断する。
- 調査・レビュー・検証・複数候補の比較など、並列化によって品質や速度が上がる作業は積極的にサブエージェントへ委譲する。
- サブエージェントを使う場合も、最終判断・統合・ユーザーへの報告はメインエージェントが責任を持つ。

## 設計・計画

- 設計書・計画書を作成する際は、必ず DoD（Definition of Done）を明記する。DoD
  は測定可能な完了条件として、少なくとも「機能完了条件」「テスト完了条件」「運用反映条件」をチェックリストで記載し、DoD未記載の文書は未完了扱いとする。

## Git のルール

- 意図しない差分を見つけたらユーザーに確認する。
- `push --force-with-lease` は、使ってもよいがユーザーに確認してから行う
- `reset` は `--hard` は使わないようにする、もし使う場合はユーザーに確認してから行う
- `git checkout .` `git restore .` などで差分をHEADまで巻き戻す作業は危険なことが多いので、ユーザーに確認してから行う

### add

- ignoreされているものは絶対に -f で強制的にaddしない

### commit

- 明示的なcommitの指示があるまで勝手にcommitはしない
- commit messageは過去のcommit logを見てある程度フォーマットを合わせる
- `git commit` で複数行のメッセージを書く場合は、`-m` を連続して使わず、1つの `-m` に改行を含めて指定する。複数の `-m` は段落として扱われ、各 `-m` の間に空行が入るため、3行目以降の箇条書きに余分な空行が入る。
- 基本的には1行目にはやったことをシンプルに書いて、3行目程度で作業内容を箇条書きで書く
  - 内容がシンプルすぎる場合は無理に箇条書きを増やす必要はない

## context-mode / RTK の使い分け

- 大量出力の分析・集計・検索は context-mode の `ctx_execute` / `ctx_batch_execute` / `ctx_execute_file` を使う。
- 直接 shell command を実行する場合は `rtk` を prefix する。
- 正確なパス、件数、JSON、機械可読出力、存在判定が必要な場合は `rtk proxy <cmd>` を使い、`rtk` の要約・整形結果を根拠にしない。
- skill / plugin / file discovery では `rtk find` の compact 出力を根拠にせず、`rtk proxy /usr/bin/find ... -print` か `rg --files` を使う。
- `ctx_execute` 内で JSON など機械可読出力を parse する場合は `rtk` を挟まない。
- `ctx_execute` 内で人間向けの noisy な command output だけが欲しい場合は `rtk` を使ってよい。

@~/.codex/RTK.md
