" =============================================================================
" Filename: autoload/lightline/colorscheme/lightline_onedark.vim
" Author: yuki_yano
" License: MIT License
" Last Change: 2017-05-09T18:04:32+0900.
" =============================================================================
let s:colors = onedark#GetColors()

if get(g:, 'onedark_termcolors', 256) == 16
  let s:term_red = s:colors.red.cterm16
  let s:term_dark_red = s:colors.dark_red.cterm16
  let s:term_green = s:colors.green.cterm16
  let s:term_yellow = s:colors.yellow.cterm16
  let s:term_blue = s:colors.blue.cterm16
  let s:term_purple = s:colors.purple.cterm16
  let s:term_white = s:colors.white.cterm16
  let s:term_black = s:colors.black.cterm16
  let s:term_grey = s:colors.cursor_grey.cterm16
  let s:term_dark_yellow = s:colors.dark_yellow.cterm16
else
  let s:term_red = s:colors.red.cterm
  let s:term_dark_red = s:colors.dark_red.cterm
  let s:term_green = s:colors.green.cterm
  let s:term_yellow = s:colors.yellow.cterm
  let s:term_blue = s:colors.blue.cterm
  let s:term_purple = s:colors.purple.cterm
  let s:term_white = s:colors.white.cterm
  let s:term_black = s:colors.black.cterm
  let s:term_grey = s:colors.cursor_grey.cterm
  let s:term_dark_yellow = s:colors.dark_yellow.cterm
endif

let s:red         = [s:colors.red.gui, s:term_red]
let s:dark_red    = [s:colors.dark_red.gui, s:term_dark_red]
let s:green       = [s:colors.green.gui, s:term_green]
let s:yellow      = [s:colors.yellow.gui, s:term_yellow]
let s:blue        = [s:colors.blue.gui, s:term_blue]
let s:purple      = [s:colors.purple.gui, s:term_purple]
let s:white       = [s:colors.white.gui, s:term_white]
let s:black       = [s:colors.black.gui, s:term_black]
let s:grey        = [s:colors.visual_grey.gui, s:term_grey]
let s:dark_yellow = [s:colors.dark_yellow.gui, s:term_dark_yellow]
let s:bold        = 'bold'

" Self Definition
let s:orange      = ['#D78700', 172]
let s:blue_green  = ['#00AFAF', 37 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left = [
\ [s:black, s:green],
\ [s:orange, s:grey],
\ [s:blue_green, s:grey],
\ [s:blue, s:grey],
\ ]

let s:p.insert.left = [
\ [s:black,      s:yellow],
\ [s:orange,     s:grey],
\ [s:blue_green, s:grey],
\ [s:blue,       s:grey],
\]

let s:p.visual.left = [
\ [s:black,      s:purple],
\ [s:orange,     s:grey],
\ [s:blue_green, s:grey],
\ [s:blue,       s:grey],
\ ]

let s:p.replace.left = [
\ [s:black,      s:red],
\ [s:orange,     s:grey],
\ [s:blue_green, s:grey],
\ [s:blue,       s:grey],
\ ]

let s:p.inactive.left = [
\ [s:blue_green, s:grey],
\ [s:orange,     s:grey],
\ [s:blue_green, s:grey],
\ [s:blue,       s:grey],
\ ]

let s:p.normal.right   = [[s:white, s:black],   [s:white, s:grey]]
let s:p.inactive.right = [[s:black, s:white],   [s:black, s:white]]
let s:p.insert.right   = [[s:black, s:blue],    [s:white, s:grey]]
let s:p.replace.right  = [[s:black, s:red],     [s:white, s:grey]]
let s:p.visual.right   = [[s:black, s:purple],  [s:white, s:grey]]

let s:p.normal.middle   = [[s:white, s:black]]
let s:p.inactive.middle = [[s:white, s:grey]]

let s:p.tabline.left   = [[s:blue,   s:grey]]
let s:p.tabline.tabsel = [[s:orange, s:black]]
let s:p.tabline.middle = [[s:white,  s:black]]
let s:p.tabline.right  = [[s:white,  s:grey]]

let s:coc_diagnostic = [
\ [s:grey, s:red   ],
\ [s:grey, s:orange],
\ [s:grey, s:yellow],
\ [s:grey, s:green ],
\ ]

let s:p.normal.error        = s:coc_diagnostic[0:0]
let s:p.insert.error        = s:coc_diagnostic[0:0]
let s:p.replace.error       = s:coc_diagnostic[0:0]
let s:p.visual.error        = s:coc_diagnostic[0:0]
let s:p.normal.warning      = s:coc_diagnostic[1:1]
let s:p.insert.warning      = s:coc_diagnostic[1:1]
let s:p.replace.warning     = s:coc_diagnostic[1:1]
let s:p.visual.warning      = s:coc_diagnostic[1:1]
let s:p.normal.information  = s:coc_diagnostic[2:2]
let s:p.insert.information  = s:coc_diagnostic[2:2]
let s:p.replace.information = s:coc_diagnostic[2:2]
let s:p.visual.information  = s:coc_diagnostic[2:2]
let s:p.normal.ok           = s:coc_diagnostic[3:3]
let s:p.insert.ok           = s:coc_diagnostic[3:3]
let s:p.replace.ok          = s:coc_diagnostic[3:3]
let s:p.visual.ok           = s:coc_diagnostic[3:3]
let g:lightline#colorscheme#onedark#palette = lightline#colorscheme#flatten(s:p)
