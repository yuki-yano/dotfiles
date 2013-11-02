set guioptions=c
set mouse=a
set ttymouse=xterm2
set mousehide

set clipboard=unnamed,autoselect

set guifont=Ricty\ Diminished\ Discord\ Regular:h16
colorscheme iceberg

" turn off disabling IM at entering input mode
if exists('&imdisableactivate')
  set noimdisableactivate
endif
