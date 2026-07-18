# 改善バックログの再照合

`reconcile` は、過去の計画を現在のcodeへ照合し、実行可能な改善バックログへ戻す作業である。
ソースコードは変更しない。

## 事前確認

1. リポジトリルートと改善バックログの配置を解決する。
2. `git status --short --untracked-files=all` を確認する。
3. 意図しない差分があればユーザーに確認する。
4. indexと全計画fileを読む。
5. 現在のshort commit SHAを記録する。

## 状態別の処理

### DONE

- 安価で副作用のないDoDだけを再実行する。
- 現在も成立する場合は、indexに確認日とcommit SHAを記録する。
- 成立しない場合はDONEを維持せず、原因に応じてTODOまたはBLOCKEDへ戻す。
- 計画fileは履歴として削除しない。

### BLOCKED

- block理由と現在のcodeを確認する。
- 同じ設計の範囲で解消できる場合は計画を更新する。
- 方針変更が必要な場合は、既存計画をREJECTEDにし、新しい番号で計画する。
- schema、auth、billing、production data、後方互換性に関わる判断はユーザーへ確認する。

### IN PROGRESS

- 対応中のworktreeやbranchを確認できる場合だけ状態を追跡する。
- 実装担当が不明、または長期間更新がない場合は、勝手にTODOへ戻さずユーザーへ報告する。

### TODO

- planned-at SHAから対象fileが変わっているか確認する。
- findingが残っているか親エージェント自身が読み直す。
- findingが残る場合は、引用、line、command、planned-at SHAを更新する。
- 独立して修正済みならREJECTEDとし、理由を記録する。

### REJECTED

- 原則として再監査しない。
- 却下理由を無効にする新しい根拠がある場合だけ、新しいfindingとして扱う。

## 完了報告

次を日本語で報告する。

- 現在もDONEと確認できた計画
- 更新したTODO
- 解消または再設計したBLOCKED
- 独立して修正済みとしてREJECTEDにした計画
- 現在すぐ実行できる計画と推奨順
- 実行できなかった検証と理由
