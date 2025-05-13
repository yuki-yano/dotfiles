local list_concat = require('rc.utils').list_concat

local M = {}

M.enabled_inlay_hint = {}
M.enabled_inlay_hint_default_value = false
M.enable_noice = false

function M.has_plugin(name)
  local specs = require('lazy').plugins()
  for _, spec in ipairs(specs) do
    if spec.name == name then
      return true
    end
  end
  return false
end

function M.is_loaded_plugin(name)
  local specs = require('lazy').plugins()
  for _, spec in ipairs(specs) do
    if spec.name == name and spec._.loaded then
      return true
    end
  end
  return false
end

function M.is_node_repo(bufnr)
  bufnr = bufnr or 0
  if vim.env.TS_RUNTIME == 'deno' then
    return false
  elseif vim.env.TS_RUNTIME == 'node' then
    return true
  end

  local found_dirs = vim.fs.find({ 'package.json' }, {
    upward = true,
    path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))),
  })
  if #found_dirs > 0 then
    return true
  end
end

local disable_cmp_filetypes = {}

M.get_disable_cmp_filetypes = function()
  return disable_cmp_filetypes
end

M.add_disable_cmp_filetypes = function(filetypes)
  disable_cmp_filetypes = list_concat({ disable_cmp_filetypes, filetypes })
end

return M
