#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title display-layout
// @raycast.packageName display layout package
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 🖥️
// @raycast.argument1 { "type": "text", "placeholder": "main | pbp" }

// Documentation:
// @raycast.description Switch display layout with displayplacer
// @raycast.author Yuki Yano
// @raycast.authorURL https://github.com/yuki-yano

import $ from "jsr:@david/dax@0.42.0";

Deno.env.set("PATH", `${Deno.env.get("PATH")}:${Deno.env.get("HOME")}/.local/bin`);

const [mode] = Deno.args as [string];

const layouts = {
  main: [
    "id:F46D20D8-7AA5-4FFE-B88A-1820DF9875E6 res:5120x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0",
    "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2624x1696 hz:120 color_depth:8 enabled:true scaling:off origin:(-2624,0) degree:0",
  ],
  pbp: [
    "id:F46D20D8-7AA5-4FFE-B88A-1820DF9875E6 res:2560x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0",
    "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2624x1696 hz:120 color_depth:8 enabled:true scaling:off origin:(-2624,0) degree:0",
  ],
} as const;

const layout = layouts[mode as keyof typeof layouts];

if (!layout) {
  Deno.exit(1);
}

await $`displayplacer ${layout[0]} ${layout[1]}`;
