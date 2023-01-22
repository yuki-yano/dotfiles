return {
  -- TODO: migrate from gina
  {
    'lambdalisue/gin.vim',
    enabled = true,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    cmd = { 'Gin', 'GinBuffer', 'GinDiff', 'GinPatch', 'GinChaperon' },
    init = function() end,
    config = function()
      require('denops-lazy').load('gin.vim')
    end,
  },
  {
    'lambdalisue/gina.vim',
    cmd = { 'Gina' },
    init = function()
      vim.g['gina#command#blame#use_default_mappings'] = false
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufRead' },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'GitSignsAddNr', { link = 'DiffAdd' })
          vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { link = 'DiffChange' })
          vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { link = 'DiffDelete' })
          vim.api.nvim_set_hl(0, 'GitSignsUntrackedNr', { link = 'LineNr' })
        end,
      })
    end,
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '-' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        signcolumn = false,
        numhl = true,
        linehl = false,
        word_diff = false,
        current_line_blame = false,
        trouble = false,
      })

      vim.keymap.set({ 'n' }, 'gp', require('gitsigns').prev_hunk)
      vim.keymap.set({ 'n' }, 'gn', require('gitsigns').next_hunk)
      vim.keymap.set({ 'n' }, 'gh', require('gitsigns').preview_hunk)
      vim.keymap.set({ 'n' }, 'gq', require('gitsigns').setqflist)
      vim.keymap.set({ 'n' }, 'gl', require('gitsigns').setloclist)
    end,
  },
  {
    'rhysd/committia.vim',
    -- FIX: git information in Neovim is corrupted when used with `Gin commit`
    enabled = false,
    ft = { 'gitcommit' },
    init = function()
      vim.g.committia_hooks = {
        edit_open = function(info)
          if info.vcs == 'git' and vim.fn.getline(1) == '' then
            vim.cmd([[startinsert]])
          end
        end,
      }
    end,
    config = function()
      local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
      if bufname == 'COMMIT_EDITMSG' or bufname == 'MERGE_MSG' then
        vim.fn['committia#open']('git')
      end
    end,
  },
  {
    'sindrets/diffview.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewRefresh',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
    },
    config = function()
      require('diffview').setup()
    end,
  },
}
