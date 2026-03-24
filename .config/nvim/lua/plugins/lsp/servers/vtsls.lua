local util = require('lspconfig.util')
local plugin_utils = require('rc.modules.plugin_utils')
local server_util = require('plugins.lsp.servers.util')

local vtsls = require('vtsls').lspconfig
local default_config = vim.deepcopy(vtsls.default_config or {})
local original_on_attach = default_config.on_attach

local filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

local function find_deno_root(bufnr)
  return vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
end

local function find_node_root(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return
  end
  return util.root_pattern('pnpm-workspace.yaml', 'package.json')(name)
end

local function resolve_default_root(bufnr)
  local root_dir = default_config.root_dir
  if type(root_dir) == 'function' then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == '' then
      return
    end
    return root_dir(name)
  end
end

default_config.filetypes = filetypes
default_config.single_file_support = false
default_config.root_dir = function(bufnr, on_dir)
  if vim.env.TS_RUNTIME == 'deno' then
    return
  end

  if find_deno_root(bufnr) then
    return
  end

  if plugin_utils.is_node_repo(bufnr) then
    local node_root = find_node_root(bufnr)
    if node_root then
      on_dir(node_root)
      return
    end
  end

  local fallback = resolve_default_root(bufnr)
  if fallback then
    on_dir(fallback)
  end
end

default_config.on_attach = function(client, bufnr)
  if original_on_attach then
    pcall(original_on_attach, client, bufnr)
  end

  server_util.ensure_organize_import_command()

  server_util.set_format_keymap(bufnr, {
    desc = 'Format with Eslint & null-ls',
    before_format = function()
      if vim.fn.exists(':EslintFixAll') == 2 then
        vim.cmd('EslintFixAll')
      end
    end,
    filter = function(lsp_client)
      return lsp_client.name == 'null-ls'
    end,
  })
end

return default_config
