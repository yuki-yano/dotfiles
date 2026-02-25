# コマンドリファレンス

このディレクトリは、仕様駆動開発スイートの各実行モードを単体運用するための詳細手順をまとめる。

## 収録モード

- `steering`
- `steering-custom`
- `spec-init`
- `spec-requirements`
- `spec-design`
- `spec-tasks`
- `spec-impl`
- `spec-status`
- `validate-design`
- `validate-gap`
- `validate-impl`

## 読み方

1. 全体像は `SKILL.md` と `workflow-playbook.md` で把握する。
2. 実行時は同名ファイルの「前提確認」「実行手順」「更新ルール」を順に適用する。
3. 承認運用は `workflow-playbook.md` の「2.1 承認記録（自然言語）」を参照する。

## パス方針

- 仕様・ステアリング成果物は `./docs/sdd/` 配下に統一する。
- `feature_name` は `spec-init` で確定した値を表記ゆれなく使用する。
