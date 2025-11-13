#!/usr/bin/env -S deno run --allow-read=/dev/stdin

import { readAll } from "jsr:@std/io@0.224.0/read-all";

const ENABLED = false;

interface ToolInput {
  tool_name?: string;
  tool_input?: {
    pattern?: string;
    [key: string]: unknown;
  };
}

type ValidationRule = {
  validate: (pattern: string) => boolean;
  message: string;
};

const VALIDATION_RULES: ValidationRule[] = [
  {
    validate: (_pattern: string) => true,
    message:
      "git grep --function-context [--and|--or|--not|(|)|-e <pattern>...] -- <pathspec>... を使ってください。--function-context フラグにより出力行が多すぎる場合、 --show-function と -C フラグを利用してください",
  },
];

function validateCommand(pattern: string): string[] {
  const issues: string[] = [];
  for (const rule of VALIDATION_RULES) {
    if (rule.validate(pattern)) {
      issues.push(rule.message);
    }
  }
  return issues;
}

async function main(): Promise<void> {
  if (!ENABLED) {
    Deno.exit(0);
  }

  try {
    const decoder = new TextDecoder();
    const input = decoder.decode(await readAll(Deno.stdin));
    const inputData: ToolInput = JSON.parse(input);

    const toolName = inputData.tool_name ?? "";
    const toolInput = inputData.tool_input ?? {};
    const pattern = toolInput.pattern ?? "";

    if (toolName !== "Grep" || !pattern) {
      Deno.exit(1);
    }

    const issues = validateCommand(pattern);

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
