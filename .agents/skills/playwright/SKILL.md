---
name: "playwright"
description: "端末から実ブラウザを自動操作する必要がある作業に使います。`playwright-cli` もしくは同梱のラッパースクリプト経由で、画面遷移、フォーム入力、スナップショット取得、スクリーンショット撮影、データ抽出、UI フローのデバッグを行います。"
---


# Playwright CLI スキル

`playwright-cli` を使って、端末から実ブラウザを操作します。CLI がグローバルインストールされていなくても動くよう、同梱のラッパースクリプトを優先してください。
このスキルは CLI ベースの自動操作を前提にします。ユーザーがテストファイルを明示的に求めない限り、`@playwright/test` へ切り替えないでください。

## 前提確認（必須）

コマンドを提案する前に、`npx` が利用可能か確認します（ラッパーが依存しています）。

```bash
command -v npx >/dev/null 2>&1
```

利用できない場合は、そこで止めて Node.js/npm（`npx` を含む）のインストールをユーザーに依頼します。次の手順をそのまま案内してください。

```bash
# Node/npm が入っているか確認
node --version
npm --version

# もし無ければ Node.js/npm を入れ、その後:
npm install -g @playwright/cli@latest
playwright-cli --help
```

`npx` が使えるなら、そのままラッパースクリプトを利用します。`playwright-cli` のグローバルインストールは任意です。

## スキルのパス（一度だけ設定）

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
```

ユーザー単位でインストールしたスキルは `$CODEX_HOME/skills` 配下に置かれます（デフォルトは `~/.codex/skills`）。

## クイックスタート

ラッパースクリプトを使います。

```bash
"$PWCLI" open https://playwright.dev --headed
"$PWCLI" snapshot
"$PWCLI" click e15
"$PWCLI" type "Playwright"
"$PWCLI" press Enter
"$PWCLI" screenshot
```

ユーザーがグローバルインストールを望むなら、こちらでも構いません。

```bash
npm install -g @playwright/cli@latest
playwright-cli --help
```

## 基本ワークフロー

1. ページを開く。
2. スナップショットを取り、安定した要素参照を得る。
3. 最新のスナップショットに含まれる参照を使って操作する。
4. ナビゲーション後や DOM が大きく変化したあとに再度スナップショットを取る。
5. 必要に応じて成果物（スクリーンショット、PDF、トレース）を取得する。

最小ループ:

```bash
"$PWCLI" open https://example.com
"$PWCLI" snapshot
"$PWCLI" click e3
"$PWCLI" snapshot
```

## スナップショットを取り直すべきタイミング

次のあとには再度スナップショットを取ります。

- ナビゲーション
- UI を大きく変えるクリック
- モーダルやメニューの開閉
- タブ切り替え

参照は古くなります。参照切れでコマンドが失敗したら、再スナップショットしてください。

## 推奨パターン

### フォーム入力と送信

```bash
"$PWCLI" open https://example.com/form
"$PWCLI" snapshot
"$PWCLI" fill e1 "user@example.com"
"$PWCLI" fill e2 "password123"
"$PWCLI" click e3
"$PWCLI" snapshot
```

### トレース付きで UI フローをデバッグする

```bash
"$PWCLI" open https://example.com --headed
"$PWCLI" tracing-start
# ...interactions...
"$PWCLI" tracing-stop
```

### 複数タブを扱う

```bash
"$PWCLI" tab-new https://example.com
"$PWCLI" tab-list
"$PWCLI" tab-select 0
"$PWCLI" snapshot
```

## ラッパースクリプト

ラッパースクリプトは `npx --package @playwright/cli playwright-cli` を使うため、グローバルインストールなしでも CLI を実行できます。

```bash
"$PWCLI" --help
```

リポジトリ全体でグローバルインストール運用に統一されていない限り、ラッパーを優先してください。

## 参考資料

必要なものだけ開いてください。

- CLI コマンドリファレンス: `references/cli.md`
- 実践的なワークフローとトラブルシュート: `references/workflows.md`

## ガードレール

- `e12` のような要素 ID を参照する前に、必ずスナップショットを取る。
- 参照が古そうなら再スナップショットする。
- 必要がない限り、`eval` や `run-code` より明示的な CLI コマンドを優先する。
- 新しいスナップショットがない場合は `eX` のような仮の参照を使い、その理由を明示する。`run-code` で参照を回避しない。
- 視覚確認が有効な場面では `--headed` を使う。
- このリポジトリ内で成果物を保存する場合は `output/playwright/` を使い、新しいトップレベルの成果物フォルダを増やさない。
- Playwright のテスト spec ではなく、CLI コマンドとワークフローを基本にする。
