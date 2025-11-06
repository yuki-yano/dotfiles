local util = require('lspconfig.util')
local server_util = require('plugins.lsp.servers.util')

return {
  filetypes = { 'astro' },
  root_dir = util.root_pattern('astro.config.mjs', 'astro.config.ts'),
  on_attach = function(_, bufnr)
    server_util.set_format_keymap(bufnr, {
      desc = 'Format with null-ls/astro',
      filter = function(client)
        return client.name == 'null-ls' or client.name == 'astro'
      end,
    })
  end,
}
