" =============================================================================
" Filename: autoload/lightline/colorscheme/iceberg_yano.vim
" Author: yuki_yano
" License: MIT License
" Last Change: 2017-05-09T18:04:32+0900.
" =============================================================================
let s:base03  = [ '#002b36', 233 ]
let s:base02  = [ '#073642', 236 ]
let s:base01  = [ '#586e75', 238 ]
let s:base00  = [ '#657b83', 241 ]
let s:base0   = [ '#839496', 244 ]
let s:base1   = [ '#93a1a1', 248 ]
let s:base2   = [ '#eee8d5', 251 ]
let s:base3   = [ '#fdf6e3', 255 ]
let s:yellow  = [ '#b58900', 136 ]
let s:orange  = [ '#cb4b16', 172 ]
let s:red     = [ '#dc322f', 52  ]
let s:magenta = [ '#d33682', 168 ]
let s:blue    = [ '#268bd2', 110 ]
let s:cyan    = [ '#2aa198', 24  ]
let s:green   = [ '#859900', 64  ]

let s:bold = 'bold'

let s:normal = [
\ [ s:base3,  s:green  ],
\ [ s:orange, s:base02 ],
\ [ s:blue,   s:base03 ], ]

let s:insert = [
\ [ s:base3,  s:yellow, ],
\ [ s:orange, s:base02  ],
\ [ s:blue,   s:base03  ], ]

let s:visual = [
\ [ s:base3,  s:cyan    ],
\ [ s:orange, s:base02  ],
\ [ s:blue,   s:base03  ], ]

let s:replace = [
\ [ s:base3,  s:magenta, ],
\ [ s:orange, s:base02   ],
\ [ s:blue,   s:base03   ], ]

let s:ale = [
\ [ s:base3, s:red,    s:bold ],
\ [ s:base3, s:yellow, s:bold ],
\ [ s:base3, s:cyan,   s:bold ],
\ [ s:base3, s:base02, s:bold ], ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left   = s:normal[0:3]
let s:p.inactive.left = s:normal[0:3]
let s:p.insert.left   = s:insert[0:3]
let s:p.replace.left  = s:replace[0:3]
let s:p.visual.left   = s:visual[0:3]

let s:p.normal.right   = [ [ s:base3, s:base00 ], [ s:base3, s:base01 ] ]
let s:p.inactive.right = [ [ s:base3, s:base00 ], [ s:base3, s:base01 ] ]
let s:p.insert.right   = [ [ s:base3, s:base00 ], [ s:base3, s:base01 ] ]
let s:p.replace.right  = [ [ s:base3, s:base00 ], [ s:base3, s:base01 ] ]
let s:p.visual.right   = [ [ s:base3, s:base00 ], [ s:base3, s:base01 ] ]

let s:p.normal.middle   = [ [ s:base1,  s:base03 ] ]
let s:p.inactive.middle = [ [ s:base01, s:base03 ] ]
let s:p.insert.middle   = [ [ s:base1,  s:base03 ] ]
let s:p.replace.middle  = [ [ s:base1,  s:base03 ] ]
let s:p.visual.middle   = [ [ s:base1,  s:base03 ] ]

let s:p.tabline.left = [
\ [ s:base3, s:base01 ],
\ [ s:base1, s:base01 ],
\ [ s:blue,  s:base02 ], ]
let s:p.tabline.tabsel  = [ [ s:orange, s:base03 ] ]
let s:p.tabline.middle  = [ [ s:base1,  s:base02 ] ]

let s:p.normal.error    = s:ale[0:0]
let s:p.insert.error    = s:ale[0:0]
let s:p.replace.error   = s:ale[0:0]
let s:p.visual.error    = s:ale[0:0]
let s:p.normal.warning  = s:ale[1:1]
let s:p.insert.warning  = s:ale[1:1]
let s:p.replace.warning = s:ale[1:1]
let s:p.visual.warning  = s:ale[1:1]
let s:p.normal.ok       = s:ale[2:2]
let s:p.insert.ok       = s:ale[2:2]
let s:p.replace.ok      = s:ale[2:2]
let s:p.visual.ok       = s:ale[2:2]
let s:p.normal.unload   = s:ale[3:3]
let s:p.insert.unload   = s:ale[3:3]
let s:p.replace.unload  = s:ale[3:3]
let s:p.visual.unload   = s:ale[3:3]

let g:lightline#colorscheme#iceberg_yano#palette = lightline#colorscheme#flatten(s:p)
