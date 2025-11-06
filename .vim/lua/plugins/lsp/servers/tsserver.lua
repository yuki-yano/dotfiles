local server_util = require('plugins.lsp.servers.util')

return {
  enable = false,
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = {
    'package.json',
  },
  workspace_required = true,
  on_attach = function(_, bufnr)
    server_util.ensure_organize_import_command()

    server_util.set_format_keymap(bufnr, {
      desc = 'Format with Eslint & null-ls',
      before_format = function()
        if vim.fn.exists(':EslintFixAll') == 2 then
          vim.cmd('EslintFixAll')
        end
      end,
      filter = function(client)
        return client.name == 'null-ls'
      end,
    })
  end,
}
