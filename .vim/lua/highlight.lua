local base_colors = require('color').base_colors
local misc_colors = require('color').misc_colors

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  pattern = { 'gruvbox-material' },
  callback = function()
    vim.api.nvim_set_hl(0, 'Normal', { fg = base_colors.white, bg = base_colors.background })
    vim.api.nvim_set_hl(0, 'NormalFloat', { fg = 'NONE', bg = base_colors.background })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = 'NONE', bg = base_colors.background })
    vim.api.nvim_set_hl(0, 'DiffAdd', { fg = 'NONE', bg = misc_colors.diff.add.bg })
    vim.api.nvim_set_hl(0, 'DiffChange', { fg = 'NONE', bg = misc_colors.diff.change.bg })
    vim.api.nvim_set_hl(0, 'DiffText', { fg = 'NONE', bg = misc_colors.diff.text.bg })
    vim.api.nvim_set_hl(0, 'Folded', { fg = base_colors.grey, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'IncSearch', { fg = 'NONE', bg = base_colors.incsearch })
    vim.api.nvim_set_hl(0, 'Search', { fg = 'NONE', bg = base_colors.search })
    vim.api.nvim_set_hl(0, 'SignColumn', { fg = base_colors.black, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'Visual', { fg = 'NONE', bg = base_colors.visual })
  end,
})
