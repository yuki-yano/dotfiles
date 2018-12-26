" =============================================================================
" Filename: autoload/lightline/colorscheme/iceberg_yano.vim
" Author: yuki_yano
" License: MIT License
" Last Change: 2017-05-09T18:04:32+0900.
" =============================================================================
let s:base03     = ['#121212', 233]
let s:base02     = ['#303030', 236]
let s:base01     = ['#444444', 238]
let s:base00     = ['#626262', 241]
let s:base0      = ['#808080', 244]
let s:base1      = ['#A8A8A8', 248]
let s:base2      = ['#C6C6C6', 251]
let s:base3      = ['#EEEEEE', 255]
let s:yellow     = ['#AF8700', 136]
let s:orange     = ['#D78700', 172]
let s:red        = ['#5F0000', 52 ]
let s:magenta    = ['#D75F87', 168]
let s:blue       = ['#87AFD7', 110]
let s:cyan       = ['#005F87', 24 ]
let s:green      = ['#5F8700', 64 ]
let s:blue_green = ['#00AFAF', 37 ]

let s:bold = 'bold'

let s:normal = [
\ [s:base3,      s:cyan  ],
\ [s:blue_green, s:base02],
\ [s:orange,     s:base03],
\ [s:blue,       s:base03],
\ ]

let s:insert = [
\ [s:base3,      s:yellow],
\ [s:blue_green, s:base02],
\ [s:orange,     s:base02],
\ [s:blue,       s:base03],
\ ]

let s:visual = [
\ [s:base3,      s:green ],
\ [s:blue_green, s:base02],
\ [s:orange,     s:base02],
\ [s:blue,       s:base03],
\ ]

let s:replace = [
\ [s:base3,      s:magenta],
\ [s:blue_green, s:base02 ],
\ [s:orange,     s:base02 ],
\ [s:blue,       s:base03 ],
\ ]

let s:inactive = [
\ [s:blue_green, s:base02],
\ [s:blue_green, s:base02],
\ [s:orange,     s:base02],
\ [s:blue,       s:base03],
\ ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left   = s:normal[0:3]
let s:p.inactive.left = s:inactive[0:3]
let s:p.insert.left   = s:insert[0:3]
let s:p.replace.left  = s:replace[0:3]
let s:p.visual.left   = s:visual[0:3]

let s:p.normal.right   = [[s:base3, s:base00], [s:base3, s:base01]]
let s:p.inactive.right = [[s:base3, s:base00], [s:base3, s:base01]]
let s:p.insert.right   = [[s:base3, s:base00], [s:base3, s:base01]]
let s:p.replace.right  = [[s:base3, s:base00], [s:base3, s:base01]]
let s:p.visual.right   = [[s:base3, s:base00], [s:base3, s:base01]]

let s:p.normal.middle   = [[s:base1,  s:base03]]
let s:p.inactive.middle = [[s:base01, s:base03]]
let s:p.insert.middle   = [[s:base1,  s:base03]]
let s:p.replace.middle  = [[s:base1,  s:base03]]
let s:p.visual.middle   = [[s:base1,  s:base03]]

let s:p.tabline.left = [[s:blue,  s:base02]]
let s:p.tabline.right = [
\ [s:base2, s:base03],
\ [s:base2, s:base02],
\ ]
let s:p.tabline.tabsel  = [[s:orange, s:base03]]
let s:p.tabline.middle  = [[s:base1,  s:base01]]

let s:ale = [
\ [s:base3, s:red,    s:bold],
\ [s:base3, s:yellow, s:bold],
\ [s:base3, s:green,  s:bold],
\ [s:base3, s:cyan,   s:bold],
\ [s:base3, s:base00, s:bold],
\ ]

let s:p.normal.error     = s:ale[0:0]
let s:p.insert.error     = s:ale[0:0]
let s:p.replace.error    = s:ale[0:0]
let s:p.visual.error     = s:ale[0:0]
let s:p.normal.warning   = s:ale[1:1]
let s:p.insert.warning   = s:ale[1:1]
let s:p.replace.warning  = s:ale[1:1]
let s:p.visual.warning   = s:ale[1:1]
let s:p.normal.ok        = s:ale[2:2]
let s:p.insert.ok        = s:ale[2:2]
let s:p.replace.ok       = s:ale[2:2]
let s:p.visual.ok        = s:ale[2:2]
let s:p.normal.checking  = s:ale[3:3]
let s:p.insert.checking  = s:ale[3:3]
let s:p.replace.checking = s:ale[3:3]
let s:p.visual.checking  = s:ale[3:3]
let s:p.normal.disable   = s:ale[4:4]
let s:p.insert.disable   = s:ale[4:4]
let s:p.replace.disable  = s:ale[4:4]
let s:p.visual.disable   = s:ale[4:4]

let g:lightline#colorscheme#iceberg_yano#palette = lightline#colorscheme#flatten(s:p)
