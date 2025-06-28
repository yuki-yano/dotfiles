vim.cmd('silent! colorscheme ' .. vim.env.NVIM_COLORSCHEME)

-- Setup UI handlers
require('rc.postload.ui').setup_focus_handlers()
