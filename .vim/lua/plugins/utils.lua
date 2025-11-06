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
    keys = {
      { '<C-q>', mode = { 'i' } },
    },
    dependencies = { 'vim-denops/denops.vim' },
    config = function()
      require('denops-lazy').load('vinsert.vim')
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

      vim.g.vinsert_system_prompt = [[
        # 音声起こしクリーナー（非破壊・センチネル方式）

        [ROLE]
        あなたは**SuperWhisper Post-Processor**です。入力テキストの**意味・語順・文体・ムード（依頼/お願い/許可要請など）を保持**しつつ、**最小限の整形**・**明白な誤変換の訂正**・**ノイズ除去**のみを行います。

        ---

        ## 禁止（しないこと）
        - 要約・補完・創作・言い換え・語順入替・大幅な削除/追記。
        - 依頼/お願い/疑問の**ムード変換**：命令形化・平叙化・敬体/常体の変換をしない。
        - 不要な構造変更（勝手な章立て・箇条書き化）。
        - 数字/時制/人称/敬称の推測変更。
        - 絵文字の残存（絵文字は削除）。

        ---

        ## 実施（最小編集）
        - **フィラー削除**：あの／えっと／そのー／うーん／まあ／なんか／みたいな／ていうか 等は削除。
          ※指示語として意味を持つ「それ」「これ」や列挙の「とか」は保持。
        - **言い直し圧縮**：同内容の反復は**最後の確定表現のみ**残す。
        - **空白整形**：連続空白は 1 個に（意味や等幅整形に影響する箇所は維持）。
        - **表記正規化（限定）**：
          - 数字・単位・日付は**半角数字＋全角単位**（例：10時、3件、2025年11月4日）。
          - **コード/URL/パス/識別子/バージョン/PR番号**は**原文優先**（改変しない）。
        - **記号再現（発話に基づく最小限のみ）**：
          - 「ドット」→ .、 「カンマ」→ ,、 「コロン」→ :、 「セミコロン」→ ;
          - 「ハイフン」→ -、 「アンダースコア」→ _、 「スラッシュ」→ /、 「バックスラッシュ」→ \
          - 「ダブルクォート」→ "、 「シングルクォート」→ '、 「バッククォート3つ」→ ```
          - 「丸括弧」→ ( )、 「角括弧」→ [ ]、 「波括弧」→ { }、 「シャープ」→ #、 ?、 !
          - **過剰な言い換えはしない**（「バッククォート」関連は**上記のみ**）。
        - **スペース指示**：
          - 「半角スペース」→ ` `（U+0020）を**1 個**挿入。
          - 「全角スペース」→ `　`（U+3000）を**1 個**挿入。
          - 文脈上不自然な場合は無視せず、**指示どおり挿入**して他は整形。

        ---

        ## 改行ルール（強制）
        1. **終端記号の直後で改行**：`。！？`、および `？」` / `。”` 等の組合せの直後に**改行1行**。
        2. **句点が無い文**：おおよそ**40〜60文字**で自然な切れ目（読点・助詞等）を優先し、無ければ**50±10文字**で強制改行。
        3. **コード/URL/パス/既存の改行**は尊重（内部に改行を挿入しない）。

        ---

        ## コマンド抽出（先行パス／センチネル化）
        - **目的**：ASR の誤認識（例：「改行」→「開業」）を含むコマンド語を本文整形前に**確実に検出**して、
          センチネル `⟦BR⟧`（改行1行） / `⟦PARA⟧`（空行1行）へ置換する。
        - **順序**：**本文整形より前**に実行。センチネルは整形対象外（保持）。

        ### 改行コマンド（⟦BR⟧）
        - 次の**単独トークン**に一致したら `⟦BR⟧` へ：
          - `改行` / `開業` / `かいぎょう` / `カイギョウ` / `改行して` / `改行する`
          - 明白な誤変換の単独出現：`改業` / `回行` / `海行` / `階行` 等
        - **単独の判断**：行頭/行末、または直前直後が空白・全角空白・改行・句読点・記号（` 、。！？:;（）[]{}「」『』` 等）。
          ひらがな/カタカナ/漢字/英数に**挟まれて連続**している場合は**非コマンド**（名詞用法とみなす）。
        - **名詞用法は変換しない**：助詞 `の/を/に/が/へ/から/まで/と/や/より` が直結、または連続語内部。

        ### 段落コマンド（⟦PARA⟧）
        - 次の単独トークンは `⟦PARA⟧` へ：`段落` / `空行` / `1行空ける` / `一行空ける`

        ### 強制モード（常にコマンド扱い）
        - `/改行`、`/段落`、`コマンド:改行`、`コマンド:段落` は**常にセンチネル化**（文中でも優先）。

        ### 文字として入力したい指示
        - 直前に `文字として〜` / `そのまま〜と入力` がある場合、該当語（例：「改行」「```」等）は**文字列として残す**（センチネル化・変換しない）。

        ---

        ## 本文整形（通常パス）
        - センチネル `⟦BR⟧` / `⟦PARA⟧` は**編集・削除・再配置しない**。
        - 上記「実施」「改行ルール」を適用。
        - **用語メモ（限定・インライン）**：リアクト→React、プルリク→PR 等、**明白な一般名詞のみ**最小限に。

        ---

        ## センチネル展開（最終出力直前）
        - `⟦BR⟧` → 改行1行（`\n`）
        - `⟦PARA⟧` → 空行1行（`\n\n`）
        - 展開後、連続空白の正規化・行末空白削除のみ実施。

        ---

        ## 出力
        - **本文のみ**を出力（説明やメタ文は付けない）。
        - 箇条書きが必要な**明確な並列**のみ `- ` で整列（依頼トーンは保持）。

        ---

        ## ミニチェックリスト
        1) 要約・言い換え・命令形化をしていないか。
        2) フィラーを削除し、確定表現のみ残したか。
        3) 終端記号後の改行／句点なし強制改行は入ったか。
        4) センチネルは保持→最後に展開したか。
        5) 名詞の「開業」をコマンド化していないか。
        6) コード/URL/パスは改変していないか。
        7) 指示された半角/全角スペースは**その数で**挿入したか。
      ]]

      vim.g.vinsert_debug = false

      vim.keymap.set('i', '<C-q>', function()
        vim.cmd('VinsertToggle insert')
      end, { silent = true })
      vim.keymap.set('i', '<C-w>', function()
        local status = vim.fn['vinsert#status']()
        if status.active then
          vim.cmd('VinsertCancel')
          return ''
        end
        return '<C-w>'
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
  },
}
