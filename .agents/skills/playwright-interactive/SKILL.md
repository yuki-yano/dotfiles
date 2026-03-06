---
name: "playwright-interactive"
description: "`js_repl` を使ってブラウザや Electron を永続セッションで操作し、高速に UI デバッグを反復するためのスキルです。"
---

# Playwright Interactive スキル

このスキルは、永続的な `js_repl` セッション内でブラウザや Electron を対話的に扱う必要があるときに使います。コード編集、リロード、繰り返し確認の間も Playwright のハンドルを生かし続け、高速に反復できる状態を保ってください。

## 前提条件

- このスキルでは `js_repl` が有効である必要があります。
- `js_repl` が無効なら、`~/.codex/config.toml` で有効化します。

```toml
[features]
js_repl = true
```

- `--enable js_repl`（`-c features.js_repl=true` と同等）で新しいセッションを開始しても構いません。
- `js_repl` を有効化したあとは、ツール一覧を更新するために Codex の新しいセッションを開始してください。
- 現時点では、このワークフローはサンドボックス無効で実行してください。`--sandbox danger-full-access`、または `sandbox_mode=danger-full-access` 相当の設定で Codex を起動します。これは、サンドボックス内での `js_repl` + Playwright サポートがまだ完全ではないための暫定要件です。
- セットアップは、実際にデバッグしたいプロジェクトディレクトリで実行します。
- `js_repl_reset` は日常的な掃除ではなく、復旧手段として扱います。カーネルをリセットすると Playwright のハンドルは破棄されます。

## 初回セットアップ

```bash
test -f package.json || npm init -y
npm install playwright
# Web 専用。Chromium を表示付きで使う場合やモバイルエミュレーションを行う場合:
# npx playwright install chromium
# Electron 専用。対象ワークスペース自体が Electron アプリの場合のみ:
# npm install --save-dev electron
node -e "import('playwright').then(() => console.log('playwright import ok')).catch((error) => { console.error(error); process.exit(1); })"
```

あとで別のワークスペースに切り替える場合は、その場所で同じセットアップを繰り返します。

## 基本ワークフロー

1. テスト前に、簡潔な QA インベントリを作成する。
   - インベントリは 3 つの情報源から組み立てます。ユーザーが求めた要件、実際に実装したユーザー可視の機能や振る舞い、最終応答で主張する予定の内容です。
   - この 3 つのいずれかに現れる項目は、サインオフ前に少なくとも 1 つの QA チェックへ対応付けられていなければなりません。
   - サインオフ予定のユーザー可視な主張を列挙します。
   - 意味のあるユーザー向けコントロール、モード切り替え、実装済みの対話動作をすべて列挙します。
   - 各コントロールや動作が引き起こす状態変化や表示変化を列挙します。
   - これを機能 QA と視覚 QA の共通カバレッジ一覧として使います。
   - 各主張や「コントロールと状態」の組について、実施する機能チェック、視覚チェックを行うべき具体的状態、取得予定の証跡を記録します。
   - 視覚的に重要だが主観的な要件は、暗黙のままにせず観測可能な QA チェックへ落とし込みます。
   - 壊れやすい挙動を露呈しそうな探索シナリオや非ハッピーパスを最低 2 件追加します。
2. bootstrap セルを一度だけ実行する。
3. 必要な開発サーバーを永続 TTY セッションで起動、または起動済みであることを確認する。
4. 適切なランタイムを起動し、同じ Playwright ハンドルを再利用し続ける。
5. 各コード変更後、レンダラーのみの変更ならリロードし、メインプロセスや起動処理の変更なら再起動する。
6. 通常のユーザー入力で機能 QA を行う。
7. 別立てで視覚 QA を行う。
8. ビューポートの収まりを確認し、主張を裏付けるスクリーンショットを取得する。
9. タスクが本当に完了した時点でのみ、Playwright セッションをクリーンアップする。

## Bootstrap（一度だけ実行）

```javascript
var chromium;
var electronLauncher;
var browser;
var context;
var page;
var mobileContext;
var mobilePage;
var electronApp;
var appWindow;

try {
  ({ chromium, _electron: electronLauncher } = await import("playwright"));
  console.log("Playwright loaded");
} catch (error) {
  throw new Error(
    `Could not load playwright from the current js_repl cwd. Run the setup commands from this workspace first. Original error: ${error}`
  );
}
```

## Web セッションを開始または再利用する

`TARGET_URL` には、デバッグ対象アプリの URL を設定します。ローカルサーバーでは `localhost` より `127.0.0.1` を優先してください。

```javascript
const TARGET_URL = "http://127.0.0.1:3000";

if (!browser) {
  browser = await chromium.launch({ headless: false });
}

if (!context) {
  context = await browser.newContext({
    viewport: { width: 1600, height: 900 },
  });
}

if (!page) {
  page = await context.newPage();
}

await page.goto(TARGET_URL, { waitUntil: "domcontentloaded" });
console.log("Loaded:", await page.title());
```

## Electron セッションを開始または再利用する

現在のワークスペースが Electron アプリで、`package.json` の `main` が正しいエントリファイルを指しているなら、`ELECTRON_ENTRY` は `.` に設定します。特定のメインプロセスファイルを直接指定したい場合は、代わりに `./main.js` のようなパスを使います。

```javascript
const ELECTRON_ENTRY = ".";

if (electronApp) {
  await electronApp.close().catch(() => {});
}

electronApp = await electronLauncher.launch({
  args: [ELECTRON_ENTRY],
  cwd: process.cwd(),
});

appWindow = await electronApp.firstWindow();

console.log("Loaded Electron window:", await appWindow.title());
```

## 反復中にセッションを再利用する

可能な限り、同じセッションを生かし続けてください。

Web レンダラーのリロード:

```javascript
for (const p of context.pages()) {
  await p.reload({ waitUntil: "domcontentloaded" });
}
console.log("Reloaded existing tabs");
```

Electron のレンダラーのみをリロード:

```javascript
await appWindow.reload({ waitUntil: "domcontentloaded" });
console.log("Reloaded Electron window");
```

メインプロセス、preload、起動処理の変更後に Electron を再起動:

```javascript
await electronApp.close().catch(() => {});

electronApp = await electronLauncher.launch({
  args: ["."],
  cwd: process.cwd(),
});

appWindow = await electronApp.firstWindow();
console.log("Relaunched Electron window:", await appWindow.title());
```

基本姿勢:

- 各 `js_repl` セルは短く保ち、1 回の対話バーストに集中させる。
- `browser`、`context`、`page`、`electronApp`、`appWindow` のような既存トップレベル変数を再宣言せず再利用する。
- 分離が必要なら、同じブラウザ内で新しい page または context を作る。
- Electron では、`electronApp.evaluate(...)` はメインプロセスの調査や目的を持った診断にのみ使う。
- 補助コードの誤りはその場で修正し、カーネル自体が壊れていない限り REPL をリセットしない。

## チェックリスト

### セッションループ

- `js_repl` の bootstrap は一度だけ実行し、以後は同じ Playwright ハンドルを反復間で維持する。
- 対象ランタイムを現在のワークスペースから起動する。
- コード変更を行う。
- 変更内容に応じて、正しい方法でリロードまたは再起動する。
- 追加のコントロール、状態、可視主張が探索で見つかったら、共通 QA インベントリを更新する。
- 機能 QA を再実行する。
- 視覚 QA を再実行する。
- 最終成果物は、いま評価している状態になってから取得する。
- タスク終了前、またはセッションを離れる前にクリーンアップを実行する。

### リロード判断

- レンダラーのみの変更: 既存の page または Electron ウィンドウをリロードする。
- メインプロセス、preload、起動処理の変更: Electron を再起動する。
- どのプロセスが責務を持つのか、または起動コードに新しい不確実性がある: 推測せず再起動する。

### 機能 QA

- サインオフでは、本物のユーザー操作を使う。キーボード、マウス、クリック、タッチ、または同等の Playwright 入力 API を用いる。
- 少なくとも 1 つの重要フローを end-to-end で検証する。
- 内部状態だけでなく、そのフローの可視結果を確認する。
- リアルタイム性やアニメーションが重いアプリでは、実際の操作タイミングで挙動を確認する。
- その場しのぎのスポットチェックではなく、共通 QA インベントリに沿って進める。
- メインのハッピーパスだけでなく、明らかな可視コントロールをサインオフ前に少なくとも一度はすべて触る。
- インベントリにある可逆コントロールや状態保持トグルは、初期状態、変化後状態、初期状態への復帰まで一巡検証する。
- スクリプト化したチェックが通ったあと、意図した経路だけをなぞるのではなく、通常入力で 30〜90 秒ほどの短い探索確認を行う。
- 探索確認で新しい状態、コントロール、主張が見つかったら、それを共通 QA インベントリに追加し、サインオフ前にカバーする。
- `page.evaluate(...)` や `electronApp.evaluate(...)` は状態確認や準備に使ってよいが、サインオフ用の入力とはみなさない。

### 視覚 QA

- 視覚 QA は機能 QA とは別物として扱う。
- テスト前に定義し、QA 中に更新した同じ共通 QA インベントリを使う。別の暗黙リストから視覚カバレッジを始めない。
- ユーザー可視の主張を言い直し、それぞれを明示的に検証する。機能 QA が通ったからといって視覚上の主張まで証明されたとみなさない。
- ユーザー可視の主張は、その主張が知覚されるべき具体的状態で確認するまでサインオフしない。
- スクロール前の初期ビューポートを確認する。
- 初期表示がインターフェースの主要な主張を視覚的に支えていることを確認する。中心となる要素がそこで明確に知覚できないなら不具合として扱う。
- 主な操作面だけでなく、必要な可視領域をすべて確認する。
- 共通 QA インベントリに列挙済みの状態やモードを確認する。対話型タスクなら、意味のある操作後状態を少なくとも 1 つ含める。
- 動きや遷移が体験の一部なら、安定状態だけでなく遷移中の状態も少なくとも 1 つ確認する。
- ラベル、オーバーレイ、注釈、ガイド、ハイライトが変化する内容に追従する設計なら、関連する状態変化のあとでその関係を確認する。
- 動的な見た目や操作依存の見た目は、安定性、レイヤリング、可読性を判断できるだけ十分に観察する。サインオフを 1 枚のスクリーンショットに頼らない。
- ロード後や操作後に密度が増す UI では、空状態、ローディング状態、折りたたみ状態だけでなく、QA 中に到達できるもっとも密な現実的状態を確認する。
- 最小サポートのビューポートやウィンドウサイズが定義されているなら、そこで別途視覚 QA を行う。定義がない場合でも、より小さいが現実的なサイズを選び、明示的に確認する。
- そこに存在することと、適切に実装されていることは別です。弱いコントラスト、被り、クリッピング、不安定さなどで明確に知覚できないなら、機能として存在していても視覚的失敗とみなします。
- 評価中の状態で必要な可視領域がクリップ、切断、隠蔽、またはビューポート外へ押し出されているなら、ページ全体のスクロール指標が問題なく見えても不具合として扱う。
- クリッピング、オーバーフロー、歪み、レイアウトの不均衡、余白や整列の不整合、判読不能な文字、弱いコントラスト、レイヤー破綻、不自然な動きの状態を探す。
- 正しさだけでなく審美性も評価する。UI はタスクに対して意図が感じられ、整合的で、視覚的に心地よいものであるべきです。
- サインオフ用にはビューポートスクリーンショットを優先し、フルページ画像は補助的なデバッグ成果物とする。
- フルウィンドウスクリーンショットだけでは特定領域を確信を持って判断できない場合、その領域に絞ったスクリーンショットを取得する。
- 動きのせいでスクリーンショットが曖昧になるなら、少し待って UI が落ち着いてから、実際に評価している状態を撮る。
- サインオフ前に明示的に自問する: このインターフェースで、まだ十分に近くで見ていない可視部分は何か。
- サインオフ前に明示的に自問する: ユーザーが注意深く見たときに、もっとも恥ずかしい欠陥になりそうな可視不具合は何か。

### サインオフ

- 通常のユーザー入力で機能経路が通っている。
- 共通 QA インベントリに対するカバレッジが明示されている。どの要件、実装済み機能、コントロール、状態、主張を検証したか、そして意図的に除外したものがあれば明記する。
- 視覚 QA が関連インターフェース全体をカバーしている。
- すべてのユーザー可視主張に、その主張が重要になる状態での視覚チェックと成果物が対応している。
- 初期表示、および必要なら最小サポートビューポートやウィンドウサイズについて、ビューポート適合チェックが通っている。
- 製品がウィンドウで起動する場合、手動でサイズ変更や再配置を行う前に、起動時のサイズ、配置、初期レイアウトを確認している。
- 取得したスクリーンショットが、最終応答で行う主張を直接裏付けている。
- 必要なスクリーンショットを、QA で定めた関連状態とビューポートまたはウィンドウサイズごとに確認している。
- UI は機能するだけでなく、視覚的に一貫しており、タスクに対して審美的に弱くない。
- 機能の正しさ、ビューポート適合、視覚品質はそれぞれ独立して合格しなければならず、どれか 1 つが他を保証しない。
- 対話型製品では短い探索確認を完了しており、応答にはその探索で何を見たかが含まれている。
- スクリーンショット確認と数値チェックがどこかで食い違った場合は、サインオフ前にその差異を調査している。スクリーンショット上の可視クリッピングは解消すべき失敗であり、数値指標で上書きしてよいものではない。
- 確認した主要な不具合クラスのうち、見つからなかったものについては短い否定確認を含める。
- クリーンアップを実行した、または意図的にセッションを維持したことを明記する。

## スクリーンショット例

`view_image` 用の成果物は、非可逆圧縮で問題ない限り `quality: 85` の JPEG を優先してください。完全なロスレス確認が必要な場合だけ別形式を使います。

デスクトップ例:

```javascript
const { unlink } = await import("node:fs/promises");
const desktopPath = `${codex.tmpDir}/desktop.jpg`;

await page.screenshot({ path: desktopPath, type: "jpeg", quality: 85 });
await codex.tool("view_image", { path: desktopPath });
await unlink(desktopPath).catch(() => {});
```

Electron 例:

```javascript
const { unlink } = await import("node:fs/promises");
const electronPath = `${codex.tmpDir}/electron-window.jpg`;

await appWindow.screenshot({ path: electronPath, type: "jpeg", quality: 85 });
await codex.tool("view_image", { path: electronPath });
await unlink(electronPath).catch(() => {});
```

モバイル例:

```javascript
const { unlink } = await import("node:fs/promises");

if (!mobileContext) {
  mobileContext = await browser.newContext({
    viewport: { width: 390, height: 844 },
    isMobile: true,
    hasTouch: true,
  });
  mobilePage = await mobileContext.newPage();
}

await mobilePage.goto(TARGET_URL, { waitUntil: "domcontentloaded" });
const mobilePath = `${codex.tmpDir}/mobile.jpg`;
await mobilePage.screenshot({ path: mobilePath, type: "jpeg", quality: 85 });
await codex.tool("view_image", { path: mobilePath });
await unlink(mobilePath).catch(() => {});
```

## ビューポート適合チェック（必須）

メインウィジェットが見えているだけで、スクリーンショットが妥当だと判断してはいけません。サインオフ前に、意図した初期表示が製品要件に一致していることを、スクリーンショット確認と数値チェックの両方で明示的に検証してください。

- サインオフ前に、意図した初期表示を定義する。スクロール可能なページなら above-the-fold の体験です。アプリ型のシェル、ゲーム、エディタ、ダッシュボード、ツールなら、完全な対話面に加え、利用に必要なコントロールと状態表示までを含みます。
- 適合の主要な証拠としてスクリーンショットを使う。数値チェックは補助であり、可視クリッピングを覆してはならない。
- 意図した初期表示で必要な可視領域がクリップ、切断、隠蔽、またはビューポート外へ押し出されているなら、ページ全体のスクロール指標が問題なく見えてもサインオフ失敗です。
- 製品がスクロール前提で設計されており、初期表示でも核となる体験と主要 CTA または必要な開始文脈が示されているなら、スクロールは許容されます。
- 固定シェル型インターフェースでは、主要な対話面や必須コントロールの一部に到達するためにスクロールが必要なら、それは許容可能な回避策ではありません。
- ドキュメント全体のスクロール指標だけに依存しない。固定高さのシェル、内部ペイン、`overflow: hidden` のコンテナでは、ページレベルのスクロールチェックが綺麗でも必要 UI がクリップされることがあります。
- ドキュメント境界ではなく、必要領域の境界を確認する。起動状態で各可視領域がビューポート内に収まっていることを検証する。
- Electron やデスクトップアプリでは、手動サイズ変更や再配置の前に、起動時ウィンドウのサイズと配置、およびレンダラーの初期可視レイアウトを確認する。
- ビューポート適合チェックが通ったことは、意図した初期表示が不要なクリッピングやスクロールなしに見えていることしか意味しません。UI が視覚的に正しいことや審美的に成功していることまでは証明しません。

Web またはレンダラーの確認:

```javascript
console.log(await page.evaluate(() => ({
  innerWidth: window.innerWidth,
  innerHeight: window.innerHeight,
  clientWidth: document.documentElement.clientWidth,
  clientHeight: document.documentElement.clientHeight,
  scrollWidth: document.documentElement.scrollWidth,
  scrollHeight: document.documentElement.scrollHeight,
  canScrollX: document.documentElement.scrollWidth > document.documentElement.clientWidth,
  canScrollY: document.documentElement.scrollHeight > document.documentElement.clientHeight,
})));
```

Electron の確認:

```javascript
console.log(await appWindow.evaluate(() => ({
  innerWidth: window.innerWidth,
  innerHeight: window.innerHeight,
  clientWidth: document.documentElement.clientWidth,
  clientHeight: document.documentElement.clientHeight,
  scrollWidth: document.documentElement.scrollWidth,
  scrollHeight: document.documentElement.scrollHeight,
  canScrollX: document.documentElement.scrollWidth > document.documentElement.clientWidth,
  canScrollY: document.documentElement.scrollHeight > document.documentElement.clientHeight,
})));
```

特定 UI でクリッピングが起こりやすいなら、必要な可視領域に対する `getBoundingClientRect()` チェックを数値確認へ追加してください。ドキュメントレベルの指標だけでは不十分です。

## 開発サーバー

ローカル Web のデバッグでは、アプリを永続 TTY セッションで動かし続けてください。短命シェルからの一発バックグラウンド起動には依存しないでください。

使用する起動コマンドは、そのプロジェクトで通常使うものに従います。たとえば:

```bash
npm start
```

`page.goto(...)` の前に、選んだポートが listen しており、アプリが応答することを確認します。

Electron のデバッグでは、同じセッションがプロセス所有権を持つように、`js_repl` から `_electron.launch(...)` を使って起動します。Electron のレンダラーが別の開発サーバー（たとえば Vite や Next）に依存する場合、そのサーバーは永続 TTY セッションで動かし続けたうえで、`js_repl` から Electron アプリを再起動またはリロードしてください。

## クリーンアップ

クリーンアップは、タスクが本当に終わったときだけ実行します。

- このクリーンアップは手動です。Codex を終了したり、ターミナルを閉じたり、`js_repl` セッションを失ったりしても、`electronApp.close()`、`context.close()`、`browser.close()` は暗黙には呼ばれません。
- 特に Electron では、先にクリーンアップセルを実行せずにセッションを離れると、アプリが動作し続ける前提で考えてください。

```javascript
if (electronApp) {
  await electronApp.close().catch(() => {});
}

if (mobileContext) {
  await mobileContext.close().catch(() => {});
}

if (context) {
  await context.close().catch(() => {});
}

if (browser) {
  await browser.close().catch(() => {});
}

browser = undefined;
context = undefined;
page = undefined;
mobileContext = undefined;
mobilePage = undefined;
electronApp = undefined;
appWindow = undefined;

console.log("Playwright session closed");
```

デバッグ後すぐに Codex を終了する予定でも、先にクリーンアップセルを実行し、`"Playwright session closed"` が出力されるまで待ってから終了してください。

## よくある失敗パターン

- `Cannot find module 'playwright'`: 現在のワークスペースで初回セットアップを実行し、`js_repl` を使う前に import 成功を確認する。
- Playwright パッケージは入っているがブラウザ実行ファイルが無い: `npx playwright install chromium` を実行する。
- `page.goto: net::ERR_CONNECTION_REFUSED`: 開発サーバーが永続 TTY セッションで動き続けていることを確認し、ポートを再確認し、`http://127.0.0.1:<port>` を優先する。
- `electron.launch` がハングする、タイムアウトする、すぐ終了する: ローカル `electron` 依存関係、`args` の対象、必要ならレンダラー用 dev server が起動済みであることを確認する。
- `Identifier has already been declared`: 既存トップレベル変数を再利用するか、新しい名前を使うか、`{ ... }` で囲む。カーネルが本当に詰まっている場合だけ `js_repl_reset` を使う。
- `js_repl` がタイムアウトまたはリセットされた: bootstrap セルを再実行し、より短く焦点を絞ったセルでセッションを作り直す。
- ブラウザ起動やネットワーク操作が即失敗する: セッションが `--sandbox danger-full-access` で開始されていたか確認し、必要ならその設定で再起動する。
