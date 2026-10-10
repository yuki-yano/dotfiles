#!/usr/bin/env bun

import {
  applyCodexTemplate,
  type ApplyCodexTemplateOptions,
  CodexTemplateApplyError,
  formatCodexTemplateApplyError,
} from "../lib/codex-template.ts";

function parseCliArgs(args: string[]): ApplyCodexTemplateOptions {
  const options: ApplyCodexTemplateOptions = {};

  for (let index = 0; index < args.length; index++) {
    const current = args[index];

    if (current === "--dry-run") {
      options.dryRun = true;
      continue;
    }

    if (current === "--overwrite-managed") {
      options.overwriteManaged = true;
      continue;
    }

    if (current === "--template-dir") {
      const value = args[index + 1];
      if (!value) {
        throw new Error("--template-dir requires a path");
      }
      options.templateDir = value;
      index++;
      continue;
    }

    if (current === "--out-dir") {
      const value = args[index + 1];
      if (!value) {
        throw new Error("--out-dir requires a path");
      }
      options.outputDir = value;
      index++;
      continue;
    }

    throw new Error(`Unknown argument: ${current}`);
  }

  return options;
}

if (import.meta.main) {
  try {
    const options = parseCliArgs(process.argv.slice(2));
    await applyCodexTemplate(options);
  } catch (error) {
    if (error instanceof CodexTemplateApplyError) {
      console.error(formatCodexTemplateApplyError(error));
      process.exit(1);
    }
    throw error;
  }
}
