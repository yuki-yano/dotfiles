local get_disable_cmp_filetypes = require('rc.modules.plugin_utils').get_disable_cmp_filetypes
local color = require('rc.modules.color')
local codicons = require('rc.modules.font').codicons
local misc_icons = require('rc.modules.font').misc_icons
local todo_icons = require('rc.modules.font').todo_icons
local list_concat = require('rc.modules.utils').list_concat
local is_editprompt = require('rc.setup.quick_ime').is_editprompt
-- local enable_noice = require('rc.modules.plugin_utils').enable_noice

return {
  {
    'hrsh7th/nvim-cmp',
    event = vim.env.LSP == 'nvim' and { 'InsertEnter', 'CmdlineEnter' } or { 'VeryLazy' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'ray-x/cmp-treesitter' },
      { 'hrsh7th/cmp-buffer' },
      { 'andersevenrud/cmp-tmux' },
      { 'lukas-reineke/cmp-rg' },
      { 'octaltree/cmp-look' },
      { 'hrsh7th/cmp-path' },
      { 'onsails/lspkind-nvim' },
      {
        'saadparwaiz1/cmp_luasnip',
        dependencies = {
          { 'L3MON4D3/LuaSnip' },
        },
      },
      {
        'kento-ogata/cmp-tsnip',
        dependencies = {
          { 'yuki-yano/tsnip.nvim' },
        },
      },
      -- { 'tzachar/cmp-tabnine', build = './install.sh' },
      {
        'zbirenbaum/copilot-cmp',
        dependencies = {
          { 'zbirenbaum/copilot.lua' },
        },
      },
      { 'hrsh7th/cmp-cmdline' },
      { 'uga-rosa/cmp-skkeleton' },
      {
        'tzachar/cmp-fuzzy-path',
        dependencies = {
          {
            'tzachar/fuzzy.nvim',
            dependencies = {
              { 'romgrk/fzy-lua-native' },
            },
          },
        },
      },
      { 'nvim-tree/nvim-web-devicons' },
      { 'roobert/tailwindcss-colorizer-cmp.nvim' },
      {
        'biosugar0/cmp-claudecode',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
      -- { 'cohama/lexima.vim' }, -- NOTE: Load before cmp
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
        callback = function()
          require('cmp').setup({
            enabled = true,
          })
        end,
      })

      vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
        callback = function()
          require('cmp').setup({
            enabled = vim.env.LSP == 'nvim',
          })
        end,
      })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { fg = color.misc().completion.match })
          vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { fg = color.misc().completion.match })

          vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindNumber', { fg = color.base().magenta })
          vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = color.base().green })
          vim.api.nvim_set_hl(0, 'CmpItemKindKey', { fg = color.base().blue })
          vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'CmpItemKindReference', { fg = color.base().cyan })
          vim.api.nvim_set_hl(0, 'CmpItemKindFolder', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = color.base().magenta })
          vim.api.nvim_set_hl(0, 'CmpItemKindNull', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindValue', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = color.base().white })
          vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = color.base().green })
          vim.api.nvim_set_hl(0, 'CmpItemKindModule', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'CmpItemKindPackage', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = color.base().green })
          vim.api.nvim_set_hl(0, 'CmpItemKindOperator', { fg = color.base().orange })
          vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'CmpItemKindObject', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = color.base().green })
          vim.api.nvim_set_hl(0, 'CmpItemKindArray', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindEnum', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindField', { fg = color.base().blue })
          vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = color.base().blue })
          vim.api.nvim_set_hl(0, 'CmpItemKindColor', { fg = color.base().magenta })
          vim.api.nvim_set_hl(0, 'CmpItemKindFile', { fg = color.base().red })
          vim.api.nvim_set_hl(0, 'CmpItemKindEvent', { fg = color.base().white })
          vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', { fg = color.base().white })
          vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = color.base().green })
          vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindBoolean', { fg = color.base().magenta })
          vim.api.nvim_set_hl(0, 'CmpItemKindNamespace', { fg = color.base().yellow })
          vim.api.nvim_set_hl(0, 'CmpItemKindString', { fg = color.base().cyan })
          vim.api.nvim_set_hl(0, 'CmpItemKindEnumMember', { fg = color.base().blue })
        end,
      })
    end,
    config = function()
      local cmp = require('cmp')
      local types = require('cmp.types')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')

      require('cmp.utils.misc').redraw.incsearch_redraw_keys = '<C-r><BS>'
      lspkind.init({
        preset = 'codicons',
        symbol_map = codicons,
      })

      if vim.env.LSP == 'nvim' then
        -- NOTE: After load lexima key mappings
        require('copilot').setup({
          suggestion = {
            auto_trigger = true,
            keymap = {
              accept = '<Tab>',
              -- <C-]> is used for insx
              dismiss = false,
            },
          },
          filetypes = {
            ['.'] = true,
            -- typescript = true,
            -- typescriptreact = true,
            -- lua = true,
            -- vim = true,
          },
        })
        require('copilot_cmp').setup()
      end

      -- NOTE: force_keyword_length is used from manual complete
      local sources = {
        { name = 'luasnip', keyword_length = 2, force_keyword_length = true },
        { name = 'tsnip', keyword_length = 2, force_keyword_length = true },
        -- { name = 'copilot' },
        { name = 'nvim_lsp' },
        -- { name = 'treesitter' },
        { name = 'nvim_lua', max_item_count = 20 },
        { name = 'lazydev', group_index = 0 },
        -- { name = 'nvim_lsp_signature_help' },
        -- { name = 'cmp_tabnine', keyword_length = 2 },
        { name = 'buffer' },
        { name = 'tmux', keyword_length = 4, max_item_count = 10, option = { all_panes = true } },
        { name = 'rg', keyword_length = 4, max_item_count = 10 },
        { name = 'look', keyword_length = 4, max_item_count = 10, option = { convert_case = true, loud = true } },
        { name = 'path' },
        -- { name = 'skkeleton' },
      }

      if is_editprompt() then
        require('cmp_claudecode').setup()
        table.insert(sources, 1, {
          name = 'claude_at',
          priority = 900,
        })
        table.insert(sources, 1, {
          name = 'claude_slash',
          priority = 900,
        })
      end

      cmp.setup({
        enabled = vim.env.LSP == 'nvim',
        mapping = vim.env.LSP == 'nvim'
            and cmp.mapping.preset.insert({
              ['<C-u>'] = cmp.mapping.scroll_docs(-4),
              ['<C-d>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping(function()
                local input = vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2])
                local match_list = vim.fn.matchlist(input, [[\k\+$]])
                local length = vim.fn.len(match_list) == 0 and 0 or vim.fn.len(match_list[1])

                -- Force use of keyword_length if force_keyword_length is true
                local manual_sources = {}
                for _, source in ipairs(sources) do
                  if source.force_keyword_length then
                    if length >= source.keyword_length then
                      table.insert(manual_sources, source)
                    end
                  else
                    table.insert(manual_sources, source)
                  end
                end

                cmp.mapping.complete({
                  config = {
                    sources = cmp.config.sources(manual_sources),
                  },
                })()
              end),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping(function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                  cmp.confirm({ select = true })
                else
                  fallback()
                end
              end),
              ['<C-n>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
                else
                  fallback()
                end
              end),
              ['<C-p>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
                else
                  fallback()
                end
              end),
              ['<C-f>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(1) then
                  luasnip.jump(1)
                elseif vim.snippet.active({ direction = 1 }) then
                  vim.snippet.jump(1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<C-b>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                elseif vim.snippet.active({ direction = -1 }) then
                  vim.snippet.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            })
          or {},
        window = {
          completion = cmp.config.window.bordered({}),
          documentation = cmp.config.window.bordered({}),
        },
        sources = cmp.config.sources(sources),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          expandable_indicator = true,
          format = lspkind.cmp_format({
            mode = 'symbol',
            before = function(entry, vim_item)
              local menu = {
                luasnip = '[Snippet]',
                tsnip = '[TSnip]',
                -- copilot = '[Copilot]',
                nvim_lsp = '[LSP]',
                treesitter = '[Tree]',
                nvim_lua = '[Lua]',
                nvim_lsp_signature_help = '[Signature]',
                -- cmp_tabnine = '[Tabnine]',
                buffer = '[Buffer]',
                tmux = '[Tmux]',
                rg = '[Rg]',
                look = '[Look]',
                path = '[Path]',
                claude_at = '[Claude @]',
                claude_slash = '[Claude /]',
              }

              vim_item = require('tailwindcss-colorizer-cmp').formatter(entry, vim_item)
              if entry.source.name == 'nvim_lsp' then
                vim_item.menu = '[' .. entry.source.source.client.name .. ']'
              else
                vim_item.menu = menu[entry.source.name] or entry.source.name
              end

              return vim_item
            end,
          }),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
      })

      local cmdline_mappings = cmp.mapping.preset.cmdline({
        ['<C-n>'] = vim.NIL,
        ['<C-p>'] = vim.NIL,
        ['<C-e>'] = vim.NIL,
      })

      local incsearch_settings = {
        mapping = cmdline_mappings,
        sources = cmp.config.sources({
          { name = 'buffer' },
        }),
        formatting = {
          fields = { 'kind', 'abbr' },
          format = lspkind.cmp_format({ mode = 'symbol' }),
        },
      }

      cmp.setup.cmdline('/', incsearch_settings)
      cmp.setup.cmdline('?', incsearch_settings)
      cmp.setup.cmdline(':', {
        mapping = cmdline_mappings,
        sources = cmp.config.sources({
          { name = 'cmdline' },
          { name = 'path' },
          {
            name = 'fuzzy_path',
            trigger_characters = { ' ', '.', '/', '~' },
            options = {
              fd_cmd = {
                'fd',
                '--hidden',
                '--max-depth',
                '20',
                '--full-path',
                '--exclude',
                '.git',
              },
            },
            entry_filter = function(entry)
              return not vim.tbl_contains({ 'No matches found', 'Searching...' }, entry:get_word())
            end,
          },
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          expandable_indicator = true,
          format = function(entry, vim_item)
            if vim.tbl_contains({ 'path', 'fuzzy_path' }, entry.source.name) then
              local icon, hl_group = require('nvim-web-devicons').get_icon(entry.completion_item.label)
              if icon then
                vim_item.kind = icon
                vim_item.kind_hl_group = hl_group
              else
                vim_item.kind = misc_icons.file
              end
            elseif 'cmdline' == entry.source.name then
              vim_item.kind = misc_icons.cmd
              vim_item.dup = 1
            end

            return lspkind.cmp_format()(entry, vim_item)
          end,
        },
      })

      -- Insert '(' after confirm function or method item
      cmp.event:on('confirm_done', function(evt)
        local Kind = cmp.lsp.CompletionItemKind

        -- TypeScript imported functions are completed as variable with the format `(alias) function {func_name} ...`.
        local ts_extra_matcher = function(item)
          return item.kind == Kind.Variable and string.match(item.detail, '^%(alias%) function ') ~= nil
        end
        local rules = {
          -- NOTE: Disabled because vtsls returns snippet
          -- typescript = {
          --   ['('] = {
          --     kind = { Kind.Function, Kind.Method },
          --     extra_matcher = ts_extra_matcher,
          --   },
          -- },
          -- typescriptreact = {
          --   ['('] = {
          --     kind = { Kind.Function, Kind.Method },
          --     extra_matcher = ts_extra_matcher,
          --   },
          -- },
        }

        local filetype = vim.o.filetype
        local item = evt.entry:get_completion_item()
        if rules[filetype] then
          for key, rule in pairs(rules[filetype]) do
            if vim.tbl_contains(rule.kind, item.kind) or rule.extra_matcher(item) then
              vim.api.nvim_feedkeys(key, 'i', true)
            end
          end
        end
      end)

      cmp.setup.filetype(get_disable_cmp_filetypes(), {
        enabled = false,
      })
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.config/nvim/luasnip' })
    end,
  },
  {
    'yuki-yano/tsnip.nvim',
    dev = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'MunifTanjim/nui.nvim' },
    },
    event = { 'InsertEnter' },
    cmd = { 'TSnip' },
    config = function()
      require('denops-lazy').load('tsnip.nvim', { wait_load = false })
    end,
  },
  {
    'roobert/tailwindcss-colorizer-cmp.nvim',
    config = function()
      require('tailwindcss-colorizer-cmp').setup({ color_square_width = 2 })
    end,
  },
  {
    'machakann/vim-sandwich',
    dependencies = {
      { 'machakann/vim-textobj-functioncall' },
      { 'kana/vim-textobj-entire' },
      { 'kana/vim-textobj-line' },
      { 'thinca/vim-textobj-between' },
      { 'yuki-yano/vim-textobj-cursor-context' },
    },
    event = { 'ModeChanged' },
    keys = {
      { '<Plug>(sandwich-add)', mode = { 'n', 'x' } },
      { '<Plug>(sandwich-delete)', mode = { 'n', 'x' } },
      { '<Plug>(sandwich-delete-auto)', mode = { 'n', 'x' } },
      { '<Plug>(sandwich-replace)', mode = { 'n', 'x' } },
      { '<Plug>(sandwich-replace-auto)', mode = { 'n', 'x' } },
      { '<Plug>(textobj-sandwich-auto-i)', mode = { 'o', 'x' } },
      { '<Plug>(textobj-sandwich-auto-a)', mode = { 'o', 'x' } },
    },
    init = function()
      vim.g.sandwich_no_default_key_mappings = true

      vim.keymap.set({ 'n', 'x' }, 'sa', '<Plug>(sandwich-add)')
      vim.keymap.set({ 'n', 'x' }, 'sd', '<Plug>(sandwich-delete)')
      vim.keymap.set({ 'n', 'x' }, 'sdb', '<Plug>(sandwich-delete-auto)')
      vim.keymap.set({ 'n', 'x' }, 'sr', '<Plug>(sandwich-replace)')
      vim.keymap.set({ 'n', 'x' }, 'srb', '<Plug>(sandwich-replace-auto)')
      vim.keymap.set({ 'o', 'x' }, 'ib', '<Plug>(textobj-sandwich-auto-i)')
      vim.keymap.set({ 'o', 'x' }, 'ab', '<Plug>(textobj-sandwich-auto-a)')

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'OperatorSandwichAdd', { bg = color.misc().sandwich.add })
          vim.api.nvim_set_hl(0, 'OperatorSandwichDelete', { bg = color.misc().sandwich.delete })
          vim.api.nvim_set_hl(0, 'OperatorSandwichChange', { bg = color.misc().sandwich.change })
        end,
      })
    end,
    config = function()
      local vimx = require('artemis')

      local sandwich_recipes = vim.fn.deepcopy(vim.g['sandwich#default_recipes'])
      sandwich_recipes = list_concat({
        sandwich_recipes,
        {
          {
            buns = { '_', '_' },
            quoteescape = 1,
            expand_range = 0,
            nesting = 1,
            linewise = 0,
            match_syntax = 1,
          },
          {
            buns = { '-', '-' },
            quoteescape = 1,
            expand_range = 0,
            nesting = 1,
            linewise = 0,
            match_syntax = 1,
          },
          {
            buns = { '/', '/' },
            quoteescape = 1,
            expand_range = 0,
            nesting = 0,
            linewise = 0,
            match_syntax = 1,
          },
          {
            buns = { '${', '}' },
            input = { '$' },
            filetype = { 'typescript', 'typescriptreact' },
          },
          {
            buns = { '[[', ']]' },
            input = { 's' },
            nesting = 0,
            filetype = { 'lua' },
          },
          {
            buns = { '[=[', ']=]' },
            input = { 'S' },
            nesting = 0,
            filetype = { 'lua' },
          },
        },
      })

      vim.g['sandwich#magicchar#f#patterns'] = {
        {
          header = [[\<\%(\h\k*\.\)*\h\k*]],
          bra = '(',
          ket = ')',
          footer = '',
        },
      }

      sandwich_recipes = list_concat({
        sandwich_recipes,
        {
          {
            buns = { 'textobj#generics#input_generics()', '">"' },
            expr = 1,
            cursor = 'inner_tail',
            kind = { 'add', 'replace' },
            action = { 'add' },
            input = { 'g' },
          },
          {
            external = {
              'i<',
              vim.api.nvim_eval([["\<Plug>(textobj-generics-i)"]]),
            },
            noremap = 0,
            kind = { 'delete', 'replace', 'query' },
            input = { 'g' },
          },
        },
      })

      vim.g['sandwich#recipes'] = sandwich_recipes

      vimx.fn.operator.sandwich.set('add', 'char', 'skip_space', 1)
      vim.cmd([[autocmd ModeChanged [vV\x16]*:* call operator#sandwich#set('add', 'char', 'skip_space', 1)]])
      vim.cmd([[autocmd ModeChanged *:[vV\x16]* call operator#sandwich#set('add', 'char', 'skip_space', 0)]])

      -- NOTE: integrate with noice
      --       The rendering breaks when toggled
      -- vim.api.nvim_create_autocmd({ 'User' }, {
      --   pattern = { 'OperatorSandwichAddPre', 'OperatorSandwichDeletePre', 'OperatorSandwichDeletePre' },
      --   callback = function()
      --     if enable_noice then
      --       require('noice').setup({
      --         cmdline = { enabled = false },
      --       })
      --     end
      --   end,
      -- })
      -- vim.api.nvim_create_autocmd({ 'User' }, {
      --   pattern = { 'OperatorSandwichAddPost', 'OperatorSandwichDeletePost', 'OperatorSandwichDeletePost' },
      --   callback = function()
      --     if enable_noice then
      --       require('noice').setup({
      --         cmdline = { enabled = true },
      --       })
      --     end
      --   end,
      -- })
    end,
  },
  {
    'machakann/vim-swap',
    keys = {
      { '<Plug>(swap-prev)', mode = { 'n' } },
      { '<Plug>(swap-next)', mode = { 'n' } },
      { '<Plug>(swap-interactive)', mode = { 'n' } },
      { '<Plug>(swap-textobject-i)', mode = { 'o', 'x' } },
      { '<Plug>(swap-textobject-a)', mode = { 'o', 'x' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'g<', '<Plug>(swap-prev)')
      vim.keymap.set({ 'n' }, 'g>', '<Plug>(swap-next)')
      vim.keymap.set({ 'n' }, 'gs', '<Plug>(swap-interactive)')

      vim.keymap.set({ 'o', 'x' }, 'i,', '<Plug>(swap-textobject-i)')
      vim.keymap.set({ 'o', 'x' }, 'a,', '<Plug>(swap-textobject-a)')
    end,
  },
  {
    'cohama/lexima.vim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    init = function()
      vim.g.lexima_no_default_rules = true
      vim.g.lexima_enable_basic_rules = false
      vim.g.lexima_enable_newline_rules = false
      vim.g.lexima_enable_space_rules = false
      vim.g.lexima_enable_endwise_rules = false
    end,
    config = function()
      local vimx = require('artemis')

      local rules = {}

      -- Markdown
      -- TODO: Use insx
      -- rules = list_concat({
      --   rules,
      --   {
      --     {
      --       filetype = 'markdown',
      --       char = '#',
      --       at = [=[^\%#\%(#\)\@!]=],
      --       input = '#<Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '#',
      --       at = [=[#\s\%#]=],
      --       input = '<BS>#<Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^#\s\%#]=],
      --       input = '<BS><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[##\s\%#]=],
      --       input = '<BS><BS><Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^#\s\%#]=],
      --       input = '<BS><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[##\s\%#]=],
      --       input = '<BS><BS><Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '-',
      --       at = [=[^\s*\%#]=],
      --       input = '-<Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Tab>',
      --       at = [=[^\s*-\s\%#]=],
      --       input = '<Home><Tab><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Tab>',
      --       at = [=[^\s*-\s\w.*\%#]=],
      --       input = '<Home><Tab><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^\s\+-\s\%#]=],
      --       input = '<Home><Del><Del><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^\s\+-\s\w.*\%#]=],
      --       input = '<Home><Del><Del><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^-\s\w.*\%#]=],
      --       input = '',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^-\s\%#]=],
      --       input = '<C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^\s\+-\s\%#]=],
      --       input = '<C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^-\s\%#]=],
      --       input = '<C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^\s\+-\s\%#]=],
      --       input = '<C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^-\s\%#]=],
      --       input = '<C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^\s\+-\s\%#]=],
      --       input = '<C-w><C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^\s*-\s\w.*\%#]=],
      --       input = '<CR>-<Space>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '[',
      --       at = [=[^\s*-\s\%#]=],
      --       input = '<Left><Space>[]<Left>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Tab>',
      --       at = [=[^\s*-\s\[\%#\]\s]=],
      --       input = '<Home><Tab><End><Left><Left>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^-\s\[\%#\]\s]=],
      --       input = '',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^\s\+-\s\[\%#\]\s]=],
      --       input = '<Home><Del><Del><End><Left><Left>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^\s*-\s\[\%#\]]=],
      --       input = '<BS><Del><Del>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^\s*-\s\[\%#\]]=],
      --       input = '<BS><Del><Del>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Space>',
      --       at = [=[^\s*-\s\[\%#\]]=],
      --       input = '<Space><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = 'x',
      --       at = [=[^\s*-\s\[\%#\]]=],
      --       input = 'x<End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^-\s\[\%#\]]=],
      --       input = '<End><C-w><C-w><C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^\s\+-\s\[\%#\]]=],
      --       input = '<End><C-w><C-w><C-w><C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Tab>',
      --       at = [=[^\s*-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<Home><Tab><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<Tab>',
      --       at = [=[^\s*-\s\[\(\s\|x\)\]\s\w.*\%#]=],
      --       input = '<Home><Tab><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<Home><Del><Del><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^\s\+-\s\[\(\s\|x\)\]\s\w.*\%#]=],
      --       input = '<Home><Del><Del><End>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<S-Tab>',
      --       at = [=[^-\s\[\(\s\|x\)\]\s\w.*\%#]=],
      --       input = '',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<C-h>',
      --       at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<BS>',
      --       at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><C-w><BS>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
      --       input = '<C-w><C-w><C-w><C-w><CR>',
      --     },
      --     {
      --       filetype = 'markdown',
      --       char = '<CR>',
      --       at = [=[^\s*-\s\[\(\s\|x\)\]\s\w.*\%#]=],
      --       input = '<CR>-<Space>[]<Space><Left><Left>',
      --     },
      --   },
      -- })

      for _, rule in ipairs(rules) do
        vimx.fn.lexima.add_rule(rule)
      end
    end,
  },
  {
    'yuki-yano/lexima-alter-command.vim',
    dependencies = {
      { 'cohama/lexima.vim' },
    },
    event = { 'CmdlineEnter' },
    config = function()
      vim.cmd([[
        LeximaAlterCommand ee                 e!
        LeximaAlterCommand cn                 cnewer
        LeximaAlterCommand cp                 colder
        LeximaAlterCommand dp                 diffput
        LeximaAlterCommand la\%[zy]           Lazy
        LeximaAlterCommand d\%[du]            Ddu
        LeximaAlterCommand rg                 Rg
        LeximaAlterCommand or\%[ganizeimport] OrganizeImport
        LeximaAlterCommand gina               Gina
        LeximaAlterCommand gin                Gin
        LeximaAlterCommand blame              Gina<Space>blame
        LeximaAlterCommand bro\%[wse]         Gina<Space>browse<Space>--exact<Space>:
        LeximaAlterCommand cap\%[ture]        Capture
        LeximaAlterCommand r\%[un]            QuickRun
        LeximaAlterCommand tr\%[ouble]        TroubleToggle
        LeximaAlterCommand ss                 SaveProjectLayout
        LeximaAlterCommand sl                 LoadProjectLayout
        LeximaAlterCommand ai                 AiReview
        LeximaAlterCommand yr                 YR
        LeximaAlterCommand te\%[lescope]      Telescope
        LeximaAlterCommand wipe\%[out]        Wipeout!
        LeximaAlterCommand f                  GhqProject
      ]])
    end,
  },
  {
    'hrsh7th/nvim-insx',
    enabled = true,
    dependencies = {
      { 'cohama/lexima.vim' }, -- NOTE: Load before insx
      { 'L3MON4D3/LuaSnip' },
    },
    event = { 'InsertEnter', 'CmdlineEnter' },
    config = function()
      local insx = require('insx')
      local esc = insx.helper.regex.esc
      local fast_wrap = require('insx.recipe.fast_wrap')
      local fast_break = require('insx.recipe.fast_break')

      -- Alias <C-h> to <BS>
      vim.keymap.set({ 'i', 'c' }, '<C-h>', '<BS>', { remap = true })

      -- Not use insert mode preset
      require('insx.preset.standard').setup_cmdline_mode()

      -- NOTE: Preset maps to `<` and `>`, so set the mappings manually
      -- quote
      for _, quote in ipairs({ '"', "'", '`' }) do
        -- auto pair
        insx.add(
          quote,
          insx.with(
            require('insx.recipe.auto_pair')({
              open = quote,
              close = quote,
              ignore_pat = [[\\\%#]],
            }),
            {
              insx.with.in_string(false),
            }
          )
        )

        -- delete pair
        insx.add(
          '<BS>',
          require('insx.recipe.delete_pair')({
            open_pat = esc(quote),
            close_pat = esc(quote),
            ignore_pat = ([[\\%s\%%#]]):format(esc(quote)),
          })
        )

        -- jump next
        insx.add(
          quote,
          require('insx.recipe.jump_next')({
            jump_pat = { [[\\\@<!\%#]] .. esc(quote) .. [[\zs]] },
          })
        )
      end

      -- bracket
      for open, close in pairs({ ['('] = ')', ['['] = ']', ['{'] = '}' }) do
        -- jump next
        insx.add(close, require('insx.recipe.jump_next')({ jump_pat = { [[\%#]] .. esc(close) .. [[\zs]] } }))
        -- auto pair
        insx.add(open, require('insx.recipe.auto_pair')({ open = open, close = close }))
        -- delete pair
        insx.add('<BS>', require('insx.recipe.delete_pair')({ open_pat = esc(open), close_pat = esc(close) }))
        -- fast wrap
        insx.add(
          '<C-]>',
          insx.with(
            fast_wrap({
              close = close,
            }),
            { insx.with.undopoint(false) }
          )
        )
        -- fast break
        insx.add(
          '<CR>',
          fast_break({
            open_pat = esc(open),
            close_pat = esc(close),
            arguments = true,
            html_attrs = true,
            html_tags = true,
          })
        )
      end

      -- spacing `()` and `{}` (exclude `[]`)
      for open, close in pairs({ ['('] = ')', ['{'] = '}' }) do
        insx.add(
          '<Space>',
          require('insx.recipe.pair_spacing').increase({ open_pat = esc(open), close_pat = esc(close) })
        )
        insx.add('<BS>', require('insx.recipe.pair_spacing').decrease({ open_pat = esc(open), close_pat = esc(close) }))
      end

      -- Use lexima when markdown
      -- insx.add('<CR>', {
      --   priority = -1,
      --   action = function(ctx)
      --     ctx.send(vim.fn.keytrans(vimx.fn.lexima.expand('<CR>', 'i')))
      --   end,
      --   enabled = function()
      --     return vim.o.filetype == 'markdown'
      --   end,
      -- })

      require('insx.recipe.snippet').expand = function(params)
        require('luasnip').lsp_expand(params.content)
      end

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zsc\%#$]],
            content = insx.dedent([[
              const ${1:v} = ${2:expr}
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zscf\%#$]],
            content = insx.dedent([[
            const ${1:fn} = (${2:args}) => {
              ${3:body}
            }
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zsf\%#$]],
            content = insx.dedent([[
            function ${1:fn}(${2:args}) {
              ${3:body}
            }
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zsif\%#$]],
            content = insx.dedent([[
            if (${1:cond}) {
              ${2:body}
            }
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zsforof\%#$]],
            content = insx.dedent([[
            for (const ${1:v} of ${2:list}) {
              ${3:body}
            }
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zspp\%#$]],
            content = insx.dedent([[
            console.log($1)
          ]]),
          }),
          {
            insx.with.filetype({ 'typescript', 'typescriptreact' }),
          }
        )
      )

      insx.add(
        '<Space>',
        insx.with(
          require('insx.recipe.snippet')({
            pattern = [[^\s*\zspp\%#$]],
            content = insx.dedent([[
            vim.print($1)
          ]]),
          }),
          {
            insx.with.filetype({ 'lua' }),
          }
        )
      )

      local substitute = require('insx.recipe.substitute')
      for level, next_level in pairs({
        log = {
          next = 'warn',
          prev = 'info',
        },
        warn = {
          next = 'error',
          prev = 'log',
        },
        error = {
          next = 'debug',
          prev = 'warn',
        },
        debug = {
          next = 'info',
          prev = 'error',
        },
        info = {
          next = 'log',
          prev = 'debug',
        },
      }) do
        insx.add(
          '<C-a>',
          substitute({
            pattern = [[console\.]] .. level .. [[(\%#]],
            replace = [[console.]] .. next_level.next .. [[(\%#]],
          })
        )
        insx.add(
          '<C-x>',
          substitute({
            pattern = [[console\.]] .. level .. [[(\%#]],
            replace = [[console.]] .. next_level.prev .. [[(\%#]],
          })
        )
      end

      -- markdown
      insx.add('`', {
        enabled = function(ctx)
          return ctx.match([[`\%#`]]) and ctx.filetype == 'markdown'
        end,
        action = function(ctx)
          ctx.send('``<Left>')
          ctx.send('``<Left>')
        end,
      })
      insx.add(
        '<CR>',
        require('insx.recipe.fast_break')({
          open_pat = [[```\w*]],
          close_pat = '```',
          indent = 0,
        })
      )
    end,
  },
  {
    'hrsh7th/nvim-linkedit',
    enabled = true,
    event = { 'ModeChanged' },
    config = function()
      require('linkedit').setup()
    end,
  },
  {
    'machakann/vim-textobj-functioncall',
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_functioncall_no_default_key_mappings = true

      vim.g.textobj_functioncall_patterns = {
        {
          header = [[\<\%(\h\k*\.\)*\h\k*]],
          bra = '(',
          ket = ')',
          footer = '',
        },
      }
      vim.keymap.set({ 'o', 'x' }, 'if', '<Plug>(textobj-functioncall-innerparen-i)')
      vim.keymap.set({ 'o', 'x' }, 'af', '<Plug>(textobj-functioncall-i)')

      vim.g.textobj_functioncall_ts_string_variable_patterns = {
        {
          header = [[\$]],
          bra = '{',
          ket = '}',
          footer = '',
        },
      }
      vim.keymap.set({ 'o', 'x' }, 'i$', '<Plug>(textobj-functioncall-ts-string-variable-i)')
      vim.keymap.set({ 'o', 'x' }, 'a$', '<Plug>(textobj-functioncall-ts-string-variable-a)')
    end,
    config = function()
      vim.keymap.set(
        { 'o' },
        '<Plug>(textobj-functioncall-ts-string-variable-i)',
        ':<C-u>call textobj#functioncall#i("o", g:textobj_functioncall_ts_string_variable_patterns)<CR>',
        { silent = true }
      )
      vim.keymap.set(
        { 'x' },
        '<Plug>(textobj-functioncall-ts-string-variable-i)',
        ':<C-u>call textobj#functioncall#i("x", g:textobj_functioncall_ts_string_variable_patterns)<CR>',
        { silent = true }
      )
      vim.keymap.set(
        { 'o' },
        '<Plug>(textobj-functioncall-ts-string-variable-a)',
        ':<C-u>call textobj#functioncall#a("o", g:textobj_functioncall_ts_string_variable_patterns)<CR>',
        { silent = true }
      )
      vim.keymap.set(
        { 'x' },
        '<Plug>(textobj-functioncall-ts-string-variable-a)',
        ':<C-u>call textobj#functioncall#a("x", g:textobj_functioncall_ts_string_variable_patterns)<CR>',
        { silent = true }
      )
    end,
  },
  {
    'yuki-yano/vim-textobj-generics',
    dependencies = {
      { 'machakann/vim-textobj-functioncall' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_generics_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'ig', '<Plug>(textobj-generics-innerparen-i)')
      vim.keymap.set({ 'o', 'x' }, 'ag', '<Plug>(textobj-generics-i)')
    end,
  },
  {
    'kana/vim-textobj-entire',
    dependencies = {
      { 'kana/vim-textobj-user' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_entire_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'ie', '<Plug>(textobj-entire-i)')
      vim.keymap.set({ 'o', 'x' }, 'ae', '<Plug>(textobj-entire-a)')
    end,
  },
  {
    'kana/vim-textobj-line',
    dependencies = {
      { 'kana/vim-textobj-user' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_line_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'il', '<Plug>(textobj-line-i)')
      vim.keymap.set({ 'o', 'x' }, 'al', '<Plug>(textobj-line-a)')
    end,
  },
  {
    'kana/vim-textobj-indent',
    dependencies = {
      { 'kana/vim-textobj-user' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_indent_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'ii', '<Plug>(textobj-indent-i)')
      vim.keymap.set({ 'o', 'x' }, 'ai', '<Plug>(textobj-indent-a)')
    end,
  },
  {
    'thinca/vim-textobj-between',
    dependencies = {
      { 'kana/vim-textobj-user' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_between_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'i/', '<Plug>(textobj-between-i)/')
      vim.keymap.set({ 'o', 'x' }, 'a/', '<Plug>(textobj-between-a)/')
      vim.keymap.set({ 'o', 'x' }, 'i_', '<Plug>(textobj-between-i)_')
      vim.keymap.set({ 'o', 'x' }, 'a_', '<Plug>(textobj-between-a)_')
      vim.keymap.set({ 'o', 'x' }, 'i-', '<Plug>(textobj-between-i)-')
      vim.keymap.set({ 'o', 'x' }, 'a-', '<Plug>(textobj-between-a)-')
    end,
  },
  {
    'yuki-yano/vim-textobj-cursor-context',
    dependencies = {
      { 'kana/vim-textobj-user' },
    },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_cursorcontext_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'ic', '<Plug>(textobj-cursorcontext-i)')
      vim.keymap.set({ 'o', 'x' }, 'ac', '<Plug>(textobj-cursorcontext-a)')
    end,
  },
  {
    'terryma/vim-expand-region',
    keys = {
      { '<Plug>(expand_region_expand)', mode = { 'x' } },
      { '<Plug>(expand_region_shrink)', mode = { 'x' } },
    },
    init = function()
      vim.keymap.set({ 'x' }, 'v', '<Plug>(expand_region_expand)')
      vim.keymap.set({ 'x' }, 'V', '<Plug>(expand_region_shrink)')

      vim.g.expand_region_text_objects = {
        ['iw'] = 0,
        ['i"'] = 1,
        ['a"'] = 1,
        ["i'"] = 1,
        ["a'"] = 1,
        ['i`'] = 1,
        ['a`'] = 1,
        ['iu'] = 1,
        ['au'] = 1,
        ['i('] = 1,
        ['a('] = 1,
        ['i['] = 1,
        ['a['] = 1,
        ['i{'] = 1,
        ['if'] = 1,
        ['af'] = 1,
        ['ig'] = 1,
        ['ag'] = 1,
        ['i$'] = 1,
        ['a$'] = 1,
        ['a{'] = 1,
        ['i<'] = 1,
        ['a<'] = 1,
        ['il'] = 0,
        ['ii'] = 1,
        ['ai'] = 1,
        ['ic'] = 0,
        ['ac'] = 0,
        ['ie'] = 0,
      }
    end,
  },
  {
    -- NOTE: Use my fork
    'yuki-yano/vim-operator-replace',
    enabled = false,
    dependencies = {
      { 'kana/vim-operator-user' },
    },
    keys = {
      { '<Plug>(operator-replace)', mode = { 'n', 'x' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'RR', 'R')
      vim.keymap.set({ 'n', 'x' }, 'R', '<Plug>(operator-replace)')
    end,
  },
  {
    'mopp/vim-operator-convert-case',
    dependencies = {
      { 'kana/vim-operator-user' },
    },
    keys = {
      { '<Plug>(operator-convert-case-loop)', mode = { 'n' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'cy', '<Plug>(operator-convert-case-loop)iw')
    end,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })
    end,
  },
  {
    -- NOTE: Use my fork
    'yuki-yano/caw.vim',
    dependencies = {
      { 'kana/vim-operator-user' },
      { 'kana/vim-textobj-line' },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
    },
    keys = {
      { 'gc', mode = { 'n', 'x' } },
      { 'gcc', mode = { 'n' } },
      { 'gw', mode = { 'n', 'x' } },
    },
    init = function()
      vim.g.caw_no_mappings = 1
    end,
    config = function()
      -- NOTE: Workaround for comment out in jsx
      local function caw_hatpos_toggle()
        require('ts_context_commentstring.internal').update_commentstring()
        if
          (vim.o.filetype == 'typescript' or vim.o.filetype == 'typescriptreact')
          and vim.o.commentstring == [[{/* %s */}]]
        then
          vim.b.caw_wrap_oneline_comment = { '{/*', '*/}' }
          return '<Plug>(caw:wrap:toggle:operator)'
        end

        return '<Plug>(caw:hatpos:toggle:operator)'
      end

      local function caw_wrap_toggle()
        require('ts_context_commentstring.internal').update_commentstring()

        if
          (vim.o.filetype == 'typescript' or vim.o.filetype == 'typescriptreact')
          and vim.o.commentstring == [[{/* %s */}]]
        then
          vim.b.caw_wrap_oneline_comment = { '{/*', '*/}' }
        elseif vim.o.filetype == 'typescript' or vim.o.filetype == 'typescriptreact' then
          vim.b.caw_wrap_oneline_comment = { '/*', '*/' }
        end

        return '<Plug>(caw:wrap:toggle:operator)'
      end

      vim.keymap.set({ 'n' }, 'gcc', function()
        return caw_hatpos_toggle() .. '<Plug>(textobj-line-i)'
      end, { expr = true })
      vim.keymap.set({ 'n', 'x' }, 'gc', caw_hatpos_toggle, { expr = true })

      vim.keymap.set({ 'n' }, 'gww', function()
        return caw_wrap_toggle() .. '<Plug>(textobj-line-i)'
      end, { expr = true })
      vim.keymap.set({ 'n', 'x' }, 'gw', caw_wrap_toggle, { expr = true })
    end,
  },
  {
    'hrsh7th/nvim-pasta',
    enabled = false,
    event = { 'VeryLazy' },
    config = function()
      vim.keymap.set({ 'n', 'x' }, 'p', require('pasta.mapping').p)
      vim.keymap.set({ 'n', 'x' }, 'P', require('pasta.mapping').P)

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'PastaEntry', { fg = color.base().orange, bg = color.base().black })
        end,
      })
    end,
  },
  {
    'gbprod/yanky.nvim',
    enabled = false,
    event = { 'VeryLazy' },
    dependencies = {
      { 'kkharji/sqlite.lua' },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({ 'n' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set({ 'n' }, '<C-p>', function()
        return require('yanky').can_cycle() and '<Plug>(YankyCycleForward)' or '<Plug>(ctrl-p)'
      end, { expr = true })
      vim.keymap.set({ 'n' }, '<C-n>', function()
        return require('yanky').can_cycle() and '<Plug>(YankyCycleBackward)' or '<Plug>(ctrl-n)'
      end, { expr = true })

      require('yanky').setup({
        ring = {
          storage = 'sqlite',
          history_length = 1000,
        },
        system_clipboard = {
          sync_with_ring = false,
        },
        highlight = {
          on_put = true,
        },
      })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'YankyPut', { fg = color.base().orange, bg = color.base().black })
        end,
      })
    end,
  },
  {
    'LeafCage/yankround.vim',
    enabled = false,
    event = { 'VeryLazy' },
    init = function()
      vim.g.yankround_max_history = 1000
      vim.g.yankround_use_region_hl = true
      vim.g.yankround_dir = vim.fn.stdpath('cache') .. '/yankround'

      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(yankround-p)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(yankround-P)')

      vim.keymap.set({ 'n' }, '<C-p>', function()
        return vim.fn['yankround#is_active']() == 1 and '<Plug>(yankround-prev)' or '<Plug>(ctrl-p)'
      end, { expr = true })
      vim.keymap.set({ 'n' }, '<C-n>', function()
        return vim.fn['yankround#is_active']() == 1 and '<Plug>(yankround-next)' or '<Plug>(ctrl-n)'
      end, { expr = true })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'YankRoundRegion', { fg = color.base().orange, bg = 'NONE' })
        end,
      })
    end,
  },
  {
    'yuki-yano/haritsuke.vim',
    enabled = true,
    dev = true,
    lazy = false,
    dependencies = {
      'vim-denops/denops.vim',
    },
    init = function()
      vim.g.haritsuke_config = {
        persist_path = vim.fn.stdpath('cache') .. '/haritsuke',
        max_entries = 10000,
        operator_replace_single_undo = true,
        debug = false,
      }

      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(haritsuke-p)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(haritsuke-P)')
      vim.keymap.set({ 'n' }, '<Tab>', '<Plug>(haritsuke-toggle-smart-indent)')
      -- vim.keymap.set({ 'n' }, 'gp', '<Plug>(haritsuke-gp)')
      -- vim.keymap.set({ 'n' }, 'gP', '<Plug>(haritsuke-gP)')
      vim.keymap.set({ 'n' }, '<C-p>', function()
        return vim.fn['haritsuke#is_active']() and '<Plug>(haritsuke-prev)' or '<Plug>(ctrl-p)'
      end, { expr = true })
      vim.keymap.set({ 'n' }, '<C-n>', function()
        return vim.fn['haritsuke#is_active']() and '<Plug>(haritsuke-next)' or '<Plug>(ctrl-n)'
      end, { expr = true })

      vim.keymap.set({ 'n', 'x' }, 'R', '<Plug>(haritsuke-replace)')
    end,
    config = function()
      require('denops-lazy').load('haritsuke.vim')
    end,
  },
  {
    'monaqa/dial.nvim',
    keys = {
      { '<Plug>(dial-increment)', mode = { 'n', 'x' } },
      { '<Plug>(dial-decrement)', mode = { 'n', 'x' } },
    },
    init = function()
      vim.keymap.set({ 'n', 'x' }, '<C-a>', '<Plug>(dial-increment)')
      vim.keymap.set({ 'n', 'x' }, '<C-x>', '<Plug>(dial-decrement)')
      vim.keymap.set({ 'x' }, 'g<C-a>', 'g<Plug>(dial-increment)')
      vim.keymap.set({ 'x' }, 'g<C-x>', 'g<Plug>(dial-decrement)')
    end,
    config = function()
      local config = require('dial.config')
      local augend = require('dial.augend')

      config.augends:register_group({
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.constant.alias.bool,
          augend.constant.new({
            elements = { '&&', '||' },
            word = false,
            cyclic = true,
          }),
          augend.constant.new({
            elements = { 'log', 'warn', 'error', 'debug', 'info' },
            word = true,
            cyclic = true,
          }),
          augend.constant.new({
            elements = { 'on', 'off' },
            word = true,
            cyclic = true,
          }),
          augend.semver.alias.semver,
        },
      })
    end,
  },
  {
    'yuki-yano/smart-i.nvim',
    keys = {
      { 'i', mode = { 'n' } },
      { 'I', mode = { 'n' } },
      { 'a', mode = { 'n' } },
      { 'A', mode = { 'n' } },
    },
    config = function()
      require('smart-i').setup()
    end,
  },

  { 'thinca/vim-qfreplace', cmd = { 'Qfreplace' } },
  {
    'yuki-yano/dedent-yank.vim',
    dev = true,
    keys = {
      { '<Plug>(dedent-yank-normal)', mode = { 'n' } },
      { '<Plug>(dedent-yank-visual)', mode = { 'x' } },
    },
    init = function()
      vim.g.dedent_yank_disable_default_mappings = true
      vim.keymap.set({ 'n' }, 'gy', '<Plug>(dedent-yank-normal)')
      vim.keymap.set({ 'x' }, 'gy', '<Plug>(dedent-yank-visual)')
    end,
  },
  {
    'tommcdo/vim-exchange',
    keys = {
      { '<Plug>(Exchange)', mode = { 'x' } },
    },
    init = function()
      vim.keymap.set({ 'x' }, 'X', '<Plug>(Exchange)')
    end,
  },
  {
    'osyo-manga/vim-jplus',
    keys = {
      { '<Plug>(jplus)', mode = { 'n', 'x' } },
      { '<Plug>(jplus-input)', mode = { 'n', 'x' } },
    },
    init = function()
      vim.keymap.set({ 'n', 'x' }, 'J', '<Plug>(jplus)')
      vim.keymap.set({ 'n', 'x' }, '<Leader>J', '<Plug>(jplus-input)')
    end,
  },
  {
    'booperlv/nvim-gomove',
    keys = {
      { '<Plug>GoVSMLeft', mode = { 'x' } },
      { '<Plug>GoVSMUp', mode = { 'x' } },
      { '<Plug>GoVSMDown', mode = { 'x' } },
      { '<Plug>GoVSMRight', mode = { 'x' } },
    },
    init = function()
      vim.keymap.set({ 'x' }, '<C-h>', '<Plug>GoVSMLeft')
      vim.keymap.set({ 'x' }, '<C-k>', '<Plug>GoVSMUp')
      vim.keymap.set({ 'x' }, '<C-j>', '<Plug>GoVSMDown')
      vim.keymap.set({ 'x' }, '<C-l>', '<Plug>GoVSMRight')
    end,
    config = function()
      require('gomove').setup({ map_defaults = true, reindent_mode = 'none' })
    end,
  },
  {
    'danymat/neogen',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    cmd = { 'Neogen' },
    config = function()
      require('neogen').setup()
    end,
  },
  {
    'yuki-yano/delete-mark.nvim',
    dev = false,
    keys = {
      { '<C-e>', mode = { 'n', 'x', 'i' } },
    },
    config = function()
      require('delete-mark').setup({
        highlight = {
          mark = { fg = color.base().black, bg = color.base().red, bold = true },
          sign = { fg = color.base().red },
        },
        sign = todo_icons.delete,
      })
    end,
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<Leader>m', mode = { 'n' } },
    },
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })
      vim.keymap.set({ 'n' }, '<Leader>m', function()
        return require('treesj').toggle()
      end)
    end,
  },
}
