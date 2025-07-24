#!/usr/bin/env -S deno run --allow-read --allow-env --allow-run

import { join, resolve } from "jsr:@std/path@1.0.8";
import { existsSync } from "jsr:@std/fs@1.0.8/exists";

try {
  const reader = Deno.stdin.readable.getReader();
  const chunks: Uint8Array[] = [];

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
  }
  reader.releaseLock();

  const decoder = new TextDecoder();
  const stdinData = chunks.map((chunk) => decoder.decode(chunk)).join("");
  const input = JSON.parse(stdinData || "{}");

  if (!input.transcript_path) {
    Deno.exit(0);
  }

  const homeDir = Deno.env.get("HOME") || "";
  let transcriptPath = input.transcript_path;

  if (transcriptPath.startsWith("~/")) {
    transcriptPath = join(homeDir, transcriptPath.slice(2));
  }

  const allowedBases = [
    join(homeDir, ".claude", "projects"),
    join(homeDir, ".config", "claude", "projects")
  ];
  const resolvedPath = resolve(transcriptPath);

  const isAllowed = allowedBases.some(base => resolvedPath.startsWith(base));
  if (!isAllowed) {
    Deno.exit(1);
  }

  if (!existsSync(resolvedPath)) {
    Deno.exit(0);
  }

  const content = await Deno.readTextFile(resolvedPath);
  const lines = content.split("\n").filter((line) => line.trim());
  if (lines.length === 0) {
    Deno.exit(0);
  }

  const lastLine = lines[lines.length - 1];
  const transcript = JSON.parse(lastLine);
  const lastMessageContent = transcript?.message?.content?.[0]?.text;

  if (lastMessageContent) {
    const script = `
          on run {notificationTitle, notificationMessage}
            try
              do shell script "afplay /System/Library/Sounds/Glass.aiff"
              display notification notificationMessage with title notificationTitle
            end try
          end run
        `;
    const command = new Deno.Command("osascript", {
      args: ["-e", script, "Claude Code", lastMessageContent],
      stdout: "null",
      stderr: "null",
    });
    await command.output();
  }
} catch (error) {
  Deno.exit(1);
}
