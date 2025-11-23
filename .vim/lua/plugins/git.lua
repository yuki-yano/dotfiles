return {
  -- TODO: migrate from gina
  {
    'lambdalisue/gin.vim',
    lazy = false,
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
    enabled = false,
    cmd = { 'Gina' },
    init = function()
      vim.g['gina#command#blame#use_default_mappings'] = true
    end,
  },
  {
    'echasnovski/mini.diff',
    version = false,
    event = { 'BufRead' },
    init = function()
      local function set_nr_hl(name, target)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = target, link = false })
        if not ok then
          return
        end
        vim.api.nvim_set_hl(0, name, {
          fg = hl.fg,
          bg = 'NONE',
        })
      end
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          set_nr_hl('MiniDiffSignAdd', 'DiffAdd')
          set_nr_hl('MiniDiffSignChange', 'DiffChange')
          set_nr_hl('MiniDiffSignDelete', 'DiffDelete')
        end,
      })
    end,
    config = function()
      local diff = require('mini.diff')
      diff.setup({
        view = {
          style = 'number',
          signs = { add = '+', change = '~', delete = '-' },
        },
        mappings = {
          apply = '',
          reset = '',
          textobject = '',
          goto_first = '',
          goto_prev = '',
          goto_next = '',
          goto_last = '',
        },
      })

      vim.keymap.set({ 'n' }, 'gp', function()
        diff.goto_hunk('prev')
      end)
      vim.keymap.set({ 'n' }, 'gn', function()
        diff.goto_hunk('next')
      end)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    enabled = false,
    event = { 'BufRead' },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
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
