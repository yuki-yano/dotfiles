local add_disable_cmp_filetypes = require('rc.plugin_utils').add_disable_cmp_filetypes

return {
  {
    'yuki-yano/fzf-preview.vim',
    dev = false,
    branch = 'release/rpc',
    dependencies = {
      { 'junegunn/fzf' },
      { 'ryanoasis/vim-devicons' },
      { 'LeafCage/yankround.vim' },
    },
    cmd = {
      'FzfPreviewProjectFilesRpc',
      'FzfPreviewBuffersRpc',
      'FzfPreviewProjectMruFilesRpc',
      'FzfPreviewProjectMrwFilesRpc',
      'FzfPreviewLinesRpc',
      'FzfPreviewCtagsRpc',
      'FzfPreviewQuickFixRpc',
      'FzfPreviewLocationListRpc',
      'FzfPreviewJumpsRpc',
      'FzfPreviewChangesRpc',
      'FzfPreviewProjectGrepRpc',
      'FzfPreviewFromResourcesRpc',
      'FzfPreviewGitActionsRpc',
      'FzfPreviewGitStatusRpc',
      'FzfPreviewCommandPaletteRpc',
      'FzfPreviewNvimLspReferencesRpc',
      'FzfPreviewNvimLspDiagnosticsRpc',
      'FzfPreviewNvimLspCurrentDiagnosticsRpc',
      'FzfPreviewNvimLspDefinitionRpc',
      'FzfPreviewNvimLspTypeDefinitionRpc',
      'FzfPreviewNvimLspImplementationRpc',
      'FzfPreviewBookmarksRpc',
      'FzfPreviewYankroundRpc',
      'FzfPreviewTodoCommentsRpc',
    },
    init = function()
      vim.g.fzf_preview_filelist_command = 'fd --type file --hidden --exclude .git --strip-cwd-prefix'
      vim.g.fzf_preview_git_files_command =
        'git ls-files --exclude-standard | while read line; do if [[ ! -L $line ]] && [[ -f $line ]]; then echo $line; fi; done'
      vim.g.fzf_preview_grep_cmd = 'rg --line-number --no-heading --color=never --sort=path --with-filename'
      vim.g.fzf_preview_mru_limit = 5000
      vim.g.fzf_preview_use_dev_icons = true
      vim.g.fzf_preview_default_fzf_options = {
        ['--scheme'] = 'history',
        ['--reverse'] = true,
        ['--preview-window'] = 'wrap',
        ['--bind'] = 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview,ctrl-n:down,ctrl-p:up,ctrl-j:next-history,ctrl-k:previous-history,ctrl-a:toggle-all',
      }
      vim.g.fzf_preview_history_dir = '~/.fzf'
      vim.g.fzf_preview_update_statusline = false

      vim.env.BAT_STYLE = 'plain'

      if vim.env.NVIM_COLORSCHEME == 'gruvbox-material' then
        vim.env.BAT_THEME = 'gruvbox-dark'
        vim.env.FZF_PREVIEW_PREVIEW_BAT_THEME = 'Catppuccin-mocha'
        vim.env.FZF_DEFAULT_OPTS =
          '--reverse --pointer=">" --marker=">" --no-separator --color=bg+:#1D2021,bg:#1d2021,spinner:#D8A657,hl:#A9B665,fg:#D4BE98,header:#928374,info:#89B482,pointer:#7DAEA3,marker:#D8A657,fg+:#D4BE98,prompt:#E78A4E,hl+:#89B482'
      elseif vim.env.NVIM_COLORSCHEME == 'catppuccin' then
        vim.env.BAT_THEME = 'gruvbox-dark'
        vim.env.FZF_PREVIEW_PREVIEW_BAT_THEME = 'Catppuccin-mocha'
        vim.env.FZF_DEFAULT_OPTS =
          '--reverse --pointer=">" --marker=">" --no-separator --color=bg+:#1E1E2E,bg:#1E1E2E,spinner:#F5E0DC,hl:#89B4FA,fg:#CDD6F4,header:#A6ADC8,info:#CBA6F7,pointer:#F5E0DC,marker:#F5E0DC,fg+:#CDD6F4,prompt:#89B4FA,hl+:#89B4FA'
      end

      local function create_fzf_preview_keymaps(mappings)
        local initialized = false

        local function initialize_all()
          if initialized then
            return
          end
          initialized = true

          for _, m in ipairs(mappings) do
            local key = m[1]
            local cmd = m[2]
            if #m > 2 then
              cmd = cmd .. ' ' .. table.concat({ unpack(m, 3) }, ' ')
            end
            vim.keymap.set('n', '<Plug>(ff)' .. key, '<Cmd>' .. cmd .. '<CR>')
          end
        end

        for _, m in ipairs(mappings) do
          local key = m[1]
          local cmd = m[2]
          if #m > 2 then
            cmd = cmd .. ' ' .. table.concat({ unpack(m, 3) }, ' ')
          end

          vim.keymap.set('n', '<Plug>(ff)' .. key, function()
            initialize_all()
            return ':<C-u>' .. cmd .. '<CR>'
          end, { expr = true, silent = true })
        end
      end

      local mappings = {
        -- { 'r', 'FzfPreviewProjectMruFilesRpc' },
        -- { 'w', 'FzfPreviewProjectMrwFilesRpc' },
        -- { 'a', 'FzfPreviewFromResourcesRpc', 'project_mru', 'git' },
        -- { 's', 'FzfPreviewGitStatusRpc' },
        -- { 'gg', 'FzfPreviewGitActionsRpc' },
        -- { 'b', 'FzfPreviewBuffersRpc' },
        -- { '<C-o>', 'FzfPreviewJumpsRpc' },
        -- { 'g;', 'FzfPreviewChangesRpc' },
        -- { 'q', 'FzfPreviewQuickFixRpc' },
        -- { 'l', 'FzfPreviewLocationListRpc' },
        -- { ':', 'FzfPreviewCommandPaletteRpc' },
        -- { 'p', 'FzfPreviewYankroundRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort' },
      }

      create_fzf_preview_keymaps(mappings)

      -- vim.keymap.set(
      --   { 'n' },
      --   '<Plug>(ff)/',
      --   [[:<C-u>FzfPreviewProjectGrepRpc --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort . <C-r>=expand('%')<CR><CR>]]
      -- )
      -- vim.keymap.set(
      --   { 'n' },
      --   '<Plug>(ff)f',
      --   ':<C-u>FzfPreviewProjectGrepRpc --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort '
      -- )
      -- vim.keymap.set(
      --   { 'x' },
      --   '<Plug>(ff)f',
      --   [["sy:FzfPreviewProjectGrepRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"]]
      -- )
    end,
    config = function()
      local vimx = require('artemis')
      vimx.fn.fzf_preview.rpc.initialize()

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'fzf_preview#rpc#initialized' },
        callback = function()
          vim.g.fzf_preview_grep_preview_cmd = 'COLORTERM=truecolor ' .. vim.g.fzf_preview_grep_preview_cmd
          vim.g.fzf_preview_command = 'COLORTERM=truecolor ' .. vim.g.fzf_preview_command
          vim.g.fzf_preview_git_status_preview_command = '[[ $(git diff --cached -- {-1}) != "" ]] && git diff --cached --color=always -- {-1} | delta || [[ $(git diff -- {-1}) != "" ]] && git diff --color=always -- {-1} | delta || '
            .. vim.g.fzf_preview_command

          local custom_processes = {}
          custom_processes['open-file'] = vim.fn['fzf_preview#rpc#get_default_processes']('open-file')
          custom_processes['open-file']['ctrl-s'] = custom_processes['open-file']['ctrl-x']
          vim.fn.remove(custom_processes['open-file'], 'ctrl-x')

          custom_processes['open-file-with-tag-stack'] =
            vimx.fn.fzf_preview.rpc.get_default_processes('open-file-with-tag-stack')
          custom_processes['open-file-with-tag-stack']['ctrl-s'] =
            custom_processes['open-file-with-tag-stack']['ctrl-x']
          vim.fn.remove(custom_processes['open-file-with-tag-stack'], 'ctrl-x')

          custom_processes['open-buffer'] = vim.fn['fzf_preview#rpc#get_default_processes']('open-buffer')
          custom_processes['open-buffer']['ctrl-s'] = custom_processes['open-buffer']['ctrl-x']
          vim.fn.remove(custom_processes['open-buffer'], 'ctrl-x')

          custom_processes['open-bufnr'] = vim.fn['fzf_preview#rpc#get_default_processes']('open-bufnr')
          custom_processes['open-bufnr']['ctrl-s'] = custom_processes['open-bufnr']['ctrl-x']
          vim.fn.remove(custom_processes['open-bufnr'], 'ctrl-x')
          custom_processes['open-bufnr']['ctrl-x'] = custom_processes['open-bufnr']['ctrl-x']

          custom_processes['git-status'] = vim.fn['fzf_preview#rpc#get_default_processes']('git-status')
          custom_processes['git-status']['ctrl-s'] = custom_processes['git-status']['ctrl-x']
          vim.fn.remove(custom_processes['git-status'], 'ctrl-x')

          vim.g.fzf_preview_custom_processes = custom_processes
        end,
      })
    end,
  },
  {
    'Shougo/ddu.vim',
    lazy = true,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'Shougo/ddu-commands.vim' },
      { 'Shougo/ddu-ui-ff' },
      { 'Shougo/ddu-kind-file' },
      { 'yuki-yano/ddu-filter-fzf' },
      { 'lambdalisue/mr.vim' },
      { 'kuuote/ddu-source-mr' },
      { 'matsui54/ddu-source-help' },
      { 'Shougo/ddu-source-action' },
      { 'yuki-yano/ddu-source-nvim-notify', dev = true },
    },
    cmd = { 'Ddu' },
    event = { 'CmdlineEnter' },
    init = function()
      -- vim.keymap.set({ 'n' }, '<Plug>(ff)h', '<Cmd>Ddu help<CR>')
      add_disable_cmp_filetypes({ 'ddu-ff', 'ddu-ff-filter' })
    end,
    config = function()
      require('denops-lazy').load('ddu.vim', { wait_load = false })

      local vimx = require('artemis')

      vimx.fn.ddu.custom.patch_global({
        ui = 'ff',
        uiParams = {
          ff = {
            split = 'floating',
            prompt = '> ',
            floatingBorder = 'rounded',
            highlights = {
              floatingCursorLine = 'Visual',
              filterText = 'Statement',
              floating = 'Normal',
              floatingBorder = 'Special',
            },
            autoAction = {
              name = 'preview',
            },
            startAutoAction = true,
            previewFloating = true,
            previewFloatingBorder = 'rounded',
            previewSplit = 'vertical',
            previewWindowOptions = {
              { '&signcolumn', 'no' },
              { '&foldcolumn', 0 },
              { '&foldenable', 0 },
              { '&number', 0 },
              { '&relativenumber', 0 },
              { '&wrap', 0 },
              { '&scrolloff', 0 },
            },
          },
        },
      })

      local resize = function()
        local width = math.floor(vim.o.columns * 0.8)
        local previewWidth = math.floor(width * 0.5)
        local height = math.floor(vim.o.lines * 0.8)
        local previewHeight = height - 2
        local row = math.floor((vim.o.lines - height) / 2)
        local previewRow = row + 1
        local col = math.floor(vim.o.columns * 0.1)
        local halfWidth = math.floor(vim.o.columns * 0.5)
        local previewCol = halfWidth - 2

        vimx.fn.ddu.custom.patch_global({
          uiParams = {
            ff = {
              winWidth = width,
              winHeight = height,
              winRow = row,
              winCol = col,
              previewWidth = previewWidth,
              previewHeight = previewHeight,
              previewRow = previewRow,
              previewCol = previewCol,
            },
          },
        })
      end
      vim.api.nvim_create_autocmd({ 'VimResized' }, {
        pattern = { '*' },
        callback = resize,
      })
      resize()

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'ddu-ff' },
        callback = function()
          vim.opt_local.cursorline = true

          vim.keymap.set({ 'n' }, '<CR>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('itemAction')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, '<Space>', function()
            vimx.fn.ddu.ui.do_action('toggleSelectItem')
            vimx.fn.ddu.ui.do_action('cursorNext')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, 'i', function()
            vimx.fn.ddu.ui.do_action('openFilterWindow')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, '>', function()
            vimx.fn.ddu.ui.do_action('chooseAction')
          end, { buffer = true })

          vim.keymap.set({ 'n' }, 'q', function()
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, '<Esc><Esc>', function()
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-g>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true, nowait = true })
          vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })

          vim.keymap.set({ 'n' }, 'j', function()
            vimx.fn.ddu.ui.do_action('cursorNext')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, 'k', function()
            vimx.fn.ddu.ui.do_action('cursorPrevious')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-n>', function()
            vimx.fn.ddu.ui.do_action('cursorNext')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-p>', function()
            vimx.fn.ddu.ui.do_action('cursorPrevious')
          end, { buffer = true })

          vim.keymap.set({ 'n', 'i' }, '<C-d>', function()
            local ctrl_d = vim.api.nvim_replace_termcodes('<C-d>', true, true, true)
            vimx.fn.ddu.ui.do_action('previewExecute', { command = 'normal! ' .. ctrl_d })
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-u>', function()
            local ctrl_u = vim.api.nvim_replace_termcodes('<C-u>', true, true, true)
            vimx.fn.ddu.ui.do_action('previewExecute', { command = 'normal! ' .. ctrl_u })
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '?', function()
            vimx.fn.ddu.ui.do_action('toggleAutoAction')
          end, { buffer = true })
        end,
      })
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'ddu-ff-filter' },
        callback = function()
          vim.keymap.set({ 'n', 'i' }, '<CR>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('itemAction')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '>', function()
            vimx.fn.ddu.ui.do_action('chooseAction')
          end, { buffer = true })

          vim.keymap.set({ 'n' }, 'q', function()
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })
          vim.keymap.set({ 'n' }, '<Esc><Esc>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-g>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true, nowait = true })
          vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
            vim.cmd([[stopinsert]])
            vimx.fn.ddu.ui.do_action('quit')
          end, { buffer = true })

          vim.keymap.set({ 'n', 'i' }, '<C-n>', function()
            vimx.fn.ddu.ui.do_action('cursorNext')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-p>', function()
            vimx.fn.ddu.ui.do_action('cursorPrevious')
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<Tab>', function()
            vimx.fn.ddu.ui.do_action('toggleSelectItem')
            vimx.fn.ddu.ui.do_action('cursorNext')
          end, { buffer = true })

          vim.keymap.set({ 'n', 'i' }, '<C-d>', function()
            local ctrl_d = vim.api.nvim_replace_termcodes('<C-d>', true, true, true)
            vimx.fn.ddu.ui.do_action('previewExecute', { command = 'normal! ' .. ctrl_d })
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '<C-u>', function()
            local ctrl_u = vim.api.nvim_replace_termcodes('<C-u>', true, true, true)
            vimx.fn.ddu.ui.do_action('previewExecute', { command = 'normal! ' .. ctrl_u })
          end, { buffer = true })
          vim.keymap.set({ 'n', 'i' }, '?', function()
            vimx.fn.ddu.ui.do_action('toggleAutoAction')
          end, { buffer = true })

          vim.keymap.set({ 'i' }, "'", "'", { buffer = true })
        end,
      })

      vimx.fn.ddu.custom.patch_global({
        kindOptions = {
          action = {
            defaultAction = 'do',
          },
          file = {
            defaultAction = 'open',
          },
          help = {
            defaultAction = 'open',
          },
          ['ai-review-request'] = {
            defaultAction = 'open',
          },
          ['ai-review-log'] = {
            defaultAction = 'resume',
          },
          ['nvim-notify'] = {
            defaultAction = 'open',
          },
        },
      })
      vimx.fn.ddu.custom.patch_global({
        sourceOptions = {
          _ = {
            matchers = { 'matcher_fzf' },
            sorters = { 'sorter_fzf' },
          },
        },
      })
      vimx.fn.ddu.custom.patch_global({
        filterParams = {
          matcher_fzf = {
            highlightMatched = 'Search',
          },
        },
      })
      vimx.fn.ddu.custom.patch_global({
        kindParams = {
          help = {
            histadd = true,
          },
        },
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-tree/nvim-web-devicons' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    cmd = { 'Telescope' },
    init = function()
      add_disable_cmp_filetypes({ 'TelescopePrompt' })
    end,
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      telescope.setup({
        defaults = {
          theme = 'ivy',
          mappings = {
            n = {
              ['<Esc>'] = { actions.close, type = 'action', opts = { nowait = true } },
              ['<C-c>'] = actions.close,
              ['<C-g>'] = actions.close,
              ['q'] = actions.close,
            },
            i = {
              ['<C-g>'] = { actions.close, type = 'action', opts = { nowait = true } },
              ['<C-c>'] = actions.close,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      })

      telescope.load_extension('fzf')
    end,
  },
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    cmd = { 'FzfLua' },
    init = function()
      -- vim.keymap.set({ 'n' }, '<Plug>(ff)h', '<Cmd>FzfLua help_tags<CR>')
    end,
    config = function()
      require('fzf-lua').setup({
        winopts = {
          win_height = 0.9,
          win_width = 0.9,
        },
        keymap = {
          builtin = {
            ['<C-d>'] = 'preview-page-down',
            ['<C-u>'] = 'preview-page-up',
          },
        },
        fzf_opts = {
          ['--info'] = 'default',
        },
      })
    end,
  },
}
