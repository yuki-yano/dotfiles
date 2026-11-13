# Pages

対象は、Pageの検索・一覧・本文参照・作成・編集・移動・コメント、ゴミ箱への移動、共有、メタデータ、自動更新、ネイティブ文書（プレゼンテーション等）、可視化、ファイル。使えるツールは`codex-bridge pages tools`で確認する。

このCLIにないもの：`progress_update`（共同編集中の進捗表示）、`upload_artifact_images`（クラウド作業領域からの画像追加）、プレゼンテーションの取り込み状況の確認。

## 読む

- 一覧は`list_pages`、検索は`find_pages`、本文は`read_page`。`read_page`の読み方（`view`、`search`、`block_ids`等）は`tools read_page`の説明から選ぶ。
- Pageが参照する画像は`read_page_reference`で読む。画像は一時ファイルに保存され、`images[].path`で返る。Pageに紐づくファイルの検索は`search_page_file_references`。
- 結果は後の編集で使うため、`codex-bridge pages call read_page --args @... > /絶対パス/page.json`のようにファイルへ保存する。

## 作成・編集する

1. Codexのpages pluginにある編集手順を読む。`ls ~/.codex/plugins/cache/openai-curated-remote/pages/`で最新版を選び、`skills/write-page/SKILL.md`と`skills/write-page/references/edit-requests.md`を読む。ツール説明が「write-page skill」と呼ぶのはこれ。見つからない場合は`tools edit_page`・`tools patch_page`の説明だけで進め、その旨を報告する。
2. 編集前に対象Pageを`read_page`で読み、出力をファイルに保存する。`page_id`、ブロックID、hash、`metadata.stream_kind`（返らない場合は省略する）は保存した出力から`jq`で取り出して引数ファイルを作る。`create_page`の応答にも作成したブロックのIDとhashが入る。
3. ブロック内の文言置換は`patch_page`、ブロックの追加・削除・分割・移動やタイトル変更は`edit_page`、状態・担当者などは`edit_page_metadata`。選び方と引数は各ツールの説明に従う。
4. `--write --args @/絶対パス/args.json`で送る。
5. `read_page`で読み戻し、変更が反映されたことを確認する。成功時の応答には`commit_status`がなく、`operation_results`と読み戻しで確かめる。タイトル変更の応答には新しいタイトルや`title_hash`が入らないので、続けて編集するときは読み直す。

write-page skill内の確認用ツール（`request_user_input_async`等）は使えない。確認はチャットで行う。

## 削除する

- `trash_page`はPageと配下のPageをゴミ箱へ移す。`trash_space`はSpace全体とそのPageをゴミ箱へ移す（SpaceはLibraryのゴミ箱から復元できる）。
- 対象のタイトルと配下の有無を`read_page`や`list_pages`で確かめ、ユーザーに示して明示的な了承を得てから実行する。
- ゴミ箱へ移したPageは、`read_page`で`tool_error`（`page_not_found`）になる。

## 共有する

- 最初に`get_sharing_availability`で共有管理が使えるかを確かめる。使えなければ理由を伝えて止める。
- 現状は`get_page_sharing`・`get_space_sharing`で読む。共有相手のIDは`search_sharing_recipients`の結果を使い、推測しない。
- `update_page_sharing`・`update_space_sharing`は、ユーザーが共有の変更を明示的に頼んだときだけ使う。誰に何の権限が付くかを示して了承を得る。結果が不明なら再実行せず、共有状態を読み直す。

## ネイティブ文書・可視化・ファイル

- プレゼンテーション等のネイティブ文書は、`create_presentation`で作り、`inspect_artifact`で読み、`execute_artifact_code`で編集する。編集の成否が不明なら`get_artifact_execution_status`で確かめ、再実行しない。コールバックの書き方は各ツールの説明に従う。
- `create_page_visualization`はHTML（256KiBまで）をPageへ可視化として挿入する。
- `write_page_reference`はローカルのファイルをPageのFilesへ上げる。このCLI経由でファイルが実際にアップロードされるかは未検証。返ったMarkdownは`edit_page`でPageに挿入する。

## 自動更新

- `list_page_automations`・`get_page_auto_update`で現状を読む。
- `set_page_auto_update`、`run_page_auto_update`、`attach_automation_to_page`、`create_controller_automation`はクラウドで定期実行を作成・実行する。ユーザーが明示的に頼んだときだけ使う。
