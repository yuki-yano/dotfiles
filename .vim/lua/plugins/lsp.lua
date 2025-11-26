local plugin_utils = require('rc.modules.plugin_utils')
local add_disable_cmp_filetypes = plugin_utils.add_disable_cmp_filetypes
local color = require('rc.modules.color')
local lsp_icons = require('rc.modules.font').lsp_icons
local codicons = require('rc.modules.font').codicons
local diagnostic_icons = require('rc.modules.font').diagnostic_icons

local server_specs = {
  { name = 'astro', module = 'plugins.lsp.servers.astro' },
  { name = 'denols', module = 'plugins.lsp.servers.denols' },
  { name = 'eslint', module = 'plugins.lsp.servers.eslint' },
  { name = 'jsonls', module = 'plugins.lsp.servers.jsonls' },
  { name = 'lua_ls', module = 'plugins.lsp.servers.lua_ls' },
  { name = 'tailwindcss', module = 'plugins.lsp.servers.tailwindcss' },
  { name = 'tsserver', module = 'plugins.lsp.servers.tsserver' },
  { name = 'vtsls', module = 'plugins.lsp.servers.vtsls' },
  { name = 'yamlls', module = 'plugins.lsp.servers.yamlls' },
}

local function setup_servers()
  for _, spec in ipairs(server_specs) do
    local ok, config_or_err = pcall(require, spec.module)
    if not ok then
      vim.notify(
        string.format('Failed to load LSP config: %s (%s)', spec.name, config_or_err),
        vim.log.levels.ERROR
      )
    else
      local enable = true
      if config_or_err.enable ~= nil then
        enable = config_or_err.enable
      end

      local config = vim.deepcopy(config_or_err)
      config.enable = nil

      vim.lsp.config(spec.name, config)
      if enable then
        vim.lsp.enable(spec.name)
      end
    end
  end
end

local plugins = {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufWrite' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'nvimtools/none-ls.nvim' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'b0o/SchemaStore.nvim' },
      { 'SmiteshP/nvim-navic' },
      { 'jose-elias-alvarez/typescript.nvim' },
      { 'yioneko/nvim-vtsls' },
      { 'folke/neodev.nvim' },
      { 'lewis6991/hover.nvim' },
      { 'davidmh/cspell.nvim' },
      { 'rachartier/tiny-inline-diagnostic.nvim' },
      { 'lambdalisue/vim-deno-cache' },
      { 'kyoh86/climbdir.nvim' },
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'LspReferenceWrite', { bold = true })
          vim.api.nvim_set_hl(0, 'LspReferenceRead', { bold = true })
          vim.api.nvim_set_hl(0, 'LspReferenceText', { bold = true })
        end,
      })
    end,
    config = function()
      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      local null_ls = require('null-ls')
      local cspell_sources = require('plugins.lsp.cspell').setup(null_ls)

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = diagnostic_icons.error,
            [vim.diagnostic.severity.WARN] = diagnostic_icons.warn,
            [vim.diagnostic.severity.INFO] = diagnostic_icons.info,
            [vim.diagnostic.severity.HINT] = diagnostic_icons.hint,
          },
        },
        virtual_text = false,
        severity_sort = true,
      })

      vim.lsp.config('*', {
        capabilities = cmp_nvim_lsp.default_capabilities(),
      })

      local lsp_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = lsp_group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end

          if client.name == 'jsonls' then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end

          if client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, ev.buf)
          end
        end,
      })

      null_ls.setup({
        diagnostics_format = '#{m} (#{s}: #{c})',
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.biome.with({
            condition = function(utils)
              return utils.root_has_file({ 'biome.json' })
            end,
          }),
          null_ls.builtins.formatting.stylua,
          cspell_sources.diagnostics,
          cspell_sources.code_actions,
        },
      })

      vim.keymap.set('n', '<Plug>(lsp)f', function()
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer' })

      setup_servers()
    end,
  },
  {
    'williamboman/mason.nvim',
    dependencies = {
      { 'williamboman/mason-lspconfig' },
      { 'jayp0521/mason-null-ls.nvim' },
    },
    cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog' },
    config = function()
      require('mason').setup()

      require('mason-lspconfig').setup({
        ensure_installed = {
          'vtsls',
          'eslint',
          'biome',
          'tailwindcss',
          'denols',
          'astro',
          'lua_ls',
          'jsonls',
          'yamlls',
        },
        automatic_enable = false,
      })

      require('mason-null-ls').setup({
        ensure_installed = {
          'prettierd',
          'stylua',
        },
        automatic_installation = true,
      })
    end,
  },
  {
    'nvimdev/lspsaga.nvim',
    event = { 'LspAttach' },
    init = function()
      add_disable_cmp_filetypes({ 'sagarename' })
    end,
    config = function()
      require('lspsaga').setup({
        ui = {
          title = true,
          border = 'rounded',
          lines = { '┗', '┣', '┃', '━', '┏' },
          kind = nil,
          button = { '', '' },
          imp_sign = '󰳛 ',
          expand = '>',
          collapse = 'v',
          preview = '< ',
          hover = diagnostic_icons.hint,
          code_action = lsp_icons.code_action,
          diagnostic = lsp_icons.diagnostic,
          incoming = lsp_icons.incoming,
          outgoing = lsp_icons.outgoing,
          colors = {
            normal_bg = color.base().black,
            title_bg = color.base().green,
            black = color.base().empty,
            white = color.base().white,
            red = color.base().red,
            blue = color.base().blue,
            green = color.base().green,
            yellow = color.base().yellow,
            cyan = color.base().cyan,
            magenta = color.base().magenta,
            orange = color.base().orange,
            purple = color.base().purple,
          },
        },
        finder = {
          default = 'imp+ref',
          keys = {
            close = '<Esc>',
          },
        },
        definition = {
          width = 0.7,
          height = 0.7,
          keys = {
            edit = '<CR>',
            quit = 'q',
            close = '<C-g>',
          },
        },
        diagnostic = {
          custom_msg = 'Message:',
          custom_fix = 'Fix:',
        },
        rename = {
          keys = {
            quit = 'q',
            exec = '<CR>',
            mark = '<Space>',
            confirm = '<CR>',
          },
        },
        lightbulb = {
          enable = false,
        },
        beacon = {
          enable = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })

      vim.keymap.set({ 'n' }, 'K', function()
        local ft = vim.o.filetype
        if ft == 'vim' or ft == 'help' then
          vim.cmd([[execute 'h ' . expand('<cword>') ]])
        else
          vim.cmd([[Lspsaga hover_doc]])
        end
      end)

      vim.keymap.set({ 'n' }, '<C-]>', '<Cmd>Lspsaga peek_definition<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)t', '<Cmd>Lspsaga peek_type_definition<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rn', '<Cmd>Lspsaga rename<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)R', '<Cmd>Lspsaga finder<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)n', '<Cmd>Lspsaga diagnostic_jump_next<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)p', '<Cmd>Lspsaga diagnostic_jump_prev<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)m', '<Cmd>Lspsaga show_cursor_diagnostics<CR>')
    end,
  },
  {
    'lewis6991/hover.nvim',
    enabled = false,
    config = function()
      local hover = require('hover')
      hover.setup({
        init = function()
          require('hover.providers.lsp')
        end,
        title = false,
      })

      vim.keymap.set({ 'n' }, 'K', function()
        local ft = vim.o.filetype
        if ft == 'vim' or ft == 'help' then
          vim.cmd([[execute 'h ' . expand('<cword>') ]])
        else
          hover.hover()
        end
      end)
      vim.keymap.set({ 'n' }, 'gK', require('hover').hover_select)
    end,
  },
  {
    'zbirenbaum/neodim',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'LspAttach' },
    config = function()
      require('neodim').setup({
        alpha = 0.6,
        hide = {
          underline = false,
          virtual_text = false,
          signs = false,
        },
      })
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('trouble').setup({
        use_diagnostic_signs = true,
        fold_open = 'v',
        fold_closed = '>',
        indent_lines = false,
      })
    end,
  },
  {
    'j-hui/fidget.nvim',
    event = { 'LspAttach' },
    config = function()
      require('fidget').setup({})
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = { 'LspAttach' },
    config = function()
      require('lsp_signature').setup({
        hint_enable = false,
        transparency = 10,
      })
    end,
  },
  {
    'aznhe21/actions-preview.nvim',
    dependencies = {
      { 'MunifTanjim/nui.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
    event = { 'LspAttach' },
    config = function()
      require('actions-preview').setup({
        diff = {
          algorithm = 'histogram',
        },
      })
      vim.keymap.set({ 'n', 'x' }, '<Plug>(lsp)a', require('actions-preview').code_actions)
    end,
  },
  {
    'SmiteshP/nvim-navic',
    config = function()
      require('nvim-navic').setup({
        icons = codicons,
      })
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('typescript-tools').setup()
    end,
  },
  {
    'yioneko/nvim-vtsls',
    config = function()
      local group = vim.api.nvim_create_augroup('UserVtslsExtras', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= 'vtsls' then
            return
          end

          vim.keymap.set(
            { 'n' },
            '<Plug>(lsp)s',
            '<Cmd>VtsExec goto_source_definition<CR>',
            { silent = true, buffer = ev.buf }
          )
        end,
      })
    end,
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    config = function()
      require('tiny-inline-diagnostic').setup({
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
          multiple_diag_under_cursor = true,
          multilines = {
            enabled = true,
            always_show = true,
          },
          show_all_diags_on_cursorline = false,
          break_line = {
            enabled = true,
          },
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
        },
      })
    end,
  },
  {
    'kyoh86/climbdir.nvim',
  },
}

return plugins
