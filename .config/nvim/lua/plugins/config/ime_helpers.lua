local M = {}

local function move_cursor_to_start(bufnr)
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

function M.feed_normal(keys)
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(termcodes, 'nx', false)
end

function M.apply_mode_opts()
  if vim.g.quick_ime_opts_applied == 1 then
    return
  end
  vim.g.quick_ime_opts_applied = 1

  vim.g.enable_number = false
  vim.g.enable_relative_number = false
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.wrap = true
  vim.opt.linebreak = true
  vim.opt.showmode = true
  vim.opt.laststatus = 0
  vim.opt.cmdheight = 0
  vim.opt.signcolumn = 'no'

  vim.cmd([[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NonText guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
  ]])
end

function M.move_cursor_to_start(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  move_cursor_to_start(bufnr)
end

return M
