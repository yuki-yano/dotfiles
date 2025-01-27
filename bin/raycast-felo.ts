#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Felo Search
// @raycast.packageName Felo Search Package
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large", "optional": true }

// Documentation:
// @raycast.description Open a new tab with Felo search results
// @raycast.author Yuki Yano

const query = encodeURIComponent(Deno.args[0]);
if (query === "") {
  const command = new Deno.Command("open", {
    args: ["-a", "Brave Browser", "https://felo.ai"],
  });
  await command.output();
  Deno.exit();
}

const url = `https://felo.ai/ja/search?query=${query}`;

const command = new Deno.Command("open", {
  args: ["-a", "Brave Browser", url],
});

await command.output();
