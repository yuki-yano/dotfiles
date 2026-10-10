#!/bin/zsh
':' //; exec bun "$0" "$@"
// Load the dotfiles PATH for Raycast before starting Bun.

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title shitsurae-resize
// @raycast.packageName shitsurae window resize package
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 🖥️
// @raycast.argument1 { "type": "text", "placeholder": "Width" }
// @raycast.argument2 { "type": "text", "placeholder": "Height" }

// Documentation:
// @raycast.description Resize window with shitsurae
// @raycast.author Yuki Yano
// @raycast.authorURL https://github.com/yuki-yano

import { $ } from "bun";

process.env.PATH = `${process.env.PATH}:${process.env.HOME}/.local/bin`;

const SHITSURAE_BIN = process.env.SHITSURAE_BIN ?? "shitsurae";
const [_width, _height] = process.argv.slice(2) as [string, string];

if (!_width || !_height) {
  process.exit(1);
}

const width = parseInt(_width, 10);
const height = parseInt(_height, 10);

if (Number.isNaN(width) || Number.isNaN(height) || width <= 0 || height <= 0) {
  process.exit(1);
}

type Frame = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type DisplayCurrent = {
  display: {
    frame: Frame;
    visibleFrame: Frame;
  };
};

const { display } = await $`${SHITSURAE_BIN} display current --json`.json() as DisplayCurrent;

const centeredX = display.frame.x + (display.frame.width - width) / 2;
const centeredY = display.frame.y + (display.frame.height - height) / 2;

const relativeX = centeredX - display.visibleFrame.x;
const relativeY = centeredY - display.visibleFrame.y;

await $`${SHITSURAE_BIN} window set -x ${relativeX} -y ${relativeY} -w ${width} -h ${height}`;
