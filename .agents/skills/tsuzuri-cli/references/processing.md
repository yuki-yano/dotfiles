# 処理手順

以下の`<UUID>`、revision、hash、pathは実際の応答・依頼から置き換える。本文の取得だけなら処理コマンドを実行しない。

## 録音を開始・停止する

AIへ送らず、停止後の文字起こしまで行う例。

```bash
tsuzuri recordings start --goal transcript --live-summary off
tsuzuri recordings stop <開始結果のmeetingID>
```

- `start`前に`tsuzuri status`で現在の録音を確認する。既存録音を勝手に停止しない。`stop`は依頼対象と一致するUUIDで実行する。
- `start`の既定値は`--goal summary`、`--agent codex`、話者分離と話者補正が有効、`--live-summary 10`。既定のままなら、録音中は10分ごとに要約し、停止後は整文・要約まで進む。録音中の自動要約は`--live-summary off|10|20`で選ぶ。
- agentは`codex`または`claude`。model/effortの指定がなければagent設定を使う。
- macOS権限が必要な場合はユーザーのOS操作が必要。開始時の空き容量不足などは返されたエラーを報告する。
- 停止は保存と後処理開始を含む。`captureState`と`followUpOperationID`を確認し、`recordings show`で成果物を確かめてから後処理完了を報告する。

## 音声を取り込む・文字起こしする

```bash
tsuzuri import /absolute/path/audio.m4a --source mixed
tsuzuri transcribe <UUID> --locale ja-JP
tsuzuri transcript show <UUID>
```

`import`は音声の取り込みと文字起こしを行い、新しい会議UUIDを返す。直後に同じ会議へ`transcribe`を重ねる必要はない。
`--source`は`microphone|system|mixed`で必須。音声の出所が不明なら確認する。locale省略時はapp設定。

一括処理で文字起こしまで進める場合は次も使える。

```bash
tsuzuri run /absolute/path/audio.m4a --source mixed --goal transcript
```

音声pathを対象にした`run`は`transcript`から開始する。会議UUIDが対象の`run`には`--source`を付けない。

## 整文・要約・再処理を行う

`run`はGUIと同じ実行プランを使う。`--goal`と`--start-stage`は`transcript|polish|summary`。既定の開始段階は`transcript`なので、既存会議の再処理では必要な段階を明示する。

整文から、または要約だけをやり直す例。

```bash
tsuzuri run <UUID> --start-stage polish --goal summary
tsuzuri run <UUID> --start-stage summary --goal summary
```

- `transcript`からの再実行は文字起こしを再生成する。整文からやり直す依頼を文字起こしからやり直さない。
- `--agent codex|claude`、必要なら`--model`、`--effort`を指定する。modelとeffortの組み合わせはCLI/appの検証に従い、古いモデル一覧を固定しない。
- 話者分離は`--diarization/--no-diarization`、話者補正・発話再構成は`--speaker-reconstruction/--no-speaker-reconstruction`。省略時はいずれも有効。必要なモデルがなければ、勝手に取得・無効化せず依頼に沿って不足を解消する。
- 現行`run`にはrevisionの引数はない。文字起こしの版を指定して要約する場合は、下記の`summarize`を使う。

## 文字起こしの版を指定して要約する

```bash
tsuzuri transcript show <UUID> --revision <revision>
tsuzuri transcript review <UUID> --revision <revision> --sha256 <transcriptSHA256>
tsuzuri summarize <UUID> --revision <revision>
```

1. `summarize`はreview済みの整文済み文字起こしを要約し、`--revision`にはreviewした版を指定する。`recordings show`の`transcriptReview`がその版を指していれば、reviewを重ねない。
2. reviewする場合は、`transcript show`の本文を読み、同じ応答のrevisionと`sha256`を使う。単なる閲覧ではreview状態を変更しない。reviewは整文済み、または整文由来の編集済み文字起こしを必要とする。未整文の音声認識結果へreviewを強制しない。
3. `summarize`のAI・model・effortはapp設定を使い、`--agent`などは付けない。review状態は変更しない。

## 成果物を書き出す

```bash
tsuzuri export <UUID> --output /absolute/path/new-export-directory
```

- 出力directoryはまだ存在せず、親directoryは存在する必要がある。先に出力先を`mkdir`しない。`mktemp -d`を使うなら、その中の未作成の子directoryを指定する。
- 現行CLIのexportは保存済み要約と、その入力文字起こし・生成済み文書・字幕を必要とする。文字起こしだけの会議には使わない。export失敗を理由に要約を自動生成しない。
- `run --output`も同じ書き出しを行う。文字起こしまでの実行など、要約が作られない場合は`--output`を付けない。
- 完了後は応答の`outputDirectory`と`artifacts[].path`を使う。Markdownファイル名はapp設定で変わるため固定しない。既存出力先へ上書きするオプションはない。別pathへの変更がユーザーの指定に反する場合は確認する。

## 話者分離・モデル管理

必要なモデル状態の確認には次を使う。

```bash
tsuzuri models list
tsuzuri diarization model status
tsuzuri diarization run <UUID> --speaker-count 3
```

話者分離は文字起こし済み会議が対象。人数不明なら人数オプションを省略する。固定人数は2〜5、範囲指定は`--min-speakers`と`--max-speakers`の両方を2〜5で指定し、固定人数と併用しない。

取得・ライセンス同意が承認済みなら`tsuzuri diarization model provision --approve-download --approve-license`。
system-managed Speech assetは`models list`のIDを使い、`tsuzuri models prepare <model-id> [--locale <locale>]`。system-managed assetへdownload/license承認フラグは付けない。

削除が依頼され、対象と影響が確定している場合だけ`tsuzuri models delete <model-id> --confirm`、または`tsuzuri diarization model delete --confirm`を使う。確認済みの依頼は取り直さない。

## 範囲選択・復旧・録音の形式変換

- `tsuzuri trim <UUID> --from-ms <開始ms> --to-ms <終了ms>`は元音声の連続範囲を選択し、文字起こしを再生成する。開始は0以上、終了は開始より後。既存成果物への影響を伴うため、範囲選択の依頼に対して使う。
- `tsuzuri recovery list`で隔離entryを確認し、復旧依頼の対象に対して`tsuzuri recovery restore <返されたentry名>`を使う。entry名をUUIDから組み立てたり、隔離directoryを直接移動したりしない。
- `tsuzuri recordings convert-audio`は全会議の保存済み録音チャンクを16bit ALACへ変換し、確かめた後に変換前のFloat32を削除する。変換を依頼され、バックアップを確認できたときだけ実行する。録音中と起動時の復旧中は実行できない。
