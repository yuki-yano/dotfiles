#!/usr/bin/env -S deno run --allow-read --allow-run --allow-env

import { readAll } from "jsr:@std/io@0.224/read-all";

async function getGitBranch(): Promise<string> {
  try {
    const isGitRepo = new Deno.Command("git", {
      args: ["rev-parse"],
      stdout: "null",
      stderr: "null",
    });
    const { success } = await isGitRepo.output();

    if (!success) return "";

    const branchCmd = new Deno.Command("git", {
      args: ["branch", "--show-current"],
      stdout: "piped",
      stderr: "null",
    });
    const { stdout } = await branchCmd.output();
    const branch = new TextDecoder().decode(stdout).trim();

    if (branch) {
      return branch;
    }

    const hashCmd = new Deno.Command("git", {
      args: ["rev-parse", "--short", "HEAD"],
      stdout: "piped",
      stderr: "null",
    });
    const hashResult = await hashCmd.output();
    const commitHash = new TextDecoder().decode(hashResult.stdout).trim();

    if (commitHash) {
      return ` |  HEAD (${commitHash})`;
    }
  } catch {
  }

  return "";
}

function getTokenCount(transcriptPath: string | null): string {
  if (!transcriptPath) {
    return "_ tokens. (%)";
  }

  try {
    const content = Deno.readTextFileSync(transcriptPath);
    const lines = content.split("\n").slice(-100);

    let totalTokens = 0;
    let foundUsage = false;

    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i];
      if (!line.trim()) continue;

      try {
        const data = JSON.parse(line);
        if (data.type === "assistant" && data.message?.usage) {
          const usage = data.message.usage;
          totalTokens = (usage.input_tokens || 0) +
            (usage.output_tokens || 0) +
            (usage.cache_creation_input_tokens || 0) +
            (usage.cache_read_input_tokens || 0);
          foundUsage = true;
          break;
        }
      } catch {
      }
    }

    if (!foundUsage) {
      return "_ tkns. (%)";
    }

    const COMPACTION_THRESHOLD = 160000;
    const percentage = Math.floor((totalTokens * 100) / COMPACTION_THRESHOLD);

    let tokenDisplay: string;
    if (totalTokens >= 1000) {
      tokenDisplay = `${(totalTokens / 1000).toFixed(1)}K`;
    } else {
      tokenDisplay = totalTokens.toString();
    }

    let color: string;
    if (percentage >= 90) {
      color = "\x1b[31m";
    } else if (percentage >= 70) {
      color = "\x1b[33m";
    } else {
      color = "\x1b[32m";
    }

    return `${tokenDisplay} tkns. (${color}${percentage}%\x1b[0m)`;
  } catch {
    return "_ tkns. (%)";
  }
}

async function main() {
  const stdin = await readAll(Deno.stdin);
  const input = JSON.parse(new TextDecoder().decode(stdin));

  const modelDisplay = input.model?.display_name || "Unknown";
  const currentDir = input.workspace?.current_dir || ".";
  const transcriptPath = input.transcript_path || null;

  const dirName = currentDir.split("/").pop() || currentDir;

  const gitBranch = await getGitBranch();
  const tokenCount = getTokenCount(transcriptPath);

  console.log(`󰚩  ${modelDisplay} |   ${dirName} | 󰘬  ${gitBranch} |   ${tokenCount}`);
}

if (import.meta.main) {
  main().catch((error) => {
    console.error("Error:", error);
    Deno.exit(1);
  });
}
