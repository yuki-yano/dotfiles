return {
  { 'farmergreg/vim-lastplace', event = { 'BufReadPre' } },
  { 'kana/vim-niceblock', event = { 'ModeChanged' } },
  {
    'andymass/vim-matchup',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'BufRead' },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'MatchParen', { fg = 'NONE', bg = 'NONE', underline = true })
          vim.api.nvim_set_hl(0, 'MatchParenCur', { fg = 'NONE', bg = 'NONE', bold = true })
          vim.api.nvim_set_hl(0, 'MatchWord', { fg = 'NONE', bg = 'NONE', underline = true })
          vim.api.nvim_set_hl(0, 'MatchWordCur', { fg = 'NONE', bg = 'NONE', bold = true })
        end,
      })
    end,
  },
  {
    'hrsh7th/nvim-dansa',
    event = { 'BufRead' },
    config = function()
      require('dansa').setup()
    end,
  },
  { 'lambdalisue/suda.vim', cmd = { 'SudaRead', 'SudaWrite' } },
  { 'lambdalisue/vim-manpager', cmd = { 'ASMANPAGER' } },
  {
    'thinca/vim-quickrun',
    dependencies = {
      { 'lambdalisue/vim-quickrun-neovim-job' },
      { 'tyru/open-browser.vim' },
      { 'rcarriga/nvim-notify' },
    },
    cmd = { 'QuickRun' },
    config = function()
      local jobs = {}

      vim.g.quickrun_config = {
        ['_'] = {
          outputter = 'error',
          ['outputter/error/success'] = 'buffer',
          ['outputter/error/error'] = 'quickfix',
          ['outputter/buffer/opener'] = ':botright 15split',
          ['outputter/buffer/close_on_empty'] = 1,
          runner = 'neovim_job',
          hooks = {
            {
              on_ready = function(session, _)
                local job_id = nil
                if session._temp_names then
                  job_id = session._temp_names[1]
                  jobs[job_id] = { finish = false }
                end

                require('notify')('[QuickRun] Running ' .. session.config.command, 'warn', {
                  title = ' QuickRun',
                  -- keep = function()
                  --   if job_id then
                  --     return not jobs[job_id].finish
                  --   else
                  --     return true
                  --   end
                  -- end,
                })
              end,
              on_success = function(session, _)
                require('notify')('[QuickRun] Success ' .. session.config.command, 'info', { title = ' QuickRun' })
              end,
              on_failure = function(session, _)
                require('notify')('[QuickRun] Error ' .. session.config.command, 'error', { title = ' QuickRun' })
              end,
              on_finish = function(session, _)
                if session._temp_names then
                  local job_id = session._temp_names[1]
                  jobs[job_id].finish = true
                end
              end,
            },
          },
        },
        deno = {
          command = 'deno',
          cmdopt = '--no-check --allow-all --unstable',
          exec = { '%c run %o %s' },
        },
        tsc = {
          command = 'tsc',
          exec = {
            'yarn run --silent %C --project . --noEmit --incremental --tsBuildInfoFile .git/.tsbuildinfo 2>/dev/null',
          },
          outputter = 'quickfix',
          ['outputter/quickfix/errorformat'] = '%+A %#%f %#(%l,%c): %m,%C%m',
        },
        eslint = {
          command = 'eslint',
          exec = { 'yarn run --silent %C --format unix --ext .ts,.tsx %a 2>/dev/null' },
          outputter = 'quickfix',
          ['outputter/quickfix/errorformat'] = '%f:%l:%c:%m,%-G%.%#',
        },
        ['json-browser'] = {
          exec = 'cat %s | jq',
          outputter = 'browser',
          ['outputter/browser/name'] = vim.fn.tempname() .. '.json',
        },
        yq = {
          exec = 'cat %s | gojq --yaml-input',
        },
        ['yq-browser'] = {
          exec = 'cat %s | gojq --yaml-input',
          outputter = 'browser',
          ['outputter/browser/name'] = vim.fn.tempname() .. '.json',
        },
      }

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'quickrun' },
        callback = function()
          vim.keymap.set({ 'n' }, 'q', '<Cmd>quit<CR>', { buffer = true, nowait = true })
        end,
      })
    end,
  },
  {
    'kyoh86/vim-ripgrep',
    cmd = { 'Rg' },
    config = function()
      local vimx = require('artemis')

      vim.api.nvim_create_user_command('Rg', function(opts)
        vimx.fn.ripgrep.search(opts.qargs)
      end, {
        nargs = '*',
        complete = 'file',
      })
    end,
  },
  {
    'rbtnn/vim-layout',
    cmd = { 'SaveProjectLayout', 'LoadProjectLayout' },
    config = function()
      local vimx = require('artemis')

      local function project_layout_file()
        return vim.fn.substitute(vim.fn.trim(vim.fn.system('git branch --show-current')), '/', '_', 'g')
          .. '_layout.json'
      end

      vim.api.nvim_create_user_command('SaveProjectLayout', function()
        if vim.fn.isdirectory(vim.fn.getcwd() .. '/.git') == 1 then
          vimx.fn.layout.save(vim.fn.getcwd() .. '/.git/' .. project_layout_file())
        else
          vim.api.nvim_err_writeln('Not git project')
        end
      end, {})

      vim.api.nvim_create_user_command('LoadProjectLayout', function()
        if vim.fn.filereadable(vim.fn.getcwd() .. '/.git/' .. project_layout_file()) == 1 then
          vimx.fn.layout.load(vim.fn.getcwd() .. '/.git/' .. project_layout_file())
        else
          vim.api.nvim_err_writeln('Undefined layout file')
        end
      end, {})
    end,
  },
  { 'itchyny/vim-qfedit', ft = { 'qf' } },
  {
    'famiu/bufdelete.nvim',
    cmd = { 'Bdelete' },
    init = function()
      vim.keymap.set({ 'n' }, '<Leader>d', '<Cmd>Bdelete<CR>')
      vim.keymap.set({ 'n' }, '<Leader>D', '<Cmd>Bdelete!<CR>')
    end,
  },
  {
    'junegunn/vim-easy-align',
    keys = {
      { '<Plug>(EasyAlign)', mode = { 'x' } },
    },
    init = function()
      vim.keymap.set({ 'x' }, 'ga', '<Plug>(EasyAlign)')

      vim.g.easy_align_delimiters = {
        ['>'] = { pattern = [[>>\|=>\|>]] },
        ['/'] = { pattern = [[//\+\|/\*\|\*/]], ignore_groups = { 'String' } },
        ['#'] = {
          pattern = [[#\+]],
          ignore_groups = { 'String' },
          delimiter_align = 'l',
        },
        [']'] = {
          pattern = [=[[[\]]]=],
          left_margin = 0,
          right_margin = 0,
          stick_to_left = 0,
        },
        [')'] = {
          pattern = '[()]',
          left_margin = 0,
          right_margin = 0,
          stick_to_left = 0,
        },
        ['d'] = {
          pattern = [[ \(\S\+\s*[;=]\)\@=]],
          left_margin = 0,
          right_margin = 0,
        },
      }
    end,
  },
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle' },
    init = function()
      vim.keymap.set({ 'n' }, '<Leader>u', '<Cmd>UndotreeToggle<CR>')
      vim.g.undotree_HelpLine = 0
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_TreeNodeShape = '●'
      vim.g.undotree_WindowLayout = 2
    end,
  },
  {
    'wesQ3/vim-windowswap',
    keys = {
      { '<Leader><C-w>', mode = { 'n' } },
    },
    init = function()
      vim.g.windowswap_map_keys = false
    end,
    config = function()
      vim.keymap.set({ 'n' }, '<Leader><C-w>', '<Cmd>call WindowSwap#EasyWindowSwap()<CR>')
    end,
  },
  { 'AndrewRadev/linediff.vim', cmd = { 'Linediff' } },
  { 'kevinhwang91/nvim-bqf', ft = { 'qf' } },
  {
    'kwkarlwang/bufresize.nvim',
    event = { 'VimResized' },
    config = function()
      require('bufresize').setup()
    end,
  },
  {
    'jsfaint/gen_tags.vim',
    event = { 'BufRead' },
    init = function()
      vim.g['gen_tags#ctags_auto_gen'] = true
      vim.g['gen_tags#ctags_opts'] = '--excmd=number'
      vim.g['loaded_gentags#gtags'] = true
    end,
  },
  {
    'aserowy/tmux.nvim',
    keys = {
      { '<C-j>', mode = { 'n' } },
      { '<C-k>', mode = { 'n' } },
      { '<C-h>', mode = { 'n' } },
      { '<C-l>', mode = { 'n' } },
    },
    config = function()
      require('tmux').setup({
        copy_sync = {
          enable = false,
        },
        navigation = {
          enable_default_keybindings = true,
          cycle_navigation = true,
        },
        resize = {
          enable_default_keybindings = false,
        },
      })
    end,
  },
  {
    'tyru/capture.vim',
    dependencies = { { 'thinca/vim-prettyprint' } },
    cmd = { 'Capture' },
    config = function()
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'Capture' },
        callback = function()
          vim.keymap.set({ 'n' }, 'q', '<Cmd>quit<CR>', { buffer = true, nowait = true })
        end,
      })
    end,
  },
  {
    'aiya000/aho-bakaup.vim',
    event = { 'BufWritePre', 'FileWritePre' },
    config = function()
      vim.g.bakaup_auto_backup = true
      vim.g.bakaup_backup_dir = vim.fn.expand('~/.cache/vim/backup')
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    cmd = { 'ToggleTerm', 'TermExec', 'YR' },
    init = function()
      vim.keymap.set({ 'n' }, '<C-s><C-s>', '<Cmd>ToggleTerm direction=float<CR>')
      vim.keymap.set({ 'n' }, '<C-s>s', '<Cmd>ToggleTerm direction=horizontal<CR>')
      vim.keymap.set({ 'n' }, '<C-s>v', '<Cmd>ToggleTerm direction=vertical<CR>')
      vim.keymap.set({ 'n' }, '<C-s><C-v>', '<Cmd>ToggleTerm direction=vertical<CR>')

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'toggleterm' },
        callback = function()
          vim.keymap.set({ 't' }, '<C-s>', [[<C-\><C-n><Cmd>close<CR>]], { buffer = true, nowait = true })
        end,
      })
    end,
    config = function()
      require('toggleterm').setup({
        size = function(term)
          if term.direction == 'horizontal' then
            return vim.o.lines * 0.4
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.3
          end
        end,
      })

      local function package_json_scripts(_, _, _)
        if vim.fn.filereadable('package.json') == 0 then
          return
        end
        local ok, json = pcall(vim.json.decode, table.concat(vim.fn.readfile('package.json'), ' '))
        if not ok then
          return {}
        end

        local scripts = {}
        for k, _ in pairs(json.scripts) do
          table.insert(scripts, k)
        end
        return scripts
      end

      local i = 1
      vim.api.nvim_create_user_command('YR', function(opts)
        vim.cmd(i .. [[TermExec cmd='yarn run ]] .. opts.args .. [[']])
        i = i + 1
      end, { nargs = 1, complete = package_json_scripts })
    end,
  },
  { 'thinca/vim-prettyprint', cmd = { 'PP' } },
  { 'rbtnn/vim-vimscript_lasterror', cmd = { 'VimscriptLastError' } },
  { 'dstein64/vim-startuptime', cmd = { 'StartupTime' } },
  {
    'segeljakt/vim-silicon',
    cmd = { 'Silicon' },
    init = function()
      vim.g.silicon = {
        font = 'UDEV Gothic 35NF',
        theme = 'OneHalfDark',
        background = '#3D3D3D',
        output = '~/Downloads/silicon-{time:%Y-%m-%d-%H%M%S}.png',
      }
    end,
  },
  -- {
  --   'skanehira/denops-silicon.vim',
  --   dependencies = { 'vim-denops/denops.vim' },
  --   cmd = { 'Silicon' },
  --   config = function()
  --     require('denops-lazy').load('denops-silicon.vim')
  --
  --     vim.g.silicon_options = {
  --       font = 'UDEV Gothic 35NF',
  --       theme = 'OneHalfDark',
  --       background_color = '#3D3D3D',
  --     }
  --   end,
  -- },
  { 'powerman/vim-plugin-AnsiEsc', cmd = { 'AnsiEsc' } },
  {
    'yuki-yano/ai-review.vim',
    -- dir = '~/repos/github.com/yuki-yano/ai-review.vim',
    dependencies = { 'vim-denops/denops.vim' },
    cmd = { 'AiReview' },
    config = function()
      require('denops-lazy').load('ai-review.vim')
    end,
  },
  {
    'lambdalisue/guise.vim',
    dependencies = { { 'vim-denops/denops.vim' } },
    event = { 'User DenopsReady' },
  },
  {
    'yuki-yano/denops-open-http.vim',
    dependencies = { { 'vim-denops/denops.vim' } },
    event = { 'CmdLineEnter' },
  },
  {
    'yuki-yano/denops-http-file-protocol.vim',
    dependencies = {
      'vim-denops/denops.vim',
      'lambdalisue/file-protocol.vim',
    },
    event = { 'User DenopsReady' },
  },
  -- TODO: try later
  -- {
  --   'hachy/cmdpalette.nvim',
  --   cmd = { 'CmdPalette' },
  --   config = function()
  --     require('cmdpalette').setup({})
  --   end,
  -- },
}
