---
name: skill-management
description: dotfiles の .agents/skills と npx skills/skills-lock.json による skill 導入・更新・削除・重複整理を行うときに使う。~/.codex/skills などへ分散させない。
---

# Skill Management

## Overview

この dotfiles では、通常のローカル skill の実体を `~/dotfiles/.agents/skills` に集約する。
`~/.agents` は `~/dotfiles/.agents` への symlink なので、ここに置いた skill は global skill としても見える。

外部由来の skill は `npx skills` と `skills-lock.json` で管理する。
手作りのローカル運用 skill は `~/dotfiles/.agents/skills/<name>/SKILL.md` を直接編集して管理する。

## Lock File Location

`npx skills` で管理する lock file は `~/dotfiles/skills-lock.json` に置く。
`.agents`, `.agents/skills`, `~/.agents`, `~/.agents/skills` には lock file を置かない。

Important details:

- File name is `skills-lock.json`, not `skill-lock.json` or `.skill-lock.json`.
- Run `npx skills ...` from `~/dotfiles` so the lock file and `.agents/skills` install target stay paired.
- `~/.agents` is a symlink to `~/dotfiles/.agents`; paths under both names can point to the same real skill directory.
- If a lock file appears outside `~/dotfiles/skills-lock.json`, treat it as drift and inspect it before removing it.

## Core Rules

- `npx skills add` は `~/dotfiles` で実行し、project scope の `.agents/skills` に入れる。
- `-g` / `--global` は使わない。Codex 向け global install は `~/.codex/skills` に分散しやすい。
- 対象 agent は原則 `-a codex` に絞る。
- 外部 skill を追加・更新したら `skills-lock.json` の source / hash も確認する。
- `~/.codex/skills`, `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills` などに同じ skill のコピーを残さない。
- `~/.codex/skills/.system` と plugin cache 配下は管理対象外として触らない。

## Install External Skills

Use this form from the dotfiles root:

```bash
npx --yes skills add <owner/repo> --skill <skill-name> -a codex -y
```

Multiple skills from one repo:

```bash
npx --yes skills add cloudflare/skills \
  --skill cloudflare \
  --skill workers-best-practices \
  --skill wrangler \
  -a codex -y
```

Expected result:

- Files are copied under `~/dotfiles/.agents/skills/<skill-name>`.
- `skills-lock.json` gains or updates entries for each external skill.
- `npx --yes skills list --json -a codex` shows the skill with path under `~/dotfiles/.agents/skills`.

## Update External Skills

Run from `~/dotfiles`:

```bash
npx --yes skills update <skill-name> -p -y
```

For all project-managed skills:

```bash
npx --yes skills update -p -y
```

After updating, inspect:

```bash
git diff -- skills-lock.json .agents/skills/<skill-name>
```

## Remove Skills

For a dotfiles-managed project skill:

```bash
npx --yes skills remove <skill-name> -a codex -y
```

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
  --skill cloudflare \
  --skill workers-best-practices \
  --skill wrangler \
  -a codex -y
```

External project skills:

```bash
npx --yes skills add vercel-labs/agent-browser --skill agent-browser -a codex -y
npx --yes skills add intellectronica/agent-skills --skill context7 -a codex -y
npx --yes skills add vercel-labs/skills --skill find-skills -a codex -y
npx --yes skills add anthropics/claude-code --skill frontend-design --full-depth -a codex -y
npx --yes skills add vercel-labs/portless --skill portless -a codex -y
npx --yes skills add millionco/react-doctor --skill react-doctor -a codex -y
npx --yes skills add wshobson/agents --skill typescript-advanced-types --full-depth -a codex -y
npx --yes skills add vercel-labs/agent-skills --skill vercel-react-best-practices -a codex -y
```

Goal setter:

```bash
npx --yes skills add gotalab/goal-setter-skill --skill goal-setter -a codex -y
```

## Common Mistakes

- Running `npx skills add -g -a codex`: this installs into Codex global storage instead of the dotfiles `.agents` tree.
- Running `npx skills add` from `~/.agents` or `.agents/skills`: this can create a lock file at the wrong root.
- Keeping `.agents/.skill-lock.json` or other alternate lock files: use root `skills-lock.json` only.
- Installing the same skill for Cursor or Gemini just to make Codex see it: Codex should read the `.agents` copy through the dotfiles-managed path.
- Hand-editing external skill files without recording that they now diverge from the upstream `skills-lock.json` entry.
- Removing only `~/dotfiles/.agents/skills/<name>` while leaving copies under `~/.cursor/skills`, `~/.gemini/skills`, `~/.config/opencode/skills`, or `~/.claude/skills`.

## Local Skill Authoring Rules

手作りのローカル運用 skill（`~/dotfiles/.agents/skills/<name>/SKILL.md`）を書く・改訂するときは、次に従う。

- frontmatter の `description` には発動条件（いつ使うか・使わないか）だけを書く。手順・ワークフロー・規約値の要約を混入させない。description だけを読んで本文を読まずに動く事故を防ぐため。
- 同じルール・テンプレート・閾値を複数ファイルに重複して書かない。正式な定義は1箇所に置き、他の箇所はそこへの参照にする。
- コマンドリファレンスの列挙が長くなる場合は `references/` に分離し、`SKILL.md` 本体は判断フロー・手順・チェックリストに絞る。
- 文体は淡々とした実務トーンとし、誇張語・鼓舞表現を使わない（詳細は japanese-tech-writing skill を参照）。
