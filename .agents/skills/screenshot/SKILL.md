---
name: "screenshot"
description: "ユーザーがデスクトップやシステム全体のスクリーンショットを明示的に求めたとき、またはツール固有のキャプチャ機能が使えず OS レベルの画面取得が必要なときに使います。全画面、特定アプリやウィンドウ、ピクセル領域の取得に対応します。"
---


# スクリーンショット取得

保存先は毎回、次のルールに従ってください。

1. ユーザーがパスを指定した場合は、そこへ保存する。
2. パス指定なしでスクリーンショットを求められた場合は、OS の既定保存先へ保存する。
3. Codex 自身の確認用に必要な場合は、一時ディレクトリへ保存する。

## ツールの優先順位

- 利用可能なら、まずツール固有のスクリーンショット機能を優先します（例: Figma ファイルには Figma の MCP/skill、ブラウザや Electron アプリには Playwright や `agent-browser` のツール）。
- このスキルは、明示的に依頼された場合、システム全体のデスクトップを撮る場合、または専用ツールでは必要な画面を取れない場合に使います。
- それ以外では、より適切に統合された取得手段がないデスクトップアプリに対するデフォルト手段として扱います。

## macOS の権限事前確認（不要なプロンプトを減らす）

macOS では、ウィンドウやアプリ単位の取得前に事前確認ヘルパーを一度実行します。これは画面収録権限を確認し、必要な理由を説明し、同じ場所で権限要求まで行います。

ヘルパーは Swift のモジュールキャッシュを `$TMPDIR/codex-swift-module-cache` に向け、サンドボックス下で余計な module-cache の権限プロンプトが出るのを避けます。

```bash
bash <path-to-skill>/scripts/ensure_macos_permissions.sh
```

サンドボックス承認プロンプトを何度も出さないため、可能なら事前確認とキャプチャを 1 コマンドにまとめてください。

```bash
bash <path-to-skill>/scripts/ensure_macos_permissions.sh && \
python3 <path-to-skill>/scripts/take_screenshot.py --app "Codex"
```

Codex の確認用なら、出力は一時領域に置きます。

```bash
bash <path-to-skill>/scripts/ensure_macos_permissions.sh && \
python3 <path-to-skill>/scripts/take_screenshot.py --app "<App>" --mode temp
```

OS ごとのコマンドを都度組み立て直さず、同梱スクリプトを使ってください。

## macOS と Linux（Python ヘルパー）

リポジトリのルートからヘルパーを実行します。

```bash
python3 <path-to-skill>/scripts/take_screenshot.py
```

よく使うパターン:

- 既定保存先（ユーザーが単に「スクリーンショットを撮って」と言った場合）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py
```

- 一時保存（Codex の視覚確認用）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --mode temp
```

- 明示パス指定（ユーザーがパスやファイル名を指定した場合）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --path output/screen.png
```

- アプリ名によるアプリ / ウィンドウ取得（macOS のみ。部分一致可。該当ウィンドウをすべて取得）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --app "Codex"
```

- アプリ内の特定ウィンドウタイトルを指定（macOS のみ）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --app "Codex" --window-name "Settings"
```

- 取得前に一致するウィンドウ ID を列挙（macOS のみ）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --list-windows --app "Codex"
```

- ピクセル領域（x,y,w,h）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --mode temp --region 100,200,800,600
```

- フォーカス中 / アクティブウィンドウのみ取得（前面ウィンドウだけを取得。全ウィンドウが必要なら `--app` を使う）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --mode temp --active-window
```

- 特定のウィンドウ ID を指定（macOS では `--list-windows` で事前に確認可能）

```bash
python3 <path-to-skill>/scripts/take_screenshot.py --window-id 12345
```

スクリプトは、取得 1 件ごとに 1 行ずつ出力パスを表示します。複数のウィンドウやディスプレイが一致した場合は、行ごとに複数パスが出力され、`-w<windowId>` や `-d<display>` のような接尾辞が付加されます。各パスは画像ビューワーツールで順番に確認し、画像の加工は必要な場合か、明示的に求められた場合だけ行ってください。

### ワークフロー例

- 「`<App>` を見て、何が表示されているか教えて」: 一時領域へ保存し、出力された各パスを順に確認する。

```bash
bash <path-to-skill>/scripts/ensure_macos_permissions.sh && \
python3 <path-to-skill>/scripts/take_screenshot.py --app "<App>" --mode temp
```

- 「Figma のデザインと実装が一致していない」: まず Figma の MCP/skill でデザイン側を取得し、その後このスキルで動作中アプリを取得します（通常は一時領域へ）。画像加工前の生スクリーンショット同士を比較してください。

### マルチディスプレイ時の挙動

- macOS の全画面取得は、複数モニタ接続時にディスプレイごとに 1 ファイル保存します。
- Linux と Windows の全画面取得は仮想デスクトップ全体を 1 枚に収めます。単一ディスプレイだけ必要なら `--region` を使います。

### Linux の前提条件と選択ロジック

ヘルパーは、次の利用可能なツールを先頭から自動選択します。

1. `scrot`
2. `gnome-screenshot`
3. ImageMagick の `import`

どれも使えない場合は、そのうち 1 つをインストールしてから再試行するようユーザーに依頼します。

座標指定の領域取得には `scrot` か ImageMagick の `import` が必要です。

`--app`、`--window-name`、`--list-windows` は macOS 専用です。Linux では `--active-window` を使うか、利用可能なら `--window-id` を指定してください。

## Windows（PowerShell ヘルパー）

PowerShell ヘルパーを実行します。

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1
```

よく使うパターン:

- 既定保存先

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1
```

- 一時保存（Codex の視覚確認用）

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1 -Mode temp
```

- 明示パス指定

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1 -Path "C:\Temp\screen.png"
```

- ピクセル領域（x,y,w,h）

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1 -Mode temp -Region 100,200,800,600
```

- アクティブウィンドウ（事前にフォーカスさせてもらう）

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1 -Mode temp -ActiveWindow
```

- 特定のウィンドウハンドル（提供されている場合のみ）

```powershell
powershell -ExecutionPolicy Bypass -File <path-to-skill>/scripts/take_screenshot.ps1 -WindowHandle 123456
```

## 直接 OS コマンドを使う場合（フォールバック）

ヘルパーが実行できない場合のみ、こちらを使います。

### macOS

- 任意パスに全画面保存

```bash
screencapture -x output/screen.png
```

- ピクセル領域

```bash
screencapture -x -R100,200,800,600 output/region.png
```

- 特定のウィンドウ ID

```bash
screencapture -x -l12345 output/window.png
```

- 対話選択またはウィンドウ選択

```bash
screencapture -x -i output/interactive.png
```

### Linux

- 全画面

```bash
scrot output/screen.png
```

```bash
gnome-screenshot -f output/screen.png
```

```bash
import -window root output/screen.png
```

- ピクセル領域

```bash
scrot -a 100,200,800,600 output/region.png
```

```bash
import -window root -crop 800x600+100+200 output/region.png
```

- アクティブウィンドウ

```bash
scrot -u output/window.png
```

```bash
gnome-screenshot -w -f output/window.png
```

## エラーハンドリング

- macOS では、最初に `bash <path-to-skill>/scripts/ensure_macos_permissions.sh` を実行し、画面収録権限をまとめて要求します。
- サンドボックス下で `"screen capture checks are blocked in the sandbox"`、`"could not create image from display"`、または Swift の `ModuleCache` 権限エラーが出た場合は、権限を引き上げて再実行します。
- macOS のアプリ / ウィンドウ取得で一致が 0 件なら、`--list-windows --app "AppName"` を実行してから `--window-id` で再試行し、対象アプリが画面上に見えていることを確認します。
- Linux の領域取得やウィンドウ取得が失敗した場合は、`command -v scrot`、`command -v gnome-screenshot`、`command -v import` でツール有無を確認します。
- OS 既定保存先への保存がサンドボックス内で権限エラーになる場合は、権限を引き上げて再実行します。
- 応答では、保存したファイルパスを必ず伝えます。
