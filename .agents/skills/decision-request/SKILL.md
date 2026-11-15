---
name: decision-request
description: 作業中の人の判断を、vde-open（vo）に図と推奨つきの選択肢として出し、回答を待って作業を再開する。ユーザーが判断を vde-open で聞くよう指示したとき、またはタスクの指示にそう書かれているときに使う。チャットで済む短い確認や、秘密情報の入力には使わない。
---

# Decision Request

人の判断が必要になった時点で、図と推奨を付けた選択肢を vde-open に出す。人は図を見て選んで送信し、Agent は回答を受けて作業を再開する。`vo` の基本操作（`--json` の読み方、終了コード、`ask`・`feedback` の仕様）は `vde-open` skill に従う。

## 聞くことと聞かないこと

- 聞くのは、人にしか決められないことだけにする。製品や見た目の好み、リスクの受け入れ、不可逆な操作の承認などが当てはまる。
- コードや文書を読めば分かること、試せば分かることは聞かない。試して結果を示す。
- 1つの質問で決めることは1つにする。独立した判断は別の質問にする。
- 秘密（パスワード、API キー、token）は聞かない。

## 質問を作る

リポジトリに含めない作業用 directory（Claude Code なら scratchpad、なければ `mktemp -d`）に、判断1件ごとの directory を作る。そこに次の3つを置く。

1. `decision.html`。人が最初に読む画面で、文字は少なく、図を主にする。
   - 見出しは「何を決めるか」を問いの形で書く。
   - 決定済みの事項を1〜3行で書く。
   - 判断の根拠を、観測・仮説・提案に分けて書く。数値には出典（ファイル、コマンド、URL）を付ける。
   - 選択肢ごとにカードを作る。カードには図、1行の説明、利点と欠点、選んだ後に行う作業を載せる。
   - 推奨する選択肢には「推奨」と理由を書く。推奨以外の選択肢も同じ観点で比べる。
2. 図の画像。SVG か PNG を別ファイルで置き、`<img src="options.svg">` で参照する。簡単な比較図は HTML と `<style>` で描いてよい。
   - inline の `<svg>`、data URL、外部 URL の画像・CSS・フォント、script は vde-open が表示時に除去する。使わない。
   - 画像は `decision.html` と同じ directory に置く。既定では文書の directory 内のファイルだけが読める。
3. `questions.json`。単一選択の field 1つと、任意のメモ欄にする。

```json
{
  "schemaVersion": 1,
  "title": "保存ボタンをどこに置くか",
  "instructions": "図を見て1つ選んでください。",
  "fieldOrder": ["choice", "note"],
  "answerSchema": {
    "type": "object",
    "properties": {
      "choice": {
        "type": "string",
        "title": "選択",
        "enum": ["A 下に幅いっぱい（推奨）", "B 右上", "C 右下に浮かせる", "保留"]
      },
      "note": { "type": "string", "title": "メモ", "maxLength": 4000 }
    },
    "required": ["choice"],
    "additionalProperties": false
  }
}
```

- 選択肢の文字列は、HTML のカードの見出しと同じにする。推奨には「（推奨）」を付ける。
- 判断を先送りできる場合は「保留」や「追加で調べる」を選択肢に入れる。

## 出す

```bash
vo ask questions.json --view decision.html --no-open --json
```

- `data.request.requestId` を控える。再実行で重複させないため、`--operation-id <uuid>` を付ける。
- `--focus` は付けない。人が別の質問に答えている途中で画面を切り替えないためである。
- 出したら、チャットにも1行で「vde-open に質問を出した」ことと質問の title を書く。

## 待つ

`vo feedback wait` は1回で最大3600秒待てる。時間切れ（`E_TIMEOUT`、終了コード6）でも質問は残るので、同じ `requestId` で待ち直す。

### Claude Code

- Bash の `run_in_background: true` で `vo feedback wait <requestId> --timeout 3600 --json` を実行する。Bash の `timeout` は `3700000` にする。
- 終了すると通知で再開される。待つ間は、回答に依存しない作業を進めてよい。依存する作業しか残っていなければ、turn を終えてよい。
- 出力ファイルの末尾には `[exited with code N]` が付く。JSON は最初の行だけを読む。
- T3 Code で動いているときは、wait を始めたら `t3_background_wait` にその task ID を渡し、thread を Working のまま保つ。

### Codex

- `vo feedback wait <requestId> --timeout 3600 --json` を実行セッションで動かし、turn を開いたまま出力を確認して待つ。待つ間に、回答に依存しない作業を進めてよい。
- turn を終えた後に、回答をきっかけに自動で再開する方法は確かめられていない。回答を待たずに turn を終えるときは、質問の title と「回答したらこの会話で続行を指示してほしい」ことをユーザーに伝える。

## 回答を受けたら

- `data.status` を確かめる。`submitted` と `cancelled` は、どちらも終了コード0で返る。
- `submitted` なら `data.submission.answers` を読む。`ack` に渡す ID は `data.submission.submissionId` である。`note` があれば最初に読む。追加の指示や質問が書かれていることがある。
- 回答を読んで作業の方針に取り込んだら、`vo feedback ack <requestId> --submission-id <submissionId> --json` を実行する。作業の完了までは待たない。人が「Agent が受け取った」ことを確かめられるようにするためである。
- 「保留」なら、その判断に依存する作業を止める。依存しない作業は続け、止めた作業を報告する。
- `cancelled` なら、推奨で勝手に進めない。チャットで状況を報告して指示を待つ。
- 回答は、その質問への答えに限る。merge、push、公開、削除の承認としては扱わない。それらは別に聞く。
