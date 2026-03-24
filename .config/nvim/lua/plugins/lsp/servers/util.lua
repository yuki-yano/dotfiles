local M = {}

local organize_import_command_created = false

function M.set_format_keymap(bufnr, opts)
  vim.keymap.set('n', '<Plug>(lsp)f', function()
    if opts.before_format then
      opts.before_format()
    end

    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = opts.filter,
    })
  end, {
    buffer = bufnr,
    desc = opts.desc or 'Format current buffer',
  })
end

function M.ensure_organize_import_command()
  if organize_import_command_created then
    return
  end

  vim.api.nvim_create_user_command('OrganizeImport', function()
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'vtsls' })
    if #clients > 0 then
      clients[1]:exec_cmd({
        title = 'Organize Imports',
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
      })
      return
    end

    clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'tsserver' })
    if #clients > 0 then
      clients[1]:exec_cmd({
        title = 'Organize Imports',
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
      })
    end
  end, {})

  organize_import_command_created = true
end

return M
