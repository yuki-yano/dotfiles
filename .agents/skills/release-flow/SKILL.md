---
name: release-flow
description: commit、push、deploy、version bump、publishを一連で行うよう依頼されたときに使う。commit整理だけ、deployだけ、CI修正、デプロイ基盤構築では使わない。
---

# Release Flow

## Overview

「commit して deploy と push」「patch を上げて publish」という依頼を、
プロジェクトのリリース方式に合わせて preflight → 実行 → 結果検証まで一貫して行う。

最初にリリース方式を判別し、該当する 1 つのフローだけを実行する:

| 方式 | 判別材料 | フロー |
|---|---|---|
| Web deploy 型 | `wrangler.toml` / `wrangler.jsonc` / package.json に `deploy` script | preflight → commit → push → deploy → 検証 |
| タグ publish 型 | `.github/workflows/` に `v*` tag起動のworkflow + package version | preflight → version bump → 再検証 → commit/tag → atomic push → workflow 監視 → 公開検証 |
| 個別型 | 上記以外（Cargo・独自 workflow・Makefile 等） | リポジトリの手順を調査し、ユーザーに確認してから実行 |

プロジェクトローカルに専用のリリーススキル（例: vde-layout の `vde-layout-publish`）が
存在する場合はそちらを優先する。このスキルは専用手順を持たないプロジェクト向けの汎用版。

## Mandatory Rules

- commit の指示が含まれない依頼（「deploy だけ」等）では commit しない。
  逆に「commit して〜」と言われたときの commit は明示指示なので実行してよい。
  差分の意図別分割が必要そうなボリュームなら commit-plan スキルに従う。
- `git status` で意図しない差分（依頼内容と無関係なファイル）を見つけたら、
  進める前にユーザーに確認する。
- バージョン指定がなければ patch bump を既定にする。minor / major は明示指示があるときのみ。
- リリース用の新規ブランチを勝手に作らない。現在のブランチで進める。
- commit、version bump、tag、push、deploy、publishより前にpreflightを完了する。
- preflight（ci / build）が 1 つでも失敗したら、そこでリリースを止めて報告する。
  「デプロイは通りそうだから続行」はしない。壊れた成果物の公開は取り消しが利かない。
- 各状態変更後に`git status --short`と直前の操作結果を確認する。
  想定外の差分、tag、公開状態が生じた場合は次の状態変更へ進まない。

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
   出力にエラーや警告があれば成功と報告せず内容を示す

## タグ publish 型（GitHub Actions + npm/レジストリ）

1. **現状確認**: branch、remote、依頼対象の差分、`package.json` の現在バージョン、local/remote tag、
   レジストリの公開済みバージョンを確認する（`npm view <pkg> version dist-tags --json`）。
   重複するversionまたはtagがあれば停止する
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
8. **公開検証**: `npm view <pkg> version` が期待バージョンになったことを確認して報告する

tag起動のpublish workflowが無く、ローカルから直接 `npm publish` / `cargo publish` / `deno publish` する
運用のプロジェクトでは、公開コマンドの実行前にユーザーに一言確認する
（公開は取り消せない操作のため）。

## 個別型

`wrangler.toml` / `wrangler.jsonc` もtag起動のpublish workflowも無い場合は、README・Makefile・`.github/workflows/` を読んで
リリース手順を特定し、「この手順で進める」という要約をユーザーに確認してから実行する。
特定できない場合は推測で公開系コマンドを実行しない。

## 報告フォーマット

完了時は次を報告する:

- コミット: ハッシュとメッセージ
- 反映先: deploy 先 URL / 公開バージョンとレジストリ / workflow run の結果
- preflight で実行したコマンドと結果

途中で止めた場合は、どのステップで何が失敗したか・リリースがどこまで進んだ状態か
（例: 「タグは push 済みだが workflow が失敗、npm 未公開」）を必ず明示する。
中途半端な状態の放置が一番危険なので、復旧に必要な選択肢も添える。
