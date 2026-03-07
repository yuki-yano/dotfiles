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

local function normalize_positions(start_pos, end_pos)
  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3] - 1
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  return start_row, start_col, end_row, end_col
end

local function get_visual_selection(bufnr, mode, start_pos, end_pos)
  start_pos = start_pos or vim.fn.getpos("'<")
  end_pos = end_pos or vim.fn.getpos("'>")
  local start_row, start_col, end_row, end_col = normalize_positions(start_pos, end_pos)

  if mode == 'V' then
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    local text = table.concat(lines, '\n')
    local function delete()
      vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
    end
    return { text = text, delete = delete, start_row = start_row, start_col = 0 }
  elseif mode == '\022' then
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    local block_start_col = math.min(start_col, end_col)
    local block_end_col = math.max(start_col, end_col)
    local parts = {}
    for i, line in ipairs(lines) do
      parts[i] = line:sub(block_start_col + 1, block_end_col + 1)
    end
    local text = table.concat(parts, '\n')
    local function delete()
      for row = start_row, end_row do
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
        local line_len = #line
        if block_start_col < line_len then
          local end_col_excl = math.min(block_end_col + 1, line_len)
          vim.api.nvim_buf_set_text(bufnr, row, block_start_col, row, end_col_excl, { '' })
        end
      end
    end
    return { text = text, delete = delete, start_row = start_row, start_col = block_start_col }
  else
    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col + 1, {})
    local text = table.concat(lines, '\n')
    local function delete()
      local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ''
      local end_col_excl = math.min(end_col + 1, #end_line)
      vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col_excl, { '' })
    end
    return { text = text, delete = delete, start_row = start_row, start_col = start_col }
  end
end

local function clamp_cursor(bufnr, row, col)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count < 1 then
    return 1, 0
  end
  row = math.max(1, math.min(row, line_count))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
  local max_col = #line
  if col < 0 then
    col = 0
  elseif col > max_col then
    col = max_col
  end
  return row, col
end

local function exit_to_normal()
  vim.cmd('stopinsert')
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
end

local function has_sendable_text(text)
  return type(text) == 'string' and text:find('%S') ~= nil
end

local function to_send_content(text)
  if not has_sendable_text(text) then
    return nil
  end

  local content = table.concat(vim.split(text, '\n', { plain = true }), '\n')
  if not content:find('\n$') then
    content = content .. '\n'
  end

  return content
end

local function should_save_editprompt_clipboard(text)
  if type(text) ~= 'string' or text == '' then
    return false
  end

  local lines = vim.split(text, '\n', { plain = true })
  local first_line = lines[1] or ''
  if not first_line:find('^/') then
    return true
  end

  local first_line_args = first_line:match('^/%S*%s*(.*)$') or ''
  if has_sendable_text(first_line_args) then
    return true
  end

  local trailing_lines = {}
  for i = 2, #lines do
    trailing_lines[#trailing_lines + 1] = lines[i]
  end
  local trailing_text = table.concat(trailing_lines, '\n')
  return has_sendable_text(trailing_text)
end

local editprompt_send_logs = {}
local editprompt_sent_history = {}
local editprompt_history_index = nil
local editprompt_history_temp = nil
local editprompt_stash_stack = {}

M.editprompt_send_logs = editprompt_send_logs
M.editprompt_sent_history = editprompt_sent_history
M.editprompt_stash_stack = editprompt_stash_stack

local function get_active_bufnr()
  return (M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr)) and M.bufnr or vim.api.nvim_get_current_buf()
end

local function set_buffer_text(bufnr, text)
  local lines = {}
  if text ~= '' then
    lines = vim.split(text, '\n', { plain = true })
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  local row = 1
  local col = 0
  if #lines > 0 then
    row = #lines
    col = #(lines[#lines] or '')
  end

  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    vim.api.nvim_win_set_cursor(win, { row, col })
  end
end

local function reset_editprompt_history_cursor()
  editprompt_history_index = nil
  editprompt_history_temp = nil
end

local function remember_confirmed_editprompt_history(text)
  editprompt_sent_history[#editprompt_sent_history + 1] = text
  reset_editprompt_history_cursor()
end

local function ensure_editprompt_history_session(bufnr)
  local newest_index = #editprompt_sent_history + 1
  if editprompt_history_index == nil then
    editprompt_history_temp = get_buffer_text(bufnr)
    editprompt_history_index = newest_index
    return
  end
  if editprompt_history_index == newest_index then
    editprompt_history_temp = get_buffer_text(bufnr)
  end
end

local function navigate_editprompt_history(step)
  local bufnr = get_active_bufnr()
  ensure_editprompt_history_session(bufnr)

  local newest_index = #editprompt_sent_history + 1
  local next_index = editprompt_history_index + step
  if next_index < 1 then
    next_index = 1
  elseif next_index > newest_index then
    next_index = newest_index
  end
  editprompt_history_index = next_index

  local text = ''
  if next_index == newest_index then
    text = editprompt_history_temp or ''
  else
    text = editprompt_sent_history[next_index] or ''
  end
  set_buffer_text(bufnr, text)
end

local function navigate_editprompt_history_async(step)
  vim.schedule(function()
    navigate_editprompt_history(step)
  end)
end

local function push_editprompt_stash()
  local bufnr = get_active_bufnr()
  local text = get_buffer_text(bufnr)
  if text == '' then
    return
  end

  editprompt_stash_stack[#editprompt_stash_stack + 1] = text
  vim.notify('editprompt stash push:\n' .. text, vim.log.levels.INFO)
  set_buffer_text(bufnr, '')
  reset_editprompt_history_cursor()
end

local function pop_editprompt_stash(bufnr)
  local stashed = table.remove(editprompt_stash_stack)
  if stashed == nil then
    return false
  end
  set_buffer_text(bufnr, stashed)
  reset_editprompt_history_cursor()
  return true
end

local function append_editprompt_send_log(entry)
  editprompt_send_logs[#editprompt_send_logs + 1] = entry
end

local function dispatch_editprompt_input(opts)
  local cmd = { 'editprompt', 'input' }
  if opts.auto_send then
    table.insert(cmd, '--auto-send')
  end
  vim.list_extend(cmd, { '--', opts.content })

  vim.system(cmd, { text = true }, function(obj)
    vim.schedule(function()
      local success = obj.code == 0
      append_editprompt_send_log({
        text = opts.text,
        source = opts.source,
        auto_send = opts.auto_send,
        success = success,
        code = obj.code,
        sent_at = os.date('%Y-%m-%d %H:%M:%S'),
      })

      if success then
        remember_confirmed_editprompt_history(opts.text)
        if opts.on_success then
          opts.on_success()
        end
        pop_editprompt_stash(opts.bufnr)
      else
        vim.notify('editprompt failed: ' .. (obj.stderr or 'unknown error'), vim.log.levels.ERROR)
      end
    end)
  end)
end

local function send_editprompt(opts)
  opts = opts or {}
  local auto_send = opts.auto_send ~= false
  local source = opts.source or 'send_editprompt'
  local bufnr = get_active_bufnr()
  local text = get_buffer_text(bufnr)
  local content = to_send_content(text)
  if not content then
    return
  end
  if should_save_editprompt_clipboard(text) then
    set_clipboard(text)
  end

  pcall(function()
    require('cmp').confirm({ select = true })
  end)

  dispatch_editprompt_input({
    bufnr = bufnr,
    text = text,
    content = content,
    auto_send = auto_send,
    source = source,
    on_success = function()
      set_buffer_text(bufnr, '')
    end,
  })
end

local function send_editprompt_visual(opts)
  opts = opts or {}
  local auto_send = opts.auto_send ~= false
  local source = opts.source or 'send_editprompt_visual'
  local bufnr = get_active_bufnr()
  local mode = vim.fn.mode()
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  exit_to_normal()
  local selection = get_visual_selection(bufnr, mode, start_pos, end_pos)
  if not selection then
    return
  end

  local text = selection.text
  local content = to_send_content(text)
  if not content then
    return
  end
  if should_save_editprompt_clipboard(text) then
    set_clipboard(text)
  end

  pcall(function()
    require('cmp').confirm({ select = true })
  end)

  dispatch_editprompt_input({
    bufnr = bufnr,
    text = text,
    content = content,
    auto_send = auto_send,
    source = source,
    on_success = function()
      selection.delete()
      local win = vim.fn.bufwinid(bufnr)
      if win ~= -1 then
        local row, col = clamp_cursor(bufnr, selection.start_row + 1, selection.start_col)
        vim.api.nvim_win_set_cursor(win, { row, col })
      end
      exit_to_normal()
    end,
  })
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

local function get_previous_bundle_id()
  return get_env_from_tmux('QUICK_IME_RETURN_BUNDLE_ID')
end

local function get_previous_window_id()
  return get_env_from_tmux('QUICK_IME_RETURN_WINDOW_ID')
end

local function focus_previous_target()
  if vim.fn.executable('shitsurae') == 1 then
    local window_id = get_previous_window_id()
    if window_id and window_id ~= '' then
      vim.fn.system({ 'shitsurae', 'focus', '--window-id', window_id })
      if vim.v.shell_error == 0 then
        return
      end
    end

    local bundle_id = get_previous_bundle_id()
    if bundle_id and bundle_id ~= '' then
      vim.fn.system({ 'shitsurae', 'focus', '--bundle-id', bundle_id })
      if vim.v.shell_error == 0 then
        return
      end
    end
  end

  local bundle_id = get_previous_bundle_id()
  if not bundle_id or bundle_id == '' then
    return
  end

  local escaped = bundle_id:gsub('"', '\\"')
  vim.fn.jobstart(
    { '/usr/bin/osascript', '-e', string.format('tell application id "%s" to activate', escaped) },
    { detach = true }
  )
end

local function quick_ime_detach()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {})

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
    navigate_editprompt_history(-1)
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<Up>', function()
    navigate_editprompt_history(-1)
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<C-n>', function()
    navigate_editprompt_history(1)
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('n', '<Down>', function()
    navigate_editprompt_history(1)
  end, { silent = true, buffer = true, nowait = true })

  vim.keymap.set('i', '<C-p>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-p>'
    end
    navigate_editprompt_history_async(-1)
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<C-n>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-n>'
    end
    navigate_editprompt_history_async(1)
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<Up>', function()
    navigate_editprompt_history_async(-1)
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })
  vim.keymap.set('i', '<Down>', function()
    navigate_editprompt_history_async(1)
    return ''
  end, { silent = true, buffer = true, nowait = true, expr = true })

  vim.keymap.set('n', '<C-q>', function()
    push_editprompt_stash()
  end, { silent = true, buffer = true, nowait = true })
  vim.keymap.set('i', '<C-q>', function()
    vim.schedule(push_editprompt_stash)
  end, { silent = true, buffer = true, nowait = true })

  local function is_buffer_empty(bufnr)
    return get_buffer_text(bufnr) == ''
  end

  local function is_buffer_blank_or_whitespace(bufnr)
    local text = get_buffer_text(bufnr)
    return not has_sendable_text(text)
  end

  vim.keymap.set('n', '<C-d>', function()
    if is_buffer_blank_or_whitespace() then
      vim.cmd('quit!')
      return
    end
    vim.cmd('normal! <C-d>')
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
