local M = {}

local function extract_word_from_diagnostic(diag, cspell_helpers)
  if cspell_helpers and cspell_helpers.get_word then
    return cspell_helpers.get_word(diag)
  end

  local word = diag.user_data and diag.user_data.misspelled
  if not word then
    local line = vim.api.nvim_buf_get_lines(0, diag.lnum, diag.lnum + 1, false)[1]
    if line then
      word = line:sub(diag.col + 1, diag.end_col)
    end
  end
  return word
end

local function extract_cspell_words(diagnostics, cspell_helpers)
  local words = {}
  local seen = {}

  for _, diag in ipairs(diagnostics) do
    if diag.source == 'cspell' then
      local word = extract_word_from_diagnostic(diag, cspell_helpers)
      if word and not seen[word] then
        seen[word] = true
        table.insert(words, word)
      end
    end
  end

  return words
end

local function add_words_with_cspell_helpers(words, cspell_helpers)
  local params = {
    bufnr = vim.api.nvim_get_current_buf(),
    bufname = vim.api.nvim_buf_get_name(0),
    get_config = function()
      return {
        config_file_preferred_name = 'cspell.json',
        encode_json = vim.json.encode,
        decode_json = vim.json.decode,
      }
    end,
  }

  local cwd = vim.fn.getcwd()
  local cspell_config_path = cspell_helpers.get_config_path and cspell_helpers.get_config_path(params, cwd)

  if not cspell_config_path and cspell_helpers.generate_cspell_config_path then
    cspell_config_path = cspell_helpers.generate_cspell_config_path(params, cwd)
  end

  if not cspell_config_path then
    cspell_config_path = cwd .. '/cspell.json'
  end

  local success, err = pcall(cspell_helpers.add_words_to_json, params, words, cspell_config_path)
  if success then
    vim.notify(string.format('Added %d words to dictionary', #words), vim.log.levels.INFO)
    vim.diagnostic.reset(nil, 0)
    vim.cmd('edit!')
    return true
  end

  vim.notify('Failed to add words using cspell helpers: ' .. tostring(err), vim.log.levels.WARN)
  return false
end

local function add_words_with_code_actions(words, diagnostics, cspell_helpers)
  vim.notify('Using fallback method to add words...', vim.log.levels.INFO)
  local added = 0
  local saved_pos = vim.api.nvim_win_get_cursor(0)

  for _, word in ipairs(words) do
    local word_added = false

    for _, diag in ipairs(diagnostics) do
      if diag.source == 'cspell' and not word_added then
        local diag_word = extract_word_from_diagnostic(diag, cspell_helpers)

        if diag_word == word then
          vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })

          local params = vim.lsp.util.make_range_params(0, 'utf-16')
          params.context = {
            diagnostics = { diag },
            only = { vim.lsp.protocol.CodeActionKind.QuickFix },
          }

          local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)
          if results then
            for client_id, result in pairs(results) do
              if result.result and not word_added then
                for _, action in ipairs(result.result) do
                  if action.title and action.title:match('Add.*dictionary') and not word_added then
                    if action.command then
                      local client = vim.lsp.get_client_by_id(client_id)
                      if client then
                        client:request('workspace/executeCommand', action.command)
                        added = added + 1
                        word_added = true
                        break
                      end
                    end
                  end
                end
              end
            end
          end
          break
        end
      end
    end
  end

  vim.api.nvim_win_set_cursor(0, saved_pos)
  vim.notify(string.format('Added %d/%d words to dictionary', added, #words), vim.log.levels.INFO)
end

local function add_cspell_diagnostics_to_dictionary(diagnostics, scope_desc)
  local ok, cspell_helpers = pcall(require, 'cspell.helpers')
  if not ok then
    cspell_helpers = nil
  end

  local words = extract_cspell_words(diagnostics, cspell_helpers)

  if #words == 0 then
    vim.notify('No cspell diagnostics found in ' .. scope_desc, vim.log.levels.INFO)
    return
  end

  if cspell_helpers and cspell_helpers.add_words_to_json then
    if add_words_with_cspell_helpers(words, cspell_helpers) then
      return
    end
  end

  add_words_with_code_actions(words, diagnostics, cspell_helpers)
end

local function setup_commands()
  vim.api.nvim_create_user_command(
    'CspellAddAllInRange',
    function(opts)
      local diagnostics = vim.diagnostic.get(0, {
        lnum_start = opts.line1 - 1,
        lnum_end = opts.line2 - 1,
      })
      add_cspell_diagnostics_to_dictionary(diagnostics, 'the selected range')
    end,
    { range = true, desc = 'Add all cspell diagnostics in range to dictionary', force = true }
  )

  vim.api.nvim_create_user_command(
    'CspellAddAll',
    function()
      local diagnostics = vim.diagnostic.get(0)
      add_cspell_diagnostics_to_dictionary(diagnostics, 'the file')
    end,
    { desc = 'Add all cspell diagnostics in file to dictionary', force = true }
  )
end

function M.setup(null_ls)
  local cspell = require('cspell')
  local sources = {
    diagnostics = cspell.diagnostics.with({
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      diagnostics_postprocess = function(d)
        d.severity = vim.diagnostic.severity.HINT
      end,
    }),
    code_actions = cspell.code_actions,
  }

  setup_commands()

  return sources
end

return M
