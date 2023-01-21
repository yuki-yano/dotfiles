local icons = require('font').icons
local list_concat = require('utils').list_concat

return {
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'ray-x/cmp-treesitter' },
      { 'hrsh7th/cmp-buffer' },
      { 'andersevenrud/cmp-tmux' },
      { 'lukas-reineke/cmp-rg' },
      { 'octaltree/cmp-look' },
      { 'hrsh7th/cmp-path' },
      { 'onsails/lspkind-nvim' },
      { 'L3MON4D3/LuaSnip' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'kento-ogata/cmp-tsnip', dependencies = { 'yuki-yano/tsnip.nvim' } },
      { 'tzachar/cmp-tabnine', build = './install.sh' },
      { 'zbirenbaum/copilot-cmp' },
      { 'hrsh7th/cmp-cmdline' },
      {
        'tzachar/cmp-fuzzy-path',
        dependencies = { 'tzachar/fuzzy.nvim', dependencies = { { 'romgrk/fzy-lua-native' } } },
      },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
      { 'kyazdani42/nvim-web-devicons' },
      { 'cohama/lexima.vim' }, -- Before loading cmp
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

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = 'TelescopePrompt',
        callback = function()
          require('cmp').setup.buffer({
            completion = { autocomplete = false },
          })
        end,
      })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindNumber', { fg = '#D3869B' })
          vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = '#A9B665' })
          vim.api.nvim_set_hl(0, 'CmpItemKindKey', { fg = '#7DAEA3' })
          vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = '#EA6962' })
          vim.api.nvim_set_hl(0, 'CmpItemKindReference', { fg = '#89B482' })
          vim.api.nvim_set_hl(0, 'CmpItemKindFolder', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = '#D3869B' })
          vim.api.nvim_set_hl(0, 'CmpItemKindNull', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindValue', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = '#D4BE98' })
          vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = '#A9B665' })
          vim.api.nvim_set_hl(0, 'CmpItemKindModule', { fg = '#EA6962' })
          vim.api.nvim_set_hl(0, 'CmpItemKindPackage', { fg = '#EA6962' })
          vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = '#A9B665' })
          vim.api.nvim_set_hl(0, 'CmpItemKindOperator', { fg = '#E78A4E' })
          vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { fg = '#EA6962' })
          vim.api.nvim_set_hl(0, 'CmpItemKindObject', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = '#A9B665' })
          vim.api.nvim_set_hl(0, 'CmpItemKindArray', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindEnum', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindField', { fg = '#7DAEA3' })
          vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = '#7DAEA3' })
          vim.api.nvim_set_hl(0, 'CmpItemKindColor', { fg = '#D3869B' })
          vim.api.nvim_set_hl(0, 'CmpItemKindFile', { fg = '#EA6962' })
          vim.api.nvim_set_hl(0, 'CmpItemKindEvent', { fg = '#D4BE98' })
          vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', { fg = '#D4BE98' })
          vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = '#A9B665' })
          vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindBoolean', { fg = '#D3869B' })
          vim.api.nvim_set_hl(0, 'CmpItemKindNamespace', { fg = '#D8A657' })
          vim.api.nvim_set_hl(0, 'CmpItemKindString', { fg = '#89B482' })
          vim.api.nvim_set_hl(0, 'CmpItemKindEnumMember', { fg = '#7DAEA3' })
        end,
      })
    end,
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')

      -- force_keyword_length is used from manual complete
      local sources = {
        { name = 'luasnip', keyword_length = 2, force_keyword_length = true },
        { name = 'tsnip', keyword_length = 2, force_keyword_length = true },
        { name = 'copilot' },
        { name = 'nvim_lsp', max_item_count = 30 },
        { name = 'treesitter' },
        { name = 'nvim_lua', max_item_count = 20 },
        { name = 'cmp_tabnine' },
        { name = 'buffer' },
        { name = 'tmux', keyword_length = 4, max_item_count = 10, option = { all_panes = true } },
        { name = 'rg', keyword_length = 4, max_item_count = 10 },
        { name = 'look', keyword_length = 4, max_item_count = 10, option = { convert_case = true, loud = true } },
        { name = 'path' },
      }

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
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<C-f>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(1) then
                  luasnip.jump(1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<C-b>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            })
          or {},
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources(sources),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = lspkind.cmp_format({
            mode = 'symbol',
            menu = {
              luasnip = '[Snippet]',
              tsnip = '[TSnip]',
              copilot = '[Copilot]',
              nvim_lsp = '[LSP]',
              treesitter = '[Tree]',
              nvim_lua = '[Lua]',
              cmp_tabnine = '[Tabnine]',
              buffer = '[Buffer]',
              tmux = '[Tmux]',
              rg = '[Rg]',
              look = '[Look]',
              path = '[Path]',
            },
          }),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
      })

      lspkind.init({
        preset = 'codicons',
        symbol_map = icons,
      })

      require('cmp.utils.misc').redraw.incsearch_redraw_keys = '<C-r><BS>'

      local incsearch_settings = {
        mapping = cmp.mapping.preset.cmdline({
          ['<C-n>'] = vim.NIL,
          ['<C-p>'] = vim.NIL,
          ['<C-e>'] = vim.NIL,
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp_document_symbol' },
        }, {
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
        mapping = cmp.mapping.preset.cmdline({
          ['<C-n>'] = vim.NIL,
          ['<C-p>'] = vim.NIL,
          ['<C-e>'] = vim.NIL,
        }),
        sources = cmp.config.sources({
          { name = 'cmdline' },
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
          format = function(entry, vim_item)
            if 'fuzzy_path' == entry.source.name then
              local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
              if icon then
                vim_item.kind = icon
                vim_item.kind_hl_group = hl_group
              else
                vim_item.kind = '󾩻 '
              end
            elseif 'cmdline' == entry.source.name then
              vim_item.kind = '󾪌 '
              vim_item.dup = true
            end

            return lspkind.cmp_format()(entry, vim_item)
          end,
        },
      })
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<Tab>',
          },
        },
        filetypes = {
          typescript = true,
          typescriptreact = true,
          lua = true,
          vim = true,
        },
      })
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
    },
    config = function()
      require('copilot_cmp').setup()
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
    dependencies = {
      'vim-denops/denops.vim',
      'MunifTanjim/nui.nvim',
    },
    event = { 'InsertEnter' },
    cmd = { 'TSnip' },
    config = function()
      require('denops-lazy').load('tsnip.nvim', { wait_load = false })
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
    dependencies = { { 'windwp/nvim-ts-autotag' } },
    event = { 'InsertEnter', 'CmdlineEnter' },
    config = function()
      local vimx = require('artemis')

      local rules = {}

      -- Parenthesis
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [[(\%#)]], input = '<BS><Del>' },
          { char = '<BS>', at = [[(\%#)]], input = '<BS><Del>' },
        },
      })

      -- Brace
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [[{\%#}]], input = '<BS><Del>' },
          { char = '<BS>', at = [[{\%#}]], input = '<BS><Del>' },
        },
      })

      -- Bracket
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [=[\[\%#\]]=], input = '<BS><Del>' },
          { char = '<BS>', at = [=[\[\%#\]]=], input = '<BS><Del>' },
        },
      })

      -- Single quote
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [['\%#']], input = '<BS><Del>' },
          { char = '<BS>', at = [['\%#']], input = '<BS><Del>' },
        },
      })

      -- Double quote
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [["\%#"]], input = '<BS><Del>' },
          { char = '<BS>', at = [["\%#"]], input = '<BS><Del>' },
        },
      })

      -- Back quote
      rules = list_concat({
        rules,
        {
          { char = '<C-h>', at = [[`\%#`]], input = '<BS><Del>' },
          { char = '<BS>', at = [[`\%#`]], input = '<BS><Del>' },
        },
      })

      -- Surround function
      -- Use nvim-insx
      -- rules = list_concat({
      --   rules,
      --   {
      --     { char = ';', at = [[);\%#]], input = '<BS><BS><C-o>:normal! $<CR>a)<Esc>' },
      --     { char = ';', at = [[);\%#.*(.*]], input = '<BS><BS><C-o>:normal! f(<CR>:normal %<CR>a)<Esc>' },
      --   },
      -- })

      -- TypeScript
      rules = list_concat({
        rules,
        {
          { char = ';', at = [[\.[a-zA-Z]\+([a-zA-Z,]*;\%#)]], input = '<BS> => {', input_after = '}' },
          {
            char = ';',
            at = [[\.[a-zA-Z]\+(([a-zA-Z, :<>]*;\%#))]],
            input = '<BS><C-g>U<Right> => {',
            input_after = '}',
          },
          { char = ';', at = [[([a-zA-Z, :<>]*;\%#)]], input = '<BS><C-g>U<Right> => {', input_after = '}' },
          {
            char = ';',
            at = [[({[a-zA-Z, :<>]\+;\%#\s\?})]],
            input = '<BS><C-o>:normal! f)<CR>a<C-g>U<Right> => {}<Esc>',
          },
        },
      })

      -- TSX with nvim-ts-autotag
      rules = list_concat({
        rules,
        {
          {
            char = '>',
            at = [[<[a-zA-Z.]\+\(\s\)\?.*\%#]],
            input = [[><Esc>:lua require('nvim-ts-autotag.internal').close_tag()<CR>a]],
          },
        },
      })

      -- Markdown
      rules = list_concat({
        rules,
        {
          { filetype = 'markdown', char = '#', at = [=[^\%#\%(#\)\@!]=], input = '#<Space>' },
          { filetype = 'markdown', char = '#', at = [=[#\s\%#]=], input = '<BS>#<Space>' },
          { filetype = 'markdown', char = '<C-h>', at = [=[^#\s\%#]=], input = '<BS><BS>' },
          { filetype = 'markdown', char = '<C-h>', at = [=[##\s\%#]=], input = '<BS><BS><Space>' },
          { filetype = 'markdown', char = '<BS>', at = [=[^#\s\%#]=], input = '<BS><BS>' },
          { filetype = 'markdown', char = '<BS>', at = [=[##\s\%#]=], input = '<BS><BS><Space>' },
          { filetype = 'markdown', char = '-', at = [=[^\s*\%#]=], input = '-<Space>' },
          { filetype = 'markdown', char = '<Tab>', at = [=[^\s*-\s\%#]=], input = '<Home><Tab><End>' },
          { filetype = 'markdown', char = '<Tab>', at = [=[^\s*-\s\w.*\%#]=], input = '<Home><Tab><End>' },
          { filetype = 'markdown', char = '<S-Tab>', at = [=[^\s\+-\s\%#]=], input = '<Home><Del><Del><End>' },
          { filetype = 'markdown', char = '<S-Tab>', at = [=[^\s\+-\s\w.*\%#]=], input = '<Home><Del><Del><End>' },
          { filetype = 'markdown', char = '<S-Tab>', at = [=[^-\s\w.*\%#]=], input = '' },
          { filetype = 'markdown', char = '<C-h>', at = [=[^-\s\%#]=], input = '<C-w><BS>' },
          { filetype = 'markdown', char = '<C-h>', at = [=[^\s\+-\s\%#]=], input = '<C-w><C-w><BS>' },
          { filetype = 'markdown', char = '<BS>', at = [=[^-\s\%#]=], input = '<C-w><BS>' },
          { filetype = 'markdown', char = '<BS>', at = [=[^\s\+-\s\%#]=], input = '<C-w><C-w><BS>' },
          { filetype = 'markdown', char = '<CR>', at = [=[^-\s\%#]=], input = '<C-w><CR>' },
          { filetype = 'markdown', char = '<CR>', at = [=[^\s\+-\s\%#]=], input = '<C-w><C-w><CR>' },
          { filetype = 'markdown', char = '<CR>', at = [=[^\s*-\s\w.*\%#]=], input = '<CR>-<Space>' },
          { filetype = 'markdown', char = '[', at = [=[^\s*-\s\%#]=], input = '<Left><Space>[]<Left>' },
          {
            filetype = 'markdown',
            char = '<Tab>',
            at = [=[^\s*-\s\[\%#\]\s]=],
            input = '<Home><Tab><End><Left><Left>',
          },
          { filetype = 'markdown', char = '<S-Tab>', at = [=[^-\s\[\%#\]\s]=], input = '' },
          {
            filetype = 'markdown',
            char = '<S-Tab>',
            at = [=[^\s\+-\s\[\%#\]\s]=],
            input = '<Home><Del><Del><End><Left><Left>',
          },
          { filetype = 'markdown', char = '<C-h>', at = [=[^\s*-\s\[\%#\]]=], input = '<BS><Del><Del>' },
          { filetype = 'markdown', char = '<BS>', at = [=[^\s*-\s\[\%#\]]=], input = '<BS><Del><Del>' },
          { filetype = 'markdown', char = '<Space>', at = [=[^\s*-\s\[\%#\]]=], input = '<Space><End>' },
          { filetype = 'markdown', char = 'x', at = [=[^\s*-\s\[\%#\]]=], input = 'x<End>' },
          { filetype = 'markdown', char = '<CR>', at = [=[^-\s\[\%#\]]=], input = '<End><C-w><C-w><C-w><CR>' },
          { filetype = 'markdown', char = '<CR>', at = [=[^\s\+-\s\[\%#\]]=], input = '<End><C-w><C-w><C-w><C-w><CR>' },
          { filetype = 'markdown', char = '<Tab>', at = [=[^\s*-\s\[\(\s\|x\)\]\s\%#]=], input = '<Home><Tab><End>' },
          {
            filetype = 'markdown',
            char = '<Tab>',
            at = [=[^\s*-\s\[\(\s\|x\)\]\s\w.*\%#]=],
            input = '<Home><Tab><End>',
          },
          {
            filetype = 'markdown',
            char = '<S-Tab>',
            at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
            input = '<Home><Del><Del><End>',
          },
          {
            filetype = 'markdown',
            char = '<S-Tab>',
            at = [=[^\s\+-\s\[\(\s\|x\)\]\s\w.*\%#]=],
            input = '<Home><Del><Del><End>',
          },
          { filetype = 'markdown', char = '<S-Tab>', at = [=[^-\s\[\(\s\|x\)\]\s\w.*\%#]=], input = '' },
          { filetype = 'markdown', char = '<C-h>', at = [=[^-\s\[\(\s\|x\)\]\s\%#]=], input = '<C-w><C-w><C-w><BS>' },
          {
            filetype = 'markdown',
            char = '<C-h>',
            at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
            input = '<C-w><C-w><C-w><C-w><BS>',
          },
          { filetype = 'markdown', char = '<BS>', at = [=[^-\s\[\(\s\|x\)\]\s\%#]=], input = '<C-w><C-w><C-w><BS>' },
          {
            filetype = 'markdown',
            char = '<BS>',
            at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
            input = '<C-w><C-w><C-w><C-w><BS>',
          },
          { filetype = 'markdown', char = '<CR>', at = [=[^-\s\[\(\s\|x\)\]\s\%#]=], input = '<C-w><C-w><C-w><CR>' },
          {
            filetype = 'markdown',
            char = '<CR>',
            at = [=[^\s\+-\s\[\(\s\|x\)\]\s\%#]=],
            input = '<C-w><C-w><C-w><C-w><CR>',
          },
          {
            filetype = 'markdown',
            char = '<CR>',
            at = [=[^\s*-\s\[\(\s\|x\)\]\s\w.*\%#]=],
            input = '<CR>-<Space>[]<Space><Left><Left>',
          },
        },
      })

      for _, rule in ipairs(rules) do
        vimx.fn.lexima.add_rule(rule)
      end

      local function lexima_alter_command(original, alternative)
        local input_space = '<C-w>' .. alternative .. '<Space>'
        local input_cr = '<C-w>' .. alternative .. '<CR>'

        local rule = {
          mode = ':',
          at = [[^\('<,'>\)\?]] .. original .. [[\%#$]],
        }

        vimx.fn.lexima.add_rule(vim.tbl_extend('force', rule, { char = '<Space>', input = input_space }))
        vimx.fn.lexima.add_rule(vim.tbl_extend('force', rule, { char = '<CR>', input = input_cr }))
      end

      vim.api.nvim_create_user_command('LeximaAlterCommand', function(opts)
        lexima_alter_command(opts.fargs[1], opts.fargs[2])
      end, { nargs = '+' })

      vim.cmd([[
        LeximaAlterCommand ee                 e!
        LeximaAlterCommand re                 update<Space><Bar><Space>e!
        LeximaAlterCommand dp                 diffput
        LeximaAlterCommand la\%[zy]           Lazy
        LeximaAlterCommand rg                 Rg
        LeximaAlterCommand or\%[ganizeimport] OrganizeImport
        LeximaAlterCommand git                Gina
        LeximaAlterCommand blame              Gina<Space>blame
        LeximaAlterCommand bro\%[wse]         Gina<Space>browse<Space>--exact<Space>:
        LeximaAlterCommand cap\%[ture]        Capture
        LeximaAlterCommand r\%[un]            QuickRun
        LeximaAlterCommand tr\%[ouble]        TroubleToggle
        LeximaAlterCommand ss                 SaveProjectLayout
        LeximaAlterCommand sl                 LoadProjectLayout
        LeximaAlterCommand re\%[view]         AiReview
        LeximaAlterCommand yr                 YR
        LeximaAlterCommand te\%[lescope]      Telescope
      ]])
    end,
  },
  {
    'hrsh7th/nvim-insx',
    dependencies = { { 'cohama/lexima.vim' } },
    event = { 'InsertEnter' },
    config = function()
      local insx = require('insx')
      local fast_wrap = require('insx.recipe.fast_wrap')
      insx.add(')', fast_wrap({ close = ')' }))
      insx.add('}', fast_wrap({ close = '}' }))
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
    dependencies = { 'kana/vim-textobj-user' },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_entire_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'ie', '<Plug>(textobj-entire-i)')
      vim.keymap.set({ 'o', 'x' }, 'ae', '<Plug>(textobj-entire-a)')
    end,
  },
  {
    'kana/vim-textobj-line',
    dependencies = { 'kana/vim-textobj-user' },
    event = { 'ModeChanged' },
    init = function()
      vim.g.textobj_line_no_default_key_mappings = true

      vim.keymap.set({ 'o', 'x' }, 'il', '<Plug>(textobj-line-i)')
      vim.keymap.set({ 'o', 'x' }, 'al', '<Plug>(textobj-line-a)')
    end,
  },
  {
    'thinca/vim-textobj-between',
    dependencies = { 'kana/vim-textobj-user' },
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
    dependencies = { 'kana/vim-textobj-user' },
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
    'yuki-yano/vim-operator-replace',
    dependencies = { 'kana/vim-operator-user' },
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
    dependencies = { 'kana/vim-operator-user' },
    keys = {
      { '<Plug>(operator-convert-case-loop)', mode = { 'n' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'cy', '<Plug>(operator-convert-case-loop)iw')
    end,
  },
  {
    'yuki-yano/caw.vim',
    dependencies = {
      { 'kana/vim-operator-user' },
      { 'kana/vim-textobj-line' },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
    },
    keys = {
      { 'gc', mode = { 'n', 'x' } },
      { 'gw', mode = { 'n', 'x' } },
    },
    init = function()
      vim.g.caw_no_mappings = 1
    end,
    config = function()
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
    'LeafCage/yankround.vim',
    event = { 'VeryLazy' },
    init = function()
      vim.g.yankround_max_history = 1000
      vim.g.yankround_use_region_hl = true
      vim.g.yankround_dir = vim.fn.expand('~/.cache/vim/yankround')

      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(yankround-p)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(yankround-P)')

      vim.keymap.set({ 'n' }, '<C-p>', function()
        return vim.fn['yankround#is_active']() == 1 and '<Plug>(yankround-prev)' or '<Plug>(ctrl-p)'
      end, { expr = true })
      vim.keymap.set({ 'n' }, '<C-n>', function()
        return vim.fn['yankround#is_active']() == 1 and '<Plug>(yankround-next)' or '<Plug>(ctrl-n)'
      end, { expr = true })

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'YankRoundRegion', { fg = '#FF875F', bg = '#3A3A3A' })
        end,
      })
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
          augend.semver.alias.semver,
        },
      })
    end,
  },
  { 'thinca/vim-qfreplace', cmd = { 'Qfreplace' } },
  {
    'yuki-yano/deindent-yank.vim',
    keys = {
      { '<Plug>(deindent-yank-normal)', mode = { 'n' } },
      { '<Plug>(deindent-yank-visual)', mode = { 'x' } },
    },
    init = function()
      vim.keymap.set({ 'n' }, 'gy', '<Plug>(deindent-yank-normal)')
      vim.keymap.set({ 'x' }, 'gy', '<Plug>(deindent-yank-visual)')
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
}
