---
name: build-technical-explainer
description: 調査・監査・技術選定比較・性能検証・実装結果について、ユーザーが「結果をHTMLで読みやすく整理して」「図を用いてHTMLで説明して」「HTMLの説明資料・レポートとして残して」のように、後から読み返せる静的HTML成果物を求めたときに使う。意味付き本文・表、複合パイプライン図、定量グラフ、検証済み画像、折りたたみ、定型指摘フィルタに対応する。内容の調査・整理を伴わないHTML断片への変換、UI案や配色の比較モック、スライド、単体の探索的グラフ、任意JavaScriptを要する対話ツールには使わない。
---

# Build Technical Explainer

調査結果と視覚表現の判断をschema version 2の構造化YAMLへ保存し、固定rendererで自己完結HTMLへ変換する。
YAMLを唯一の編集元とし、生成HTMLは直接編集しない。
v1 YAMLの互換処理、migrator、fallbackは提供しない。

## Workflow

### 1. 適用範囲と保存先を決める

- 事実、関係、数値、根拠、判断、DoDを理解・記録する依頼に使う。
- レイアウト、配色、情報密度などの見た目を複数案から選ぶ依頼は`ui-mock-proposals`に任せる。
- 両方が必要なら成果物を分ける。ExplainerからUI mockへ制約を渡し、選択後に案IDと理由をExplainerへ戻す。
- スライドはpresentation系、調整可能なグラフやシミュレーターはvisualization系、一般Webサイトはサイト実装系へ任せる。
- 共通の出力・安全性・連携規則は[HTML Artifact Contract](../_shared/html-artifacts/contract.md)に従う。
- 保存先の明示がなければ、対象リポジトリの`tmp/ai/explainers/<slug>/`を使う。
- 継続管理や公開を明示された場合だけ、リポジトリ規約に従って`docs/`などへ置く。
- `document.visibility`は既定で`private`とし、匿名化を確認した資料だけ`shareable`にする。

### 2. YAMLを初期化する

skillディレクトリを`<skill-dir>`として、次を実行する。

```bash
ruby <skill-dir>/scripts/render_explainer.rb init <output-dir>/explainer.yaml
```

既存ファイルがある場合、`init`は上書きしない。
フィールドやblock形式が不足する場合だけ[references/format.md](references/format.md)を読む。

### 3. 視覚表現を先に設計する

- YAML本文を書く前に、各節で読者へ理解させること、採用する表現、理由を`visual_plan`へ記録する。
- 比較は`table`、確定数値の傾向は`chart`、順序・依存・状態は`diagram`、スクリーンショット・写真・既存図は`image`を選ぶ。
- 図を求められた場合、図が理解コストを下げる節があるのに`form: none`だけで終えない。
- 図を装飾ノルマにしない。本文や表の方が正確なら`none`または`table`を選ぶ。
- 添付画像を丸ごと1枚へ焼き直さず、本文・表・calloutはHTMLとして保持し、空間関係だけを図へする。

### 4. 調査結果を構造化する

- `document.summary`には結論を先に書く。
- 観測事実、推論、採用判断、未確定事項を混同しない。
- 根拠を持つblockには`refs`を付け、`sources`のIDと一致させる。
- 出典がない内容へ参照IDを捏造しない。
- 大きなhero、宣伝文句、重複した結論、装飾目的の節を作らない。
- 計画書・設計書を含む場合は、機能・テスト・運用反映の3分類を`checklist` blockで明記する。
- 関連するUI mockや実装計画がある場合は`related_artifacts`に登録し、本文を複製しない。

補助表現は、読み手の理解や探索コストを実際に下げる場合だけ使う。

- `runs`: `plain`、`strong`、`code`だけのtyped inline表現を使う。任意MarkdownやHTMLは使わない。
- typed table cell: `text`、`tone`、`emphasis`で改善値や警告値を意味付き表示する。
- `details`: 補足根拠や長いログを初期表示から退避する。主要な結論は隠さない。
- `chart`: YAMLにある確定済み数値を固定styleのline/barで比較する。この補助chartのために別のdataviz skillは併用しない。グラフ自体が主成果物、探索的、調整可能ならvisualization系へ任せる。
- `diagram`: 単純なflow/dependency/sequence、または1階層groupと複数rowを持つcompositeを説明する。compositeは隣接cellを自動接続し、任意edgeや座標を持たせない。
- `image`: 証拠として必要なPNG/JPEG/WebPだけを使う。`image-info`でmetadataを取得し、YAML配下の相対path、hash、寸法、provenance、権利、共有確認を記録する。
- `findings`: 監査指摘のような定型項目を、定義済みfacetで絞り込む。全文検索や任意条件式には使わない。

任意HTMLや任意JavaScriptはYAMLに入れない。
JavaScriptは`findings`がある場合だけrenderer所有の固定scriptをCSP hash付きで埋め込み、通信・状態保存・product logicを持たせない。

画像を使う場合、次でasset mappingに必要な値を取得する。

```bash
ruby <skill-dir>/scripts/render_explainer.rb image-info <image>
```

画像生成サービスへ非公開内容を送る場合は、送信前にユーザーの権限と機密性を確認する。
技術図の正確な数値・識別子・関係を生成画像の正本にしない。

### 5. 検証して生成する

```bash
ruby <skill-dir>/scripts/render_explainer.rb validate <output-dir>/explainer.yaml
ruby <skill-dir>/scripts/render_explainer.rb render <output-dir>/explainer.yaml <output-dir>/index.html
```

`render`はschema、参照ID、公開時のローカル情報、危険なURLを再検証する。
画像があればpath containment、magic、MIME、hash、寸法、容量、animation、metadata、共有確認も検証する。
生成後は共通validatorでCSP、許可外script、外部通信、状態保存、data image、内部anchor、ID重複を静的検査する。
renderは`index.manifest.json`も生成し、YAML hash、HTML hash、renderer version、asset hashを記録する。
失敗した場合はYAMLを修正し、検証を迂回しない。

### 6. 成果を報告する

- YAML、HTML、manifestの絶対パスを示す。
- validation結果、section数、source数を短く示す。
- 通常生成ではAgentがブラウザを開かず、ブラウザ目視を完了条件に含めない。
- 公開を依頼されていない資料を外部へ送信しない。

## Updating an Existing Explainer

既存v2 `explainer.yaml`だけを更新し、同じ`index.html`へ再renderする。
v1 YAMLは更新せず、v2として書き直す。
HTML側の手修正を見つけた場合はYAMLか固定templateへ戻して表現し、生成HTMLとの二重管理を増やさない。

UI mockで案が選ばれた場合は、判断節へ安定案ID、選択理由、実装制約を追記する。
`related_artifacts.href`は選択案の`#proposal-<id>`へ更新する。

## Skill Maintenance

renderer、starter、template、CSS、固定scriptを変更した場合は次を実行する。
`<shared-dir>`は`<skill-dir>/../_shared/html-artifacts`を指す。

```bash
ruby <skill-dir>/scripts/test_render_explainer.rb
ruby <shared-dir>/scripts/test_validate_html.rb
uv run --with pyyaml python <skill-creator-dir>/scripts/quick_validate.py <skill-dir>
```

`composite` rendererまたはlayout CSSを変えた場合は、代表fixtureをbrowser-controlで開き、viewportを320px、768px、1440pxへ順に設定する。
各幅でreload後、次のread-only評価を実行し、すべて`false`かつ`clipped`が空であることを記録する。
スクリーンショット目視は必須にせず、このgeometry検査を保守時の回帰条件とする。

```javascript
() => {
  const root = document.documentElement;
  const targets = [...document.querySelectorAll(".composite-diagram, table, pre")];
  return {
    documentOverflow: root.scrollWidth > root.clientWidth,
    compositeOverflow: [...document.querySelectorAll(".composite-diagram")]
      .some((element) => element.scrollWidth > element.clientWidth),
    clipped: targets.filter((element) => {
      const rect = element.getBoundingClientRect();
      return rect.left < -1 || rect.right > root.clientWidth + 1;
    }).map((element) => element.tagName + "." + element.className)
  };
}
```

### 保守DoD

機能完了条件:

- [ ] v2 YAMLで`visual_plan`、typed content、対象visual blockがvalidate・renderできる。
- [ ] 不正なlayout、画像path、画像宣言値、共有確認不足がhard failする。

テスト完了条件:

- [ ] renderer test、shared validator test、`quick_validate.py`がすべて成功する。
- [ ] 同じ入力を2回renderし、HTMLとmanifestのSHA-256がそれぞれ一致する。
- [ ] `composite`変更時は320px、768px、1440pxのgeometry検査がすべて合格する。

運用反映条件:

- [ ] `SKILL.md`、`references/format.md`、starter、shared contractが同じschemaを説明する。
- [ ] 代表fixtureのYAML、HTML、manifestを生成し、成果物pathと検証結果を報告する。

新しいdiagram engineや自由度は追加せず、v2の実利用3件後に不足を確認する。

## Resources

- `scripts/render_explainer.rb`: init、validate、renderを行う実行仕様。
- `scripts/test_render_explainer.rb`: 固定シナリオと異常系の回帰テスト。
- `references/format.md`: YAMLフィールドとblock形式。
- `assets/starter.yaml`: 初期YAML。
- `assets/report.html.erb` / `assets/report.css`: 固定HTML template。
- `assets/report.js`: `findings`専用の固定絞り込みscript。
- render時の`*.manifest.json`: 入力・出力・画像assetの決定的な監査記録。
- `../_shared/html-artifacts/`: UI mockと共有する成果物契約と基礎validator。
