local util = require('lspconfig.util')
local config = require('vtsls.lspconfig')

local filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

local function find_node_root(fname)
  return util.root_pattern('package.json', 'pnpm-workspace.yaml')(fname)
end

config.default_config.filetypes = filetypes
config.default_config.single_file_support = false

local original_root_dir = config.default_config.root_dir

config.default_config.root_dir = function(fname)
  if vim.env.TS_RUNTIME == 'deno' then
    return nil
  end

  local node_root = find_node_root(fname)
  if node_root then
    return node_root
  end

  if original_root_dir then
    return original_root_dir(fname)
  end

  return nil
end

return config
