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

## Common Mistakes

- Running `npx skills add -g -a codex`: this installs into Codex global storage instead of the dotfiles `.agents` tree.
- Running `npx skills add` from `~/.agents` or `.agents/skills`: this can create a lock file at the wrong root.
- Keeping `.agents/.skill-lock.json` or other alternate lock files: use root `skills-lock.json` only.
- Installing the same skill for Cursor or Gemini just to make Codex see it: Codex should read the `.agents` copy through the dotfiles-managed path.
- Hand-editing external skill files without recording that they now diverge from the upstream `skills-lock.json` entry.
- Removing only `~/dotfiles/.agents/skills/<name>` while leaving copies under `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills`, or `~/.claude/skills`.

