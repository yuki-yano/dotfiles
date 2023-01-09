if vim.tbl_contains(vim.fn.getcompletion('', 'color'), vim.env.NVIM_COLORSCHEME) then
  vim.cmd('colorscheme ' .. vim.env.NVIM_COLORSCHEME)
end
