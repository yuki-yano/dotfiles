local icons = require('font').icons
local cycle_lsp_lines = require('plugin_utils').cycle_lsp_lines

local plugins = {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre' },
    -- Use onetime deno file
    ft = { 'typescript', 'typescriptreact' },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig' },
      { 'jose-elias-alvarez/null-ls.nvim' },
      { 'jayp0521/mason-null-ls.nvim' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'b0o/SchemaStore.nvim' },
      { 'SmiteshP/nvim-navic' },
      { 'jose-elias-alvarez/typescript.nvim' },
      { 'yioneko/nvim-vtsls' },
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = false,
        signs = {
          priority = 100,
        },
        severity_sort = true,
      })
      local signs = { Error = '', Warn = '', Info = '', Hint = '' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      local mason = require('mason')
      local lspconfig = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')
      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      local null_ls = require('null-ls')
      local mason_null_ls = require('mason-null-ls')

      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = {
          'tsserver',
          'eslint',
          'denols',
          'sumneko_lua',
          'vimls',
          'jsonls',
          'yamlls',
        },
        automatic_installation = true,
      })

      local opts = {
        capabilities = cmp_nvim_lsp.default_capabilities(),
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.document_highlight()
              end,
            })
            vim.api.nvim_create_autocmd('CursorMoved', {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.clear_references()
              end,
            })
          end

          if client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, bufnr)
          end
        end,
      }

      local node_root_dir = lspconfig.util.root_pattern('package.json')
      local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

      mason_lspconfig.setup_handlers({
        function(server_name)
          if server_name == 'tsserver' then
            if not is_node_repo then
              return
            end

            -- Use nvim-vtsls or typescript.nvim
            if vim.fn.executable('vtsls') == 1 then
              require('lspconfig.configs').vtsls = require('vtsls').lspconfig
              require('lspconfig').vtsls.setup(opts)
            else
              require('typescript').setup({ server = opts })
            end

            return
          end

          if server_name == 'eslint' then
            if not is_node_repo then
              return
            end
          end

          if server_name == 'denols' then
            if is_node_repo then
              return
            end

            opts.root_dir = lspconfig.util.root_pattern('deno.json')
            opts.init_options = {
              lint = true,
              unstable = true,
              suggest = {
                imports = {
                  hosts = {
                    ['https://deno.land'] = true,
                  },
                },
              },
            }
          end

          if server_name == 'sumneko_lua' then
            opts.settings = {
              Lua = {
                diagnostics = { globals = { 'vim' } },
                completion = { callSnippet = 'Replace' },
                format = { enable = false },
                hint = { enable = true },
                telemetry = { enable = false },
                workspace = { checkThirdParty = false },
                -- semantic = { enable = false },
              },
            }
          end

          if server_name == 'jsonls' then
            opts.settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
            }
          end

          if server_name == 'yamlls' then
            opts.settings = {
              yaml = {
                schemas = { require('schemastore').json.schemas() },
                validate = { enable = true },
              },
            }
          end

          lspconfig[server_name].setup(opts)
        end,
      })

      mason_null_ls.setup({
        ensure_installed = {
          'prettierd',
          'stylua',
          'cspell',
        },
        automatic_installation = true,
      })
      null_ls.setup({
        diagnostics_format = '#{m} (#{s}: #{c})',
        sources = {
          null_ls.builtins.code_actions.gitsigns,
          null_ls.builtins.formatting.prettierd.with({
            prefer_local = 'node_modules/.bin',
          }),
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.cspell.with({
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity['HINT']
            end,
          }),
          null_ls.builtins.code_actions.cspell,
        },
      })

      vim.keymap.set({ 'n' }, '<Plug>(lsp)q', '<Cmd>FzfPreviewNvimLspCurrentDiagnosticsRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)Q', '<Cmd>FzfPreviewNvimLspDiagnosticsRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)f', vim.lsp.buf.format)
      vim.keymap.set({ 'n' }, '<Plug>(lsp)d', '<Cmd>FzfPreviewNvimLspDefinitionRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)i', '<Cmd>FzfPreviewNvimLspImplementationRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)t', '<Cmd>FzfPreviewNvimLspTypeDefinitionRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rf', '<Cmd>FzfPreviewNvimLspReferencesRpc<CR>')

      -- tagjump does not work with Deno
      vim.keymap.set({ 'n' }, '<C-]>', vim.lsp.buf.definition)

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'typescript', 'typescriptreact' },
        callback = function()
          if is_node_repo then
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
              vim.cmd([[EslintFixAll]])
              vim.lsp.buf.format({ name = 'null-ls' })
            end)
          else
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', vim.lsp.buf.format)
          end
        end,
      })

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'lua' },
        callback = function()
          vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
            vim.lsp.buf.format({ name = 'null-ls' })
          end)
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        pattern = { 'ai-review://*' },
        callback = function(ctx)
          local clients = vim.lsp.get_active_clients({ bufnr = ctx.buf })
          for _, client in ipairs(clients) do
            vim.lsp.buf_detach_client(ctx.buf, client.id)
          end
        end,
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall' },
  },
  {
    'glepnir/lspsaga.nvim',
    commit = 'b7b477',
    -- dir = '~/repos/github.com/yuki-yano/lspsaga.nvim',
    event = { 'LspAttach' },
    config = function()
      require('lspsaga').init_lsp_saga({
        border_style = 'rounded',
        -- saga_winblend = 10,
        diagnostic_header = { ' ', ' ', ' ', ' ' },
        code_action_lightbulb = {
          enable = false,
        },
      })

      -- TODO: new version settings
      -- require('lspsaga').setup({
      --   ui = {
      --     border = 'rounded',
      --     winblend = 10,
      --     code_action = ' ',
      --     diagnostic = ' ',
      --     incoming = ' ',
      --     outgoing = ' ',
      --     colors = {
      --       normal_bg = '#1D1536',
      --       title_bg = '#B4BE82',
      --       red = '#EA6962',
      --       magenta = '#D3869B',
      --       orange = '#FFAF60',
      --       yellow = '#D8A657',
      --       green = '#A9B665',
      --       cyan = '#89B482',
      --       blue = '#7DAEA3',
      --       purple = '#CBA6F7',
      --       white = '#D4BE98',
      --       black = '#32302F',
      --     },
      --     kind = {},
      --   },
      --   lightbulb = {
      --     enable = false,
      --   },
      --   symbol_in_winbar = {
      --     enable = false,
      --   },
      -- })

      -- different window is previewed than when jumped
      -- vim.api.nvim_create_autocmd({ 'CursorHold' }, {
      --   pattern = { '*' },
      --   callback = function()
      --     vim.cmd([[Lspsaga show_cursor_diagnostics]])
      --   end,
      -- })

      vim.keymap.set({ 'n' }, 'K', function()
        local ft = vim.o.filetype
        if ft == 'vim' or ft == 'help' then
          vim.cmd([[execute 'h ' . expand('<cword>') ]])
        else
          vim.cmd([[Lspsaga hover_doc]])
        end
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)h', '<Cmd>Lspsaga lsp_finder<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)D', '<Cmd>Lspsaga peek_definition<CR>')
      -- Use actions-preview.nvim
      -- vim.keymap.set({ 'n', 'x' }, '<Plug>(lsp)a', '<Cmd>Lspsaga code_action<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rn', '<Cmd>Lspsaga rename<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)n', '<Cmd>Lspsaga diagnostic_jump_next<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)p', '<Cmd>Lspsaga diagnostic_jump_prev<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)m', '<Cmd>Lspsaga show_cursor_diagnostics<CR>')
    end,
  },
  {
    'zbirenbaum/neodim',
    dependencies = { { 'nvim-treesitter/nvim-treesitter' } },
    event = { 'LspAttach' },
    init = function()
      -- TODO: workaround
      vim.api.nvim_set_hl(0, 'TSPunctuationBracket', { link = 'TSPunctBracket' })
      vim.api.nvim_set_hl(0, 'TSPunctuationDelimiter', { link = 'TSPunctDelimiter' })
      vim.api.nvim_set_hl(0, 'TSSpell', { link = '@spell' })
    end,
    config = function()
      require('neodim').setup({
        update_in_insert = {
          enable = false,
        },
        hide = {
          signs = false,
          underline = true,
        },
      })
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    config = function()
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
      require('fidget').setup()
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = { 'LspAttach' },
    config = function()
      require('lsp_signature').setup({
        hint_enable = false,
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
        icons = icons,
      })
    end,
  },
  {
    'yioneko/nvim-vtsls',
    config = function()
      vim.keymap.set({ 'n' }, '<Plug>(lsp)s', '<Cmd>VtsExec goto_source_definition<CR>')
      vim.api.nvim_create_user_command('OrganizeImport', function()
        vim.cmd([[VtsExec organize_imports]])
      end, {})
    end,
  },
  {
    'yuki-yano/lsp_lines.nvim',
    event = { 'LspAttach' },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },

        callback = function()
          vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { link = 'DiagnosticSignError' })
          vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { link = 'DiagnosticSignWarn' })
        end,
      })
    end,
    config = function()
      local virtual_lines = { mode = 'current', value = { only_current_line = true } }
      require('lsp_lines').setup()
      vim.diagnostic.config({ virtual_lines = virtual_lines.value })

      vim.keymap.set({ 'n' }, '<Plug>(lsp)l', cycle_lsp_lines)
    end,
  },
}

for _, plugin in ipairs(plugins) do
  plugin.enabled = vim.env.LSP == 'nvim'
end

return plugins
