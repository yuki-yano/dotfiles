local plugin_utils = require('rc.modules.plugin_utils')
local server_util = require('plugins.lsp.servers.util')

local filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

local function find_deno_root(bufnr)
  return vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
end

local function default_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return
  end
  return vim.fs.dirname(vim.fs.normalize(name))
end

return {
  filetypes = filetypes,
  single_file_support = true,
  root_dir = function(bufnr, on_dir)
    if plugin_utils.is_node_repo(bufnr) then
      return
    end

    local deno_root = find_deno_root(bufnr)
    if deno_root then
      on_dir(deno_root)
      return
    end

    local fallback = default_dir(bufnr)
    if fallback then
      on_dir(fallback)
    end
  end,
  init_options = {
    lint = true,
    unstable = true,
    documentPreloadLimit = 0,
    suggest = {
      completeFunctionCalls = true,
      names = true,
      paths = true,
      autoImports = true,
      imports = {
        autoDiscover = true,
        hosts = vim.empty_dict(),
      },
    },
  },
  on_attach = function(_, bufnr)
    server_util.set_format_keymap(bufnr, {
      desc = 'Format with denols',
      filter = function(client)
        return client.name == 'denols'
      end,
    })
  end,
}
