#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env

import { dirname, join } from "jsr:@std/path@1";

export const START_MARKER = "# dotfiles-managed:start";
export const END_MARKER = "# dotfiles-managed:end";

type ApplyCodexTemplateOptions = {
  templateDir?: string;
  outputDir?: string;
  startMarker?: string;
  endMarker?: string;
  dryRun?: boolean;
  copyTargets?: string[];
};

export class CodexTemplateApplyError extends Error {
  readonly details: string[];

  constructor(message: string, details: string[] = []) {
    super(message);
    this.name = "CodexTemplateApplyError";
    this.details = details;
  }
}

export function formatCodexTemplateApplyError(error: CodexTemplateApplyError): string {
  const lines = [
    "Codex template apply failed.",
    `- ${error.message}`,
  ];

  if (error.details.length > 0) {
    lines.push("- How to fix:");
    lines.push(...error.details.map((line) => `  ${line}`));
  }

  return lines.join("\n");
}

function escapeForRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export function stripNvimDirectiveLines(templateBody: string): string {
  return templateBody
    .split("\n")
    .filter((line) => !/^\s*#\s*@nvim\b/.test(line))
    .join("\n");
}

async function collectRelativeFilePaths(rootDirectory: string, prefix = ""): Promise<string[]> {
  const currentDirectory = prefix ? join(rootDirectory, prefix) : rootDirectory;
  const files: string[] = [];

  for await (const entry of Deno.readDir(currentDirectory)) {
    const nextPrefix = prefix ? join(prefix, entry.name) : entry.name;
    if (entry.isDirectory) {
      files.push(...await collectRelativeFilePaths(rootDirectory, nextPrefix));
      continue;
    }
    if (entry.isFile) {
      files.push(nextPrefix);
      continue;
    }
    throw new CodexTemplateApplyError(
      "Template copy target contains unsupported entry type.",
      [
        `Path: ${join(rootDirectory, nextPrefix)}`,
        "Only regular files and directories are supported.",
      ],
    );
  }

  return files.sort();
}

function normalizeManagedSection(
  templateBody: string,
  startMarker: string,
  endMarker: string,
): string {
  if (templateBody.includes(startMarker) || templateBody.includes(endMarker)) {
    throw new CodexTemplateApplyError(
      "Template config.toml must not include managed markers.",
      [
        "Remove the marker lines from template.",
        `Marker start: ${startMarker}`,
        `Marker end:   ${endMarker}`,
        "Markers must exist only in ~/.codex/config.toml.",
      ],
    );
  }

  const normalizedBody = templateBody.trim().replace(/\n+$/, "");
  return `${startMarker}\n${normalizedBody}\n${endMarker}`;
}

function normalizeTrailingNewline(content: string): string {
  return `${content.replace(/\n+$/, "")}\n`;
}

export function stripManagedSection(
  content: string,
  startMarker = START_MARKER,
  endMarker = END_MARKER,
): string {
  if (content.length === 0) {
    return "";
  }

  const managedSectionRegex = new RegExp(
    `${escapeForRegex(startMarker)}[\\s\\S]*?${escapeForRegex(endMarker)}\\n*`,
    "g",
  );
  const stripped = content
    .replace(managedSectionRegex, "")
    .replace(/^\n+/, "")
    .replace(/\n+$/, "");

  if (stripped.length === 0) {
    return "";
  }

  return `${stripped}\n`;
}

function ensureManagedMarkersInTarget(
  existing: string,
  startMarker = START_MARKER,
  endMarker = END_MARKER,
): void {
  const startIndex = existing.indexOf(startMarker);
  const endIndex = existing.indexOf(endMarker);
  if (startIndex === -1 || endIndex === -1 || startIndex > endIndex) {
    throw new CodexTemplateApplyError(
      "Target ~/.codex/config.toml is missing managed markers or marker order is invalid.",
      [
        "Open ~/.codex/config.toml and add this block:",
        startMarker,
        "# managed by dotfiles",
        endMarker,
      ],
    );
  }
}

export function applyManagedTemplateToTarget(
  existing: string,
  templateBody: string,
  startMarker = START_MARKER,
  endMarker = END_MARKER,
): string {
  ensureManagedMarkersInTarget(existing, startMarker, endMarker);
  const managedSection = normalizeManagedSection(templateBody, startMarker, endMarker);
  const managedRegex = new RegExp(
    `${escapeForRegex(startMarker)}[\\s\\S]*?${escapeForRegex(endMarker)}`,
  );
  return normalizeTrailingNewline(existing.replace(managedRegex, managedSection));
}

async function readTextFileIfExists(path: string): Promise<string> {
  try {
    return await Deno.readTextFile(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return "";
    }
    throw error;
  }
}

async function writeTextFileAtomically(path: string, content: string): Promise<void> {
  const directory = dirname(path);
  const temporaryPath = join(directory, `.tmp-${crypto.randomUUID()}`);

  await Deno.mkdir(directory, { recursive: true });
  await Deno.writeTextFile(temporaryPath, content, { mode: 0o600 });
  await Deno.rename(temporaryPath, path);
}

function resolveCodexHome(): string {
  const home = Deno.env.get("HOME");
  if (!home) {
    throw new Error("HOME environment variable is not set");
  }
  return `${home}/.codex`;
}

async function updateFileIfNeeded(
  path: string,
  nextContent: string,
  dryRun = false,
): Promise<boolean> {
  const current = await readTextFileIfExists(path);
  if (current === nextContent) {
    console.log(`No changes: ${path}`);
    return false;
  }

  if (dryRun) {
    console.log(`[DRY RUN] Would update ${path}`);
    return true;
  }

  await writeTextFileAtomically(path, nextContent);
  console.log(`Updated ${path}`);
  return true;
}

async function updateTemplateTextFileIfNeeded(
  templatePath: string,
  outputPath: string,
  dryRun = false,
): Promise<boolean> {
  const templateBody = await Deno.readTextFile(templatePath);
  const normalized = normalizeTrailingNewline(stripNvimDirectiveLines(templateBody));
  return await updateFileIfNeeded(outputPath, normalized, dryRun);
}

async function applyCopyTarget(
  templateDir: string,
  outputDir: string,
  copyTarget: string,
  dryRun = false,
): Promise<boolean> {
  const templatePath = join(templateDir, copyTarget);

  let templateStat: Deno.FileInfo;
  try {
    templateStat = await Deno.stat(templatePath);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      throw new CodexTemplateApplyError(
        "Template copy target was not found.",
        [
          `Missing target: ${templatePath}`,
          "Create the file or directory under .config/codex-template.",
        ],
      );
    }
    throw error;
  }

  if (templateStat.isFile) {
    const outputPath = join(outputDir, copyTarget);
    return await updateTemplateTextFileIfNeeded(templatePath, outputPath, dryRun);
  }

  if (templateStat.isDirectory) {
    const relativeFiles = await collectRelativeFilePaths(templatePath);
    let hasChanged = false;
    for (const relativeFilePath of relativeFiles) {
      const sourcePath = join(templatePath, relativeFilePath);
      const destinationPath = join(outputDir, copyTarget, relativeFilePath);
      const changed = await updateTemplateTextFileIfNeeded(sourcePath, destinationPath, dryRun);
      hasChanged = hasChanged || changed;
    }
    return hasChanged;
  }

  throw new CodexTemplateApplyError(
    "Template copy target must be a file or directory.",
    [`Target: ${templatePath}`],
  );
}

export async function applyCodexTemplate(options: ApplyCodexTemplateOptions = {}): Promise<boolean> {
  const startMarker = options.startMarker ?? START_MARKER;
  const endMarker = options.endMarker ?? END_MARKER;
  const templateDir = options.templateDir ?? `${Deno.cwd()}/.config/codex-template`;
  const outputDir = options.outputDir ?? resolveCodexHome();
  const copyTargets = [...new Set(options.copyTargets ?? ["AGENTS.md"])];

  const configTemplatePath = join(templateDir, "config.toml");
  const configOutputPath = join(outputDir, "config.toml");

  const configTemplateBody = stripNvimDirectiveLines(await Deno.readTextFile(configTemplatePath));
  const currentConfig = await Deno.readTextFile(configOutputPath).catch((error: unknown) => {
    if (error instanceof Deno.errors.NotFound) {
      throw new CodexTemplateApplyError(
        "Target ~/.codex/config.toml was not found.",
        [
          `Create file: ${configOutputPath}`,
          "Then add this block:",
          startMarker,
          "# managed by dotfiles",
          endMarker,
        ],
      );
    }
    throw error;
  });
  const mergedConfig = applyManagedTemplateToTarget(
    currentConfig,
    configTemplateBody,
    startMarker,
    endMarker,
  );

  const configChanged = await updateFileIfNeeded(configOutputPath, mergedConfig, options.dryRun);
  let copiedChanged = false;
  for (const copyTarget of copyTargets) {
    const changed = await applyCopyTarget(templateDir, outputDir, copyTarget, options.dryRun);
    copiedChanged = copiedChanged || changed;
  }

  return configChanged || copiedChanged;
}

function parseCliArgs(args: string[]): ApplyCodexTemplateOptions {
  const options: ApplyCodexTemplateOptions = {};

  for (let index = 0; index < args.length; index++) {
    const current = args[index];

    if (current === "--dry-run") {
      options.dryRun = true;
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
    const options = parseCliArgs(Deno.args);
    await applyCodexTemplate(options);
  } catch (error) {
    if (error instanceof CodexTemplateApplyError) {
      console.error(formatCodexTemplateApplyError(error));
      Deno.exit(1);
    }
    throw error;
  }
}
