local color = require('rc.color')

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/playground' },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
      { 'm-demare/hlargs.nvim' },
      { 'nvim-treesitter/nvim-treesitter-context' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      -- { 'hiphish/rainbow-delimiters.nvim' },
      { 'yioneko/nvim-yati' },
    },
    event = { 'BufRead', 'BufNewFile', 'InsertEnter' },
    cmd = { 'TSHighlightCapturesUnderCursor' },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'typescript',
          'tsx',
          -- NOTE: Minified JS files are too slow when opened, so they are not used
          -- 'javascript',
          'graphql',
          'jsdoc',
          'ruby',
          'python',
          'lua',
          'vim',
          'json',
          'jsonc',
          'json5',
          'yaml',
          'toml',
          'markdown',
          'markdown_inline',
          'bash',
          'html',
          'css',
          'comment',
          'regex',
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = false,
        },
        playground = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ['i`'] = '@block.inner',
              ['a`'] = '@block.outer',
              -- NOTE: Not yet supported for jsx attributes
              -- ['ax'] = '@tag.attribute',
              -- ['ix'] = '@tag.attribute',
            },
          },
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        yati = {
          enable = true,
          default_lazy = true,
        },
        matchup = {
          enable = true,
          disable_virtual_text = true,
        },
      })

      -- require('rainbow-delimiters')
      require('treesitter-context').setup()

      -- NOTE: Workaround for tsx not working with markdown_inline
      vim.treesitter.query.add_directive('directivename', function() end, true)
    end,
  },
  {
    'David-Kunz/treesitter-unit',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'ModeChanged' },
    config = function()
      vim.keymap.set({ 'x' }, 'iu', [[:lua require('treesitter-unit').select()<CR>]])
      vim.keymap.set({ 'x' }, 'au', [[:lua require('treesitter-unit').select(true)<CR>]])
      vim.keymap.set({ 'o' }, 'iu', [[:<C-u>lua require('treesitter-unit').select()<CR>]])
      vim.keymap.set({ 'o' }, 'au', [[:<C-u>lua require('treesitter-unit').select(true)<CR>]])
    end,
  },
  {
    'm-demare/hlargs.nvim',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'BufRead' },
    config = function()
      require('hlargs').setup()
    end,
  },
  {
    'mfussenegger/nvim-treehopper',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
      { 'm-demare/hlargs.nvim' },
    },
    keys = {
      { 'zf', mode = { 'n' } },
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'TSNodeKey', { fg = color.base().blue })
        end,
      })
    end,
    config = function()
      vim.keymap.set({ 'n' }, 'zf', function()
        require('hlargs').disable()
        pcall(function()
          require('tsht').nodes()
          vim.cmd([[normal! zf]])
        end)
        require('hlargs').enable()
      end)
    end,
  },
  {
    'bennypowers/nvim-regexplainer',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
      { 'MunifTanjim/nui.nvim' },
    },
    event = { 'BufRead' },
    config = function()
      require('regexplainer').setup({
        auto = true,
        popup = {
          border = {
            padding = { 0, 0 },
            style = 'rounded',
          },
        },
      })
    end,
  },
}
