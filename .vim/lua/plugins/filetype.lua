return {
  {
    'windwp/nvim-ts-autotag',
    enabled = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    ft = { 'typescriptreact' },
    config = function()
      require('nvim-ts-autotag').setup({ enable_close = false })
    end,
  },
  {
    'lambdalisue/vim-deno-cache',
    config = function()
      require('denops-lazy').load('vim-deno-cache')
    end,
  },
  -- NOTE: Too slow to build
  {
    'barrett-ruth/import-cost.nvim',
    enabled = false,
    build = 'sh install.sh yarn',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('import-cost').setup()
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        'lazy.nvim',
        'plenary.nvim',
      },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('lazydev').setup({
        library = {
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          'lazy.nvim',
          'plenary.nvim',
        },
      })
    end,
  },
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  {
    'kchmck/vim-coffee-script',
    enabled = false,
    ft = { 'coffee' },
  },
}
