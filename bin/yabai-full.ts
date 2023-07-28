#!/usr/bin/env -S deno run --unstable -A

import $ from "https://deno.land/x/dax@0.33.0/mod.ts";

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
  display: number;
  "has-focus": boolean;
  "is-floating": boolean;
};

const windows = await $`yabai -m query --windows`.json() as Array<YabaiWindow>;
const window = windows.find((w) => w["has-focus"])!;
const displaySel = window.display;
const display = await $`yabai -m query --displays --display ${displaySel}`.json() as YabaiDisplay;

if (!window["is-floating"]) {
  await $`yabai -m window --toggle float`;
}

await $`yabai -m window --display ${displaySel} --move abs:${display.frame.x}:${display.frame.y}`;
await $`yabai -m window --resize abs:${display.frame.w}:${display.frame.h}`;
