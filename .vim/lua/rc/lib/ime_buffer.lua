local M = {}

local function normalize_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return bufnr
end

function M.has_sendable_text(text)
  return type(text) == 'string' and text:find('%S') ~= nil
end

function M.get_text(bufnr)
  bufnr = normalize_bufnr(bufnr)
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

function M.set_text(bufnr, text)
  bufnr = normalize_bufnr(bufnr)
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

function M.get_visual_selection(bufnr, mode, start_pos, end_pos)
  bufnr = normalize_bufnr(bufnr)
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

function M.clamp_cursor(bufnr, row, col)
  bufnr = normalize_bufnr(bufnr)
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

function M.exit_to_normal()
  vim.cmd('stopinsert')
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
end

return M
