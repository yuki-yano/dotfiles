#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Multi AI Search
// @raycast.packageName Multi AI Search Package
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large" }
// @raycast.argument2 { "type": "text", "placeholder": "Service prefixes", "width": "large", "optional": true }

// Documentation:
// @raycast.description Open a new tab with multi AI search results
// @raycast.author Yuki Yano

type Prefix = typeof defaultPrefixes[number];

const defaultPrefixes = ["g", "f", "p", "c"] as const;
const query = encodeURIComponent(Deno.args[0]);
const arg1 = Deno.args[1];
const prefixes = arg1 ? arg1.split("") as Array<Prefix> : defaultPrefixes;

const services = {
  g: "https://chatgpt.com/?query=",
  f: "https://felo.ai/ja/search?query=",
  p: "https://www.perplexity.ai/?query=",
  c: "https://claude.ai/new?query=",
};

const urls = prefixes.map((prefix) => `${services[prefix]}${query}`);

for (const url of urls) {
  const command = new Deno.Command("open", {
    args: ["-a", "Brave Browser", url],
  });

  await command.output();
}
