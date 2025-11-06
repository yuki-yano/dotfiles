local server_util = require('plugins.lsp.servers.util')

return {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
  on_attach = function(_, bufnr)
    server_util.set_format_keymap(bufnr, {
      desc = 'Format JSON with null-ls',
      filter = function(client)
        return client.name == 'null-ls'
      end,
    })
  end,
}
