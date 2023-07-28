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
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = vim.env.NVIM_COLORSCHEME == 'catppuccin' and 1000 or 50,
    lazy = vim.env.NVIM_COLORSCHEME ~= 'catppuccin',
    config = function()
      require('catppuccin').setup({
        term_colors = true,
        custom_highlights = function(colors)
          return {
            ['@keyword.export'] = { fg = colors.sapphire, style = {} },
          }
        end,
        integrations = {
          aerial = true,
          coc_nvim = true,
          cmp = true,
          dropbar = {
            enabled = true,
          },
          fern = true,
          fidget = true,
          gitsigns = true,
          lsp_saga = true,
          lsp_trouble = true,
          mason = true,
          notify = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          rainbow_delimiters = true,
          indent_blankline = {
            enabled = true,
          },
          sandwich = true,
        },
      })
    end,
  },
}
