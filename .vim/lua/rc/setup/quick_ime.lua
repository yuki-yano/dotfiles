local M = {}

M.bufnr = nil
local editprompt_group = vim.api.nvim_create_augroup('Editprompt', { clear = true })

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1
end

local uv = vim.loop

local function clipboard_dir()
  if M._clipboard_dir ~= nil then
    return M._clipboard_dir
  end
  local dir = vim.fs.normalize(vim.fn.stdpath('cache') .. '/codex-clipboard')
  vim.fn.mkdir(dir, 'p')
  M._clipboard_dir = dir
  return dir
end

local function unique_image_path()
  local dir = clipboard_dir()
  local stamp = os.date('%Y%m%d%H%M%S')
  local suffix
  if uv and uv.hrtime then
    suffix = tostring(uv.hrtime()):sub(-9)
  else
    suffix = tostring(math.random(0, 1000000000))
  end
  return string.format('%s/codex-clipboard-%s-%s.png', dir, stamp, suffix)
end

local function capture_clipboard_image(dest)
  if vim.fn.executable('pngpaste') ~= 1 then
    return nil, 'pngpaste is required to capture clipboard images (try `brew install pngpaste`).'
  end

  local result = vim.system({ 'pngpaste', dest }, { text = true }):wait()
  if result.code ~= 0 then
    local reason = result.stderr
    if reason and reason ~= '' then
      reason = vim.trim(reason)
    else
      reason = string.format('pngpaste exited with code %d', result.code)
    end
    return nil, reason
  end

  if uv and uv.fs_stat then
    local stat = uv.fs_stat(dest)
    if not stat or (stat.size or 0) == 0 then
      return nil, 'Generated image file is empty.'
    end
  end

  return dest
end

local function insert_text_at_cursor(text)
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { text })
  vim.api.nvim_win_set_cursor(win, { row, col + #text })
end

function M.paste_clipboard_image()
  local dest = unique_image_path()
  local path, err = capture_clipboard_image(dest)
  if not path then
    return false, err
  end
  local real = (uv and uv.fs_realpath and uv.fs_realpath(path)) or vim.fs.normalize(path)
  insert_text_at_cursor(real .. ' ')
  return true
end

local function apply_mode_opts()
  if vim.g.editprompt_opts_applied == 1 then
    return
  end
  vim.g.editprompt_opts_applied = 1

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

local function ensure_multibyte_alnum_spacing(text)
  if text == '' then
    return text
  end
  -- Insert spaces between multi-byte characters and single ASCII alphanumerics on either side.
  local multibyte = '[\194-\244][\128-\191]*'
  text = text:gsub('(' .. multibyte .. ')%f[%w]([%w])%f[^%w]', '%1 %2')
  text = text:gsub('%f[%w]([%w])(' .. multibyte .. ')', '%1 %2')
  return text
end

local function send_editprompt()
  local bufnr = (M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr)) and M.bufnr or vim.api.nvim_get_current_buf()
  local text = get_buffer_text(bufnr)
  local content = ''
  if text ~= '' then
    local adjusted = ensure_multibyte_alnum_spacing(text)
    local lines = vim.split(adjusted, '\n', { plain = true })
    content = table.concat(lines, '\n')
    if content ~= '' and not content:find('\n$') then
      content = content .. '\n'
    end
    set_clipboard(text)
  end

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

if M.is_editprompt() then
  vim.g.editprompt = 1
  vim.api.nvim_create_user_command('SendEditPrompt', send_editprompt, {})
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = editprompt_group,
    pattern = { 'markdown' },
    callback = function()
      apply_mode_opts()
      vim.bo.filetype = 'markdown.editprompt'
      vim.cmd('startinsert')
    end,
  })
  vim.api.nvim_create_autocmd({ 'FocusGained' }, {
    group = editprompt_group,
    callback = function()
      if vim.bo.filetype == 'markdown.editprompt' then
        vim.schedule(function()
          local mode = vim.api.nvim_get_mode().mode
          if mode ~= 'i' and mode ~= 'R' and mode ~= 'Rv' and mode ~= 'c' then
            -- vim.cmd('startinsert') -- Ensure returning focus re-enters insert mode
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', false)
          end
        end)
      end
    end,
  })
  vim.keymap.set({ 'n', 'i' }, '<C-g>', '<Cmd>quit!<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'q', '<Cmd>SendEditPrompt<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', '<Cmd>SendEditPrompt<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n' }, 'ZZ', '<Cmd>SendEditPrompt<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set('i', '<C-v>', function()
    local ok, err = M.paste_clipboard_image()
    if ok then
      return
    end
    if err and err ~= '' then
      vim.notify(err, vim.log.levels.WARN)
    end
  end, { silent = true, buffer = true })
else
  vim.g.editprompt = 0
end

return M
