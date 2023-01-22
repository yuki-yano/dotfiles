-- Cache base settings by using lazy.nvim plugin loading
require('options')
require('func')
require('highlight')

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = { 'VeryLazy' },
  callback = function()
    require('keymaps')
  end,
})

return {}
