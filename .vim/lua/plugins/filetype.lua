return {
  {
    'windwp/nvim-ts-autotag',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('nvim-ts-autotag').setup({ enable_close = false })
    end,
  },
  -- Too slow to build
  -- {
  --   'barrett-ruth/import-cost.nvim',
  --   build = 'sh install.sh yarn',
  --   ft = { 'typescript', 'typescriptreact' },
  --   config = function()
  --     require('import-cost').setup()
  --   end,
  -- },
  { 'folke/neodev.nvim', ft = { 'lua' } },
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && yarn',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewToggle', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    init = function()
      vim.g.mkdp_auto_close = false
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_open_to_the_world = true
    end,
  },
}
