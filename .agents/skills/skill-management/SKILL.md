---
name: skill-management
description: dotfilesで共有するローカルskillの作成・改訂、外部skillの導入・更新・削除、重複整理を行うときに使う。
---

# Skill Management

## 配置と管理元

- 手作りskillの正本は`~/dotfiles/.agents/skills/<name>/`。直接編集する。
- `~/.agents`は`~/dotfiles/.agents`へのsymlink、`~/.config/claude/skills`も同じ実体を参照する。
- 外部skillは`~/dotfiles/skills-lock.json`の`skills` entryで識別し、`npx skills`で管理する。
- `~/.codex/skills/.system`とplugin cacheはこのリポジトリの管理対象外。

## 作業の選択

ローカルskillの本文やdescriptionを直すだけなら、対象ファイルと必要な参照・呼び出し元を読む。
外部skillの更新確認や全agentの重複監査を毎回実行しない。

外部skillの追加・更新・削除、重複整理では[管理手順](references/package-operations.md)の該当節を読む。

- `npx skills`は`~/dotfiles`から実行し、追加・更新は`-a codex`を明示する。global installで別の場所へ分散させない。
- lock fileは`~/dotfiles/skills-lock.json`だけに置き、実体とsource/hashをそろえる。
- `skills` 1.5.19では`check`も実体を更新し、`update`は不要なClaude用aliasを作る。read-only監査では実行せず、更新時は対象sourceへの`add -a codex`を使う。
- 外部skillをローカル改訂する必要がある場合は、上流追従かローカル派生への移行かを明確にし、lockと実体を不一致のままにしない。

## ローカル指示の書き方

- `description`は用途と発動条件を短く書く。似たskillとの誤発動を防ぐ除外条件だけを残し、手順・機能一覧・大量の言い換えを入れない。
- 本文には目的、成果物、判断に必要な固有情報、実際の制約を置く。一般的な助言や、モデルの能力不足を前提にした一律の手順を重ねない。
- 複数モードの詳細は必要時に読む`references/`へ分け、読込条件を本文に書く。短い単一用途のskillは無理に分割しない。
- コマンド契約、誤配送防止、データ保護などの壊れやすい操作条件は保持する。同じ定義・閾値・テンプレートを複数箇所に持たせない。
- 「必ず確認」「失敗時は停止」は対象操作と理由を特定する。依頼内の修正・検証を止めず、既存の承認や明示指示を尊重する。
- 履歴を使う改訂では、ユーザーの訂正とagentの解釈を分け、一度限りの例を全作業のルールにしない。
- AGENTS.mdには横断的な好みと制約、skillには用途固有の手順、CLI仕様には現在のhelp/schemaを使う。

## 検証と反映

- 本文の改訂ではdescription/body、参照リンク、`agents/openai.yaml`があればその既定プロンプトの整合を確認する。
- 利用可能な`skill-creator`のvalidatorで形式を確認し、スクリプト変更時は影響する既存検証を行う。
- 独立agentによる実証評価を依頼された場合は`empirical-prompt-tuning`を使う。静的点検だけを実証評価と呼ばない。
- 導入・削除・配置変更では、管理手順にある実体・lock・symlinkの確認を行う。
- 完了時に差分と必要な検証結果を示す。共有symlink経由の反映と、次セッションでの読込を区別する。
