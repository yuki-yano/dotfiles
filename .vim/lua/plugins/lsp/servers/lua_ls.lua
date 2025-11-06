local server_util = require('plugins.lsp.servers.util')

return {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      completion = { callSnippet = 'Replace' },
      format = { enable = false },
      hint = { enable = true },
      telemetry = { enable = false },
      workspace = { checkThirdParty = false },
    },
  },
  on_attach = function(_, bufnr)
    server_util.set_format_keymap(bufnr, {
      desc = 'Format Lua with null-ls',
      filter = function(client)
        return client.name == 'null-ls'
      end,
    })
  end,
}
