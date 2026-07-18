# 改善計画テンプレート

## 目次

- ファイル配置
- 計画ファイル
- Indexファイル
- 品質確認

計画は、その計画を初めて読む実装エージェントが、会話履歴なしで実装できる内容にする。
推測で埋めさせず、検証と停止条件で判断範囲を限定する。

## ファイル配置

リポジトリに文書配置規約があれば従う。
規約がなければ次を使う。

```text
docs/improvements/
├── README.md
├── 001-short-slug.md
└── 002-short-slug.md
```

番号は推奨実行順を基準に単調増加させる。

## 計画ファイル

```markdown
# 改善計画 NNN：完了後に成立する状態

> 実装担当への指示：この計画を最初から読み、順番に実装する。
> 各phaseの検証結果を確認してから次へ進む。
> 停止条件に当たった場合は、自己判断で範囲を広げず報告して停止する。
>
> 変更確認：`git diff --stat <planned-at SHA>..HEAD -- <in-scope paths>`
> 対象fileが計画作成後に変わっている場合は、「現在の状態」の引用と照合する。
> 一致しなければ停止条件として扱う。

## 状態

- Priority：P1 | P2 | P3
- Effort：S | M | L
- Risk：LOW | MED | HIGH
- Depends on：`docs/improvements/NNN-*.md` または「なし」
- Category：bug | security | perf | tests | tech-debt | migration | dx | docs | direction
- Planned at：commit `<short SHA>`、<YYYY-MM-DD>

## 背景と目的

現在の問題、具体的なcost、完了後に改善するbehaviorを2文から5文で書く。

## 確定済みの設計判断

- 採用する方針と理由を書く。
- 検討して採用しなかった案があれば、再検討を防ぐため理由を書く。
- ADR、PRD、DESIGNなどの制約を、実装に必要な範囲で引用する。

## 現在の状態

- 関連fileと役割を列挙する。
- findingを裏付ける現在のcodeを、`file:line`付きで短く引用する。
- 従うべきrepo規約を、実在するexemplar fileとともに示す。
- 推測と確認済みの事実を分ける。

## 使用するコマンド

| 目的 | コマンド | 成功条件 |
|---|---|---|
| Test | `<repoで確認したcommand>` | exit 0、対象testが成功 |
| Typecheck | `<repoで確認したcommand>` | exit 0、errorなし |
| Lint | `<repoで確認したcommand>` | exit 0 |
| Build | `<必要な場合だけ>` | exit 0 |

推測したcommandを書かない。
該当commandがない場合は「なし」とし、その事実を計画の前提へ含める。

## 参照物

- 関連文書、mock、screenshot、ADRのlocal pathを示す。
- 参照物が仕様源なら、どの要素がどの実装へ対応するかを書く。

## 対象範囲

### 変更対象

- `path/to/file`

### 変更対象外

- `path/to/related-file`：対象外にする理由
- public API shapeなど、変えてはいけないbehavior

## 実装phase

### Phase 1：命令形の題名

- 対象fileとsymbolを指定する。
- 実現するbehaviorと、必要なcode shapeを書く。
- 後方互換性対応やfallbackは、ユーザーが承認した場合だけ含める。

検証：`<command>`

期待結果：`<observable result>`

### Phase 2：命令形の題名

- 前phaseからの依存関係を書く。
- 並行可能なら、共有stateと統合検証を示す。

検証：`<command>`

期待結果：`<observable result>`

## Test plan

- 追加するtest fileとcaseを列挙する。
- happy path、findingの回帰、名前付きedge caseを区別する。
- 構造を合わせる既存test fileを示す。
- testを追加しない場合は、不要と判断した根拠を書く。

## DoD（Definition of Done）

### 機能完了条件

- [ ] 完了後に成立すべきbehaviorを、観測可能な形で書く
- [ ] findingの原因となった旧patternが残っていないことを確認する

### テスト完了条件

- [ ] `<test command>` がexit 0で終了する
- [ ] 追加した回帰testが、修正前の問題を検出できる
- [ ] 必要なedge caseが通る

### 運用反映条件

- [ ] lint、typecheck、buildのうちrepoで必要なcommandが成功する
- [ ] 文書、設定、migrationなど必要な運用資材が更新されている
- [ ] `git status`で変更対象外のfileが変更されていない
- [ ] 改善バックログのindexが更新されている

## 停止条件

- 「現在の状態」の引用と実codeが一致しない。
- 前提としていた設計判断が誤っている。
- 変更対象外のfileを触らないと完了できない。
- 同じ検証が、異なる修正を試しても繰り返し失敗する。
- schema、auth、billing、production dataなど、未承認の高risk判断が必要になる。
- 後方互換性対応やfallbackが必要になる。

## やらないこと

- findingと無関係なrefactorを行わない。
- formatterを変更対象外へ広げない。
- commit、push、PR作成を行わない。必要な場合はユーザーの明示指示を待つ。

## 保守上の注意

- 今後どの変更がこの実装へ影響するかを書く。
- reviewerが確認すべき箇所を書く。
- 今回見送ったfollow-upと理由を書く。
```

## Indexファイル

```markdown
# 改善バックログ

## 実行順と状態

| Plan | Title | Priority | Effort | Depends on | Status |
|---|---|---|---|---|---|
| 001 | ... | P1 | S | なし | TODO |

Status：TODO | IN PROGRESS | DONE | BLOCKED | REJECTED

## 依存関係

- 002は001を必要とする。理由：...

## 棄却したfinding

- <finding>：対応価値がない、仕様どおり、独立して修正済みなどの理由
```

## 品質確認

- 計画だけを渡された実装エージェントが追加質問なしで開始できるか確認する。
- 各phaseにcommandと期待結果があるか確認する。
- file名ではなくsymbolまで特定できる箇所は特定する。
- DoDに機能、テスト、運用反映の3分類があるか確認する。
- 停止条件が対象finding固有のriskを含むか確認する。
- secret値が含まれていないか確認する。
- planned-at SHAと変更対象pathが一致しているか確認する。
