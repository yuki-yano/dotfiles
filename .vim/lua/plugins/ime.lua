local ime = require('rc.modules.ime')
local editprompt_config = require('plugins.config.editprompt')

local editprompt_group = vim.api.nvim_create_augroup('Editprompt', { clear = true })

return {
  {
    'eetann/editprompt.nvim',
    cond = function()
      return ime.is_editprompt()
    end,
    lazy = false,
    dependencies = {
      { 'folke/snacks.nvim' },
    },
    init = function()
      if ime.is_editprompt() then
        vim.g.editprompt = 1
        vim.api.nvim_create_autocmd({ 'FileType' }, {
          group = editprompt_group,
          pattern = { 'markdown' },
          callback = function(ev)
            local bufnr = ev.buf
            local map_opts = { silent = true, nowait = true, buffer = bufnr }

            editprompt_config.apply_mode_opts()
            vim.bo[bufnr].filetype = 'markdown.editprompt'
            vim.opt_local.virtualedit = 'block'

            vim.keymap.set({ 'n', 'i' }, '<C-g>', '<Cmd>quit!<CR>', map_opts)
            vim.keymap.set('n', 'q', function()
              editprompt_config.send_current(bufnr, true)
            end, map_opts)
            vim.keymap.set('n', '<CR>', function()
              editprompt_config.send_current(bufnr, true)
            end, map_opts)
            vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
              editprompt_config.send_current(bufnr, true)
            end, map_opts)
            vim.keymap.set({ 'n', 'i' }, 'g<C-c>', function()
              editprompt_config.send_current(bufnr, false)
            end, map_opts)
            vim.keymap.set('x', '<C-c>', function()
              editprompt_config.send_visual(bufnr, true)
            end, map_opts)
            vim.keymap.set('x', 'g<C-c>', function()
              editprompt_config.send_visual(bufnr, false)
            end, map_opts)
            vim.keymap.set('n', 'ZZ', function()
              editprompt_config.send_current(bufnr, true)
            end, map_opts)

            for digit = 1, 9 do
              local text = tostring(digit)
              vim.keymap.set('n', text, function()
                editprompt_config.send_literal(bufnr, text, false)
              end, map_opts)
            end

            vim.keymap.set('n', '<C-p>', function()
              require('editprompt').history_prev()
            end, map_opts)
            vim.keymap.set('n', '<Up>', function()
              require('editprompt').history_prev()
            end, map_opts)
            vim.keymap.set('n', '<C-n>', function()
              require('editprompt').history_next()
            end, map_opts)
            vim.keymap.set('n', '<Down>', function()
              require('editprompt').history_next()
            end, map_opts)

            vim.keymap.set('i', '<C-p>', function()
              if vim.fn.pumvisible() == 1 then
                return '<C-p>'
              end
              vim.schedule(function()
                require('editprompt').history_prev()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<C-n>', function()
              if vim.fn.pumvisible() == 1 then
                return '<C-n>'
              end
              vim.schedule(function()
                require('editprompt').history_next()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<Up>', function()
              vim.schedule(function()
                require('editprompt').history_prev()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<Down>', function()
              vim.schedule(function()
                require('editprompt').history_next()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))

            vim.keymap.set('n', '<C-q>', function()
              require('editprompt').stash_push()
              vim.schedule(function()
                editprompt_config.move_cursor_to_start(bufnr)
              end)
            end, map_opts)
            vim.keymap.set('i', '<C-q>', function()
              vim.schedule(function()
                require('editprompt').stash_push()
                editprompt_config.move_cursor_to_start(bufnr)
              end)
            end, map_opts)

            vim.keymap.set('n', '<C-d>', function()
              if editprompt_config.is_buffer_blank_or_whitespace(bufnr) then
                vim.cmd('quit!')
                return
              end
              editprompt_config.feed_normal('<C-d>')
            end, map_opts)

            vim.keymap.set('i', '<C-d>', function()
              if editprompt_config.is_buffer_blank_or_whitespace(bufnr) then
                vim.schedule(function()
                  vim.cmd('quit!')
                end)
                return ''
              end
              return '<C-d>'
            end, vim.tbl_extend('force', map_opts, { expr = true }))

            for _, mapping in ipairs({
              { '<C-h>', 'h' },
              { '<C-j>', 'j' },
              { '<C-k>', 'k' },
              { '<C-l>', 'l' },
            }) do
              local lhs, dir = unpack(mapping)
              vim.keymap.set('n', lhs, function()
                if editprompt_config.is_buffer_empty(bufnr) then
                  vim.cmd('startinsert')
                end
                pcall(function()
                  require('smart-tmux-nav').navigate(dir)
                end)
              end, map_opts)
            end

            for _, mapping in ipairs({
              { '<C-h>', '<BS>', 'h' },
              { '<C-j>', '<C-j>', 'j' },
              { '<C-k>', '<C-k>', 'k' },
              { '<C-l>', '<C-l>', 'l' },
            }) do
              local lhs, fallback, dir = unpack(mapping)
              vim.keymap.set('i', lhs, function()
                if not editprompt_config.is_buffer_empty(bufnr) then
                  return fallback
                end
                pcall(function()
                  require('smart-tmux-nav').navigate(dir)
                end)
                return ''
              end, vim.tbl_extend('force', map_opts, { expr = true }))
            end

            vim.cmd('startinsert')
          end,
        })
      end
    end,
    config = function()
      require('editprompt').setup({
        cmd = 'editprompt',
        picker = 'snacks',
      })
    end,
  },
  {
    'vim-skk/skkeleton',
    enabled = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'skk-dev/dict', lazy = true },
      { 'delphinus/skkeleton_indicator.nvim' },
    },
    event = { 'InsertEnter' },
    init = function()
      vim.keymap.set({ 'i' }, '<C-j>', '<Plug>(skkeleton-toggle)')
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'skkeleton-initialize-pre' },
        callback = function()
          vim.fn['skkeleton#config']({
            eggLikeNewline = true,
            globalDictionaries = {
              vim.fn.stdpath('cache') .. '/lazy/dict/SKK-JISYO.L',
            },
          })
        end,
      })
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'DenopsPluginPost:skkeleton' },
        callback = function()
          vim.fn['skkeleton#initialize']()
        end,
      })
    end,
    config = function()
      require('denops-lazy').load('skkeleton', { wait_load = false })
      require('skkeleton_indicator').setup({
        border = 'rounded',
        eijiHlName = 'LineNr',
        hiraHlName = 'String',
        kataHlName = 'Todo',
        hankataHlName = 'Special',
        zenkakuHlName = 'LineNr',
      })
    end,
  },
}
