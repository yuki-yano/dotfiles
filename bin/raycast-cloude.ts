#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Claude Search
// @raycast.packageName Claude Search Package
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large", "optional": true }

// Documentation:
// @raycast.description Open a new tab with Claude search results
// @raycast.author Yuki Yano

const query = encodeURIComponent(Deno.args[0]);
if (query === "") {
  const command = new Deno.Command("open", {
    args: ["-a", "Brave Browser", "https://claude.ai"],
  });
  await command.output();
  Deno.exit();
}

const url = `https://claude.ai/new?query=${query}`;

const command = new Deno.Command("open", {
  args: ["-a", "Brave Browser", url],
});

await command.output();
