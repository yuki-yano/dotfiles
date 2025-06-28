local plugin_utils = require('rc.plugin_utils')
local add_focus_gain = plugin_utils.add_focus_gain
local add_focus_lost = plugin_utils.add_focus_lost

local M = {}

-- Setup window highlight handlers for FocusGain/FocusLost
function M.setup_focus_handlers()
  -- Register FocusLost handler for window highlights
  add_focus_lost(function()
    -- Set all windows to inactive background color
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:NormalInactive,NormalNC:NormalInactive')
    end
  end)

  -- Register FocusGained handler for window highlights
  add_focus_gain(function()
    -- Reset active window background color
    vim.api.nvim_win_set_option(0, 'winhighlight', '')

    -- Reset other windows to default NormalNC behavior
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_win_set_option(win, 'winhighlight', '')
      end
    end
  end)
end

return M