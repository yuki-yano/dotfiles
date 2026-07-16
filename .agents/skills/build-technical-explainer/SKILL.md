---
name: build-technical-explainer
description: 調査・監査・技術選定比較・性能検証・実装結果について、ユーザーが「結果をHTMLで読みやすく整理して」「HTMLの説明資料・レポートとして残して」のように、後から読み返せる静的HTML成果物を求めたときに使う。説明を補助する表、限定的な図解・定量グラフ・折りたたみ・定型指摘フィルタにも対応する。内容の調査・整理を伴わないHTML断片への変換、UI案や配色の比較モック、スライド、単体の探索的グラフ、任意JavaScriptを要する対話ツールには使わない。
---

# Build Technical Explainer

調査結果を構造化YAMLへ保存し、固定rendererで自己完結HTMLへ変換する。
YAMLを唯一の編集元とし、生成HTMLは直接編集しない。

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

### 3. 調査結果を構造化する

- `document.summary`には結論を先に書く。
- 観測事実、推論、採用判断、未確定事項を混同しない。
- 根拠を持つblockには`refs`を付け、`sources`のIDと一致させる。
- 出典がない内容へ参照IDを捏造しない。
- 大きなhero、宣伝文句、重複した結論、装飾目的の節を作らない。
- 計画書・設計書を含む場合は、機能・テスト・運用反映の3分類を`checklist` blockで明記する。
- 関連するUI mockや実装計画がある場合は`related_artifacts`に登録し、本文を複製しない。

補助表現は、読み手の理解や探索コストを実際に下げる場合だけ使う。

- `details`: 補足根拠や長いログを初期表示から退避する。主要な結論は隠さない。
- `chart`: YAMLにある確定済み数値を固定styleのline/barで比較する。この補助chartのために別のdataviz skillは併用しない。グラフ自体が主成果物、探索的、調整可能ならvisualization系へ任せる。
- `diagram`: 2〜8要素のflow/dependency/sequenceを説明する。自由配置や作図用途には使わない。
- `findings`: 監査指摘のような定型項目を、定義済みfacetで絞り込む。全文検索や任意条件式には使わない。

任意HTMLや任意JavaScriptはYAMLに入れない。
JavaScriptは`findings`がある場合だけrenderer所有の固定scriptをCSP hash付きで埋め込み、通信・状態保存・product logicを持たせない。

### 4. 検証して生成する

```bash
ruby <skill-dir>/scripts/render_explainer.rb validate <output-dir>/explainer.yaml
ruby <skill-dir>/scripts/render_explainer.rb render <output-dir>/explainer.yaml <output-dir>/index.html
```

`render`はschema、参照ID、公開時のローカル情報、危険なURLを再検証する。
生成後は共通validatorでCSP、許可外script、外部通信、状態保存、内部anchor、ID重複を静的検査する。
失敗した場合はYAMLを修正し、検証を迂回しない。

### 5. 成果を報告する

- YAMLとHTMLの絶対パスを示す。
- validation結果、section数、source数を短く示す。
- 通常生成ではAgentがブラウザを開かず、ブラウザ目視を完了条件に含めない。
- 公開を依頼されていない資料を外部へ送信しない。

## Updating an Existing Explainer

既存`explainer.yaml`だけを更新し、同じ`index.html`へ再renderする。
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

ブラウザ目視は保守時にも必須にしない。ユーザーが明示した場合だけ行う。
新しいblockやdiagram kindは増やさず、実利用3件後に利用頻度と不足を確認する。特に`sequence`は実績がなければ削除を再検討する。

## Resources

- `scripts/render_explainer.rb`: init、validate、renderを行う実行仕様。
- `scripts/test_render_explainer.rb`: 固定シナリオと異常系の回帰テスト。
- `references/format.md`: YAMLフィールドとblock形式。
- `assets/starter.yaml`: 初期YAML。
- `assets/report.html.erb` / `assets/report.css`: 固定HTML template。
- `assets/report.js`: `findings`専用の固定絞り込みscript。
- `../_shared/html-artifacts/`: UI mockと共有する成果物契約と基礎validator。
