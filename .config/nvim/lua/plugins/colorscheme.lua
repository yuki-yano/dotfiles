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
      local transparency = require('rc.modules.transparency')
      transparency.configure_catppuccin()

      vim.api.nvim_create_user_command('ToggleTransparency', function()
        transparency.toggle()
      end, { desc = 'Toggle UI transparency mode' })
    end,
  },
}
