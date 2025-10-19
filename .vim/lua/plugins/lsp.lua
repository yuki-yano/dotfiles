local add_disable_cmp_filetypes = require('rc.modules.plugin_utils').add_disable_cmp_filetypes
local is_node_repo = require('rc.modules.plugin_utils').is_node_repo
local color = require('rc.modules.color')
local lsp_icons = require('rc.modules.font').lsp_icons
local codicons = require('rc.modules.font').codicons
local diagnostic_icons = require('rc.modules.font').diagnostic_icons
local enabled_inlay_hint = require('rc.modules.plugin_utils').enabled_inlay_hint
local enabled_inlay_hint_default_value = require('rc.modules.plugin_utils').enabled_inlay_hint_default_value

local uv = vim.uv or vim.loop

local function load_vtsls_override()
  local paths = {
    vim.fn.stdpath('config') .. '/after/lsp/vtsls.lua',
    vim.fn.expand('~/.vim/after/lsp/vtsls.lua'),
  }

  for _, path in ipairs(paths) do
    if path ~= '' then
      local stat = uv.fs_stat(path)
      if stat then
        local ok, err = pcall(dofile, path)
        if not ok then
          vim.notify(string.format('vtsls override failed: %s', err), vim.log.levels.WARN)
        end
      end
    end
  end
end

local enable_vtsls = true
local enable_tsserver = not enable_vtsls

local plugins = {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufWrite' },
    -- NOTE: Use onetime deno file
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
      -- { 'davidosomething/format-ts-errors.nvim' },
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

      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      local null_ls = require('null-ls')

      vim.lsp.config('*', {
        capabilities = cmp_nvim_lsp.default_capabilities(),
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
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
          null_ls.builtins.code_actions.gitsigns,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.biome.with({
            condition = function(utils)
              return utils.root_has_file({ 'biome.json' })
            end,
          }),
          null_ls.builtins.formatting.stylua,
          require('cspell').diagnostics.with({
            method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
            diagnostics_postprocess = function(d)
              d.severity = vim.diagnostic.severity.HINT
            end,
          }),
          require('cspell').code_actions,
        },
      })

      -- Helper function to extract word from diagnostic
      local function extract_word_from_diagnostic(diag, cspell_helpers)
        if cspell_helpers and cspell_helpers.get_word then
          return cspell_helpers.get_word(diag)
        end

        -- Fallback to manual extraction
        local word = diag.user_data and diag.user_data.misspelled
        if not word then
          local line = vim.api.nvim_buf_get_lines(0, diag.lnum, diag.lnum + 1, false)[1]
          if line then
            word = line:sub(diag.col + 1, diag.end_col)
          end
        end
        return word
      end

      -- Extract unique words from cspell diagnostics
      local function extract_cspell_words(diagnostics, cspell_helpers)
        local words = {}
        local seen = {}

        for _, diag in ipairs(diagnostics) do
          if diag.source == 'cspell' then
            local word = extract_word_from_diagnostic(diag, cspell_helpers)
            if word and not seen[word] then
              seen[word] = true
              table.insert(words, word)
            end
          end
        end

        return words
      end

      -- Add words using cspell.nvim helpers
      local function add_words_with_cspell_helpers(words, cspell_helpers)
        -- Create params object with necessary fields
        local params = {
          bufnr = vim.api.nvim_get_current_buf(),
          bufname = vim.api.nvim_buf_get_name(0),
          get_config = function()
            return {
              config_file_preferred_name = 'cspell.json',
              encode_json = vim.json.encode,
              decode_json = vim.json.decode,
            }
          end,
        }

        -- Find or generate config path
        local cwd = vim.fn.getcwd()
        local cspell_config_path = cspell_helpers.get_config_path and cspell_helpers.get_config_path(params, cwd)

        if not cspell_config_path and cspell_helpers.generate_cspell_config_path then
          cspell_config_path = cspell_helpers.generate_cspell_config_path(params, cwd)
        end

        if not cspell_config_path then
          cspell_config_path = cwd .. '/cspell.json'
        end

        -- Add words using cspell's function
        local success, err = pcall(cspell_helpers.add_words_to_json, params, words, cspell_config_path)
        if success then
          vim.notify(string.format('Added %d words to dictionary', #words), vim.log.levels.INFO)
          -- Trigger diagnostics refresh
          vim.diagnostic.reset(nil, 0)
          vim.cmd('edit!')
          return true
        else
          vim.notify('Failed to add words using cspell helpers: ' .. tostring(err), vim.log.levels.WARN)
          return false
        end
      end

      -- Fallback: add words using code actions
      local function add_words_with_code_actions(words, diagnostics, cspell_helpers)
        vim.notify('Using fallback method to add words...', vim.log.levels.INFO)
        local added = 0
        local saved_pos = vim.api.nvim_win_get_cursor(0)

        for _, word in ipairs(words) do
          local word_added = false

          -- Find first diagnostic for this word
          for _, diag in ipairs(diagnostics) do
            if diag.source == 'cspell' and not word_added then
              local diag_word = extract_word_from_diagnostic(diag, cspell_helpers)

              if diag_word == word then
                -- Move cursor to diagnostic position
                vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })

                -- Request code actions at this position
                local params = vim.lsp.util.make_range_params(0, 'utf-16')
                params.context = {
                  diagnostics = { diag },
                  only = { vim.lsp.protocol.CodeActionKind.QuickFix },
                }

                local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)
                if results then
                  for client_id, result in pairs(results) do
                    if result.result and not word_added then
                      for _, action in ipairs(result.result) do
                        if action.title and action.title:match('Add.*dictionary') and not word_added then
                          -- Try to apply the action
                          if action.command then
                            local client = vim.lsp.get_client_by_id(client_id)
                            if client then
                              client:request('workspace/executeCommand', action.command)
                              added = added + 1
                              word_added = true
                              break
                            end
                          end
                        end
                      end
                    end
                  end
                end
                break
              end
            end
          end
        end

        -- Restore cursor position
        vim.api.nvim_win_set_cursor(0, saved_pos)
        vim.notify(string.format('Added %d/%d words to dictionary', added, #words), vim.log.levels.INFO)
      end

      -- Main function to add cspell diagnostics to dictionary
      local function add_cspell_diagnostics_to_dictionary(diagnostics, scope_desc)
        -- Try to load cspell.nvim's helpers module
        local ok, cspell_helpers = pcall(require, 'cspell.helpers')
        if not ok then
          cspell_helpers = nil
        end

        -- Extract unique words from diagnostics
        local words = extract_cspell_words(diagnostics, cspell_helpers)

        if #words == 0 then
          vim.notify('No cspell diagnostics found in ' .. scope_desc, vim.log.levels.INFO)
          return
        end

        -- Try to use cspell helpers first
        if cspell_helpers and cspell_helpers.add_words_to_json then
          if add_words_with_cspell_helpers(words, cspell_helpers) then
            return
          end
        end

        -- Fallback to code actions
        add_words_with_code_actions(words, diagnostics, cspell_helpers)
      end

      -- Add all cspell diagnostics in range to dictionary
      vim.api.nvim_create_user_command('CspellAddAllInRange', function(opts)
        local diagnostics = vim.diagnostic.get(0, {
          lnum_start = opts.line1 - 1,
          lnum_end = opts.line2 - 1,
        })
        add_cspell_diagnostics_to_dictionary(diagnostics, 'the selected range')
      end, { range = true, desc = 'Add all cspell diagnostics in range to dictionary' })

      -- Add all cspell diagnostics in entire file to dictionary
      vim.api.nvim_create_user_command('CspellAddAll', function()
        local diagnostics = vim.diagnostic.get(0)
        add_cspell_diagnostics_to_dictionary(diagnostics, 'the file')
      end, { desc = 'Add all cspell diagnostics in file to dictionary' })

      vim.keymap.set('n', '<Plug>(lsp)f', function()
        vim.lsp.buf.format()
      end, { buffer = true, desc = 'Format current buffer' })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        callback = function(ev)
          if vim.bo[ev.buf].filetype == 'astro' then
            vim.keymap.set('n', '<Plug>(lsp)f', function()
              vim.lsp.buf.format({
                bufnr = ev.buf,
                filter = function(c)
                  return c.name == 'null-ls' or c.name == 'astro'
                end,
              })
            end, { buffer = ev.buf, desc = 'Format with null-ls/astro' })
          elseif is_node_repo() then
            vim.keymap.set('n', '<Plug>(lsp)f', function()
              if vim.fn.exists(':EslintFixAll') == 2 then
                vim.cmd('EslintFixAll')
              end
              vim.lsp.buf.format({
                bufnr = ev.buf,
                filter = function(c)
                  return c.name == 'null-ls'
                end,
              })
            end, { buffer = ev.buf, desc = 'Format with Eslint & null-ls' })
          else
            vim.keymap.set('n', '<Plug>(lsp)f', function()
              -- fallback to LSP formatting
              vim.lsp.buf.format({
                bufnr = ev.buf,
                filter = function(c)
                  return c.name == 'denols'
                end,
              })
            end, { buffer = ev.buf, desc = 'Format with denols' })
          end
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'json',
        callback = function(ev)
          vim.keymap.set('n', '<Plug>(lsp)f', function()
            vim.lsp.buf.format({
              bufnr = ev.buf,
              filter = function(c)
                return c.name == 'null-ls'
              end,
            })
          end, { buffer = ev.buf, desc = 'Format JSON with null-ls' })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'lua',
        callback = function(ev)
          vim.keymap.set('n', '<Plug>(lsp)f', function()
            vim.lsp.buf.format({
              bufnr = ev.buf,
              filter = function(c)
                return c.name == 'null-ls'
              end,
            })
          end, { buffer = ev.buf, desc = 'Format Lua with null-ls' })
        end,
      })

      vim.api.nvim_create_user_command('OrganizeImport', function()
        local clients = vim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })
        if #clients > 0 then
          clients[1]:exec_cmd({
            title = 'Organize Imports',
            command = '_typescript.organizeImports',
            arguments = { vim.api.nvim_buf_get_name(0) },
          })
        else
          clients = vim.lsp.get_clients({ bufnr = 0, name = 'tsserver' })
          if #clients > 0 then
            clients[1]:exec_cmd({
              title = 'Organize Imports',
              command = '_typescript.organizeImports',
              arguments = { vim.api.nvim_buf_get_name(0) },
            })
          end
        end
      end, {})
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

      local mason_lspconfig = require('mason-lspconfig')
      local ts_lsp = enable_tsserver and 'tsserver' or 'vtsls'
      mason_lspconfig.setup({
        ensure_installed = {
          ts_lsp,
          'eslint',
          'biome',
          'tailwindcss',
          'denols',
          'astro',
          'lua_ls',
          'vimls',
          'jsonls',
          'yamlls',
        },
        automatic_enable = {
          exclude = { 'vtsls' },
        },
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
    enabled = enable_tsserver,
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
    enabled = enable_vtsls,
    config = function()
      load_vtsls_override()

      local configs = require('lspconfig.configs')
      local vtsls_config = require('vtsls').lspconfig
      if not configs.vtsls then
        configs.vtsls = vtsls_config
      end
      require('lspconfig').vtsls.setup({
        autostart = false,
        root_dir = vtsls_config.default_config.root_dir,
        single_file_support = vtsls_config.default_config.single_file_support,
        on_new_config = vtsls_config.default_config.on_new_config,
      })

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'typescript', 'typescriptreact' },
        callback = function()
          vim.keymap.set({ 'n' }, '<Plug>(lsp)s', '<Cmd>VtsExec goto_source_definition<CR>')
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        callback = function(ev)
          if not is_node_repo(ev.buf) then
            return
          end

          local manager = require('lspconfig').vtsls.manager
          if manager then
            manager:try_add(ev.buf)
          end
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
