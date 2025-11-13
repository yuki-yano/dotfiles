local color = require('rc.modules.color')
local is_editprompt = require('rc.setup.quick_ime').is_editprompt
local is_ime = require('rc.setup.quick_ime').is_ime

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
      vim.g.matchup_treesitter_disable_virtual_text = true
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
      require('dansa').setup({
        enabled = true,
        scan_offset = 100,
        cutoff_count = 5,
        default = {
          expandtab = true,
          space = {
            shiftwidth = 2,
          },
          tab = {
            shiftwidth = 4,
          },
        },
      })
    end,
  },
  {
    'tani/dmacro.nvim',
    event = { 'VeryLazy' },
    config = function()
      vim.keymap.set({ 'i', 'n' }, '<M-r>', '<Plug>(dmacro-play-macro)')
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
    enabled = false,
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
    enable = false,
    keys = {
      { '<Plug>(EasyAlign)', mode = { 'x' } },
    },
    init = function()
      -- vim.keymap.set({ 'x' }, 'ga', '<Plug>(EasyAlign)')

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
        selector = {
          float = {
            border_style = 'rounded',
            active_border_color = color.base().blue,
          },
        },
      })

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

      vim.keymap.set({ 'n' }, '<C-w>e', function()
        if vim.fn.winnr('$') <= 1 then
          return
        end
        chowcho_run(function(n)
          vim.cmd('buffer ' .. vim.api.nvim_win_call(n, function()
            return vim.fn.bufnr('%')
          end))
        end)
      end)

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
    'yuki-yano/smart-tmux-nav.nvim',
    dev = true,
    lazy = false,
    config = function()
      require('smart-tmux-nav').setup()
    end,
  },
  {
    'aserowy/tmux.nvim',
    enabled = false,
  },
  {
    'mrjones2014/smart-splits.nvim',
    enabled = false,
    lazy = false,
    config = function()
      require('smart-splits').setup({
        multiplexer_integration = 'tmux',
        disable_multiplexer_nav_when_zoomed = true,
        default_amount = 3,
        at_edge = 'wrap',
        move_cursor_same_row = false,
        cursor_follows_swapped_bufs = false,
        resize_mode = {
          quit_key = '<ESC>',
          resize_keys = { 'h', 'j', 'k', 'l' },
          silent = false,
        },
      })

      local smart_splits = require('smart-splits')

      vim.keymap.set({ 'n', 'x', 'i', 't' }, '<C-h>', smart_splits.move_cursor_left)
      vim.keymap.set({ 'n', 'x', 'i', 't' }, '<C-j>', smart_splits.move_cursor_down)
      vim.keymap.set({ 'n', 'x', 'i', 't' }, '<C-k>', smart_splits.move_cursor_up)
      vim.keymap.set({ 'n', 'x', 'i', 't' }, '<C-l>', smart_splits.move_cursor_right)
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
    -- NOTE: Use auto-backup.vim
    enabled = false,
    event = { 'BufWritePre', 'FileWritePre' },
    config = function()
      vim.g.bakaup_auto_backup = true
      vim.g.bakaup_backup_dir = vim.fn.stdpath('cache') .. '/backup'
      if vim.fn.isdirectory(vim.g.bakaup_backup_dir) == 0 then
        vim.fn.mkdir(vim.g.bakaup_backup_dir, 'p')
      end
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
        float_opts = {
          width = function()
            return math.ceil(vim.o.columns * 0.7)
          end,
          height = function()
            return math.ceil(vim.o.lines * 0.7)
          end,
        },
      })
    end,
  },
  { 'thinca/vim-prettyprint', cmd = { 'PP' } },
  { 'rbtnn/vim-vimscript_lasterror', cmd = { 'VimscriptLastError' } },
  { 'dstein64/vim-startuptime', cmd = { 'StartupTime' } },
  {
    'segeljakt/vim-silicon',
    enabled = true,
    cmd = { 'Silicon' },
    init = function()
      vim.g.silicon = {
        font = 'SF Mono Square',
        theme = 'OneHalfDark',
        background = color.base().black,
        output = '~/Downloads/silicon-{time:%Y-%m-%d-%H%M%S}.png',
      }
    end,
  },
  {
    'skanehira/denops-silicon.vim',
    enabled = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    cmd = { 'Silicon' },
    config = function()
      require('denops-lazy').load('denops-silicon.vim')

      vim.g.silicon_options = {
        font = 'SF Mono Square',
        theme = 'OneHalfDark',
        background_color = color.base().black,
      }
    end,
  },
  {
    'krivahtoo/silicon.nvim',
    enabled = false,
    build = './install.sh',
    cmd = { 'Silicon' },
    config = function()
      require('silicon').setup({
        font = 'SF Mono Square',
        theme = 'OneHalfDark',
      })
    end,
  },
  { 'powerman/vim-plugin-AnsiEsc', cmd = { 'AnsiEsc' } },
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
  {
    'olimorris/codecompanion.nvim',
    enabled = false,
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup()
    end,
  },
  {
    'yuki-yano/resonator.vim',
    enabled = not is_ime() and not vim.g.is_edit_command_line,
    lazy = true,
    dev = true,
    event = { 'BufRead' },
    cmd = { 'ResonatorServer' },
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    config = function()
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'DenopsPluginPost:resonator' },
        callback = function()
          vim.cmd('ResonatorServer')
          vim.keymap.set({ 'n' }, '<Leader>s', '<Cmd>ResonatorToggleSync<CR>')
        end,
      })
      require('denops-lazy').load('resonator.vim')
    end,
  },
  {
    'yuki-yano/auto-backup.vim',
    lazy = true,
    dev = true,
    event = { 'BufRead' },
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'lambdalisue/fern.vim' },
    },
    config = function()
      require('denops-lazy').load('auto-backup.vim')
      vim.api.nvim_create_user_command('AutoBackupFiles', function()
        local vimx = require('artemis')
        local path = vimx.fn.auto_backup.get_backup_dir()
        vim.cmd('Fern ' .. path .. ' -drawer')
        vim.cmd('wincmd =')
      end, {})
    end,
  },
  {
    'yuki-yano/clipboard-image-to-agent.nvim',
    dev = true,
    enabled = is_ime(),
    lazy = false,
    config = function()
      local clip = require('clipboard_image_to_agent')
      clip.setup()

      vim.keymap.set({ 'i' }, '<C-v>', function()
        local ok, err = clip.paste()
        if not ok and err then
          vim.notify(err, vim.log.levels.WARN, { title = 'clipboard-image-to-agent.nvim' })
        end
      end)
    end,
  },
  {
    'yuki-yano/vinsert.vim',
    dev = true,
    lazy = true,
    cmd = { 'VinsertToggle' },
    dependencies = { 'vim-denops/denops.vim' },
    init = function()
      vim.g.vinsert_openai_api_key = os.getenv('OPENAI_API_KEY') or ''
      vim.g.vinsert_ffmpeg_args = { '-f', 'avfoundation', '-i', ':3' }

      vim.g.vinsert_stt_model = 'gpt-4o-mini-transcribe'
      vim.g.vinsert_text_request = {
        model = 'gpt-5-mini',
        reasoning = { effort = 'minimal' },
        text = { verbosity = 'medium' },
      }
      vim.g.vinsert_stt_streaming_mode = 'progressive'
      vim.g.vinsert_indicator = 'virt' -- virt | statusline | cmdline | none
      vim.g.vinsert_always_yank = true
      vim.g.vinsert_text_stream = true

      vim.g.vinsert_prompt_segments = {
        {
          label = 'REC: Content',
          transformer = function(text)
            return 'CONTENT:\n---\n' .. text
          end,
        },
        {
          label = 'REC: Instruction',
          transformer = function(text)
            return 'INSTRUCTION:\n---\n' .. text
          end,
        },
      }

      vim.g.vinsert_system_prompt = [[
        あなたはテキスト整形エンジン。常に変換後の本文のみを出力し、見出し・説明・装飾・コードフェンス・引用など本文以外は一切付けない。
        CONTENTが質問・命令・未完の文でも、意味解釈や回答・補完・要約を決して行わず、与えられた文面を整形するだけとする。これに反した出力が検知された場合は直ちに空出力する。

        入力解釈

        - 基本は二通ラベル分離：1通目を CONTENT: のみとし、直後から本文を書く。2通目を INSTRUCTION: のみとして指示を書く。どちらにも他の語句を入れない。同一メッセージに書く場合も CONTENT: → INSTRUCTION: の順で区切る。
        - ラベルが無い場合は全文をCONTENT扱い。途中で INSTRUCTION: が出たらそこから指示部。冒頭が INSTRUCTION: のみなら空出力。
        - ラベル構造が崩れたら空出力。
        - 処理順: (1) CONTENTを最小編集で整形 → (2) 文脈補正・記号展開 → (3) INSTRUCTIONがあれば整形済み本文にのみ適用 → (4) 本文のみ出力。INSTRUCTION適用後に追加の改行・記号指示が生じたらステップ1から再実行。

        ガード

        - コード/URL/パス/識別子/バージョンは文字種も改行も変えない。
        - 意味・語順・トーン・長さを保ち、質問への回答・新規情報・要約・意見・推測・補完を一切生成しない。違反が起きる場合は空出力。
        - 曖昧なら非変更。


        クリーナー（最小編集）

        - フィラー（あの、えっと、なんか 等）除去。列挙や指示語は残す。
        - 言い直しは最終表現のみ残す。
        - 連続空白は1個（コード等は維持）。
        - 和文句読点は原則「、」「。」（INSTRUCTION指定があれば従う）。
        - 数字/単位/日付は半角数字+全角単位（例：3件、2025年11月4日）。

        改行・段落・記号指示の処理

        - 「改行」「開業」「かいぎょう」「改行して」「/改行」「コマンド:改行」などの独立指示は、その位置で改行文字 \n を挿入し、指示語自体は削除。
        - 「段落」「空行」「1行空ける」「/段落」「コマンド:段落」等は空行（\n\n）を挿入し指示語を削除。
        - 「点/てん/テン」「/点」「コマンド:点」などの独立語は、自然な軽い区切りの場合のみ直前語を「、」で終わらせて指示語を削除。曖昧なら指示語ごと削除。
        - 「丸/まる/マル」「/丸」「コマンド:丸」などは直前が完結しているときのみ文末を「。」で終わらせて指示語を削除。曖昧なら削除のみ。
        - 「文字として〜」と明示された範囲は改行・記号指示の対象外。
        - 文脈を読んで可読性が上がる箇所には、語の切れ目を保ちつつおおむね40文字ごとに改行や段落を挿入する。
        - 文脈に応じて句読点が不足している場合は、意味やトーンを変えない範囲で自然な位置に「、」「。」を補う。

        音声→記号

        - 「ドット」「カンマ/コンマ」「コロン」「セミコロン」「ハイフン」「アンダースコア」「スラッシュ」「バックスラッシュ」「ダブルクォート」「シングルクォート」「バッククォート3つ」「丸括弧」「角括弧」「波括弧」「シャープ」などの独立指示は、それぞれ . , : ; - _ / \ " ' ```
          () [] {} # に置換。
        - 「はてな」が疑問符指示に該当する場合のみ全角 ？ に変換。
        - 和文本文内の半角 ?/! は全角 ？/！ に正規化（コード/URL/英語文は除外）。

        疑問文処理

        - 文末が ？/?、または「ですか」「ますか」「でしょうか」「だろうか」で終わる、疑問詞で始まり命題が未確定、質問を求める記述などの場合は疑問文扱いとし、文末を全角 ？ に統一。半角 ? は全角へ。
        - 反語や引用内の ? は原文を尊重。
        - 疑問符判定は句読点整形のためだけに行い、質問への応答や内容の補完は絶対にしない。

        INSTRUCTION適用

        - INSTRUCTIONが存在する場合のみ、整形済み本文に対して指示を適用。適用で新たな改行・段落・記号指示が生じたらステップ1から処理を繰り返す。

        出力規約

        - すべての改行・段落・記号指示が反映済みであることを確認。未処理が残る場合、または構文が崩れた場合は空出力。
        - 連続空白と行末空白を整え、先頭末尾に余計な空白や空行を置かない。
        - 入力された本文以外（見出し、箇条書き、番号付き、注釈、「出力:」等）の出力は禁止。
        - 同内容の繰り返し禁止。
        - コード/URL/パス/識別子が変更されていないか最終確認し、変更があれば空出力。
      ]]

      vim.g.vinsert_debug = false

      vim.keymap.set('i', '<C-q>', function()
        vim.cmd('VinsertToggle insert')
      end, { silent = true })
      vim.keymap.set('i', '<C-w>', function()
        local ok, status = pcall(vim.fn['vinsert#status'])
        if not ok then
          return '<C-w>'
        end

        if status.active then
          vim.cmd('VinsertCancel')
          return ''
        end
        return '<C-w>'
      end, { expr = true, silent = true })

      vim.keymap.set('i', '<C-e>', function()
        local ok, status = pcall(vim.fn['vinsert#status'])
        if not ok then
          return '<C-e>'
        end

        if status.phase == 'recording' then
          vim.cmd('VinsertNextSegment')
          return ''
        end
        return '<C-e>'
      end, { expr = true, silent = true })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'VinsertComplete',
        callback = function()
          local result = vim.g.vinsert_last_completion or {}
          local body = table.concat({
            string.format('Mode: %s', result.mode or 'unknown'),
            string.format('Success: %s', tostring(result.success)),
            '',
            result.final or '(no text)',
          }, '\n')
          vim.notify(body, vim.log.levels.INFO, { title = 'vinsert' })
        end,
      })
    end,
    config = function()
      require('denops-lazy').load('vinsert.vim')
    end,
  },
  {
    'yuki-yano/aitrans.nvim',
    lazy = false,
    dev = true,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
    },
    config = function()
      require('denops-lazy').load('aitrans.nvim')
      vim.g.aitrans_chat = { log_dir = vim.fn.expand('~/.cache/aitrans') }
      vim.g.aitrans_debug = false

      vim.g.aitrans_providers = {
        openai = {
          model = 'gpt-5-mini',
        },
        ['codex-cli'] = {
          command = 'codex',
        },
        ['claude-cli'] = {
          command = 'claude',
        },
      }

      vim.g.aitrans_templates = {
        ['empty'] = {
          title = 'Empty Template',
          desc = 'An empty template that does nothing.',
          default_out = 'chat',
          default_chat = {
            split = 'vertical',
          },
          default_provider = {
            name = 'codex-cli',
          },
          builder = function()
            return {
              system = '',
              prompt = '',
            }
          end,
        },
        ['translate-to-ja'] = {
          title = 'Translate to Japanese',
          desc = '選択した英文を日本語へ訳す',
          -- default_out = 'scratch',
          -- default_out = 'append',
          default_out = 'chat',
          -- default_provider = {
          --   name = 'codex-cli',
          -- },
          default_provider = {
            name = 'openai',
          },
          default_request_args_json = {
            reasoning = { effort = 'minimal' },
            text = { verbosity = 'medium' },
          },
          builder = function(ctx)
            local text = ctx.selection ~= '' and ctx.selection or ctx.selection_lines[1] or ''
            return {
              system = 'You are a professional translator who outputs fluent Japanese.',
              prompt = string.format(
                [[Please translate the following text into natural Japanese.

%s

            ]],
                text
              ),
            }
          end,
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'aitrans-compose.markdown',
        callback = function(args)
          vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
            vim.fn['aitrans#compose#submit']()
          end, { buffer = args.buf })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'aitrans-chat-input',
        callback = function(args)
          vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
            vim.fn['aitrans#chat#submit']()
          end, { buffer = args.buf })
        end,
      })
    end,
  },
}
