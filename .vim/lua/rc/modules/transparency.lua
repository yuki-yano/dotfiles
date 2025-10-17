local M = {}

local function bool_from_env(value)
  if not value or value == '' then
    return nil
  end
  local normalized = string.lower(value)
  if normalized == '0' or normalized == 'false' or normalized == 'off' then
    return false
  end
  return true
end

function M.is_enabled()
  if vim.g.ui_transparency == nil then
    local env_value = bool_from_env(vim.env.NVIM_TRANSPARENCY)
    if env_value == nil then
      vim.g.ui_transparency = true
    else
      vim.g.ui_transparency = env_value
    end
  end
  return vim.g.ui_transparency ~= false
end

function M.set_enabled(value)
  vim.g.ui_transparency = value and true or false
end

local function integrations()
  return {
    aerial = true,
    coc_nvim = true,
    cmp = true,
    dropbar = {
      enabled = true,
    },
    fern = true,
    fidget = true,
    gitsigns = true,
    lsp_saga = true,
    lsp_trouble = true,
    mason = true,
    notify = true,
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    rainbow_delimiters = true,
    indent_blankline = {
      enabled = true,
    },
    sandwich = false,
  }
end

function M.configure_catppuccin()
  local ok, catppuccin = pcall(require, 'catppuccin')
  if not ok then
    return
  end

  local transparent = M.is_enabled()
  catppuccin.setup({
    term_colors = true,
    transparent_background = transparent,
    dim_inactive = {
      enabled = false,
    },
    custom_highlights = function(colors)
      local highlights = {
        ['@keyword.export'] = { fg = colors.sapphire, style = {} },
      }
      if transparent then
        highlights.Normal = { bg = 'NONE' }
        highlights.NormalNC = { bg = 'NONE' }
        highlights.NormalFloat = { bg = 'NONE' }
        highlights.FloatBorder = { bg = 'NONE' }
        highlights.SignColumn = { bg = 'NONE' }
        highlights.EndOfBuffer = { bg = 'NONE' }
      end
      return highlights
    end,
    integrations = integrations(),
  })
end

function M.apply()
  M.configure_catppuccin()
  local colorscheme = vim.env.NVIM_COLORSCHEME or 'catppuccin'
  vim.cmd('colorscheme ' .. colorscheme)
  vim.api.nvim_exec_autocmds('User', { pattern = 'TransparencyApplied' })
end

function M.toggle()
  M.set_enabled(not M.is_enabled())
  M.apply()
  local mode = M.is_enabled() and 'transparent' or 'solid'
  vim.notify('Transparency mode: ' .. mode, vim.log.levels.INFO, { title = 'Appearance' })
end

return M
