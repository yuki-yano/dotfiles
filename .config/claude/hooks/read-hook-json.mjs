#!/usr/bin/env node

import { StringDecoder } from "node:string_decoder";

const MAX_INPUT_BYTES = 8 * 1024 * 1024;
const READ_DEADLINE_MS = 1_000;

const decoder = new StringDecoder("utf8");
let input = "";
let inputBytes = 0;
let finished = false;

function isCompleteHookInput(value) {
  try {
    const parsed = JSON.parse(value);
    return parsed !== null && typeof parsed === "object" && !Array.isArray(parsed);
  } catch {
    return false;
  }
}

function finish(output = "") {
  if (finished) return;
  finished = true;
  clearTimeout(deadline);
  process.stdin.removeAllListeners();
  process.stdin.destroy();
  if (output) process.stdout.write(output);
}

function finishIfComplete() {
  if (!isCompleteHookInput(input)) return false;
  finish(input);
  return true;
}

process.stdin.on("data", (chunk) => {
  inputBytes += chunk.length;
  if (inputBytes > MAX_INPUT_BYTES) {
    finish();
    return;
  }

  input += decoder.write(chunk);
  finishIfComplete();
});

process.stdin.once("end", () => {
  input += decoder.end();
  if (!finishIfComplete()) finish();
});

process.stdin.once("error", () => finish());

const deadline = setTimeout(() => finishIfComplete() || finish(), READ_DEADLINE_MS);
process.stdin.resume();
