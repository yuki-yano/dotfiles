-- zero
vim.keymap.set({ 'n', 'o', 'x' }, '0', [[getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^']], { expr = true })
vim.keymap.set({ 'n', 'o', 'x' }, '^', '0')

-- Neovim default <C-w>
vim.keymap.del({ 'i' }, '<C-w>')

-- Buffer
vim.keymap.set({ 'n' }, '<C-q>', '<C-^>')

-- Save
vim.keymap.set({ 'n' }, '<Leader>w', '<Cmd>update<CR>')
vim.keymap.set({ 'n' }, '<Leader>W', '<Cmd>update!<CR>')

-- Automatically indent with i and A
-- NOTE: Use smart-i.nvim
-- vim.keymap.set({ 'n' }, 'i', [[len(getline('.')) ? 'i' : '"_cc']], { expr = true })
-- vim.keymap.set({ 'n' }, 'A', [[len(getline('.')) ? 'A' : '"_cc']], { expr = true })
-- vim.keymap.set({ 'n' }, 'gi', 'i')

-- Split undo history when <CR>
vim.keymap.set('i', '<CR>', '<C-g>u<CR>', { silent = true })

-- Ignore register
vim.keymap.set({ 'n' }, 'x', '"_x')

-- tagjump
-- vim.keymap.set({ 'n' }, 's<C-]>', '<Cmd>wincmd ]<CR>')
-- vim.keymap.set({ 'n' }, 'v<C-]>', '<Cmd>vertical wincmd ]<CR>')
-- vim.keymap.set({ 'n' }, 't<C-]>', '<Cmd>tab wincmd ]<CR>')
-- vim.keymap.set({ 'n' }, 'r<C-]>', '<C-w>}')

-- Quickfix
vim.keymap.set({ 'n' }, '[c', '<Cmd>cprevious<CR>')
vim.keymap.set({ 'n' }, ']c', '<Cmd>cnext<CR>')
vim.keymap.set({ 'n' }, '[q', '<Cmd>colder<CR>')
vim.keymap.set({ 'n' }, ']q', '<Cmd>cnewer<CR>')

-- Location List
vim.keymap.set({ 'n' }, '[l', '<Cmd>lprevious<CR>')
vim.keymap.set({ 'n' }, ']l', '<Cmd>lnext<CR>')

-- InsertMode and CmdlineMode
vim.keymap.set({ 'i', 'c' }, '<C-h>', '<BS>')
vim.keymap.set({ 'i', 'c' }, '<C-d>', '<Del>')
vim.keymap.set({ 'i' }, '<C-a>', '<C-g>U<Home>')
vim.keymap.set({ 'i' }, '<C-b>', '<C-g>U<Left>')
vim.keymap.set({ 'i' }, '<C-f>', '<C-g>U<Right>')

vim.keymap.set({ 'c' }, '<C-b>', '<Left>')
vim.keymap.set({ 'c' }, '<C-f>', '<Right>')
vim.keymap.set({ 'c' }, '<C-a>', '<Home>')
vim.keymap.set({ 'c' }, '<C-n>', '<Down>')
vim.keymap.set({ 'c' }, '<C-p>', '<Up>')

-- Indent
vim.keymap.set({ 'n' }, '<', '<<')
vim.keymap.set({ 'n' }, '>', '>>')
vim.keymap.set({ 'x' }, '<', '<gv')
vim.keymap.set({ 'x' }, '>', '>gv')

-- Focus floating
vim.keymap.set({ 'n' }, '<C-w><C-w>', function()
  if vim.fn.empty(vim.api.nvim_win_get_config(vim.fn.win_getid()).relative) == 0 then
    vim.cmd([[wincmd p]])
    return
  end

  for winnr = 1, vim.fn.winnr('$') do
    local winid = vim.fn.win_getid(winnr)
    local conf = vim.api.nvim_win_get_config(winid)
    if conf.focusable and vim.fn.empty(conf.relative) == 0 then
      vim.fn.win_gotoid(winid)
      return
    end
  end
  vim.cmd([[normal! <C-w><C-w>]])
end)

-- Tab
vim.keymap.set({ 'n' }, '<Plug>(tab)t', '<Cmd>tablast <Bar> tabedit<CR>')
vim.keymap.set({ 'n' }, '<Plug>(tab)d', '<Cmd>tabclose<CR>')
vim.keymap.set({ 'n' }, '<Plug>(tab)h', '<Cmd>tabprevious<CR>')
vim.keymap.set({ 'n' }, '<Plug>(tab)l', '<Cmd>tabnext<CR>')
vim.keymap.set({ 'n' }, '<Plug>(tab)m', '<C-w>T')

-- Resize
vim.keymap.set({ 'n' }, '<Left>', '<Cmd>vertical resize -1<CR>')
vim.keymap.set({ 'n' }, '<Right>', '<Cmd>vertical resize +1<CR>')
vim.keymap.set({ 'n' }, '<Up>', '<Cmd>resize -1<CR>')
vim.keymap.set({ 'n' }, '<Down>', '<Cmd>resize +1<CR>')

-- Macro
vim.keymap.set({ 'n' }, 'Q', '@q')

-- Replace
vim.keymap.set({ 'n' }, '<Leader>r', [[:<C-u>%s/\v//g<Left><Left><Left>]])
vim.keymap.set({ 'x' }, '<Leader>r', [["sy:%s/\v<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>]])

-- C-g
vim.keymap.set({ 'n' }, '<C-g>', '2<C-g>')

-- Clipboard
vim.keymap.set({ 'n' }, 'sc', function()
  vim.fn.setreg('+', vim.fn.getreg('"'))
  vim.notify('Copied to OS clipboard.', vim.log.levels.INFO)
end)

vim.keymap.set({ 'n' }, 'sC', function()
  local md = vim.fn.getreg('"')

  if vim.fn.executable('pandoc') == 0 then
    vim.fn.system({ 'pbcopy' }, md)
    return
  end

  local html = vim.fn.system({ 'pandoc', '-f', 'markdown', '-t', 'html', '--wrap=none' }, md)
  html = html:gsub('"', '\\"'):gsub('\n', '')

  local hex = vim.fn.system(string.format([[printf '%%s' "%s" | hexdump -ve '1/1 "%%02x"']], html)):gsub('%s+$', '')

  local plain = vim.fn.system({ 'pandoc', '-f', 'markdown', '-t', 'plain' }, md)
  plain = plain:gsub('"', '\\"'):gsub('\n', '\\n')

  local script = table.concat({
    'set the clipboard to {',
    '«class HTML»:«data HTML' .. hex .. '», ',
    'string:"' .. plain .. '"}',
  }, '')
  vim.fn.system({ 'osascript', '-e', script })

  vim.notify('Both HTML and plain text have been set to the clipboard.', vim.log.levels.INFO)
end)

vim.keymap.set({ 'n', 'x' }, 'sp', function()
  vim.fn.setreg('"', vim.fn.getreg('+'))
  vim.notify('Copied from OS clipboard to " register', vim.log.levels.INFO)
end)

-- Terminal
vim.keymap.set({ 't' }, '<Esc>', [[<C-\><C-n>]])
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.keymap.set({ 'n' }, 'i', 'i', { buffer = true })
  end,
})

-- quit
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'qf', 'help' },
  callback = function()
    vim.keymap.set({ 'n' }, 'q', '<Cmd>quit<CR>', { buffer = true })
  end,
})

-- Cmdwin
vim.api.nvim_create_autocmd({ 'CmdwinEnter' }, {
  pattern = '*',
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = false

    vim.keymap.set({ 'n' }, '<CR>', '<CR>', { buffer = true })
    vim.keymap.set({ 'n' }, 'q', '<Cmd>q<CR>', { buffer = true, nowait = true })
    vim.keymap.set({ 'i' }, 'q', '<Esc>l<C-c>', { buffer = true })
  end,
})

-- zz
vim.keymap.set('n', 'zz', 'zz<Plug>(z1)')
vim.keymap.set('n', '<Plug>(z1)z', 'zt<Plug>(z2)')
vim.keymap.set('n', '<Plug>(z2)z', 'zb<Plug>(z0)')
vim.keymap.set('n', '<Plug>(z0)z', 'zz<Plug>(z1)')
