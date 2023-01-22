local base_colors = require('color').base_colors

return {
  {
    'folke/lazy.nvim',
    cmd = { 'Lazy' },
    init = function()
      vim.keymap.set({ 'n' }, '<leader>L', '<Cmd>Lazy<CR>')
    end,
  },
  { 'tani/vim-artemis' },
  { 'kana/vim-operator-user' },
  { 'kana/vim-textobj-user' },
  { 'tpope/vim-repeat', event = { 'VeryLazy' } },
  { 'stevearc/dressing.nvim', event = { 'VeryLazy' } },
  { 'MunifTanjim/nui.nvim' },
  { 'nvim-lua/plenary.nvim' },
  {
    'rcarriga/nvim-notify',
    event = { 'VeryLazy' },
    config = function()
      require('notify').setup({ background_colour = base_colors.empty, stages = 'static' })
    end,
  },
  { 'vim-denops/denops.vim', event = { 'VeryLazy' } },
  { 'yuki-yano/denops-lazy.nvim' },
  {
    'vigoux/notifier.nvim',
    -- NOTE: Use fidget
    enabled = false,
    config = function()
      require('notifier').setup()
    end,
  },
}
