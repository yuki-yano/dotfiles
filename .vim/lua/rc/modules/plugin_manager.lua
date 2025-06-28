local misc_icons = require('rc.modules.font').misc_icons

local M = {}

local function confirm(manager)
  return vim.fn.confirm('Install ' .. manager .. ' or Launch Neovim immediately', '&Yes\n&No', 1) == 1
end

local lazy_enabled = false

local function install_lazy(path)
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    path,
  })
end

local lazy_init_default_opts = {
  lazy_path = vim.fn.stdpath('cache') .. '/lazy/lazy.nvim',
}

M.lazy_init = function(opts)
  opts = vim.tbl_deep_extend('force', lazy_init_default_opts, opts or {})
  local lazy_path = opts.lazy_path
  local installed_lazy = vim.loop.fs_stat(lazy_path)

  if installed_lazy then
    lazy_enabled = true
    vim.opt.rtp:prepend(lazy_path)
  elseif confirm('lazy.nvim') then
    install_lazy(lazy_path)
    lazy_enabled = true
    vim.opt.rtp:prepend(lazy_path)
  end
end

local lazy_setup_default_opts = {
  root = vim.fn.stdpath('cache') .. '/lazy',
  defaults = {
    lazy = true,
  },
  concurrency = 10,
  install = {
    colorscheme = { vim.env.NVIM_COLORSCHEME },
  },
  checker = {
    enable = true,
    concurrency = 100,
  },
  dev = { path = '~/repos/github.com/yuki-yano' },
  ui = {
    border = 'rounded',
    icons = {
      lazy = misc_icons.lazy .. ' ',
      runtime = misc_icons.vim,
      cmd = misc_icons.cmd,
      import = misc_icons.file,
      ft = misc_icons.folder,
    },
  },
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'editorconfig',
        'gzip',
        'man',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'osc52',
        'rplugin',
        'spellfile',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}

M.lazy_setup = function(opts)
  if not lazy_enabled then
    return
  end

  opts = vim.tbl_deep_extend('force', lazy_setup_default_opts, opts or {})
  require('lazy').setup('plugins', opts)
end

return M
