local color = require('rc.modules.color')
local font = require('rc.modules.font')
local transparency = require('rc.modules.transparency')

local M = {}

local function diagnostics_indicator_factory(diagnostic_icons)
  local coc_diagnostic_results = {}

  return function(_, _, diagnostics_dict, context)
    local error_text = ''
    local warning_text = ''

    if vim.env.LSP == 'nvim' then
      if diagnostics_dict.error then
        error_text = diagnostic_icons.error .. ' ' .. diagnostics_dict.error
      end
      if diagnostics_dict.warning then
        warning_text = diagnostic_icons.warn .. ' ' .. diagnostics_dict.warning
      end
    else
      local buf = vim.api.nvim_get_current_buf()
      if context.buffer.id ~= buf then
        return coc_diagnostic_results[context.buffer.id] or ''
      end

      local ok, diagnostics = pcall(vim.api.nvim_buf_get_var, buf, 'coc_diagnostic_info')
      if not ok then
        return ''
      end

      if diagnostics.error ~= 0 then
        error_text = diagnostic_icons.error .. ' ' .. diagnostics.error
      end
      if diagnostics.warning ~= 0 then
        warning_text = diagnostic_icons.warn .. ' ' .. diagnostics.warning
      end
    end

    local result = ''
    if error_text ~= '' then
      result = error_text
    end
    if warning_text ~= '' then
      if result ~= '' then
        result = result .. ' '
      end
      result = result .. warning_text
    end

    return result
  end
end

local function highlight_groups(transparent)
  local base = color.base()
  local misc = color.misc()

  local grey = base.grey
  local green = base.green
  local yellow = base.yellow
  local blue = base.blue
  local white = base.white
  local red = base.red
  local info = base.yellow
  local background = base.background
  local empty = base.empty
  local black = base.black
  local split = misc.split or {}
  local vert_split = split.vert_split
  if type(vert_split) == 'table' then
    vert_split = vert_split.fg
  end
  vert_split = vert_split or background
  local none = 'NONE'

  if transparent then
    return {
      fill = { fg = grey, bg = none },
      background = { fg = grey, bg = none },
      tab = { fg = grey, bg = none },
      buffer = { fg = grey, bg = none },
      close_button = { fg = grey, bg = none },
      numbers = { fg = grey, bg = none },
      separator = { fg = vert_split, bg = none },
      duplicate = { fg = green, bg = none, bold = false, italic = false },
      diagnostic = { fg = white, bg = none },
      error = { fg = grey, bg = none },
      warning = { fg = grey, bg = none },
      info = { fg = grey, bg = none },
      hint = { fg = grey, bg = none },
      error_diagnostic = { fg = red, bg = none },
      warning_diagnostic = { fg = yellow, bg = none },
      info_diagnostic = { fg = info, bg = none },
      hint_diagnostic = { fg = white, bg = none },
      modified = { fg = yellow, bg = none },
      tab_selected = { fg = white, bg = none, bold = true, italic = false },
      buffer_selected = { fg = white, bg = none, bold = true, italic = false },
      close_button_selected = { fg = white, bg = none, bold = false, italic = false },
      numbers_selected = { fg = white, bg = none, bold = false, italic = false },
      indicator_selected = { fg = blue, bg = none, bold = true, italic = false },
      duplicate_selected = { fg = green, bg = none, bold = false, italic = false },
      error_selected = { fg = white, bg = none, bold = true, italic = false },
      warning_selected = { fg = white, bg = none, bold = true, italic = false },
      info_selected = { fg = white, bg = none, bold = true, italic = false },
      hint_selected = { fg = white, bg = none, bold = true, italic = false },
      error_diagnostic_selected = { fg = red, bg = none, bold = false, italic = false },
      warning_diagnostic_selected = { fg = yellow, bg = none, bold = false, italic = false },
      info_diagnostic_selected = { fg = info, bg = none, bold = false, italic = false },
      hint_diagnostic_selected = { fg = white, bg = none, bold = false, italic = false },
      modified_selected = { fg = yellow, bg = none, bold = false, italic = false },
      buffer_visible = { fg = white, bg = none, bold = false, italic = false },
      close_button_visible = { fg = white, bg = none, bold = false, italic = false },
      numbers_visible = { fg = white, bg = none, bold = false, italic = false },
      indicator_visible = { fg = white, bg = none, bold = false, italic = false },
      duplicate_visible = { fg = green, bg = none, bold = false, italic = false },
      error_visible = { fg = white, bg = none, bold = false, italic = false },
      warning_visible = { fg = white, bg = none, bold = false, italic = false },
      info_visible = { fg = info, bg = none, bold = false, italic = false },
      hint_visible = { fg = white, bg = none, bold = false, italic = false },
      error_diagnostic_visible = { fg = red, bg = none, bold = false, italic = false },
      warning_diagnostic_visible = { fg = yellow, bg = none, bold = false, italic = false },
      info_diagnostic_visible = { fg = info, bg = none, bold = false, italic = false },
      hint_diagnostic_visible = { fg = white, bg = none, bold = false, italic = false },
      modified_visible = { fg = yellow, bg = none, bold = false, italic = false },
      offset_separator = { fg = vert_split, bg = none },
    }
  end

  return {
    fill = { fg = grey, bg = empty },
    background = { fg = grey, bg = background },
    tab = { fg = grey, bg = black },
    buffer = { fg = grey, bg = black },
    close_button = { fg = grey, bg = background },
    numbers = { fg = grey, bg = background },
    separator = { fg = background, bg = background },
    duplicate = { fg = green, bg = background, bold = false, italic = false },
    diagnostic = { fg = white, bg = black },
    error = { fg = grey, bg = background },
    warning = { fg = grey, bg = background },
    info = { fg = grey, bg = background },
    hint = { fg = grey, bg = background },
    error_diagnostic = { fg = red, bg = background },
    warning_diagnostic = { fg = yellow, bg = background },
    info_diagnostic = { fg = info, bg = background },
    hint_diagnostic = { fg = white, bg = background },
    modified = { fg = yellow, bg = background },
    tab_selected = { fg = white, bg = black, bold = true, italic = false },
    buffer_selected = { fg = white, bg = black, bold = true, italic = false },
    close_button_selected = { fg = white, bg = black, bold = false, italic = false },
    numbers_selected = { fg = white, bg = black, bold = false, italic = false },
    indicator_selected = { fg = blue, bg = black, bold = true, italic = false },
    duplicate_selected = { fg = green, bg = black, bold = false, italic = false },
    error_selected = { fg = white, bg = black, bold = true, italic = false },
    warning_selected = { fg = white, bg = black, bold = true, italic = false },
    info_selected = { fg = white, bg = black, bold = true, italic = false },
    hint_selected = { fg = white, bg = black, bold = true, italic = false },
    error_diagnostic_selected = { fg = red, bg = black, bold = false, italic = false },
    warning_diagnostic_selected = { fg = yellow, bg = black, bold = false, italic = false },
    info_diagnostic_selected = { fg = info, bg = black, bold = false, italic = false },
    hint_diagnostic_selected = { fg = white, bg = black, bold = false, italic = false },
    modified_selected = { fg = yellow, bg = black, bold = false, italic = false },
    buffer_visible = { fg = white, bg = background, bold = false, italic = false },
    close_button_visible = { fg = white, bg = background, bold = false, italic = false },
    numbers_visible = { fg = white, bg = background, bold = false, italic = false },
    indicator_visible = { fg = white, bg = background, bold = false, italic = false },
    duplicate_visible = { fg = green, bg = background, bold = false, italic = false },
    error_visible = { fg = white, bg = background, bold = false, italic = false },
    warning_visible = { fg = white, bg = background, bold = false, italic = false },
    info_visible = { fg = info, bg = background, bold = false, italic = false },
    hint_visible = { fg = white, bg = background, bold = false, italic = false },
    error_diagnostic_visible = { fg = red, bg = background, bold = false, italic = false },
    warning_diagnostic_visible = { fg = yellow, bg = background, bold = false, italic = false },
    info_diagnostic_visible = { fg = info, bg = background, bold = false, italic = false },
    hint_diagnostic_visible = { fg = white, bg = background, bold = false, italic = false },
    modified_visible = { fg = yellow, bg = background, bold = false, italic = false },
    offset_separator = { fg = vert_split, bg = background },
  }
end

local function options(transparent)
  local base = color.base()
  local none = 'NONE'
  local empty = base.empty
  local yellow = base.yellow
  local white = base.white

  local tab_bg = transparent and none or empty
  local diagnostic_icons = font.diagnostic_icons

  return {
    numbers = 'ordinal',
    buffer_close_icon = '×',
    show_close_icon = false,
    diagnostics = vim.env.LSP == 'nvim' and 'nvim_lsp' or 'coc',
    separator_style = { '|', ' ' },
    modified_icon = '[+]',
    diagnostics_indicator = diagnostics_indicator_factory(diagnostic_icons),
    offsets = {
      {
        filetype = 'fern',
        text = 'Fern',
        highlight = 'Directory',
        separator = true,
      },
      {
        filetype = 'DiffviewFiles',
        text = 'Diffview',
        highlight = 'Directory',
        separator = true,
      },
    },
    custom_areas = {
      left = function()
        local count = #vim.fn.gettabinfo()
        if count == 1 then
          return {}
        end
        return {
          {
            text = '▎',
            fg = yellow,
            bg = tab_bg,
          },
          {
            text = ' ' .. vim.fn.tabpagenr() .. '/' .. vim.fn.tabpagenr('$') .. ' ',
            fg = white,
            bg = tab_bg,
          },
        }
      end,
    },
  }
end

local function apply(transparent)
  local ok, bufferline = pcall(require, 'bufferline')
  if not ok then
    return
  end

  bufferline.setup({
    options = options(transparent),
    highlights = highlight_groups(transparent),
  })
end

function M.refresh()
  apply(transparency.is_enabled())
end

function M.setup()
  M.refresh()
end

return M
