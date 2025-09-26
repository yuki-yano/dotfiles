#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env

import { readAll } from "jsr:@std/io@0.224.0/read-all";
import { existsSync } from "jsr:@std/fs@1.0.8/exists";

interface ToolOutput {
  tool_name?: string;
  tool_input?: {
    file_path?: string;
    [key: string]: unknown;
  };
  tool_output?: {
    [key: string]: unknown;
  };
}

async function ensureEOL(filePath: string): Promise<boolean> {
  try {
    // ファイルが存在しない場合はスキップ
    if (!existsSync(filePath)) {
      return false;
    }

    // バイナリファイルやシンボリックリンクはスキップ
    const fileInfo = Deno.statSync(filePath);
    if (fileInfo.isSymlink) {
      return false;
    }

    // ファイルを読み込む
    const content = await Deno.readFile(filePath);

    // 空ファイルはスキップ
    if (content.length === 0) {
      return false;
    }

    // 最後の文字が改行でない場合は追加
    const lastByte = content[content.length - 1];
    if (lastByte !== 0x0A) { // \n (LF)
      // 改行を追加
      const newContent = new Uint8Array(content.length + 1);
      newContent.set(content);
      newContent[content.length] = 0x0A;

      await Deno.writeFile(filePath, newContent);

      await Deno.stderr.write(
        new TextEncoder().encode(`✓ Added EOL to ${filePath}\n`),
      );
      return true;
    }

    return false;
  } catch (error) {
    // ファイルが読めない場合（権限がない、バイナリファイルなど）は無視
    if (error instanceof Deno.errors.PermissionDenied) {
      return false;
    }

    await Deno.stderr.write(
      new TextEncoder().encode(`Warning: Could not check EOL for ${filePath}: ${error}\n`),
    );
    return false;
  }
}

async function main(): Promise<void> {
  try {
    const decoder = new TextDecoder();
    const input = decoder.decode(await readAll(Deno.stdin));
    const outputData: ToolOutput = JSON.parse(input);

    const toolName = outputData.tool_name ?? "";
    const toolInput = outputData.tool_input ?? {};

    // Edit, MultiEdit, Write ツールの場合のみ処理
    if (!["Edit", "MultiEdit", "Write"].includes(toolName)) {
      Deno.exit(0);
    }

    // ファイルパスを取得
    const filePath = toolInput.file_path;
    if (typeof filePath !== "string" || !filePath) {
      Deno.exit(0);
    }

    // ユーザーのホームディレクトリを展開
    const expandedPath = filePath.replace(/^~/, Deno.env.get("HOME") ?? "");

    // 特定の拡張子のファイルはスキップ（バイナリや画像ファイルなど）
    const skipExtensions = [
      ".png",
      ".jpg",
      ".jpeg",
      ".gif",
      ".bmp",
      ".svg",
      ".ico",
      ".zip",
      ".tar",
      ".gz",
      ".bz2",
      ".xz",
      ".7z",
      ".pdf",
      ".doc",
      ".docx",
      ".xls",
      ".xlsx",
      ".mp3",
      ".mp4",
      ".avi",
      ".mov",
      ".mkv",
      ".exe",
      ".dll",
      ".so",
      ".dylib",
      ".pyc",
      ".class",
      ".o",
      ".a",
    ];

    const lowerPath = expandedPath.toLowerCase();
    if (skipExtensions.some((ext) => lowerPath.endsWith(ext))) {
      Deno.exit(0);
    }

    // EOL確認と追加
    await ensureEOL(expandedPath);
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
    // エラーがあってもClaudeの処理は続行させる
    Deno.exit(0);
  }
}

if (import.meta.main) {
  main();
}

