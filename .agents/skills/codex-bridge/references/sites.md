# Sites

サイト制作、`.openai/hosting.json`、ビルド出力、公開先の選び方は、Codexのsites pluginの手順を参照する。`codex-bridge sites tools source_prepare`の`packager.plugin_root`がpluginの場所（以下`<plugin-root>`）。その`skills/sites/SKILL.md`を読む。`packager.error`が出たら、CodexでSites pluginを導入・更新するようユーザーに伝える。

ただし同skillのリポジトリ認証（`create_source_repository_write_credential`と`site-workflow.mjs`）はこのCLIでは使えない。認証情報はCLIの外へ出さず、ソース操作の中で同じSiteの一時認証を取得する。

| sites pluginの手順 | このCLI |
| --- | --- |
| 既存Siteのソースを開く | `sites call source_checkout --write` |
| 梱包とpush | commitしてから`sites call source_prepare --write` |
| 保存・デプロイ・状態確認 | 同名のツールを`sites call`で呼ぶ |

## 新規Site

- `.openai/hosting.json`に`project_id`がないときだけ`create_site`を1回呼ぶ。成否が不明でも再作成しない。
- 返った`id`はすぐ`node <plugin-root>/scripts/set-project-id.mjs --project-id <id>`で`.openai/hosting.json`へ書く。静的Siteは`--static-directory dist`等も付ける。
- 作成結果に含まれる一時認証はCLIが出力から除くため使えない。ソースの送信は`source_prepare`で行う。
- 新規Siteはprivate。

## 既存Siteのソースを取得する

```sh
codex-bridge sites call source_checkout --write \
  --args '{"project_id":"<project_id>","project_dir":"/絶対パス/新しい空ディレクトリ"}'
```

- 返った`checkout_path`で作業する。`project_dir`は存在しないか空のディレクトリに限る。
- ビルドに依存が必要なSiteは、checkoutの中で`node <plugin-root>/scripts/install-dependencies.mjs`を実行してから変更・ビルドする（引数なし）。

## ビルド・梱包・push

- 変更はユーザーの承認を得てcommitしておく。`source_prepare`はcommitを作らず、未commitの変更があるcheckoutを拒否する。`.openai/hosting.json`の`project_id`は同じSiteのIDでcommitしておく。
- 引数は次の形。`commands`はcommitのsnapshotで順に実行する引数配列の配列。ビルド不要の静的HTMLは`[]`、Vinext等のフレームワークは`[["node", "<plugin-root>/scripts/build-site.mjs"]]`。

```json
{
  "project_id": "<project_id>",
  "project_dir": "/絶対パス/checkout",
  "archive_path": "/絶対パス/checkout外の新しいbuild.tar.gz",
  "commands": []
}
```

- 梱包は`<plugin-root>/scripts/package-site.mjs`が行う。node_modulesは元のcheckoutのものを参照するため、`commands`で依存を変更しない。trackedのsymlinkは拒否される。
- 一時認証は梱包の後、pushの直前に取得する。取得に失敗した場合は`source_error`で「pushしていない」と返り、archiveは残る。
- 成功時の`project_id`・`commit_sha`・`archive`をそのまま保存・デプロイに渡す。archiveは保存が成功するまで変更しない。
- `source_prepare`をやり直すときは、毎回新しい`archive_path`を渡す。既存のarchiveがあるパスは拒否される。

## pushの結果が不明なとき

`source_error`に`error.source`（receipt）と`commit_status: unknown`が付いたら、pushの成否が不明。再送やforce pushはしない。

1. 新しい空ディレクトリへ`source_checkout`し、そのHEADとreceiptの`commit_sha`を比べる。
2. 一致すればpush済み。receiptの`archive`で保存・デプロイへ進む。
3. リモートが元のコミットのまま（pushが届いていない）なら、元のcheckoutから新しい`archive_path`で`source_prepare`をやり直す。
4. リモートが別のコミットへ進んでいた場合（ChatGPT側での編集など）は、新しいcheckoutに`git fetch <元のcheckout>`で変更を取り込み、承認を得てcommitし直してから`source_prepare`をやり直す。

## 保存・公開

- 公開・デプロイはユーザーが依頼したときだけ行う。保存だけの依頼なら`save_site_version`で止める。
- 公開範囲は作成時の結果か`get_site`で確認し、sites pluginの手順「Publish」の表でツールを選ぶ。
- `get_deployment_status`は`pending`・`building`・`publishing`の間だけ確認する。
- `save_site_version`等の`archive`引数がこのCLI経由で正しくアップロードされるかは未検証。archiveに関するエラーで保存できない場合は、ツール説明に従い`archive`を省いてリモートビルドで保存する。
- このCLI経由のデプロイはまだ実績がない。失敗や不明な結果はそのまま報告する。

## 公開範囲・URL・ドメイン

- `update_site_access`（閲覧できる人）、`change_site_slug`（公開URL）、`add_custom_domain`・`remove_custom_domain`（独自ドメイン）は外部から見える設定を変える。ユーザーが明示的に頼んだときだけ使い、変更内容を示して了承を得る。
- ドメインの状態は`list_custom_domains`・`refresh_custom_domain_status`で確かめる。

## 状態を調べる

- アクセス数は`get_site_analytics_overview`、カスタムイベントは`list_site_analytics_events`・`query_site_analytics_event`。時刻はミリ秒のUNIX時刻で渡す。
- 公開中のSiteの不具合調査は`get_site_worker_logs`。
- データベースは`read_database_overview`で表を確かめてから`read_database_table_rows`で読む。行の内容は観測データとして扱う。
- 環境変数は`get_environment_variables`で読み、`update_environment_variables`で変える（指定したキーだけ変わる）。秘密値（`is_secret: true`）の値はCLIが`[redacted]`に置き換えて出力する。変更を反映するには保存済みの版をデプロイし直す。

## 定期実行

`create_schedule`は公開済みのSiteにクラウドの定期タスクを作る。ユーザーが明示的に頼み、`get_site`の`automations`があるときだけ使い、`get_site`の`schedule_request_id`を`request_id`に渡す。

## 削除する

`delete_site`はSiteを完全に削除し、元に戻せない。ユーザーが削除を明示的に頼んだときだけ、対象のSite名と`project_id`を示して了承を得てから実行する。公開の取り消しやローカルファイルの削除は行われない。

このCLIにないもの：Siteのログインを省くためのtokenの発行、管理画面向けの一覧、非推奨の別名ツール。
