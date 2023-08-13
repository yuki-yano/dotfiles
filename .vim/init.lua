vim.loader.enable()

if vim.env.LSP == nil then
  vim.env.LSP = 'nvim'
  -- vim.env.LSP = 'coc'
end

if vim.env.NVIM_COLORSCHEME == nil then
  -- vim.env.NVIM_COLORSCHEME = 'gruvbox-material'
  vim.env.NVIM_COLORSCHEME = 'catppuccin'
end

require('rc.plugin_manager').lazy_init()
require('rc.preload')
-- NOTE: lazy.nvim auto load lua/plugins/config.lua
--       unnecessary `require('plugins/config')`
--       config.lua load base settings with cache. (from lazy.nvim)
--         - lua/options.lua
--         - lua/func.lua
--         - lua/highlight.lua
require('rc.plugin_manager').lazy_setup()
require('rc.postload')
