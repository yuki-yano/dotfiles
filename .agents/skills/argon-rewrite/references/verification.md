# 検証記録

2026-11-04、macOS、agy 1.4.12、Python 3.15.2で確認。個人のローカル利用と同時2呼び出しを対象とした。commit・pushは行っていない。

## 静的点検

- 親Agentが本文を取得し、JSONを一度渡す構造。ファイル入力や出力先を指定する独自CLIは作っていない。
- モデルは`rewrite.py`の定数、書き直し指示は`assets/argon-rewrite.md`のみを正とした。専用Agentにモデル指定はない。
- shell、`-p`、workspace追加、会話継続、他モデルへのfallback、全回答への強制適用、discovery無効化設定はない。
- `communicate`でstdinを書いて閉じると同時にstdout/stderrを回収する。途中のテキストは出力せず、最終resultと終了コードを検証する。タイムアウト・中断では起動したプロセスグループを終了する。
- 今回の差分を`ponytail-review`の観点でセルフ点検した。非標準JSON定数・不正Unicodeの拒否と、SUCCESSでも`denied_actions`があれば不採用とする処理を補い、テストした。

## 模擬テスト

```bash
python3 -B -m unittest discover -s .agents/skills/argon-rewrite/scripts -v
```

7テスト成功。入力のJSON・型・空本文・UTF-8、成功応答、空応答・不正イベント・異なるモデルや権限・tool/subagent step・拒否記録、非0終了、認証・利用枠エラーを確認した。失敗時のstdoutは空。

偽agyを実プロセスとして起動し、長文と`/`始まりの行、1件のuserイベント、引数配列、同時2呼び出しの状態分離を確認した。短縮した1秒のタイムアウトで、子プロセスが後からファイルを作らず、workspaceも消えることを確認した。実際に10分待つテストや実アカウントの認証失効・枠不足は起こしていない。

## Argonの実呼び出し

| 経路 | 入力UTF-8バイト数 | 結果 |
| --- | ---: | --- |
| 回答下書き | 328 | 終了0、数値・担当・期限・否定・条件・義務・可能性・未確認事項・引用を保持 |
| 指定Markdownファイル | 846 | 終了0、frontmatter・コードブロック・識別子・URL・内部リンク・引用・`/model`行を保持 |
| 貼付長文 | 51,416 | 終了0、出力48,031バイト、188項目を保持 |
| 命令を含む貼付文章 | 短文 | 終了0、命令を本文として書き直し、コマンドの実行・ファイル作成なし |

回答下書きとMarkdownを同時に起動し、それぞれの本文・背景・cwdが分離され、workspaceが終了後に削除された。`~/.agents/skills`と`~/.config/claude/skills`の両経路から、現在の親Codexの実行環境で同じスクリプトを呼び出した。元Markdownはバイト一致。

短文・Markdownの全文を原文と照合した。長文は全188項目の順序・件数・担当・日付・承認条件・否定・未確認事項・可能性を機械照合し、先頭・末尾の文面も確認した。これは今回の入力に対する確認であり、任意の文章の意味保持を自動保証するものではない。

全4呼び出しでモデル・Agent・一時cwd・strictが一致し、tool stepは0。最後の命令入り本文は、非標準JSON拒否・`denied_actions`拒否を追加した最終スクリプトでも実呼び出しした。通常3経路の実呼び出し後の修正は、この入力・応答検証の強化のみ。

### 権限とコンテキストの確認

- 初回の新規一時workspaceでも、信頼確認や対話入力なしで完了した。global設定のハッシュは呼び出し前後で一致した。
- `tools: []`の専用Agentへ一時ファイルの読み取りを要求した検証では、ツールが提供されていない旨の応答となり、tool stepはなかった。これは書き直し用の指示とは別の、権限検証用プロンプトで行った。
- 対照として、別の検証用Agentへ`view_file`を明示するとtool stepが発生し、strictが一時workspace内のファイル読み取りを拒否した。秘密の検証文字列は応答に現れなかった。このrunは終了0・SUCCESS・空response・`denied_actions`付きだった。実イベントを最終validatorへ渡し、不採用になることも確認した。
- `init.tools`には`tools: []`でも60ツールが列挙された。列挙を有効な許可集合と同一視できないため、空配列を成功条件にしていない。毎回その一覧をstderrへ出し、strictとAgent選択を検証し、tool/subagent step・拒否記録を含む結果は返さない。
- 当時のglobal rules・Agent・hooks・plugins・上位AGENTS/GEMINIファイルは存在せず、global MCP設定ファイルは空だった。将来追加されるglobal設定やhooksの影響、OSレベルの完全隔離までは保証しない。独自sandboxは追加していない。

[headless仕様](https://antigravity.google/docs/cli/headless/)、[専用Agent](https://antigravity.google/docs/subagents/)、[設定schema](https://antigravity.google/schemas/v1/settings.json)、[discovery](https://antigravity.google/docs/customization-discovery/)、[権限](https://antigravity.google/docs/permissions/)を参照した。タイムアウトの既定値はWeb文書に古い記載が残るため、現行helpの`0`を採用した。`agentMode`の既定モード指定は文字列`""`であり、`"default"`は実機で拒否された。

## 削除・配置の確認

- `npx --yes skills remove yomiyasu -y`で本体を削除し、`skills-lock.json`の該当entryを削除した。他のlock entryは変更前と一致した。
- `.agents`、Codex、Cursor、Gemini（config/antigravity-cliを含む）、OpenCode、Claudeの既知のskill導入先に有効な重複・aliasなし。設定・hook・rules・commands・Agent・plugin登録に有効な呼び出しなし。`YOMIYASU_LINT`環境変数も未設定だった。
- 管理文書の導入コマンドを削除し、使い分けを`argon-rewrite`へ更新した。
- explainerの2ファイルは変更前とバイト一致。既存の出典・ライセンス表記は保持した。最小のMarkdownに対する`verify-doc.mjs --skip-html`で、`yomiyasu not installed; skipped`と`verdict: VERIFIED`を確認した。HTML全体の検証は今回の範囲外。
- `npx --yes skills list --json`のproject Codex、global Codex、global Claude Codeで新スキルを検出し、旧スキルがないことを確認した。lock実体はdotfiles直下の1件だけ。
- 利用可能なskill-creatorの`quick_validate.py`は成功。validator専用に`uv run --no-project --with pyyaml`を使い、スキルの実行依存は追加していない。`git diff --check`も成功。
- 作業前からあった`Brewfile`、`Caskfile`、`.config/claude/settings.json`の差分はバイト一致で保持した。indexは変更していない。

現セッションの開始時catalogには旧yomiyasuが読み込まれているため、その表示までは除去できない。新しいdiscoveryコマンドでは新スキルが現れ旧スキルは消えた。Codex/Claudeアプリを再起動した新規対話セッションのcatalog自体は未確認。

## 機能完了条件

- [x] 回答下書き・Markdownファイル・貼付文章を同じ実行スクリプトで処理した。
- [x] Argon High固定と、検証入力の情報・保護対象の保持を確認した。
- [x] 原文の無断変更・全回答への常時適用・他モデルへのfallbackがない。
- [x] 失敗結果・途中出力・ツール操作を含む結果を本文として返さない。

## テスト完了条件

- [x] 入力検証・応答検証・異常終了・タイムアウトの自動テストが成功した。
- [x] 数値・否定・条件・未確認事項と、Markdownの保護対象を実呼び出しで確認した。
- [x] 約50KBと`/`始まりの行を標準入力で処理した。
- [x] 同時2呼び出しの入力・出力・一時状態の分離を模擬・実機で確認した。
- [x] 初回workspaceの非対話完了、意図しないツール操作なし、元ファイル不変を確認した。
- [x] skill-creator validatorが成功した。
- [x] explainerの未導入時スキップを確認した。
- [x] 静的点検・模擬テスト・実呼び出しの確認範囲を分けて記録した。

## 運用反映条件

- [x] dotfilesの共有配置から新スキルを参照できる。
- [x] 現在の親Codex実行環境から共有経路で実際に呼び出せた。
- [x] 旧スキルの本体・lock・有効な重複導入物・強制呼び出し設定が残っていない。
- [x] 管理文書と実装が一致し、無関係な既存差分を保持した。
- [x] 現セッションの旧catalogと、新しいdiscoveryの結果を区別して報告した。
