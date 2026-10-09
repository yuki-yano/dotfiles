# 外部skillの管理手順

追加・更新・削除・重複整理のうち、依頼された操作の節だけ読む。
本文のCLIの制約は`skills` 1.5.19で確認した運用記録であり、バージョン番号を実行許可条件にしない。
導入済みCLIで該当の挙動が変わったと確認できた場合は、現在の実装・helpを根拠に手順を更新する。

## Install External Skills

Use this form from the dotfiles root:

```bash
npx --yes skills add <owner/repo> --skill <skill-name> -a codex -y
```

Multiple skills from one repo:

```bash
npx --yes skills add cloudflare/skills \
  --skill workers-best-practices \
  --skill wrangler \
  -a codex -y
```

Expected result:

- Files are copied under `~/dotfiles/.agents/skills/<skill-name>`.
- `skills-lock.json` gains or updates entries for each external skill.
- `npx --yes skills list --json -a codex` shows the skill with path under `~/dotfiles/.agents/skills`.

## Update External Skills

`skills` 1.5.19 の `update` は更新時の内部 `add` に対象 agent を引き継がない。
このリポジトリにはローカル設定用の `.claude` があるため、`npx skills update -p`
を実行すると Claude Code も自動検出され、不要な `.claude/skills/<name>` が作られる。
`update` に `--agent` が追加されるまでは、このリポジトリで `npx skills update` を使わない。

`npx skills check` もread-onlyの更新確認ではなく、lockにあるskillを再取得して実体とhashを更新する。
変更有無の確認だけを目的に実行しない。上流との差分確認が必要な場合はsourceを個別に調査し、
実体を更新する場合だけ下記の`add -a codex`を使う。

代わりに、下記の `Current Known External Sources` にある対象 source の `add` を
`~/dotfiles` から再実行する。各コマンドは `-a codex` を明示するため、
`.agents/skills` と `skills-lock.json` だけを更新する。

単一 skill の更新例:

```bash
npx --yes skills add <owner/repo> --skill <skill-name> -a codex -y
```

全 external skill の更新では、`Current Known External Sources` のコマンドをすべて再実行する。

誤って `update` を実行した場合は、`.claude/skills` の各 entry が
`../../.agents/skills/<name>` への symlink であることを確認し、その project alias だけを削除する。
`.agents/skills` の実体や `.config/claude/skills` の global alias は削除しない。

After updating, inspect:

```bash
git diff -- skills-lock.json .agents/skills/<skill-name>
```

## Remove Skills

`skills` 1.5.19 の project scope `remove` は、`-a codex` を付けると
`.agents/skills/<name>` の canonical path を共有利用中と判定して残す。
また、agent指定なしで実体を削除しても、project scope の `skills-lock.json` entry は削除しない。

外部由来の dotfiles-managed skill は、agent指定なしで実体とproject aliasを削除する。

```bash
npx --yes skills remove <skill-name> -y
```

その後、`~/dotfiles/skills-lock.json` の `skills.<skill-name>` entry を削除する。
CLIが `Successfully removed` と表示しても、実体とlockを個別に確認する。

If the skill exists in other global agent locations, remove those copies explicitly:

```bash
npx --yes skills remove --global -a cursor -y <skill-name>
npx --yes skills remove --global -a gemini-cli -y <skill-name>
npx --yes skills remove --global -a opencode -y <skill-name>
npx --yes skills remove --global -a claude-code -y <skill-name>
```

For a hand-written local skill that is not in `skills-lock.json`, remove the directory directly:

```bash
rm -r ~/dotfiles/.agents/skills/<skill-name>
```

## Audit For Duplicate Installs

Check the known places where duplicate skills tend to appear:

```bash
find ~/.agents/skills ~/.codex/skills ~/.cursor/skills ~/.gemini/skills ~/.config/opencode/skills ~/.claude/skills ~/dotfiles/.agents/skills \
  -maxdepth 1 -name '<skill-name>' -print 2>/dev/null | sort -u
```

Interpretation:

- `~/.agents/skills/<skill-name>` and `~/dotfiles/.agents/skills/<skill-name>` are the same location because `~/.agents` is a symlink.
- Any matching path under `~/.codex/skills`, `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills`, or `~/.claude/skills` is a duplicate unless there is an explicit reason to keep it.
- `~/.config/claude/skills` is a symlink to `~/.agents/skills`, so it is out of audit scope. `~/.claude/skills` is a real directory, so it is in audit scope.

Check lock file drift separately:

```bash
find ~/dotfiles ~/.agents \( \
  -name skills-lock.json -o \
  -name skill-lock.json -o \
  -name .skills-lock.json -o \
  -name .skill-lock.json \
\) -print
```

The only desired real path is `~/dotfiles/skills-lock.json`.

## Verify Current Management State

Use these checks before reporting completion:

```bash
ls -ld ~/.agents ~/dotfiles/.agents
npx --yes skills list --json -a codex
npx --yes skills list --json -g -a codex
git status --short --untracked-files=all
```

The desired state is:

- `~/.agents -> ~/dotfiles/.agents`.
- The only lock file is `~/dotfiles/skills-lock.json`.
- Dotfiles-managed skills appear under `~/dotfiles/.agents/skills`.
- External skills installed through `npx skills` are represented in `skills-lock.json`.
- Deleted or de-duplicated skills do not remain under `~/.codex/skills`, `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills`, or `~/.claude/skills`.

## Current Known External Sources

Cloudflare skills:

```bash
npx --yes skills add cloudflare/skills \
  --skill workers-best-practices \
  --skill wrangler \
  -a codex -y
```

External project skills:

```bash
npx --yes skills add vercel-labs/agent-browser --skill agent-browser -a codex -y
npx --yes skills add emilkowalski/skills --skill apple-design -a codex -y
npx --yes skills add anthropics/claude-code --skill frontend-design --full-depth -a codex -y
npx --yes skills add vercel-labs/portless --skill portless -a codex -y
npx --yes skills add millionco/react-doctor --skill react-doctor -a codex -y
npx --yes skills add vercel-labs/agent-skills --skill vercel-react-best-practices -a codex -y
npx --yes skills add github/gh-stack --skill gh-stack -a codex -y
```

説明・図解・日本語推敲:

```bash
npx --yes skills add https://github.com/anthropics/claude-plugins-community/tree/main/eli5/skills/eli5 --skill eli5 -a codex -y
npx --yes skills add tt-a1i/archify --skill archify -a codex -y
npx --yes skills add mizchi/explainer --skill explainer first-reader -a codex -y
npx --yes skills add nanaism/yomiyasu --skill yomiyasu -a codex -y
npx --yes skills add kmizu/concise --skill concise -a codex -y
```

- 初歩的な絵中心の説明は`eli5`、構成・処理・状態の図は`archify`、読み手に合わせた説明資料は`explainer`、日本語の推敲は`yomiyasu`を使う。通常の調査メモや判断記録はMarkdownでよく、全skillを毎回通す必要はない。
- 会話・進捗・結果報告の分量と構造は`concise`で整える。`i-have-adhd`とは併用しない。日本語そのものの推敲は`yomiyasu`で扱う。
- `concise`はcanonicalの`skills/concise`を無改変で導入する。Claude Codeでは`/concise`、Codexでは`$concise`で明示し、解除は`stop concise mode`と伝える。単体導入にalways-on hookは含まれない。Claude Codeは`disable-model-invocation: true`で自動起動を抑止するが、canonicalには`agents/openai.yaml`がなく、Codexでの明示起動指定はdescriptionに依存する。
- `first-reader`は`explainer`が参照する補助skill。`explainer-book`、`d2-diagram`、`d2-slides`は導入対象に含めない。
- `archify`はNode 18以上を使い、`finalize`のブラウザ検証にはChromeが必要。`finalize` / `deliver`には更新確認の外部GETが含まれる。更新確認を止める場合は`ARCHIFY_UPDATE_CHECK_DISABLED=1`を指定する。
- `explainer`のHTML生成・検証はNode 24以上と、資料を作るprojectの`@mizchi/vlmkit marked playwright mermaid`を使う。利用時にそのprojectのpackage managerで準備する。D2とIconifyは必要な場合だけ追加する。skillの配置先に一括installしても、利用projectの依存の代わりにはならない。
- `verify-doc.mjs`の引用照合は出力文字列の一致を検査する。実行コマンドの成功や技術的な正しさを保証するものとして扱わない。
- 外部skillの本文は上流のまま管理する。旧rendererの再現機能は引き継がず、過去の資料はそのまま残す。UIの比較・選択はローカルの`ui-mock-proposals`で扱う。
- `npx skills`が取り込む上流のtests・examples・補助資料も保持する。lockのhashと再導入結果を一致させるため、一部だけ削除したりgitignoreで追跡対象から外したりしない。

## Common Mistakes

- Running `npx skills add -g -a codex`: this installs into Codex global storage instead of the dotfiles `.agents` tree.
- Running `npx skills add` from `~/.agents` or `.agents/skills`: this can create a lock file at the wrong root.
- Keeping `.agents/.skill-lock.json` or other alternate lock files: use root `skills-lock.json` only.
- Installing the same skill for Cursor or Gemini just to make Codex see it: Codex should read the `.agents` copy through the dotfiles-managed path.
- Hand-editing external skill files without recording that they now diverge from the upstream `skills-lock.json` entry.
- Removing only `~/dotfiles/.agents/skills/<name>` while leaving copies under `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills`, or `~/.claude/skills`.
