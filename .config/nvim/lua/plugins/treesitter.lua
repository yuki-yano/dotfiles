local color = require('rc.modules.color')

local install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site')
local managed_parsers = {
  'bash',
  'comment',
  'css',
  'diff',
  'graphql',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'json5',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'regex',
  'ruby',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

local managed_parser_set = {}

for _, parser in ipairs(managed_parsers) do
  managed_parser_set[parser] = true
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        install_dir = install_dir,
      })

      vim.treesitter.language.register('bash', { 'zsh' })

      if vim.fn.executable('tree-sitter') == 1 then
        require('nvim-treesitter').install(managed_parsers, {
          summary = false,
        })
      end

      local group = vim.api.nvim_create_augroup('rc_treesitter_main', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = '*',
        callback = function(args)
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end

          local filetype = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang or not managed_parser_set[lang] then
            return
          end

          if not pcall(vim.treesitter.start, args.buf, lang) then
            return
          end

          if pcall(vim.treesitter.query.get, lang, 'indents') then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          include_surrounding_whitespace = false,
        },
      })

      vim.keymap.set({ 'x', 'o' }, 'aF', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end, { silent = true })
      vim.keymap.set({ 'x', 'o' }, 'iF', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end, { silent = true })
      vim.keymap.set({ 'x', 'o' }, 'ab', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@block.outer', 'textobjects')
      end, { silent = true })
      vim.keymap.set({ 'x', 'o' }, 'ib', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@block.inner', 'textobjects')
      end, { silent = true })
      vim.keymap.set({ 'x', 'o' }, 'ax', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@attribute.outer', 'textobjects')
      end, { silent = true })
      vim.keymap.set({ 'x', 'o' }, 'ix', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@attribute.inner', 'textobjects')
      end, { silent = true })
    end,
  },
  {
    'David-Kunz/treesitter-unit',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'ModeChanged' },
    config = function()
      vim.keymap.set({ 'x' }, 'iu', [[:lua require('treesitter-unit').select()<CR>]], { silent = true })
      vim.keymap.set({ 'x' }, 'au', [[:lua require('treesitter-unit').select(true)<CR>]], { silent = true })
      vim.keymap.set({ 'o' }, 'iu', [[:<C-u>lua require('treesitter-unit').select()<CR>]], { silent = true })
      vim.keymap.set({ 'o' }, 'au', [[:<C-u>lua require('treesitter-unit').select(true)<CR>]], { silent = true })
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
