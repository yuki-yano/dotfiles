# @nvim.on_save deno task codex:template -- --apply

## 前提

日本語で思考して日本語で回答する

## 作業の進め方

- 実装・修正の依頼は、依頼範囲の変更、必要な検証、判明した不具合の修正まで続ける。調査だけ・計画だけ・レビューだけの依頼では、その範囲を守る。
- 既に明示された実行指示や承認は同じ範囲で引き継ぎ、手順ごとに確認し直さない。対象・影響が変わる場合や、下記の確認必須操作では確認する。
- 読む文書・skill・参照ファイルは、今回の判断に必要なものを選ぶ。軽微な変更のために全体調査や一律の手順を追加しない。
- 検証は変更の影響範囲に合わせる。同じ差分で成功済みの検証は、新しい失敗や懸念がなければ繰り返さない。細かなUI修正ごとのE2E・画面確認は避け、大きな変更の節目や表示不具合の確認時に行う。

## 実装方針

- 後方互換性の検討や fallback の用意は、原則として行わない。
- 後方互換性対応や fallback がどうしても必要な場合のみ、必要性と影響を整理したうえでユーザーに確認する。

## 設計・計画

- 設計書・計画書には、測定可能なDoD（Definition of Done）を「機能完了条件」「テスト完了条件」「運用反映条件」のチェックリストで記載する。DoD未記載の文書は未完了扱いとする。

## ブラウザ操作

- Web上の情報検索、公式ドキュメントの参照、URL内容の取得だけなら、検索・HTTP取得・専用connectorを使い、`agent-browser`を起動しない。
- click、入力、login、screenshot、visual QAなど、実際のブラウザUI操作が必要な場合は、目的専用のconnector・API・CLI、実行環境が提供するin-app BrowserまたはChrome操作、`agent-browser`の順で選ぶ。
- ユーザーが指定した操作手段を優先する。`@Browser`指定時は`cua_repl`のin-app Browser操作面を使う。Chrome操作時も提供ドキュメントで操作面を選び、OSのComputer Useと取り違えない。
- 利用可否は、提供ツール、説明、接続結果で判断する。Codex CLIであることやin-app BrowserのskillがないことだけでChrome操作を利用不可と判断しない。
- 署名・信頼チェックで失敗した場合は、使用したツールとエラー本文を確認して原因を調べる。別のブラウザ操作手段へ自動的に切り替えない。
- ログイン済みbrowser profileが必要で、in-app BrowserやChrome操作が使えない場合は、`agent-browser`より`chrome-profile-browser`を優先する。
- `agent-browser`は、CLIとして再現可能な操作、独立session、録画、Electron操作、専用workflowが必要な場合、または適切な組み込みUI操作手段がない場合に使う。`agent-browser`の`SKILL.md`にある「組み込みbrowserより優先する」という指示より、この選択順を優先する。
- `agent-browser`を使う前に`agent-browser skills get core`を読み、specialized skillは該当作業だけ追加読込する。コマンドがなければ自動installせず不足を報告する。

## Git のルール

- 意図しない差分を見つけたらユーザーに確認する。
- `push --force-with-lease`はユーザーに確認してから行う。`git reset --hard`、`git checkout .`、`git restore .`など差分をHEADまで巻き戻す操作も、事前に確認する。

### add

- ignoreされているものは絶対に -f で強制的にaddしない

### commit

- 明示的なcommitの指示があるまで勝手にcommitはしない
- commit messageは過去のcommit logを見てある程度フォーマットを合わせる
- 複数行のcommit messageは、1つの`-m`に改行を含めて渡す。`-m`の繰り返しによる箇条書き間の余分な空行を避ける。
- 基本的には1行目にはやったことをシンプルに書いて、3行目程度で作業内容を箇条書きで書く
  - 内容がシンプルすぎる場合は無理に箇条書きを増やす必要はない
