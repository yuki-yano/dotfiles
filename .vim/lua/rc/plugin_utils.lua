local list_concat = require('rc.utils').list_concat

local M = {}

M.enabled_inlay_hint = {}
M.enabled_inlay_hint_default_value = false
M.enable_noice = false
M.enable_lsp_lines = vim.env.LSP == 'nvim'

function M.is_loaded_plugin(name)
  local specs = require('lazy').plugins()
  for _, spec in ipairs(specs) do
    if spec.name == name and spec._.loaded then
      return true
    end
  end
  return false
end

function M.is_node_repo()
  if vim.env.TS_RUNTIME == 'deno' then
    return false
  elseif vim.env.TS_RUNTIME == 'node' then
    return true
  end

  local node_root_dir = require('lspconfig').util.root_pattern('package.json')
  return node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil
end

local disable_cmp_filetypes = {}
M.get_disable_cmp_filetypes = function()
  return disable_cmp_filetypes
end
M.add_disable_cmp_filetypes = function(filetypes)
  disable_cmp_filetypes = list_concat({ disable_cmp_filetypes, filetypes })
end

local lsp_lines_status = { mode = 'none', value = false }
M.cycle_lsp_lines = function()
  if lsp_lines_status.mode == 'none' then
    lsp_lines_status = { mode = 'current', value = { only_current_line = true } }
  elseif lsp_lines_status.mode == 'current' then
    lsp_lines_status = { mode = 'all', value = true }
  elseif lsp_lines_status.mode == 'all' then
    lsp_lines_status = { mode = 'none', value = false }
  end
  vim.diagnostic.config({ virtual_lines = lsp_lines_status.value })
end

M.get_lsp_lines_status = function()
  return lsp_lines_status
end

return M
