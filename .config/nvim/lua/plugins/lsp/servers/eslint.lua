return {
  root_dir = function(bufnr, on_dir)
    local path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)))
    if not path or path == '' then
      return
    end

    local eslint_config_files = {
      'eslint.config.js',
      'eslint.config.cjs',
      'eslint.config.mjs',
      'eslint.config.ts',
      'eslint.config.mts',
      'eslint.config.cts',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      '.eslintrc',
    }

    local found_configs = vim.fs.find(eslint_config_files, {
      upward = true,
      path = path,
    })

    if #found_configs > 0 then
      on_dir(vim.fs.dirname(vim.fs.normalize(found_configs[1])))
    end
  end,
}
