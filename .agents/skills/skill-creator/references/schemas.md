# JSON スキーマ

このドキュメントは、skill-creator で使用する JSON スキーマを定義します。

---

## evals.json

スキル用の eval を定義します。場所はスキルディレクトリ内の `evals/evals.json` です。

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's example prompt",
      "expected_output": "Description of expected result",
      "files": ["evals/files/sample1.pdf"],
      "expectations": [
        "The output includes X",
        "The skill used script Y"
      ]
    }
  ]
}
```

**フィールド:**
- `skill_name`: スキルの frontmatter と一致する名前
- `evals[].id`: 一意な整数 ID
- `evals[].prompt`: 実行するタスク
- `evals[].expected_output`: 成功条件の人間可読な説明
- `evals[].files`: 入力ファイルパスの任意リスト（skill ルートからの相対パス）
- `evals[].expectations`: 検証可能な文のリスト

---

## history.json

Improve モードでのバージョン進行を追跡します。場所は workspace ルートです。

```json
{
  "started_at": "2026-01-15T10:30:00Z",
  "skill_name": "pdf",
  "current_best": "v2",
  "iterations": [
    {
      "version": "v0",
      "parent": null,
      "expectation_pass_rate": 0.65,
      "grading_result": "baseline",
      "is_current_best": false
    },
    {
      "version": "v1",
      "parent": "v0",
      "expectation_pass_rate": 0.75,
      "grading_result": "won",
      "is_current_best": false
    },
    {
      "version": "v2",
      "parent": "v1",
      "expectation_pass_rate": 0.85,
      "grading_result": "won",
      "is_current_best": true
    }
  ]
}
```

**フィールド:**
- `started_at`: 改善開始時刻の ISO タイムスタンプ
- `skill_name`: 改善対象スキル名
- `current_best`: 最良結果のバージョン識別子
- `iterations[].version`: バージョン識別子（v0, v1, ...）
- `iterations[].parent`: このバージョンの派生元
- `iterations[].expectation_pass_rate`: grading での pass 率
- `iterations[].grading_result`: `"baseline"`, `"won"`, `"lost"`, `"tie"` のいずれか
- `iterations[].is_current_best`: 現在の best バージョンかどうか

---

## grading.json

grader エージェントの出力です。場所は `<run-dir>/grading.json` です。

```json
{
  "expectations": [
    {
      "text": "The output includes the name 'John Smith'",
      "passed": true,
      "evidence": "Found in transcript Step 3: 'Extracted names: John Smith, Sarah Johnson'"
    },
    {
      "text": "The spreadsheet has a SUM formula in cell B10",
      "passed": false,
      "evidence": "No spreadsheet was created. The output was a text file."
    }
  ],
  "summary": {
    "passed": 2,
    "failed": 1,
    "total": 3,
    "pass_rate": 0.67
  },
  "execution_metrics": {
    "tool_calls": {
      "Read": 5,
      "Write": 2,
      "Bash": 8
    },
    "total_tool_calls": 15,
    "total_steps": 6,
    "errors_encountered": 0,
    "output_chars": 12450,
    "transcript_chars": 3200
  },
  "timing": {
    "executor_duration_seconds": 165.0,
    "grader_duration_seconds": 26.0,
    "total_duration_seconds": 191.0
  },
  "claims": [
    {
      "claim": "The form has 12 fillable fields",
      "type": "factual",
      "verified": true,
      "evidence": "Counted 12 fields in field_info.json"
    }
  ],
  "user_notes_summary": {
    "uncertainties": ["Used 2023 data, may be stale"],
    "needs_review": [],
    "workarounds": ["Fell back to text overlay for non-fillable fields"]
  },
  "eval_feedback": {
    "suggestions": [
      {
        "assertion": "The output includes the name 'John Smith'",
        "reason": "A hallucinated document that mentions the name would also pass"
      }
    ],
    "overall": "Assertions check presence but not correctness."
  }
}
```

**フィールド:**
- `expectations[]`: 証拠付きで採点された expectation
- `summary`: pass/fail 件数の集計
- `execution_metrics`: ツール使用量と出力サイズ（executor の `metrics.json` 由来）
- `timing`: 実時間計測（`timing.json` 由来）
- `claims`: 出力から抽出・検証した主張
- `user_notes_summary`: executor がフラグした問題
- `eval_feedback`: （任意）eval 改善提案。grader が指摘すべき問題を見つけた場合のみ存在

---

## metrics.json

executor エージェントの出力です。場所は `<run-dir>/outputs/metrics.json` です。

```json
{
  "tool_calls": {
    "Read": 5,
    "Write": 2,
    "Bash": 8,
    "Edit": 1,
    "Glob": 2,
    "Grep": 0
  },
  "total_tool_calls": 18,
  "total_steps": 6,
  "files_created": ["filled_form.pdf", "field_values.json"],
  "errors_encountered": 0,
  "output_chars": 12450,
  "transcript_chars": 3200
}
```

**フィールド:**
- `tool_calls`: ツール種別ごとの回数
- `total_tool_calls`: 全ツール呼び出し回数の合計
- `total_steps`: 主要実行ステップ数
- `files_created`: 生成された出力ファイルの一覧
- `errors_encountered`: 実行中に発生したエラー件数
- `output_chars`: 出力ファイル総文字数
- `transcript_chars`: トランスクリプト文字数

---

## timing.json

実行 1 回分の実時間計測です。場所は `<run-dir>/timing.json` です。

**取得方法:** サブエージェントタスク完了時の通知には `total_tokens` と `duration_ms` が含まれます。これらは即座に保存してください。他所には永続化されず、後から復元できません。

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3,
  "executor_start": "2026-01-15T10:30:00Z",
  "executor_end": "2026-01-15T10:32:45Z",
  "executor_duration_seconds": 165.0,
  "grader_start": "2026-01-15T10:32:46Z",
  "grader_end": "2026-01-15T10:33:12Z",
  "grader_duration_seconds": 26.0
}
```

---

## benchmark.json

Benchmark モードの出力です。場所は `benchmarks/<timestamp>/benchmark.json` です。

```json
{
  "metadata": {
    "skill_name": "pdf",
    "skill_path": "/path/to/pdf",
    "executor_model": "claude-sonnet-4-20250514",
    "analyzer_model": "most-capable-model",
    "timestamp": "2026-01-15T10:30:00Z",
    "evals_run": [1, 2, 3],
    "runs_per_configuration": 3
  },

  "runs": [
    {
      "eval_id": 1,
      "eval_name": "Ocean",
      "configuration": "with_skill",
      "run_number": 1,
      "result": {
        "pass_rate": 0.85,
        "passed": 6,
        "failed": 1,
        "total": 7,
        "time_seconds": 42.5,
        "tokens": 3800,
        "tool_calls": 18,
        "errors": 0
      },
      "expectations": [
        {"text": "...", "passed": true, "evidence": "..."}
      ],
      "notes": [
        "Used 2023 data, may be stale",
        "Fell back to text overlay for non-fillable fields"
      ]
    }
  ],

  "run_summary": {
    "with_skill": {
      "pass_rate": {"mean": 0.85, "stddev": 0.05, "min": 0.80, "max": 0.90},
      "time_seconds": {"mean": 45.0, "stddev": 12.0, "min": 32.0, "max": 58.0},
      "tokens": {"mean": 3800, "stddev": 400, "min": 3200, "max": 4100}
    },
    "without_skill": {
      "pass_rate": {"mean": 0.35, "stddev": 0.08, "min": 0.28, "max": 0.45},
      "time_seconds": {"mean": 32.0, "stddev": 8.0, "min": 24.0, "max": 42.0},
      "tokens": {"mean": 2100, "stddev": 300, "min": 1800, "max": 2500}
    },
    "delta": {
      "pass_rate": "+0.50",
      "time_seconds": "+13.0",
      "tokens": "+1700"
    }
  },

  "notes": [
    "Assertion 'Output is a PDF file' passes 100% in both configurations - may not differentiate skill value",
    "Eval 3 shows high variance (50% ± 40%) - may be flaky or model-dependent",
    "Without-skill runs consistently fail on table extraction expectations",
    "Skill adds 13s average execution time but improves pass rate by 50%"
  ]
}
```

**フィールド:**
- `metadata`: ベンチマーク実行に関する情報
  - `skill_name`: スキル名
  - `timestamp`: ベンチマーク実行時刻
  - `evals_run`: 実行した eval 名または ID の一覧
  - `runs_per_configuration`: 各構成の実行回数（例: 3）
- `runs[]`: 個別実行結果
  - `eval_id`: 数値 eval ID
  - `eval_name`: 人間可読な eval 名（viewer でセクション見出しに使用）
  - `configuration`: 必ず `"with_skill"` または `"without_skill"`（viewer はこの文字列でグルーピングと色分けを行う）
  - `run_number`: 実行番号の整数（1, 2, 3...）
  - `result`: `pass_rate`, `passed`, `total`, `time_seconds`, `tokens`, `errors` を持つネストオブジェクト
- `run_summary`: 構成ごとの統計集計
  - `with_skill` / `without_skill`: それぞれ `pass_rate`, `time_seconds`, `tokens` オブジェクトを持ち、`mean` と `stddev` を含む
  - `delta`: `"+0.50"`, `"+13.0"`, `"+1700"` のような差分文字列
- `notes`: analyzer の自由記述観察

**重要:** viewer はこれらのフィールド名を厳密に参照します。`configuration` ではなく `config` を使ったり、`pass_rate` を `result` の外に置いたりすると、viewer で空値/ゼロ表示になります。`benchmark.json` を手動生成する際は必ず本スキーマを参照してください。

---

## comparison.json

blind comparator の出力です。場所は `<grading-dir>/comparison-N.json` です。

```json
{
  "winner": "A",
  "reasoning": "Output A provides a complete solution with proper formatting and all required fields. Output B is missing the date field and has formatting inconsistencies.",
  "rubric": {
    "A": {
      "content": {
        "correctness": 5,
        "completeness": 5,
        "accuracy": 4
      },
      "structure": {
        "organization": 4,
        "formatting": 5,
        "usability": 4
      },
      "content_score": 4.7,
      "structure_score": 4.3,
      "overall_score": 9.0
    },
    "B": {
      "content": {
        "correctness": 3,
        "completeness": 2,
        "accuracy": 3
      },
      "structure": {
        "organization": 3,
        "formatting": 2,
        "usability": 3
      },
      "content_score": 2.7,
      "structure_score": 2.7,
      "overall_score": 5.4
    }
  },
  "output_quality": {
    "A": {
      "score": 9,
      "strengths": ["Complete solution", "Well-formatted", "All fields present"],
      "weaknesses": ["Minor style inconsistency in header"]
    },
    "B": {
      "score": 5,
      "strengths": ["Readable output", "Correct basic structure"],
      "weaknesses": ["Missing date field", "Formatting inconsistencies", "Partial data extraction"]
    }
  },
  "expectation_results": {
    "A": {
      "passed": 4,
      "total": 5,
      "pass_rate": 0.80,
      "details": [
        {"text": "Output includes name", "passed": true}
      ]
    },
    "B": {
      "passed": 3,
      "total": 5,
      "pass_rate": 0.60,
      "details": [
        {"text": "Output includes name", "passed": true}
      ]
    }
  }
}
```

---

## analysis.json

post-hoc analyzer の出力です。場所は `<grading-dir>/analysis.json` です。

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
    "Included validation script that caught formatting errors"
  ],
  "loser_weaknesses": [
    "Vague instruction 'process the document appropriately' led to inconsistent behavior",
    "No script for validation, agent had to improvise"
  ],
  "instruction_following": {
    "winner": {
      "score": 9,
      "issues": ["Minor: skipped optional logging step"]
    },
    "loser": {
      "score": 6,
      "issues": [
        "Did not use the skill's formatting template",
        "Invented own approach instead of following step 3"
      ]
    }
  },
  "improvement_suggestions": [
    {
      "priority": "high",
      "category": "instructions",
      "suggestion": "Replace 'process the document appropriately' with explicit steps",
      "expected_impact": "Would eliminate ambiguity that caused inconsistent behavior"
    }
  ],
  "transcript_insights": {
    "winner_execution_pattern": "Read skill -> Followed 5-step process -> Used validation script",
    "loser_execution_pattern": "Read skill -> Unclear on approach -> Tried 3 different methods"
  }
}
```
