local escesc = require('func').escesc

local plugins = {
  {
    'github/copilot.vim',
    cmd = { 'Copilot' },
    init = function()
      vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
        pattern = '*',
        callback = function()
          vim.cmd([[inoremap <silent> <expr> <Tab> copilot#Accept()]])

          -- Debug
          -- vim.keymap.set({ 'i' }, '<C-g>', [[<Cmd>PP b:_copilot<CR>]])
        end,
      })
    end,
  },
  {
    'SirVer/ultisnips',
    ft = { 'snippets' },
    event = { 'InsertEnter' },
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
  {
    'neoclide/coc.nvim',
    build = 'yarn install --frozen-lockfile',
    event = { 'BufRead' },
    dependencies = {
      { 'junegunn/fzf' },
      { 'cohama/lexima.vim' },
      { 'github/copilot.vim' },
      { 'kevinhwang91/nvim-ufo' },
      { 'SirVer/ultisnips' },
    },
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
        vimx.fn.copilot.Next()
        vimx.fn.copilot.Previous()

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
      end, { silent = true })

      vim.keymap.set({ 'n' }, '<Leader>K', [[<Cmd>call CocActionAsync('doHover', 'preview')<CR>]], { silent = true })
      vim.keymap.set(
        { 'n' },
        '<Plug>(lsp)p',
        [[<Plug>(coc-diagnostic-prev)], { silent = true })
          vim.keymap.set({ 'n' }, '<Plug>(lsp)n', [[<Plug>(coc-diagnostic-next)]],
        { silent = true }
      )
      vim.keymap.set({ 'n' }, '<Plug>(lsp)D', [[<Plug>(coc-definition)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)I', [[<Plug>(coc-implementation)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rF', [[<Plug>(coc-references)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)rn', [[<Plug>(coc-rename)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)T', [[<Plug>(coc-type-definition)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)a', [[<Plug>(coc-codeaction-cursor)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)A', [[<Plug>(coc-codeaction)]], { silent = true })
      vim.keymap.set({ 'n' }, '<Plug>(lsp)f', [[<Plug>(coc-format)]], { silent = true })

      vim.keymap.set(
        { 'n' },
        '<C-d>',
        [[coc#float#has_scroll() ? coc#float#scroll(1) : '<C-d>']],
        { silent = true, expr = true }
      )
      vim.keymap.set(
        { 'n' },
        '<C-u>',
        [[coc#float#has_scroll() ? coc#float#scroll(0) : '<C-u>']],
        { silent = true, expr = true }
      )
      vim.keymap.set(
        { 'i' },
        '<C-d>',
        [[coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(1)<CR>' : '<Del>']],
        { silent = true, expr = true }
      )
      vim.keymap.set(
        { 'i' },
        '<C-u>',
        [[coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(0)<CR>' : '<C-u>']],
        { silent = true, expr = true }
      )

      vim.keymap.set({ 'i' }, '<CR>', '')

      vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineLeave' }, {
        pattern = '*',
        callback = function()
          vim.keymap.set({ 'i' }, '<C-n>', [[coc#pum#visible() ? coc#pum#next(1) : '']], { expr = true, silent = true })
          vim.keymap.set({ 'i' }, '<C-p>', [[coc#pum#visible() ? coc#pum#prev(1) : '']], { expr = true, silent = true })
          -- TODO: Change lua mapping
          vim.cmd([[
                function! CocPumLeximaEnter() abort
                  let key = lexima#expand('<CR>', 'i')
                  call coc#on_enter()
                  return key
                endfunction
                inoremap <silent> <expr> <CR>  coc#pum#visible() ? coc#pum#confirm() : CocPumLeximaEnter()
              ]])
        end,
      })

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
            vim.keymap.set({ 'n' }, '<Plug>(lsp)f', [[<Plug>(coc-format)]], { silent = true })
          else
            vim.keymap.set(
              { 'n' },
              '<Plug>(lsp)f',
              [[<Cmd>CocCommand eslint.executeAutofix<CR><Cmd>CocCommand prettier.formatFile<CR>]],
              { silent = true }
            )
          end
        end,
      })

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'rust' },
        callback = function()
          vim.opt_local.tagfunc = 'CocTagFunc'
          vim.keymap.set({ 'n' }, 'gK', [[<Cmd>CocCommand rust-analyzer.openDocs<CR>]], { silent = true })
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
}

for _, plugin in ipairs(plugins) do
  plugin.enabled = vim.env.LSP == 'coc'
end

return plugins
