---
name: skill-creator
description: 新しいスキルを作成し、既存スキルを修正・改善し、スキル性能を測定します。ユーザーがスキルをゼロから作りたい、既存スキルを更新・最適化したい、評価を実行してスキルを検証したい、分散分析付きでスキル性能をベンチマークしたい、またはトリガー精度向上のためにスキル説明文を最適化したい場合に使用します。
---

# Skill Creator

新しいスキルを作成し、反復的に改善していくためのスキルです。

高レベルでは、スキル作成プロセスは次のように進みます。

- スキルに何をさせたいかと、どう実現するかを大まかに決める
- スキルのドラフトを書く
- いくつかのテストプロンプトを作成し、スキルにアクセス可能なエージェント（Claude/Codex）で実行する
- ユーザーが結果を定性的・定量的の両面で評価できるよう支援する
  - 実行がバックグラウンドで進んでいる間に、定量評価がなければドラフトする（すでにあればそのまま使うか、必要に応じて修正する）。その後、ユーザーに説明する（既存の評価がある場合は、その既存評価を説明する）
  - `eval-viewer/generate_review.py` スクリプトを使って結果をユーザーに提示し、定量メトリクスも確認できるようにする
- ユーザーの結果評価からのフィードバックに基づいてスキルを書き直す（定量ベンチマークで明らかな欠陥が見えた場合も反映する）
- 納得できるまで繰り返す
- テストセットを拡張し、より大きな規模で再試行する

このスキルを使うときのあなたの仕事は、ユーザーがこのプロセスのどこにいるかを見極め、各段階を前進させることです。たとえばユーザーが「X 向けのスキルを作りたい」と言ったなら、意図の絞り込み、ドラフト作成、テストケース作成、評価方法の設計、すべてのプロンプト実行、そして反復まで支援できます。

一方で、ユーザーがすでにスキルのドラフトを持っている場合もあります。そのときは、ループの評価/反復フェーズから直接始められます。

もちろん、常に柔軟に対応してください。ユーザーが「大量の評価は不要だから、まず一緒に感覚的に進めたい」と言うなら、その進め方で構いません。

そしてスキル完成後には（ただし順序は柔軟で構いません）、スキルのトリガーを最適化するために、専用スクリプトで description 改善を実行できます。

大丈夫ですね？ では進めましょう。

## ユーザーとのコミュニケーション

skill creator は、コーディング用語への習熟度が幅広い人に使われる可能性があります。最近ようやく広まり始めた流れですが、Claude の力に触発されて配管工がターミナルを開き、親や祖父母が「npm のインストール方法」を検索するような状況も起きています。一方で、ユーザーの大半は比較的コンピューターに慣れているはずです。

そのため、文脈の手がかりに注意して、伝え方を調整してください。デフォルトの感覚としては次のとおりです。

- 「evaluation」や「benchmark」は境界線上だが、使ってよい
- 「JSON」や「assertion」は、説明なしで使う前に、ユーザーがそれらを理解している明確な手がかりを確認したい

迷った場合に用語を短く説明するのは問題ありませんし、ユーザーが理解できるか不確かなときは、短い定義を添えて明確化して構いません。

---

## スキルを作成する

### 意図を把握する

まずはユーザーの意図を理解してください。現在の会話に、すでにユーザーがスキル化したいワークフローが含まれている場合があります（例: 「これをスキルにして」）。その場合はまず会話履歴から、使ったツール、手順の順序、ユーザーが行った修正、観測された入出力形式を抽出します。足りない部分はユーザーに補ってもらい、次のステップへ進む前に確認を取ってください。

1. このスキルによって Claude に何をできるようにしたいか？
2. どのようなときにこのスキルをトリガーすべきか？（どんなユーザー表現/文脈か）
3. 期待される出力形式は何か？
4. スキルが機能することを検証するためにテストケースを設定するべきか？ 客観的に検証可能な出力（ファイル変換、データ抽出、コード生成、固定ワークフローステップ）のスキルはテストケースの恩恵が大きいです。主観的な出力（文体、アート）のスキルは不要なことが多いです。スキル種別に応じた適切なデフォルトを提案しつつ、最終判断はユーザーに委ねてください。

### ヒアリングと調査

エッジケース、入出力形式、サンプルファイル、成功基準、依存関係について先回りして質問してください。この部分が固まるまではテストプロンプトを書かないでください。

利用可能な MCP を確認し、調査に有用なら（ドキュメント検索、類似スキル探索、ベストプラクティス確認など）、可能であればサブエージェントで並列調査し、無理ならインラインで調査してください。ユーザーの負担を減らせるよう、必要な文脈を準備して臨んでください。

### SKILL.md を書く

ユーザーヒアリングに基づいて、次の要素を埋めてください。

- **name**: スキル識別子
- **description**: いつトリガーし、何をするか。これは主要なトリガー機構です。スキルが何をするかに加え、いつ使うべきかの具体的文脈を含めてください。「いつ使うか」の情報は本文ではなくここに入れます。注: 現在 Claude はスキルを「アンダートリガー」しがちです（有用でも使わない）。これを補うため、description はやや「押しの強い」書き方にしてください。たとえば「How to build a simple fast dashboard to display internal Anthropic data.」ではなく、「How to build a simple fast dashboard to display internal Anthropic data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'」のように書くとよいです。
- **compatibility**: 必要ツール、依存関係（任意。必要になることはまれ）
- **the rest of the skill :)**

### スキル記述ガイド

#### スキルの構造

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

#### 段階的開示

スキルは 3 段階の読み込みシステムを使います。
1. **Metadata** (name + description) - 常にコンテキストに入る（約 100 語）
2. **SKILL.md body** - スキルがトリガーされるたびにコンテキストへ入る（理想は 500 行未満）
3. **Bundled resources** - 必要時に読み込む（上限なし。スクリプトは読み込まずに実行可能）

これらの語数は目安であり、必要なら長くして構いません。

**重要なパターン:**
- SKILL.md は 500 行未満を維持する。上限に近づく場合は階層を追加し、スキルを使うモデルが次にどこを読めばよいかを明確に示す
- SKILL.md から参照ファイルを明確に示し、いつ読むべきかのガイダンスを付ける
- 大きな参照ファイル（>300 行）には目次を含める

**ドメイン整理**: スキルが複数ドメイン/フレームワークをサポートする場合は、バリアントごとに整理します。
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude は関連する参照ファイルだけを読みます。

#### 驚きを最小化する原則

言うまでもありませんが、スキルにはマルウェア、エクスプロイトコード、またはシステムセキュリティを損なう可能性のある内容を含めてはいけません。スキルの内容は、説明された意図の範囲でユーザーを驚かせるものであってはいけません。誤解を招くスキルや、未承認アクセス・データ持ち出し・その他の悪意ある行為を助長するためのスキル作成要求には応じないでください。ただし「XYZ としてロールプレイする」のようなものは問題ありません。

#### 記述パターン

指示は命令形を優先して書いてください。

**出力形式の定義** - たとえば次のように書けます。
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**例のパターン** - 例を含めるのは有用です。次のように書けます（ただし例に "Input" と "Output" がある場合は、少し崩しても構いません）。
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### 文体

過剰で古びた MUST の連打よりも、なぜ重要なのかをモデルに説明することを試みてください。心の理論を意識し、特定例に過度に狭く寄せず、一般化されたスキルを目指してください。まずドラフトを書き、少し時間をおいて新鮮な目で見直して改善してください。

### テストケース

スキルのドラフトを書いたら、現実的なテストプロンプトを 2〜3 個作ってください。実ユーザーが実際に言いそうなものにします。ユーザーには次のように共有してください（文言は完全一致でなくて構いません）: 「試したいテストケースをいくつか用意しました。これでよいですか、それとも追加しますか？」 その後に実行します。

テストケースは `evals/evals.json` に保存します。まだ assertion は書かず、まずはプロンプトだけを書いてください。assertion は次のステップで、実行中にドラフトします。

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

完全なスキーマ（後で追加する `assertions` フィールドを含む）は `references/schemas.md` を参照してください。

## テストケースの実行と評価

このセクションは一連の連続した手順です。途中で止めないでください。`/skill-test` や他のテスト用スキルは使わないでください。

結果はスキルディレクトリの兄弟として `<skill-name>-workspace/` に置きます。workspace 内では、イテレーション単位（`iteration-1/`, `iteration-2/` など）で整理し、その中で各テストケースにディレクトリ（`eval-0/`, `eval-1/` など）を割り当てます。これらを最初にすべて作るのではなく、進行に合わせて都度作成してください。

### Step 1: 同一ターンで全実行（with-skill と baseline）を起動する

各テストケースについて、同一ターンで 2 つのサブエージェントを起動します。1 つはスキルあり、もう 1 つはスキルなしです。これは重要です。with-skill を先に全部実行して、後で baseline を回収する進め方はしないでください。すべて同時に起動し、完了時刻をそろえます。

**With-skill run:**

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what the user cares about — e.g., "the .docx file", "the final CSV">
```

**Baseline run**（同一プロンプト。ただし baseline は文脈依存です）:
- **Creating a new skill**: スキルは一切使わない。同じプロンプトで skill path なし、保存先は `without_skill/outputs/`。
- **Improving an existing skill**: 旧バージョンを使う。編集前にスキルをスナップショットする（`cp -r <skill-path> <workspace>/skill-snapshot/`）。その後、baseline サブエージェントはこのスナップショットを参照させる。保存先は `old_skill/outputs/`。

各テストケースごとに `eval_metadata.json` を書きます（assertion は当面空でよい）。各 eval には、単なる "eval-0" ではなく、何を検証するかが分かる説明的な名前を付けてください。ディレクトリ名にもこの名前を使います。このイテレーションで新規または変更した eval プロンプトを使う場合、各新規 eval ディレクトリにこれらのファイルを作成してください。前回から引き継がれている前提にしないでください。

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

### Step 2: 実行中に assertion をドラフトする

実行完了を待つだけにしないでください。この時間を有効活用できます。各テストケースの定量 assertion をドラフトし、ユーザーに説明してください。`evals/evals.json` に assertion が既にある場合は、それらを見直して何を検証しているかを説明してください。

良い assertion は客観的に検証可能で、説明的な名前を持ちます。ベンチマークビューアで見たとき、結果を流し見する人でも何を検証しているか即座に分かるべきです。主観的スキル（文体、デザイン品質）は定性的評価の方が適切なので、人間の判断が必要なものに assertion を無理に当てはめないでください。

assertion をドラフトしたら `eval_metadata.json` と `evals/evals.json` を更新します。また、ビューアでユーザーに何が見えるかも説明してください。定性的な出力と定量ベンチマークの両方を含めます。

### Step 3: 実行完了ごとにタイミングデータを記録する

各サブエージェントタスクが完了すると、`total_tokens` と `duration_ms` を含む通知を受け取ります。このデータは即座に実行ディレクトリの `timing.json` に保存してください。

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

このデータを取得できる機会はここだけです。タスク通知経由で届き、他には永続化されません。後でまとめて処理しようとせず、通知が来るたびに処理してください。

### Step 4: 採点・集計・ビューア起動

すべての実行が完了したら:

1. **各実行を採点する** — サブエージェント grader を起動（またはインラインで採点）し、`agents/grader.md` を読んで各 assertion を出力に対して評価します。結果は各実行ディレクトリの `grading.json` に保存します。grading.json の expectations 配列は `text`、`passed`、`evidence` フィールドを必ず使ってください（`name`/`met`/`details` などの別名は不可）。ビューアはこれらの正確なフィールド名に依存します。プログラムで検証可能な assertion は目視判定せず、スクリプトを書いて実行してください。スクリプトの方が速く、信頼性が高く、イテレーション間で再利用できます。

2. **ベンチマークへ集計する** — skill-creator ディレクトリから集計スクリプトを実行します。
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
   これにより `benchmark.json` と `benchmark.md` が生成されます。各構成について、pass_rate、時間、トークンが mean ± stddev と delta 付きで出力されます。benchmark.json を手動生成する場合は、ビューアが期待する正確なスキーマを `references/schemas.md` で確認してください。
Put each with_skill version before its baseline counterpart.

3. **分析者視点で確認する** — ベンチマークデータを読み、集計統計だけでは見えにくいパターンを抽出します。着目点は `agents/analyzer.md`（"Analyzing Benchmark Results" セクション）を参照してください。たとえば、スキル有無に関係なく常に通る assertion（識別力不足）、分散の大きい eval（フレーキーの可能性）、時間/トークンのトレードオフなどです。

4. **ビューアを起動する**。定性的出力と定量データの両方を表示します。
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   VIEWER_PID=$!
   ```
   iteration 2+ では `--previous-workspace <workspace>/iteration-<N-1>` も渡してください。

   **Cowork / headless environments:** `webbrowser.open()` が使えない、または表示環境がない場合、サーバー起動ではなく `--static <output_path>` でスタンドアロン HTML を出力してください。ユーザーが "Submit All Reviews" を押すと `feedback.json` がダウンロードされます。ダウンロード後、次イテレーションで取り込めるよう `feedback.json` を workspace ディレクトリへコピーしてください。

Note: please use generate_review.py to create the viewer; there's no need to write custom HTML.

5. **ユーザーに伝える**。たとえば次のように: "結果をブラウザで開きました。タブは 2 つあります。'Outputs' では各テストケースを確認してフィードバックできます。'Benchmark' では定量比較を見られます。確認が終わったら、ここに戻って知らせてください。"

### ビューアでユーザーに見えるもの

"Outputs" タブは 1 回に 1 テストケースを表示します。
- **Prompt**: 与えられたタスク
- **Output**: スキルが生成したファイル（可能ならインライン表示）
- **Previous Output**（iteration 2+）: 前回イテレーションの出力を折りたたみ表示
- **Formal Grades**（採点済みの場合）: assertion の pass/fail を折りたたみ表示
- **Feedback**: 入力中に自動保存されるテキストボックス
- **Previous Feedback**（iteration 2+）: 前回コメントをテキストボックス下に表示

"Benchmark" タブには統計サマリーが表示されます。各構成の pass rate、時間、トークン使用量に加え、eval ごとの内訳と分析者の所見が含まれます。

ナビゲーションは prev/next ボタンまたは矢印キーです。完了時に "Submit All Reviews" を押すと、すべてのフィードバックが `feedback.json` に保存されます。

### Step 5: フィードバックを読む

ユーザーが完了を知らせたら、`feedback.json` を読みます。

```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "the chart is missing axis labels", "timestamp": "..."},
    {"run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..."},
    {"run_id": "eval-2-with_skill", "feedback": "perfect, love this", "timestamp": "..."}
  ],
  "status": "complete"
}
```

空のフィードバックは「問題なし」を意味します。ユーザーが具体的な指摘をしたテストケースに改善の焦点を当ててください。

ビューアサーバーは使い終わったら停止します。

```bash
kill $VIEWER_PID 2>/dev/null
```

---

## スキルを改善する

ここがループの中心です。テストケースを実行し、ユーザーが結果をレビューし、ここからフィードバックに基づいてスキルを良くしていきます。

### 改善の考え方

1. **フィードバックから一般化する。** ここで起きている本質は、何度も（文字どおり何百万回、あるいはそれ以上）使えるスキルを作ることです。いまは高速に進めるため、少数の例を繰り返し使って改善しています。ユーザーはその例をよく理解しており、新しい出力の評価も速くできます。しかし、あなたとユーザーが共同開発したスキルがその例だけでしか機能しないなら無価値です。細かな過学習的変更や過度に抑圧的な MUST を入れるのではなく、しつこい課題があるなら、比喩を変える・異なる作業パターンを提案するなど、別方向を試してください。試行コストは比較的低いので、優れた着地に届く可能性があります。

2. **プロンプトを引き締める。** 効いていない要素は削除してください。最終出力だけでなく transcript も読み、スキルのせいでモデルが非生産的な作業に時間を浪費しているようなら、その原因となっているスキル部分を削って挙動を確認してください。

3. **なぜを説明する。** モデルに求めることすべてについて、**なぜ** それが必要かを丁寧に説明してください。現在の LLM は賢く、良い枠組みがあれば単なる手順実行を超えて成果を出せます。ユーザーからのフィードバックが短文や苛立った調子でも、実際の課題と意図、書かれている内容を正しく理解し、その理解を指示に反映してください。ALWAYS や NEVER を全大文字で多用したり、過度に硬直した構造に頼り始めたら黄信号です。可能であれば、要求の背景理由を説明してモデルが重要性を理解できる形に言い換えてください。その方が人間的で、強力で、効果的です。

4. **テストケース間の繰り返し作業を探す。** テスト実行の transcript を読み、各サブエージェントが同じ補助スクリプトを書いたり、同様の多段手順を取っていないか確認してください。3 つのテストケースすべてで `create_docx.py` や `build_chart.py` を書いているなら、スキルにそのスクリプトを同梱すべき強いシグナルです。1 回だけ書いて `scripts/` に置き、スキルから使うよう指示してください。将来の呼び出しで毎回同じ車輪を再発明せずに済みます。

この作業は非常に重要です（ここで年間で莫大な経済価値を生み出そうとしています）。考える時間自体はボトルネックではないので、十分に時間をかけて熟考してください。まず改訂ドラフトを書き、改めて見直して改善することを勧めます。ユーザーの立場に深く入り、何を望み何を必要としているかを理解する努力をしてください。

### 反復ループ

スキル改善後:

1. 改善内容をスキルに反映する
2. すべてのテストケースを新しい `iteration-<N+1>/` ディレクトリで再実行し、baseline 実行も含める。新規スキル作成時の baseline は常に `without_skill`（スキルなし）で、これはイテレーションをまたいで同じ。既存スキル改善時は、元のバージョンを baseline にするか前回イテレーションを baseline にするかを、状況に応じて判断する
3. `--previous-workspace` で前回イテレーションを指して reviewer を起動する
4. ユーザーのレビュー完了連絡を待つ
5. 新しいフィードバックを読み、再度改善して繰り返す

次のいずれかまで続けてください。
- ユーザーが満足したと言う
- フィードバックがすべて空（すべて問題なし）
- 有意な改善が出なくなる

---

## Advanced: ブラインド比較

2 つのスキルバージョンをより厳密に比較したい場合（例: 「新バージョンは本当に良くなったか？」）、ブラインド比較システムがあります。詳細は `agents/comparator.md` と `agents/analyzer.md` を読んでください。基本アイデアは、どちらの出力かを伏せたまま独立エージェントに 2 つの出力を評価させ、勝因を分析することです。

これは任意機能で、サブエージェントが必要です。ほとんどのユーザーには不要で、通常は人間レビューのループで十分です。

---

## Description Optimization

SKILL.md frontmatter の description フィールドは、エージェントがスキルを呼び出すかどうかを決める主要メカニズムです。スキル作成または改善の後は、トリガー精度向上のために description 最適化を提案してください。

### Step 1: トリガー評価用クエリを生成する

should-trigger と should-not-trigger を混在させた eval クエリを 20 件作成し、JSON で保存します。

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

クエリは現実的で、Claude Code / Claude.ai / Codex のユーザーが実際に入力しそうな内容にしてください。抽象的な依頼ではなく、具体性と詳細を持たせます。たとえばファイルパス、ユーザーの仕事や状況に関する個人的文脈、列名と値、会社名、URL、少しの背景情報。小文字だけの文や略語、typo、口語も混ぜます。長短を混在させ、明確すぎるケースよりエッジケースを重視します（最終的にユーザー確認の機会があります）。

Bad: `"Format this data"`, `"Extract text from PDF"`, `"Create a chart"`

Good: `"ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think"`

**should-trigger** クエリ（8〜10 件）では、カバレッジを意識します。同じ意図の言い換えを複数用意し、フォーマル/カジュアルを混在させます。ユーザーがスキル名やファイル種別を明示しないが、明らかにそのスキルが必要なケースを含めます。珍しいユースケースや、別スキルと競合するがこのスキルが勝つべきケースも入れてください。

**should-not-trigger** クエリ（8〜10 件）で価値が高いのはニアミスです。キーワードや概念は共有するが、実際には別の対応が必要なクエリです。隣接ドメイン、曖昧表現（単純キーワード一致なら誤発火しそうだが発火すべきでないもの）、スキル対象に一部触れるが文脈的には別ツールが適切なケースを考えてください。

避けるべき要点: should-not-trigger を明らかに無関係な内容にしないこと。PDF スキルの負例として「Write a fibonacci function」は簡単すぎて検証になりません。負例は本当に紛らわしいものにしてください。

### Step 2: ユーザーとレビューする

HTML テンプレートを使って eval セットをユーザーに提示します。

1. `assets/eval_review.html` からテンプレートを読む
2. プレースホルダーを置換する
   - `__EVAL_DATA_PLACEHOLDER__` → eval 項目の JSON 配列（引用符で囲まない。JS 変数代入として埋める）
   - `__SKILL_NAME_PLACEHOLDER__` → スキル名
   - `__SKILL_DESCRIPTION_PLACEHOLDER__` → 現在のスキル description
3. 一時ファイルに書き出して（例: `/tmp/eval_review_<skill-name>.html`）、開く: `open /tmp/eval_review_<skill-name>.html`
4. ユーザーはクエリ編集、should-trigger 切替、項目追加/削除を行い、その後 "Export Eval Set" を押す
5. ファイルは `~/Downloads/eval_set.json` にダウンロードされる。複数ある場合に備えて Downloads フォルダ内で最新を確認する（例: `eval_set (1).json`）

このステップは重要です。質の悪い eval クエリは質の悪い description を生みます。

### Step 3: 最適化ループを実行する

ユーザーには次のように伝えてください: "This will take some time — I'll run the optimization loop in the background and check on it periodically."

Eval セットを workspace に保存し、バックグラウンドで次を実行します。

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --agent <claude|codex> \
  --optimizer <anthropic|codex> \
  --model <model-id-powering-this-session-optional-for-codex> \
  --max-iterations 5 \
  --verbose
```

`--agent` はトリガー評価の実行バックエンドです。`--optimizer` は description 改善案の生成バックエンドです。`--model` は Anthropic バックエンドでは必須、Codex バックエンドでは省略可能です。

実行中は定期的に出力を tail し、どの iteration を実行中か、スコアがどうなっているかをユーザーに共有してください。

この処理は最適化ループ全体を自動で扱います。eval セットを 60% の train と 40% の held-out test に分割し、現行 description を評価（各クエリを 3 回実行して信頼できるトリガー率を取得）し、失敗結果に基づいて改善案を生成します。新しい description ごとに train/test の両方で再評価し、最大 5 回反復します。完了時には、iteration ごとの結果を示す HTML レポートをブラウザで開き、`best_description` を含む JSON を返します。`best_description` は過学習回避のため train ではなく test スコアで選ばれます。

### スキルのトリガーの仕組み

トリガーメカニズムを理解すると、より良い eval クエリを設計できます。スキルは name + description とともにエージェントの `available_skills` リストに現れ、エージェントは description をもとにスキル参照の要否を判断します。重要なのは、エージェントは自力で容易に処理できるタスクにはスキルを参照しない点です。たとえば「この PDF を読んで」のような単純な 1 ステップ依頼は、description が完全一致でもスキルをトリガーしないことがあります。逆に、複雑・多段・専門的な依頼は、description が一致していれば安定してトリガーされます。

したがって eval クエリは、エージェントが実際にスキル参照の恩恵を受ける程度に十分実質的である必要があります。「file X を読む」のような単純クエリは description 品質に関係なくスキルを発火しないため、テストケースとして不適切です。

### Step 4: 結果を適用する

JSON 出力の `best_description` を取り出し、スキルの SKILL.md frontmatter を更新します。変更前後をユーザーに示し、スコアを報告してください。

---

### Package and Present（`present_files` ツールが使える場合のみ）

`present_files` ツールにアクセスできるか確認してください。できない場合はこのステップをスキップします。できる場合はスキルをパッケージ化し、.skill ファイルをユーザーに提示します。

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

パッケージ化後、生成された `.skill` ファイルのパスをユーザーに案内し、インストールできるようにしてください。

---

## Claude.ai 固有の指示

Claude.ai でも中核ワークフローは同じです（ドラフト → テスト → レビュー → 改善 → 反復）。ただし Claude.ai にはサブエージェントがないため、いくつかの運用が変わります。適用ポイントは次のとおりです。

**テストケース実行**: サブエージェントがないため並列実行はできません。各テストケースごとにスキルの SKILL.md を読み、その指示に従って自分でテストプロンプトを達成してください。1 件ずつ順番に実行します。これは独立サブエージェントより厳密性は下がります（スキルを書いた本人が実行もするため、完全な文脈を持っている）が、有効なサニティチェックになります。人間レビューがその不足を補います。baseline 実行はスキップし、依頼どおりスキルを使った実行のみ行ってください。

**結果レビュー**: ブラウザを開けない場合（例: Claude.ai の VM にディスプレイがない、またはリモートサーバー上）には、ブラウザレビューアを完全にスキップします。代わりに会話内で直接結果を提示してください。各テストケースについて、プロンプトと出力を示します。出力がユーザー確認を要するファイル（.docx や .xlsx など）ならファイルシステムに保存し、ダウンロードして確認できる場所を伝えてください。フィードバックは会話内で求めます: "How does this look? Anything you'd change?"

**ベンチマーク**: 定量ベンチマークはスキップします。これは baseline 比較を前提としており、サブエージェントなしでは意味が薄いためです。ユーザーからの定性的フィードバックに注力してください。

**反復ループ**: 進め方は同じです。スキルを改善し、テストを再実行し、フィードバックを求める。ただし途中のブラウザレビューアは使いません。ファイルシステムがあるなら、結果を iteration ディレクトリで整理する運用は継続できます。

**description 最適化**: このセクションは CLI 実行が必要です。Claude 系では `claude -p`、Codex 系では `codex exec --json` を使います。Claude.ai ではスキップしてください。

**ブラインド比較**: サブエージェントが必要です。スキップします。

**パッケージ化**: `package_skill.py` スクリプトは Python とファイルシステムがあればどこでも動きます。Claude.ai でも実行でき、ユーザーは生成された `.skill` ファイルをダウンロードできます。

---

## Cowork 固有の指示

Cowork では主に次を把握してください。

- サブエージェントが使えるため、メインワークフロー（テストケース並列実行、baseline 実行、採点など）はそのまま動作します。（ただしタイムアウトが深刻な場合は、テストプロンプトを並列ではなく直列で実行しても構いません。）
- ブラウザ/ディスプレイがないため、eval viewer 生成時はサーバー起動の代わりに `--static <output_path>` を使ってスタンドアロン HTML を出力してください。その後、ユーザーがクリックしてブラウザで開けるリンクを提示します。
- 何らかの理由で、Cowork 環境ではテスト実行後に Claude が eval viewer 生成を避ける傾向があるようです。繰り返しになりますが、Cowork でも Claude Code でも、テスト実行後は必ず `generate_review.py`（独自 HTML の手書きではない）で eval viewer を生成し、人間が例を確認してからスキル改訂に入ってください。ここだけ全大文字で強調します: 自分で入力評価を始める *前に* EVAL VIEWER を生成してください。できるだけ早く人間に見せることが重要です。
- フィードバックの扱いが異なります。サーバーが動いていないため、ビューアの "Submit All Reviews" ボタンは `feedback.json` をファイルとしてダウンロードします。そこから読み取ってください（必要なら先にアクセス許可を依頼する必要があります）。
- パッケージ化は可能です。`package_skill.py` は Python とファイルシステムのみ必要です。
- description 最適化（`run_loop.py` / `run_eval.py`）は CLI ベースです。`--agent codex --optimizer codex` でも `--agent claude --optimizer anthropic` でも実行できます。ただしスキル改善を十分に終え、ユーザーが良好と判断してから最後に実施してください。

---

## 参照ファイル

agents/ ディレクトリには、特化サブエージェント向け指示があります。該当サブエージェントを起動するときに読んでください。

- `agents/grader.md` — 出力に対して assertion を評価する方法
- `agents/comparator.md` — 2 つの出力のブラインド A/B 比較を行う方法
- `agents/analyzer.md` — どちらのバージョンが勝ったかの理由を分析する方法

references/ ディレクトリには追加ドキュメントがあります。
- `references/schemas.md` — evals.json、grading.json などの JSON 構造

---

強調のため、コアループをもう一度示します。

- スキルの対象を明確にする
- スキルをドラフトまたは編集する
- スキルアクセス可能なエージェント（Claude/Codex）でテストプロンプトを実行する
- ユーザーと一緒に出力を評価する:
  - `benchmark.json` を作成し、`eval-viewer/generate_review.py` を実行してユーザーのレビューを支援する
  - 定量評価を実行する
- あなたとユーザーが満足するまで繰り返す
- 最終スキルをパッケージ化してユーザーに返す

TodoList のようなものがあるなら、忘れないよう手順を追加してください。Cowork の場合は特に、"Create evals JSON and run `eval-viewer/generate_review.py` so human can review test cases" を TodoList に入れて、確実に実施してください。

健闘を祈ります！
