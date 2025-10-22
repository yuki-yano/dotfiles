local M = {}

M.bufnr = nil
local editprompt_group = vim.api.nvim_create_augroup('Editprompt', { clear = true })

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1
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
else
  vim.g.editprompt = 0
end

return M
