#!/usr/bin/env -S deno run --allow-read=/dev/stdin

import { readAll } from "jsr:@std/io@0.224.0/read-all";

interface ToolInput {
  tool_name?: string;
  tool_input?: {
    command?: string;
    [key: string]: unknown;
  };
}

type ValidationRule = {
  validate: (command: string) => boolean;
  message: string;
};

const VALIDATION_RULES: ValidationRule[] = [
  {
    validate: (cmd: string) => cmd.trim().startsWith("grep "),
    message:
      "grep の変わりに git grep --function-context [--and|--or|--not|(|)|-e <pattern>...] -- <pathspec>... を使ってください。--function-context フラグにより出力行が多すぎる場合、 --show-function と -C フラグを利用してください",
  },
  {
    validate: (cmd: string) => cmd.trim().startsWith("rg "),
    message:
      "rg の変わりに git grep --function-context [--and|--or|--not|(|)|-e <pattern>...] -- <pathspec>... を使ってください。--function-context フラグにより出力行が多すぎる場合、 --show-function と -C フラグを利用してください",
  },
  {
    validate: (cmd: string) => {
      const gitGrepMatch = /^git\s+grep\s+/.test(cmd);
      const hasRequiredFlags = /-W|-p|--function-context|--show-function/.test(cmd);
      return gitGrepMatch && !hasRequiredFlags;
    },
    message:
      "git grep では --function-context か --show-function フラグを使ってください。まず --function-context フラグを利用し、結果行が多すぎる場合、 --show-function と [ -C | -A | -B ] フラグを利用してください",
  },
  {
    validate: (cmd: string) => /\bfind\s+.+\s+-name\b/.test(cmd),
    message:
      "find -name の変わりに git ls-files -- <パターン> を使ってください。git ls-files -o --exclude-standard を使うと、未追跡のファイルも確認できます。チェックアウトしていないコミットを確認するときは --with-tree=<tree-ish> でコミットを指定してください",
  },
  {
    validate: (cmd: string) => /^git\s+ls-files\b.*\|\s*xargs\s+(git\s+)?grep/.test(cmd),
    message:
      "git ls-files を xargs へパイプして使うのではなく、git grep --show-function [-C|-A|-B] -- <path...> を使ってください。xargs は不要です",
  },
  {
    validate: (cmd: string) => /^cd/.test(cmd),
    message:
      "cd コマンドは使わないでください。例えば yarn の場合 --cwd フラグ、make の場合 -C フラグ、docker compose なら --project-directory フラグが利用できます",
  },
];

function validateCommand(command: string): string[] {
  const issues: string[] = [];
  for (const rule of VALIDATION_RULES) {
    if (rule.validate(command)) {
      issues.push(rule.message);
    }
  }
  return issues;
}

async function main(): Promise<void> {
  try {
    const decoder = new TextDecoder();
    const input = decoder.decode(await readAll(Deno.stdin));
    const inputData: ToolInput = JSON.parse(input);

    const toolName = inputData.tool_name ?? "";
    const toolInput = inputData.tool_input ?? {};
    const command = toolInput.command ?? "";

    if (toolName !== "Bash" || !command) {
      Deno.exit(1);
    }

    const issues = validateCommand(command);

    if (issues.length > 0) {
      for (const message of issues) {
        await Deno.stderr.write(new TextEncoder().encode(`• ${message}\n`));
      }
      Deno.exit(2);
    }
  } catch (error) {
    if (error instanceof SyntaxError) {
      await Deno.stderr.write(
        new TextEncoder().encode(`Error: Invalid JSON input: ${error.message}\n`),
      );
    } else {
      await Deno.stderr.write(
        new TextEncoder().encode(`Error: ${error}\n`),
      );
    }
    Deno.exit(1);
  }
}

if (import.meta.main) {
  main();
}
