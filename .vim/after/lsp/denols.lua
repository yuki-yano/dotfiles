local is_node_repo = require('rc.modules.plugin_utils').is_node_repo

return {
  root_dir = function(bufnr, callback)
    if not is_node_repo(bufnr) then
      callback(vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))))
    end
  end,
  single_file_support = true,
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
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
}
