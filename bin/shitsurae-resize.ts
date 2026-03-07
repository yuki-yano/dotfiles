#!/usr/bin/env -S deno run -A

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

import $ from "jsr:@david/dax@0.45.0";

Deno.env.set("PATH", `${Deno.env.get("PATH")}:${Deno.env.get("HOME")}/.local/bin`);

const SHITSURAE_BIN = Deno.env.get("SHITSURAE_BIN") ?? "shitsurae";
const [_width, _height] = Deno.args as [string, string];

if (!_width || !_height) {
  Deno.exit(1);
}

const width = parseInt(_width, 10);
const height = parseInt(_height, 10);

if (Number.isNaN(width) || Number.isNaN(height) || width <= 0 || height <= 0) {
  Deno.exit(1);
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

await $`${SHITSURAE_BIN} window set --x ${relativeX} --y ${relativeY} --w ${width} --h ${height}`;
