local M = {}
local buffer = require('rc.lib.ime_buffer')

local function set_clipboard(text)
  vim.fn.system('pbcopy', text)
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

function M.focus_previous_target()
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

function M.detach(opts)
  opts = opts or {}

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  if opts.clear_buffer ~= false then
    buffer.set_text(bufnr, '')
  end

  local tty = vim.fn.systemlist({ 'tmux', 'display-message', '-p', '#{client_tty}' })[1]
  if tty and #tty > 0 then
    vim.fn.jobstart({ 'tmux', 'detach-client', '-t', tty }, { detach = true })
  else
    vim.fn.jobstart({ 'tmux', 'detach-client' }, { detach = true })
  end

  vim.defer_fn(M.focus_previous_target, opts.focus_delay_ms or 150)
end

function M.send(opts)
  opts = opts or {}

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local text = buffer.get_text(bufnr)
  local copy = opts.set_clipboard or set_clipboard
  if text ~= '' then
    copy(text)
  end

  buffer.set_text(bufnr, '')

  if opts.on_detach then
    opts.on_detach()
  end
end

return M
