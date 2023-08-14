local color = require('rc.color')

return {
  { 'farmergreg/vim-lastplace', event = { 'BufReadPre' } },
  { 'kana/vim-niceblock', event = { 'ModeChanged' } },
  {
    'andymass/vim-matchup',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    event = { 'BufRead' },
    -- TODO: Disable in cmdwin
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
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

                vim.notify('[QuickRun] Running ' .. session.config.command, 'warn', {
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
                vim.notify('[QuickRun] Success ' .. session.config.command, 'info', { title = ' QuickRun' })
              end,
              on_failure = function(session, _)
                vim.notify('[QuickRun] Error ' .. session.config.command, 'error', { title = ' QuickRun' })
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
        vimx.fn.ripgrep.search(opts.args)
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

      -- FIX: Respond to cases where the project root and repository root do not match
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
    'ojroques/nvim-bufdel',
    enabled = false,
    cmd = { 'BufDel' },
    init = function()
      require('bufdel').setup({
        quit = false,
      })
      vim.keymap.set({ 'n' }, '<Leader>d', '<Cmd>BufDel<CR>')
      vim.keymap.set({ 'n' }, '<Leader>D', '<Cmd>BufDel!<CR>')
    end,
  },
  {
    'echasnovski/mini.bufremove',
    keys = {
      { '<Leader>d', mode = { 'n' } },
      { '<Leader>D', mode = { 'n' } },
    },
    config = function()
      local bufremove = require('mini.bufremove')
      bufremove.setup()

      vim.keymap.set({ 'n' }, '<Leader>d', function()
        bufremove.delete()
      end)
      vim.keymap.set({ 'n' }, '<Leader>D', function()
        bufremove.delete(0, true)
      end)
    end,
  },
  {
    'kyoh86/wipeout-buffers.nvim',
    cmd = { 'Wipeout' },
    config = function()
      vim.api.nvim_create_user_command('Wipeout', function(opts)
        require('wipeout').menu({ force = opts.bang, keep_layout = true })
      end, { bang = true })
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
    -- NOTE: Use chowcho.nvim
    enable = false,
    keys = {
      -- Load from keys because `on_func` does not support
      { '<Leader><C-w>', mode = { 'n' } },
    },
    init = function()
      vim.g.windowswap_map_keys = false
    end,
    config = function()
      vim.keymap.set({ 'n' }, '<Leader><C-w>', '<Cmd>call WindowSwap#EasyWindowSwap()<CR>')
    end,
  },
  {
    'tkmpypy/chowcho.nvim',
    keys = {
      { '<C-w>e', mode = { 'n' } },
      { '<C-w>x', mode = { 'n' } },
    },
    config = function()
      require('chowcho').setup({
        border_style = 'rounded',
        active_border_color = color.base().blue,
      })

      vim.keymap.set({ 'n' }, '<C-w>e', function()
        if vim.fn.winnr('$') <= 1 then
          return
        end
        require('chowcho').run(function(n)
          vim.cmd('buffer ' .. vim.api.nvim_win_call(n, function()
            return vim.fn.bufnr('%')
          end))
        end)
      end)

      local chowcho_run = require('chowcho').run
      local chowcho_bufnr = function(winid)
        return vim.api.nvim_win_call(winid, function()
          return vim.fn.bufnr('%'), vim.opt_local
        end)
      end
      local chowcho_buffer = function(winid, bufnr)
        return vim.api.nvim_win_call(winid, function()
          local old = chowcho_bufnr(0)
          vim.cmd('buffer ' .. bufnr)
          return old
        end)
      end

      vim.keymap.set({ 'n' }, '<C-w>x', function()
        chowcho_run(function(n)
          if vim.fn.winnr('$') <= 2 then
            vim.cmd([[wincmd x]])
            return
          end
          local bufnr0 = chowcho_bufnr(0)
          local bufnrn = chowcho_buffer(n, bufnr0)
          chowcho_buffer(0, bufnrn)
        end)
      end)
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
      vim.g.bakaup_backup_dir = vim.fn.stdpath('cache') .. '/backup'
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

      -- yarn run command
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
    enabled = false,
    cmd = { 'Silicon' },
    init = function()
      vim.g.silicon = {
        font = 'UDEV Gothic 35NF',
        theme = 'OneHalfDark',
        background = color.base().black,
        output = '~/Downloads/silicon-{time:%Y-%m-%d-%H%M%S}.png',
      }
    end,
  },
  {
    'skanehira/denops-silicon.vim',
    -- Use vim-silicon
    enabled = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    cmd = { 'Silicon' },
    config = function()
      require('denops-lazy').load('denops-silicon.vim')

      vim.g.silicon_options = {
        font = 'UDEV Gothic 35NF',
        theme = 'OneHalfDark',
        background_color = color.base().black,
      }
    end,
  },
  { 'powerman/vim-plugin-AnsiEsc', cmd = { 'AnsiEsc' } },
  {
    'yuki-yano/ai-review.vim',
    lazy = true,
    dev = true,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'Shougo/ddu.vim' },
    },
    cmd = { 'AiReview', 'AiReviewLog' },
    init = function()
      vim.keymap.set({ 'n', 'x' }, '<Leader><CR>', ':AiReview<CR>', { silent = true })
    end,
    config = function()
      require('denops-lazy').load('ai-review.vim', { wait_load = false })

      local vimx = require('artemis')
      local request = require('plugins.config.ai-review')

      vimx.fn.ai_review.config({
        log_dir = vim.fn.expand('~/dotfiles/data/ai-review'),
        chat_gpt = {
          model = 'gpt-4',
          requests = {
            {
              title = 'Customize request',
              request = request.customize_request,
              preview = function(opts)
                return request.customize_request(opts).text
              end,
            },
            {
              title = 'Find bugs',
              request = request.find_bugs,
              preview = function(opts)
                return request.find_bugs(opts).text
              end,
            },
            {
              title = 'Fix syntax error',
              request = request.fix_syntax_error,
              preview = function(opts)
                return request.fix_syntax_error(opts).text
              end,
            },
            {
              title = 'Split function',
              request = request.split_function,
              preview = function(opts)
                return request.split_function(opts).text
              end,
            },
            {
              title = 'Fix diagnostics',
              request = request.fix_diagnostics,
              preview = function(opts)
                return request.fix_diagnostics(opts).text
              end,
            },
            {
              title = 'Optimize',
              request = request.optimize,
              preview = function(opts)
                return request.optimize(opts).text
              end,
            },
            {
              title = 'Add comments',
              request = request.add_comments,
              preview = function(opts)
                return request.add_comments(opts).text
              end,
            },
            {
              title = 'Add tests',
              request = request.add_tests,
              preview = function(opts)
                return request.add_tests(opts).text
              end,
            },
            {
              title = 'Explain',
              request = request.explain,
              preview = function(opts)
                return request.explain(opts).text
              end,
            },
            {
              title = 'Commit Message',
              request = request.commit_message,
              preview = function(opts)
                return request.commit_message(opts).text
              end,
            },
          },
        },
      })

      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        pattern = { 'ai-review://*' },
        callback = function(ctx)
          local clients = vim.lsp.get_clients({ bufnr = ctx.buf })
          local notify = vim.notify
          -- NOTE: Disable detach notify
          ---@diagnostic disable-next-line: duplicate-set-field
          vim.notify = function(...) end
          for _, client in ipairs(clients) do
            vim.lsp.buf_detach_client(ctx.buf, client.id)
          end
          vim.notify = notify
        end,
      })
    end,
  },
  {
    'lambdalisue/guise.vim',
    lazy = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
    },
  },
  {
    'yuki-yano/denops-open-http.vim',
    dependencies = {
      { 'vim-denops/denops.vim' },
    },
    event = { 'CmdLineEnter' },
    config = function()
      require('denops-lazy').load('denops-open-http.vim', { wait_load = false })
    end,
  },
  {
    'yuki-yano/denops-http-file-protocol.vim',
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'lambdalisue/file-protocol.vim' },
    },
    cmd = { 'HttpFileProtocolServerStart' },
    config = function()
      require('denops-lazy').load('denops-http-file-protocol.vim')
    end,
  },
  {
    'haya14busa/vim-metarepeat',
    keys = {
      { '<Plug>(metarepeat)', mode = { 'n', 'x' } },
      { '<Plug>(metarepeat-preset-occurence)', mode = { 'n' } },
    },
    init = function()
      vim.keymap.set({ 'n', 'x' }, 'g.', '<Plug>(metarepeat)')
      vim.keymap.set({ 'n' }, 'go', '<Plug>(metarepeat-preset-occurence)')
    end,
  },
  {
    -- TODO: try later
    'hachy/cmdpalette.nvim',
    enabled = false,
    cmd = { 'CmdPalette' },
    config = function()
      require('cmdpalette').setup({})
    end,
  },
  {
    'wakatime/vim-wakatime',
    enabled = false,
    event = { 'BufRead', 'BufNewFile' },
  },
}
