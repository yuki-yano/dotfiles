vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax enable]])

-- Encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'utf-8', 'sjis', 'cp932', 'euc-jp' }
vim.opt.fileformats = { 'unix', 'mac', 'dos' }
vim.cmd.termencoding = 'utf-8'

-- Neovim
vim.opt.inccommand = 'nosplit'
vim.opt.pumblend = 10
vim.opt.splitkeep = 'screen'
vim.opt.laststatus = 3

-- Appearance
vim.cmd([[language messages C]])
vim.cmd([[language time C]])
vim.opt.background = 'dark'
vim.opt.belloff = 'all'
vim.opt.cmdheight = 1
vim.opt.concealcursor = 'nc'
vim.opt.diffopt = { 'internal', 'filler', 'algorithm:histogram', 'indent-heuristic', 'vertical' }
vim.opt.display = 'lastline'
vim.opt.fillchars = { diff = '/', eob = ' ' }
vim.opt.foldtext = ''
vim.opt.helplang = 'ja'
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.list = true
vim.opt.listchars = { tab = '^ ', trail = '_', extends = '>', precedes = '<' }
vim.opt.matchpairs:append('<:>')
vim.opt.matchtime = 1
vim.opt.number = true
vim.opt.pumheight = 40
vim.opt.relativenumber = true
vim.opt.scrolloff = 5
vim.opt.shortmess:append('I')
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.spellcapcheck = ''
vim.opt.spelllang = { 'en', 'cjk' }
vim.opt.synmaxcol = 300
vim.opt.termguicolors = true
vim.opt.virtualedit = 'all'
-- NOTE: This is a workaround for treesitter flashing
-- vim.g._ts_force_sync_parsing = true
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinNew', 'WinClosed', 'TabEnter' }, {
  group = vim.api.nvim_create_augroup('ts_toggle_sync_parsing', {}),
  callback = function(ctx)
    local function exec()
      local wins = vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())
      local bufs = {}
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if bufs[buf] == true then
          local parsable = pcall(vim.treesitter.get_parser, buf)
          if parsable then
            vim.g._ts_force_sync_parsing = true
            return
          end
          -- set to false to avoid multiple tests on the availability of parser
          bufs[buf] = false
        end
        if bufs[buf] == nil then
          bufs[buf] = true
        end
      end
      vim.g._ts_force_sync_parsing = false
    end

    if ctx.event == 'WinClosed' then
      return vim.schedule(exec)
    end
    return exec()
  end,
})

-- Indent
vim.opt.autoindent = true
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.startofline = false
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

local function set_format_options()
  vim.opt.formatoptions:remove('c')
  vim.opt.formatoptions:remove('r')
  vim.opt.formatoptions:remove('o')
  vim.opt.formatoptions:append('jBn')
end
vim.api.nvim_create_autocmd({ 'FileType', 'BufReadPost', 'WinEnter' }, { pattern = '*', callback = set_format_options })

-- viminfo
vim.opt.viminfo = [['100,:100]]

-- Search
vim.opt.ignorecase = true
vim.opt.regexpengine = 2
vim.opt.smartcase = true

-- Completion
vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'noselect' }

-- Command
vim.opt.wildignorecase = true
vim.opt.wildmenu = true
vim.opt.wildmode = { 'longest:full', 'full' }
vim.opt.wrapscan = true

-- Fold
vim.opt.foldcolumn = '1'
vim.opt.foldenable = true
vim.opt.foldmethod = 'manual'

-- Sign
vim.opt.signcolumn = 'yes'

-- Diff
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = '*',
  callback = function()
    if vim.wo.diff then
      vim.cmd([[diffupdate]])
    end
  end,
})

-- Undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('cache') .. '/undo'

-- Swap
vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath('cache') .. '/swap'
vim.opt.updatetime = 500

-- Term
vim.opt.shell = 'zsh'
vim.opt.ttyfast = true
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10
vim.opt.lazyredraw = false

-- Mouse
vim.opt.mouse = 'a'
-- Should it be run? Change &mousemodel 'popup_setpos' to 'extend'.
-- Need to use statuscolumn
-- vim.cmd([[behave xterm]])

-- Autoread
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained' }, {
  pattern = '*',
  callback = function()
    vim.cmd([[checktime]])
  end,
})

-- Remote Plugin
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- Use UltiSnips when coc.nvim
if vim.env.LSP ~= 'coc' then
  vim.g.loaded_python3_provider = 0
end

-- Conceal
-- TODO: move ftplugin
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'json', 'jsonc', 'markdown', 'dockerfile' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Fold
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'typescript', 'typescriptreact', 'lua', 'vim', 'markdown' },
  callback = function()
    vim.opt_local.foldlevel = 100
  end,
})

-- Cmdwin
vim.opt.cedit = '<C-c>'
