#!/bin/zsh
':' //; exec bun "$0" "$@"
// Load the dotfiles PATH for Raycast before starting Bun.

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

import { $ } from "bun";

process.env.PATH = `${process.env.PATH}:${process.env.HOME}/.local/bin`;

const [mode] = process.argv.slice(2) as [string];

const layouts = {
  main: [
    "id:040232A0-65C5-4350-B338-FD9C807986E7 res:5120x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0",
    "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2624x1696 hz:120 color_depth:8 enabled:true scaling:off origin:(-2624,0) degree:0",
  ],
  pbp: [
    "id:040232A0-65C5-4350-B338-FD9C807986E7 res:2560x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0",
    "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2624x1696 hz:120 color_depth:8 enabled:true scaling:off origin:(-2624,0) degree:0",
  ],
} as const;

const layout = layouts[mode as keyof typeof layouts];

if (!layout) {
  process.exit(1);
}

await $`displayplacer ${layout[0]} ${layout[1]}`;
