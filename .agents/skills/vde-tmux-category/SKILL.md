---
name: vde-tmux-category
description: vde-tmuxのCategory一覧、Repository所属確認、既存Categoryへの分類移動、Automatic Classificationへの復帰を依頼されたときに使う。Category作成、改名、削除、表示順変更、session切替、tmux pane間のAgent操作には使わない。
---

# vde-tmux Category

Repository単位のCategory所属を、`vt`のversioned JSON APIだけで観測・変更する。

## Schema gate

1. `command -v vt`でCLIの存在を確認する。
2. `mktemp -d`で今回専用の一時directoryを作り、以後は解決済み絶対pathを使う。
3. `vt api schema --json`のstdoutを一時fileへ保存する。
4. `meta.api_version == 4`、`result.contract.versions.daemon_protocol >= 21`、request schemaに`category_list`、`category_get`、`category_assign`、`category_automatic`があることを確認する。

schema gateに失敗した場合は停止する。raw tmux option、Category state file、config直接編集へfallbackしない。

## 対象を解決する

- ユーザーがpathを指定した場合は、そのpathを使う。
- 「このrepo」「このRepository」の場合は、`git rev-parse --show-toplevel`の成功結果を使う。
- cwdがGit Repositoryでない場合は暗黙に対象とせず、project pathを確認する。
- 対象Repositoryまたは移動先Categoryが一意でない場合だけ、mutation前にユーザーへ確認する。

## Read-only

一覧だけなら`vt category list --json`だけを実行する。
所属確認なら`vt category get --repo <path> --json`だけを実行する。
read-only依頼で`vt daemon ensure`やmutationを実行しない。

success envelopeの`meta.api_version`と`result.type`を検証してから値を使う。

## 既存Categoryへ移動する

1. 必要なら`vt daemon ensure`を実行する。
2. `vt category list --json`で移動先Categoryが存在することを確認する。
3. `vt category get --repo <path> --json`で現在配置とcanonical `repo.key`を記録する。
4. 移動先が存在しなければ停止する。Categoryを作成しない。
5. `vt category assign <category> --repo <path> --json`を一度だけ実行する。
6. receiptの`repo.key`、`requested`、`after`、`changed`、`category_state_revision`を検証する。
7. `vt category get --repo <path> --json`を一度実行し、最終的な`category`と`explicit`がreceiptの`after`と一致することを確認する。

`changed: false`は、すでに要求状態だったことを示す成功として扱う。

## Automatic Classificationへ戻す

移動と同じschema gate、daemon ensure、list/get preflightを行い、mutationだけを次に置き換える。

```bash
vt category automatic --repo <path> --json
```

receiptの`requested.type == "automatic"`と`after.explicit == false`を確認し、最後に`category get`で一致を検証する。

## Typed error

失敗時はstdoutではなくstderrの1個のerror envelopeを読む。

- `invalid_target`、`identity_verification_failed`: 対象pathを修正または確認する。
- `stale_precondition`: configを勝手に編集せず、messageのreload要件を報告する。
- `daemon_invalid_request`: Categoryを作成せず、Catalogと依頼内容を再確認する。
- `delivery_unknown`: mutationを再送しない。`category get --repo <path> --json`を一度だけ実行して現在状態を報告し、「元のmutation receiptは未回収」と明記する。

`retry_action: inspect_manually`または`side_effect: possible`のerrorからmutationを自動再送しない。

## Scope boundary

Categoryの作成、改名、削除、CategoryまたはRepositoryの表示順変更は実行しない。
category navigation、session切替、tmux pane間のAgent操作も扱わない。
これらを依頼された場合は、このskillの範囲外であることを伝え、既存human CLIを勝手に実行しない。
