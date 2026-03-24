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

local function tmux_env_value()
  if not vim.env.TMUX then
    return nil
  end

  local ok, output = pcall(function()
    return vim.fn.systemlist({ 'tmux', 'show-environment', '-g', 'NVIM_TRANSPARENCY' })
  end)

  if not ok or not output or #output == 0 then
    return nil
  end

  local line = vim.trim(output[1] or '')
  if line == '' then
    return nil
  end

  local _, value = line:match('^([^=]+)=(.*)$')
  if value == nil then
    return nil
  end

  return bool_from_env(value)
end

local function tmux_theme_mode()
  if not vim.env.TMUX then
    return nil
  end

  local function read_tmux_option(args)
    local ok, output = pcall(function()
      return vim.fn.systemlist(args)
    end)

    if not ok or not output or #output == 0 then
      return nil
    end

    local value = vim.trim(output[1] or '')
    return value ~= '' and value or nil
  end

  local mode = read_tmux_option({ 'tmux', 'show-option', '-qv', '@theme_mode' })
  if not mode then
    mode = read_tmux_option({ 'tmux', 'show-option', '-gqv', '@theme_mode' })
  end

  if not mode then
    return nil
  end

  local normalized = string.lower(mode)
  if normalized == 'solid' or normalized == 'off' or normalized == '0' or normalized == 'false' then
    return 'solid'
  elseif normalized == 'transparent' or normalized == 'on' or normalized == '1' or normalized == 'true' then
    return 'transparent'
  end

  return mode
end

function M.is_enabled()
  if vim.g.ui_transparency == nil then
    local env_value = bool_from_env(vim.env.NVIM_TRANSPARENCY)
    if env_value == nil then
      env_value = tmux_env_value()
    end
    if env_value ~= nil then
      vim.g.ui_transparency = env_value
    else
      local tmux_mode = tmux_theme_mode()
      if tmux_mode == 'solid' then
        vim.g.ui_transparency = false
      elseif tmux_mode == 'transparent' then
        vim.g.ui_transparency = true
      else
        vim.g.ui_transparency = true
      end
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
