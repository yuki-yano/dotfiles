return {
  {
    'folke/lazy.nvim',
    init = function()
      vim.keymap.set({ 'n' }, '<leader>L', '<Cmd>Lazy<CR>')
    end,
  },
  { 'tani/vim-artemis' },
  { 'kana/vim-operator-user' },
  { 'kana/vim-textobj-user' },
  { 'tpope/vim-repeat', event = { 'VeryLazy' } },
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },
  { 'MunifTanjim/nui.nvim' },
  { 'nvim-lua/plenary.nvim' },
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({ background_colour = '#26282F', stages = 'static' })
    end,
  },
  -- {
  --   'vigoux/notifier.nvim',
  --   config = function()
  --     require('notifier').setup()
  --   end,
  -- },
  { 'vim-denops/denops.vim', event = { 'VeryLazy' } },
  { 'yuki-yano/denops-lazy.nvim' },
}
