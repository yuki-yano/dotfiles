local M = {}

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

local function get_buffer_text(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local last = #lines
  while last > 1 and lines[last] == '' do
    last = last - 1
  end
  if last < #lines then
    lines = { unpack(lines, 1, last) }
  end
  return table.concat(lines, '\n')
end

local function set_clipboard(text)
  vim.fn.system('pbcopy', text)
end

local function send_editprompt()
  local bufnr = (M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr)) and M.bufnr or vim.api.nvim_get_current_buf()
  local text = get_buffer_text(bufnr)
  local content = ''
  if text ~= '' then
    local lines = vim.split(text, '\n', { plain = true })
    content = table.concat(lines, '\n')
    if content ~= '' and not content:find('\n$') then
      content = content .. '\n'
    end
    set_clipboard(text)
  end

  vim.cmd('startinsert')
  vim.system({ 'editprompt', '--', content }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
        local win = vim.fn.bufwinid(bufnr)
        if win ~= -1 then
          vim.api.nvim_win_set_cursor(win, { 1, 0 }) -- Move cursor back to buffer start
        end
      else
        vim.notify('editprompt failed: ' .. (obj.stderr or 'unknown error'), vim.log.levels.ERROR)
      end
    end)
  end)
end

local function get_env_from_tmux(var)
  local lines = vim.fn.systemlist({ 'tmux', 'show-environment', '-g', var })
  if vim.v.shell_error ~= 0 or not lines or #lines == 0 then
    local fallback = vim.env[var]
    if fallback and fallback ~= '' then
      return fallback
    end
    return nil
  end

  local raw = lines[#lines]
  local eq = raw:find('=')
  if not eq then
    return nil
  end

  local value = raw:sub(eq + 1)
  if not value or value == '' then
    return nil
  end

  value = value:gsub('[\r\n]', '')
  if value == '' then
    return nil
  end

  vim.env[var] = value
  return value
end

local function get_previous_app()
  return get_env_from_tmux('QUICK_IME_RETURN_APP')
end

local function get_previous_window_id()
  return get_env_from_tmux('QUICK_IME_RETURN_WINDOW_ID')
end

local function focus_previous_target()
  if vim.fn.executable('yabai') == 1 then
    local window_id = get_previous_window_id()
    if window_id and window_id ~= '' then
      vim.fn.system({ 'yabai', '-m', 'window', '--focus', window_id })
      if vim.v.shell_error == 0 then
        return
      end
    end
  end

  local app = get_previous_app()
  if not app or app == '' then
    return
  end

  local escaped = app:gsub('"', '\\"')
  vim.fn.jobstart(
    { '/usr/bin/osascript', '-e', string.format('tell application "%s" to activate', escaped) },
    { detach = true }
  )
end

local function quick_ime_detach()
  local tty = vim.fn.systemlist({ 'tmux', 'display-message', '-p', '#{client_tty}' })[1]
  if tty and #tty > 0 then
    vim.fn.jobstart({ 'tmux', 'detach-client', '-t', tty }, { detach = true })
  else
    vim.fn.jobstart({ 'tmux', 'detach-client' }, { detach = true })
  end

  vim.defer_fn(focus_previous_target, 150)
end

local function send_quick_ime()
  local bufnr = (M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr)) and M.bufnr or vim.api.nvim_get_current_buf()
  local text = get_buffer_text(bufnr)
  local content = ''
  if text ~= '' then
    local lines = vim.split(text, '\n', { plain = true })
    content = table.concat(lines, '\n')
    if content ~= '' and not content:find('\n$') then
      content = content .. '\n'
    end
    set_clipboard(text)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  quick_ime_detach()
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
  vim.keymap.set({ 'n' }, 'q', send_editprompt, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', send_editprompt, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'ZZ', send_editprompt, { silent = true, buffer = true, nowait = true })

  local function is_buffer_empty(bufnr)
    return get_buffer_text(bufnr) == ''
  end

  local function map_tmux_normal_nav(lhs, dir)
    vim.keymap.set('n', lhs, function()
      vim.cmd('startinsert')
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
    callback = function()
      vim.bo.filetype = 'markdown.quickime'
    end,
  })

  vim.keymap.set({ 'n', 'i' }, '<C-g>', quick_ime_detach, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', send_quick_ime, { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'ZZ', send_quick_ime, { silent = true, buffer = true, nowait = true })
else
  vim.g.editprompt = 0
  vim.g.quickime = 0
end

return M
