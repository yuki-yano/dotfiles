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
      require('notify').setup({ background_colour = base_colors().empty, stages = 'static' })

      -- NOTE: override vim.notify
      vim.notify = function(...)
        vim.notify = require('notify')
        vim.notify(...)
      end

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'notify' },
        callback = function()
          vim.keymap.set({ 'n' }, 'q', '<Cmd>quit<CR>', { buffer = true })
        end,
      })
    end,
  },
  {
    'vim-denops/denops.vim',
    lazy = false,
  },
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
