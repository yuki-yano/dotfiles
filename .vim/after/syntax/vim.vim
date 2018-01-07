highlight def link myVimAutoCmd vimAutoCmd
syntax keyword myVimAutoCmd Autocmd skipwhite nextgroup=vimAutoEventList

syntax match    vimAutoGroup contained "\S\+" nextgroup=vimAutoEventList skipwhite
syntax keyword  vimAutoCmd   au[tocmd] do[autocmd] doautoa[ll]  skipwhite nextgroup=vimAutoEventList,vimAutoGroup
