local util = require('lspconfig.util')

return {
  root_dir = util.root_pattern('astro.config.mjs', 'astro.config.ts'),
  filetypes = { 'astro' },
}
