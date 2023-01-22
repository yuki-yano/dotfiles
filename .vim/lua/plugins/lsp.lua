local add_disable_cmp_filetypes = require('plugin_utils').add_disable_cmp_filetypes
local base_colors = require('color').base_colors
local lsp_icons = require('font').lsp_icons
local codicons = require('font').codicons
local diagnostic_icons = require('font').diagnostic_icons
local enable_lsp_lines = require('plugin_utils').enable_lsp_lines
local get_lsp_lines_status = require('plugin_utils').get_lsp_lines_status
local cycle_lsp_lines = require('plugin_utils').cycle_lsp_lines

local plugins = {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufWrite' },
    -- Use onetime deno file
    ft = { 'typescript', 'typescriptreact' },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'jose-elias-alvarez/null-ls.nvim' },
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
      local signs = {
        Error = diagnostic_icons.error,
        Warn = diagnostic_icons.warn,
        Info = diagnostic_icons.info,
        Hint = diagnostic_icons.hint,
      }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      local lspconfig = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')
      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      local null_ls = require('null-ls')

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

          client.server_capabilities.semanticTokensProvider = nil

          if client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, bufnr)
          end
        end,
      }

      local node_root_dir = lspconfig.util.root_pattern('package.json')
      local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

      mason_lspconfig.setup_handlers({
        function(server_name)
          -- NOTE: vtsls added to mason and lspconfig
          --       Try to always enable vtsls
          if server_name == 'vtsls' then
            if not is_node_repo then
              return
            end

            -- Load nvim-vtsls
            require('vtsls')

            opts.settings = {
              typescript = {
                suggest = {
                  completeFunctionCalls = true,
                },
              },
            }
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
      vim.keymap.set({ 'n' }, '<Plug>(lsp)I', vim.lsp.buf.implementation)
      vim.keymap.set({ 'n' }, '<Plug>(lsp)t', '<Cmd>FzfPreviewNvimLspTypeDefinitionRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)T', vim.lsp.buf.type_definition)
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
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
              vim.lsp.buf.format({ name = 'denols' })
            end)
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
          -- 'tsserver',
          'vtsls',
          'eslint',
          'denols',
          'sumneko_lua',
          'vimls',
          'jsonls',
          'yamlls',
        },
        automatic_installation = true,
      })

      require('mason-null-ls').setup({
        ensure_installed = {
          'prettierd',
          'stylua',
          'cspell',
        },
        automatic_installation = true,
      })
    end,
  },
  {
    'glepnir/lspsaga.nvim',
    -- NOTE: Use versions earlier than 0.2.3
    commit = 'b7b477',
    -- dir = '~/repos/github.com/yuki-yano/lspsaga.nvim',
    event = { 'LspAttach' },
    init = function()
      add_disable_cmp_filetypes({ 'sagarename' })
    end,
    config = function()
      require('lspsaga').init_lsp_saga({
        border_style = 'rounded',
        -- saga_winblend = 10,
        diagnostic_header = {
          diagnostic_icons.error .. ' ',
          diagnostic_icons.warn .. ' ',
          diagnostic_icons.info .. ' ',
          diagnostic_icons.hint .. ' ',
        },
        code_action_lightbulb = {
          enable = false,
        },
      })

      -- TODO: new version settings
      -- require('lspsaga').setup({
      --   ui = {
      --     theme = 'round',
      --     border = 'rounded',
      --     title = true,
      --     code_action = lsp_icons.code_action,
      --     diagnostic = lsp_icons.diagnostics,
      --     incoming = lsp_icons.incoming,
      --     outgoing = lsp_icons.outgoing,
      --     colors = {
      --       normal_bg = base_colors.black,
      --       title_bg = base_colors.green,
      --       red = base_colors.red,
      --       magenta = base_colors.magenta,
      --       orange = base_colors.orange,
      --       yellow = base_colors.yellow,
      --       green = base_colors.green,
      --       cyan = base_colors.cyan,
      --       blue = base_colors.blue,
      --       purple = base_colors.purple,
      --       white = base_colors.white,
      --       black = base_colors.black,
      --     },
      --   },
      --   diagnostic = {
      --     show_code_action = false,
      --   },
      --   lightbulb = {
      --     enable = false,
      --   },
      --   symbol_in_winbar = {
      --     enable = false,
      --   },
      -- })

      -- TODO: Integrate with nvim-ufo
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
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'LspAttach' },
    init = function()
      -- FIX: Workaround, highlighted group does not exist error
      --      TSPunctuation{Xxx} where it should be defined as TSPunct{Xxx}.
      vim.api.nvim_set_hl(0, 'TSPunctuationBracket', { link = '@punctuation.bracket' })
      vim.api.nvim_set_hl(0, 'TSPunctuationDelimiter', { link = '@punctuation.delimiter' })
      vim.api.nvim_set_hl(0, 'TSPunctuationSpecial', { link = '@punctuation.special' })
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
    -- Load from lspconfig
    'SmiteshP/nvim-navic',
    config = function()
      require('nvim-navic').setup({
        icons = codicons,
      })
    end,
  },
  {
    'yioneko/nvim-vtsls',
    config = function()
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'typescript', 'typescriptreact' },
        callback = function()
          vim.keymap.set({ 'n' }, '<Plug>(lsp)s', '<Cmd>VtsExec goto_source_definition<CR>')
        end,
      })
      vim.api.nvim_create_user_command('OrganizeImport', function()
        vim.cmd([[VtsExec organize_imports]])
      end, {})
    end,
  },
  {
    -- NOTE: Use my fork
    'yuki-yano/lsp_lines.nvim',
    enabled = enable_lsp_lines,
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
      local virtual_lines = get_lsp_lines_status()
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
