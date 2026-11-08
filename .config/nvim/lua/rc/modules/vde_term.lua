-- vde-term の中で ⌃H/J/K/L と ⌘V・⌘C を Pane の操作へつなぐ。$TMUX があれば tmux の経路に任せる
local M = {
  active = vim.env.VDE_TERM ~= nil and vim.env.TMUX == nil,
}

local directions = { h = 'left', j = 'down', k = 'up', l = 'right' }

function M.send(request)
  vim.api.nvim_chan_send(vim.v.stderr, '\27]7777;' .. request .. '\7')
end

local function is_floating()
  return vim.api.nvim_win_get_config(0).relative ~= ''
end

function M.navigate(key)
  if is_floating() or vim.fn.winnr() == vim.fn.winnr(key) then
    M.send('pane-move;' .. directions[key])
  else
    vim.cmd('wincmd ' .. key)
  end
end

-- 入ってきた位置の window を選ぶ。位置は vde-term が入る側の端に合わせて送る
local function select_window(y_percent, x_percent)
  if is_floating() then
    return
  end
  local row = math.floor(y_percent * (vim.o.lines - vim.o.cmdheight) / 100)
  local col = math.floor(x_percent * vim.o.columns / 100)
  local best, best_distance = nil, math.huge
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(window).relative == '' then
      local top, left = unpack(vim.api.nvim_win_get_position(window))
      local bottom = top + vim.api.nvim_win_get_height(window) - 1
      local right = left + vim.api.nvim_win_get_width(window) - 1
      -- 中なら 0。statusline や区切りの上なら最も近い window になる
      local distance = math.max(top - row, row - bottom, 0) + math.max(left - col, col - right, 0)
      if distance < best_distance then
        best, best_distance = window, distance
      end
    end
  end
  if best then
    vim.api.nvim_set_current_win(best)
  end
end

function M.setup()
  if not M.active then
    return
  end
  for key, direction in pairs(directions) do
    vim.keymap.set({ 'n', 't' }, '<C-' .. key .. '>', function()
      M.navigate(key)
    end, { silent = true, desc = 'Navigate ' .. direction })
  end
  vim.api.nvim_create_autocmd('TermResponse', {
    group = vim.api.nvim_create_augroup('VdeTermPane', { clear = true }),
    callback = function(event)
      local y, x = event.data.sequence:match('^\27%]7778;pane%-enter;(%d+);(%d+)')
      if y then
        select_window(tonumber(y), tonumber(x))
      end
    end,
    desc = 'Select the window aligned with where vde-term entered this pane',
  })
end

return M
