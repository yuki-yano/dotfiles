# YAML Format

`scripts/render_explainer.rb`を実行仕様とする。
この文書はYAMLを書くときの入力リファレンスであり、rendererの規則を変更しない。

## 目次

- [Root](#root)
- [document](#document)
- [metrics](#metrics)
- [related_artifacts](#related_artifacts)
- [visual_plan](#visual_plan)
- [sections](#sections)
- [blocks](#blocks)
- [sources](#sources)
- [対応しない表現](#対応しない表現)

## Root

```yaml
version: 2
document: {}
visual_plan: []
metrics: []
related_artifacts: []
sections: []
sources: []
```

- `version`は`2`だけを受理する。v1の互換処理・migrator・fallbackはない。
- 未定義fieldはvalidation errorになる。
- mappingを要求する位置に空mappingは使えない。
- YAML anchorとaliasは使えない。
- HTML、Markdown、JavaScriptを埋め込んでも文字列としてescapeされる。

## document

```yaml
document:
  title: "資料名"
  summary: "最初に読む結論。"
  kind: research
  status: draft
  visibility: private
  updated: "2026-07-15"
  audience: "判断する人"
  tags: ["agent", "evaluation"]
```

必須fieldは`title`、`summary`、`kind`、`status`、`visibility`、`updated`。

- `kind`: `research`、`audit`、`comparison`、`decision`、`implementation-report`
- `status`: `draft`、`final`
- `visibility`: `private`、`shareable`
- `shareable`では、ホームディレクトリの絶対path、`file://`、localhost参照を拒否する。

## metrics

```yaml
metrics:
  - label: "直接適合"
    value: "9 / 812"
    note: "全履歴の1.11%"
```

`metrics`は冒頭に出す必要がある数値だけに使う。

## related_artifacts

```yaml
related_artifacts:
  - id: sidebar-proposals
    title: "Sidebar UI proposals"
    href: "./sidebar-proposals.html#proposal-b"
    relation: visual-spec
    note: "案Bを採用"
```

- `relation`: `visual-spec`、`context`、`implementation-plan`、`related`
- UI案の選択後は`href`を`#proposal-<id>`まで指定する。
- 本文を複製せず、成果物間の役割を`note`で短く示す。

## sections

```yaml
sections:
  - id: conclusion
    title: "結論"
    lead: "この節の要約。"
    blocks: []
```

`id`は小文字英数字とhyphenで一意にする。
表示順は配列順になる。

## visual_plan

YAMLを書く前に、各節で何を理解させ、どの表現を選んだかを記録する。
1〜12件必須で、同じsectionを重複指定できない。

```yaml
visual_plan:
  - section: performance
    goal: "処理の入れ子とhotspotを説明する"
    form: diagram
    reason: "文章だけでは処理境界を追いにくい"
```

`form`は`none`、`table`、`chart`、`diagram`、`image`。

## blocks

すべてのblockは安定した`id`が必須で、任意で`refs`を持てる。
`id`は文書全体で一意にする。

### prose

```yaml
- id: conclusion-prose
  type: prose
  text: |-
    段落を記述する。

    空行で次の段落に分ける。
  refs: [history]
```

`text`の代わりにtyped runを指定できる。

```yaml
- id: inline-evidence
  type: prose
  runs:
    - text: "直列処理: "
      style: strong
    - text: "PreparedEvalQuery.Eval"
      style: code
```

`style`は`plain`、`strong`、`code`だけ。HTMLやMarkdownは解釈しない。

### list

```yaml
- id: scope-list
  type: list
  style: bullet
  items:
    - "項目A"
    - "項目B"
```

itemは文字列のほか、`runs`を持つmappingを使える。

`style`は`bullet`または`number`。

### table

```yaml
- id: comparison-table
  type: table
  caption: "比較結果"
  columns: ["案", "利点", "欠点"]
  rows:
    - ["A", "単純", "拡張性が低い"]
    - ["B", "拡張可能", "初期費用が高い"]
```

cellはscalar/nullのほか、意味付きcellを使える。

```yaml
rows:
  - ["全体",
     { text: ">30分でtimeout", tone: warning, emphasis: strong },
     { text: "4.2s", tone: success, emphasis: strong }]
```

`tone`は`neutral`、`info`、`success`、`warning`、`critical`。
`emphasis`は`normal`または`strong`。

各rowのcell数は`columns`と一致させる。
mobileではrow単位のcard表示へ変換される。

### code

```yaml
- id: validation-command
  type: code
  language: bash
  caption: "検証コマンド"
  content: |-
    ruby scripts/render_explainer.rb validate explainer.yaml
```

### callout

```yaml
- id: unresolved-warning
  type: callout
  tone: warning
  title: "未確定"
  text: "実利用3件で再評価する。"
```

`tone`は`neutral`、`info`、`success`、`warning`、`critical`。

### checklist

```yaml
- id: test-dod
  type: checklist
  title: "テスト完了条件"
  items:
    - text: "schema validationが成功する"
      checked: true
    - text: "実タスク3件で検証する"
      checked: false
```

計画・設計では「機能完了条件」「テスト完了条件」「運用反映条件」を別々に示す。

### details

```yaml
- id: audit-details
  type: details
  summary: "監査根拠を表示"
  open: false
  blocks:
    - id: audit-details-prose
      type: prose
      text: "補足の観測事実。"
```

- nativeの`details`として描画し、JavaScriptは使わない。
- 主要な結論や必須操作を隠さない。
- 最大12 block。`details`と`findings`は内部へ入れ子にできない。

### chart

```yaml
- id: timing-chart
  type: chart
  kind: line
  title: "処理時間の推移"
  x_label: "試行"
  y_label: "時間"
  unit: "ms"
  labels: ["1", "2", "3"]
  series:
    - name: before
      values: [120, 118, 121]
    - name: after
      values: [80, 76, 74]
```

- `kind`: `line`または`bar`
- labelは最大36、seriesは最大6。各seriesの値数はlabel数と一致させる。
- rendererが決定的なinline SVGと表形式の代替表示を生成する。
- SVG内の長いlabelは表示幅に合わせて省略し、表では完全な文字列を保持する。
- YAMLにある確定済み数値の説明専用。軸調整、zoom、tooltip、任意描画は扱わない。

### diagram

```yaml
- id: decision-flow
  type: diagram
  kind: flow
  title: "判断から実装まで"
  direction: horizontal
  nodes:
    - id: audit
      label: "監査"
      tone: info
    - id: implementation
      label: "実装"
      tone: success
  edges:
    - from: audit
      to: implementation
      label: "制約を渡す"
```

- `kind`: `flow`、`dependency`、`sequence`、`composite`
- `flow`と`dependency`の`direction`: `horizontal`または`vertical`
- `sequence`では`direction`を指定しない。
- nodeは2〜8、edgeは1〜16。nodeの`tone`はcalloutと同じ値を使う。
- rendererが決定的なinline SVGと文章の関係一覧を生成する。SVG内の長いlabelは表示幅に合わせて省略し、関係一覧では完全な文字列を保持する。
- 自由配置には対応しない。`flow`と`dependency`の非隣接edgeは中間nodeと交差し得るため、交差を避ける必要がある図は別の可視化手段へ任せる。

### composite diagram

group、複数段、node内のnotes/metricを含む技術説明図をHTML/CSSで描画する。
任意edgeは持たず、同じrowの隣接cellをrendererが自動接続する。

```yaml
- id: eval-pipeline
  type: diagram
  kind: composite
  title: "評価パイプライン"
  summary: "walk後にparseし、ASTノードごとに評価する。"
  layout:
    rows:
      - [walk, parse, ast-loop]
  groups:
    - id: ast-loop
      label: "全ASTノードごとのループ"
      tone: info
      emphasis: normal
      layout:
        rows:
          - [clone, json]
          - [rego]
  nodes:
    - { id: walk, label: "walk", notes: [".goファイル列挙"] }
    - { id: parse, label: "parse", tone: success, emphasis: strong }
    - { id: clone, label: "deep clone", tone: critical, emphasis: strong }
    - { id: json, label: "JSON往復" }
    - { id: rego, label: "Rego評価", metric: "441µs → 2.0µs" }
```

- nodeは2〜16、groupは0〜4、row/columnは各1〜4。
- groupは1階層だけ。各node/group IDはlayout内へちょうど1回配置する。
- `notes`は最大4件。`tone`と`emphasis`はtable cellと同じ値を使う。
- `summary`は必須、`description`は任意。完全な構造テキストをrendererが隣接detailsへ生成する。
- HTML、SVG、CSS、座標、`edges`、`direction`は指定できない。

### image

スクリーンショット、写真、既存図の証拠用途に限る。
PNG/JPEG/WebPをYAMLと同じディレクトリ配下から読み、data URIとしてHTMLへ埋め込む。

```yaml
- id: profile-screenshot
  type: image
  title: "計測結果"
  alt: "改善前後の計測結果を表示した画面"
  caption: "ローカル計測環境"
  description: "左列が変更前、右列が変更後。"
  asset:
    path: "assets/profile.png"
    media_type: "image/png"
    sha256: "64桁の小文字SHA-256"
    width: 1600
    height: 900
    byte_size: 245000
  provenance:
    kind: captured
    tool: "screencapture"
    version: "macOS"
    created: "2026-07-31"
    rights: "user-owned"
    sharing_reviewed: false
    source_refs: [benchmark]
```

- `image-info <image>`でasset mappingに必要な値を取得できる。
- pathは`~`を含まないplain relative pathのみ。YAMLディレクトリ外へのescape、symlink escapeを拒否する。
- 最大5MiB、最大16M pixels。animated PNG/WebP、EXIF/XMP/text metadataを拒否する。
- magic bytes、MIME、hash、寸法、byte数の不一致はhard fail。
- `shareable`文書では`sharing_reviewed: true`が必須。

### findings

```yaml
- id: primary
  type: findings
  title: "主要指摘"
  facets:
    - id: priority
      label: "優先度"
      values:
        - id: must-fix
          label: "must-fix"
        - id: should-fix
          label: "should-fix"
    - id: surface
      label: "対象"
      values:
        - id: sidebar
          label: "sidebar"
  items:
    - id: c01
      title: "選択状態が一致しない"
      summary: "表示と操作対象が異なる。"
      facets:
        priority: must-fix
        surface: sidebar
      details:
        - label: "推奨対応"
          text: "stable IDを共通に使う。"
      refs: [audit-log]
```

- facetは1〜4、各facetの値は1〜8、itemは1〜100。
- `id`は文書内で一意の必須値とし、blockの表示順を変えても再利用する。
- 全itemが全facetへ値を割り当てる。
- 複数facetはAND条件で絞り込み、resetと件数表示だけを提供する。
- renderer所有の固定scriptだけをCSP hashで許可し、検索、sort、状態保存、任意条件式は提供しない。
- item anchorは`#finding-<findings-id>-<item-id>`として生成される。

## sources

```yaml
sources:
  - id: history
    title: "Claude Code / Codex history"
    href: "/path/to/local/evidence"
    accessed: "2026-07-15"
    note: "812 sessions"
```

- `id`はsectionと同じ形式で一意にする。
- `href`は`https://`、`http://`、`file://`、絶対path、相対path、`#anchor`を使える。
- `href`の前後に空白を入れない。
- `javascript:`や`data:`などのschemeは使えない。
- `refs`から参照されるsourceを必ず定義する。

## 対応しない表現

- 任意HTML、任意JavaScript、iframe、remote asset、外部asset参照
- タブ、全文検索、自由なfilter/sort、状態保存、クイズ
- 任意座標・任意edgeの作図、マインドマップ、ネットワーク図
- 調整可能なグラフ、探索ダッシュボード、シミュレーター
- UI案・配色案そのものの比較
