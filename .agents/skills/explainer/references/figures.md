# 図：問い → 種類 → 事実シート → 検査

図は Mermaid か D2 のテキストで描く（足りなければ SVG / HTML。順序は下の「手で描く図」）。
座標は書かない。書くのは箱と辺（意味）で、配置は道具が決める。
どの図にも事実シート `figures/<name>.facts.json` を付け、`figure-check.mjs` で照合する。

## 描くか

次の場合は描く。
- 4 つ以上の要素とその関係がある
- 時間の順序がある
- 包含関係・前後の比較がある

次の場合は描かない。
- 答えが 1 文で済む
- 1 つの関数の中身
- 値を 1 つ聞かれている

## 問いから形を選ぶ

| 読み手の問い | 形 | 事実の出どころ |
|---|---|---|
| どういう状態があり、何で移るか | Mermaid flowchart（状態 = 箱、遷移 = 辺） | TLC `-dump dot,actionlabels` → `scripts/tlc-to-mermaid.mjs` |
| 反例はどういう順序で起きたか | 状態の図で反例の道を太枠（`--trace`）に。やり取りなら Mermaid `sequenceDiagram` | TLC・Apalache・Quint の反例トレース |
| A は B に含まれるか（集合・範囲） | D2 の入れ子のコンテナ | 道具の出力（到達可能状態の一覧、型の定義） |
| どう分岐するか | Mermaid flowchart / D2 | 条件分岐のコード |
| どういう構造か（モジュール） | D2（`d2-diagram` スキル） | import / package.json の依存 |

1 つの問いに図は 1 枚。

## 手順

```
1. 事実シート  <name>.facts.json を道具の出力から作る（手で書くなら、出どころを本文に書く）
2. ソース     <name>.mmd か <name>.d2。id は ASCII、表示はラベルに
3. 検査       figure-check.mjs figures/<name>.mmd --write   ✗ を 0 に（facts の edges はソースの辺とちょうど一致）
4. 目で見る   シートと辺のシートを Read で開く（下の「ループ」）
```

`verify-doc.mjs` は 3 を毎回やり直す。
SVG がソースより古ければ落ちる。

## 事実シートは道具から

- 状態グラフ：`tlc-to-mermaid.mjs` が TLC の dot から `.mmd` と `.facts.json` を同時に作る。`--trace` / `--also` の行動列が TLC の遷移に無ければエラーで止まる。
  - `checks.json` に「作り直して、コミット済みのものと diff」を入れておく。図が TLC とずれたら検証が落ちる。
- 手で描いた図（例：包含関係の D2）：図の一部を道具の出力と照合する小さなスクリプトを `checks.json` に入れる（例：`figures/check-induction.mjs` が D2 の `reach` コンテナを TLC の状態と照合する）。

## よくある kickback

- スマホで文字が 9px 未満：ラベルが長いか、横に広い。`tlc-to-mermaid.mjs --bare --abbrev read=R,...` で短くし、凡例を本文に書く。`--layout tb` / `lr` を比べる。
- Mermaid が箱の中でラベルを折り返し、facts の語が見つからない：frontmatter の `flowchart: { wrappingWidth: 480 }` で折り返しを広げる。
- 描くたびに SVG が変わり「stale」で落ちる：Mermaid のスタジアム形 `([…])` は輪郭を乱数で描く。角丸 `(…)` にする。
- 二重丸 `(((…)))` はラベルの幅で円が決まり、ほかの箱の倍になる。終端は `[[…]]` にする。
- 動きは図にしない。状態の図に道を太枠で引き、手順は本文で番号を振って書く。

## データの図（グラフ）

数値の分布・関係・モデルの診断を見せる図は、Vega-Lite の spec（`figures/<name>.vl.json`）で書く。
`figure-check.mjs` が vega で SVG にし、ほかの図と同じ検査をする（`npm i -D vega vega-lite`）。

- 文字が SVG の `<text>` のまま出るので、重なり・はみ出し・小さすぎる文字・事実シートの検査が届く。
- spec は JSON なので、題と値を事実シートや `checks.json` と照合できる。
- ブラウザを使わず、node だけで描ける。

値の計算と描画は分ける。値はスクリプトで計算して spec のデータに入れ、本文に載せる値は `checks.json` で計算し直して照合する。
計算は、JS で書ければ JS、書けなければ Python。

| 計算 | JS / TS | Python が要る |
|---|---|---|
| 集計・分布・ROC / PR・キャリブレーション | 手で書ける（数十行） | |
| GLM の係数と SE（IRLS） | `ml-matrix` で書ける（`docs/dataviz/` で statsmodels と小数 6 桁まで一致） | |
| 検定（t・χ²・順位） | `@stdlib/stats` | |
| PCA・k-means・決定木 | `ml-pca`・`ml-kmeans`・`ml-cart` | |
| 混合効果・Cox・頑健 SE・因子分析・SHAP | 成熟したものが無い | statsmodels・lifelines・factor_analyzer・shap |
| MCMC | Stan の CLI（cmdstan）の出力を読めばよい | どちらでも |

Python で計算したときも、図は Vega-Lite の spec に値を入れて描くのがよい。
matplotlib で描くなら、次の 2 つを守る。

- SVG の文字を輪郭にしない：`plt.rcParams["svg.fonttype"] = "none"`。既定のままだと文字が path になり、`figure-check` は「drawn as outlines」で落とす（文字の検査がすべて素通りするため）。
- `Glyph ... missing from font(s)` の警告は、失敗として扱う。PNG にその文字が豆腐（□）で出る。日本語のフォントには `≤` などの記号が無いことがある。ブラウザで描く図の豆腐は、`figure-check` が見つける。

### 診断の図と判定表

モデルや分析の診断を読み手に見せるときは、次の型にする。

- 1 つの手法につき 1 枚。パネルの題に「何を見る図か — 何が見えれば合格か」を書く（例：「キャリブレーション — 対角線に沿う」）。題にこの形が無いパネルは、`figure-check` が △ で知らせる。
- 合格の基準の線（対角線・陽性率・±2SE のバンド）は破線で描く。
- スマホで読む資料では、パネルを 2 列に並べない。縦に積む（`vconcat`）。375px 幅で 2 列にすると、目盛りが 6px になる。
- 本文に判定表を置く。

  | 診断項目 | 実測値 | 合格基準 | 判定 | 次アクション |
  |---|---|---|---|---|

  - 実測値は、スクリプトの出力をそのまま写す。
  - 判定（OK / 要対処 / 確認）と次アクションは、図と合格基準を見て書く。スクリプトの if で組み立てない（件数は基準内でも、図に形があることがある）。
  - 要対処には、次アクションを必ず書く。すべて OK でも表を出す。
  - 実測値には、依頼文の値か、実行した出力の値だけを書く。合格基準には、出典のあるものだけを書く。出典の無い閾値は作らず、「文脈による」として判定を「確認」にする。

#### よく使う合格基準（ロジスティック回帰）

| 診断項目 | 合格基準 | 出典・根拠 |
|---|---|---|
| AUC・AP | 決まった閾値は無い。用途で決める（判定は「確認」）。AP は陽性率と比べる | 陽性率が AP のベースライン（でたらめに並べたときの値） |
| Brier score | ベースライン p(1 − p)（p は陽性率）より小さい | 全員に陽性率を答えたときの Brier が p(1 − p) |
| キャリブレーション | 十分位の点が対角線に沿う。外れ方に形が無い | 図を見て判断する（数の閾値は無い） |
| binned residual | ±2SE のバンドの外に出るビンが、Binomial(K, 0.05) の上側 5% 点以下（K = 20 なら 3 個以下）。外れ方に形が無い | モデルが正しければ、各ビンはおよそ 5% の確率でバンドの外に出る（Gelman & Hill 2007 の binned residual plot） |
| 係数 | 解釈する係数の SE が出ている。|係数| / SE の大きさを示す（p 値の閾値は依頼文に無ければ置かない） | — |

例は `docs/dataviz/`（ロジスティック回帰の 4 パネル。JS で計算した値を、Python の値と照合している）。
この型は、[atsushi-green/ds-ai-coding-skills](https://github.com/atsushi-green/ds-ai-coding-skills) の diagnostics スキルの考え方を参考に書いた（ライセンスの記載が無いので、文章とコードは使っていない）。

## 手で描く図（Mermaid / D2 / SVG / HTML）と、目で見るループ

道具の出力から作る図（上）でも、手で書く概念図（使い分けの図、コードと箱が混ざる図）でも、形式は同じ順で選ぶ。
形式は **Mermaid → D2 → SVG / HTML** の順に当て、足りるものを使う（測った結果は `docs/figure-cheatsheet/`）。

1. **Mermaid で済むなら Mermaid**：フロー・シーケンス・状態遷移など。GitHub の Markdown（PR 本文・Issue）がそのまま描くので、PR の説明に置く図はこれが一番安い。
2. **Mermaid で足りない構造なら D2**：次のどれかに当たるとき。
   - サブグラフの中の向きを変えたいが、中の箱が外とつながる（Mermaid は中の `direction` をエラーを出さずに無視する）
   - 箱の名前の上を線が通る（Mermaid・ELK・dagre で起きた。TALA で避けられた）
   - 位置の固定や `near` が要る
   - エンジン（TALA / ELK）を選びたい
3. **D2 の「箱と線」に乗らない自由な図なら SVG / HTML**：位置そのものに意味があるなら SVG、文字とコードが主なら HTML。

| 形式 | 向いているもの | 置き場所 |
|---|---|---|
| Mermaid（`figures/<name>.mmd`） | 箱と線だけで崩れない図。GitHub にそのまま貼る図 | `--write` で `<name>.svg` を作り、それを参照する（`mermaid` をプロジェクトに入れる） |
| SVG（`figures/<name>.svg`） | 位置に意味がある図：包含関係、範囲、平面上の配置 | Markdown から `![…](figures/<name>.svg)` |
| HTML（`figures/<name>.fig.html`） | 文字とコードが主で、箱で区切る図。ページのライト / ダークに従う | Markdown からは `![…](figures/<name>.fig.png)`。HTML に組むときは `.fig.html` が埋め込まれる |
| D2（`figures/<name>.d2`） | 分岐・流れ・依存。レイアウトを道具に任せたい図 | `--write` で `<name>.svg` を作り、それを参照する |

どの形式でも、事実シート `figures/<name>.facts.json` を先に書く。

```json
{ "labels": ["図に必ず出る語"], "forbidden": ["出てはいけない語（過去の誤り）"], "edges": ["a->b"] }
```

`edges` は D2 と Mermaid で使う（ソースの辺と照合する）。

### ループ（1 回 = 描画 → 機械の検査 → 目で見る → 直す）

```
node <skill>/scripts/figure-check.mjs figures/<name>.svg|.fig.html|.d2|.mmd [--write]
node <skill>/scripts/figure-variants.mjs figures/<name>.d2|.mmd          # 配置が不自然なとき
```

D2 と Mermaid は、書いたのは意味（箱と辺）だけで、配置は道具が決める。
意味が正しくても、描いてみると不自然な配置や、どこからどこへ行くのか読めない矢印になることがある。
だから、描いたものを必ず目で見て、配置を選び直す。

1. **機械の検査**：✗ を 0 にする。
   - overlap：文字同士の重なり
   - clipped：図の外へのはみ出し
   - crossing：文字が箱の枠線をまたぐ
   - through：線が文字の中を通る（D2 がマスクで切り抜いた部分と、Mermaid の辺のラベルは数えない）
   - tiny：スマホ幅で 9px 未満の文字
   - facts：事実シート
   - vlmkit：integrity と a11y contrast
   - arrows（D2 / Mermaid、`data-edge` を付けた SVG）：
     - ✗ shared：2 本の辺が長く（40px 以上）重なって走る。分かれ目が、別の箱同士をつなぐ矢印に見える
     - ✗ through：辺が、端点でない箱の中を通る
     - △ cross（交差）・detour（遠回り）・against（流れと逆向き）：落とさないが、辺のシートで目で見る
2. **目で見る**：2 枚を **Read で開く**。
   - `look at it:` のシート（ライト・ダーク・スマホ）で、図全体を見る。
     - 読む順序：入口が左上か上にあるか。ループの戻り先が先頭に来ていないか
     - 意味：ラベルが指しているものは正しいか（例：CTI は「Inv の外へ出た状態」ではなく「出発点」）
     - 詰まり・余白：ある部分だけ窮屈ではないか。大きな空白で要素が離れすぎていないか
     - ダーク：色で区別している枠が見分けられるか（非テキストは 3:1 以上。色は計算して確かめる）
   - `look at the arrows:` の辺のシートで、矢印を 1 本ずつ見る。赤い線が 1 本ずつ強調されている。
     - その線だけを見て「どこから、どこへ」と読めるか。見出しの「a → b」と一致するか
     - 分かれ目や合流点で、別の線に乗り換えたように見えないか
     - △ の付いた辺（赤枠）：逆向きの辺は、戻る辺として意図したものか。交差は避けられないものか
3. **配置が不自然なら、選び直す**：`figure-variants.mjs` で候補を並べる。
   - D2 は、TALA の seed 1〜6・ELK・dagre（`--directions down,right` で向きも掛け合わせる）。Mermaid は、向き × 線の曲げ方。
   - 各候補を figure-check に通し、減点（✗ の重みづけ）・矢印の点数・△ の数の順に並べた `<name>.variants.png` を出す。これを Read で開いて見比べる。
   - 機械の順位は、明らかに悪い候補を落とすためのもの。残った候補から、目で見て選ぶ。
   - 選んだら、出力の「選んだら：」のとおりソースに書き、選んだ理由をコメントに 1 行残す（例：`# 既定の seed では…に見えた。seed 4〜9 を並べて、5 を選んだ`）。
   - どの候補にも ✗ が残るなら、配置では直らない。図の構造（箱の分け方・向き・ラベルの長さ）を変える。Mermaid で足りないなら D2（TALA）に移す。
4. **直す**：目で見つけた誤りのうち、機械で捉えられる種類のものは、先に `figure-check.mjs` か `figure-arrows.mjs` の検査に足す（`tests/figure-check/` に悪い例を 1 つ足す）。意味の誤りは `forbidden` に足す。
5. 上限は 5 回。それでも直らなければ、図をやめて文章にするか、分け方を変える。

### アイコン

アイコンは、箱の種類（利用者・サーバ・データベース）や、製品そのもの（PostgreSQL・Redis）を一目で分けたいときだけ使う。
飾りのために足さない。ラベルは消さない（アイコンだけでは読めない人がいる）。

`scripts/icons.mjs` が、プロジェクトに入っている Iconify のアイコンセットから探して、図の隣に置く。

| セット | 中身 | ライセンス | 入れ方 |
|---|---|---|---|
| `lucide` | 線のアイコン（約 1900 個）。箱の中に置く | ISC | `npm i -D @iconify-json/lucide` |
| `logos` | 技術のロゴ（色つき、約 2200 個）。その製品そのものを指すときだけ | CC0（ロゴは各社の商標） | `npm i -D @iconify-json/logos` |

```
node <skill>/scripts/icons.mjs search database --sheet /tmp/icons.png   # 候補を探し、1 枚に並べて目で選ぶ
node <skill>/scripts/icons.mjs add lucide:database                      # figures/icons/database.svg を書き、ICONS.md に出典を残す
node <skill>/scripts/icons.mjs inline lucide:database --size 24 --x 10 --y 10   # 手書きの SVG / HTML に貼る <svg>
```

- **D2**：`db: DB {icon: ./icons/database.svg}`。パスは `.d2` から見た相対パス。ロゴを主役にするなら `shape: image` にし、`width: 72; height: 72` のように大きさを決める（決めないと、ロゴが図の中で一番大きくなった）。
- **Mermaid**：`db@{ icon: "lucide:database", label: "DB", pos: "b" }`。figure-check が、プロジェクトに入っているセットを Mermaid に登録して描く。
- **SVG / HTML**：`icons.mjs inline` の出力を貼る。線の色は `--color` で決める（既定は `#1f2328`）。
- figure-check は、次の 2 つを落とす。
  - 図に埋め込まれていない画像。ファイルが無いか、パスが違うと、D2 は画像を埋め込まずにパスだけを残す。
  - `ICONS.md` に出典の無い D2 のアイコン。`icons.mjs add` で置けば、自動で記録される。

### 形式ごとの注意

- **SVG**：`viewBox` を狭く縦長にすると、スマホでも文字が小さくなりにくい（640 幅より 520 幅）。文字は 15px 以上。説明の文字は、矢印が出ていく側と反対に置く。
- **HTML**：色は `var(--fg)` などのページのトークンを使う。固有の色は、ダーク用の値を `:root[data-theme="dark"]` と `@media (prefers-color-scheme: dark)` の両方に書く。スマホ幅（〜520px）では 1 列に落とす。
- **Mermaid**：文字は SVG の `<text>` で描かせる（`figure-check.mjs` がそう設定する）。辺のラベルは線の上に背景つきで置かれるので、`through` では数えない。サブグラフの名前を線が通るのは数える。
- **D2 のエンジン**（測った結果は `docs/figure-cheatsheet/`）：
  - **TALA**（既定）：箱の入れ子（アーキテクチャ）、箱ごとの `direction`、固定位置（`top` / `left`）、`near: 別の箱`。後ろの 3 つは TALA しかできない。
    - direction を書かないと、入口が上に来ないことがある。書く。
    - seed で配置がすべて変わる。線の分かれ目が別の矢印に見えたら（arrows の shared）、`figure-variants.mjs` で seed を並べて選ぶ。v0.9.0 はファイルの `vars` に seed を書けないので、`# d2-flags: --tala-seeds=N` の行を書く（`figure-check.mjs` が d2 に渡す）。
    - 箱の数に対して描画時間が急に伸びる（40 個で ELK の 10 倍以上）。
  - **ELK**：一方向の長い DAG、戻る辺のある手順、何度も描き直す大きい図。1 つ足しても配置があまり動かない。
    - 箱をまたぐ線が箱の名前を通る（`through` で落ちる）。
    - **箱ごとの `direction` を、エラーを出さずに無視する**。箱の中を縦にするなら `grid-columns: 1`。
  - **dagre**：ELK より良い場面は見つかっていない。
  - 横に長い流れは、どのエンジンでもスマホで文字が潰れる。縦に流す。
- **D2**：戻る辺があると、TALA は戻り先を上に置くことがあり、入口が上に来ない。入口を上にしたいときは、ファイルの先頭で ELK を選ぶ。
  ```d2
  vars: { d2-config: { layout-engine: elk } }
  ```
  文字は `*.style.font-size: 22` のように大きめにし、ラベルは 2 行以内にする。`d2 fmt` で整形する。
