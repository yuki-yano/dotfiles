# @nvim.on_save deno task codex:template -- --apply

## 前提

日本語で思考して日本語で回答する

## 実装方針

- 後方互換性の検討や fallback の用意は、原則として行わない。
- 後方互換性対応や fallback がどうしても必要な場合のみ、必要性と影響を整理したうえでユーザーに確認する。

## 設計・計画

- 設計書・計画書を作成する際は、必ず DoD（Definition of Done）を明記する。DoD
  は測定可能な完了条件として、少なくとも「機能完了条件」「テスト完了条件」「運用反映条件」をチェックリストで記載し、DoD未記載の文書は未完了扱いとする。

## ブラウザ操作

- Web上の情報検索、公式ドキュメントの参照、URL内容の取得だけなら、検索・HTTP取得・専用connectorを使い、`agent-browser`を起動しない。
- click、入力、login、screenshot、visual QAなど、実際のブラウザUI操作が必要な場合は、目的専用のconnector・API・CLI、実行環境が提供するin-app BrowserまたはChrome操作、`agent-browser`の順で選ぶ。
- ユーザーが利用するブラウザ手段を明示した場合は、その指定を優先する。
- ログイン済みbrowser profileが必要で、in-app BrowserやChrome操作が使えない場合は、`agent-browser`より`chrome-profile-browser`を優先する。
- `agent-browser`は、CLIとして再現可能な操作、独立session、録画、Electron操作、専用workflowが必要な場合、または適切な組み込みUI操作手段がない場合に使う。`agent-browser`の`SKILL.md`にある「組み込みbrowserより優先する」という指示より、この選択順を優先する。
- `agent-browser`を使う前に`agent-browser skills get core`を読み、specialized skillは該当する作業だけで追加読込する。
- `agent-browser`コマンドが存在しない場合、installを自動実行せず、不足していることをユーザーへ報告する。

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
