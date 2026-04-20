local ime = require('rc.modules.ime')
local ime_helpers = require('plugins.config.ime_helpers')

local editprompt_group = vim.api.nvim_create_augroup('Editprompt', { clear = true })

return {
  {
    'eetann/editprompt.nvim',
    -- dev = true,
    cond = function()
      return ime.is_editprompt()
    end,
    lazy = false,
    dependencies = {
      { 'folke/snacks.nvim' },
      { 'yuki-yano/smart-tmux-nav.nvim' },
    },
    init = function()
      if ime.is_editprompt() then
        vim.g.editprompt = 1
        vim.api.nvim_create_autocmd({ 'FileType' }, {
          group = editprompt_group,
          pattern = { 'markdown' },
          callback = function(ev)
            local bufnr = ev.buf
            local editprompt = require('editprompt')
            local smart_tmux_nav = require('smart-tmux-nav')
            local map_opts = { silent = true, nowait = true, buffer = bufnr }
            local function is_buffer_blank()
              local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              return table.concat(lines, '\n'):find('%S') == nil
            end
            local function handle_cr()
              local mode = vim.api.nvim_get_mode().mode
              if is_buffer_blank() then
                if mode:sub(1, 1) == 'i' then
                  vim.schedule(function()
                    editprompt.press('<CR>')
                  end)
                else
                  editprompt.press('<CR>')
                end
                return ''
              end

              if mode:sub(1, 1) == 'i' then
                return '<CR>'
              end

              editprompt.input_auto_send()
              return ''
            end

            ime_helpers.apply_mode_opts()
            vim.bo[bufnr].filetype = 'markdown.editprompt'
            vim.opt_local.virtualedit = 'block'

            vim.keymap.set({ 'n', 'i' }, '<C-g>', '<Cmd>quit!<CR>', map_opts)
            vim.keymap.set('n', 'q', function()
              editprompt.input_auto_send()
            end, map_opts)
            vim.keymap.set({ 'n', 'i' }, '<CR>', handle_cr, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
              editprompt.input_auto_send()
            end, map_opts)
            vim.keymap.set({ 'n', 'i' }, 'g<C-c>', function()
              editprompt.input()
            end, map_opts)
            vim.keymap.set('x', '<C-c>', function()
              editprompt.input_visual_auto_send()
            end, map_opts)
            vim.keymap.set('x', 'g<C-c>', function()
              editprompt.input_visual()
            end, map_opts)
            vim.keymap.set('n', 'ZZ', function()
              editprompt.input_auto_send()
            end, map_opts)
            vim.keymap.set({ 'n', 'i' }, '<C-o>', '<Nop>', map_opts)

            for digit = 1, 9 do
              local text = tostring(digit)
              vim.keymap.set('n', text, function()
                editprompt.press(text)
              end, map_opts)
            end

            vim.keymap.set('n', '<C-p>', function()
              editprompt.history_prev()
            end, map_opts)
            vim.keymap.set('n', '<Up>', function()
              editprompt.history_prev()
            end, map_opts)
            vim.keymap.set('n', '<C-n>', function()
              editprompt.history_next()
            end, map_opts)
            vim.keymap.set('n', '<Down>', function()
              editprompt.history_next()
            end, map_opts)

            vim.keymap.set('i', '<C-p>', function()
              if vim.fn.pumvisible() == 1 then
                return '<C-p>'
              end
              vim.schedule(function()
                editprompt.history_prev()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<C-n>', function()
              if vim.fn.pumvisible() == 1 then
                return '<C-n>'
              end
              vim.schedule(function()
                editprompt.history_next()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<Up>', function()
              vim.schedule(function()
                editprompt.history_prev()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))
            vim.keymap.set('i', '<Down>', function()
              vim.schedule(function()
                editprompt.history_next()
              end)
              return ''
            end, vim.tbl_extend('force', map_opts, { expr = true }))

            vim.keymap.set('n', '<C-q>', function()
              editprompt.stash_push()
              vim.schedule(function()
                ime_helpers.move_cursor_to_start(bufnr)
              end)
            end, map_opts)
            vim.keymap.set('i', '<C-q>', function()
              vim.schedule(function()
                editprompt.stash_push()
                ime_helpers.move_cursor_to_start(bufnr)
              end)
            end, map_opts)

            vim.keymap.set('n', '<C-d>', function()
              if is_buffer_blank() then
                vim.cmd('quit!')
                return
              end
              ime_helpers.feed_normal('<C-d>')
            end, map_opts)

            vim.keymap.set('i', '<C-d>', function()
              if is_buffer_blank() then
                vim.schedule(function()
                  vim.cmd('quit!')
                end)
                return ''
              end
              return '<C-d>'
            end, vim.tbl_extend('force', map_opts, { expr = true }))

            for _, mapping in ipairs({
              { '<C-h>', 'h' },
              { '<C-j>', 'j' },
              { '<C-k>', 'k' },
              { '<C-l>', 'l' },
            }) do
              local lhs, dir = unpack(mapping)
              vim.keymap.set('n', lhs, function()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                if #lines == 0 or (#lines == 1 and lines[1] == '') then
                  vim.cmd('startinsert')
                end
                smart_tmux_nav.navigate(dir)
              end, map_opts)
            end

            for _, mapping in ipairs({
              { '<C-h>', '<BS>', 'h' },
              { '<C-j>', '<C-j>', 'j' },
              { '<C-k>', '<C-k>', 'k' },
              { '<C-l>', '<C-l>', 'l' },
            }) do
              local lhs, fallback, dir = unpack(mapping)
              vim.keymap.set('i', lhs, function()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                if #lines ~= 0 and (#lines ~= 1 or lines[1] ~= '') then
                  return fallback
                end
                smart_tmux_nav.navigate(dir)
                return ''
              end, vim.tbl_extend('force', map_opts, { expr = true }))
            end

            vim.cmd('startinsert')
          end,
        })
      end
    end,
    config = function()
      local editprompt = require('editprompt')
      local function should_save_editprompt_clipboard(content)
        if type(content) ~= 'string' or content == '' then
          return false
        end

        local lines = vim.split(content, '\n', { plain = true })
        local first_line = lines[1] or ''
        if not first_line:find('^/') then
          return true
        end

        local first_line_args = first_line:match('^/%S*%s*(.*)$') or ''
        if first_line_args:find('%S') ~= nil then
          return true
        end

        local trailing_text = table.concat(vim.list_slice(lines, 2), '\n')
        return trailing_text:find('%S') ~= nil
      end

      editprompt.setup({
        cmd = 'editprompt',
        picker = 'snacks',
        before_input = function(content)
          local normalized = content:gsub('\t', '  ')
          if not normalized:find('\n$') then
            normalized = normalized .. '\n'
          end
          return normalized
        end,
        on_success = function(content, _, ctx)
          if should_save_editprompt_clipboard(content) then
            vim.fn.system('pbcopy', content)
          end
          if ctx.auto_send then
            editprompt.stash_pop_latest()
          end
        end,
        on_error = function(_, _, result)
          vim.notify('editprompt failed: ' .. (result.stderr or 'unknown error'), vim.log.levels.ERROR)
        end,
      })
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
    'vim-skk/skkeleton',
    enabled = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'skk-dev/dict', lazy = true },
      { 'delphinus/skkeleton_indicator.nvim' },
    },
    event = { 'InsertEnter' },
    init = function()
      vim.keymap.set({ 'i' }, '<C-j>', '<Plug>(skkeleton-toggle)')
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'skkeleton-initialize-pre' },
        callback = function()
          vim.fn['skkeleton#config']({
            eggLikeNewline = true,
            globalDictionaries = {
              vim.fn.stdpath('cache') .. '/lazy/dict/SKK-JISYO.L',
            },
          })
        end,
      })
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'DenopsPluginPost:skkeleton' },
        callback = function()
          vim.fn['skkeleton#initialize']()
        end,
      })
    end,
    config = function()
      require('denops-lazy').load('skkeleton', { wait_load = false })
      require('skkeleton_indicator').setup({
        border = 'rounded',
        eijiHlName = 'LineNr',
        hiraHlName = 'String',
        kataHlName = 'Todo',
        hankataHlName = 'Special',
        zenkakuHlName = 'LineNr',
      })
    end,
  },
}
