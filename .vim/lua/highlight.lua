vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  pattern = { 'gruvbox-material' },
  callback = function()
    vim.api.nvim_set_hl(0, 'Normal', { fg = '#D4BE98', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { fg = 'NONE', bg = '#232526' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = 'NONE', bg = '#232526' })
    vim.api.nvim_set_hl(0, 'DiffText', { fg = 'NONE', bg = '#716522' })
    vim.api.nvim_set_hl(0, 'Folded', { fg = '#686F9A', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'IncSearch', { fg = 'NONE', bg = '#175655' })
    vim.api.nvim_set_hl(0, 'Search', { fg = 'NONE', bg = '#213F72' })
    vim.api.nvim_set_hl(0, 'SignColumn', { fg = '#32302F', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'Visual', { fg = 'NONE', bg = '#1D4647' })
    vim.api.nvim_set_hl(0, 'Pmenu', { fg = 'NONE', bg = '#2C3538' })
    vim.api.nvim_set_hl(0, 'PmenuSel', { fg = 'NONE', bg = '#3C6073' })
  end,
})
