local M = {}
local palette = {}

-- global settings
local incsearch = '#175655'
local search = '#213F72'
local diff = {
  add = {
    bg = '#002800',
  },
  delete = {
    bg = '#350001',
  },
  change = {
    bg = '#2b2a00',
  },
  text = {
    bg = '#485400',
  },
}

palette['gruvbox-material'] = function()
  return {
    base = {
      black = '#32302F',
      red = '#EA6962',
      green = '#A9B665',
      yellow = '#D8A657',
      blue = '#7DAEA3',
      magenta = '#D3869B',
      cyan = '#89B482',
      white = '#D4BE98',
      grey = '#807569',
      orange = '#E78A4E',
      purple = '#CBA6F7', -- TODO: Temporary settings
      background = '#1D2021',
      empty = '#1C1C1C',
      info = '#FFFFAF',
      incsearch = incsearch,
      search = search,
      visual = '#1D4647',
    },
    misc = {
      completion = {
        match = '#7DAEA3',
      },
      pointer = {
        red = '#E27878',
        blue = '#5F87D7',
      },
      diff = diff,
      -- NOTE: Copy from catppuccino
      sandwich = {
        add = '#0E4A1D',
        delete = '#541010',
        change = '#544E10',
      },
      vert_split = '#504945',
      scrollbar = {
        bar = '#3A3A3A',
        search = '#00AFAF',
      },
      hlslens = {
        lens = {
          fg = '#889EB5',
          bg = '#283642',
        },
        near = {
          fg = 'NONE',
          bg = search,
        },
        float = {
          fg = 'NONE',
          bg = search,
        },
      },
      focus_inactive = '#2A2827', -- Slightly lighter than gruvbox background
    },
  }
end

-- base = "#1E1E2E",
-- blue = "#89B4FA",
-- crust = "#11111B",
-- flamingo = "#F2CDCD",
-- green = "#A6E3A1",
-- lavender = "#B4BEFE",
-- mantle = "#181825",
-- maroon = "#EBA0AC",
-- mauve = "#CBA6F7",
-- overlay0 = "#6C7086",
-- overlay1 = "#7F849C",
-- overlay2 = "#9399B2",
-- peach = "#FAB387",
-- pink = "#F5C2E7",
-- red = "#F38BA8",
-- rosewater = "#F5E0DC",
-- sapphire = "#74C7EC",
-- sky = "#89DCEB",
-- subtext0 = "#A6ADC8",
-- subtext1 = "#BAC2DE",
-- surface0 = "#313244",
-- surface1 = "#45475A",
-- surface2 = "#585B70",
-- teal = "#94E2D5",
-- text = "#CDD6F4",
-- yellow = "#F9E2AF"
palette['catppuccin'] = function()
  local catppuccin_palette = require('catppuccin.palettes').get_palette('mocha')

  return {
    base = {
      black = catppuccin_palette.base, -- #1E1E2E
      red = catppuccin_palette.red, -- #F38BA8
      green = catppuccin_palette.green, -- #A6E3A1
      yellow = catppuccin_palette.yellow, -- #F9E2AF
      blue = catppuccin_palette.blue, -- #89B4FA
      magenta = catppuccin_palette.pink, -- #F5C2E7
      cyan = catppuccin_palette.lavender, -- #B4BEFE
      sky = catppuccin_palette.sky, -- #89DCEB
      white = catppuccin_palette.rosewater, -- #F5E0DC
      grey = catppuccin_palette.overlay0, -- #6C7086
      orange = catppuccin_palette.peach, -- #FAB387
      purple = catppuccin_palette.mauve, -- #CBA6F7
      background = catppuccin_palette.mantle, -- #181825
      empty = catppuccin_palette.crust, -- #11111B
      info = catppuccin_palette.yellow, -- #F9E2AF
      incsearch = incsearch,
      search = search,
      visual = catppuccin_palette.surface0, -- #313244
      vert_split = catppuccin_palette.surface0, -- #313244
      inlay_hint = catppuccin_palette.surface2, -- #585B70
    },
    misc = {
      completion = {
        match = catppuccin_palette.sky, -- #89DCEB
      },
      pointer = {
        red = '#f17497',
        blue = '#71a4f9',
      },
      diff = diff,
      sandwich = {
        add = '#0E4A1D',
        delete = '#541010',
        change = '#544E10',
      },
      scrollbar = {
        bar = catppuccin_palette.surface1, -- #45475A
        search = catppuccin_palette.sky, -- #89DCEB
      },
      hlslens = {
        lens = {
          fg = catppuccin_palette.overlay2, -- #9399B2
          bg = catppuccin_palette.surface0, -- #313244
        },
        near = {
          fg = 'NONE',
          bg = search,
        },
        float = {
          fg = 'NONE',
          bg = search,
        },
      },
      -- lualine inactive colors
      lualine_inactive = {
        fg = catppuccin_palette.overlay0, -- #6C7086
        bg = catppuccin_palette.surface0, -- #313244
        bg_alt = catppuccin_palette.base, -- #1E1E2E
      },
      focus_inactive = catppuccin_palette.base, -- #1E1E2E
    },
  }
end

M.base = function()
  return palette[vim.env.NVIM_COLORSCHEME]().base
end
M.misc = function()
  return palette[vim.env.NVIM_COLORSCHEME]().misc
end

return M
