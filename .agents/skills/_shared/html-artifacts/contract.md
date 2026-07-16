# HTML Artifact Contract

`build-technical-explainer`と`ui-mock-proposals`が共有する成果物契約。
生成方式と本文の見た目は各skillが所有し、この契約では共通部分だけを定義する。

## Routing

- 事実、関係、数値、根拠、判断、DoDを理解・記録する場合は`build-technical-explainer`を使う。
- レイアウト、配色、情報密度など、実装候補の見た目を選ぶ場合は`ui-mock-proposals`を使う。
- 両方が必要な場合は成果物を分け、ExplainerからUI mockへ制約を渡し、選択後に採用案IDと理由をExplainerへ戻す。

## Authoring Ownership

- ExplainerではAgentがYAMLを編集し、固定rendererがHTML・CSS・許可済みscriptを生成する。生成HTMLをAgentが自由記述しない。
- UI mockではAgentが対象UI固有のHTML・CSSを案ごとに設計する。ExplainerのYAML schema、renderer、CSSを流用しない。
- 共有するのは出力契約、基礎validator、成果物間のlink規約だけとする。

## Common Output Rules

- 単体で開ける自己完結HTMLとし、外部asset、CDN、iframe、inline event handler、ネットワーク通信、storage、cookieを使わない。
- 大きなheroを置かず、成果物の主内容を最初の画面から確認できる構成にする。
- `lang`、viewport、keyboard focus、十分なcontrastを用意し、動きを使う場合は`prefers-reduced-motion`へ対応する。
- 公開を明示されていない成果物は外部送信しない。
- 関連成果物は相対linkで相互に結び、同じ内容を複製しない。

## Shared Validation

`scripts/validate_html.rb`を共通の基礎検証とする。

```bash
ruby <shared-dir>/scripts/validate_html.rb --profile explainer <index.html>
ruby <shared-dir>/scripts/validate_html.rb --profile ui-mock <proposals.html>
```

- `explainer`はscriptなし、またはCSP hashで許可されたrenderer所有scriptだけを受け入れる。
- `ui-mock`は必要最小限のinline scriptを許可するが、外部通信、状態保存、product logicは許可しない。
- 各skillは共通検証に加えて、schemaやproposal IDなど固有の検証を行う。

## Linkage

- UI mockの現状は`current`、各案は`proposal-<id>`の安定anchorを持つ。
- Explainerの定型指摘は`finding-<findings-id>-<item-id>`の安定anchorを持つ。
- Explainerは関連UI mockを`related_artifacts`へ登録し、採用後は選択したanchorと理由を判断節へ記録する。
- UI mockは、前提となるExplainerがある場合だけheaderからlinkする。
- 実装時は、Explainerを要件・根拠・DoDの基準、選択済みUI mockを視覚仕様の基準として参照する。

## Definition of Done

### 機能完了条件

- [ ] 内容に応じてExplainer、UI mock、または分離した両成果物へroutingされている。
- [ ] ExplainerはYAMLから再生成でき、UI mockは`current`と2〜5件の安定proposal IDを持つ。
- [ ] 両成果物がある場合は相対linkで接続され、選択後のExplainerに案IDと理由が記録されている。

### テスト完了条件

- [ ] 各HTMLが共通validatorの該当profileを通過している。
- [ ] Explainerはrenderer test、UI mockはproposal validator testが成功している。
- [ ] skill metadataを含む`quick_validate.py`が両skillで成功している。

### 運用反映条件

- [ ] 両skillの`description`が自然言語の発火条件を区別し、Codex用`agents/openai.yaml`でimplicit invocationが許可されている。
- [ ] 最終報告に成果物の絶対path、validation結果、選択済みならproposal IDが含まれている。
- [ ] 公開を依頼されていない成果物が外部送信されていない。
