" =============================================================================
" Filename: autoload/lightline/colorscheme/iceberg_tigberd.vim
" Author: tibberd
" License: MIT License
" Last Change: 2017-05-09T18:04:32+0900.
" =============================================================================
let s:base03 = [ '#002b36', '8' ]
let s:base02 = [ '#073642', '0' ]
let s:base01 = [ '#586e75', '10' ]
let s:base00 = [ '#657b83', '109' ]
let s:base0 = [ '#839496', '12' ]
let s:base1 = [ '#93a1a1', '110' ]
let s:base2 = [ '#eee8d5', '67' ]
let s:base3 = [ '#fdf6e3', '15' ]
let s:yellow = [ '#b58900', '229' ]
let s:orange = [ '#cb4b16', '216' ]
let s:red = [ '#dc322f', '203' ]
let s:magenta = [ '#d33682', '5' ]
let s:violet = [ '#6c71c4', '13' ]
let s:blue = [ '#268bd2', '110' ]
let s:cyan = [ '#2aa198', '6' ]
let s:green = [ '#859900', '151' ]

let s:bold = 'bold'

let s:insert = [
			\ [ s:base03, s:blue, s:bold ],
			\ [ s:base03, [ '#5383bd', 67 ] ],
			\ [ s:base03, s:base0 ],
			\ [ s:base3, s:base02 ],
			\ [ s:base03, [ '#0e53a7', 25 ] ],
			\ [ s:base2, [ '#0a4081', 24 ] ],
			\ [ s:base2, [ '#0e53a7', 25 ] ] ]
let s:replace = [
			\ [ s:base03, s:red, s:bold ],
			\ [ s:base03, [ '#ff8e63', 209 ] ],
			\ [ s:base03, s:base0 ],
			\ [ s:base3, s:base02 ],
			\ [ s:base03, [ '#ff5f39', 203 ] ],
			\ [ s:base2, [ '#c52600', 160 ] ],
			\ [ s:base2, [ '#ff5f39', 203 ] ] ]
let s:visual = [
			\ [ s:base03, s:magenta, s:bold ],
			\ [ s:base03, [ '#aa4dbe', 133 ] ],
			\ [ s:base03, s:base0 ],
			\ [ s:base3, s:base02 ],
			\ [ s:base03, [ '#962aad', 92 ] ],
			\ [ s:base2, [ '#6c0382', 54 ] ],
			\ [ s:base2, [ '#962aad', 92 ] ] ]
let s:normal = [
			\ [ s:base03, s:base01, s:bold ],
			\ [ s:base03, s:base2 ],
			\ [ s:base03, s:blue ],
			\ [ s:base3, s:base02 ],
			\ [ s:base02, s:red ],
			\ [ s:base02, s:yellow ],
			\ [ s:base02, s:green ] ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left     = s:normal[0:3]
let s:p.inactive.left   = s:normal[0:3]
let s:p.insert.left     = s:insert[0:3]
let s:p.replace.left    = s:replace[0:3]
let s:p.visual.left     = s:visual[0:3]

" let s:p.normal.right    = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]
" let s:p.inactive.right  = [ [ s:base03, s:base00 ], [ s:base0, s:base02 ] ]
" let s:p.insert.right    = s:insert[1:2] + s:insert[4:4]
" let s:p.replace.right   = s:replace[1:2] + s:replace[4:4]
" let s:p.visual.right    = s:visual[1:2] + s:visual[4:4]
let s:p.normal.right    = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]
let s:p.inactive.right  = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]
let s:p.insert.right    = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]
let s:p.replace.right   = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]
let s:p.visual.right    = [ [ s:base03, s:base1 ], [ s:base03, s:base00 ] ]

let s:p.normal.middle   = [ [ s:base1, s:base02 ] ]
let s:p.inactive.middle = [ [ s:base01, s:base02 ] ]
let s:p.insert.middle   = [ [ s:base1, s:base02 ] ]
let s:p.replace.middle  = [ [ s:base1, s:base02 ] ]
let s:p.visual.middle   = [ [ s:base1, s:base02 ] ]

let s:p.tabline.left    = [ [ s:base03, s:base00 ] ]
let s:p.tabline.tabsel  = [ [ s:base03, s:base1 ] ]
let s:p.tabline.middle  = [ [ s:base0, s:base02 ] ]
let s:p.tabline.right   = copy(s:p.normal.right)

let s:p.normal.error    = s:normal[4:4]
let s:p.insert.error    = s:normal[4:4]
let s:p.replace.error   = s:normal[4:4]
let s:p.visual.error    = s:normal[4:4]
let s:p.normal.warning  = s:normal[5:5]
let s:p.insert.warning  = s:normal[5:5]
let s:p.replace.warning = s:normal[5:5]
let s:p.visual.warning  = s:normal[5:5]
let s:p.normal.ok       = s:normal[6:6]
let s:p.insert.ok       = s:normal[6:6]
let s:p.replace.ok      = s:normal[6:6]
let s:p.visual.ok       = s:normal[6:6]

let g:lightline#colorscheme#iceberg_tigberd#palette = lightline#colorscheme#flatten(s:p)
