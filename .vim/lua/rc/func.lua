local M = {}

-- EscEsc
M.escesc = {
  function()
    vim.cmd([[echo '']])
  end,
}
vim.api.nvim_create_user_command('EscEsc', function()
  for _, v in ipairs(M.escesc) do
    v()
  end
end, {})
vim.keymap.set({ 'n' }, '<Esc><Esc>', '<Cmd>nohlsearch<CR><Cmd>EscEsc<CR>')

-- Reset scroll
vim.on_key(function(key)
  if vim.fn.mode() ~= 'n' then
    return
  end

  local c_d = vim.api.nvim_replace_termcodes('<C-d>', true, true, true)
  local c_u = vim.api.nvim_replace_termcodes('<C-u>', true, true, true)
  if key == c_d or key == c_u then
    vim.opt.scroll = 0
  end
end, nil)

-- Auto mkdir
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if
      vim.fn.isdirectory(dir) == 0 and vim.fn.input(string.format('"%s" does not exist. Create? [y/N]', dir)) == 'y'
    then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- Toggle line number
vim.g.enable_number = true
vim.g.enable_relative_number = true

local function set_number(current)
  local winnrs = current and { vim.fn.winnr() } or vim.fn.range(1, vim.fn.winnr('$'))
  for _, winnr in ipairs(winnrs) do
    local winid = vim.fn.win_getid(winnr)
    if vim.api.nvim_win_get_config(winid).relative ~= '' then
      break
    end

    if not vim.g.enable_number and not vim.g.enable_relative_number then
      vim.fn.setwinvar(winid, '&number', 0)
      vim.fn.setwinvar(winid, '&relativenumber', 0)
    elseif vim.g.enable_number and not vim.g.enable_relative_number then
      vim.fn.setwinvar(winid, '&number', 1)
      vim.fn.setwinvar(winid, '&relativenumber', 0)
    elseif vim.g.enable_number and vim.g.enable_relative_number then
      vim.fn.setwinvar(winid, '&number', 1)
      vim.fn.setwinvar(winid, '&relativenumber', 1)
    end
  end
end

local function toggle_number()
  if not vim.g.enable_number and not vim.g.enable_relative_number then
    vim.g.enable_number = true
  elseif vim.g.enable_number and not vim.g.enable_relative_number then
    vim.g.enable_relative_number = true
  elseif vim.g.enable_number and vim.g.enable_relative_number then
    vim.g.enable_number = false
    vim.g.enable_relative_number = false
  end
  set_number(false)
end

local function enable_number()
  vim.g.enable_number = true
  vim.g.enable_relative_number = false
  set_number(false)
end

local function enable_relative_number()
  vim.g.enable_number = true
  vim.g.enable_relative_number = false
  set_number(false)
end

local function disable_number()
  vim.g.enable_number = false
  vim.g.enable_relative_number = false
  set_number(false)
end

vim.api.nvim_create_user_command('ToggleNumber', toggle_number, {})
vim.api.nvim_create_user_command('EnableNumber', enable_number, {})
vim.api.nvim_create_user_command('EnableRelativeNumber', enable_relative_number, {})
vim.api.nvim_create_user_command('DisableNumber', disable_number, {})

vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
  pattern = '*',
  callback = function()
    if vim.fn.empty(vim.api.nvim_win_get_config(vim.fn.win_getid()).relative) == 0 then
      return
    end

    if vim.fn.filereadable(vim.fn.expand('#' .. vim.fn.bufnr('') .. ':p')) then
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
    end
  end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = '*',
  callback = function()
    if vim.fn.filereadable(vim.fn.expand('#' .. vim.fn.bufnr('') .. ':p')) then
      set_number(true)
    end
  end,
})

-- Add qf to current line
vim.api.nvim_create_user_command('AddQf', function(opts)
  local filename = vim.fn.expand('%:p')
  for i = opts.line1, opts.line2 do
    vim.fn.setqflist({ { filename = filename, lnum = i, text = vim.fn.getline(i) } }, 'a')
  end
  vim.cmd([[copen]])
end, { range = true })

-- My Normal
vim.api.nvim_create_user_command('Normal', function(opts)
  local code = vim.api.nvim_replace_termcodes(opts.args, true, true, true)
  local normal = opts.bang and 'normal!' or 'normal'
  for i = opts.line1, opts.line2 do
    vim.cmd(i .. normal .. ' ' .. code)
  end
end, { nargs = 1, range = true, bang = true })

-- Execute <Plug> map
local function execute_map(key, mode)
  if mode == 'i' then
    vim.cmd([[startinsert]])
  end

  local map = vim.api.nvim_replace_termcodes(key, true, true, true)
  vim.api.nvim_feedkeys(map, '', false)
end

local function get_nmap(_, _, _)
  local map = {}
  for _, v in ipairs(vim.api.nvim_get_keymap('n')) do
    table.insert(map, v.lhs)
  end
  return map
end

local function get_imap(_, _, _)
  local map = {}
  for _, v in ipairs(vim.api.nvim_get_keymap('i')) do
    table.insert(map, v.lhs)
  end
  return map
end

vim.api.nvim_create_user_command('ExecuteNMap', function(opts)
  execute_map(opts.args, 'n')
end, { nargs = 1, complete = get_nmap })

vim.api.nvim_create_user_command('ExecuteIMap', function(opts)
  execute_map(opts.args, 'n')
end, { nargs = 1, complete = get_imap })

-- Toggle QuickFix
vim.api.nvim_create_user_command('ToggleQuickFix', function()
  local i = vim.fn.winnr('$')
  vim.cmd([[cclose]])

  if i == vim.fn.winnr('$') then
    vim.cmd([[botright copen]])
  end
end, {})
vim.keymap.set({ 'n' }, '<leader>q', '<Cmd>ToggleQuickFix<CR>')

-- Toggle LocationList
vim.api.nvim_create_user_command('ToggleLocationList', function()
  local i = vim.fn.winnr('$')
  vim.cmd([[lclose]])

  if i == vim.fn.winnr('$') then
    local status, _ = pcall(vim.cmd, 'botright lopen')
    if not status then
      vim.cmd([[
        echohl ErrorMsg
        echomsg 'No LocationList'
        echohl None
      ]])
    end
  end
end, {})
vim.keymap.set({ 'n' }, '<leader>l', '<Cmd>ToggleLocationList<CR>')

-- Deno fmt
vim.api.nvim_create_user_command('DenoFmt', function(opts)
  local ft_map = {
    typescript = 'ts',
    typescriptreact = 'tsx',
    javascript = 'js',
    javascriptreact = 'jsx',
    markdown = 'md',
    json = 'json',
    jsonc = 'jsonc',
  }
  local ft = ft_map[vim.o.filetype]
  if ft == nil then
    vim.notify('Not support filetype "' .. vim.o.filetype .. '"', vim.log.levels.ERROR, { title = 'DenoFmt' })
    return
  end

  vim.cmd(opts.line1 .. ',' .. opts.line2 .. '!deno fmt --ext=' .. ft .. ' -')
end, { range = '%' })

-- VSCode
vim.api.nvim_create_user_command('VSCode', function()
  local full_path = vim.fn.expand('%:p')
  vim.notify('Open ' .. full_path .. ' in VSCode', vim.log.levels.INFO, { title = 'Open VSCode' })

  -- for Mac
  vim.cmd('!open vscode://file/' .. full_path .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.'))
end, {})

-- Interrupt large js file
vim.cmd([[autocmd BufEnter *.js if getfsize(@%) > 1024 * 1024 | set syntax=OFF | call interrupt() | endif]])

-- HelpEdit, HelpView
vim.api.nvim_create_user_command('HelpEdit', function()
  vim.cmd([[setlocal buftype= modifiable noreadonly]])
  vim.cmd([[setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78]])
  vim.cmd([[setlocal colorcolumn=+1]])
  vim.cmd([[setlocal conceallevel=0]])
end, {})

vim.api.nvim_create_user_command('HelpView', function()
  vim.cmd([[setlocal buftype=help nomodifiable readonly]])
  vim.cmd([[setlocal nolist]])
  vim.cmd([[setlocal colorcolumn=]])
  vim.cmd([[setlocal conceallevel=2]])
end, {})

return M
