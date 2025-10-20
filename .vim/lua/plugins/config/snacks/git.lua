local merge = require('rc.modules.utils').merge

local M = {}

---@param snacks snacks
function M.setup(snacks)
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

  local function build_git_reflog_items(opts)
    opts = opts or {}
    local limit = opts.limit or 200
    local include_subject = opts.include_subject
    local git_root = opts.cwd
    if (not git_root or git_root == '') and snacks.git and snacks.git.get_root then
      git_root = snacks.git.get_root()
    end
    if not git_root or git_root == '' then
      return nil, 'Git repository not found'
    end

    local cmd = {
      'git',
      'reflog',
      '--color=never',
      '--date=iso',
      '-n',
      tostring(limit),
      '--pretty=format:%H%x1f%h%x1f%gd%x1f%gs%x1f%cr%x1f%cd%x1e',
    }

    local ok, result = pcall(function()
      return vim.system(cmd, { cwd = git_root, text = true }):wait()
    end)
    if not ok or not result or result.code ~= 0 then
      local err = ok and (result.stderr or '') or tostring(result)
      if err == '' then
        err = 'git reflog failed'
      end
      return nil, err
    end

    local entries = {}
    local record_sep = string.char(0x1e)
    local field_sep = string.char(0x1f)
    for _, record in ipairs(vim.split(result.stdout or '', record_sep, { plain = true, trimempty = true })) do
      local fields = vim.split(record, field_sep, { plain = true })
      local full_sha = fields[1] and vim.trim(fields[1]) or ''
      if full_sha and full_sha ~= '' then
        local short_sha = fields[2] and vim.trim(fields[2]) or ''
        if not short_sha or short_sha == '' then
          short_sha = full_sha:sub(1, 7)
        end
        local ref = fields[3] and vim.trim(fields[3]) or ''
        local subject = fields[4] and vim.trim(fields[4]) or ''
        local relative = fields[5] and vim.trim(fields[5]) or ''
        local iso = fields[6] and vim.trim(fields[6]) or ''

        local include = true
        if include_subject then
          if type(include_subject) == 'table' then
            include = false
            for _, pat in ipairs(include_subject) do
              if subject:find(pat, 1, true) then
                include = true
                break
              end
            end
          else
            include = subject:find(include_subject, 1, true) ~= nil
          end
        end

        if include then
          entries[#entries + 1] = {
            sha = full_sha,
            short_sha = short_sha,
            ref = ref,
            subject = subject,
            relative = relative,
            iso = iso,
            cwd = git_root,
            value = full_sha,
            ordinal = table.concat({ short_sha, ref, subject, relative, iso }, ' '),
          }
        end
      end
    end

    if #entries == 0 then
      return {}, git_root
    end

    return entries, git_root
  end

  local function format_git_reflog_item(item)
    local segments = {}
    if item.short_sha and item.short_sha ~= '' then
      segments[#segments + 1] = { item.short_sha, 'SnacksPickerGitStatusStaged' }
    end
    if item.relative and item.relative ~= '' then
      segments[#segments + 1] = { ('  %-12s'):format(item.relative), 'Comment' }
    end
    if item.iso and item.iso ~= '' then
      segments[#segments + 1] = { ('  %s'):format(item.iso:sub(1, 16)), 'Comment' }
    end
    if item.ref and item.ref ~= '' then
      segments[#segments + 1] = { ('  %s'):format(item.ref), 'SnacksPickerDir' }
    end
    if item.subject and item.subject ~= '' then
      segments[#segments + 1] = { ('  %s'):format(item.subject) }
    end
    return segments
  end

  local function preview_git_reflog_item(ctx)
    local item = ctx.item
    ctx.preview:reset()
    if not item or not item.sha then
      ctx.preview:notify('Select a reflog entry to preview', 'info')
      return
    end

    ctx.preview:set_title(item.short_sha or item.sha:sub(1, 7))

    local state = ctx.preview.state
    if state.git_reflog_job then
      pcall(function()
        state.git_reflog_job:kill('sigterm')
      end)
      state.git_reflog_job = nil
    end

    local cmd = {
      'git',
      '--no-pager',
      'show',
      '--color=never',
      item.sha,
    }
    local cwd = item.cwd or ctx.picker:cwd() or (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
    local target_item = item

    state.git_reflog_job = vim.system(cmd, { cwd = cwd, text = true }, function(res)
      vim.schedule(function()
        if ctx.item ~= target_item then
          return
        end
        state.git_reflog_job = nil
        if res.code ~= 0 then
          local err = vim.trim(res.stderr or res.stdout or 'git show failed')
          if err == '' then
            err = 'git show failed'
          end
          ctx.preview:notify(err, 'warn')
          return
        end
        local output = res.stdout or ''
        if output == '' then
          ctx.preview:notify('Diff is empty', 'info')
          return
        end
        if output:sub(-1) == '\n' then
          output = output:sub(1, -2)
        end
        ctx.preview:set_lines(vim.split(output, '\n', { plain = true }))
        ctx.preview:highlight({ ft = 'git' })
        ctx.preview:loc()
      end)
    end)
  end

  local function open_git_reflog_picker(opts)
    opts = opts or {}
    local entries, root_or_err = build_git_reflog_items(opts)
    if not entries then
      vim.notify(root_or_err or 'Failed to load git reflog', vim.log.levels.WARN, { title = 'Snacks Reflog' })
      return
    end
    if vim.tbl_isempty(entries) then
      vim.notify('Git reflog is empty', vim.log.levels.INFO, { title = 'Snacks Reflog' })
      return
    end

    local overrides = {}
    for key, value in pairs(opts) do
      if key ~= 'limit' and key ~= 'include_subject' then
        overrides[key] = value
      end
    end

    local picker_options = merge({
      source = 'git_reflog',
      items = entries,
      cwd = root_or_err,
      format = format_git_reflog_item,
      preview = preview_git_reflog_item,
      confirm = 'git_reflog_diffview',
    }, overrides)

    snacks.picker(picker_options)
  end

  snacks.picker.git_reflog = open_git_reflog_picker

  local function apply_keymaps()
    vim.keymap.set({ 'n' }, '<Plug>(ff)s', function()
      snacks.picker.git_status()
    end)

    vim.keymap.set({ 'n' }, '<Plug>(ff)R', function()
      snacks.picker.git_reflog({
        include_subject = { 'Git quick save:' },
        title = 'Git Reflog (Quick Save)',
      })
    end)
  end

  local picker_overrides = {
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
      git_reflog_diffview = function(picker, item, action)
        local target = item
        if action and type(action) == 'table' and action.selection and action.selection[1] then
          target = action.selection[1]
        end
        if not target or type(target) ~= 'table' then
          local selected = picker:selected({ fallback = true })
          target = selected[1]
        end
        if not target or not target.sha then
          vim.notify('No reflog entry selected', vim.log.levels.WARN, { title = 'Snacks Reflog' })
          return
        end
        local sha = target.sha
        if vim.fn.exists(':DiffviewOpen') == 0 then
          vim.notify('DiffviewOpen command is not available', vim.log.levels.ERROR, { title = 'Snacks Reflog' })
          return
        end
        picker:close()
        vim.schedule(function()
          local ok_open, err_open = pcall(vim.cmd, ('DiffviewOpen %s^!'):format(sha))
          if not ok_open then
            vim.notify(err_open, vim.log.levels.ERROR, { title = 'Snacks Reflog' })
          end
        end)
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

  return {
    picker = picker_overrides,
    apply_keymaps = apply_keymaps,
  }
end

return M
