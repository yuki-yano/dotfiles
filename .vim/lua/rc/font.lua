-- TODO: Memo char codes

local M = {}

M.diagnostic_icons = {
  error = '󾪇',
  warn = '󾩬',
  info = '󾩴',
  hint = '󾩳',
  success = '󾪲',
}

M.lsp_icons = {
  diagnostic = '󾫘',
  code_action = '',
  incoming = ' ',
  outgoing = ' ',
}

-- TODO: Add more icons
--       - String
--       - Number
--       - Boolean
--       - Package
--       - Namespace
--       - Object
--       - Array
M.codicons = {
  Text = '󾪓 ', -- 0xFEA93
  Method = '󾪌 ', -- 0xFEA8C
  Function = '󾪌 ', -- 0xFEA8C
  Constructor = '󾪌 ', -- 0xFEA8C
  Field = '󾭟 ', -- 0xFEB5F
  Variable = '󾪈 ', -- 0xFEA88
  Class = '󾭛 ', -- 0xFEB5B
  Interface = '󾭡 ', -- 0xFEB61
  Module = '󾪋 ', -- 0xFEA8B
  Property = '󾭥 ', -- 0xFEB65
  Unit = '󾪖 ', -- 0xFEA96
  Value = '󾪕 ', -- 0xFEA95
  Enum = '󾪕 ', -- 0xFEA95
  Keyword = '󾭢 ', -- 0xFEB62
  Snippet = '󾩻 ', -- 0xFEB66
  Color = '󾭜 ', -- 0xFEB5C
  File = '󾩻 ', -- 0xFEA7B
  Reference = '󾪔 ', -- 0xFEA94
  Folder = '󾪃 ', -- 0xFEA83
  EnumMember = '󾪕 ', -- 0xFEA95
  Constant = '󾭝 ', -- 0xFEB5D
  Struct = '󾪑 ', -- 0xFEA91
  Event = '󾪆 ', -- 0xFEA86
  Operator = '󾭤 ', -- 0xFEB64
  TypeParameter = '󾪒 ', -- 0xFEA92
  Null = ' ', -- 0xEBE0
  Copilot = ' ',
}

M.todo_icons = {
  todo = '󾪲',
  fix = '󾫘',
  warn = '󾩬',
  test = '󾮨',
  note = '󾩻',
  pref = '󾪆',
  hack = '',
  delete = '󾪁',
}

M.misc_icons = {
  file = '󾩻',
  folder = '󾪃',
  cmd = '󾪌',
  vim = '',
  lazy = '',
}

return M
