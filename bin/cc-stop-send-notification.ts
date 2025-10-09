#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

async function readStdin() {
  if (process.stdin.isTTY) return '';

  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(typeof chunk === 'string' ? chunk : chunk.toString('utf8'));
  }
  return chunks.join('');
}

function safeJsonParse(raw) {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch (error) {
    console.error('JSONのパースに失敗しました');
    return {};
  }
}

function resolveTranscriptPath(rawPath, homeDir) {
  if (typeof rawPath !== 'string' || rawPath.trim() === '') return undefined;
  const trimmed = rawPath.trim();
  if (trimmed.startsWith('~/')) {
    return path.join(homeDir, trimmed.slice(2));
  }
  return trimmed;
}

async function sendNotification(message) {
  if (!message) return;

  const script = `
        on run {notificationTitle, notificationMessage}
          try
            do shell script "afplay /System/Library/Sounds/Glass.aiff"
            display notification notificationMessage with title notificationTitle
          end try
        end run
      `;

  await new Promise((resolve) => {
    const child = spawn('osascript', ['-e', script, 'Claude Code', message], {
      stdio: 'ignore'
    });

    child.on('exit', () => resolve());
    child.on('error', () => resolve());
  });
}

async function main() {
  const rawInput = await readStdin();
  const input = safeJsonParse(rawInput);

  if (!input || !input.transcript_path) {
    process.exit(0);
  }

  const homeDir = process.env.HOME || '';
  const transcriptPath = resolveTranscriptPath(input.transcript_path, homeDir);
  if (!transcriptPath) {
    process.exit(0);
  }

  const allowedBases = [
    path.join(homeDir, '.claude', 'projects'),
    path.join(homeDir, '.config', 'claude', 'projects')
  ];

  const resolvedPath = path.resolve(transcriptPath);
  const isAllowed = allowedBases.some(base => resolvedPath.startsWith(base));
  if (!isAllowed) {
    process.exit(1);
  }

  if (!fs.existsSync(resolvedPath)) {
    process.exit(0);
  }

  const content = fs.readFileSync(resolvedPath, 'utf8');
  const lines = content.split('\n').map(line => line.trim()).filter(Boolean);
  if (lines.length === 0) {
    process.exit(0);
  }

  const lastLine = lines[lines.length - 1];
  let lastMessageContent = '';

  try {
    const transcript = JSON.parse(lastLine);
    lastMessageContent = transcript?.message?.content?.[0]?.text || '';
  } catch (error) {
    process.exit(0);
  }

  if (!lastMessageContent) {
    process.exit(0);
  }

  await sendNotification(lastMessageContent);
}

main().catch(() => process.exit(1));
