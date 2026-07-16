# YAML Format

`scripts/render_explainer.rb`を実行仕様とする。
この文書はYAMLを書くときの入力リファレンスであり、rendererの規則を変更しない。

## 目次

- [Root](#root)
- [document](#document)
- [metrics](#metrics)
- [related_artifacts](#related_artifacts)
- [sections](#sections)
- [blocks](#blocks)
- [sources](#sources)
- [対応しない表現](#対応しない表現)

## Root

```yaml
version: 1
document: {}
metrics: []
related_artifacts: []
sections: []
sources: []
```

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

## blocks

すべてのblockは任意で`refs`を持てる。

### prose

```yaml
- type: prose
  text: |-
    段落を記述する。

    空行で次の段落に分ける。
  refs: [history]
```

### list

```yaml
- type: list
  style: bullet
  items:
    - "項目A"
    - "項目B"
```

`style`は`bullet`または`number`。

### table

```yaml
- type: table
  caption: "比較結果"
  columns: ["案", "利点", "欠点"]
  rows:
    - ["A", "単純", "拡張性が低い"]
    - ["B", "拡張可能", "初期費用が高い"]
```

各rowのcell数は`columns`と一致させる。
mobileではrow単位のcard表示へ変換される。

### code

```yaml
- type: code
  language: bash
  caption: "検証コマンド"
  content: |-
    ruby scripts/render_explainer.rb validate explainer.yaml
```

### callout

```yaml
- type: callout
  tone: warning
  title: "未確定"
  text: "実利用3件で再評価する。"
```

`tone`は`neutral`、`info`、`success`、`warning`、`critical`。

### checklist

```yaml
- type: checklist
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
- type: details
  summary: "監査根拠を表示"
  open: false
  blocks:
    - type: prose
      text: "補足の観測事実。"
```

- nativeの`details`として描画し、JavaScriptは使わない。
- 主要な結論や必須操作を隠さない。
- 最大12 block。`details`と`findings`は内部へ入れ子にできない。

### chart

```yaml
- type: chart
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
- type: diagram
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

- `kind`: `flow`、`dependency`、`sequence`
- `flow`と`dependency`の`direction`: `horizontal`または`vertical`
- `sequence`では`direction`を指定しない。
- nodeは2〜8、edgeは1〜16。nodeの`tone`はcalloutと同じ値を使う。
- rendererが決定的なinline SVGと文章の関係一覧を生成する。SVG内の長いlabelは表示幅に合わせて省略し、関係一覧では完全な文字列を保持する。
- 自由配置には対応しない。`flow`と`dependency`の非隣接edgeは中間nodeと交差し得るため、交差を避ける必要がある図は別の可視化手段へ任せる。

### findings

```yaml
- type: findings
  id: primary
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

- 任意HTML、任意JavaScript、iframe、外部asset
- タブ、全文検索、自由なfilter/sort、状態保存、クイズ
- 任意座標の作図、マインドマップ、ネットワーク図
- 調整可能なグラフ、探索ダッシュボード、シミュレーター
- UI案・配色案そのものの比較
