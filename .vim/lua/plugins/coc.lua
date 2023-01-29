local escesc = require('func').escesc

local plugins = {
  {
    'neoclide/coc.nvim',
    build = 'yarn install --frozen-lockfile',
    event = { 'BufReadPre' },
    dependencies = {
      { 'junegunn/fzf' },
      { 'cohama/lexima.vim' },
      { 'github/copilot.vim' },
      { 'SirVer/ultisnips' },
      { 'yuki-yano/tsnip.nvim' },
      -- NOTE: Vim plugin is not loaded if coc-fzf-preview is loaded first
      { 'yuki-yano/fzf-preview.vim' },
      -- NOTE: Dependencies insx and lexima mappings
      { 'hrsh7th/nvim-insx' },
      { 'cohama/lexima.vim' },
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'CocMenuSel', { link = 'Visual' })
        end,
      })
    end,
    config = function()
      local vimx = require('artemis')

      vim.g.coc_global_extensions = {
        'coc-copilot',
        'coc-deno',
        'coc-eslint',
        'coc-fzf-preview',
        'coc-json',
        'coc-lists',
        'coc-nav',
        'coc-npm-version',
        'coc-prettier',
        'coc-prisma',
        'coc-rg',
        'coc-rust-analyzer',
        'coc-spell-checker',
        'coc-stylua',
        'coc-sumneko-lua',
        'coc-tabnine',
        'coc-tsdetect',
        'coc-tsnip',
        'coc-tsserver',
        'coc-ultisnips-select',
        'coc-vimlsp',
        'coc-word',
        'coc-yaml',
      }

      vim.keymap.set({ 'i' }, '<C-Space>', function()
        vimx.fn.copilot.Suggest()

        return vim.fn['coc#refresh']()
      end, { expr = true, silent = true })

      vim.keymap.set({ 'i' }, '<C-s>', [[<Cmd>call CocActionAsync('showSignatureHelp')<CR>]], { silent = true })

      vim.keymap.set({ 'n' }, 'K', function()
        if require('ufo').peekFoldedLinesUnderCursor() then
          return
        end

        if vim.tbl_contains({ 'vim', 'help' }, vim.bo.filetype) then
          vim.cmd('h ' .. vim.fn.expand('<cword>'))
        elseif vim.fn['coc#rpc#ready']() then
          vimx.fn.CocActionAsync('doHover')
        end
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)p', [[<Plug>(coc-diagnostic-prev)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)n', [[<Plug>(coc-diagnostic-next)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)D', [[<Plug>(coc-definition)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)I', [[<Plug>(coc-implementation)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rF', [[<Plug>(coc-references)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rn', [[<Plug>(coc-rename)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)T', [[<Plug>(coc-type-definition)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)a', [[<Plug>(coc-codeaction-cursor)]])
      vim.keymap.set({ 'x' }, '<Plug>(lsp)a', [[<Plug>(coc-codeaction-selected)]])
      vim.keymap.set({ 'n' }, '<Plug>(lsp)f', [[<Plug>(coc-format)]])

      vim.keymap.set({ 'n' }, '<Plug>(lsp)q', '<Cmd>CocCommand fzf-preview.CocCurrentDiagnostics<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)Q', '<Cmd>CocCommand fzf-preview.CocDiagnostics<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)d', '<Cmd>CocCommand fzf-preview.CocDefinition<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)i', '<Cmd>CocCommand fzf-preview.CocImplementation<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)t', '<Cmd>CocCommand fzf-preview.CocTypeDefinition<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rf', '<Cmd>CocCommand fzf-preview.CocReferences<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(lsp)s', '<Cmd>CocCommand fzf-preview.CocTsServerSourceDefinition<CR>')

      vim.keymap.set({ 'i' }, '<C-n>', [[coc#pum#visible() ? coc#pum#next(1) : '']], { expr = true, silent = true })
      vim.keymap.set({ 'i' }, '<C-p>', [[coc#pum#visible() ? coc#pum#prev(1) : '']], { expr = true, silent = true })
      vim.keymap.set({ 'n' }, '<C-d>', [[coc#float#has_scroll() ? coc#float#scroll(1) : '<C-d>']], { expr = true })
      vim.keymap.set({ 'n' }, '<C-u>', [[coc#float#has_scroll() ? coc#float#scroll(0) : '<C-u>']], { expr = true })
      vim.keymap.set(
        { 'i' },
        '<C-d>',
        [[coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(1)<CR>' : '<Del>']],
        { expr = true, silent = true }
      )
      vim.keymap.set(
        { 'i' },
        '<C-u>',
        [[coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(0)<CR>' : '<C-u>']],
        { expr = true, silent = true }
      )

      vim.keymap.set({ 'i' }, '<CR>', function()
        if vimx.fn.coc.pum.visible() == 1 then
          return vimx.fn.coc.pum.confirm()
        end

        vimx.fn.coc.on_enter()

        return require('insx').expand('<CR>')
      end, { expr = true, silent = true, replace_keycodes = false })

      vim.api.nvim_create_autocmd({ 'CursorHold' }, {
        pattern = '*',
        callback = function()
          vimx.fn.CocActionAsync('highlight')
        end,
      })
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'CocJumpPlaceholder',
        callback = function()
          vimx.fn.CocActionAsync('showSignatureHelp')
        end,
      })

      -- NOTE: use coc-tsdetect
      -- local is_deno_cache = false
      local function is_deno()
        -- if is_deno_cache then
        --   return is_deno_cache
        -- end
        --
        -- if vim.fn.filereadable('.git/is_deno') or not vim.fn.isdirectory('node_modules') then
        --   is_deno_cache = true
        --   return true
        -- else
        --   is_deno_cache = false
        --   return false
        -- end
        return vim.b.tsdetect_is_node ~= 1
      end

      vim.api.nvim_create_user_command('OrganizeImport', function()
        vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
      end, {})

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'typescript', 'typescriptreact' },
        callback = function()
          vim.opt_local.tagfunc = 'CocTagFunc'
          if is_deno() then
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', [[<Plug>(coc-format)]])
          else
            vim.keymap.set(
              { 'n' },
              '<Plug>(lsp)f',
              [[<Cmd>CocCommand eslint.executeAutofix<CR><Cmd>CocCommand prettier.formatFile<CR>]]
            )
          end
        end,
      })

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'rust' },
        callback = function()
          vim.opt_local.tagfunc = 'CocTagFunc'
          vim.keymap.set({ 'n' }, 'gK', [[<Cmd>CocCommand rust-analyzer.openDocs<CR>]])
        end,
      })

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'vim', 'lua' },
        callback = function()
          vim.opt_local.tagfunc = 'CocTagFunc'
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        pattern = 'deno:/*.ts',
        callback = function()
          vim.cmd([[filetype detect]])
        end,
      })

      vim.list_extend(escesc, {
        function()
          vimx.fn.coc.float.close_all()
        end,
      })
    end,
  },
  {
    'github/copilot.vim',
    config = function()
      vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
        pattern = '*',
        callback = function()
          vim.keymap.set({ 'i' }, '<Tab>', [[copilot#Accept()]], { expr = true, silent = true, replace_keycodes = false })

          -- Debug
          -- vim.keymap.set({ 'i' }, '<C-g>', [[<Cmd>PP b:_copilot<CR>]])
        end,
      })
    end,
  },
  {
    'SirVer/ultisnips',
    init = function()
      vim.g.UltiSnipsSnippetDirectories = { '~/.vim/ultisnips' }

      vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
        pattern = '*.snippets',
        callback = function()
          vim.cmd([[set filetype=snippets]])
        end,
      })
    end,
  },
}

for _, plugin in ipairs(plugins) do
  if plugin.enabled == nil then
    plugin.enabled = vim.env.LSP == 'coc'
  end
end

return plugins
