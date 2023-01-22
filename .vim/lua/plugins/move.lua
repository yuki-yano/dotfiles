local misc_colors = require('color').misc_colors

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
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'EftChar', { fg = misc_colors.pointer.red })
          vim.api.nvim_set_hl(0, 'EftSubChar', { fg = misc_colors.pointer.blue })
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
        '<Cmd>lua require("hlslens").enable()<CR><Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require("hlslens").start()<CR>zzzv'
      )
      vim.keymap.set(
        { 'n' },
        'N',
        '<Cmd>lua require("hlslens").enable()<CR><Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require("hlslens").start()<CR>zzzv'
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
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'HlSearchLensNear', { link = 'IncSearch' })
          vim.api.nvim_set_hl(0, 'HlSearchLens', { fg = misc_colors.hlslens.lens.fg, bg = misc_colors.hlslens.lens.bg })
          vim.api.nvim_set_hl(
            0,
            'HlSearchLensNear',
            { fg = misc_colors.hlslens.near.fg, bg = misc_colors.hlslens.near.bg }
          )
          vim.api.nvim_set_hl(
            0,
            'HlSearchFloat',
            { fg = misc_colors.hlslens.float.fg, bg = misc_colors.hlslens.float.bg }
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
      vim.keymap.set({ 'n' }, '<C-b>', '<Plug>(backandforward-back)')
      vim.keymap.set({ 'n' }, '<C-f>', '<Plug>(backandforward-forward)')
    end,
  },
  {
    'yuki-yano/fuzzy-motion.vim',
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'lambdalisue/kensaku.vim' },
    },
    cmd = { 'FuzzyMotion' },
    init = function()
      vim.g.fuzzy_motion_matchers = { 'fzf', 'kensaku' }
      vim.keymap.set({ 'n', 'x' }, 'ss', '<Cmd>FuzzyMotion<CR>')
    end,
    config = function()
      require('denops-lazy').load('fuzzy-motion.vim', { wait_load = false })
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
}
