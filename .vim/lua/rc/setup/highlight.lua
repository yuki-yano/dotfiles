local color = require('rc.modules.color')

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  pattern = { '*' },
  callback = function()
    vim.api.nvim_set_hl(0, 'Normal', { fg = color.base().white, bg = color.base().background })
    vim.api.nvim_set_hl(0, 'NormalFloat', { fg = 'NONE', bg = color.base().background })
    -- vim.api.nvim_set_hl(0, 'FloatBorder', { fg = 'NONE', bg = color.base().background })
    vim.api.nvim_set_hl(0, 'DiffAdd', { fg = 'NONE', bg = color.misc().diff.add.bg })
    vim.api.nvim_set_hl(0, 'DiffDelete', { fg = 'NONE', bg = color.misc().diff.delete.bg })
    vim.api.nvim_set_hl(0, 'DiffChange', { fg = 'NONE', bg = color.misc().diff.change.bg })
    vim.api.nvim_set_hl(0, 'DiffText', { fg = 'NONE', bg = color.misc().diff.text.bg })
    vim.api.nvim_set_hl(0, 'Folded', { fg = color.base().grey, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'IncSearch', { fg = 'NONE', bg = color.base().incsearch })
    vim.api.nvim_set_hl(0, 'Search', { fg = 'NONE', bg = color.base().search })
    vim.api.nvim_set_hl(0, 'CurSearch', { fg = 'NONE', bg = color.base().search })
    vim.api.nvim_set_hl(0, 'SignColumn', { fg = color.base().black, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'Visual', { fg = 'NONE', bg = color.base().visual, bold = true })
    vim.api.nvim_set_hl(0, 'WinSeparator', color.misc().split.win_separator)
    vim.api.nvim_set_hl(0, 'VertSplit', color.misc().split.vert_split)
    vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = color.base().inlay_hint, bg = 'NONE' })

    -- Custom highlight groups for focus states
    vim.api.nvim_set_hl(0, 'NormalInactive', { bg = color.misc().focus_inactive })
    vim.api.nvim_set_hl(0, 'NormalActive', { bg = color.base().background })
  end,
})
