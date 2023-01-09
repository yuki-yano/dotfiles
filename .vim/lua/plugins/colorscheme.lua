return {
  {
    'sainnhe/gruvbox-material',
    priority = vim.env.NVIM_COLORSCHEME == 'gruvbox-material' and 1000 or 50,
    lazy = vim.env.NVIM_COLORSCHEME ~= 'gruvbox-material',
    config = function()
      vim.g.gruvbox_material_better_performance = true
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_transparent_background = 2
      vim.g.gruvbox_material_enable_bold = true
      vim.g.gruvbox_material_enable_italic = true
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = vim.env.NVIM_COLORSCHEME == 'tokyonight' and 1000 or 50,
    lazy = vim.env.NVIM_COLORSCHEME ~= 'tokyonight',
  },
}
