#!/usr/bin/env node

const { spawn } = require('child_process');

const DEFAULT_TITLE = 'Codex';
const DEFAULT_MESSAGE = 'Codex task completed';
const DEFAULT_SOUND = '/System/Library/Sounds/Glass.aiff';

async function readStdin() {
  if (process.stdin.isTTY) return '';

  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(typeof chunk === 'string' ? chunk : chunk.toString('utf8'));
  }
  return chunks.join('').trim();
}

function parseJson(raw) {
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch (error) {
    console.error('入力JSONのパースに失敗しました');
    return {};
  }
}

function asString(value) {
  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (trimmed.length > 0) return trimmed;
  }
  return undefined;
}

function extractMessage(payload) {
  const direct = asString(payload['last-assistant-message']);
  if (direct) return direct;

  const messageField = asString(payload.message);
  if (messageField) return messageField;

  const messages = payload.messages;
  if (Array.isArray(messages)) {
    for (let i = messages.length - 1; i >= 0; i -= 1) {
      const entry = messages[i];
      if (!entry || typeof entry !== 'object') continue;
      const { role, content } = entry;
      if (role !== 'assistant') continue;

      if (typeof content === 'string') {
        const text = content.trim();
        if (text.length > 0) return text;
      }

      if (Array.isArray(content)) {
        for (const part of content) {
          if (!part || typeof part !== 'object') continue;
          const text = asString(part.text);
          if (text) return text;
        }
      }
    }
  }

  const transcript = payload.transcript;
  if (transcript && typeof transcript === 'object') {
    const last = transcript.message;
    if (last && typeof last === 'object') {
      const content = last.content;
      if (Array.isArray(content) && content.length > 0) {
        const lastPart = content[content.length - 1];
        if (lastPart && typeof lastPart === 'object') {
          const text = asString(lastPart.text);
          if (text) return text;
        }
      }
    }
  }

  return undefined;
}

function extractTitle(payload) {
  return asString(payload['notification-title']) || asString(payload.title) || DEFAULT_TITLE;
}

function resolveSound(payload) {
  const envValue = asString(process.env.CODEX_NOTIFICATION_SOUND);
  const raw = payload.sound === undefined ? envValue : payload.sound;

  if (raw === false || raw === 0 || raw === 'none') {
    return { enabled: false, path: '' };
  }

  if (raw === true) {
    return { enabled: true, path: DEFAULT_SOUND };
  }

  const soundPath = asString(raw);
  if (soundPath) {
    const normalized = soundPath.toLowerCase();
    if (normalized === 'default' || normalized === 'glass') {
      return { enabled: true, path: DEFAULT_SOUND };
    }
    return { enabled: true, path: soundPath };
  }

  return { enabled: false, path: DEFAULT_SOUND };
}

async function runOsascript(title, message, playSound, soundPath) {
  const scriptLines = [
    'on run {notificationTitle, notificationMessage, playSound, soundPath}',
    '  try',
    '    if playSound is "true" then',
    '      do shell script "afplay " & quoted form of soundPath',
    '    end if',
    '    display notification notificationMessage with title notificationTitle',
    '  end try',
    'end run'
  ];

  await new Promise((resolve) => {
    const child = spawn('osascript', [
      '-e',
      scriptLines.join('\n'),
      title,
      message,
      playSound ? 'true' : 'false',
      soundPath
    ], {
      stdio: 'ignore'
    });

    child.on('exit', () => resolve());
    child.on('error', () => resolve());
  });
}

async function main() {
  if (process.platform !== 'darwin') {
    console.error('macOS以外では通知を送信できません');
    process.exit(0);
  }

  const rawInput = await readStdin();
  const payloadSource = rawInput || process.argv[2] || '';
  const payload = parseJson(payloadSource);

  const message = extractMessage(payload) || DEFAULT_MESSAGE;
  const title = extractTitle(payload);
  const { enabled: playSound, path: soundPath } = resolveSound(payload);

  await runOsascript(title, message, playSound, soundPath);
}

main().catch(() => process.exit(1));
