#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

function readStdin() {
  return fs.readFileSync(0, "utf8");
}

function expandHome(value) {
  if (value === "~") {
    return os.homedir();
  }
  if (value.startsWith("~/")) {
    return path.join(os.homedir(), value.slice(2));
  }
  return value;
}

function main() {
  JSON.parse(readStdin());

  const configuredDirectory = process.env.AGENT_NOTE_DIR;
  if (!configuredDirectory) {
    process.exit(0);
  }

  const absoluteDirectory = path.resolve(expandHome(configuredDirectory));

  let stats;
  try {
    stats = fs.statSync(absoluteDirectory);
  } catch {
    process.exit(0);
  }

  if (!stats.isDirectory()) {
    process.exit(0);
  }

  const lines = [
    "このセッションでは AGENT_NOTE_DIR 配下のメモも参照対象です。",
    "必要に応じて絶対パスで参照してください。",
    `メモディレクトリ: ${absoluteDirectory}`,
    "内容の列挙や要約は行っていません。必要に応じてこのディレクトリ配下を確認してください。",
  ];

  process.stdout.write(`${
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: lines.join("\n"),
      },
    })
  }\n`);
}

main();
