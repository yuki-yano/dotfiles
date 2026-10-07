---
name: ui-mock-proposals
description: UI・配色・レイアウト・情報密度の複数案を静的HTMLモックで比較・選択するときに使う。技術説明資料、単一案の実装、挙動だけの変更には使わない。
---

# UI Mock Proposals

実装可能なUIの見た目を、現状と複数案を並べた単一HTMLで比較し、安定案IDを使って選択と実装へつなげる。

## Workflow

### 1. 実装と比較条件を調べる

- 対象UIのコードを読み、色token、font、icon、spacing、component構造を把握する。
- 技術的な表示制約を確認する。TUIなどでは端末で再現できない装飾を案に含めない。
- スクリーンショットがある場合は、見た目を推測せず比較基準として利用する。
- 既存の要件や仕様がある場合は、比較に関係する制約と未確定事項を確認する。

### 2. 比較案を設計する

- `current` 1件と、方向性の異なる2〜3案を基本とし、依頼に合わせて案数を変える。単一案の実装はこのskillの対象外。
- 現状を局所修正した微差だけで埋めず、各案の設計意図を明確に変える。
- 推奨案は1つだけ明示してよいが、他案を不当に弱く作らない。
- 各案に短い方向性、Pros、Cons、実装上の注意を付ける。
- 表示データはダミーのLorem ipsumではなく、実アプリに出る現実的な内容を使う。

### 3. 単一HTMLを作る

- 全案を1ファイルにまとめる。命名は`<target>-proposals.html`、配色中心なら`<target>-compare.html`。
- 使い捨てならproject内の`tmp/`などgitignore済みの場所、記録として残すなら規約に沿って`docs/`へ置く。
- 大きなheroを置かず、compactなheader、比較navigation、`current`、各proposalの順にする。
- 現状は`id="current"`、各案は`id="proposal-<id>" data-proposal-id="<id>"`を持つ`section`か`article`にする。
- 案IDは小文字英数字とhyphenで固定し、表示名を変えても再利用する。例: `proposal-a`、`proposal-dense`。
- navigationから`#current`と全proposal anchorへlinkする。
- 実アプリのtokenとfont指定を反映し、対象アプリのUIとして実装可能なHTML・CSSにする。
- 単体で開ける自己完結HTMLにし、CSSを埋め込み、iconはinline SVGかCSSで表現する。外部asset、画像要素、iframe、inline event handler、通信、storage、cookieは使わない。
- linkはHTTP(S)、同一文書内anchor、同梱する資料への相対pathを使う。root絶対path、`file://`、home相対path、Windows絶対pathを埋め込まない。
- CSPは`default-src 'none'; style-src 'unsafe-inline'; script-src 'none'; connect-src 'none'; img-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'`を基本とする。視覚状態の切替に最小限のinline scriptが必要な場合だけ、`script-src`をmatching SHA-256 hashまたは`'unsafe-inline'`に変える。product logicは実装しない。
- `lang`、viewport、keyboard focus、十分なcontrastを用意し、動きを使う場合は`prefers-reduced-motion`へ対応する。
- theme対応が必要なら`prefers-color-scheme`を使う。複数theme自体が比較対象なら、同じHTML内へ静的に並べる。

### 4. 静的検証して提示する

skillディレクトリを`<skill-dir>`として実行する。

```bash
ruby <skill-dir>/scripts/validate_proposals.rb <proposals.html>
```

validatorはHTMLの基本構造・参照・禁止APIと、`current`、2件以上のproposal、安定案ID、navigation linkを静的に点検する。見た目やcontrastの良否までは保証しない。
HTMLの絶対pathと案IDを報告する。ブラウザ目視はユーザーの指定や具体的な表示不具合がある場合に行う。公開の依頼がなければ外部送信しない。

### 5. 選択・修正・実装へつなぐ

- ユーザーは「Bで」「denseベースでAの配色」のように自由回答で選べる。テキスト択一UIを強制しない。
- 微調整は同じファイルと同じ案IDを更新する。意味が変わる新案だけ新しいIDを使う。
- 方向転換では既存案に固執しない。選択がないまま話題が変わっても選択を強要しない。
- 選択した案IDと理由を記録する。UI mockは視覚仕様の基準とし、挙動や受け入れ条件は依頼・仕様から確認する。
- 直接実装する場合は、案と実装component/tokenの対応を示してから変更し、対象projectのtest・lintを通す。
- 別Agentへ引き継ぐ場合は実装計画を作り、少なくとも次のDoDを測定可能なchecklistとして含める。
  - [ ] 機能完了条件: 選択案IDと対象component/tokenの対応が実装されている。
  - [ ] テスト完了条件: 対象projectで指定されたtest・lint・必要な回帰確認が成功している。
  - [ ] 運用反映条件: 必要な設定・文書・配布先への反映方法と確認結果が記録されている。

## Skill Maintenance

validation規則を変更した場合は次を実行する。

```bash
ruby <skill-dir>/scripts/test_validate_proposals.rb
ruby <skill-dir>/scripts/test_validate_html.rb
uv run --with pyyaml python <skill-creator-dir>/scripts/quick_validate.py <skill-dir>
```

本文だけの変更では形式・参照先・既定プロンプトの整合を確認する。ブラウザ目視は一律に追加しない。
