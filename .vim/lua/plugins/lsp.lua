local add_disable_cmp_filetypes = require('rc.plugin_utils').add_disable_cmp_filetypes
local color = require('rc.color')
local lsp_icons = require('rc.font').lsp_icons
local codicons = require('rc.font').codicons
local diagnostic_icons = require('rc.font').diagnostic_icons
local enabled_inlay_hint = require('rc.plugin_utils').enabled_inlay_hint
local enabled_inlay_hint_default_value = require('rc.plugin_utils').enabled_inlay_hint_default_value
local enable_lsp_lines = require('rc.plugin_utils').enable_lsp_lines
local get_lsp_lines_status = require('rc.plugin_utils').get_lsp_lines_status
local cycle_lsp_lines = require('rc.plugin_utils').cycle_lsp_lines

local plugins = {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufWrite' },
    -- NOTE: Use onetime deno file
    ft = { 'typescript', 'typescriptreact' },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'jose-elias-alvarez/null-ls.nvim' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'b0o/SchemaStore.nvim' },
      { 'SmiteshP/nvim-navic' },
      { 'jose-elias-alvarez/typescript.nvim' },
      { 'yioneko/nvim-vtsls' },
      -- { 'kevinhwang91/nvim-ufo' }, -- NOTE: Explicitly adding to dependencies causes errors when loading
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

          if client.name ~= 'lua_ls' then
            -- client.server_capabilities.semanticTokensProvider = nil
          end

          if client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, bufnr)
          end

          if client.server_capabilities.inlayHintProvider then
            -- NOTE: This is a workaround for current inlay hints state
            enabled_inlay_hint[bufnr] = enabled_inlay_hint_default_value
            vim.lsp.inlay_hint(bufnr, enabled_inlay_hint_default_value)

            vim.keymap.set({ 'n' }, '<Plug>(lsp)h', function()
              local buf = vim.api.nvim_get_current_buf()
              local enabled = not enabled_inlay_hint[buf]
              vim.lsp.inlay_hint(buf, enabled)
              enabled_inlay_hint[buf] = enabled
            end)

            vim.keymap.set({ 'n' }, '<Plug>(lsp)H', function()
              enabled_inlay_hint_default_value = not enabled_inlay_hint_default_value
              for i, _ in pairs(enabled_inlay_hint) do
                enabled_inlay_hint[i] = enabled_inlay_hint_default_value
                vim.lsp.inlay_hint(i, enabled_inlay_hint_default_value)
              end
            end)

            vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
              buffer = bufnr,
              callback = function()
                if vim.v.event.new_mode == 'i' or vim.v.event.new_mode == 'v' or vim.v.event.new_mode == 'V' then
                  vim.lsp.inlay_hint(bufnr, false)
                else
                  vim.lsp.inlay_hint(bufnr, enabled_inlay_hint[vim.api.nvim_get_current_buf()])
                end
              end,
            })
          end
        end,
      }

      local node_root_dir = lspconfig.util.root_pattern('package.json')
      local is_node_repo = node_root_dir(vim.api.nvim_buf_get_name(0)) ~= nil

      mason_lspconfig.setup_handlers({
        function(server_name)
          local typescriptInlayHints = {
            parameterNames = {
              enabled = 'literals',
              suppressWhenArgumentMatchesName = true,
            },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = false },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          }

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
                inlayHints = typescriptInlayHints,
              },
            }
          end

          if server_name == 'eslint' then
            if not is_node_repo then
              return
            end
          end

          if server_name == 'tailwindcss' then
            opts.settings = {
              tailwindCSS = {
                classAttributes = { 'class', 'className', 'class:list', 'classList', '.*Class', '.*ClassName' },
                lint = {
                  cssConflict = 'warning',
                  invalidApply = 'error',
                  invalidConfigPath = 'error',
                  invalidScreen = 'error',
                  invalidTailwindDirective = 'error',
                  invalidVariant = 'error',
                  recommendedVariantOrder = 'warning',
                },
                validate = true,
              },
            }
          end

          if server_name == 'denols' then
            if is_node_repo then
              return
            end

            opts.root_dir = lspconfig.util.root_pattern('deno.json')
            opts.init_options = {
              lint = true,
              unstable = true,
              documentPreloadLimit = 0,
              suggest = {
                imports = {
                  hosts = {
                    ['https://deno.land'] = true,
                  },
                },
              },
              inlayHints = typescriptInlayHints,
              single_file_support = true,
            }
          end

          if server_name == 'lua_ls' then
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
            method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
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
          if vim.o.filetype == 'astro' then
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
              vim.lsp.buf.format({ name = 'astro' })
            end)
          elseif is_node_repo then
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', function()
              if vim.fn.exists(':EslintFixAll') == 2 then
                vim.cmd([[EslintFixAll]])
              end
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
        pattern = { 'json' },
        callback = function()
          vim.lsp.buf.format({ name = 'null-ls' })
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
          'tailwindcss',
          'astro',
          'denols',
          'lua_ls',
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
    event = { 'LspAttach' },
    init = function()
      add_disable_cmp_filetypes({ 'sagarename' })
    end,
    config = function()
      require('lspsaga').setup({
        ui = {
          theme = 'round',
          border = 'rounded',
          title = false,
          winblend = 10,
          expand = '>',
          collapse = 'v',
          preview = '< ',
          hover = diagnostic_icons.hint,
          code_action = lsp_icons.code_action,
          diagnostic = lsp_icons.diagnostic,
          incoming = lsp_icons.incoming,
          outgoing = lsp_icons.outgoing,
          -- NOTE: from: `require('catppuccin.groups.integrations.lsp_saga').custom_colors()`
          colors = {
            normal_bg = color.base().black,
            title_bg = color.base().green,
            black = color.base().empty,
            white = color.base().white, -- TODO: change to text
            red = color.base().red,
            blue = color.base().blue,
            green = color.base().green,
            yellow = color.base().yellow,
            cyan = color.base().cyan, -- TODO: change to sky
            magenta = color.base().magenta, -- TODO: change to maroon
            orange = color.base().orange,
            purple = color.base().purple,
          },
        },
        -- scroll_preview = {
        --   scroll_down = '<C-d>',
        --   scroll_up = '<C-u>',
        -- },
        definition = {
          edit = '<CR>',
          quit = 'q',
          close = '<Esc>',
        },
        diagnostic = {
          custom_msg = 'Message:',
          custom_fix = 'Fix:',
        },
        rename = {
          quit = '<C-c>',
          exec = '<CR>',
          mark = '<Space>',
          confirm = '<CR>',
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
        if require('ufo').peekFoldedLinesUnderCursor() then
          return
        end

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
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rN', '<Cmd>Lspsaga rename ++project<CR>')
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
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'TSPunctuationBracket', { link = '@punctuation.bracket' })
          vim.api.nvim_set_hl(0, 'TSPunctuationDelimiter', { link = '@punctuation.delimiter' })
          vim.api.nvim_set_hl(0, 'TSPunctuationSpecial', { link = '@punctuation.special' })
          vim.api.nvim_set_hl(0, 'TSSpell', { link = '@spell' })
        end,
      })
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
    tag = 'legacy',
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
        pattern = { '*' },

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
  if plugin.enabled == nil then
    plugin.enabled = vim.env.LSP == 'nvim'
  end
end

return plugins
