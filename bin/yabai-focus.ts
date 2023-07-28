#!/usr/bin/env -S deno run --unstable -A

import $ from "https://deno.land/x/dax@0.33.0/mod.ts";

const reversed = Deno.args.includes("-r");

type Yabai = {
  id: number;
  app: string;
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  "is-floating": boolean;
  "has-focus": boolean;
};

const windows = await $`yabai -m query --windows --space`.json() as Array<Yabai>;

let sortedWindows = windows.sort((a, b) => {
  if (a.frame.x < b.frame.x) {
    return -1;
  }
  if (a.frame.x > b.frame.x) {
    return 1;
  }
  if (a.frame.y < b.frame.y) {
    return -1;
  }
  if (a.frame.y > b.frame.y) {
    return 1;
  }
  if (a.frame.w < b.frame.w) {
    return -1;
  }
  if (a.frame.w > b.frame.w) {
    return 1;
  }
  if (a.frame.h < b.frame.h) {
    return -1;
  }

  return 0;
});

if (reversed) {
  sortedWindows = sortedWindows.reverse();
}

let isFocused = false;
for (const window of sortedWindows) {
  if (window["has-focus"]) {
    isFocused = true;
    continue;
  }
  if (!isFocused) {
    continue;
  }

  await $`yabai -m window --focus ${window.id}`;
  Deno.exit(0);
}

// Focus not exist
await $`yabai -m window --focus ${sortedWindows[0].id}`;
Deno.exit(0);
