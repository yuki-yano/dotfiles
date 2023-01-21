local get_lsp_lines_status = require('plugin_utils').get_lsp_lines_status

return {
  {
    'nvim-lualine/lualine.nvim',
    event = { 'InsertEnter', 'CursorHold', 'FocusLost', 'BufRead', 'BufNewFile' },
    init = function()
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
    end,
    config = function()
      local theme_table = {
        ['gruvbox-material'] = function()
          local custom_gruvbox = require('lualine.themes.gruvbox-material')
          custom_gruvbox.normal.a.fg = '#32302F'
          custom_gruvbox.normal.a.bg = '#7DAEA3'
          custom_gruvbox.insert.a.fg = '#32302F'
          custom_gruvbox.insert.a.bg = '#D8A657'
          custom_gruvbox.visual.a.fg = '#32302F'
          custom_gruvbox.visual.a.bg = '#D3869B'
          custom_gruvbox.replace.a.fg = '#32302F'
          custom_gruvbox.replace.a.bg = '#EA6962'
          return custom_gruvbox
        end,
        ['tokyonight'] = function()
          return 'tokyonight'
        end,
      }

      local function modified_buffers()
        local modified_background_buffers = vim.tbl_filter(function(bufnr)
          return vim.api.nvim_buf_is_valid(bufnr)
            and vim.api.nvim_buf_is_loaded(bufnr)
            and vim.api.nvim_buf_get_option(bufnr, 'buftype') == ''
            and vim.api.nvim_buf_get_option(bufnr, 'modifiable')
            and vim.api.nvim_buf_get_name(bufnr) ~= ''
            and vim.api.nvim_buf_get_number(bufnr) ~= vim.api.nvim_get_current_buf()
            and vim.api.nvim_buf_get_option(bufnr, 'modified')
        end, vim.api.nvim_list_bufs())

        if #modified_background_buffers > 0 then
          return '!' .. #modified_background_buffers
        else
          return ''
        end
      end

      local function lsp_line_mode()
        local mode = ''
        if get_lsp_lines_status() == 'current' then
          mode = 'C'
        elseif get_lsp_lines_status() == 'all' then
          mode = 'A'
        elseif get_lsp_lines_status() == 'none' then
          mode = 'N'
        end
        return 'LspLines: [' .. mode .. ']'
      end

      require('lualine').setup({
        options = {
          theme = theme_table[vim.env.NVIM_COLORSCHEME](),
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = { { 'filename', path = 1 }, modified_buffers },
          lualine_x = {
            { 'diagnostics', symbols = { error = ' ', warn = '  ', info = ' ', hint = ' ' } },
            { lsp_line_mode },
            { 'filetype', colored = true, icon_only = false },
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        extensions = {
          'aerial',
          'fern',
          'fzf',
          'man',
          'quickfix',
          'toggleterm',
        },
      })
    end,
  },
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'tiagovla/scope.nvim' },
    event = { 'BufRead' },
    init = function()
      vim.keymap.set({ 'n' }, '<Plug>(ctrl-n)', '<Cmd>BufferLineCycleNext<CR>')
      vim.keymap.set({ 'n' }, '<Plug>(ctrl-p)', '<Cmd>BufferLineCyclePrev<CR>')
    end,
    config = function()
      local black = '#32302F'
      local red = '#EA6962'
      local green = '#A9B665'
      local yellow = '#D8A657'
      local blue = '#7DAEA3'
      local magenta = '#D3869B'
      local cyan = '#89B482'
      local white = '#D4BE98'
      local grey = '#807569'
      local background = '#1D2021'
      local empty = '#1C1C1C'
      local info = '#FFFFAF'
      local vert_split = '#504945'

      require('scope').setup()

      local coc_diagnostic_results = {}
      require('bufferline').setup({
        options = {
          -- mode = 'tabs',
          numbers = 'ordinal',
          buffer_close_icon = '×',
          show_close_icon = false,
          diagnostics = vim.env.LSP == 'nvim' and 'nvim_lsp' or 'coc',
          show_buffer_default_icon = false,
          separator_style = { '|', ' ' },
          modified_icon = '[+]',
          diagnostics_indicator = function(_, _, diagnostics_dict, context)
            local error = ''
            local warning = ''

            if vim.env.LSP == 'nvim' then
              if diagnostics_dict.error then
                error = ' ' .. diagnostics_dict.error
              end

              if diagnostics_dict.warning then
                warning = '  ' .. diagnostics_dict.warning
              end
            else
              local buf = vim.api.nvim_get_current_buf()
              if context.buffer.id ~= buf then
                return coc_diagnostic_results[context.buffer.id] or ''
              end

              local coc_diagnostic_info = vim.api.nvim_buf_get_var(buf, 'coc_diagnostic_info')

              if coc_diagnostic_info.error ~= 0 then
                error = ' ' .. coc_diagnostic_info.error
              end

              if coc_diagnostic_info.warning ~= 0 then
                warning = '  ' .. coc_diagnostic_info.warning
              end
            end

            local result = ''
            if error ~= '' then
              result = error
            end
            if warning ~= '' then
              result = result .. ' ' .. warning
            end

            return result
          end,
          offsets = {
            {
              filetype = 'fern',
              text = 'Fern',
              highlight = 'Directory',
              separator = true,
            },
          },
          custom_areas = {
            -- TODO: Format the display of tab information
            left = function()
              local count = #vim.fn.gettabinfo()

              if count == 1 then
                return {}
              else
                return {
                  {
                    text = '▎',
                    fg = yellow,
                    bg = empty,
                  },
                  {
                    text = ' ' .. vim.fn.tabpagenr() .. '/' .. vim.fn.tabpagenr('$') .. ' ',
                    fg = white,
                    bg = empty,
                  },
                }
              end
            end,
          },
        },
        highlights = {
          fill = {
            fg = grey,
            bg = empty,
          },
          background = {
            fg = grey,
            bg = background,
          },
          tab = {
            fg = grey,
            bg = black,
          },
          buffer = {
            fg = grey,
            bg = black,
          },
          close_button = {
            fg = grey,
            bg = background,
          },
          numbers = {
            fg = grey,
            bg = background,
          },
          separator = {
            fg = background,
            bg = background,
          },
          duplicate = {
            fg = green,
            bg = background,
            bold = false,
            italic = false,
          },
          diagnostic = {
            fg = white,
            bg = black,
          },
          error = {
            fg = grey,
            bg = background,
          },
          warning = {
            fg = grey,
            bg = background,
          },
          info = {
            fg = grey,
            bg = background,
          },
          hint = {
            fg = grey,
            bg = background,
          },
          error_diagnostic = {
            fg = red,
            bg = background,
          },
          warning_diagnostic = {
            fg = yellow,
            bg = background,
          },
          info_diagnostic = {
            fg = info,
            bg = background,
          },
          hint_diagnostic = {
            fg = white,
            bg = background,
          },
          modified = {
            fg = yellow,
            bg = background,
          },
          tab_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          buffer_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          close_button_selected = {
            fg = white,
            bg = black,
            bold = false,
            italic = false,
          },
          numbers_selected = {
            fg = white,
            bg = black,
            bold = false,
            italic = false,
          },
          indicator_selected = {
            fg = blue,
            bg = black,
            bold = true,
            italic = false,
          },
          duplicate_selected = {
            fg = green,
            bg = black,
            bold = false,
            italic = false,
          },
          error_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          warning_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          info_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          hint_selected = {
            fg = white,
            bg = black,
            bold = true,
            italic = false,
          },
          error_diagnostic_selected = {
            fg = red,
            bg = black,
            bold = false,
            italic = false,
          },
          warning_diagnostic_selected = {
            fg = yellow,
            bg = black,
            bold = false,
            italic = false,
          },
          info_diagnostic_selected = {
            fg = info,
            bg = black,
            bold = false,
            italic = false,
          },
          hint_diagnostic_selected = {
            fg = white,
            bg = black,
            bold = false,
            italic = false,
          },
          modified_selected = {
            fg = yellow,
            bg = black,
            bold = false,
            italic = false,
          },
          buffer_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          close_button_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          numbers_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          indicator_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          duplicate_visible = {
            fg = green,
            bg = background,
            bold = false,
            italic = false,
          },
          error_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          warning_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          info_visible = {
            fg = info,
            bg = background,
            bold = false,
            italic = false,
          },
          hint_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          error_diagnostic_visible = {
            fg = red,
            bg = background,
            bold = false,
            italic = false,
          },
          warning_diagnostic_visible = {
            fg = yellow,
            bg = background,
            bold = false,
            italic = false,
          },
          info_diagnostic_visible = {
            fg = info,
            bg = background,
            bold = false,
            italic = false,
          },
          hint_diagnostic_visible = {
            fg = white,
            bg = background,
            bold = false,
            italic = false,
          },
          modified_visible = {
            fg = yellow,
            bg = background,
            bold = false,
            italic = false,
          },
          offset_separator = {
            fg = vert_split,
            bg = background,
          },
        },
      })
    end,
  },
  {
    'b0o/incline.nvim',
    dependencies = {
      { 'kyazdani42/nvim-web-devicons' },
      { 'SmiteshP/nvim-navic' },
    },
    event = { 'VeryLazy' },
    config = function()
      require('incline').setup({
        window = {
          width = 'fit',
          placement = { horizontal = 'right', vertical = 'top' },
          margin = {
            horizontal = { left = 1, right = 0 },
            vertical = { bottom = 0, top = 1 },
          },
          padding = { left = 1, right = 1 },
          padding_char = ' ',
          winhighlight = {
            Normal = 'NormalFloat',
          },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          local icon, color = require('nvim-web-devicons').get_icon_color(filename)
          local nav = {}

          if vim.env.LSP == 'nvim' then
            local data = require('nvim-navic').get_data(props.buf)

            for _, v in ipairs(data) do
              table.insert(nav, { '  ' })
              table.insert(nav, {
                v.icon,
                group = 'CmpItemKind' .. v.type,
              })
              table.insert(nav, { v.name })
            end
          else
            local ok, nav_var = pcall(function()
              return vim.api.nvim_buf_get_var(props.buf, 'coc_nav')
            end)
            if ok then
              for _, v in ipairs(nav_var) do
                table.insert(nav, { '  ' })
                table.insert(nav, { v.label, group = v.highlight })
                table.insert(nav, { v.name })
              end
            end
          end

          return {
            { icon, guifg = color },
            { ' ' },
            { filename },
            nav,
          }
        end,
      })
    end,
  },
  -- {
  --   'luukvbaal/statuscol.nvim',
  --   event = { 'BufRead' },
  --   config = function()
  --     require('statuscol').setup({
  --       setopt = true,
  --     })
  --   end,
  -- },
  {
    'levouh/tint.nvim',
    event = { 'BufRead' },
    config = function()
      require('tint').setup({
        highlight_ignore_patterns = {
          'WinSeparator',
          'VertSplit',
          'Status.*',
        },
        window_ignore_function = function(winid)
          local bufid = vim.api.nvim_win_get_buf(winid)
          local buftype = vim.api.nvim_buf_get_option(bufid, 'buftype')
          local floating = vim.api.nvim_win_get_config(winid).relative ~= ''

          return buftype == 'terminal' or floating
        end,
      })
    end,
  },
  {
    'petertriho/nvim-scrollbar',
    dependencies = {
      {
        'petertriho/nvim-scrollbar',
        'lewis6991/gitsigns.nvim',
      },
    },
    event = { 'BufRead' },
    config = function()
      require('scrollbar').setup({
        handle = {
          color = '#3A3A3A',
        },
        handlers = {
          search = true,
          cursor = false,
          diagnostic = true,
        },
        marks = {
          Search = {
            text = { '-', '=' },
            priority = 5,
            color = '#00AFAF',
          },
          Error = {
            priority = 1,
            highlight = 'DiagnosticSignError',
          },
          Warn = {
            priority = 2,
            highlight = 'DiagnosticSignWarn',
          },
          Info = {
            priority = 3,
            highlight = 'DiagnosticSignInfo',
          },
          Hint = {
            priority = 4,
            highlight = 'DiagnosticSignHint',
          },
        },
      })

      require('scrollbar.handlers.search').setup()
      require('scrollbar.handlers.gitsigns').setup()
    end,
  },
  {
    'gen740/SmoothCursor.nvim',
    event = { 'BufRead' },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#7DAEA3', bg = 'NONE' })
        end,
      })
    end,
    config = function()
      require('SmoothCursor').setup({
        cursor = '>',
        priority = 10,
        disabled_filetypes = {
          'lazy',
          'aerial',
          'toggleterm',
        },
        disable_float_win = true,
      })
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    cmd = { 'IndentBlanklineToggle' },
    init = function()
      vim.g.indent_blankline_enabled = false
      vim.keymap.set({ 'n' }, '<Leader>i', '<Cmd>IndentBlanklineToggle!<CR>')
    end,
    config = function()
      require('indent_blankline').setup({
        show_current_context = true,
        show_current_context_start = true,
      })
    end,
  },
  -- {
  --   "luukvbaal/statuscol.nvim",
  --   event = { 'BufRead' },
  --   config = function()
  --     require("statuscol").setup()
  --   end
  -- },
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPost' },
    config = function()
      require('todo-comments').setup({
        keywords = {
          FIX = { icon = '', color = '#E98989', alt = { 'FIXME', 'BUG', 'ISSUE' } },
          TODO = { icon = '', color = '#B4BE82' },
          WARN = { icon = '', color = '#FFAF60', alt = { 'WARNING', 'XXX' } },
          NOTE = { icon = '', color = '#7DAEA3', alt = { 'INFO' } },
          TEST = { icon = '', color = '#7DAEA3', alt = { 'TESTING', 'PASSED', 'FAILED' } },
        },
      })
    end,
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = { 'FocusLost', 'CursorHold' },
    init = function()
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'UfoFoldVirtText', { fg = '#74A097' })
        end,
      })
    end,
    config = function()
      local enable_file_type = { 'typescript', 'typescriptreact', 'vim' }

      local function ufo_width()
        local width = 0
        for winnr = 1, vim.fn.winnr('$') do
          local win_width = vim.api.nvim_win_get_width(vim.fn.win_getid(winnr))
          width = win_width > width and win_width or width
        end
        return width
      end

      require('ufo').setup({
        open_fold_hl_timeout = 0,
        provider_selector = function(_, filetype, _)
          if vim.tbl_contains(enable_file_type, filetype) then
            return { 'treesitter', 'indent' }
          end

          return ''
        end,
        preview = {
          win_config = {
            winhighlight = 'Normal:Normal,FloatBorder:Normal',
            winblend = 0,
          },
          mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
          },
        },
        enable_fold_and_virt_text = true,
        fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
          local new_virt_text = {}
          local suffix = (' ↲ %d '):format(end_lnum - lnum)
          local suf_width = vim.fn.strdisplaywidth(suffix)
          local target_width = width - suf_width
          local cur_width = 0

          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = vim.fn.strdisplaywidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(new_virt_text, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(new_virt_text, { chunk_text, hl_group })
              chunk_width = vim.fn.strdisplaywidth(chunk_text)
              if cur_width + chunk_width < target_width then
                suffix = suffix .. ('.'):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end

          table.insert(new_virt_text, { suffix, 'UfoFoldVirtText' })
          table.insert(new_virt_text, { ('.'):rep(ufo_width()), 'Comment' })
          return new_virt_text
        end,
      })
    end,
  },
  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle' },
    init = function()
      vim.keymap.set({ 'n' }, '<Leader>a', '<Cmd>AerialToggle!<CR>')
      vim.keymap.set({ 'n' }, '<Leader>A', '<Cmd>AerialToggle<CR>')
    end,
    config = function()
      require('aerial').setup({
        backends = { 'treesitter', 'markdown' },
        filter_kind = {
          'Class',
          'Constructor',
          'Enum',
          'Function',
          'Interface',
          'Module',
          'Method',
          'Struct',
          'Variable',
        },
        layout = {
          win_opts = {
            winblend = 10,
          },
          default_direction = 'float',
          placement = 'edge',
        },
        float = {
          border = 'rounded',
          relative = 'win',
          max_height = 0.9,
          height = nil,
          min_height = { 8, 0.1 },

          override = function(conf, source_winid)
            conf.anchor = 'NE'
            conf.col = vim.fn.winwidth(source_winid)
            conf.row = 0
            return conf
          end,
        },
      })
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    event = { 'BufRead' },
    config = function()
      local ccc = require('ccc')
      local ColorInput = require('ccc.input')
      local convert = require('ccc.utils.convert')

      local RgbHslCmykInput = setmetatable({
        name = 'RGB/HSL/CMYK',
        max = { 1, 1, 1, 360, 1, 1, 1, 1, 1, 1 },
        min = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        delta = { 1 / 255, 1 / 255, 1 / 255, 1, 0.01, 0.01, 0.005, 0.005, 0.005, 0.005 },
        bar_name = { 'R', 'G', 'B', 'H', 'S', 'L', 'C', 'M', 'Y', 'K' },
      }, { __index = ColorInput })

      function RgbHslCmykInput.format(n, i)
        if i <= 3 then
          -- RGB
          n = n * 255
        elseif i == 5 or i == 6 then
          -- S or L of HSL
          n = n * 100
        elseif i >= 7 then
          -- CMYK
          return ('%5.1f%%'):format(math.floor(n * 200) / 2)
        end
        return ('%6d'):format(n)
      end

      function RgbHslCmykInput.from_rgb(RGB)
        local HSL = convert.rgb2hsl(RGB)
        local CMYK = convert.rgb2cmyk(RGB)
        local R, G, B = unpack(RGB)
        local H, S, L = unpack(HSL)
        local C, M, Y, K = unpack(CMYK)
        return { R, G, B, H, S, L, C, M, Y, K }
      end

      function RgbHslCmykInput.to_rgb(value)
        return { value[1], value[2], value[3] }
      end

      function RgbHslCmykInput:_set_rgb(RGB)
        self.value[1] = RGB[1]
        self.value[2] = RGB[2]
        self.value[3] = RGB[3]
      end

      function RgbHslCmykInput:_set_hsl(HSL)
        self.value[4] = HSL[1]
        self.value[5] = HSL[2]
        self.value[6] = HSL[3]
      end

      function RgbHslCmykInput:_set_cmyk(CMYK)
        self.value[7] = CMYK[1]
        self.value[8] = CMYK[2]
        self.value[9] = CMYK[3]
        self.value[10] = CMYK[4]
      end

      function RgbHslCmykInput:callback(index, new_value)
        self.value[index] = new_value
        local v = self.value
        if index <= 3 then
          local RGB = { v[1], v[2], v[3] }
          local HSL = convert.rgb2hsl(RGB)
          local CMYK = convert.rgb2cmyk(RGB)
          self:_set_hsl(HSL)
          self:_set_cmyk(CMYK)
        elseif index <= 6 then
          local HSL = { v[4], v[5], v[6] }
          local RGB = convert.hsl2rgb(HSL)
          local CMYK = convert.rgb2cmyk(RGB)
          self:_set_rgb(RGB)
          self:_set_cmyk(CMYK)
        else
          local CMYK = { v[7], v[8], v[9], v[10] }
          local RGB = convert.cmyk2rgb(CMYK)
          local HSL = convert.rgb2hsl(RGB)
          self:_set_rgb(RGB)
          self:_set_hsl(HSL)
        end
      end

      ccc.setup({
        bar_len = 50,
        bar_char = '█',
        point_char = '|',
        highlighter = {
          auto_enable = true,
          max_byte = 1024 * 1024,
        },
        pickers = {
          ccc.picker.hex,
          ccc.picker.css_rgb,
          ccc.picker.css_hsl,
        },
        inputs = {
          RgbHslCmykInput,
        },
      })
    end,
  },
  {
    'machakann/vim-highlightedundo',
    keys = {
      { '<Plug>(highlightedundo-undo)', mode = { 'n' } },
      { '<Plug>(highlightedundo-redo)', mode = { 'n' } },
    },
    init = function()
      vim.g.enable_highlightedundo = false
      vim.g['highlightedundo#highlight_mode'] = 2

      if vim.g.enable_highlightedundo then
        vim.keymap.set({ 'n' }, 'u', '<Plug>(highlightedundo-undo)')
        vim.keymap.set({ 'n' }, '<C-r>', '<Plug>(highlightedundo-redo)')
      end

      local function highlightedundo_enable()
        vim.keymap.set({ 'n' }, 'u', '<Plug>(highlightedundo-undo)')
        vim.keymap.set({ 'n' }, '<C-r>', '<Plug>(highlightedundo-redo)')
      end

      local function highlightedundo_disable()
        vim.keymap.del({ 'n' }, 'u')
        vim.keymap.del({ 'n' }, '<C-r>')
      end

      local function highlightedundo_toggle()
        if vim.g.enable_highlightedundo then
          vim.g.enable_highlightedundo = false
          highlightedundo_disable()
        else
          vim.g.enable_highlightedundo = true
          highlightedundo_enable()
        end
      end

      vim.api.nvim_create_user_command('ToggleHighlightedUndo', highlightedundo_toggle, {})
    end,
  },
  {
    'machakann/vim-highlightedyank',
    event = { 'TextYankPost' },
    init = function()
      vim.g.highlightedyank_highlight_duration = 300
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { 'gruvbox-material' },
        callback = function()
          vim.api.nvim_set_hl(0, 'HighlightedyankRegion', { fg = '#E27878', bg = 'NONE' })
        end,
      })
    end,
  },
  -- {
  --   'folke/noice.nvim',
  --   dependencies = {
  --     'MunifTanjim/nui.nvim',
  --     'rcarriga/nvim-notify',
  --   },
  --   event = { 'VeryLazy' },
  --   config = function()
  --     require('noice').setup({
  --       lsp = {
  --         signature = {
  --           enabled = false,
  --         },
  --         override = {
  --           ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
  --           ['vim.lsp.util.stylize_markdown'] = true,
  --         },
  --       },
  --       presets = {
  --         command_palette = true,
  --         long_message_to_split = true,
  --       },
  --     })
  --   end,
  -- },
  {
    'anuvyklack/hydra.nvim',
    keys = {
      { 'g;', mode = { 'n' } },
      { 'g,', mode = { 'n' } },
      { '<Leader>t', mode = { 'n' } },
      { '<Leader>z', mode = { 'n' } },
    },
    config = function()
      local hydra = require('hydra')

      hydra({
        name = 'Change list',
        mode = 'n',
        body = 'g',
        heads = {
          { ';', 'g;', { desc = '<=' } },
          { ',', 'g,', { desc = '=>' } },
        },
      })

      local toggle_hint = [[
           Toggle

 _n_: %{number} Number
 _i_: %{indent} Indent
 _q_: %{quickfix} QuickFix
 _l_: %{location_list} LocationList
 _f_: %{eft} Eft
 _u_: %{highlighted_undo} HighlightedUndo
                         _<Esc>_
]]

      hydra({
        name = 'Toggle',
        hint = toggle_hint,
        mode = 'n',
        body = '<Leader>t',
        config = {
          invoke_on_body = true,
          hint = {
            position = 'middle',
            border = 'rounded',
            funcs = {
              number = function()
                if vim.o.number and vim.o.relativenumber then
                  return '[r]'
                elseif vim.o.number then
                  return '[n]'
                else
                  return '[ ]'
                end
              end,
              indent = function()
                if vim.g.indent_blankline_enabled then
                  return '[x]'
                else
                  return '[ ]'
                end
              end,
              quickfix = function()
                for _, win in ipairs(vim.fn.getwininfo()) do
                  if win.quickfix == 1 then
                    return '[x]'
                  end
                end

                return '[ ]'
              end,
              location_list = function()
                for _, win in ipairs(vim.fn.getwininfo()) do
                  if win.loclist == 1 then
                    return '[x]'
                  end
                end

                return '[ ]'
              end,
              eft = function()
                if vim.g.eft_enable then
                  return '[x]'
                else
                  return '[ ]'
                end
              end,
              highlighted_undo = function()
                if vim.g.highlightedundo_enable then
                  return '[x]'
                else
                  return '[ ]'
                end
              end,
            },
          },
        },
        heads = {
          {
            'n',
            function()
              vim.cmd([[ToggleNumber]])
            end,
            { silent = true },
          },
          {
            'i',
            function()
              vim.cmd([[IndentBlanklineToggle!]])
            end,
            { silent = true },
          },
          {
            'q',
            function()
              vim.cmd([[ToggleQuickFix]])
            end,
            { silent = true },
          },
          {
            'l',
            function()
              vim.cmd([[ToggleLocationList]])
            end,
            { silent = true },
          },
          {
            'f',
            function()
              vim.cmd([[ToggleEft]])
            end,
            { silent = true },
          },
          {
            'u',
            function()
              vim.cmd([[ToggleHighlightedundo]])
            end,
            { silent = true },
          },
          { '<Esc>', nil, { exit = true } },
        },
      })

      local fold_hint = [[
            Fold

_o_: open       _O_: open recursive
_c_: close      _C_: close recursive
_a_: toggle     _A_: toggle recursive

          Fold Count

_r_: open       _R_: open recursive
_m_: close      _M_: close recursive

            Misc

_x_: reload

                             _<Esc>_
]]

      hydra({
        name = 'Fold',
        hint = fold_hint,
        mode = 'n',
        body = '<Leader>z',
        config = {
          invoke_on_body = true,
          hint = {
            position = 'middle',
            border = 'rounded',
          },
        },
        heads = {
          { 'o', '<Cmd>normal! zo<CR>', { silent = true } },
          { 'O', '<Cmd>normal! zO<CR>', { silent = true } },
          { 'c', '<Cmd>normal! zc<CR>', { silent = true } },
          { 'C', '<Cmd>normal! zC<CR>', { silent = true } },
          { 'a', '<Cmd>normal! za<CR>', { silent = true } },
          { 'A', '<Cmd>normal! zA<CR>', { silent = true } },
          { 'r', '<Cmd>normal! zr<CR>', { silent = true } },
          { 'R', '<Cmd>normal! zR<CR>', { silent = true } },
          { 'm', '<Cmd>normal! zm<CR>', { silent = true } },
          { 'M', '<Cmd>normal! zM<CR>', { silent = true } },
          { 'x', '<Cmd>normal! zx<CR>', { silent = true } },
          { '<Esc>', nil, { exit = true } },
        },
      })
    end,
  },
  { 'ryanoasis/vim-devicons' },
  {
    'kyazdani42/nvim-web-devicons',
    config = function()
      local red = '#EA6962'
      local green = '#A9B665'
      local yellow = '#D8A657'
      local blue = '#7DAEA3'
      local magenta = '#D3869B'
      local cyan = '#89B482'
      local white = '#D4BE98'

      require('nvim-web-devicons').set_default_icon('󾩻 ', white)
      require('nvim-web-devicons').setup({
        override = {
          ['.babelrc'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Babelrc',
          },
          ['.gitignore'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'GitIgnore',
          },
          ['.vimrc'] = {
            icon = ' ',
            color = green,
            cterm_color = '29',
            name = 'Vimrc',
          },
          ['.zshenv'] = {
            icon = ' ',
            color = white,
            cterm_color = '113',
            name = 'Zshenv',
          },
          ['.zshrc'] = {
            icon = ' ',
            color = white,
            cterm_color = '113',
            name = 'Zshrc',
          },
          ['Brewfile'] = {
            icon = ' ',
            color = green,
            cterm_color = '113',
            name = 'Brewfile',
          },
          ['COMMIT_EDITMSG'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'GitCommit',
          },
          ['Dockerfile'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'Dockerfile',
          },
          ['Gemfile$'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Gemfile',
          },
          ['LICENSE'] = {
            icon = ' ',
            color = white,
            cterm_color = '179',
            name = 'LICENSE',
          },
          ['ai'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Ai',
          },
          ['bash'] = {
            icon = ' ',
            color = green,
            cterm_color = '113',
            name = 'Bash',
          },
          ['bmp'] = {
            icon = ' ',
            color = cyan,
            cterm_color = '140',
            name = 'Bmp',
          },
          ['coffee'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Coffee',
          },
          ['conf'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Conf',
          },
          ['config.ru'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'ConfigRu',
          },
          ['css'] = {
            icon = ' ',
            color = blue,
            cterm_color = '39',
            name = 'Css',
          },
          ['csv'] = {
            icon = ' ',
            color = blue,
            cterm_color = '113',
            name = 'Csv',
          },
          ['diff'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'Diff',
          },
          ['doc'] = {
            icon = '  ',
            color = blue,
            cterm_color = '25',
            name = 'Doc',
          },
          ['dockerfile'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'Dockerfile',
          },
          ['ejs'] = {
            icon = '�� ',
            color = yellow,
            cterm_color = '185',
            name = 'Ejs',
          },
          ['erb'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Erb',
          },
          ['favicon.ico'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Favicon',
          },
          ['gemspec'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Gemspec',
          },
          ['gif'] = {
            icon = ' ',
            color = cyan,
            cterm_color = '140',
            name = 'Gif',
          },
          ['git'] = {
            icon = ' ',
            color = magenta,
            cterm_color = '202',
            name = 'GitLogo',
          },
          ['go'] = {
            icon = ' ',
            color = blue,
            cterm_color = '67',
            name = 'Go',
          },
          ['graphql'] = {
            icon = ' ',
            color = magenta,
            cterm_color = '202',
            name = 'GraphQL',
          },
          ['htm'] = {
            icon = ' ',
            color = magenta,
            cterm_color = '166',
            name = 'Htm',
          },
          ['html'] = {
            icon = ' ',
            color = magenta,
            cterm_color = '202',
            name = 'Html',
          },
          ['ico'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Ico',
          },
          ['ini'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Ini',
          },
          ['jpeg'] = {
            icon = '  ',
            color = cyan,
            cterm_color = '140',
            name = 'Jpeg',
          },
          ['jpg'] = {
            icon = ' ',
            color = cyan,
            cterm_color = '140',
            name = 'Jpg',
          },
          ['js'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Js',
          },
          ['json'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'Json',
          },
          ['jsx'] = {
            icon = ' ',
            color = blue,
            cterm_color = '67',
            name = 'Jsx',
          },
          ['license'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '185',
            name = 'License',
          },
          ['lua'] = {
            icon = ' ',
            color = blue,
            cterm_color = '74',
            name = 'Lua',
          },
          ['makefile'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Makefile',
          },
          ['markdown'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '67',
            name = 'Markdown',
          },
          ['md'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '67',
            name = 'Markdown',
          },
          ['mdx'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '67',
            name = 'Mdx',
          },
          ['mjs'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '221',
            name = 'Mjs',
          },
          ['node_modules'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '161',
            name = 'NodeModules',
          },
          ['package.json'] = {
            icon = ' ',
            color = yellow,
            name = 'PackageJson',
          },
          ['package-lock.json'] = {
            icon = ' ',
            color = yellow,
            name = 'PackageLockJson',
          },
          ['pdf'] = {
            icon = '  ',
            color = red,
            cterm_color = '124',
            name = 'Pdf',
          },
          ['png'] = {
            icon = ' ',
            color = cyan,
            cterm_color = '140',
            name = 'Png',
          },
          ['psd'] = {
            icon = ' ',
            color = blue,
            cterm_color = '67',
            name = 'Psd',
          },
          ['py'] = {
            icon = '',
            color = yellow,
            cterm_color = '61',
            name = 'Py',
          },
          ['rake'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Rake',
          },
          ['Rakefile'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Rakefile',
          },
          ['rb'] = {
            icon = ' ',
            color = red,
            cterm_color = '52',
            name = 'Rb',
          },
          ['rs'] = {
            icon = ' ',
            color = white,
            cterm_color = '180',
            name = 'Rs',
          },
          ['scss'] = {
            icon = ' ',
            color = magenta,
            cterm_color = '204',
            name = 'Scss',
          },
          ['sh'] = {
            icon = ' ',
            color = white,
            cterm_color = '59',
            name = 'Sh',
          },
          ['sql'] = {
            icon = ' ',
            color = white,
            cterm_color = '188',
            name = 'Sql',
          },
          ['sqlite'] = {
            icon = ' ',
            color = white,
            cterm_color = '188',
            name = 'Sql',
          },
          ['svg'] = {
            icon = 'ﰟ ',
            color = yellow,
            cterm_color = '215',
            name = 'Svg',
          },
          ['tex'] = {
            icon = 'ﭨ ',
            color = green,
            cterm_color = '58',
            name = 'Tex',
          },
          ['toml'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Toml',
          },
          ['ts'] = {
            icon = ' ',
            color = blue,
            cterm_color = '67',
            name = 'Ts',
          },
          ['tsx'] = {
            icon = ' ',
            color = blue,
            cterm_color = '67',
            name = 'Tsx',
          },
          ['txt'] = {
            icon = '󾩻 ',
            color = green,
            cterm_color = '113',
            name = 'Txt',
          },
          ['vim'] = {
            icon = ' ',
            color = green,
            cterm_color = '29',
            name = 'Vim',
          },
          ['vue'] = {
            icon = '  ',
            color = green,
            cterm_color = '107',
            name = 'Vue',
          },
          ['webp'] = {
            icon = ' ',
            color = cyan,
            cterm_color = '140',
            name = 'Webp',
          },
          ['xml'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '173',
            name = 'Xml',
          },
          ['yaml'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Yaml',
          },
          ['yml'] = {
            icon = ' ',
            color = white,
            cterm_color = '66',
            name = 'Yml',
          },
          ['zsh'] = {
            icon = ' ',
            color = green,
            cterm_color = '113',
            name = 'Zsh',
          },
          ['.env'] = {
            icon = ' ',
            color = yellow,
            cterm_color = '226',
            name = 'Env',
          },
          ['prisma'] = {
            icon = ' ',
            color = white,
            cterm_color = 'white',
            name = 'Prisma',
          },
        },
      })
    end,
  },
}
