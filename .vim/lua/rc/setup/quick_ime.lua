local M = {}
local editprompt_lib = require('rc.lib.editprompt')
local quick_ime_lib = require('rc.lib.quick_ime')

M.bufnr = nil
local editprompt_group = vim.api.nvim_create_augroup('Editprompt', { clear = true })
local quick_ime_group = vim.api.nvim_create_augroup('QuickIme', { clear = true })

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1
end

function M.is_quick_ime()
  return vim.env.QUICK_IME == '1' or vim.g.quick_ime == 1
end

function M.is_ime()
  return M.is_editprompt() or M.is_quick_ime()
end

local function apply_mode_opts()
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

local function set_clipboard(text)
  vim.fn.system('pbcopy', text)
end

M.editprompt_send_logs = editprompt_lib.send_logs
M.editprompt_sent_history = editprompt_lib.sent_history
M.editprompt_stash_stack = editprompt_lib.stash_stack

local function get_active_bufnr()
  return (M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr)) and M.bufnr or vim.api.nvim_get_current_buf()
end

local function send_editprompt(opts)
  opts = opts or {}
  opts.bufnr = get_active_bufnr()
  opts.set_clipboard = set_clipboard
  editprompt_lib.send(opts)
end

local function send_editprompt_visual(opts)
  opts = opts or {}
  opts.bufnr = get_active_bufnr()
  opts.set_clipboard = set_clipboard
  editprompt_lib.send_visual(opts)
end

local function quick_ime_detach()
  quick_ime_lib.detach({ bufnr = get_active_bufnr() })
end

local function send_quick_ime()
  local bufnr = get_active_bufnr()
  quick_ime_lib.send({
    bufnr = bufnr,
    set_clipboard = set_clipboard,
    on_detach = function()
      quick_ime_lib.detach({ bufnr = bufnr, clear_buffer = false })
    end,
  })
end

if M.is_editprompt() then
  vim.g.editprompt = 1
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = editprompt_group,
    pattern = { 'markdown' },
    callback = function()
      apply_mode_opts()
      vim.bo.filetype = 'markdown.editprompt'
      vim.cmd('startinsert')
    end,
  })
  vim.keymap.set({ 'n', 'i' }, '<C-g>', '<Cmd>quit!<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'q', function()
    send_editprompt({ source = 'n_q' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, '<CR>', function()
    send_editprompt({ source = 'n_cr' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
    send_editprompt({ source = 'ni_ctrl_c' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, 'g<C-c>', function()
    send_editprompt({ auto_send = false, source = 'ni_g_ctrl_c' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'x' }, '<C-c>', function()
    send_editprompt_visual({ source = 'x_ctrl_c' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'x' }, 'g<C-c>', function()
    send_editprompt_visual({ auto_send = false, source = 'x_g_ctrl_c' })
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'ZZ', function()
    send_editprompt({ source = 'n_zz' })
  end, { silent = true, buffer = true, nowait = true })

  vim.keymap.set('n', '<C-p>', function()
    editprompt_lib.navigate_history(-1, get_active_bufnr())
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<Up>', function()
    editprompt_lib.navigate_history(-1, get_active_bufnr())
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<C-n>', function()
    editprompt_lib.navigate_history(1, get_active_bufnr())
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<Down>', function()
    editprompt_lib.navigate_history(1, get_active_bufnr())
  end, { silent = true, buffer = true, nowait = true })

  vim.keymap.set('i', '<C-p>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-p>'
    end
    editprompt_lib.navigate_history_async(-1, get_active_bufnr())
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<C-n>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-n>'
    end
    editprompt_lib.navigate_history_async(1, get_active_bufnr())
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<Up>', function()
    editprompt_lib.navigate_history_async(-1, get_active_bufnr())
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<Down>', function()
    editprompt_lib.navigate_history_async(1, get_active_bufnr())
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })

  vim.keymap.set('n', '<C-q>', function()
    editprompt_lib.push_stash(get_active_bufnr())
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('i', '<C-q>', function()
    local bufnr = get_active_bufnr()
    vim.schedule(function()
      editprompt_lib.push_stash(bufnr)
    end)
  end, { silent = true, buffer = true, nowait = true })

  local function is_buffer_empty(bufnr)
    return editprompt_lib.is_empty(bufnr)
  end

  local function is_buffer_blank_or_whitespace(bufnr)
    return editprompt_lib.is_blank_or_whitespace(bufnr)
  end

  vim.keymap.set('n', '<C-d>', function()
    if is_buffer_blank_or_whitespace() then
      vim.cmd('quit!')
      return
    end
    editprompt_lib.feed_normal('<C-d>')
  end, { silent = true, buffer = true, nowait = true })

  vim.keymap.set('i', '<C-d>', function()
    if is_buffer_blank_or_whitespace() then
      vim.schedule(function()
        vim.cmd('quit!')
      end)
      return ''
    end
    return '<C-d>'
  end, { silent = true, buffer = true, nowait = true, expr = true })

  local function map_tmux_normal_nav(lhs, dir)
    vim.keymap.set('n', lhs, function()
      if is_buffer_empty() then
        vim.cmd('startinsert')
      end
      pcall(function()
        require('smart-tmux-nav').navigate(dir)
      end)
    end, { silent = true, buffer = true, nowait = true })
  end
  for _, mapping in ipairs({
    { '<C-h>', 'h' },
    { '<C-j>', 'j' },
    { '<C-k>', 'k' },
    { '<C-l>', 'l' },
  }) do
    map_tmux_normal_nav(unpack(mapping))
  end

  local function map_tmux_insert_nav(lhs, fallback, dir)
    vim.keymap.set('i', lhs, function()
      if not is_buffer_empty() then
        return fallback
      else
        pcall(function()
          require('smart-tmux-nav').navigate(dir)
        end)
      end
    end, { silent = true, buffer = true, nowait = true, expr = true })
  end

  for _, mapping in ipairs({
    { '<C-h>', '<BS>', 'h' },
    { '<C-j>', '<C-j>', 'j' },
    { '<C-k>', '<C-k>', 'k' },
    { '<C-l>', '<C-l>', 'l' },
  }) do
    map_tmux_insert_nav(unpack(mapping))
  end
elseif M.is_quick_ime() then
  vim.g.quick_ime = 1
  vim.api.nvim_create_user_command('SendQuickIme', send_quick_ime, {})
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = quick_ime_group,
    pattern = { 'markdown.quickime' },
    callback = function()
      apply_mode_opts()
      vim.cmd('startinsert')
    end,
  })
  vim.api.nvim_create_autocmd({ 'FocusGained' }, {
    group = quick_ime_group,
    callback = function()
      if vim.bo.filetype == 'markdown.quickime' then
        vim.cmd('startinsert')
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    pattern = { '*' },
    group = quick_ime_group,
    callback = function()
      vim.bo.filetype = 'markdown.quickime'
    end,
  })

  vim.keymap.set({ 'n', 'i' }, '<C-g>', quick_ime_detach, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, '<CR>', send_quick_ime, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', send_quick_ime, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'ZZ', send_quick_ime, { silent = true, buffer = true, nowait = true })
else
  vim.g.editprompt = 0
  vim.g.quickime = 0
end

return M
