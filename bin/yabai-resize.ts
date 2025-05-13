#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title yabai-resize
// @raycast.packageName yabai window resize package
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 🖥️
// @raycast.argument1 { "type": "text", "placeholder": "Width" }
// @raycast.argument2 { "type": "text", "placeholder": "Height" }

// Documentation:
// @raycast.description Resize window from yabai
// @raycast.author Yuki Yano
// @raycast.authorURL https://github.com/yuki-yano

import $ from "jsr:@david/dax@0.42.0";

Deno.env.set("PATH", `${Deno.env.get("PATH")}:${Deno.env.get("HOME")}/.local/bin`);

const [_width, _height] = Deno.args as [string, string];

if (!_width || !_height) {
  Deno.exit(1);
}

const width = parseInt(_width, 10);
const height = parseInt(_height, 10);

type YabaiDisplay = {
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
};

type YabaiWindow = {
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  "is-floating": boolean;
};

const display = await $`yabai -m query --displays --display 1`.json() as YabaiDisplay;
const window = await $`yabai -m query --windows --window`.json() as YabaiWindow;

if (!window["is-floating"]) {
  await $`yabai -m window --toggle float`;
}

await $`yabai -m window --move abs:0:0`;
await $`yabai -m window --resize abs:${width}:${height}`;

const x = display.frame.x + (display.frame.w - width) / 2;
const y = display.frame.y + (display.frame.h - height) / 2;
await $`yabai -m window --move abs:${x}:${y}`;
