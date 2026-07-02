---
name: ultracode-codex
description: Use when the user explicitly asks Codex to work in ultracode style, use many agents, run parallel or staged subagents, perform adversarial verification, or handle a broad high-risk task with deep multi-agent review.
metadata:
  short-description: Codex で ultracode 風の多段 agent workflow を実行する
---

# Ultracode Codex

Codex で Claude Code の ultracode に近い進め方をするための明示起動型 workflow です。
目的は agent 数を増やすことではなく、独立調査、分割実行、敵対的検証、統合判断を段階的に組み合わせて、単一 agent の思い込みや検証漏れを減らすことです。

## 前提

- 日本語でユーザーに説明します。
- `spawn_agent` は、ユーザーがこの skill、ultracode、subagent、parallel agent、敵対 agent、多数 agent などを明示している場合だけ使います。
- `spawn_agent` が使えない環境では、この skill の多 agent phase は実行できません。main thread だけで同等に進めたとは言わず、必要 tool がないことを伝えます。
- 大量出力の検索、集計、ログ解析、ファイル横断分析は context-mode を優先します。
- 明示的な commit 指示がない限り commit しません。
- destructive な git 操作、強制 push、差分巻き戻しはユーザー確認なしに行いません。

## 使うべきタスク

- リポジトリ横断のバグ調査、セキュリティ監査、認可漏れ確認、性能監査。
- 大きなリファクタ、移行、複数モジュールにまたがる実装。
- 仕様、設計、計画、調査結果を敵対的に検証したいとき。
- 「50 agent くらい使って」「ultracode っぽく」「多段 agent で」「反対意見 agent も入れて」のような明示依頼。

## 使わないタスク

- 1 ファイルの小修正、短い質問、単純なコマンド確認。
- 分割単位が曖昧で、先に調査しても agent に渡す独立作業を作れない場合。
- 競合する書き込み範囲を複数 agent に同時編集させる必要がある場合。
- ユーザーが subagent 利用を明示していない通常タスク。

## Agent Budget

最初に task size と risk を見積もり、予算を宣言します。
ユーザーが明示した上限がある場合はそれを優先します。

| Mode | 総 agent 目安 | 用途 |
| --- | ---: | --- |
| `light` | 1-10 | 小さめだが独立検証を入れたい調査、実装、レビュー |
| `standard` | 11-30 | 通常の ultracode 風実行。調査、実装、skeptic、verifier を分ける作業 |
| `wide` | 31-60 | 複数領域の横断調査、広めのレビュー、分割可能な中規模 fan-out |
| `massive` | 61-100 | endpoint、claim、module、file group などに自然分割できる大規模作業 |

`massive` でも 100 agent を一度に起動しません。
小さな wave に分け、各 wave の結果を統合してから次の wave を決めます。
同時実行は原則 3-8 agent から始め、広げる価値が確認できた場合だけ増やします。

## Mode Selection

mode は完全に無言で決めません。
この skill が明示起動されたら、main agent が task size、risk、分割可能性を見積もり、最初に選んだ mode と理由を短く宣言します。

優先順位:

1. ユーザーが mode または agent 上限を明示した場合は、それを優先します。
2. 明示がない場合は、main agent が `light`、`standard`、`wide`、`massive` から選びます。
3. 実行中に追加 wave が必要だと分かった場合は、残 budget と増やす理由を説明してから拡張します。

選択基準:

- `light`: 影響範囲が狭いが、独立した skeptic または verifier が成果を変えうる。
- `standard`: 調査、実装、敵対的検証、最終検証を分ける価値がある。
- `wide`: 対象領域が複数あり、read-only 調査や検証を自然に fan-out できる。
- `massive`: 分割単位が数十個あり、各 agent の出力を構造化して統合できる。

`massive` を選ぶときは特に、最初から 61-100 agent を使い切る前提にしません。
小さい slice で有効性を確認し、追加 wave が Done 判定を変える場合だけ増やします。

## Workflow

### 1. Scope

最初に次を短く固定します。

- 目的。
- 対象範囲。
- 除外範囲。
- 成功条件。
- 失敗条件。
- 使う agent budget。
- 予定する phase。

設計書や計画書を作る場合は DoD を必ず含めます。

DoD:

- [ ] 機能完了条件: ユーザーが求めた成果が対象範囲内で完了している。
- [ ] テスト完了条件: 自動テスト、手動確認、または根拠付き検証のどれで完了判定するかが明記されている。
- [ ] 運用反映条件: 変更の反映方法、残リスク、次に人間が判断すべき点が明記されている。

### 2. Planner

main agent が分割軸を作ります。
ここではまだ大量 agent を起動しません。
分割単位は、後で統合できる粒度にします。

よい分割単位:

- directory、module、endpoint、test suite、claim、issue、dependency、migration target。

悪い分割単位:

- 「全部調べる」「品質を見る」「いい感じに直す」のような抽象作業。

### 3. Recon Wave

必要なら read-only の explorer agent を 2-8 件起動します。
各 agent には独立した調査範囲を渡し、編集させません。
main agent は待っている間に、非重複のローカル調査やテスト環境確認を進めます。

Recon agent への指示には必ず含めます。

```text
あなたは read-only 調査 agent です。
編集、commit、依存追加、破壊的操作は禁止です。
担当範囲だけを調べ、事実と推測を分けてください。
根拠ファイルと行番号を付けてください。
最後に JSON 風の短い構造で返してください。
```

### 4. Fan-out Work Wave

実装が必要な場合だけ worker agent を使います。
複数 worker を使うときは書き込み範囲を分けます。
同じファイルを複数 agent に編集させません。

worker agent には次を明示します。

- 担当範囲。
- 書き込み可能な path。
- 触ってはいけない path。
- 完了条件。
- 実行すべき検証。
- 変更したファイル一覧を最終回答に含めること。

main agent は返ってきた差分を必ずレビューし、統合します。
subagent の成果を無検証で採用しません。

### 5. Adversarial Review Wave

大きいタスク、正しさが重要なタスク、実装を伴うタスクでは敵対的検証を入れます。
この phase は原則 read-only です。

敵対 agent の役割:

- main agent や worker の結論が間違っている前提で反例を探す。
- 仕様違反、未検証、過剰実装、互換性を壊す変更、セキュリティや運用上の穴を探す。
- 「根拠がない成功主張」を検出する。
- false positive の可能性も書く。

敵対 agent への指示テンプレート:

```text
あなたは敵対的 reviewer です。
目的は成果を褒めることではなく、採用前に止めるべき問題を探すことです。
編集は禁止です。
次の成果物が間違っている、危険である、または未検証である前提で調べてください。
各 finding には severity、根拠、再現条件、false positive の可能性、推奨判断を付けてください。
証拠が弱い指摘は speculation と明記してください。
```

### 6. Verification Wave

必要に応じて verifier agent を起動します。
verifier はテスト、再現手順、仕様照合、差分レビューのいずれかに絞ります。
verifier は実装の代替ではありません。

verification の観点:

- 自動テストが要求範囲を覆っているか。
- 変更前に再現した問題が変更後に解消したか。
- 仕様や AGENTS.md のルールに反していないか。
- 失敗時に何が未確定として残るか。

### 7. Integrator

main agent が統合判断をします。
agent の多数決で決めません。
根拠、リスク、テスト結果、ユーザーの目的に照らして採否を決めます。

統合時に必ず分類します。

- 採用する finding。
- 却下する finding と理由。
- 未確定で残す finding。
- 追加作業が必要な finding。

## Subagent Output Schema

subagent には長文の自由回答を避けさせ、次の形で返させます。

```json
{
  "scope": "担当範囲",
  "summary": "1-3文の結論",
  "findings": [
    {
      "severity": "blocker|high|medium|low|info",
      "claim": "指摘内容",
      "evidence": ["path:line"],
      "confidence": "high|medium|low",
      "false_positive_risk": "high|medium|low",
      "recommended_action": "fix|verify|accept_risk|ignore"
    }
  ],
  "tested": ["実行した確認"],
  "not_checked": ["未確認事項"]
}
```

## Massive Mode Pattern

100 前後まで agent を使う場合は、順番に wave を消費します。

例:

1. Planner: 1-2 agent。
2. Recon: 5-15 agent。
3. Fan-out: 20-55 agent。
4. Adversarial review: 10-20 agent。
5. Verification: 5-12 agent。
6. Integration: main agent、必要なら 1-2 read-only reviewer。

各 wave の後に、main agent は次を行います。

- 重複をまとめる。
- 次 wave に渡す単位を減らす。
- 以降の agent 起動が成果を変える見込みを判断する。
- agent budget の残りを更新する。

追加 wave が Done 判定を変えないと判断したら、予算が残っていても止めます。

## Common Mistakes

- 最初から 100 agent を並べる。統合不能になりやすいので wave に分けます。
- 敵対 agent に編集させる。原則 read-only にして、採否は main agent が決めます。
- agent の結論を多数決で採用する。証拠と再現性で判断します。
- 同じファイルを複数 worker に編集させる。書き込み範囲を分けます。
- subagent の長文をそのままユーザーに流す。要約、採否、残リスクに統合します。
- 「完了」と言う前に検証結果を確認しない。検証できていない場合は未検証と明記します。

## Final Report

最終回答は簡潔にし、次を含めます。

- 実行した phase と agent budget の実績。
- 変更したファイル、または調査対象。
- 採用した重要 finding。
- 却下した重要 finding と理由。
- 実行した検証。
- 未確定リスク。
