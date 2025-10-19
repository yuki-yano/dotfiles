local util = require('lspconfig.util')
local config = require('vtsls').lspconfig
local uv = vim.uv or vim.loop
local path = util.path

local filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

local function find_node_root(fname)
  return util.root_pattern('package.json', 'pnpm-workspace.yaml')(fname)
end

local function find_deno_root(fname)
  return util.root_pattern('deno.json', 'deno.jsonc')(fname)
end

local function has_deno_config(root)
  if not root then
    return false
  end

  local candidates = { 'deno.json', 'deno.jsonc' }
  for _, name in ipairs(candidates) do
    local file_path
    if path and path.join then
      file_path = path.join(root, name)
    else
      file_path = root .. '/' .. name
    end
    local stat = uv.fs_stat(file_path)
    if stat and stat.type == 'file' then
      return true
    end
  end

  return false
end

config.default_config.filetypes = filetypes
config.default_config.single_file_support = false

local original_root_dir = config.default_config.root_dir
local original_on_new_config = config.default_config.on_new_config

config.default_config.root_dir = function(fname)
  if vim.env.TS_RUNTIME == 'deno' then
    return nil
  end

  if find_deno_root(fname) then
    return nil
  end

  local node_root = find_node_root(fname)
  if node_root then
    return node_root
  end

  if original_root_dir then
    local root = original_root_dir(fname)
    if root then
      local package_json
      if path and path.join then
        package_json = path.join(root, 'package.json')
      else
        package_json = root .. '/package.json'
      end
      local package_stat = uv.fs_stat(package_json)
      if package_stat and package_stat.type == 'file' then
        return root
      end
    end
  end

  return nil
end

config.default_config.on_new_config = function(new_config, new_root_dir)
  if original_on_new_config then
    pcall(original_on_new_config, new_config, new_root_dir)
  end

  if has_deno_config(new_root_dir) then
    new_config.enabled = false
  end
end

return config
