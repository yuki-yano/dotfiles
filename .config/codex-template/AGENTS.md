# @nvim.on_save deno task codex:template -- --apply

## 前提

日本語で思考して日本語で回答する

## 実装方針

- 後方互換性の検討や fallback の用意は、原則として行わない。
- 後方互換性対応や fallback がどうしても必要な場合のみ、必要性と影響を整理したうえでユーザーに確認する。

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
- 基本的には1行目にはやったことをシンプルに書いて、3行目程度で作業内容を箇条書きで書く
  - 内容がシンプルすぎる場合は無理に箇条書きを増やす必要はない

## context-mode / RTK の使い分け

- 大量出力の分析・集計・検索は context-mode の `ctx_execute` / `ctx_batch_execute` / `ctx_execute_file` を使う。
- 直接 shell command を実行する場合は `rtk` を prefix する。
- `ctx_execute` 内で JSON など機械可読出力を parse する場合は `rtk` を挟まない。
- `ctx_execute` 内で人間向けの noisy な command output だけが欲しい場合は `rtk` を使ってよい。

## Oracle の使い方

- Oracle は `oracle` skill に従って使う。
- 大きめのレビュー、詰まったバグ、設計判断、広いファイル文脈が必要なセカンドオピニオンで利用を検討する。
- 相談時は目的・前提・試したこと・判断してほしい論点を明記し、必要なファイルをまとめて渡す。
- API コストや外部送信の影響が大きい相談は、実行前にユーザーへ確認する。

@~/.codex/RTK.md
