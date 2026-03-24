local plugin_utils = require('rc.modules.plugin_utils')
local add_focus_gain = plugin_utils.add_focus_gain
local add_focus_lost = plugin_utils.add_focus_lost

local function set_inactive_windows_highlight()
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    local is_float = config and config.relative ~= ''

    if not is_float then
      if win == current_win then
        vim.api.nvim_win_set_option(win, 'winhighlight', '')
      else
        vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:NormalInactive,NormalNC:NormalInactive')
      end
    end
  end
end

-- Register FocusLost handler for window highlights
add_focus_lost(function()
  -- Set all windows to inactive background color
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    local is_float = config and config.relative ~= ''

    if not is_float then
      vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:NormalInactive,NormalNC:NormalInactive')
    end
  end
end)

-- Register FocusGained handler for window highlights
add_focus_gain(function()
  set_inactive_windows_highlight()
end)

vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  callback = function()
    set_inactive_windows_highlight()
  end,
})
