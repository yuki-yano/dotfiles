local color = require('rc.modules.color')
local merge = require('rc.modules.utils').merge
local dedent = require('rc.modules.utils').dedent
local add_disable_cmp_filetypes = require('rc.modules.plugin_utils').add_disable_cmp_filetypes

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'SnacksPickerTitle', { fg = color.base().orange })
          vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = color.base().sky })

          vim.api.nvim_create_autocmd({ 'FileType' }, {
            pattern = { 'snacks_picker_input' },
            callback = function()
              vim.keymap.set({ 'i' }, '<C-a>', '<Home>', { buffer = true })
              vim.keymap.set({ 'i' }, '<C-e>', '<End>', { buffer = true })
            end,
          })
        end,
      })
    end,
    config = function()
      local snacks = require('snacks')

      ---@type snacks.picker.Config
      local picker_opts = {
        layout = 'default',
        auto_confirm = false,
        formatters = {
          file = {
            truncate = 999,
            icon_width = 3,
          },
        },
        matcher = {
          frecency = true,
          history_bonus = true,
        },
        win = {
          input = {
            keys = {
              ['<C-f>'] = false,
              ['<C-b>'] = false,
              ['<C-a>'] = false,
              ['<C-g>'] = { 'close', mode = { 'n', 'i', 'x' } },
              ['<C-j>'] = { 'history_forward', mode = { 'i', 'n' } },
              ['<C-k>'] = { 'history_back', mode = { 'i', 'n' } },
              ['<C-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
              ['<C-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<C-w><C-w>'] = { 'cycle_win', mode = { 'n' } },
              ['!'] = { 'toggle_hidden', mode = { 'n' } },
              ['I'] = { 'toggle_ignored', mode = { 'n' } },
              ['P'] = { 'toggle_preview', mode = { 'n' } },
              ['<C-l>'] = { 'toggle_live', mode = { 'n', 'i' } },
            },
            b = {
              insx_disabled = true,
            },
          },
          list = {
            keys = {
              ['<C-g>'] = { 'close', mode = { 'n', 'i', 'x' } },
              ['<C-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
              ['<C-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<C-a>'] = { 'select_all', mode = { 'n' } },
              ['!'] = { 'toggle_hidden', mode = { 'n' } },
              ['I'] = { 'toggle_ignored', mode = { 'n' } },
              ['P'] = { 'toggle_preview', mode = { 'n' } },
              ['<C-w><C-w>'] = { 'cycle_win', mode = { 'n' } },
            },
          },
          preview = {
            keys = {
              ['<C-w><C-w>'] = { 'cycle_win', mode = { 'n' } },
            },
          },
        },
      }

      ---@type snacks.Config
      local opts = {
        bigfile = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        picker = merge(picker_opts, { enabled = true }),
        quickfile = { enabled = true },
        image = { enabled = false },
        words = {
          enabled = true,
          notify_jump = true,
        },
      }

      snacks.setup(opts)
      snacks.words.enable()

      -- bufdelete
      vim.keymap.set({ 'n' }, '<Leader>d', function()
        snacks.bufdelete()
      end)
      vim.keymap.set({ 'n' }, '<Leader>D', function()
        snacks.bufdelete({ force = true })
      end)

      add_disable_cmp_filetypes({ 'snacks_picker_input' })

      -- indent
      vim.keymap.set({ 'n' }, '<Leader>i', function()
        if snacks.indent.enabled then
          snacks.indent.disable()
        else
          snacks.indent.enable()
        end
      end)

      -- notification
      vim.api.nvim_create_user_command('SnacksNotification', snacks.notifier.show_history, {})

      -- words
      vim.keymap.set({ 'n' }, ']]', function()
        snacks.words.jump(vim.v.count1, true)
      end)

      vim.keymap.set({ 'n' }, '[[', function()
        snacks.words.jump(-vim.v.count1, true)
      end)

      -- picker
      vim.keymap.set({ 'n' }, '<Plug>(ff)r', function()
        snacks.picker.smart({
          filter = {
            cwd = true,
          },
        })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)a', function()
        snacks.picker.files({
          filter = {
            cwd = true,
          },
          hidden = true,
        })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)s', function()
        snacks.picker.git_status()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)c', function()
        snacks.picker.pickers()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)b', function()
        snacks.picker.buffers()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)<C-o>', function()
        snacks.picker.jumps()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)q', function()
        snacks.picker.qflist()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)l', function()
        snacks.picker.loclist()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)/', function()
        snacks.picker.lines()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)f', function()
        snacks.picker.grep({
          hidden = true,
        })
      end)

      vim.keymap.set({ 'x' }, '<Plug>(ff)f', function()
        snacks.picker.grep_word({
          hidden = true,
        })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)h', function()
        snacks.picker.help()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)L', function()
        snacks.picker.lazy()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)p', function()
        snacks.picker({
          finder = function()
            local haritsuke_list = vim.fn['haritsuke#list']()
            local items = {}

            for i, entry in ipairs(haritsuke_list) do
              local text = entry.type .. '  ' .. dedent(entry.content)
              items[i] = {
                type = entry.type,
                text = text,
                yank = entry.content,
                preview = { text = entry.content },
              }
            end

            return items
          end,
          format = 'text',
          preview = 'preview',
          confirm = function(picker, item)
            picker:close()
            vim.fn.setreg('"', item.yank, item.type)
          end,
        })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(ff)t', function()
        ---@diagnostic disable-next-line: undefined-field
        snacks.picker.todo_comments()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)q', function()
        snacks.picker.diagnostics_buffer()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)Q', function()
        snacks.picker.diagnostics()
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)d', function()
        snacks.picker.lsp_definitions({ auto_confirm = false })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)i', function()
        snacks.picker.lsp_implementations({ auto_confirm = false })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)t', function()
        snacks.picker.lsp_type_definitions({ auto_confirm = false })
      end)

      vim.keymap.set({ 'n' }, '<Plug>(lsp)rf', function()
        snacks.picker.lsp_references({ auto_confirm = false })
      end)

      -- AI directory picker
      vim.keymap.set({ 'n' }, '<Plug>(ff)i', function()
        local ai_dir = vim.fn.getcwd() .. '/ai'
        if vim.fn.isdirectory(ai_dir) == 1 then
          snacks.picker.files({
            cwd = ai_dir,
            hidden = true,
            filter = {
              cwd = false,
            },
          })
        else
          vim.notify('AI directory not found in current directory', vim.log.levels.WARN)
        end
      end)
    end,
  },
}
