local color = require('rc.modules.color')

return {
  {
    'folke/lazy.nvim',
    cmd = { 'Lazy', 'LazyAll' },
    init = function()
      vim.keymap.set({ 'n' }, '<Leader>L', '<Cmd>Lazy<CR>')

      -- Load all plugins
      local did_load_all = false
      vim.api.nvim_create_user_command('LazyAll', function()
        if did_load_all then
          return
        end

        local specs = require('lazy').plugins()
        local names = {}
        for _, spec in pairs(specs) do
          if spec.lazy and not spec['_'].loaded and not spec['_'].dep then
            table.insert(names, spec.name)
          end
        end
        require('lazy').load({ plugins = names })
        did_load_all = true
      end, {})
    end,
  },
  { 'tani/vim-artemis' },
  { 'kana/vim-operator-user' },
  { 'kana/vim-textobj-user' },
  { 'tpope/vim-repeat', event = { 'VeryLazy' } },
  {
    'stevearc/dressing.nvim',
    enabled = false,
    event = { 'VeryLazy' },
    config = function()
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'DressingInput' },
        callback = function()
          vim.keymap.set({ 'n' }, 'q', '<Cmd>quit<CR>', { buffer = true })
        end,
      })
    end,
  },
  { 'MunifTanjim/nui.nvim' },
  { 'nvim-lua/plenary.nvim' },
  {
    'rcarriga/nvim-notify',
    enabled = false,
    event = { 'VeryLazy' },
    config = function()
      require('notify').setup({
        background_colour = color.base().empty,
        stages = 'static',
      })

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
  { 'yuki-yano/lazy_on_func.nvim' },
  {
    'vigoux/notifier.nvim',
    -- NOTE: Use fidget
    enabled = false,
    config = function()
      require('notifier').setup()
    end,
  },
}
