local M = {}

local lsp_lines_status = { mode = 'current', value = { only_current_line = true } }
M.cycle_lsp_lines = function()
  if lsp_lines_status.mode == 'current' then
    lsp_lines_status = { mode = 'all', value = true }
  elseif lsp_lines_status.mode == 'all' then
    lsp_lines_status = { mode = 'none', value = false }
  elseif lsp_lines_status.mode == 'none' then
    lsp_lines_status = { mode = 'current', value = { only_current_line = true } }
  end
  vim.diagnostic.config({ virtual_lines = lsp_lines_status.value })
end

M.get_lsp_lines_status = function()
  return lsp_lines_status.mode
end

return M
