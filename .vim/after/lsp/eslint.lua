return {
  root_dir = function(bufnr, callback)
    local path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)))
    local eslint_config_files = {
      -- Flat Config (ESLint v8+)
      'eslint.config.js',
      'eslint.config.cjs',
      'eslint.config.mjs',
      'eslint.config.ts',
      'eslint.config.mts',
      'eslint.config.cts',
      -- Legacy .eslintrc.* formats
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      '.eslintrc',
    }

    local found_dirs = vim.fs.find(eslint_config_files, {
      upward = true,
      path = path,
    })
    if #found_dirs > 0 then
      return callback(found_dirs[1])
    end
  end,
}
