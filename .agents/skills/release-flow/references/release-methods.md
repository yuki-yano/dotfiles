# リリース方式別の実行手順

依頼範囲とプロジェクトの運用が一致する方式の節だけ読む。
各手順は既存の専用scriptやCIフローを優先し、依頼されていない操作を追加しない。
preflightは本体の条件に従って成功済み結果を再利用できる。

## Web deploy 型（wrangler 等）

1. **現状確認**: branch、remote、依頼対象の差分、package.jsonのdeploy script、プロジェクト固有手順を確認する
2. **preflight**: lockfileからpackage managerを特定し、そのprojectのbuild scriptを実行する
   （deploy script に build が含まれる場合も、push 前に失敗を検知するため単独で先に実行する）。
   lint / typecheck の script があれば併走
3. **差分再確認**: preflightによる想定外の生成差分がなく、commit対象が依頼範囲と一致することを確認する
4. **commit**: 依頼された範囲の差分をコミットする（メッセージは過去ログの形式に合わせる）
5. **push**: `git push origin HEAD`
6. **deploy**: package.json の `deploy` script を使う（例: `pnpm run deploy`）。
   独自の deploy script がある場合に生の `wrangler deploy` を直接叩かない
   （script 側の build 前処理や環境指定が抜けるため）
7. **検証**: deploy コマンドの出力から反映先（URL / version ID）を確認して報告する。
   エラー・警告は結果への影響を確認し、公開状態と残る問題を区別して報告する

## タグ publish 型（GitHub Actions + npm/レジストリ）

1. **現状確認**: branch、remote、依頼対象の差分、`package.json`の現在値から次に公開するversionを決め、
   local/remote tagとレジストリの公開済みversionを確認する。
   次に公開するversionまたはそのtagが既に存在する場合は、過去の公開結果を確認し、重ねて発行しない
2. **preflight**: プロジェクトの ci 相当（`pnpm run ci` / lint + typecheck + test）と build を実行
3. **bump**: `npm version <patch|指定> --no-git-tag-version`。
   version 以外の差分が混ざっていないか確認する
4. **bump後再検証**: buildと、既存のpack/dry-run検証があれば実行する。
   bump後のmanifestと生成物を使った検証が失敗した場合はcommitしない
5. **commit & tag**: 直近のversion bump commit形式に合わせてコミットする。
   規約を確認できない場合だけ`Bump version to <version>`を使い、annotated/lightweightの既存規約に合わせて`v<version>` tagを作る
6. **atomic push**: `git push --atomic origin HEAD refs/tags/v<version>`でbranchとtagを同時にpushする。
   remoteがatomic pushを受け付けない場合は、非atomic pushへ自動で切り替えず停止して確認する
7. **workflow 監視**: tag triggerを確認したworkflow file名を使って`gh run list --workflow <workflow-file> --limit 5`でrunを特定し、
   `gh run watch <run-id>` で完了まで見届ける。失敗したら
   `gh run view <run-id> --log-failed` で原因を取得して報告する
8. **公開検証**: `npm view <pkg>@<version> version`で対象versionの存在を確認し、dist-tagも既存の公開規約に一致することを確認して報告する

## ローカルpublish・個別方式

README、Makefile、`.github/workflows/`、専用skillから実際のリリース経路を確認する。
明示されたpublish・deployの指示から対象と手順を特定できれば、preflight完了後に実行する。
対象registry、環境、version、権限が不明で公開先や影響が変わる場合は、準備と検証を済ませ、
不足する判断を確認してから実行する。公開コマンド名や設定ファイルの有無だけで経路を決めない。
