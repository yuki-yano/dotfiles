local M = {}

M.bufnr = nil

function M.is_tmux_yank()
  return vim.env.TMUX_YANK == '1'
end

local function apply_mode_opts()
  if vim.g.tmux_yank_opts_applied == 1 then
    return
  end
  vim.g.tmux_yank_opts_applied = 1

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

local function sync_yank_to_clipboard()
  vim.fn.setreg('+', vim.fn.getreg('"'))
  vim.notify('Copied to OS clipboard.', vim.log.levels.INFO)
end

local function trim_trailing_blank_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local last_nonblank

  for i = #lines, 1, -1 do
    if lines[i]:match('%S') then
      last_nonblank = i
      break
    end
  end

  local new_end = last_nonblank or 1

  if new_end < #lines then
    vim.api.nvim_buf_set_lines(bufnr, new_end, -1, false, {})
  end
end

if M.is_tmux_yank() then
  apply_mode_opts()
  local augroup = vim.api.nvim_create_augroup('rc_tmux_yank', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = sync_yank_to_clipboard,
  })
  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    group = augroup,
    pattern = { '*' },
    callback = function()
      trim_trailing_blank_lines()
      vim.cmd('normal! G')
    end,
  })

  vim.keymap.set({ 'n', 'i' }, '<C-g>', function()
    vim.cmd('quit!')
  end, { silent = true, buffer = true, nowait = true })
end
