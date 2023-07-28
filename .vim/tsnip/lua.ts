import { Snippet } from "./deps.ts";

const functionName = (name: string | undefined) => {
  if (name?.endsWith(",")) {
    return name.slice(0, -1);
  }
  return name ?? "";
};

const func: Snippet = {
  name: "func",
  text: "function ${1:name}(${2:args})\n\t$0\nend",
  params: [
    {
      name: "name",
      type: "single_line",
    },
    {
      name: "args",
      type: "single_line",
    },
  ],
  render: ({ name, args }, ctx) => {
    return [
      `function ${functionName(name?.text)}(${args?.text ?? ""})`,
      `\t${ctx.postCursor}`,
      `end${name?.text?.endsWith(",") ? "," : ""}`,
    ].join("\n");
  },
};

const command: Snippet = {
  name: "command",
  text: [
    "vim.api.nvim_create_user_command('${1:command}', function(opts)",
    "\t$0",
    "end, {})",
  ].join("\n"),
  params: [
    {
      name: "command",
      type: "single_line",
    },
  ],
  render: ({ command }, ctx) => {
    return [
      `vim.api.nvim_create_user_command('${command?.text ? command.text : ""}', function(opts)`,
      `\t${ctx.postCursor}`,
      `end, {})`,
    ].join("\n");
  },
};

const autocmd: Snippet = {
  name: "autocmd",
  text: [
    "vim.api.nvim_create_autocmd({ '${1:event}' }, {",
    "\tpattern = '${2:pattern}',",
    "\tcallback = function()",
    "\t\t$0",
    "\tend",
    "})",
  ].join("\n"),
  params: [
    {
      name: "event",
      type: "multi_line",
    },
    {
      name: "pattern",
      type: "multi_line",
    },
  ],
  render: ({ event, pattern }, ctx) => {
    const events = event?.text?.split("\n") ?? [];
    const patterns = pattern?.text?.split("\n") ?? [];

    const event_text = events.map((e) => `'${e}'`).join(", ");
    const pattern_text = patterns.map((p) => `'${p}'`).join(", ");

    return [
      `vim.api.nvim_create_autocmd({ ${event_text} }, {`,
      `\tpattern = { ${pattern_text} },`,
      `\tcallback = function()`,
      `\t\t${ctx.postCursor}`,
      `\tend`,
      ` })`,
    ].join("\n");
  },
};

export default {
  func,
  command,
  autocmd,
};
