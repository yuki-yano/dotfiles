local M = {}

-- TODO: Split and define fg and bg, Only fg now
M.base_colors = {
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
  incsearch = '#175655',
  search = '#213F72',
  visual = '#1D4647',
  info = '#FFFFAF',
}

M.misc_colors = {
  pointer = {
    red = '#E27878',
    blue = '#5F87D7',
  },
  diff = {
    add = {
      bg = '#1A3627',
    },
    change = {
      bg = '#36341a',
    },
    text = {
      bg = '#716522',
    },
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
      bg = '#213F72',
    },
    float = {
      fg = 'NONE',
      bg = '#213F72',
    },
  },
}

return M
