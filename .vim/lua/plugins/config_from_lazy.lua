-- Cache base settings by using lazy.nvim plugin loading
require('rc.options')
require('rc.func')
require('rc.highlight')
require('rc.extui')

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = { 'VeryLazy' },
  callback = function()
    require('rc.keymaps')
  end,
})

return {}
