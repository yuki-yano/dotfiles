# wait / collect: 完了待ちと回収

## wait: 完了待ち

send.md手順8の受理確認の時点で既に完了マーカーが見えている（高速応答）場合は、waitを省略してcollectへ進んでよい。

方式の選択:

- Claude Code環境でMonitorツール（バックグラウンド監視）が使える場合はそれを優先してよい。監視条件は「連結済みマーカーの出現」または「作業中表示（`Working` / `esc to interrupt` 等）の消失」。上限時間を必ず設定する。
- それ以外（Codex等）は下記のポーリングスクリプトを既定とする。固定sleepの反復では待たない。マーカー検出+停滞判定を1回のシェル呼び出しで行う。

```bash
pane='%N'
marker='===BRIDGE-DONE-R1==='   # 連結済みマーカー。依頼文には分割形式でしか書かれていないこと（SKILL.mdの規約）
deadline=$((SECONDS + 1800))     # 上限。レビューは30分、実装依頼は依頼内容に応じて延長
stall_limit=300                  # 画面が変化しないまま何秒で停滞とみなすか
last_hash='' ; stall=0
while [ $SECONDS -lt $deadline ]; do
  snap=$(tmux capture-pane -p -t "$pane" -S -200 2>&1) || { echo "PANE-GONE: $snap"; exit 2; }
  if printf '%s' "$snap" | grep -qF "$marker"; then echo "DONE"; exit 0; fi
  h=$(printf '%s' "$snap" | shasum -a 256 | cut -d' ' -f1)
  if [ "$h" = "$last_hash" ]; then
    stall=$((stall + 20))
    [ $stall -ge $stall_limit ] && { echo "STALLED"; printf '%s\n' "$snap" | tail -25; exit 3; }
  else
    stall=0
  fi
  last_hash=$h
  sleep 20
done
echo "TIMEOUT"; exit 1
```

終了コードごとの対応:

- `DONE`: collectへ進む。
- `PANE-GONE`: 中断してユーザーに報告する。
- `STALLED`: 末尾出力を確認する。permission promptや確認待ちで止まっている場合はユーザーに報告して判断を仰ぐ（勝手に承認キーを送らない）。入力受付表示へ戻っているのに マーカーがない場合は「マーカー指示が無視された」とみなし、collectをfallback完了として実行し、その旨を報告に明記する。
- `TIMEOUT`: 途中経過をcaptureして報告し、待機を延長するか打ち切るかユーザーに確認する。

長時間の待機で自分の別作業と並行したい場合は、上記スクリプトをバックグラウンド実行にする。待機中に相手paneへ追加送信をしない。

## collect: 回収

1. スクロールバックをファイルへダンプする。直接読まない。sendから続ける場合はsend.md手順3で記録した作業ディレクトリを使う。collect単独の場合は、先に`mktemp -d "${TMPDIR:-/tmp}/tmux-agent-bridge.XXXXXX"`を実行し、出力された絶対パスを記録する。以降のツール呼び出しでは、その絶対パスを`<作業ディレクトリ>`へ文字どおり埋め込む。

```bash
tmux capture-pane -p -t %N -S -3000 > "<作業ディレクトリ>/bridge-collect.txt"
wc -l "<作業ディレクトリ>/bridge-collect.txt"
```

2. マーカーと依頼文送信位置をgrepで特定し、その間の範囲だけをReadで読む。

```bash
grep -n '===BRIDGE-DONE-R1===' "<作業ディレクトリ>/bridge-collect.txt" | head -1
grep -n '<依頼文の特徴的な行>' "<作業ディレクトリ>/bridge-collect.txt" | tail -1
```

- マーカーが複数回出現する場合（Enter誤送などによる再実行）は**最初の出現を採用**する。2回目以降の出現を見つけたら、再実行が起きた旨を報告に含める。

3. `-S -3000` で依頼文の開始位置が見つからない場合のみ `-S -6000` へ拡大して再ダンプする。無条件に `-S -10000` 級から始めない。

## collectのみのモード（他paneの作業ログ読取）

送信を伴わない読取（「%Nの作業内容をまとめて」）では:

1. send.md の手順1でpaneを特定する（`pane_current_command` でエージェントpaneを見分ける）。
2. 上記と同じくファイルへダンプし、キーワードで当たりを付けてから範囲Readする。キーワードは部分文字列の誤爆に注意して選ぶ（例: 「解約」を探すのに「約」を含む語で拾わない）。
3. 相手paneには何も送信しない。
