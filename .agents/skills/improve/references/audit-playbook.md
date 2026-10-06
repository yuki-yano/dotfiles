# 監査プレイブック

## 目次

- Correctnessとbugs
- Security
- Performance
- Test coverage
- Tech debtとarchitecture
- Over-engineering
- Dependenciesとmigrations
- DXとtooling
- Docs
- Direction
- Finding形式
- 優先順位

findingにはコード上の根拠が必要である。
「N+1がありそう」ではなく、「`orders/api.ts:142` が各itemについてqueryを実行する」と示す。

## Correctnessとbugs

- 例外の握り潰し、critical pathの空catch、失敗状態の欠落を探す。
- await漏れ、競合、cancelやcleanupの欠落を確認する。
- null、undefined、配列境界、空collection、timezone、localeを確認する。
- state machineの未処理分岐と、不可能状態を表現できる型を探す。
- check-then-act、transaction不足、retry時の非idempotent処理を確認する。
- `any`、強制cast、`@ts-ignore` がcompilerを迂回している箇所を確認する。
- handle、connection、subscriptionのresource leakを確認する。

## Security

防御側の保守として、コードで確認できた問題だけを報告する。
再現用の攻撃手順や実行可能なpayloadは計画へ書かない。

- hardcoded credential、commit済み`.env`、credentialを含むlogや永続化を確認する。
- request dataがSQL、shell、HTML sink、dynamic execution、filesystem pathへ流れる境界を確認する。
- server-side authentication、authorization、ownership、tenant境界を確認する。
- request body、upload、mass assignmentのschema validationを確認する。
- production CORS、cookie属性、security header、debug設定を確認する。
- PII、stack trace、内部errorの外部露出を確認する。
- dependency auditはhighまたはcriticalで、runtimeや配布経路へ到達するものだけを扱う。

標準platform規約や文書化済みtrade-offをsecurity findingにしない。
ただし、ADRと実装が食い違う場合はdecision driftとして報告する。

secret値は引用しない。
credentialの種類と場所だけを示し、漏えい済みならrotationを含める。

## Performance

- loop内queryやfetchなどのN+1を探す。
- 同じcollectionに対するnested scanやhot path内の反復`find`を確認する。
- 同一の高コスト処理やfetchがrequest単位で重複していないか確認する。
- unbounded list、pagination不足、over-fetching、大きなpayloadを確認する。
- frontendではwaterfall、不要なclient fetch、重いdependency、code splitting不足を確認する。
- backendでは同期処理、pooling不足、schemaから裏付けられるindex候補を確認する。
- CIではcache不足、重複step、直列実行しかしていない独立testを確認する。

micro optimizationより、計算量とarchitecture上の改善を優先する。

## Test coverage

- money、auth、data mutationなどのcritical pathに意味のあるtestがあるか確認する。
- 変更頻度が高くtestのないmoduleをcharacterization test候補として扱う。
- assertionの弱いtest、mock自体を試すtest、放置snapshot、real timerやreal networkを確認する。
- unit、integration、E2Eの不足を、riskとfeedback速度に応じて判断する。
- 一つのcommandで健全性を確認できない場合は、verification baselineを先行findingにする。

coverage率だけを目的にしない。

## Tech debtとarchitecture

- 同じlogicが3箇所以上に複製され、すでにdriftしていないか確認する。
- UIからdata layer内部への直接依存、circular dependency、巨大なutilsを確認する。
- dead code、展開済みfeature flag、comment out、未使用dependencyを確認する。
- repo中央値から大きく外れたmodule、深いnest、過剰なparameterを確認する。
- data fetching、error handling、stylingの複数方式が混在していないか確認する。
- 一実装しかない早すぎる抽象化と、同時変更を強いる抽象化不足を区別する。

## Over-engineering

要件と現在の挙動を保ったまま保守負担を減らせる候補だけをfindingにする。
LOC削減は補助指標であり、短くなること自体を根拠にしない。
未使用コード、不要な抽象化、重複はTech debtとarchitectureと観点を共有するため、`over-engineering` の分野限定でもTech debtとarchitectureの観点を併せて読んで確認する。全カテゴリ監査では同じfindingを一方のカテゴリだけで報告する。

- 委譲しかしないwrapper、誰も設定しない設定項目や分岐、1箇所しか通らない層など、要件にない汎用化を確認する。
- 既存の共通処理やhelperで置き換えられる個別実装を確認する。
- 自前実装を標準ライブラリ、プラットフォーム標準機能、導入済み依存で置き換えられないか確認する。置換後も現在の挙動、UI操作、競合対策、入力検証、エラー処理、アクセシビリティが保たれる場合だけ候補にする。
- 一実装のinterface、1 exportのfile、小さなwrapperは、それだけでは過剰実装と断定しない。責務の分離、境界の明示、型やlintによる制約など理由が確認できれば必要な実装として維持する。必要性が未確認、または保守負担の削減根拠が不足するものはLOW confidenceの調査候補にとどめ、根拠が揃ったものだけを改善候補にする。
- 削除や置換の候補は、本体だけでなく参照元、test、fixture、設定、文字列参照やdynamic importによる動的利用まで確認する。確認しきれない場合はLOW confidenceの調査候補にする。

Finding形式では、Evidenceに参照元と利用実態の確認結果を、Riskに削減で失う可能性のある保証と維持すべき挙動を書く。
候補がなければ対応不要と報告し、件数を作らない。

## Dependenciesとmigrations

- core runtimeやframeworkのEOL、security fix終了、ecosystem非互換を確認する。
- removal予定のdeprecated APIを確認する。
- critical path上のarchive済みまたは長期停止dependencyを確認する。
- 同じ目的のdependency重複を確認する。
- monorepo内のversion pinningとlockfileの不整合を確認する。
- migration候補ごとに変更ファイル数とbehavioral riskを見積もる。

minor updateを網羅的に列挙しない。

## DXとtooling

- typecheck、lint、formatter、editorconfigなどの欠落または破損を確認する。
- testやdev serverの遅いstartup、watch mode不足、CI cache不足を確認する。
- READMEのsetup誤り、未記載env、`.env.example`不足を確認する。
- agentが作業するrepoでは、実態に合った`AGENTS.md`があるか確認する。
- error message、structured log、request IDなど、debug時の情報不足を確認する。

## Docs

欠落による具体的なコストがある文書だけをfindingにする。

- public APIの利用方法が分からない。
- 活発に変更されるarchitectureの判断理由を再構築できない。
- setupやAPI例が現行codeと食い違っている。

## Direction

壊れている箇所ではなく、次に作る価値のあるものを探す。
どの提案もrepo固有の根拠を持たなければならない。

- 同一themeのTODO、stub、未完feature flagなど、unfinished intentを探す。
- README、roadmap、PRDに書かれ、codeに存在しない機能を確認する。
- exportだけ、createだけなど、一方向だけ存在するsurfaceを確認する。
- 現architectureにより低コストで追加できる隣接機能を探す。
- 利用者が手作業している周辺作業をdocsやexampleから探す。

各提案には、誰のどの負担を減らすか、trade-off、概算effortを付ける。
選択後は、全面実装計画ではなくdesignまたはspike計画にしてもよい。

## Finding形式

```markdown
### [CATEGORY-NN] 命令形の短い題名

- Evidence：`path/file.ts:123`。確認した事実
- Impact：現在起きる失敗または支払っているコスト
- Effort：S（数時間）、M（1日程度）、L（複数日）
- Risk：LOW、MED、HIGHと、修正で壊れ得るもの
- Confidence：HIGH、MED、LOWと、未確認部分
- Fix sketch：工数を判断できる1文から3文の方針
```

LOW confidenceは修正計画ではなく、追加調査計画として扱う。

## 優先順位

`leverage = impact / effort` を基礎にし、confidenceと修正riskで割り引く。

同程度なら次の順で上げる。

1. 他の改善を可能にするverification baselineやcharacterization test
2. HIGH confidenceのsecurity finding
3. 検証方法が明確なfinding
4. 小さい変更で継続的な保守コストを下げるfinding

対応価値がない場合は棄却し、理由をindexへ残す。
