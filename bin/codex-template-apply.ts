#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run=/usr/bin/plutil

import { dirname, join } from "@std/path";
import { parse } from "@std/toml";

export const START_MARKER = "# dotfiles-managed:start";
export const END_MARKER = "# dotfiles-managed:end";
const CHATGPT_APP_VERSION_TOKEN = "{{CHATGPT_APP_VERSION}}";

type ApplyCodexTemplateOptions = {
  templateDir?: string;
  outputDir?: string;
  startMarker?: string;
  endMarker?: string;
  dryRun?: boolean;
  overwriteManaged?: boolean;
  copyTargets?: string[];
  chatgptAppPath?: string;
};

export class CodexTemplateApplyError extends Error {
  readonly details: string[];
  readonly managedDiff?: string;

  constructor(message: string, details: string[] = [], managedDiff?: string) {
    super(message);
    this.name = "CodexTemplateApplyError";
    this.details = details;
    this.managedDiff = managedDiff;
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

  if (error.managedDiff) {
    lines.push("", "Managed section diff (current -> rendered template):", error.managedDiff);
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

function renderTemplateText(templateBody: string): string {
  return stripNvimDirectiveLines(templateBody).replace(
    /(^|[\s"'`])~(?=\/|["'`]|$)/gm,
    (_match, prefix: string) => `${prefix}${resolveHome()}`,
  );
}

async function renderConfigTemplate(
  templateBody: string,
  chatgptAppPath: string,
): Promise<string> {
  const rendered = renderTemplateText(templateBody);
  if (!rendered.includes(CHATGPT_APP_VERSION_TOKEN)) {
    return rendered;
  }

  const infoPath = join(chatgptAppPath, "Contents", "Info.plist");
  let version: string;
  try {
    const result = await new Deno.Command("/usr/bin/plutil", {
      args: ["-extract", "CFBundleShortVersionString", "raw", "-o", "-", infoPath],
      stdout: "piped",
      stderr: "piped",
    }).output();
    const decoder = new TextDecoder();
    if (!result.success) {
      throw new Error(
        decoder.decode(result.stderr).trim() || decoder.decode(result.stdout).trim() ||
          `plutil exited with code ${result.code}`,
      );
    }
    version = decoder.decode(result.stdout).trim();
  } catch (error) {
    throw new CodexTemplateApplyError(
      "Could not read the ChatGPT app version.",
      [`Info.plist: ${infoPath}`, String(error), "Ensure the ChatGPT app is installed and its Info.plist is readable."],
    );
  }

  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    throw new CodexTemplateApplyError(
      "The ChatGPT app version is invalid.",
      [`Info.plist: ${infoPath}`, `CFBundleShortVersionString: ${JSON.stringify(version)}`],
    );
  }

  const configBody = rendered.replaceAll(CHATGPT_APP_VERSION_TOKEN, version);
  let browserServicePath: string;
  try {
    const config = parse(configBody) as {
      mcp_servers?: { node_repl?: { env?: { NODE_REPL_TRUSTED_SERVICES?: unknown } } };
    };
    const trustedServices = config.mcp_servers?.node_repl?.env?.NODE_REPL_TRUSTED_SERVICES;
    if (typeof trustedServices !== "string") {
      throw new Error("NODE_REPL_TRUSTED_SERVICES must be a JSON string containing a browser service path.");
    }
    const browser: unknown = JSON.parse(trustedServices).browser;
    if (typeof browser !== "string" || browser.length === 0) {
      throw new Error("NODE_REPL_TRUSTED_SERVICES.browser must be a non-empty string.");
    }
    browserServicePath = browser;
  } catch (error) {
    throw new CodexTemplateApplyError("The browser service configuration is invalid.", [String(error)]);
  }

  try {
    if (!(await Deno.stat(browserServicePath)).isFile) {
      throw new Error("The browser service path is not a regular file.");
    }
  } catch (error) {
    throw new CodexTemplateApplyError(
      "The browser service for the ChatGPT app version is unavailable.",
      [
        `ChatGPT app version: ${version}`,
        `Browser service: ${browserServicePath}`,
        String(error),
        "Launch the updated ChatGPT app to initialize its bundled browser plugin, then retry.",
      ],
    );
  }

  console.log(`ChatGPT app version: ${version}`);
  return configBody;
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

function isTomlTable(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value) && !(value instanceof Date);
}

function tomlValuesEqual(current: unknown, template: unknown): boolean {
  if (current instanceof Date && template instanceof Date) {
    return current.getTime() === template.getTime();
  }
  if (Array.isArray(current) && Array.isArray(template)) {
    return current.length === template.length &&
      current.every((value, index) => tomlValuesEqual(value, template[index]));
  }
  if (isTomlTable(current) && isTomlTable(template)) {
    return Object.keys(current).length === Object.keys(template).length &&
      Object.entries(current).every(([key, value]) =>
        Object.hasOwn(template, key) && tomlValuesEqual(value, template[key])
      );
  }
  return Object.is(current, template);
}

function collectManagedChanges(
  current: Record<string, unknown>,
  template: Record<string, unknown>,
  prefix: string[] = [],
): string[] {
  const settings: string[] = [];
  for (const [key, value] of Object.entries(current)) {
    const path = [...prefix, /^[A-Za-z0-9_-]+$/.test(key) ? key : JSON.stringify(key)];
    const exists = Object.hasOwn(template, key);
    if (isTomlTable(value) && isTomlTable(template[key])) {
      settings.push(...collectManagedChanges(value, template[key], path));
    } else if (!exists && isTomlTable(value) && Object.keys(value).length > 0) {
      settings.push(...collectManagedChanges(value, {}, path));
    } else if (!exists || !tomlValuesEqual(value, template[key])) {
      settings.push(path.join("."));
    }
  }
  return settings;
}

function formatManagedSectionDiff(current: string, template: string, outputPath: string, templatePath: string): string {
  const before = current ? current.split(/\r?\n/) : [];
  const after = template ? template.split(/\r?\n/) : [];
  const matches = Array.from({ length: before.length + 1 }, () => new Uint32Array(after.length + 1));
  for (let i = before.length - 1; i >= 0; i--) {
    for (let j = after.length - 1; j >= 0; j--) {
      matches[i][j] = before[i] === after[j]
        ? matches[i + 1][j + 1] + 1
        : Math.max(matches[i + 1][j], matches[i][j + 1]);
    }
  }

  const lines = [
    `--- ${outputPath} (managed section)`,
    `+++ ${templatePath} (rendered)`,
    `@@ -${before.length ? 1 : 0},${before.length} +${after.length ? 1 : 0},${after.length} @@`,
  ];
  let i = 0;
  let j = 0;
  while (i < before.length || j < after.length) {
    if (i < before.length && j < after.length && before[i] === after[j]) {
      lines.push(` ${before[i++]}`);
      j++;
    } else if (i < before.length && (j === after.length || matches[i + 1][j] >= matches[i][j + 1])) {
      lines.push(`-${before[i++]}`);
    } else {
      lines.push(`+${after[j++]}`);
    }
  }
  return lines.join("\n");
}

function ensureManagedChangesReviewed(
  currentConfig: string,
  templateBody: string,
  configOutputPath: string,
  configTemplatePath: string,
  startMarker: string,
  endMarker: string,
  overwriteManaged = false,
): void {
  const currentBody = currentConfig.slice(
    currentConfig.indexOf(startMarker) + startMarker.length,
    currentConfig.indexOf(endMarker),
  ).trim();
  const renderedBody = templateBody.trim();
  let current: Record<string, unknown>;
  let template: Record<string, unknown>;
  try {
    current = parse(currentBody);
    template = parse(renderedBody);
  } catch (error) {
    throw new CodexTemplateApplyError(
      "Could not compare the managed Codex settings.",
      [
        `Target: ${configOutputPath}`,
        `Template: ${configTemplatePath}`,
        String(error),
        "Fix the invalid TOML before applying the template.",
      ],
    );
  }

  const changedSettings = collectManagedChanges(current, template).sort();
  if (changedSettings.length === 0) {
    return;
  }

  const diff = formatManagedSectionDiff(currentBody, renderedBody, configOutputPath, configTemplatePath);
  if (overwriteManaged) {
    console.log("Existing managed settings will be overwritten (--overwrite-managed).");
    console.log(diff);
    return;
  }

  throw new CodexTemplateApplyError(
    "The template would remove or change existing managed settings. No files were written.",
    [
      "Existing settings that would be removed or changed:",
      ...changedSettings.map((setting) => `  ${setting}`),
      "Review the diff below and add any settings you want to keep to the template.",
      "To intentionally overwrite them, rerun the apply command with --overwrite-managed.",
    ],
    diff,
  );
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

function resolveHome(): string {
  const home = Deno.env.get("HOME");
  if (!home) {
    throw new Error("HOME environment variable is not set");
  }
  return home;
}

async function updateFileIfNeeded(
  path: string,
  nextContent: string,
  dryRun = false,
  expectedContent?: string,
): Promise<boolean> {
  const current = await readTextFileIfExists(path);
  if (expectedContent !== undefined && current !== expectedContent) {
    throw new CodexTemplateApplyError(
      "The target config changed while preparing the template. No files were written.",
      [`Target: ${path}`, "Rerun the command to review the latest managed settings."],
    );
  }
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
  const normalized = normalizeTrailingNewline(renderTemplateText(templateBody));
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
  const outputDir = options.outputDir ?? join(resolveHome(), ".codex");
  const copyTargets = [...new Set(options.copyTargets ?? ["AGENTS.md"])];

  const configTemplatePath = join(templateDir, "config.toml");
  const configOutputPath = join(outputDir, "config.toml");

  const configTemplateBody = await renderConfigTemplate(
    await Deno.readTextFile(configTemplatePath),
    options.chatgptAppPath ?? "/Applications/ChatGPT.app",
  );
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
  ensureManagedChangesReviewed(
    currentConfig,
    configTemplateBody,
    configOutputPath,
    configTemplatePath,
    startMarker,
    endMarker,
    options.overwriteManaged,
  );

  const configChanged = await updateFileIfNeeded(configOutputPath, mergedConfig, options.dryRun, currentConfig);
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
