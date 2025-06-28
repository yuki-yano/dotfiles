-- Cache base settings by using lazy.nvim plugin loading
require('rc.setup.options')
require('rc.setup.func')
require('rc.setup.highlight')
require('rc.setup.extui')

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = { 'VeryLazy' },
  callback = function()
    require('rc.setup.keymaps')
    require('rc.setup.ui')
  end,
})

return {}
