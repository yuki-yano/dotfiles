#!/usr/bin/env -S deno run -A

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title ChatGPT Search
// @raycast.packageName ChatGPT Search Package
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔍
// @raycast.argument1 { "type": "text", "placeholder": "Search Query", "width": "large", "optional": true }
// @raycast.argument2 { "type": "dropdown", "placeholder": "Model", "data": [{ "title": "4o", "value": "4o" }, { "title": "o1-mini", "value": "o1-mini" }, { "title": "o1", "value": "o1" }], "optional": true }

// Documentation:
// @raycast.description Open a new tab with ChatGPT search results
// @raycast.author Yuki Yano

const query = encodeURIComponent(Deno.args[0]);
if (query === "") {
  const command = new Deno.Command("open", {
    args: ["-a", "Brave Browser", "https://chatgpt.com"],
  });
  await command.output();
  Deno.exit();
}

const model = Deno.args[1];
const encodedQuery = query === "" ? undefined : encodeURIComponent(query);
const encodedModel = model === "" ? undefined : encodeURIComponent(model);
const queryToParam = query === "" ? "" : `&query=${encodedQuery}`;
const targetModel = model === "" ? "" : `&targetModel=${encodedModel}`;

const url = `https://chatgpt.com/?${queryToParam}${targetModel}`;

const command = new Deno.Command("open", {
  args: ["-a", "Brave Browser", url],
});

await command.output();
