local M = {}

local function get_cmd()
  local ok, config = pcall(require, 'editprompt.config')
  if ok and type(config.get_cmd) == 'function' then
    return vim.deepcopy(config.get_cmd())
  end
  return { 'editprompt' }
end

local function system(args, callback)
  vim.system(args, { text = true }, function(obj)
    vim.schedule(function()
      callback(obj)
    end)
  end)
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

local function move_cursor_to_start(bufnr)
  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

local function push_history(text)
  local ok, history = pcall(require, 'editprompt.history')
  if ok and type(history.push) == 'function' then
    history.push(text)
  end
end

local function get_latest_stash_key(stashes)
  if type(stashes) ~= 'table' or vim.tbl_isempty(stashes) then
    return nil
  end

  table.sort(stashes, function(a, b)
    return (a.key or '') > (b.key or '')
  end)

  return stashes[1] and stashes[1].key or nil
end

local function pop_latest_stash(bufnr)
  local list_cmd = get_cmd()
  vim.list_extend(list_cmd, { 'stash', 'list' })

  system(list_cmd, function(list_result)
    if list_result.code ~= 0 then
      return
    end

    local ok, stashes = pcall(vim.json.decode, list_result.stdout or '[]')
    if not ok then
      return
    end

    local key = get_latest_stash_key(stashes)
    if not key then
      return
    end

    local pop_cmd = get_cmd()
    vim.list_extend(pop_cmd, { 'stash', 'pop', '--key', key })

    system(pop_cmd, function(pop_result)
      if pop_result.code ~= 0 then
        return
      end
      local output = (pop_result.stdout or ''):gsub('\n$', '')
      set_buffer_text(bufnr, output)
    end)
  end)
end

local function normalize_rows(start_pos, end_pos)
  local start_row = start_pos[2] - 1
  local end_row = end_pos[2] - 1
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end
  return start_row, end_row
end

local function get_visual_line_selection(bufnr, start_pos, end_pos)
  start_pos = start_pos or vim.fn.getpos("'<")
  end_pos = end_pos or vim.fn.getpos("'>")
  if start_pos[2] == 0 or end_pos[2] == 0 then
    return nil
  end

  local start_row, end_row = normalize_rows(start_pos, end_pos)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local text = table.concat(lines, '\n')

  local function delete()
    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
  end

  return {
    text = text,
    delete = delete,
  }
end

local function to_send_content(text)
  if type(text) ~= 'string' or text:find('%S') == nil then
    return nil
  end

  local content = text:gsub('\t', '  ')
  if not content:find('\n$') then
    content = content .. '\n'
  end
  return content
end

local function should_save_clipboard(text)
  if type(text) ~= 'string' or text == '' then
    return false
  end

  local lines = vim.split(text, '\n', { plain = true })
  local first_line = lines[1] or ''
  if not first_line:find('^/') then
    return true
  end

  local first_line_args = first_line:match('^/%S*%s*(.*)$') or ''
  if first_line_args:find('%S') ~= nil then
    return true
  end

  local trailing_text = table.concat(vim.list_slice(lines, 2), '\n')
  return trailing_text:find('%S') ~= nil
end

local function copy_if_needed(text)
  if should_save_clipboard(text) then
    vim.fn.system('pbcopy', text)
  end
end

local function dispatch_input(bufnr, text, content, auto_send, on_success)
  local cmd = get_cmd()
  vim.list_extend(cmd, { 'input' })
  if auto_send then
    table.insert(cmd, '--auto-send')
  end
  vim.list_extend(cmd, { '--', content })

  system(cmd, function(result)
    if result.code ~= 0 then
      vim.notify('editprompt failed: ' .. (result.stderr or 'unknown error'), vim.log.levels.ERROR)
      return
    end

    push_history(text)
    if on_success then
      on_success()
    end
    pop_latest_stash(bufnr)
  end)
end

function M.get_buffer_text(bufnr)
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

function M.is_buffer_empty(bufnr)
  return M.get_buffer_text(bufnr) == ''
end

function M.is_buffer_blank_or_whitespace(bufnr)
  return M.get_buffer_text(bufnr):find('%S') == nil
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

function M.send_current(bufnr, auto_send)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local text = M.get_buffer_text(bufnr)
  local content = to_send_content(text)
  if not content then
    return
  end

  copy_if_needed(text)
  dispatch_input(bufnr, text, content, auto_send ~= false, function()
    set_buffer_text(bufnr, '')
  end)
end

function M.send_visual(bufnr, auto_send)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local selection = get_visual_line_selection(bufnr)
  if not selection then
    return
  end

  local content = to_send_content(selection.text)
  if not content then
    return
  end

  copy_if_needed(selection.text)
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  dispatch_input(bufnr, selection.text, content, auto_send ~= false, function()
    selection.delete()
  end)
end

function M.send_literal(bufnr, text, auto_send)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local content = to_send_content(text)
  if not content then
    return
  end

  dispatch_input(bufnr, text, content, auto_send ~= false, function()
    set_buffer_text(bufnr, '')
  end)
end

return M
