local util = require('lspconfig.util')

local filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

local function find_node_root(fname)
  return util.root_pattern('package.json', 'pnpm-workspace.yaml', 'yarn.lock', 'lerna.json')(fname)
end

local function find_deno_root(fname)
  return util.root_pattern('deno.json', 'deno.jsonc')(fname)
end

return {
  filetypes = filetypes,
  root_dir = function(fname)
    local node_root = find_node_root(fname)
    if not node_root then
      return nil
    end

    local deno_root = find_deno_root(fname)
    if deno_root then
      local normalized_deno_root = vim.fs.normalize(deno_root)
      local normalized_file_dir = vim.fs.dirname(vim.fs.normalize(fname))

      if normalized_file_dir and vim.startswith(normalized_file_dir, normalized_deno_root) then
        return nil
      end
    end

    return node_root
  end,
  single_file_support = false,
}
