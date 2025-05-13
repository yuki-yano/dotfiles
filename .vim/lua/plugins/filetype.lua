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
    'folke/neodev.nvim',
    config = function()
      require('neodev').setup()
    end,
  },
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  {
    'kchmck/vim-coffee-script',
    enabled = false,
    ft = { 'coffee' },
  },
}
