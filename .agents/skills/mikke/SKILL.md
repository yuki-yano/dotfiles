---
name: mikke
description: 現在の Git リポジトリにある Markdown の設計、仕様、過去記録を検索するときに使う。ソースコードのシンボル検索や Web の最新情報には使わない。
---

# mikke

`mikke` CLI で現在のリポジトリの Markdown を検索し、必要な文書だけを根拠として読む。
検索セマンティクスの正本は [kimushun1101/mikke](https://github.com/kimushun1101/mikke) の `docs/SPEC.md` とする。

## 検索ルート

- ユーザーが対象 repo を指定した場合は、その repo の `git rev-parse --show-toplevel` を使う。
- 指定がない場合は、現在の cwd から `git rev-parse --show-toplevel` で repo root を解決する。
- Git リポジトリでない場合は対象 root をユーザーに確認する。別のディレクトリを推測しない。
- 解決した絶対パスを `repo_root` とし、コマンドには常に `--root "$repo_root"` を指定する。
- `.mikke/` は再生成可能な検索 index である。内容を直接読まない。
- ノートや設定を無断で変更しない。検索と読み取りに限定する。
- `mikke` は Markdown 検索用である。ソースコード、設定値、シンボルは `rg` など通常のコード検索を使う。

## 検索手順

1. `mikke --version` と `test -d "$repo_root"` で前提を確認する。
2. セッションで初めて検索する時、または Markdown が変わった後は `mikke --root "$repo_root" index` で index を更新する。
3. 固有名詞、型番、エラーメッセージ、本文にありそうな語は `mikke --root "$repo_root" find <語...>` で検索する。
4. `.mikke/embeddings/` が存在する repo で、言い換えを含む概念的な問いを探す場合は `mikke --root "$repo_root" hybrid <自然文>` を使う。
5. 結果の title、tags、summary から候補を絞り、表示された path のノートだけを読む。
6. 根拠に使ったノートの path を回答に示す。

`find` の複数語は全語 AND であり、語を増やすほど結果が絞られる。
0 件の場合は語を減らすか言い換えて再検索する。
embedding がある repo では次に `hybrid` を試し、それでも見つからない場合だけ `rg` で repo 内の Markdown を直接検索する。

## 補助コマンド

- 最近の記録から探す: `mikke --root "$repo_root" recent 10`
- タグから探す: `mikke --root "$repo_root" list-tags` の後に `tag <タグ>`
- タイトルから探す: `mikke --root "$repo_root" title <語>`
- 引数に迷った場合: `mikke <サブコマンド> --help`

`mikke embed` はモデルの初回ダウンロードを伴うため、ユーザーが明示的に求めた場合だけ実行する。
