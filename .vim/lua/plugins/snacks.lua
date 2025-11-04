local color = require('rc.modules.color')
local merge = require('rc.modules.utils').merge
local dedent = require('rc.modules.utils').dedent
local add_disable_cmp_filetypes = require('rc.modules.plugin_utils').add_disable_cmp_filetypes

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'lambdalisue/gin.vim' },
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          local base = color.base()
          vim.api.nvim_set_hl(0, 'SnacksPickerTitle', { fg = base.orange })
          vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = base.sky })
          vim.api.nvim_set_hl(0, 'SnacksPickerGitStatusStaged', { fg = base.green })
          vim.api.nvim_set_hl(0, 'SnacksPickerGitStatusModified', { fg = base.red })

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
      if not snacks.picker.format._git_status_dual_highlight_override then
        local original_git_status_format = snacks.picker.format.git_status
        local stage_hls = {
          A = 'SnacksPickerGitStatusAdded',
          C = 'SnacksPickerGitStatusCopied',
          D = 'SnacksPickerGitStatusDeleted',
          M = 'SnacksPickerGitStatusStaged',
          R = 'SnacksPickerGitStatusRenamed',
          U = 'SnacksPickerGitStatusUnmerged',
          ['?'] = 'SnacksPickerGitStatusUntracked',
          ['!'] = 'SnacksPickerGitStatusIgnored',
        }
        local work_hls = {
          A = 'SnacksPickerGitStatusAdded',
          C = 'SnacksPickerGitStatusCopied',
          D = 'SnacksPickerGitStatusDeleted',
          M = 'SnacksPickerGitStatusModified',
          R = 'SnacksPickerGitStatusRenamed',
          U = 'SnacksPickerGitStatusUnmerged',
          ['?'] = 'SnacksPickerGitStatusUntracked',
          ['!'] = 'SnacksPickerGitStatusIgnored',
        }
        local function resolve_hl(char, map, fallback)
          if not char or char == '' then
            return fallback
          end
          if char:match('^%s$') then
            return nil
          end
          return map[char] or fallback
        end
        snacks.picker.format.git_status = function(item, picker)
          local ret = original_git_status_format(item, picker)
          local first = ret[1]
          if type(first) ~= 'table' or type(first[1]) ~= 'string' then
            return ret
          end
          local status_text = first[1]
          if status_text == '' then
            return ret
          end
          if #status_text < 2 then
            status_text = status_text .. (' '):rep(2 - #status_text)
          elseif #status_text > 2 then
            status_text = status_text:sub(-2)
          end
          local stage_char = status_text:sub(1, 1)
          local work_char = status_text:sub(2, 2)
          local default_stage_hl = first[2] or 'SnacksPickerGitStatus'
          first[1] = stage_char
          first[2] = resolve_hl(stage_char, stage_hls, default_stage_hl)
          local work_hl = resolve_hl(work_char, work_hls, 'SnacksPickerGitStatus')
          table.insert(ret, 2, { work_char, work_hl })
          return ret
        end
        snacks.picker.format._git_status_dual_highlight_override = true
      end

      local git_config = require('plugins.config.snacks.git').setup(snacks)

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

      if git_config and git_config.picker then
        picker_opts = merge(picker_opts, git_config.picker)
      end

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

      -- NOTE: Use smart_open_files picker
      -- picker
      -- vim.keymap.set({ 'n' }, '<Plug>(ff)r', function()
      --   snacks.picker.smart({
      --     filter = {
      --       cwd = true,
      --     },
      --   })
      -- end)

      -- picker keymaps (global visibility)
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

      vim.keymap.set({ 'n' }, '<Plug>(ff)R', function()
        ---@diagnostic disable-next-line: undefined-field
        snacks.picker.git_reflog({
          include_subject = { 'Git quick save:' },
          title = 'Git Reflog (Quick Save)',
        })
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
        snacks.picker.lines()
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
        local cwd = vim.fn.getcwd()
        local ai_dir = cwd .. '/ai'
        local tmp_ai_dir = cwd .. '/tmp/ai'
        local docs_dir = cwd .. '/docs'
        local kiro_dir = cwd .. '/.kiro'
        local has_ai = vim.fn.isdirectory(ai_dir) == 1
        local has_tmp_ai = vim.fn.isdirectory(tmp_ai_dir) == 1
        local has_docs = vim.fn.isdirectory(docs_dir) == 1
        local has_kiro = vim.fn.isdirectory(kiro_dir) == 1
        local dirs = {}

        if has_ai then
          table.insert(dirs, 'ai')
        end
        if has_tmp_ai then
          table.insert(dirs, 'tmp/ai')
        end
        if has_docs then
          table.insert(dirs, 'docs')
        end
        if has_kiro then
          table.insert(dirs, '.kiro')
        end

        if #dirs > 0 then
          snacks.picker.files({
            cwd = cwd,
            hidden = true,
            dirs = dirs,
            filter = {
              cwd = false,
            },
          })
        else
          vim.notify('ai, tmp/ai, docs, or .kiro directory not found in current directory', vim.log.levels.WARN)
        end
      end)
    end,
  },
  {
    'yuki-yano/snacks-smart-open.nvim',
    dev = true,
    event = 'VeryLazy',
    dependencies = { 'folke/snacks.nvim' },
    config = function()
      require('snacks-smart-open').setup({
        apply_to = { 'smart', 'smart_open_files' },
      })

      vim.keymap.set({ 'n' }, '<Plug>(ff)r', function()
        local snacks = require('snacks')
        ---@diagnostic disable-next-line: undefined-field
        snacks.picker.smart_open_files({
          filter = {
            cwd = true,
          },
          hidden = true,
        })
      end)
    end,
  },
}
