#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Felo Search
// @raycast.packageName Felo Search Package
// @raycast.mode compact

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large" }

// Documentation:
// @raycast.description Open a new tab with Felo search results
// @raycast.author Yuki Yano

const query = encodeURIComponent(Deno.args[0]);
const url = `https://felo.ai/ja/search?query=${query}`;

// Open the URL in Brave using Deno.Command
const command = new Deno.Command("open", {
  args: ["-a", "Brave Browser", url],
});

await command.output();
