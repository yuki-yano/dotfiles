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
      if not snacks.picker.format._git_status_staged_override then
        local original_git_status_format = snacks.picker.format.git_status
        snacks.picker.format.git_status = function(item, picker)
          local ret = original_git_status_format(item, picker)
          if item and item.status and item.status:sub(1, 1) == 'M' and type(ret[1]) == 'table' then
            ret[1] = { ret[1][1], 'SnacksPickerGitStatusStaged' }
          end
          return ret
        end
        snacks.picker.format._git_status_staged_override = true
      end

      local function sanitize_selection(selection)
        local items = {}
        for _, item in ipairs(selection or {}) do
          if item.file then
            items[#items + 1] = {
              file = item.file,
              cwd = item.cwd,
              status = item.status,
            }
          end
        end
        return items
      end

      local function refresh_git_status_picker(picker)
        if not picker or picker.closed or not picker.list then
          return
        end
        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end

      local function run_git_batch(picker, selection, builder)
        local items = sanitize_selection(selection or picker:selected({ fallback = true }))
        if vim.tbl_isempty(items) then
          return
        end
        local groups = {}
        local fallback_cwd = picker:cwd() or (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
        for _, item in ipairs(items) do
          if item.file and item.file ~= '' then
            local cwd = item.cwd or fallback_cwd
            groups[cwd] = groups[cwd] or {}
            table.insert(groups[cwd], item.file)
          end
        end
        local total = 0
        local completed = 0
        for cwd, files in pairs(groups) do
          if not vim.tbl_isempty(files) then
            local cmd = builder(files)
            if cmd then
              total = total + 1
              snacks.picker.util.cmd(cmd, function()
                completed = completed + 1
                if completed == total then
                  refresh_git_status_picker(picker)
                end
              end, { cwd = cwd })
            end
          end
        end
        if total == 0 then
          refresh_git_status_picker(picker)
        end
      end

      local function stage_selection(picker, selection)
        if picker.focus ~= 'list' then
          picker:focus('list', { show = true })
        end
        run_git_batch(picker, selection, function(files)
          local cmd = { 'git', 'add', '--' }
          vim.list_extend(cmd, files)
          return cmd
        end)
      end

      local function reset_selection(picker, selection)
        if picker.focus ~= 'list' then
          picker:focus('list', { show = true })
        end
        run_git_batch(picker, selection, function(files)
          local cmd = { 'git', 'restore', '--staged', '--' }
          vim.list_extend(cmd, files)
          return cmd
        end)
      end

      local function commit_selection(picker, _)
        if picker.focus ~= 'list' then
          picker:focus('list', { show = true })
        end
        local cwd = picker:cwd() or (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
        picker:close()
        vim.schedule(function()
          local ok, result = pcall(function()
            return vim.system({ 'git', 'diff', '--cached', '--name-only' }, { cwd = cwd, text = true }):wait()
          end)
          if not ok or not result or result.code ~= 0 then
            return
          end
          if not result.stdout or result.stdout:match('%S') == nil then
            return
          end
          vim.cmd({ cmd = 'Gin', args = { '-C', cwd, 'commit' } })
        end)
      end

      local function open_tab_for_item(item)
        vim.cmd('tabnew')
        if item.cwd and item.cwd ~= '' then
          vim.cmd(string.format('lcd %s', vim.fn.fnameescape(item.cwd)))
        end
        if item.file and item.file ~= '' then
          local fullpath = item.file
          if item.cwd and item.cwd ~= '' then
            fullpath = table.concat({ item.cwd, item.file }, '/')
          end
          vim.cmd(string.format('edit %s', vim.fn.fnameescape(fullpath)))
        end
      end

      local function patch_selection(picker, selection)
        local items = sanitize_selection(selection or picker:selected({ fallback = true }))
        if vim.tbl_isempty(items) then
          return
        end
        picker:close()
        vim.schedule(function()
          for _, item in ipairs(items) do
            open_tab_for_item(item)
            if item.file and item.file ~= '' then
              vim.cmd(string.format('GinPatch %s', vim.fn.fnameescape(item.file)))
            else
              vim.cmd('GinPatch')
            end
          end
        end)
      end

      local function chaperon_selection(picker, selection)
        local items = sanitize_selection(selection or picker:selected({ fallback = true }))
        if vim.tbl_isempty(items) then
          return
        end
        picker:close()
        vim.schedule(function()
          for _, item in ipairs(items) do
            open_tab_for_item(item)
            if item.file and item.file ~= '' then
              vim.cmd(string.format('GinChaperon %s', vim.fn.fnameescape(item.file)))
            else
              vim.cmd('GinChaperon')
            end
          end
        end)
      end

      local function open_actions_picker(picker)
        local items = sanitize_selection(picker:selected({ fallback = true }))
        if vim.tbl_isempty(items) then
          return
        end
        local prev_auto_close = picker.opts.auto_close
        picker.opts.auto_close = false

        local summary = {}
        for _, item in ipairs(items) do
          summary[#summary + 1] = ('%s %s'):format(item.status or '  ', item.file or '')
        end
        local preview_text = table.concat(summary, '\n')
        local target_ref = picker:ref()

        local function with_target(fn)
          local target = target_ref()
          if target then
            fn(target)
          end
        end

        snacks.picker.pick({
          source = 'git_status_actions',
          title = 'Git Actions',
          prompt = '> ',
          layout = 'select',
          format = 'text',
          confirm = 'item_action',
          on_close = function()
            local target = target_ref()
            if target then
              target.opts.auto_close = prev_auto_close
              if not target.closed then
                target:focus('list', { show = true })
              end
            elseif picker then
              picker.opts.auto_close = prev_auto_close
            end
          end,
          items = {
            {
              text = 'Add (git add)',
              action = function()
                with_target(function(target)
                  stage_selection(target, items)
                end)
              end,
              preview = { text = preview_text },
            },
            {
              text = 'Reset (git restore --staged)',
              action = function()
                with_target(function(target)
                  reset_selection(target, items)
                end)
              end,
              preview = { text = preview_text },
            },
            {
              text = 'Patch (:Gin patch)',
              action = function()
                with_target(function(target)
                  patch_selection(target, items)
                end)
              end,
              preview = { text = preview_text },
            },
            {
              text = 'Chaperon (:Gin chaperon)',
              action = function()
                with_target(function(target)
                  chaperon_selection(target, items)
                end)
              end,
              preview = { text = preview_text },
            },
          },
        })
      end

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
        actions = {
          git_stage_selected = function(picker, _, action)
            stage_selection(picker, action and action.selection)
          end,
          git_reset_selected = function(picker, _, action)
            reset_selection(picker, action and action.selection)
          end,
          git_commit_selected = function(picker, _, action)
            commit_selection(picker, action and action.selection)
          end,
          git_patch_selected = function(picker, _, action)
            patch_selection(picker, action and action.selection)
          end,
          git_chaperon_selected = function(picker, _, action)
            chaperon_selection(picker, action and action.selection)
          end,
          git_status_actions = function(picker)
            open_actions_picker(picker)
          end,
        },
        sources = {
          git_status = {
            win = {
              input = {
                keys = {
                  ['<Tab>'] = { 'select_and_next', mode = { 'n', 'i' } },
                  ['<S-Tab>'] = { 'select_and_prev', mode = { 'n', 'i' } },
                  ['>'] = { 'git_status_actions', mode = { 'n', 'i' }, nowait = true },
                  ['<C-a>'] = { 'git_stage_selected', mode = { 'n', 'i' }, nowait = true },
                  ['<C-r>'] = { 'git_reset_selected', mode = { 'n', 'i' }, nowait = true },
                  ['<C-c>'] = { 'git_commit_selected', mode = { 'n', 'i' }, nowait = true },
                },
              },
              list = {
                keys = {
                  ['<Tab>'] = { 'select_and_next', mode = { 'n', 'x' } },
                  ['<S-Tab>'] = { 'select_and_prev', mode = { 'n', 'x' } },
                  ['>'] = { 'git_status_actions', mode = { 'n' }, nowait = true },
                  ['<C-a>'] = { 'git_stage_selected', mode = { 'n' }, nowait = true },
                  ['<C-r>'] = { 'git_reset_selected', mode = { 'n' }, nowait = true },
                  ['<C-c>'] = { 'git_commit_selected', mode = { 'n' }, nowait = true },
                },
              },
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
      -- vim.keymap.set({ 'n' }, '<Plug>(ff)r', function()
      --   snacks.picker.smart({
      --     filter = {
      --       cwd = true,
      --     },
      --   })
      -- end)

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
        local cwd = vim.fn.getcwd()
        local ai_dir = cwd .. '/ai'
        local docs_dir = cwd .. '/docs'
        local kiro_dir = cwd .. '/.kiro'
        local has_ai = vim.fn.isdirectory(ai_dir) == 1
        local has_docs = vim.fn.isdirectory(docs_dir) == 1
        local has_kiro = vim.fn.isdirectory(kiro_dir) == 1
        local dirs = {}

        if has_ai then
          table.insert(dirs, 'ai')
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
          vim.notify('AI or docs directory not found in current directory', vim.log.levels.WARN)
        end
      end)
    end,
  },
  {
    'yuki-yano/snacks-smart-open.nvim',
    dev = true,
    lazy = false,
    dependencies = { 'folke/snacks.nvim' },
    config = function()
      local snacks = require('snacks')
      require('snacks-smart-open').setup({
        apply_to = { 'smart', 'smart_open_files' },
      })
      vim.keymap.set({ 'n' }, '<Plug>(ff)r', function()
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
