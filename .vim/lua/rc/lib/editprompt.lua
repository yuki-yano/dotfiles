local M = {}
local buffer = require('rc.lib.ime_buffer')

local send_logs = {}
local sent_history = {}
local stash_stack = {}
local history_index = nil
local history_temp = nil

M.send_logs = send_logs
M.sent_history = sent_history
M.stash_stack = stash_stack

local function set_clipboard(text)
  vim.fn.system('pbcopy', text)
end

local function reset_history_cursor()
  history_index = nil
  history_temp = nil
end

local function remember_confirmed_history(text)
  sent_history[#sent_history + 1] = text
  reset_history_cursor()
end

local function ensure_history_session(bufnr)
  local newest_index = #sent_history + 1
  if history_index == nil then
    history_temp = buffer.get_text(bufnr)
    history_index = newest_index
    return
  end
  if history_index == newest_index then
    history_temp = buffer.get_text(bufnr)
  end
end

local function append_send_log(entry)
  send_logs[#send_logs + 1] = entry
end

local function dispatch_input(opts)
  local cmd = { 'editprompt', 'input' }
  if opts.auto_send then
    table.insert(cmd, '--auto-send')
  end
  vim.list_extend(cmd, { '--', opts.content })

  vim.system(cmd, { text = true }, function(obj)
    vim.schedule(function()
      local success = obj.code == 0
      append_send_log({
        text = opts.text,
        source = opts.source,
        auto_send = opts.auto_send,
        success = success,
        code = obj.code,
        sent_at = os.date('%Y-%m-%d %H:%M:%S'),
      })

      if success then
        remember_confirmed_history(opts.text)
        if opts.on_success then
          opts.on_success()
        end
        M.pop_stash(opts.bufnr)
      else
        vim.notify('editprompt failed: ' .. (obj.stderr or 'unknown error'), vim.log.levels.ERROR)
      end
    end)
  end)
end

local function confirm_completion()
  pcall(function()
    require('cmp').confirm({ select = true })
  end)
end

function M.to_send_content(text)
  if not buffer.has_sendable_text(text) then
    return nil
  end

  local content = text
  content = content:gsub('\t', '  ')
  if not content:find('\n$') then
    content = content .. '\n'
  end

  return content
end

function M.should_save_clipboard(text)
  if type(text) ~= 'string' or text == '' then
    return false
  end

  local lines = vim.split(text, '\n', { plain = true })
  local first_line = lines[1] or ''
  if not first_line:find('^/') then
    return true
  end

  local first_line_args = first_line:match('^/%S*%s*(.*)$') or ''
  if buffer.has_sendable_text(first_line_args) then
    return true
  end

  local trailing_lines = {}
  for i = 2, #lines do
    trailing_lines[#trailing_lines + 1] = lines[i]
  end
  local trailing_text = table.concat(trailing_lines, '\n')
  return buffer.has_sendable_text(trailing_text)
end

function M.is_empty(bufnr)
  return buffer.get_text(bufnr) == ''
end

function M.is_blank_or_whitespace(bufnr)
  return not buffer.has_sendable_text(buffer.get_text(bufnr))
end

function M.navigate_history(step, bufnr)
  ensure_history_session(bufnr)

  local newest_index = #sent_history + 1
  local next_index = history_index + step
  if next_index < 1 then
    next_index = 1
  elseif next_index > newest_index then
    next_index = newest_index
  end
  history_index = next_index

  local text = ''
  if next_index == newest_index then
    text = history_temp or ''
  else
    text = sent_history[next_index] or ''
  end
  buffer.set_text(bufnr, text)
end

function M.navigate_history_async(step, bufnr)
  vim.schedule(function()
    M.navigate_history(step, bufnr)
  end)
end

function M.push_stash(bufnr)
  local text = buffer.get_text(bufnr)
  if text == '' then
    return
  end

  stash_stack[#stash_stack + 1] = text
  vim.notify('editprompt stash push:\n' .. text, vim.log.levels.INFO)
  buffer.set_text(bufnr, '')
  reset_history_cursor()
end

function M.pop_stash(bufnr)
  local stashed = table.remove(stash_stack)
  if stashed == nil then
    return false
  end
  buffer.set_text(bufnr, stashed)
  reset_history_cursor()
  return true
end

function M.send(opts)
  opts = opts or {}

  local auto_send = opts.auto_send ~= false
  local source = opts.source or 'send_editprompt'
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local text = buffer.get_text(bufnr)
  local content = M.to_send_content(text)
  if not content then
    return
  end

  local copy = opts.set_clipboard or set_clipboard
  if M.should_save_clipboard(text) then
    copy(text)
  end

  confirm_completion()

  dispatch_input({
    bufnr = bufnr,
    text = text,
    content = content,
    auto_send = auto_send,
    source = source,
    on_success = function()
      if opts.on_success then
        opts.on_success(bufnr)
      else
        buffer.set_text(bufnr, '')
      end
    end,
  })
end

function M.send_visual(opts)
  opts = opts or {}

  local auto_send = opts.auto_send ~= false
  local source = opts.source or 'send_editprompt_visual'
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local mode = opts.mode or vim.fn.mode()
  local start_pos = opts.start_pos or vim.fn.getpos('v')
  local end_pos = opts.end_pos or vim.fn.getpos('.')

  buffer.exit_to_normal()
  local selection = buffer.get_visual_selection(bufnr, mode, start_pos, end_pos)
  if not selection then
    return
  end

  local text = selection.text
  local content = M.to_send_content(text)
  if not content then
    return
  end

  local copy = opts.set_clipboard or set_clipboard
  if M.should_save_clipboard(text) then
    copy(text)
  end

  confirm_completion()

  dispatch_input({
    bufnr = bufnr,
    text = text,
    content = content,
    auto_send = auto_send,
    source = source,
    on_success = function()
      selection.delete()
      local win = vim.fn.bufwinid(bufnr)
      if win ~= -1 then
        local row, col = buffer.clamp_cursor(bufnr, selection.start_row + 1, selection.start_col)
        vim.api.nvim_win_set_cursor(win, { row, col })
      end
      buffer.exit_to_normal()
      if opts.on_success then
        opts.on_success(selection, bufnr)
      end
    end,
  })
end

function M.feed_normal(keys)
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(termcodes, 'nx', false)
end

return M
