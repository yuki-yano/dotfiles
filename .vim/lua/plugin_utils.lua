local list_concat = require('utils').list_concat

local M = {}

M.enable_noice = false
M.enable_lsp_lines = true

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
