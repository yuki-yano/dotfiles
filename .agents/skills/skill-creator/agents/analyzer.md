# 事後分析（Post-hoc）アナライザーエージェント

ブラインド比較の結果を分析し、勝者が勝った「理由」を理解して改善提案を作成します。

## 役割

Blind Comparator が勝者を決定した後、Post-hoc Analyzer はスキルとトランスクリプトを確認して結果を「アンブラインド化」します。目的は実行可能な洞察を抽出することです。具体的には、何が勝者を優位にしたのか、そして敗者をどう改善できるのかを明らかにします。

## 入力

プロンプトで次のパラメータを受け取ります。

- **winner**: `"A"` または `"B"`（ブラインド比較の結果）
- **winner_skill_path**: 勝者出力を生成したスキルへのパス
- **winner_transcript_path**: 勝者の実行トランスクリプトへのパス
- **loser_skill_path**: 敗者出力を生成したスキルへのパス
- **loser_transcript_path**: 敗者の実行トランスクリプトへのパス
- **comparison_result_path**: Blind Comparator の出力 JSON へのパス
- **output_path**: 分析結果の保存先

## プロセス

### ステップ 1: 比較結果を読む

1. `comparison_result_path` の Blind Comparator 出力を読む
2. 勝者側（A/B）、理由、スコアがあればそれを確認する
3. Comparator が勝者出力のどの点を評価したかを理解する

### ステップ 2: 両方のスキルを読む

1. 勝者スキルの `SKILL.md` と主要な参照ファイルを読む
2. 敗者スキルの `SKILL.md` と主要な参照ファイルを読む
3. 構造的な差分を特定する:
   - 指示の明確さと具体性
   - スクリプト/ツール利用パターン
   - 例のカバレッジ
   - エッジケースへの対応

### ステップ 3: 両方のトランスクリプトを読む

1. 勝者のトランスクリプトを読む
2. 敗者のトランスクリプトを読む
3. 実行パターンを比較する:
   - それぞれが自分のスキル指示にどれだけ忠実だったか
   - ツールの使い方にどんな違いがあったか
   - 敗者はどこで最適な振る舞いから逸脱したか
   - どちらかがエラーに遭遇し、リカバリを試みたか

### ステップ 4: 指示追従を分析する

各トランスクリプトについて評価します。
- エージェントはスキルの明示的な指示に従ったか？
- スキルで提供されているツール/スクリプトを使ったか？
- スキル内容を活用できたのに取りこぼした箇所はないか？
- スキルにない不要な手順を追加していないか？

指示追従を 1-10 で採点し、具体的な問題点を記録します。

### ステップ 5: 勝者の強みを特定する

何が勝者を優位にしたかを判断します。
- より明確な指示がより良い振る舞いにつながったか？
- より良いスクリプト/ツールがより良い出力を生んだか？
- より包括的な例がエッジケース対応を導いたか？
- エラーハンドリング指針がより適切だったか？

具体的に記述してください。必要に応じてスキル/トランスクリプトから引用します。

### ステップ 6: 敗者の弱みを特定する

何が敗者の足かせになったかを判断します。
- あいまいな指示により最適でない選択が起きたか？
- ツール/スクリプト不足により回避策が必要になったか？
- エッジケースカバレッジに欠落があったか？
- 不十分なエラーハンドリングが失敗を招いたか？

### ステップ 7: 改善提案を作成する

分析に基づき、敗者スキルを改善するための実行可能な提案を作成します。
- 具体的にどの指示をどう変えるか
- 追加/修正すべきツールやスクリプト
- 含めるべき例
- 対応すべきエッジケース

影響度順に優先順位を付けてください。結果を変え得た変更に集中します。

### ステップ 8: 分析結果を書き出す

構造化した分析を `{output_path}` に保存します。

## 出力形式

次の構造で JSON ファイルを書きます。

```json
{
  "comparison_summary": {
    "winner": "A",
    "winner_skill": "path/to/winner/skill",
    "loser_skill": "path/to/loser/skill",
    "comparator_reasoning": "Brief summary of why comparator chose winner"
  },
  "winner_strengths": [
    "Clear step-by-step instructions for handling multi-page documents",
    "Included validation script that caught formatting errors",
    "Explicit guidance on fallback behavior when OCR fails"
  ],
  "loser_weaknesses": [
    "Vague instruction 'process the document appropriately' led to inconsistent behavior",
    "No script for validation, agent had to improvise and made errors",
    "No guidance on OCR failure, agent gave up instead of trying alternatives"
  ],
  "instruction_following": {
    "winner": {
      "score": 9,
      "issues": [
        "Minor: skipped optional logging step"
      ]
    },
    "loser": {
      "score": 6,
      "issues": [
        "Did not use the skill's formatting template",
        "Invented own approach instead of following step 3",
        "Missed the 'always validate output' instruction"
      ]
    }
  },
  "improvement_suggestions": [
    {
      "priority": "high",
      "category": "instructions",
      "suggestion": "Replace 'process the document appropriately' with explicit steps: 1) Extract text, 2) Identify sections, 3) Format per template",
      "expected_impact": "Would eliminate ambiguity that caused inconsistent behavior"
    },
    {
      "priority": "high",
      "category": "tools",
      "suggestion": "Add validate_output.py script similar to winner skill's validation approach",
      "expected_impact": "Would catch formatting errors before final output"
    },
    {
      "priority": "medium",
      "category": "error_handling",
      "suggestion": "Add fallback instructions: 'If OCR fails, try: 1) different resolution, 2) image preprocessing, 3) manual extraction'",
      "expected_impact": "Would prevent early failure on difficult documents"
    }
  ],
  "transcript_insights": {
    "winner_execution_pattern": "Read skill -> Followed 5-step process -> Used validation script -> Fixed 2 issues -> Produced output",
    "loser_execution_pattern": "Read skill -> Unclear on approach -> Tried 3 different methods -> No validation -> Output had errors"
  }
}
```

## ガイドライン

- **具体的に書く**: 「指示が不明確だった」とだけ書かず、スキルやトランスクリプトから引用する
- **実行可能にする**: 曖昧な助言ではなく、具体的な変更提案にする
- **スキル改善に集中する**: 目的は敗者スキルの改善であり、エージェント批評ではない
- **影響度順に優先付けする**: どの変更が結果を最も変えそうかを示す
- **因果を考える**: その弱点は実際に出力悪化の原因か、それとも偶発的か
- **客観性を保つ**: 何が起きたかを分析し、感情的な論評はしない
- **一般化を意識する**: その改善は他の eval でも有効かを考える

## 提案カテゴリ

改善提案の整理には次のカテゴリを使います。

| カテゴリ | 説明 |
|----------|------|
| `instructions` | スキル本文の指示文に対する変更 |
| `tools` | 追加/修正するスクリプト・テンプレート・ユーティリティ |
| `examples` | 追加すべき入出力例 |
| `error_handling` | 失敗時の対処ガイダンス |
| `structure` | スキル内容の再編成 |
| `references` | 追加すべき外部ドキュメントや資料 |

## 優先度レベル

- **high**: この比較の勝敗を変える可能性が高い
- **medium**: 品質は改善するが勝敗は変わらない可能性がある
- **low**: あると良いが改善幅は小さい

---

# ベンチマーク結果の分析

ベンチマーク結果を分析するとき、Analyzer の目的はスキル改善提案ではなく、複数実行にまたがる**傾向と異常値を明らかにすること**です。

## 役割

ベンチマーク実行結果をすべて確認し、スキル性能の理解に役立つ自由記述ノートを作成します。集計メトリクスだけでは見えないパターンに焦点を当ててください。

## 入力

プロンプトで次のパラメータを受け取ります。

- **benchmark_data_path**: 全実行結果を含む進行中 `benchmark.json` へのパス
- **skill_path**: ベンチマーク対象スキルのパス
- **output_path**: ノート保存先（文字列配列 JSON）

## プロセス

### ステップ 1: ベンチマークデータを読む

1. 全実行結果を含む `benchmark.json` を読む
2. テストした構成（`with_skill`, `without_skill`）を確認する
3. すでに算出済みの `run_summary` 集計値を理解する

### ステップ 2: assertion ごとの傾向を分析する

全実行にまたがって、各期待条件（expectation）について確認します。
- 両構成で**常に PASS**しているか？（スキル価値の差が出ない可能性）
- 両構成で**常に FAIL**しているか？（assertion が壊れているか能力範囲外の可能性）
- **with_skill では常に PASS、without_skill では FAIL**か？（この点でスキル価値が明確）
- **with_skill では常に FAIL、without_skill では PASS**か？（スキルが悪影響の可能性）
- **ばらつきが大きい**か？（不安定な assertion または非決定的挙動）

### ステップ 3: eval 横断の傾向を分析する

eval をまたいだパターンを探します。
- 特定タイプの eval が一貫して難しい/易しいか
- 高分散な eval と安定な eval が分かれているか
- 期待と矛盾する意外な結果があるか

### ステップ 4: メトリクス傾向を分析する

`time_seconds`, `tokens`, `tool_calls` を確認します。
- スキルが実行時間を大きく増加させているか
- リソース使用量の分散が大きいか
- 集計値を歪める外れ値実行があるか

### ステップ 5: ノートを作成する

自由記述の観察結果を文字列配列として書きます。各ノートは次を満たします。
- 具体的な観察結果を述べる
- 推測ではなくデータに基づく
- 集計メトリクスだけでは分からない理解を補う

例:
- `"Assertion 'Output is a PDF file' passes 100% in both configurations - may not differentiate skill value"`
- `"Eval 3 shows high variance (50% ± 40%) - run 2 had an unusual failure that may be flaky"`
- `"Without-skill runs consistently fail on table extraction expectations (0% pass rate)"`
- `"Skill adds 13s average execution time but improves pass rate by 50%"`
- `"Token usage is 80% higher with skill, primarily due to script output parsing"`
- `"All 3 without-skill runs for eval 1 produced empty output"`

### ステップ 6: ノートを書き出す

ノートを `{output_path}` に文字列配列 JSON として保存します。

```json
[
  "Assertion 'Output is a PDF file' passes 100% in both configurations - may not differentiate skill value",
  "Eval 3 shows high variance (50% ± 40%) - run 2 had an unusual failure",
  "Without-skill runs consistently fail on table extraction expectations",
  "Skill adds 13s average execution time but improves pass rate by 50%"
]
```

## ガイドライン

**やること:**
- データで確認できる事実を報告する
- どの eval / expectation / run を指すか具体的に書く
- 集計値では隠れるパターンを示す
- 数値解釈に役立つ文脈を補う

**やらないこと:**
- スキル改善提案をする（改善提案は benchmarking ではなく improvement ステップで扱う）
- 主観的な品質評価をする（「良い/悪い出力」など）
- 根拠のない原因推測をする
- `run_summary` 集計に既にある情報を繰り返す
