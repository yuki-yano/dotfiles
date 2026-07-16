---
name: ui-mock-proposals
description: UI改善案、配色案、レイアウト案、情報密度の異なる案を、複数の静的HTMLモックとして比較・選択したいときに使う。「UI案をHTMLで比較して」「見た目を複数案出して」のような自然言語でも適用する。調査結果や技術比較を説明資料として残す依頼、単一案の実装、挙動・product logicだけの変更には使わない。
---

# UI Mock Proposals

実装可能なUIの見た目を、現状と複数案を並べた単一HTMLで比較し、安定案IDを使って選択と実装へつなげる。

## Workflow

### 1. 役割と前提を確認する

- レイアウト、配色、情報密度、視覚的優先順位など「見た目を選ぶ」依頼に使う。
- 事実、関係、数値、根拠、判断、DoDを説明・記録する依頼は`build-technical-explainer`に任せる。
- 両方が必要なら成果物を分ける。Explainerの要件・制約を入力にし、選択後に案IDと理由をExplainerへ戻す。
- 共通の出力・安全性・連携規則は[HTML Artifact Contract](../_shared/html-artifacts/contract.md)に従う。

### 2. 実装を調べる

- 対象UIのコードを読み、色token、font、icon、spacing、component構造を把握する。
- 技術的な表示制約を確認する。TUIなどでは端末で再現できない装飾を案に含めない。
- スクリーンショットがある場合は、見た目を推測せず比較基準として利用する。
- 前提Explainerがある場合は、機能要件、制約、アクセシビリティ条件、未確定事項を先に読む。

### 3. 比較案を設計する

- `current` 1件と、方向性の異なる3〜5案を基本とする。明示された案数がある場合は2〜5案の範囲で従う。
- 現状を局所修正した微差だけで埋めず、各案の設計意図を明確に変える。
- 推奨案は1つだけ明示してよいが、他案を不当に弱く作らない。
- 各案に短い方向性、Pros、Cons、実装上の注意を付ける。
- 表示データはダミーのLorem ipsumではなく、実アプリに出る現実的な内容を使う。

### 4. 単一HTMLを作る

- 全案を1ファイルにまとめる。命名は`<target>-proposals.html`、配色中心なら`<target>-compare.html`。
- 使い捨てならproject内の`tmp/`などgitignore済みの場所、記録として残すなら規約に沿って`docs/`へ置く。
- 大きなheroを置かず、compactなheader、比較navigation、`current`、各proposalの順にする。
- 現状は`id="current"`、各案は`id="proposal-<id>" data-proposal-id="<id>"`を持つ`section`か`article`にする。
- 案IDは小文字英数字とhyphenで固定し、表示名を変えても再利用する。例: `proposal-a`、`proposal-dense`。
- navigationから`#current`と全proposal anchorへlinkする。
- 前提Explainerがある場合だけ、compactなheaderから相対linkで戻れるようにする。
- 実アプリのtokenとfontを移植し、各案を実装可能な表現にする。対象アプリのUIとして見えるCSSを優先し、資料用rendererのCSSは共有しない。
- CSSとassetは共通契約に従い、iconはinline SVGかCSSで表現する。
- 原則として`script-src 'none'`にする。視覚状態の比較に最小限のinline scriptが不可欠な場合だけ、共通契約の`ui-mock` profileが許可する範囲で使う。
- theme対応が必要なら`prefers-color-scheme`を使う。複数theme自体が比較対象なら、同じHTML内へ静的に並べる。

### 5. 静的検証して提示する

skillディレクトリを`<skill-dir>`として実行する。

```bash
ruby <skill-dir>/scripts/validate_proposals.rb <proposals.html>
```

validatorは共通契約に加え、`current`、2〜5件のproposal、安定案ID、`data-proposal-id`、navigation linkを検証する。
Agentによるブラウザ目視は完了条件に含めない。HTMLの絶対pathと案IDを報告し、ユーザーが任意の方法で確認できるようにする。

### 6. 選択と反復を扱う

- ユーザーは「Bで」「denseベースでAの配色」のように自由回答で選べる。テキスト択一UIを強制しない。
- 微調整は同じファイルと同じ案IDを更新する。意味が変わる新案だけ新しいIDを使う。
- 方向転換では既存案に固執しない。選択がないまま話題が変わっても選択を強要しない。

### 7. 選択後に実装へつなぐ

- 選択済みUI mockは視覚仕様の基準であり、挙動・根拠・DoDまで含む唯一の仕様源ではない。
- 前提Explainerがある場合は、判断節へ選択案ID、理由、採用した制約を記録し、`related_artifacts.href`を`#proposal-<id>`へ更新する。
- 直接実装する場合は、案と実装component/tokenの対応を示してから変更し、対象projectのtest・lintを通す。
- 別Agentへ引き継ぐ場合は実装計画を作り、少なくとも次のDoDを測定可能なchecklistとして含める。
  - 機能完了条件: 選択案IDと対象component/tokenの対応が実装されている。
  - テスト完了条件: 対象projectで指定されたtest・lint・必要な回帰確認が成功している。
  - 運用反映条件: 必要な設定・文書・配布先への反映方法と確認結果が記録されている。

## Skill Maintenance

validation規則を変更した場合は次を実行する。
`<shared-dir>`は`<skill-dir>/../_shared/html-artifacts`を指す。

```bash
ruby <skill-dir>/scripts/test_validate_proposals.rb
ruby <shared-dir>/scripts/test_validate_html.rb
uv run --with pyyaml python <skill-creator-dir>/scripts/quick_validate.py <skill-dir>
```

ブラウザ目視は保守時にも必須にしない。ユーザーが明示した場合だけ行う。

## Resources

- `scripts/validate_proposals.rb`: 共通契約とproposal固有規則のvalidator。
- `scripts/test_validate_proposals.rb`: proposal固有規則の回帰テスト。
- `../_shared/html-artifacts/`: Explainerと共有する成果物契約と基礎validator。
