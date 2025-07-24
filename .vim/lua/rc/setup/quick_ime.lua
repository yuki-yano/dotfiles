local M = {}
M.bufnr = nil

function M.is_quick_ime()
  return vim.env.QUICK_IME == '1' or vim.g.quick_ime == 1
end

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1
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

-- Create scratch buffer
local function create_scratch()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    vim.api.nvim_buf_delete(M.bufnr, { force = true })
  end
  local bufnr = vim.api.nvim_create_buf(false, true)
  M.bufnr = bufnr
  vim.api.nvim_set_current_buf(bufnr)

  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].filetype = 'markdown'
  vim.bo[bufnr].fileformat = 'unix'
end

local function reset()
  if M.is_quick_ime() then
    create_scratch()
  end
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

local function send_hammerspoon()
  local text = get_buffer_text(M.bufnr)
  vim.fn.system('pbcopy', text)

  local osa = [[osascript -e 'tell application "Hammerspoon" to execute lua code "quick_ime_done()"']]
  local result = vim.fn.system(osa)
  if vim.v.shell_error ~= 0 then
    vim.notify('Failed to notify Hammerspoon: ' .. tostring(result), vim.log.levels.ERROR)
  end

  reset()
end

local function send_editprompt()
  vim.cmd('wq!')
end

local function send_quick_ime()
  send_hammerspoon()
end

if vim.env.QUICK_IME == '1' or vim.env.EDITPROMPT == '1' then
  if M.is_quick_ime() then
    vim.g.quick_ime = 1
    vim.api.nvim_create_user_command('SendQuickIme', send_quick_ime, {})
    reset()
    apply_mode_opts()
    vim.cmd('startinsert')
  elseif M.is_editprompt() then
    vim.g.editprompt = 1
    vim.api.nvim_create_user_command('SendQuickIme', send_editprompt, {})
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      pattern = { 'markdown' },
      callback = function()
        apply_mode_opts()
        vim.cmd('startinsert')
      end,
    })
  else
    vim.g.quick_ime = 0
    vim.g.editprompt = 0
  end

  vim.keymap.set({ 'n', 'i' }, '<C-g>', '<Cmd>quit!<CR>', { silent = true, buffer = true, nowait = true })
  vim.keymap.set({ 'n', 'i' }, '<C-c>', '<Cmd>SendQuickIme<CR>', { silent = true, buffer = true, nowait = true })
end

return M
