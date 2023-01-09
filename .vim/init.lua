if vim.env.LSP == nil then
  vim.env.LSP = 'nvim'
  -- vim.env.LSP = 'coc'
end

if vim.env.NVIM_COLORSCHEME == nil then
  vim.env.NVIM_COLORSCHEME = 'gruvbox-material'
  -- vim.env.NVIM_COLORSCHEME = 'tokyonight'
end

require('plugin_manager').lazy_init()
require('preload')
require('plugin_manager').lazy_setup()
require('postload')
