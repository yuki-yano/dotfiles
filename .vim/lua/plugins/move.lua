local color = require('rc.color')

return {
  {
    'haya14busa/vim-edgemotion',
    keys = {
      { '<Leader>j', mode = { 'n', 'o', 'x' } },
      { '<Leader>k', mode = { 'n', 'o', 'x' } },
    },
    config = function()
      vim.keymap.set({ 'n' }, '<Leader>j', function()
        return 'm`' .. vim.fn['edgemotion#move'](1)
      end, { silent = true, expr = true })
      vim.keymap.set({ 'o', 'x' }, '<Leader>j', function()
        return vim.fn['edgemotion#move'](1)
      end, { silent = true, expr = true })
      vim.keymap.set({ 'n', 'o', 'x' }, '<Leader>k', function()
        return vim.fn['edgemotion#move'](0)
      end, { silent = true, expr = true })
    end,
  },
  {
    'hrsh7th/vim-eft',
    keys = {
      { '<Plug>(eft-f)', mode = { 'n', 'o', 'x' } },
      { '<Plug>(eft-F)', mode = { 'n', 'o', 'x' } },
      { '<Plug>(eft-t)', mode = { 'n', 'o', 'x' } },
      { '<Plug>(eft-T)', mode = { 'n', 'o', 'x' } },
      { '<Plug>(eft-repeat)', mode = { 'n', 'o', 'x' } },
    },
    init = function()
      local function enable_eft()
        vim.g.eft_enable = true
        vim.keymap.set({ 'n', 'o', 'x' }, ';;', '<Plug>(eft-repeat)')
        vim.keymap.set({ 'n', 'o', 'x' }, 'f', '<Plug>(eft-f)')
        vim.keymap.set({ 'n', 'o', 'x' }, 'F', '<Plug>(eft-F)')
        vim.keymap.set({ 'o', 'x' }, 't', '<Plug>(eft-t)')
        vim.keymap.set({ 'o', 'x' }, 'T', '<Plug>(eft-T)')
      end

      local function disable_eft()
        vim.g.eft_enable = false
        vim.keymap.set({ 'n', 'x' }, ';;', ';')
        vim.keymap.del({ 'n', 'o', 'x' }, 'f')
        vim.keymap.del({ 'n', 'o', 'x' }, 'F')
        vim.keymap.del({ 'o', 'x' }, 't')
        vim.keymap.del({ 'o', 'x' }, 'T')
      end

      enable_eft()

      local function eft_toggle()
        if vim.g.eft_enable then
          disable_eft()
        else
          enable_eft()
        end
      end

      vim.api.nvim_create_user_command('ToggleEft', eft_toggle, {})
      vim.keymap.set({ 'n' }, '<Leader>f', eft_toggle)

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'EftChar', { fg = color.misc().pointer.red, bold = true })
          vim.api.nvim_set_hl(0, 'EftSubChar', { fg = color.misc().pointer.blue, bold = true })
        end,
      })
    end,
  },
  {
    'kevinhwang91/nvim-hlslens',
    dependencies = {
      { 'petertriho/nvim-scrollbar' },
      { 'haya14busa/vim-asterisk' },
    },
    init = function()
      vim.keymap.set({ 'n' }, '/', '<Cmd>lua require("hlslens").enable()<CR>/')
      vim.keymap.set({ 'n' }, '?', '<Cmd>lua require("hlslens").enable()<CR>?')
      vim.keymap.set(
        { 'n' },
        'n',
        '<Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require("hlslens").enable()<CR><Cmd>lua require("hlslens").start()<CR>zzzv'
      )
      vim.keymap.set(
        { 'n' },
        'N',
        '<Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require("hlslens").enable()<CR><Cmd>lua require("hlslens").start()<CR>zzzv'
      )
      vim.keymap.set(
        { 'n', 'x' },
        '*',
        '<Cmd>lua require("hlslens").enable()<CR><Plug>(asterisk-z*)<Cmd>lua require("hlslens").start()<CR>'
      )
      vim.keymap.set(
        { 'n', 'x' },
        '#',
        '<Cmd>lua require("hlslens").enable()<CR><Plug>(asterisk-z#)<Cmd>lua require("hlslens").start()<CR>'
      )
      vim.keymap.set(
        { 'n', 'x' },
        'g*',
        '<Cmd>lua require("hlslens").enable()<CR><Plug>(asterisk-gz*)<Cmd>lua require("hlslens").start()<CR>'
      )
      vim.keymap.set(
        { 'n', 'x' },
        'g#',
        '<Cmd>lua require("hlslens").enable()<CR><Plug>(asterisk-gz#)<Cmd>lua require("hlslens").start()<CR>'
      )

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'HlSearchLensNear', { link = 'IncSearch' })
          vim.api.nvim_set_hl(
            0,
            'HlSearchLens',
            { fg = color.misc().hlslens.lens.fg, bg = color.misc().hlslens.lens.bg }
          )
          vim.api.nvim_set_hl(
            0,
            'HlSearchLensNear',
            { fg = color.misc().hlslens.near.fg, bg = color.misc().hlslens.near.bg }
          )
          vim.api.nvim_set_hl(
            0,
            'HlSearchFloat',
            { fg = color.misc().hlslens.float.fg, bg = color.misc().hlslens.float.bg }
          )
        end,
      })
    end,
    config = function()
      -- NOTE: setup from nvim-scrollbar
      -- require('hlslens').setup()
    end,
  },
  {
    'Bakudankun/BackAndForward.vim',
    keys = {
      { '<Plug>(backandforward-back)', mode = { 'n' } },
      { '<Plug>(backandforward-forward)', mode = { 'n' } },
    },
    init = function()
      vim.g.backandforward_config = {
        define_commands = false,
      }
      vim.keymap.set({ 'n' }, '<C-b>', '<Plug>(backandforward-back)')
      vim.keymap.set({ 'n' }, '<C-f>', '<Plug>(backandforward-forward)')
    end,
  },
  {
    'yuki-yano/fuzzy-motion.vim',
    dev = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'lambdalisue/kensaku.vim' },
    },
    cmd = { 'FuzzyMotion' },
    init = function()
      vim.g.fuzzy_motion_matchers = { 'fzf', 'kensaku' }
      vim.keymap.set({ 'n', 'x' }, 'ss', '<Cmd>FuzzyMotion<CR>')

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'FuzzyMotionShade', { fg = color.base().grey })
          vim.api.nvim_set_hl(0, 'FuzzyMotionChar', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'FuzzyMotionSubChar', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'FuzzyMotionMatch', { fg = color.base().blue })
        end,
      })
    end,
    config = function()
      require('denops-lazy').load('fuzzy-motion.vim', { wait_load = false })
    end,
  },
  {
    'lambdalisue/kensaku-search.vim',
    enabled = false,
    dependencies = {
      { 'lambdalisue/kensaku.vim' },
    },
    event = { 'CmdlineEnter' },
    init = function()
      local prev_maparg = nil
      vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
        pattern = { '*' },
        callback = function()
          if prev_maparg == nil and vim.fn.getcmdtype() == '/' then
            ---@diagnostic disable-next-line: missing-parameter
            prev_maparg = vim.fn.maparg('<CR>', 'c')
            vim.keymap.set({ 'c' }, '<CR>', '<Plug>(kensaku-search-replace)<CR>')
          end
        end,
      })
      vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
        pattern = { '*' },
        callback = function()
          if prev_maparg ~= nil then
            vim.keymap.set({ 'c' }, '<CR>', prev_maparg)
            prev_maparg = nil
          end
        end,
      })
    end,
  },
  {
    'lambdalisue/kensaku.vim',
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    config = function()
      require('denops-lazy').load('kensaku.vim', { wait_load = false })
    end,
  },
  {
    'hrsh7th/nvim-gtd',
    -- FIX: lazy load now working?
    --      Is it removed from the map when it fails to run?
    enabled = false,
    keys = {
      { 'gf', mode = { 'n' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'gf', function()
        require('gtd').exec({ command = 'edit' })
      end)
    end,
    config = function()
      require('gtd').setup({
        sources = {
          { name = 'lsp' },
          { name = 'findup' },
          -- { name = 'walk' },
        },
      })
    end,
  },
  {
    -- NOTE: Try lazy_on_func.nvim
    'hrsh7th/vim-searchx',
    enabled = true,
    lazy = true,
    init = function()
      local on_func = require('lazy_on_func').on_func
      local searchx = on_func('vim-searchx', 'searchx')

      vim.keymap.set({ 'n', 'x' }, '/', function()
        searchx('start')({ dir = 1 })
      end)
      vim.keymap.set({ 'n', 'x' }, '?', function()
        searchx('start')({ dir = 0 })
      end)
      vim.keymap.set({ 'c' }, ';', function()
        searchx('select')()
      end)

      vim.keymap.set({ 'n', 'x' }, 'n', function()
        searchx('next_dir')()
      end)
      vim.keymap.set({ 'n', 'x' }, 'N', function()
        searchx('prev_dir')()
      end)
    end,
  },
}
