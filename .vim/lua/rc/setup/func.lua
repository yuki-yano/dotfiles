-- EscEsc
local esc_esc_width = 1
vim.keymap.set({ 'n' }, '<Esc><Esc>', function()
  vim.cmd([[nohlsearch]])
  esc_esc_width = esc_esc_width == 1 and 2 or 1
  vim.print(string.rep(' ', esc_esc_width))
end)

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

    if vim.fn.filereadable(vim.fn.expand('#' .. vim.fn.bufnr('') .. ':p')) and vim.g.enable_number then
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
vim.keymap.set({ 'n' }, '<Leader>q', '<Cmd>ToggleQuickFix<CR>')

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
vim.keymap.set({ 'n' }, '<Leader>l', '<Cmd>ToggleLocationList<CR>')

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

vim.api.nvim_create_user_command('CodeToChar', function(opts)
  if opts.range ~= 2 then
    vim.print('Not select code')
    return
  end

  local code = vim.fn.getline('.'):sub(vim.fn.col("'<"), vim.fn.col("'>"))
  vim.print(vim.fn.nr2char(vim.fn.str2nr(code, 16)))
end, { range = true })

vim.api.nvim_create_user_command('CharToCode', function(opts)
  if opts.range ~= 2 then
    vim.print('Not select char')
    return
  end

  local char = vim.fn.getline('.'):sub(vim.fn.col("'<"), vim.fn.col("'>"))
  vim.print(vim.fn.printf('0x%X', vim.fn.char2nr(char)))
end, { range = true })

-- ghq project selector with tmux integration
vim.api.nvim_create_user_command('GhqProject', function()
  -- Save current state
  local current_file = vim.fn.expand('%:p')

  -- Run the selector
  vim.cmd('silent !ghq-project-selector')

  -- If we switched tmux sessions, the command effect is already applied
  -- If not in tmux or stayed in same session, we need to handle cd
  if vim.v.shell_error == 0 and vim.env.TMUX == nil then
    -- Not in tmux, the script only output the directory
    local result = vim.fn.system('ghq-project-selector')
    if result ~= '' then
      local dir = result:gsub('\n$', ''):gsub('^~', vim.env.HOME)
      vim.cmd('cd ' .. vim.fn.fnameescape(dir))
    end
  end

  -- Refresh the screen
  vim.cmd('redraw!')
end, {})

vim.api.nvim_create_user_command('PluginList', function()
  local plugins = require('lazy').plugins()
  for _, plugin in ipairs(plugins) do
    vim.print(plugin[1])
  end
end, {})

local open_vscode_based_editor = function(editor, args)
  local path = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')

  vim.cmd('!' .. editor .. ' . ' .. args .. ' --goto ' .. path .. ':' .. line .. ':' .. col)
  vim.notify('Open ' .. path .. ' in ' .. editor, vim.log.levels.INFO, { title = 'Open ' .. editor })
end

-- VSCode
vim.api.nvim_create_user_command('VSCode', function(opts)
  open_vscode_based_editor('code', opts.args)
end, { nargs = '?' })

-- Cursor
vim.api.nvim_create_user_command('Cursor', function(opts)
  open_vscode_based_editor('cursor', opts.args)
end, { nargs = '?' })

-- Arto
vim.api.nvim_create_user_command('Arto', function()
  local path = vim.fn.expand('%:p')
  vim.cmd('!open -a /Applications/Arto.app ' .. path)
end, {})

-- Claude Code yank commands
local function get_relative_filepath()
  local filepath = vim.fn.expand('%:.')
  if filepath == '' then
    filepath = vim.fn.expand('%:p')
  end
  return filepath
end

local function format_diagnostics(diagnostics)
  local lines = {}
  for _, diag in ipairs(diagnostics) do
    -- Only include ERROR and WARN
    if diag.severity == vim.diagnostic.severity.ERROR or diag.severity == vim.diagnostic.severity.WARN then
      local severity = ({ 'ERROR', 'WARN' })[diag.severity]
      local line = diag.lnum + 1 -- Convert back to 1-indexed
      local msg = string.format('[%s] Line %d: %s', severity, line, diag.message)
      if diag.source then
        msg = msg .. string.format(' (%s)', diag.source)
      end
      table.insert(lines, msg)
    end
  end
  return lines
end

local function yank_content(content, has_diagnostics)
  vim.fn.setreg('"', content)
  local lines = vim.split(content, '\n')
  local notification = 'Yanked: ' .. lines[1]
  if has_diagnostics then
    notification = notification .. ' (with ' .. (#lines - 2) .. ' diagnostics)'
  end
  vim.notify(notification, vim.log.levels.INFO, { title = 'Claude Code Yank' })

  pcall(
    vim.fn['haritsuke#notify'],
    'onTextYankPost',
    {
      {
        operator = 'y',
        regname = '"',
        regtype = vim.fn.getregtype('"'),
        regcontents = vim.fn.getreg('"', 1, true),
      },
    }
  )
end

-- Normal mode: yank file path as @path/to/file
vim.keymap.set('n', 'ga', function()
  local content = get_relative_filepath()
  yank_content(content, false)
  vim.fn.setreg('+', vim.fn.getreg('"'))
end, { desc = 'Yank file path for Claude Code' })

-- Visual mode: yank with line range as @path/to/file#Lxx-yy
vim.keymap.set('x', 'ga', function()
  local filepath = get_relative_filepath()

  -- Get current visual selection range
  -- Use vim.fn.getpos() to get the current visual selection
  local vstart = vim.fn.getpos('v')
  local vend = vim.fn.getpos('.')

  local start_line = math.min(vstart[2], vend[2])
  local end_line = math.max(vstart[2], vend[2])

  -- Build the base content
  local content = filepath .. '#L' .. start_line
  if start_line ~= end_line then
    content = content .. '-' .. end_line
  end

  -- Check for diagnostics in the selected range
  local diagnostics = vim.diagnostic.get(0, {
    lnum_start = start_line - 1, -- 0-indexed
    lnum_end = end_line - 1, -- 0-indexed
  })

  -- Add diagnostics info if present (only ERROR and WARN)
  local diag_lines = format_diagnostics(diagnostics)
  local has_diagnostics = #diag_lines > 0
  if has_diagnostics then
    content = content .. '\n' .. table.concat(diag_lines, '\n')
  end

  yank_content(content, has_diagnostics)
  vim.fn.setreg('+', vim.fn.getreg('"'))

  -- Exit visual mode safely
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'n', false)
end, { desc = 'Yank file path with line range for Claude Code' })
