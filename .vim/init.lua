vim.loader.enable()

if vim.env.LSP == nil then
  vim.env.LSP = 'nvim'
  -- vim.env.LSP = 'coc'
end

if vim.env.NVIM_COLORSCHEME == nil then
  -- vim.env.NVIM_COLORSCHEME = 'gruvbox-material'
  vim.env.NVIM_COLORSCHEME = 'catppuccin'
end

require('rc.modules.plugin_manager').lazy_init()
require('rc.init.preload')
-- NOTE: lazy.nvim auto load lua/plugins/config_from_lazy.lua
--       config_from_lazy.lua loads base settings:
--         - rc/setup/options.lua
--         - rc/setup/keymaps.lua
--         - rc/setup/func.lua
--         - rc/setup/highlight.lua
--         - rc/setup/extui.lua
--       And VeryLazy event loads:
--         - rc/setup/ui.lua
require('rc.modules.plugin_manager').lazy_setup()
require('rc.init.postload')
