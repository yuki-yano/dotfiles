#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Gemini Search
// @raycast.packageName Gemini Search Package
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large", "optional": true }

// Documentation:
// @raycast.description Open a new tab with Gemini search results
// @raycast.author Yuki Yano

const query = encodeURIComponent(Deno.args[0]);
if (query === "") {
  const command = new Deno.Command("open", {
    args: ["-a", "Brave Browser", "https://gemini.google.com"],
  });
  await command.output();
  Deno.exit();
}

const url = `https://gemini.google.com/app?query=${query}`;

const command = new Deno.Command("open", {
  args: ["-a", "Brave Browser", url],
});

await command.output();
