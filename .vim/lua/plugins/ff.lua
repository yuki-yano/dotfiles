local add_disable_cmp_filetypes = require('rc.plugin_utils').add_disable_cmp_filetypes

return {
  {
    'yuki-yano/fzf-preview.vim',
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
          '--reverse --no-separator --color=bg+:#1D2021,bg:#1d2021,spinner:#D8A657,hl:#A9B665,fg:#D4BE98,header:#928374,info:#89B482,pointer:#7DAEA3,marker:#D8A657,fg+:#D4BE98,prompt:#E78A4E,hl+:#89B482'
      elseif vim.env.NVIM_COLORSCHEME == 'catppuccin' then
        vim.env.BAT_THEME = 'gruvbox-dark'
        vim.env.FZF_PREVIEW_PREVIEW_BAT_THEME = 'Catppuccin-mocha'
        vim.env.FZF_DEFAULT_OPTS =
          '--reverse --no-separator --color=bg+:#1E1E2E,bg:#1E1E2E,spinner:#F5E0DC,hl:#89B4FA,fg:#CDD6F4,header:#A6ADC8,info:#CBA6F7,pointer:#F5E0DC,marker:#F5E0DC,fg+:#CDD6F4,prompt:#89B4FA,hl+:#89B4FA'
      end

      vim.keymap.set({ 'n' }, '<Plug>(ff)r', '<Cmd>FzfPreviewProjectMruFilesRpc --experimental-fast<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)w', '<Cmd>FzfPreviewProjectMrwFilesRpc --experimental-fast<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)a', '<Cmd>FzfPreviewFromResourcesRpc --experimental-fast project_mru git<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)s', '<Cmd>FzfPreviewGitStatusRpc --experimental-fast<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)gg', '<Cmd>FzfPreviewGitActionsRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)b', '<Cmd>FzfPreviewBuffersRpc<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)<C-o>', '<Cmd>FzfPreviewJumpsRpc --experimental-fast<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ff)g;', '<Cmd>FzfPreviewChangesRpc<CR>')
      vim.keymap.set(
        { 'n' },
        '<Plug>(ff)/',
        [[:<C-u>FzfPreviewProjectGrepRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort . <C-r>=expand('%')<CR><CR>]]
      )
      vim.keymap.set({ 'n' }, '<Plug>(ff)q', '<Cmd>FzfPreviewQuickFixRpc<CR>')
      -- vim.keymap.set({ 'n' }, '<Plug>(ff)l', '<Cmd>FzfPreviewLocationListRpc<CR>')
      vim.keymap.set(
        { 'n' },
        '<Plug>(ff)f',
        ':<C-u>FzfPreviewProjectGrepRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort '
      )
      vim.keymap.set(
        { 'x' },
        '<Plug>(ff)f',
        [["sy:FzfPreviewProjectGrepRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"]]
      )
      vim.keymap.set({ 'n' }, '<Plug>(ff):', '<Cmd>FzfPreviewCommandPaletteRpc<CR>')
      vim.keymap.set(
        { 'n' },
        '<Plug>(ff)p',
        '<Cmd>FzfPreviewYankroundRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>'
      )
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
              ['<C-g>'] = actions.close,
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
      telescope.load_extension('notify')
    end,
  },
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    cmd = { 'FzfLua' },
    init = function()
      vim.keymap.set({ 'n' }, '<Plug>(ff)h', '<Cmd>FzfLua help_tags<CR>')
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
