" Plugin Manager {{{1

" Install & Load Dein {{{2
let s:DEIN_BASE_PATH = $HOME . '/.vim/bundle/'
let s:DEIN_PATH      = expand(s:DEIN_BASE_PATH . 'repos/github.com/Shougo/dein.vim')
if !isdirectory(s:DEIN_PATH)
  if executable('git') && confirm('Install dein.vim or Launch vim immediately', "&Yes\n&No", 1)
    execute '!git clone --depth=1 https://github.com/Shougo/dein.vim' s:DEIN_PATH
  endif
endif

let &runtimepath .= ',' . s:DEIN_PATH
let g:dein#install_max_processes   = 20
let g:dein#install_process_timeout = 300
" }}}2

" Load Plugin {{{2
if dein#load_state(s:DEIN_BASE_PATH)
  call dein#begin(s:DEIN_BASE_PATH)

  " Dein {{{3
  call dein#add('Shougo/dein.vim')
  call dein#add('haya14busa/dein-command.vim')
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja')
  " }}}3

  " IDE {{{3
  call dein#add('neoclide/coc.nvim', {'merged':0, 'rev': 'release'})
  " }}}3

  " Language {{{3
  call dein#add('elzr/vim-json',                           {'lazy': 1, 'on_ft': 'json'})
  call dein#add('hail2u/vim-css3-syntax',                  {'lazy': 1, 'on_ft': 'css'})
  call dein#add('jparise/vim-graphql',                     {'lazy': 1, 'on_ft': ['graphql', 'javascript', 'typescript', 'typescriptreact', 'typescript.tsx']})
  call dein#add('leafgarland/typescript-vim',              {'lazy': 1, 'on_ft': ['typescript', 'typescriptreact', 'typescript.tsx']})
  call dein#add('othree/yajs.vim',                         {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('plasticboy/vim-markdown',                 {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('posva/vim-vue',                           {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('styled-components/vim-styled-components', {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'typescriptreact', 'typescript.tsx']})
  call dein#add('tpope/vim-rails',                         {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('yuki-ycino/ruby_hl_lvar.vim',             {'lazy': 1, 'on_ft': 'ruby'})
  " }}}3

  " Git {{{3
  call dein#add('lambdalisue/gina.vim')
  call dein#add('rhysd/committia.vim')
  call dein#add('rhysd/conflict-marker.vim')
  call dein#add('wting/gitsessions.vim')
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim')
  call dein#add('ozelentok/denite-gtags')

  call dein#add('junegunn/fzf', {'build': './install --bin', 'merged': 0})
  " call dein#add('yuki-ycino/fzf-preview.vim')
  call dein#local('~/repos/github.com/yuki-ycino', {}, ['fzf-preview.vim'])
  " }}}3

  " filer {{{3
  call dein#add('lambdalisue/fern.vim')

  call dein#add('lambdalisue/fern-renderer-devicons.vim')
  " }}}3

  " textobj & operator {{{3
  call dein#add('machakann/vim-sandwich')
  call dein#add('machakann/vim-swap') " g< g> i, a,

  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-operator-user')

  call dein#add('kana/vim-textobj-entire') " ie ae
  call dein#add('kana/vim-textobj-fold') " iz az
  call dein#add('kana/vim-textobj-indent') " ii ai
  call dein#add('kana/vim-textobj-line') " al il
  call dein#add('rhysd/vim-textobj-ruby') " ir ar
  call dein#add('thinca/vim-textobj-between') " i{char} a{char}

  call dein#add('mopp/vim-operator-convert-case',  {'lazy': 1, 'depends': 'vim-operator-user', 'on_map': '<Plug>'}) " cy
  call dein#add('yuki-ycino/vim-operator-replace', {'lazy': 1, 'depends': 'vim-operator-user', 'on_map': '<Plug>'}) " _
  " }}}3

  " Edit & Move & Search {{{3
  call dein#add('AndrewRadev/splitjoin.vim', {'lazy': 1, 'on_cmd': ['SplitJoinSplit', 'SplitJoinJoin']})
  call dein#add('LeafCage/yankround.vim')
  call dein#add('MattesGroeger/vim-bookmarks')
  call dein#add('cohama/lexima.vim',         {'lazy': 1, 'on_event': 'InsertEnter', 'hook_post_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('deris/vim-shot-f')
  call dein#add('easymotion/vim-easymotion')
  call dein#add('haya14busa/incsearch.vim')
  call dein#add('haya14busa/vim-asterisk',   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion')
  call dein#add('haya14busa/vim-metarepeat', {'lazy': 1, 'on_map': ['go', 'g.', '<Plug>']})
  call dein#add('junegunn/vim-easy-align',   {'lazy': 1, 'on_cmd': 'EasyAlign'})
  call dein#add('mg979/vim-visual-multi',    {'rev': 'test'})
  call dein#add('mhinz/vim-grepper',         {'lazy': 1, 'on_cmd': 'Grepper', 'on_map': '<Plug>'})
  call dein#add('mtth/scratch.vim',          {'lazy': 1, 'on_cmd': 'Scratch'})
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('osyo-manga/vim-jplus',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/accelerated-jk',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('ronakg/quickr-preview.vim')
  call dein#add('terryma/vim-expand-region', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-qfreplace',      {'lazy': 1, 'on_cmd': 'Qfreplace'})
  call dein#add('tommcdo/vim-exchange',      {'lazy': 1, 'on_map': {'n': ['cx', 'cxc', 'cxx'], 'x': ['X']}})
  call dein#add('tpope/vim-repeat')
  call dein#add('tyru/caw.vim'             , {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('unblevable/quick-scope')
  call dein#add('vim-scripts/Align',         {'lazy': 1, 'on_cmd': 'Align'})
  " }}}3

  " Appearance {{{3
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('RRethy/vim-hexokinase', {'build': 'make hexokinase'})
  call dein#add('Yggdroot/indentLine')
  call dein#add('andymass/vim-matchup')
  call dein#add('itchyny/lightline.vim')
  call dein#add('kamykn/spelunker.vim')
  call dein#add('luochen1990/rainbow')
  call dein#add('machakann/vim-highlightedundo')
  call dein#add('machakann/vim-highlightedyank')
  call dein#add('mopp/smartnumber.vim')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('ryanoasis/vim-devicons')
  call dein#add('wellle/context.vim')
  call dein#add('yuttie/comfortable-motion.vim')
  " }}}3

  " tmux {{{3
  call dein#add('christoomey/vim-tmux-navigator')
  " }}}3

  " Util {{{3
  call dein#add('AndrewRadev/linediff.vim',     {'lazy': 1, 'on_cmd': 'Linediff'})
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('dhruvasagar/vim-table-mode',   {'lazy': 1, 'on_cmd': 'TableModeToggle'})
  call dein#add('itchyny/vim-qfedit')
  call dein#add('jsfaint/gen_tags.vim')
  call dein#add('kana/vim-niceblock',           {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('kannokanno/previm',            {'lazy': 1, 'on_cmd': 'PrevimOpen'})
  call dein#add('lambdalisue/vim-manpager',     {'lazy': 1, 'on_cmd': ['Man', 'MANPAGER']})
  call dein#add('lambdalisue/vim-pager',        {'lazy': 1, 'on_cmd': 'PAGER'})
  call dein#add('moll/vim-bbye',                {'lazy': 1, 'on_cmd': ['Bdelete', 'Bwipeout']})
  call dein#add('osyo-manga/vim-brightest')
  call dein#add('osyo-manga/vim-gift')
  call dein#add('pocke/vim-automatic',          {'depends': 'vim-gift'})
  call dein#add('simnalamburt/vim-mundo',       {'lazy': 1, 'on_cmd': 'MundoToggle'})
  call dein#add('thinca/vim-localrc')
  call dein#add('thinca/vim-ref',               {'lazy': 1, 'on_cmd': 'Ref'})
  call dein#add('tyru/capture.vim',             {'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('tyru/vim-altercmd')
  call dein#add('voldikss/vim-floaterm')
  call dein#add('wesQ3/vim-windowswap',         {'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  " }}}3

  " Develop {{{3
  call dein#add('rbtnn/vim-vimscript_lasterror')
  call dein#add('thinca/vim-prettyprint')
  call dein#add('thinca/vim-quickrun')
  call dein#add('vim-jp/vital.vim', {'merged': 0})
  " }}}3

  " Color Theme {{{3
  call dein#add('cocopon/iceberg.vim')
  call dein#add('joshdick/onedark.vim')
  " }}}3

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
" }}}2

" Install Plugin {{{2
if dein#check_install() && confirm('Would you like to download some plugins ?', "&Yes\n&No", 1)
  call dein#install()
endif
" }}}2

" }}}1

" Global Settings {{{1

" Encoding {{{2
set encoding=utf-8
set fileencodings=utf-8,sjis,cp932,euc-jp
set fileformats=unix,mac,dos
set termencoding=utf-8
scriptencoding utf-8
" }}}2

" Easy autocmd {{{2
augroup MyVimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd MyVimrc <args>
" }}}2

" Mappings {{{2

"---------------------------------------------------------------------------|
" Commands \ Modes | Normal | Insert | Command | Visual | Select | Operator |
" map  / noremap   |    @   |   -    |    -    |   @    |   @    |    @     |
" nmap / nnoremap  |    @   |   -    |    -    |   -    |   -    |    -     |
" vmap / vnoremap  |    -   |   -    |    -    |   @    |   @    |    -     |
" omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    @     |
" xmap / xnoremap  |    -   |   -    |    -    |   @    |   -    |    -     |
" smap / snoremap  |    -   |   -    |    -    |   -    |   @    |    -     |
" map! / noremap!  |    -   |   @    |    @    |   -    |   -    |    -     |
" imap / inoremap  |    -   |   @    |    -    |   -    |   -    |    -     |
" cmap / cnoremap  |    -   |   -    |    @    |   -    |   -    |    -     |
"---------------------------------------------------------------------------"

"" Leader
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
noremap <Leader>      <Nop>
noremap <LocalLeader> <Nop>

"" Move beginning toggle
noremap <silent> <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'

"" Disable mark
nnoremap m <Nop>

"" BackSpace
imap <C-h> <BS>
cmap <C-h> <BS>

"" Yank
nnoremap Y y$

"" Disable s
noremap s <Nop>

"" Save
nnoremap <silent> <Leader>w :<C-u>update<CR>
nnoremap <silent> <Leader>W :<C-u>update!<CR>

"" Automatically indent with i and A
nnoremap <expr> i len(getline('.')) ? "i" : "cc"
nnoremap <expr> A len(getline('.')) ? "A" : "cc"

" Ignore registers
nnoremap x "_x

"" incsearch
" nnoremap / /\v

"" QuickFix
nnoremap [c :cprevious<CR>
nnoremap ]c :cnext<CR>

"" Location List
nnoremap [l :lprevious<CR>
nnoremap ]l :lnext<CR>

"" CommandLine
noremap! <C-a> <Home>
noremap! <C-b> <Left>
noremap! <C-d> <Del>
noremap! <C-e> <End>
noremap! <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" Indent
nnoremap < <<
nnoremap > >>
vnoremap < <gv
vnoremap > >gv|

"" Tab
nnoremap <silent> gt :<C-u>tablast <Bar> tabedit<CR>
nnoremap <silent> gd :<C-u>tabclose<CR>
nnoremap <silent> gh :<C-u>tabprevious<CR>
nnoremap <silent> gl :<C-u>tabnext<CR>

"" resize
nnoremap <Left>  :vertical resize -1<CR>
nnoremap <Right> :vertical resize +1<CR>
nnoremap <Up>    :resize -1<CR>
nnoremap <Down>  :resize +1<CR>

"" Macro
nnoremap Q @q

"" regexp
nnoremap <Leader>R "syiw:%s/\v<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>
nnoremap <Leader>r :%s/\v//g<Left><Left><Left>
vnoremap <Leader>r "sy:%s/\v<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>

"" Clipboard
nnoremap <silent> sc :<C-u>call system("pbcopy", @") <Bar> echo "Copied \" register to OS clipboard"<CR>
nnoremap <silent> sp :<C-u>let @" = substitute(system("pbpaste"), "\n\+$", "", "") <Bar> echo "Copied from OS clipboard to \" register"<CR>
vnoremap <silent> sp :<C-u>let @" = substitute(system("pbpaste"), "\n\+$", "", "") <Bar> echo "Copied from OS clipboard to \" register"<CR>gv
" }}}2

" Set Options {{{2

"" NeoVim
if has('nvim')
  if has('vim_starting') && empty(argv())
    syntax off
  endif

  let g:python_host_prog  = $HOME . '/.pyenv/shims/python2'
  let g:python3_host_prog = $HOME . '/.pyenv/shims/python3'

  set inccommand=nosplit

  AutoCmd CursorHold   * rshada | wshada
  AutoCmd TextYankPost * rshada | wshada

  AutoCmd FocusGained * checktime

  tnoremap <Esc> <C-\><C-n>
  AutoCmd TermOpen * set nonumber | set norelativenumber

  " block cursor for insert
  " set guicursor=

  " Set neovim embedded terminal colors
  let g:terminal_color_0  = '#1e2132'
  let g:terminal_color_1  = '#e27878'
  let g:terminal_color_2  = '#b4be82'
  let g:terminal_color_3  = '#e2a478'
  let g:terminal_color_4  = '#84a0c6'
  let g:terminal_color_5  = '#a093c7'
  let g:terminal_color_6  = '#89b8c2'
  let g:terminal_color_7  = '#c6c8d1'
  let g:terminal_color_8  = '#6b7089'
  let g:terminal_color_9  = '#e98989'
  let g:terminal_color_10 = '#c0ca8e'
  let g:terminal_color_11 = '#e9b189'
  let g:terminal_color_12 = '#91acd1'
  let g:terminal_color_13 = '#ada0d3'
  let g:terminal_color_14 = '#95c4ce'
  let g:terminal_color_15 = '#d2d4de'

  set termguicolors
  set pumblend=20
  set wildoptions+=pum
endif

"" Appearance
set belloff=all
set cmdheight=2
set concealcursor=nc
set conceallevel=2
set diffopt=internal,filler,algorithm:histogram,indent-heuristic,vertical
set display=lastline
set helplang=ja
set hidden
set hlsearch
set laststatus=2
set list listchars=tab:^\ ,trail:_,extends:>,precedes:<
set matchpairs+=<:>
set matchtime=1
set pumheight=40
set scrolloff=5
set showtabline=2
set spellcapcheck=
set spelllang=en,cjk
set synmaxcol=300
set virtualedit=all

"" Indent
set autoindent
set backspace=indent,eol,start
set breakindent
set expandtab
set nostartofline
set shiftwidth=2
set smartindent
set tabstop=2

AutoCmd FileType * setlocal formatoptions-=ro
AutoCmd FileType * setlocal formatoptions+=jBn

"" viminfo
set viminfo='1000,:1000

"" Search & Complete
set ignorecase
set regexpengine=2
set smartcase

"" Completion
set completeopt=menu,menuone,noinsert,noselect

"" Command
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan

"" Folding
set foldcolumn=1
set foldenable
set foldmethod=manual

"" FileType
set viewoptions=cursor,folds
set suffixesadd=.js,.ts,.rb

"" Diff
AutoCmd InsertLeave * if &l:diff | diffupdate | endif

"" Undo
set undofile
set undodir=~/.cache/vim/undo/

"" Swap
set swapfile
set directory=~/.cache/vim/swap/
AutoCmd SwapExists * let v:swapchoice = 'o'

"" Term
set shell=zsh
set lazyredraw
set ttyfast
set ttimeout
set timeoutlen=750
set ttimeoutlen=10

if !has('nvim')
  set term=xterm-256color
endif

if $TERM ==# 'screen'
  set t_Co=256
endif

"" Git Editor require neovim-remote
if has('nvim')
  let $GIT_EDITOR = 'nvr --remote-wait'
endif

"" Automatically Disable Paste Mode
AutoCmd InsertLeave * setlocal nopaste

"" Misc
set autoread
set updatetime=500

"" Turn off default plugins.
let g:loaded_gzip              = 1
let g:loaded_tar               = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zip               = 1
let g:loaded_zipPlugin         = 1
let g:loaded_rrhelper          = 1
let g:loaded_2html_plugin      = 1
let g:loaded_vimball           = 1
let g:loaded_vimballPlugin     = 1
let g:loaded_getscript         = 1
let g:loaded_getscriptPlugin   = 1
let g:loaded_netrw             = 1
let g:loaded_netrwPlugin       = 1
let g:loaded_netrwSettings     = 1
let g:loaded_netrwFileHandlers = 1

"" Highlight Annotation Comment
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|OPTIMIZE\|HACK\|REVIEW\|NOTE\|INFO\|TEMP\):')

" }}}2

" }}}1

" Command & Function {{{1

" Move cursor last position {{{2
AutoCmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
" }}}2

" highlight cursorline and cursorcolumn with timer {{{2
let g:highlight_cursor      = 1
let s:highlight_cursor_wait = 500

function! s:enter(...) abort
  if &filetype ==# 'list'
    return
  endif

  if g:highlight_cursor && get(b:, 'highlight_cursor', 1)
    setlocal cursorline cursorcolumn
  endif
  augroup highlight_cursor
    autocmd!
    autocmd CursorMoved,WinLeave * call s:leave()
  augroup END
endfunction

function! s:leave() abort
  setlocal nocursorline nocursorcolumn
  augroup highlight_cursor
    autocmd!
    autocmd CursorHold * call s:enter()
    autocmd WinEnter * call timer_start(s:highlight_cursor_wait, function('s:enter'))
  augroup END
endfunction

AutoCmd VimEnter * call timer_start(s:highlight_cursor_wait, function('s:enter'))

function! s:cursor_highlight_toggle()
  if g:highlight_cursor
    let g:highlight_cursor = 0
    setlocal nocursorline nocursorcolumn
  else
    let g:highlight_cursor = 1
    setlocal cursorline cursorcolumn
  endif
endfunction

command! CursorHighlightToggle call <SID>cursor_highlight_toggle()
" }}}2

" Auto mkdir {{{2
AutoCmd BufWritePre * call <SID>auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
" }}}2

" ToggleSyntaxHighLight {{{2
function! s:syntax_highlight_toggle()
  if exists('g:syntax_on')
    syntax off
  else
    syntax enable
  endif
endfunction

command! SyntaxHighlightToggle call <SID>syntax_highlight_toggle()
" }}}2

" ToggleQuickfix {{{2
function! s:toggle_quickfix()
  let l:_ = winnr('$')
  cclose
  if l:_ == winnr('$')
    botright copen
    " call g:Set_quickfix_keymap()
  endif
endfunction

command! ToggleQuickfix call <SID>toggle_quickfix()
nnoremap <silent> <LocalLeader>q :<C-u>ToggleQuickfix<CR>
" }}}2

" ToggleLocationList {{{2
function! s:toggle_location_list()
  let l:_ = winnr('$')
  lclose
  if l:_ == winnr('$')
    botright lopen
    " call g:Set_locationlist_keymap()
  endif
endfunction

command! ToggleLocationList call <SID>toggle_location_list()
nnoremap <silent> <LocalLeader>l :<C-u>ToggleLocationList<CR>
" }}}2

" HelpEdit & HelpView {{{2
function! s:option_to_view()
  setlocal buftype=help nomodifiable readonly
  setlocal nolist
  setlocal colorcolumn=
  setlocal conceallevel=2
endfunction

function! s:option_to_edit()
  setlocal buftype= modifiable noreadonly
  setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
  setlocal colorcolumn=+1
  setlocal conceallevel=0
endfunction

command! HelpEdit call <SID>option_to_edit()
command! HelpView call <SID>option_to_view()
" }}}2

" HighlightInfo {{{2
function! s:get_syn_id(transparent)
  let synid = synID(line('.'), col('.'), 1)
  return a:transparent ? synIDtrans(synid) : synid
endfunction

function! s:get_syn_name(synid)
  return synIDattr(a:synid, 'name')
endfunction

function! s:get_highlight_info()
  execute 'highlight ' . s:get_syn_name(s:get_syn_id(0))
  execute 'highlight ' . s:get_syn_name(s:get_syn_id(1))
endfunction

command! HighlightInfo call s:get_highlight_info()
" }}}2

" VSCode {{{2
command! VSCode execute printf('!code -r "%s"', expand('%'))
" }}}2

" }}}1

" FileType Settings {{{1

" FileType {{{2

" Intent {{{3
AutoCmd FileType javascript      setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript      setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescriptreact setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript.tsx  setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vue             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType ruby            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType eruby           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType python          setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType go              setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType json            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType markdown        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType html            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType css             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType scss            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vim             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType sh              setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType zsh             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" Fold {{{3
AutoCmd FileType javascript      setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType typescript      setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType typescriptreact setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType typescript.tsx  setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType vue             setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType ruby            setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType python          setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType go              setlocal foldmethod=syntax foldlevel=100
" }}}3

" iskeyword {{{3
AutoCmd FileType vue  setlocal iskeyword+=$ iskeyword+=& iskeyword+=- iskeyword+=? iskeyword-=/
AutoCmd FileType ruby setlocal iskeyword+=@ iskeyword+=! iskeyword+=? iskeyword+=&
AutoCmd FileType html setlocal iskeyword+=-
AutoCmd FileType css  setlocal iskeyword+=- iskeyword+=#
AutoCmd FileType scss setlocal iskeyword+=- iskeyword+=# iskeyword+=$
AutoCmd FileType vim  setlocal iskeyword+=-
AutoCmd FileType sh   setlocal iskeyword+=-
AutoCmd FileType zsh  setlocal iskeyword+=-
" }}}3

" Set FileType {{{3
AutoCmd BufNewFile,BufRead *.js             set filetype=javascript
AutoCmd BufNewFile,BufRead *.erb            set filetype=eruby
AutoCmd BufNewFile,BufRead *.cson           set filetype=coffee
AutoCmd BufNewFile,BufRead .babelrc         set filetype=json
AutoCmd BufNewFile,BufRead .eslintrc        set filetype=json
AutoCmd BufNewFile,BufRead .stylelintrc     set filetype=json
AutoCmd BufNewFile,BufRead .prettierrc      set filetype=json
AutoCmd BufNewFile,BufRead .tern-project    set filetype=json
AutoCmd BufNewFile,BufRead .pryrc           set filetype=ruby
AutoCmd BufNewFile,BufRead Gemfile          set filetype=ruby
AutoCmd BufNewFile,BufRead Vagrantfile      set filetype=ruby
AutoCmd BufNewFile,BufRead Schemafile       set filetype=ruby
AutoCmd BufNewFile,BufRead .gitconfig.local set filetype=gitconfig
" }}}3

" }}}2

" HTML & eruby {{{2
function! s:map_html_keys()
  inoremap <silent> <buffer> \\ \
  inoremap <silent> <buffer> \& &amp;
  inoremap <silent> <buffer> \< &lt;
  inoremap <silent> <buffer> \> &gt;
  inoremap <silent> <buffer> \- &#8212;
  inoremap <silent> <buffer> \<Space> &nbsp;
  inoremap <silent> <buffer> \` &#8216;
  inoremap <silent> <buffer> \' &#8217;
  inoremap <silent> <buffer> \" &#8221;
endfunction
AutoCmd FileType html,eruby call <SID>map_html_keys()
" }}}2

" vim {{{2
AutoCmd FileType vim setlocal keywordprg=:help
" }}}2

" shell {{{2
AutoCmd FileType sh,bash,zsh,man setlocal keywordprg=man
" }}}2

" Set quit {{{2
AutoCmd FileType help nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType diff nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType man  nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType git  nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}2

" }}}1

" Command Line Window {{{1
set cedit=\<C-c>

" nnoremap : q:
" xnoremap : q:
" nnoremap q: :
" xnoremap q: :

AutoCmd CmdwinEnter * call <SID>init_cmdwin()

function! s:init_cmdwin() abort
  setlocal number | setlocal norelativenumber
  nnoremap <buffer> <CR> <CR>
  nnoremap <buffer> <silent> q :<C-u>quit<CR>
  inoremap <buffer> <C-c> <Esc>l<C-c>

  " nnoremap <silent> <buffer> dd :<C-u>rviminfo<CR>:call histdel(getcmdwintype(), line('.') - line('$'))<CR>:wviminfo!<CR>dd
  startinsert!
endfunction
" }}}1

" Plugin Settings {{{1

" Eager Load {{{2

" altercmd {{{3
if dein#tap('vim-altercmd')
  call altercmd#load()
  AlterCommand!          ee              e!
  AlterCommand! <cmdwin> ee              e!
  AlterCommand!          high[lightinfo] HighlightInfo
  AlterCommand! <cmdwin> high[lightinfo] HighlightInfo
  AlterCommand!          vs[code]        VSCode
  AlterCommand! <cmdwin> vs[code]        VSCode
  AlterCommand!          co[de]          VSCode
  AlterCommand! <cmdwin> co[de]          VSCode
endif
" }}}3

" }}}2

" Plugin Manager {{{2

" dein {{{3
AlterCommand!          dein Dein
AlterCommand! <cmdwin> dein Dein
" }}}

" }}}2

" IDE {{{2
AlterCommand!          list CocList
AlterCommand! <cmdwin> list CocList

let g:coc_global_extensions = [
\ 'coc-calc',
\ 'coc-css',
\ 'coc-cssmodules',
\ 'coc-diagnostic',
\ 'coc-docker',
\ 'coc-eslint',
\ 'coc-git',
\ 'coc-go',
\ 'coc-html',
\ 'coc-json',
\ 'coc-markdownlint',
\ 'coc-prettier',
\ 'coc-python',
\ 'coc-sh',
\ 'coc-snippets',
\ 'coc-solargraph',
\ 'coc-stylelint',
\ 'coc-tabnine',
\ 'coc-tailwindcss',
\ 'coc-tsserver',
\ 'coc-vetur',
\ 'coc-vimlsp',
\ 'coc-yaml',
\ ]

" Manual completion
inoremap <silent> <expr> <C-Space> coc#refresh()

" Move diagnostics
nmap <silent> <LocalLeader>[ <Plug>(coc-diagnostic-prev)
nmap <silent> <LocalLeader>] <Plug>(coc-diagnostic-next)

" Snippet map
let g:coc_snippet_next = '<C-f>'
let g:coc_snippet_prev = '<C-b>'

" Git
nmap gp <Plug>(coc-git-prevchunk)
nmap gn <Plug>(coc-git-nextchunk)

" keymap
nnoremap K               :call <SID>show_documentation()<CR>
nmap     <LocalLeader>p  <Plug>(coc-diagnostic-prev)
nmap     <LocalLeader>n  <Plug>(coc-diagnostic-next)
nmap     <LocalLeader>d  <Plug>(coc-definition)
nmap     <LocalLeader>t  <Plug>(coc-type-definition)
nmap     <LocalLeader>i  <Plug>(coc-implementation)
nmap     <LocalLeader>rf <Plug>(coc-references)
nmap     <LocalLeader>rn <Plug>(coc-rename)
nmap     <LocalLeader>a  <Plug>(coc-fix-current)
nmap     <Leader>a       <Plug>(coc-format)
xmap     <Leader>a       <Plug>(coc-format-selected)

AutoCmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

AutoCmd FileType typescript,typescript.tsx setlocal tagfunc=CocTagFunc
" }}}2

" Language {{{2

" gen_tags {{{3
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#gtags_auto_gen = 1
let g:gen_tags#ctags_opts = '--excmd=number'
" }}}3

" json {{{3
let g:vim_json_syntax_conceal = 0
" }}}3

" markdown {{{3
let g:vim_markdown_folding_disabled        = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_conceal                 = 0
let g:vim_markdown_conceal_code_blocks     = 0
let g:vim_markdown_auto_insert_bullets     = 0
let g:vim_markdown_new_list_item_indent    = 0
" }}}3

" typescript {{{3
AutoCmd BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx
" }}}3

" vim {{{3
let g:vimsyntax_noerror = 1
let g:vim_indent_cont   = 0
" }}}3

" vue {{{3
AutoCmd FileType vue syntax sync fromstart
" }}}3

" }}}2

" Completion & Fuzzy Finder {{{2

" Denite {{{3
AlterCommand!          d[enite] Denite
AlterCommand! <cmdwin> d[enite] Denite

if dein#tap('denite.nvim')
  " Denite

  "" highlight
  call denite#custom#option('default', 'prompt', '>')
  call denite#custom#option('default', 'mode', 'insert')
  call denite#custom#option('default', 'highlight_matched', 'Keyword')
  call denite#custom#option('default', 'highlight_mode_normal', 'DeniteLine')
  call denite#custom#option('default', 'highlight_mode_insert', 'DeniteLine')
  call denite#custom#option('default', 'statusline', v:false)

  " Define mappings
  function! s:denite_settings() abort
    nnoremap <silent> <expr> <buffer> i       denite#do_map('open_filter_buffer')
    nnoremap <silent> <expr> <buffer> <CR>    denite#do_map('do_action')
    nnoremap <silent> <expr> <buffer> <C-g>   denite#do_map('quit')
    nnoremap <silent> <expr> <buffer> q       denite#do_map('quit')
    nnoremap <silent> <expr> <buffer> ZQ      denite#do_map('quit')
    nnoremap <silent>        <buffer> <C-n>   j
    nnoremap <silent>        <buffer> <C-p>   k
    nnoremap <silent> <expr> <buffer> <Space> denite#do_map('toggle_select') . 'j'
    nnoremap <silent> <expr> <buffer> d       denite#do_map('do_action', 'delete')
    nnoremap <silent> <expr> <buffer> p       denite#do_map('do_action', 'preview')
  endfunction

  function! s:denite_filter_settings() abort
    nnoremap <silent> <expr> <buffer> <C-g> denite#do_map('quit')
    nnoremap <silent> <expr> <buffer> q     denite#do_map('quit')
    nnoremap <silent> <expr> <buffer> ZQ    denite#do_map('quit')
    inoremap <silent>        <buffer> <C-g> <Esc>
  endfunction

  AutoCmd FileType denite        call s:denite_settings()
  AutoCmd FileType denite-filter call s:denite_filter_settings()

  "" menu
  let s:menus = {}
  let s:menus.toggle = { 'description': 'Toggle Command' }
  let s:menus.toggle.command_candidates = [
  \ ['Toggle CursorHighlight   [CursorHighlightToggle]',     'CursorHighlightToggle'  ],
  \ ['Toggle SmartNumber       [SmartNumberToggleRelative]', 'SNumbersToggleRelative' ],
  \ ['Toggle Context           [ContextToggleWindow]',       'ContextToggleWindow'    ],
  \ ['Toggle ComfortableMotion [ComfortableMotionToggle]',   'ToggleComfortableMotion'],
  \ ['Toggle IndentLine        [IndentLinesToggle]',         'IndentLinesToggle'      ],
  \ ['Toggle SyntaxHighlight   [SyntaxHighlightToggle]',     'SyntaxHighlightToggle'  ],
  \ ['Toggle TableMode         [TableMode]',                 'TableModeToggle'        ],
  \ ]
  call denite#custom#var('menu', 'menus', s:menus)
  nnoremap <silent> <Leader>t :<C-u>Denite menu:toggle<CR>

  "" resume
  nnoremap <silent> dr :<C-u>Denite -resume<CR>
endif

" }}}3

" fzf-preview {{{3
let g:fzf_preview_command                      = 'bat --color=always --style=grid --theme=ansi-dark {-1}'
let g:fzf_preview_filelist_postprocess_command = 'gxargs -d "\n" exa --color=always'
let g:fzf_preview_use_dev_icons                = 1
let $FZF_PREVIEW_PREVIEW_BAT_THEME             = 'ansi-dark'

nnoremap <silent> <Leader>p         :<C-u>FzfPreviewFromResources project_mru git<CR>
nnoremap <silent> <Leader>gs        :<C-u>FzfPreviewGitStatus -processors=g:fzf_preview_gina_processors<CR>
nnoremap <silent> <Leader>gf        :<C-u>FzfPreviewFromResources project_mru git -add-fzf-arg=--select-1 -add-fzf-arg=--query="'<C-r>=substitute(expand('<cfile>'), '^\.\+/', '', '')<CR>"<CR>
nnoremap <silent> <Leader>b         :<C-u>FzfPreviewBuffers -processors=g:fzf_preview_buffer_delete_processors<CR>
nnoremap <silent> <Leader>B         :<C-u>FzfPreviewAllBuffers -processors=g:fzf_preview_buffer_delete_processors<CR>
nnoremap <silent> <Leader>o         :<C-u>FzfPreviewFromResources buffer project_mru<CR>
nnoremap <silent> <Leader>O         :<C-u>FzfPreviewFromResources buffer project_mrw<CR>
nnoremap <silent> <Leader><C-o>     :<C-u>FzfPreviewJumps<CR>
nnoremap <silent> <Leader>g;        :<C-u>FzfPreviewChanges<CR>
nnoremap <silent> <Leader>/         :<C-u>FzfPreviewLines -resume -add-fzf-arg=--no-sort -add-fzf-arg=--query="'"<CR>
nnoremap <silent> <Leader><Leader>/ :<C-u>FzfPreviewBufferLines -resume -add-fzf-arg=--no-sort -add-fzf-arg=--query="'"<CR>
nnoremap <silent> <Leader>*         :<C-u>FzfPreviewLines -add-fzf-arg=--no-sort -add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap          gr                :<C-u>FzfPreviewProjectGrep<Space>
xnoremap          gr                "sy:FzfPreviewProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap          gR                :<C-u>FzfPreviewProjectCommandGrep<Space>
xnoremap          gR                "sy:FzfPreviewProjectCommandGrep<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <silent> <Leader><C-]>     :<C-u>FzfPreviewCtags -add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap <silent> <Leader>m         :<C-u>FzfPreviewBookmarks -resume<CR>

nnoremap <silent> <LocalLeader>b              :<C-u>FzfPreviewBufferTags<CR>
nnoremap <silent> <LocalLeader><LocalLeader>q :<C-u>FzfPreviewQuickFix<CR>
nnoremap <silent> <LocalLeader><LocalLeader>l :<C-u>FzfPreviewLocationList<CR>

augroup fzf_preview
  autocmd!
  autocmd User fzf_preview#initialized call s:fzf_preview_settings()
augroup END

function! s:buffers_delete_from_lines(lines) abort
  for line in a:lines
    let matches = matchlist(line, '^buffer \(\d\+\)$')
    if len(matches) >= 1
      execute 'Bdelete! ' . matches[1]
    else
      execute 'Bdelete! ' . line
    endif
  endfor
endfunction

function! s:gina_add(paths) abort
  for path in a:paths
    execute 'silent Gina add ' . path
  endfor

  echomsg 'Git add ' . join(a:paths, ', ')
endfunction

function! s:gina_reset(paths) abort
  for path in a:paths
    execute 'silent Gina reset ' . path
  endfor

  echomsg 'Git reset ' . join(a:paths, ', ')
endfunction

function! s:gina_patch(paths) abort
  for path in a:paths
    execute 'silent Gina patch ' . path
  endfor

  echomsg 'Git add --patch ' . join(a:paths, ', ')
endfunction

function! s:fzf_preview_settings() abort
  let g:fzf_preview_custom_default_processors = fzf_preview#resource_processor#get_default_processors()
  call remove(g:fzf_preview_custom_default_processors, 'ctrl-x')
  let g:fzf_preview_custom_default_processors['ctrl-s'] = function('fzf_preview#resource_processor#split')

  let g:fzf_preview_buffer_delete_processors = fzf_preview#resource_processor#get_default_processors()
  let g:fzf_preview_buffer_delete_processors['ctrl-x'] = function('s:buffers_delete_from_lines')

  let g:fzf_preview_gina_processors = fzf_preview#resource_processor#get_processors()
  let g:fzf_preview_gina_processors['ctrl-a'] = function('s:gina_add')
  let g:fzf_preview_gina_processors['ctrl-r'] = function('s:gina_reset')
  let g:fzf_preview_gina_processors['ctrl-c'] = function('s:gina_patch')
endfunction

AutoCmd FileType fzf let b:highlight_cursor = 0

" FzfPreviewYankround {{{4
function! FzfPreviewYankround(addtional, args)
  let histories = map(copy(g:_yankround_cache), 'split(v:val, "\t", 1)')
  let source = map(histories, { key, val -> key + 1 . ' ' . val[0] . ' ' . val[1] })

  let optional = '--no-sort --with-nth 3..'
  let preview = 'preview_yankround_register {1}'

  return{
  \ 'source': source,
  \ 'sink': function('<SID>register_history_sink'),
  \ 'options': fzf_preview#command#get_command_options('RegisterHistory', preview, optional)
  \ }
endfunction

function! s:register_history_sink(lines)
  let l:parts = split(a:lines[1], ' ', 1)
  call setreg('"', join(l:parts[2:], ' '), l:parts[0])
endfunction

command! FzfPreviewYankround :call fzf_preview#runner#fzf_run(fzf_preview#initializer#initialize('FzfPreviewYankround', {}, <f-args>))
nnoremap <silent> (ctrlp) :<C-u>FzfPreviewYankround<CR>
" }}}4

" FzfPreviewBookmarks {{{4
command! -nargs=* -complete=customlist,fzf_preview#args#complete_options FzfPreviewBookmarks
  \ :call fzf_preview#runner#fzf_run(fzf_preview#initializer#initialize('FzfPreviewBookmarks', {}, <f-args>))

function! FzfPreviewBookmarks(additional, args) abort
  let source = fzf_preview#converter#convert_for_fzf(filter(map(bm#location_list(), {
  \ _, b -> s:bookmarks_format_line(b)
  \ }), {
  \ _, b -> b !=# ''
  \ }), 1)

  let optional = '--delimiter :'
  let preview = g:fzf_preview_grep_preview_cmd . ' {}'

  return {
  \ 'source': source,
  \ 'sink': function('fzf_preview#handler#handle_grep'),
  \ 'options': fzf_preview#command#get_command_options('Bookmarks', preview, optional)
  \ }
endfunction

function! s:bookmarks_format_line(line) abort
  let line = split(a:line, ':')
  let filename = fnamemodify(line[0], ':.')
  if !filereadable(filename)
    return ''
  endif

  let line_number = line[1]
  let text = line[2]

  if text ==# 'Annotation'
    let comment = line[3]
  else
    let text = join(line[2:], ':')
  endif

  if text !=# 'Annotation'
    return filename . ':' . line_number . ':' . text
  else
    return filename . ':' . line_number . ':' . text . ':' . comment
  endif
endfunction
" }}}4

" }}}3

" lexima {{{3
if dein#tap('lexima.vim')

  let g:lexima_map_escape = ''
  let g:lexima_enable_endwise_rules = 0

  function! Hook_on_post_source_lexima() abort
    let s:rules = []

    "" Parenthesis
    let s:rules += [
    \ { 'char': '(',     'at': '(\%#)', 'input': '<Del>',      },
    \ { 'char': '(',     'at': '(\%#',                         },
    \ { 'char': '<C-h>', 'at': '(\%#)', 'input': '<BS><Del>',  },
    \ { 'char': '<BS>',  'at': '(\%#)', 'input': '<BS><Del>',  },
    \ { 'char': '<TAB>', 'at': '\%#)',  'input': '<Right>',    },
    \ ]

    "" Brace
    let s:rules += [
    \ { 'char': '{',     'at': '{\%#}', 'input': '<Del>',     },
    \ { 'char': '{',     'at': '{\%#',                        },
    \ { 'char': '<C-h>', 'at': '{\%#}', 'input': '<BS><Del>', },
    \ { 'char': '<BS>',  'at': '{\%#}', 'input': '<BS><Del>', },
    \ { 'char': '<TAB>', 'at': '\%#}',  'input': '<Right>',   },
    \ ]

    "" Bracket
    let s:rules += [
    \ { 'char': '[',     'at': '\[\%#\]', 'input': '<Del>',     },
    \ { 'char': '[',     'at': '\[\%#',                         },
    \ { 'char': '<C-h>', 'at': '\[\%#\]', 'input': '<BS><Del>', },
    \ { 'char': '<BS>',  'at': '\[\%#\]', 'input': '<BS><Del>', },
    \ { 'char': '<TAB>', 'at': '\%#\]',   'input': '<Right>',   },
    \ ]

    "" Sinble Quote
    let s:rules += [
    \ { 'char': "'",     'at': "'\\%#'", 'input': '<Del>',     },
    \ { 'char': "'",     'at': "'\\%#",                        },
    \ { 'char': "'",     'at': "''\\%#",                       },
    \ { 'char': '<C-h>', 'at': "'\\%#'", 'input': '<BS><Del>', },
    \ { 'char': '<BS>',  'at': "'\\%#'", 'input': '<BS><Del>', },
    \ { 'char': '<TAB>', 'at': "\\%#'",  'input': '<Right>',   },
    \ ]

    "" Double Quote
    let s:rules += [
    \ { 'char': '"',     'at': '"\%#"', 'input': '<Del>',     },
    \ { 'char': '"',     'at': '"\%#',                        },
    \ { 'char': '"',     'at': '""\%#',                       },
    \ { 'char': '<C-h>', 'at': '"\%#"', 'input': '<BS><Del>', },
    \ { 'char': '<BS>',  'at': '"\%#"', 'input': '<BS><Del>', },
    \ { 'char': '<TAB>', 'at': '\%#"',  'input': '<Right>',   },
    \ ]

    "" Back Quote
    let s:rules += [
    \ { 'char': '`',     'at': '`\%#`', 'input': '<Del>',     },
    \ { 'char': '`',     'at': '`\%#',                        },
    \ { 'char': '`',     'at': '``\%#',                       },
    \ { 'char': '<C-h>', 'at': '`\%#`', 'input': '<BS><Del>', },
    \ { 'char': '<BS>',  'at': '`\%#`', 'input': '<BS><Del>', },
    \ { 'char': '<TAB>', 'at': '\%#`',  'input': '<Right>',   },
    \ ]

    "" ruby
    let s:rules += [
    \ { 'filetype': ['ruby'], 'char': '<CR>',  'at': '^\s*\%(module\|def\|class\|if\|unless\)\s\w\+\((.*)\)\?\%#$', 'input': '<CR>',         'input_after': 'end',          },
    \ { 'filetype': ['ruby'], 'char': '<CR>',  'at': '^\s*\%(begin\)\s*\%#',                                        'input': '<CR>',         'input_after': 'end',          },
    \ { 'filetype': ['ruby'], 'char': '<CR>',  'at': '\%(^\s*#.*\)\@<!do\%(\s*|.*|\)\?\s*\%#',                      'input': '<CR>',         'input_after': 'end',          },
    \ { 'filetype': ['ruby'], 'char': '<Bar>', 'at': 'do\%#',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby'], 'char': '<Bar>', 'at': 'do\s\%#',                                                     'input': '<Bar>',        'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby'], 'char': '<Bar>', 'at': '{\%#}',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><Space>', },
    \ { 'filetype': ['ruby'], 'char': '<Bar>', 'at': '{\s\%#\s}',                                                   'input': '<Bar>',        'input_after': '<Bar><Space>', },
    \ ]

    "" eruby
    let s:rules += [
    \ { 'filetype': 'eruby', 'char': '%',     'at': '<\%#',         'input': '%<Space>',                        'input_after': '<Space>%>',                 },
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#',        'input': '=<Space><Right>',                 'input_after': '<Space>%>',                 },
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\s\%#\s%>',  'input': '<Left>=<Right>',                                                              },
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#.\+%>',                                                                           'priority': 10, },
    \ { 'filetype': 'eruby', 'char': '<C-h>', 'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
    \ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
    \ { 'filetype': 'eruby', 'char': '<C-h>', 'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
    \ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
    \ ]

    "" markdown
    let s:rules += [
    \ { 'filetype': 'markdown', 'char': '`',       'at': '``\%#',                                                                        'input_after': '<CR><CR>```', 'priority': 10, },
    \ { 'filetype': 'markdown', 'char': '#',       'at': '^\%#\%(#\)\@!',                  'input': '#<Space>'                                                                         },
    \ { 'filetype': 'markdown', 'char': '#',       'at': '#\s\%#',                         'input': '<BS>#<Space>',                                                                    },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^#\s\%#',                        'input': '<BS><BS>'                                                                         },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '##\s\%#',                        'input': '<BS><BS><Space>',                                                                 },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^#\s\%#',                        'input': '<BS><BS>'                                                                         },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '##\s\%#',                        'input': '<BS><BS><Space>',                                                                 },
    \ { 'filetype': 'markdown', 'char': '-',       'at': '^\s*\%#',                        'input': '-<Space>',                                                                        },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\%#',                     'input': '<Home><Tab><End>',                                                                },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\w.*\%#',                 'input': '<Home><Tab><End>',                                                                },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\%#',                    'input': '<Home><Del><Del><End>',                                                           },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\w.*\%#',                'input': '<Home><Del><Del><End>',                                                           },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\w.*\%#',                    'input': '',                                                                                },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^-\s\%#',                        'input': '<C-w><BS>',                                                                       },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><BS>',                                                                  },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\%#',                        'input': '<C-w><BS>',                                                                       },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><BS>',                                                                  },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\%#',                        'input': '<C-w><CR>',                                                                       },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><CR>',                                                                  },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\w.*\%#',                 'input': '<CR>-<Space>',                                                                    },
    \ { 'filetype': 'markdown', 'char': '[',       'at': '^\s*-\s\%#',                     'input': '<Left><Space>[]<Left>',                                                           },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\%#\]\s',               'input': '<Home><Tab><End><Left><Left>',                                                    },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\%#\]\s',                  'input': '',                                                                                },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\%#\]\s',              'input': '<Home><Del><Del><End><Left><Left>',                                               },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s*-\s\[\%#\]',                 'input': '<BS><Del><Del>',                                                                  },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s*-\s\[\%#\]',                 'input': '<BS><Del><Del>',                                                                  },
    \ { 'filetype': 'markdown', 'char': '<Space>', 'at': '^\s*-\s\[\%#\]',                 'input': '<Space><End>',                                                                    },
    \ { 'filetype': 'markdown', 'char': 'x',       'at': '^\s*-\s\[\%#\]',                 'input': 'x<End>',                                                                          },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\%#\]',                    'input': '<End><C-w><C-w><C-w><CR>',                                                        },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\%#\]',                'input': '<End><C-w><C-w><C-w><C-w><CR>',                                                   },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\%#',      'input': '<Home><Tab><End>',                                                                },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<Home><Tab><End>',                                                                },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<Home><Del><Del><End>',                                                           },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\w.*\%#', 'input': '<Home><Del><Del><End>',                                                           },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\(\s\|x\)\]\s\w.*\%#',     'input': '',                                                                                },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><BS>',                                                             },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><BS>',                                                        },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><BS>',                                                             },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><BS>',                                                        },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><CR>',                                                             },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><CR>',                                                        },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<CR>-<Space>[',                     'input_after': ']<Space>',                    },
    \ ]

    "" vim
    let s:rules += [
    \ { 'filetype': 'vim', 'char': '{', 'at': '^".*{\%#$', 'input': '{{', 'input_after': '<CR>" }}}', 'priority': 10, },
    \ ]

    "" shell
    let s:rules += [
    \ { 'filetype': ['sh', 'zsh'], 'char': '[', 'at': '\[\%#\]', 'input': '[<Space>', 'input_after': '<Space>]', 'priority': 10 },
    \ ]

    for s:rule in s:rules
      call lexima#add_rule(s:rule)
    endfor
  endfunction
endif
" }}}3

" }}}2

" Git {{{2

" gina {{{3
AlterCommand!          git   Gina
AlterCommand! <cmdwin> git   Gina
AlterCommand!          gina  Gina
AlterCommand! <cmdwin> gina  Gina
AlterCommand!          gs    Gina<Space>status
AlterCommand! <cmdwin> gs    Gina<Space>status
AlterCommand!          gci   Gina<Space>commit
AlterCommand! <cmdwin> gci   Gina<Space>commit
AlterCommand!          gd    Gina<Space>diff
AlterCommand! <cmdwin> gd    Gina<Space>diff
AlterCommand!          gdc   Gina<Space>diff<Space>--cached
AlterCommand! <cmdwin> gdc   Gina<Space>diff<Space>--cached
AlterCommand!          gco   Gina<Space>checkout
AlterCommand! <cmdwin> gco   Gina<Space>checkout
AlterCommand!          log   Gina<Space>log
AlterCommand! <cmdwin> log   Gina<Space>log
AlterCommand!          blame Gina<Space>blame
AlterCommand! <cmdwin> blame Gina<Space>blame

AutoCmd VimEnter * call s:gina_settings()

function! s:gina_settings()
  call gina#custom#command#option('status', '--short')
  call gina#custom#command#option('/\%(status\|commit\|branch\)', '--opener', 'split')

  call gina#custom#command#option('/\%(status\|changes\)', '--ignore-submodules')
  call gina#custom#command#option('status', '--branch')
  call gina#custom#command#option('branch', '-v', 'v')
  call gina#custom#command#option('branch', '--all')
  call gina#custom#mapping#nmap('status', '<C-j>', ':TmuxNavigateDown<CR>', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('status', '<C-k>', ':TmuxNavigateUp<CR>',   {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#vmap('show', 'p', ':diffput<CR>', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#vmap('show', 'o', ':diffget<CR>', {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('blame', '<C-l>', ':TmuxNavigateRight<CR>',    {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', '<C-r>', '<Plug>(gina-blame-redraw)', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', 'j',     'j<Plug>(gina-blame-echo)')
  call gina#custom#mapping#nmap('blame', 'k',     'k<Plug>(gina-blame-echo)')

  call gina#custom#action#alias('/\%(blame\|log\|reflog\)', 'preview', 'topleft show:commit:preview')
  call gina#custom#mapping#nmap('/\%(blame\|log\|reflog\)', 'p',       ":<C-u>call gina#action#call('preview')<CR>", {'noremap': 1, 'silent': 1})

  call gina#custom#execute('/\%(ls\|log\|reflog\|grep\)',                 'setlocal noautoread')
  call gina#custom#execute('/\%(status\|branch\|ls\|log\|reflog\|grep\)', 'setlocal cursorline')

  call gina#custom#mapping#nmap('/\%(status\|commit\|branch\|ls\|log\|reflog\|grep\)', 'q', 'ZQ', {'nnoremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('log', 'yy', ":<C-u>call gina#action#call('yank:rev')<CR>", {'noremap': 1, 'silent': 1})
  " require floaterm
  call gina#custom#mapping#nmap('log', 'R', ":<C-u>call gina#action#call('yank:rev')<CR>:FloatermNew git rebase -i <C-r>\"<CR>", {'noremap': 1, 'silent': 1})
endfunction
" }}}3

" gitsessions {{{3
AlterCommand!          gss GitSessionSave
AlterCommand! <cmdwin> gss GitSessionSave
AlterCommand!          gsl GitSessionLoad
AlterCommand! <cmdwin> gsl GitSessionLoad
AlterCommand!          gsd GitSessionDelete
AlterCommand! <cmdwin> gsd GitSessionDelete

let g:gitsessions_disable_auto_load = 1
" }}}3

" }}}2

" filer {{{2

" fern {{{3
let g:fern#disable_default_mappings = 1
let g:fern#drawer_width = 40
let g:fern#renderer = 'devicons'

nnoremap <silent> <Leader>e :<C-u>Fern . -drawer <CR>
nnoremap <silent> <Leader>E :<C-u>Fern . -drawer -reveal=%<CR>

function! s:fern_settings() abort
  nmap <silent> <buffer> <expr> <Plug>(fern-expand-or-collapse) fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")

  nmap <silent> <buffer> <nowait> a     <Plug>(fern-choice)
  nmap <silent> <buffer> <nowait> <CR>  <Plug>(fern-action-open:select)
  nmap <silent> <buffer> <nowait> t     <Plug>(fern-expand-or-collapse)
  nmap <silent> <buffer> <nowait> l     <Plug>(fern-open-or-enter)
  nmap <silent> <buffer> <nowait> h     <Plug>(fern-action-leave)
  nmap <silent> <buffer> <nowait> x     <Plug>(fern-action-mark-toggle)
  nmap <silent> <buffer> <nowait> x     <Plug>(fern-action-mark-toggle)
  vmap <silent> <buffer> <nowait> x     <Plug>(fern-action-mark-toggle)
  nmap <silent> <buffer> <nowait> N     <Plug>(fern-action-new-file)
  nmap <silent> <buffer> <nowait> K     <Plug>(fern-action-new-dir)
  nmap <silent> <buffer> <nowait> d     <Plug>(fern-action-trash)
  nmap <silent> <buffer> <nowait> r     <Plug>(fern-action-rename)
  nmap <silent> <buffer> <nowait> c     <Plug>(fern-action-copy)
  nmap <silent> <buffer> <nowait> m     <Plug>(fern-action-move)
  nmap <silent> <buffer> <nowait> !     <Plug>(fern-action-hidden-toggle)
  nmap <silent> <buffer> <nowait> <C-g> <Plug>(fern-action-debug)
  nmap <silent> <buffer> <nowait> ?     <Plug>(fern-action-help)
  nmap <silent> <buffer> <nowait> <C-c> <Plug>(fern-action-cancel)
  nmap <silent> <buffer> <nowait> .     <Plug>(fern-repeat)
  nmap <silent> <buffer> <nowait> R     <Plug>(fern-action-redraw)

  nnoremap <silent> <buffer> <nowait> q :<C-u>quit<CR>
  nnoremap <silent> <buffer> <nowait> Q :<C-u>bwipe!<CR>
endfunction

AutoCmd FileType fern call s:fern_settings()
" }}}3

" }}}2

" textobj & operator {{{2

" operator-convert-case {{{3
map cy <Plug>(operator-convert-case-loop)
" }}}3

" operator-replace {{{3
map _ <Plug>(operator-replace)
" }}}3

" swap {{{3
omap i, <Plug>(swap-textobject-i)
xmap i, <Plug>(swap-textobject-i)
omap a, <Plug>(swap-textobject-a)
xmap a, <Plug>(swap-textobject-a)
" }}}3

" textobj-between {{{3
let g:textobj_between_no_default_key_mappings = 1

omap i/ <Plug>(textobj-between-i)/
omap a/ <Plug>(textobj-between-a)/
xmap i/ <Plug>(textobj-between-i)/
xmap a/ <Plug>(textobj-between-a)/

omap i_ <Plug>(textobj-between-i)_
omap a_ <Plug>(textobj-between-a)_
xmap i_ <Plug>(textobj-between-i)_
xmap a_ <Plug>(textobj-between-a)_

omap i- <Plug>(textobj-between-i)-
omap a- <Plug>(textobj-between-a)-
xmap i- <Plug>(textobj-between-i)-
xmap a- <Plug>(textobj-between-a)-
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{3
if dein#tap('accelerated-jk')
  nmap j <Plug>(accelerated_jk_j)
  nmap k <Plug>(accelerated_jk_k)
endif
" }}}3

" anzu & asterisk & incsearch {{{3
if dein#tap('vim-anzu') && dein#tap('vim-asterisk') && dein#tap('incsearch.vim')
  let g:incsearch#magic = '\v'

  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map n  <Plug>(anzu-n)zzzv
  map N  <Plug>(anzu-N)zzzv
  map *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status)
  map #  <Plug>(asterisk-z#)<Plug>(anzu-update-search-status)
  map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status)
  map g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status)
endif
" }}}3

" bookmarks {{{3
let g:bookmark_save_per_working_dir = 1

function! g:BMWorkDirFileLocation()
  let filename = 'bookmarks'
  let location = ''

  if isdirectory('.git')
    let location = getcwd() . '/.git'
  else
    let location = finddir('.git', '.;')
  endif

  if len(location) > 0
    return location . '/' . filename
  else
    return getcwd() . '/.' . filename
  endif
endfunction
" }}}3

" caw {{{3
let g:caw_no_default_keymappings = 1

nmap <silent> <Leader>cc <Plug>(caw:hatpos:toggle)
xmap <silent> <Leader>cc <Plug>(caw:hatpos:toggle)
nmap <silent> <Leader>cw <Plug>(caw:wrap:comment)
xmap <silent> <Leader>cw <Plug>(caw:wrap:comment)
nmap <silent> <Leader>cW <Plug>(caw:wrap:uncomment)
xmap <silent> <Leader>cW <Plug>(caw:wrap:uncomment)
" }}}3

" easy-align {{{3
vnoremap ga :EasyAlign<CR>

let g:easy_align_delimiters = {
\ '>': {
\   'pattern': '===\|<=>\|=\~[#?]\?\|=>\|[:+/*!%^=><&|.-?]*=[#?]\?\|[-=]>\|<[-=]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left':  1,
\ },
\ '/': {
\   'pattern': '//\+\|/\*\|\*/',
\   'left_margin':   1,
\   'right_margin':  1,
\   'stick_to_left':  0,
\   'delimiter_align': 'l',
\   'ignore_groups':   ['!Comment']
\ },
\ ']': {
\   'pattern': '[[\]]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left':  0,
\  },
\ ')': {
\   'pattern': '[()]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left':  0,
\ },
\ '#': { 'pattern': '#',
\   'left_margin':   1,
\   'right_margin':  1,
\   'stick_to_left':  0,
\   'ignore_groups': ['String'],
\ },
\ '"': {
\   'left_margin':   1,
\   'right_margin':  1,
\   'stick_to_left':  0,
\   'pattern': '"',
\   'ignore_groups': ['String'],
\ },
\ ';': {
\   'pattern': ';',
\   'left_margin': 0,
\   'right_margin':  1,
\   'stick_to_left': 1,
\ }
\ }
" }}}3

" easymotion & shot-f {{{3
if dein#tap('vim-easymotion') && dein#tap('vim-shot-f')
  " EasyMotion
  let g:EasyMotion_do_mapping       = 0
  let g:EasyMotion_smartcase        = 1
  let g:EasyMotion_startofline      = 0
  let g:EasyMotion_keys             = 'HJKLASDFGYUIOPQWERTNMZXCVB'
  let g:EasyMotion_use_upper        = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
  let g:EasyMotion_prompt           = 'Search by EasyMotion ({n} character(s)) > '

  nmap <silent> S  <Plug>(easymotion-overwin-f2)
  omap <silent> S  <Plug>(easymotion-bd-f2)
  xmap <silent> S  <Plug>(easymotion-bd-f2)
  nmap <silent> ss <Plug>(easymotion-overwin-f2)
  omap <silent> ss <Plug>(easymotion-bd-f2)
  xmap <silent> ss <Plug>(easymotion-bd-f2)
  omap <silent> f  <Plug>(easymotion-fl)
  omap <silent> t  <Plug>(easymotion-tl)
  omap <silent> F  <Plug>(easymotion-Fl)
  omap <silent> T  <Plug>(easymotion-Tl)

  " shot-f
  let g:shot_f_no_default_key_mappings = 1
  nmap <silent> f <Plug>(shot-f-f)
  nmap <silent> F <Plug>(shot-f-F)
  nmap <silent> t <Plug>(shot-f-t)
  nmap <silent> T <Plug>(shot-f-T)
endif
" }}}3

" expand-region {{{3
let g:expand_region_text_objects = {
\ 'iw': 0,
\ 'i"': 0,
\ 'a"': 0,
\ "i'": 0,
\ "a'": 0,
\ 'i(': 0,
\ 'a(': 0,
\ 'i[': 0,
\ 'a[': 0,
\ 'i{': 0,
\ 'a{': 0,
\ 'i<': 0,
\ 'a<': 0,
\ 'il': 0,
\ 'ie': 0,
\ }

let g:expand_region_text_objects_ruby = {
\ 'iw': 0,
\ 'i"': 0,
\ 'a"': 0,
\ "i'": 0,
\ "a'": 0,
\ 'i(': 0,
\ 'a(': 0,
\ 'i[': 0,
\ 'a[': 0,
\ 'i{': 0,
\ 'a{': 0,
\ 'il': 0,
\ 'ir': 0,
\ 'ar': 0,
\ 'ie': 0,
\ }

vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)
" }}}3

" edgemotion {{{3
nmap <silent> <Leader>j <Plug>(edgemotion-j)
nmap <silent> <Leader>k <Plug>(edgemotion-k)
xmap <silent> <Leader>j <Plug>(edgemotion-j)
xmap <silent> <Leader>k <Plug>(edgemotion-k)
" }}}3

" grepper {{{3
AlterCommand!          gr[ep] Grepper
AlterCommand! <cmdwin> gr[ep] Grepper

let g:grepper = {
\ 'tools': ['rg', 'git', 'ag'],
\ }
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  nmap J         <Plug>(jplus)
  vmap J         <Plug>(jplus)
  nmap <Leader>J <Plug>(jplus-input)
  vmap <Leader>J <Plug>(jplus-input)
endif
" }}}3

" quickr-preview {{{3
let g:quickr_preview_keymaps = 0

function! s:quickr_preview_settings() abort
  nmap <silent> <buffer> p <Plug>(quickr_preview)
  nmap <silent> <buffer> q <Plug>(quickr_preview_qf_close)
endfunction

AutoCmd FileType qf call s:quickr_preview_settings()
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich')
  let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
  let g:sandwich#recipes += [
  \ {
  \   'buns':         ['_', '_'],
  \   'quoteescape':  1,
  \   'expand_range': 0,
  \   'nesting':      1,
  \   'linewise':     0,
  \   'match_syntax': 1,
  \ },
  \ {
  \   'buns':         ['-', '-'],
  \   'quoteescape':  1,
  \   'expand_range': 0,
  \   'nesting':      1,
  \   'linewise':     0,
  \   'match_syntax': 1,
  \ },
  \ {
  \   'buns':         ['/', '/'],
  \   'quoteescape':  1,
  \   'expand_range': 0,
  \   'nesting':      0,
  \   'linewise':     0,
  \   'match_syntax': 1,
  \ },
  \ {
  \   '__filetype__': 'ruby',
  \   'buns':     ['#{', '}'],
  \   'input':    ['#'],
  \   'filetype': ['ruby', 'eruby'],
  \ },
  \ {
  \   '__filetype__': 'ruby',
  \   'buns':     ['-> () {', '}'],
  \   'input':    ['->'],
  \   'kind':     ['add'],
  \   'filetype': ['ruby', 'eruby'],
  \ },
  \ {
  \   '__filetype__': 'eruby',
  \   'buns':     ['<% ', ' %>'],
  \   'input':    ['%'],
  \   'filetype': ['eruby'],
  \ },
  \ {
  \   '__filetype__': 'eruby',
  \   'buns':     ['<%= ', ' %>'],
  \   'input':    ['='],
  \   'filetype': ['eruby'],
  \ },
  \ ]

  let g:sandwich#magicchar#f#patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '(',
  \   'ket'    : ')',
  \   'footer' : '',
  \ },
  \ ]
endif
" }}}3

" scratch {{{3
AlterCommand!          sc[ratch] Scratch
AlterCommand! <cmdwin> sc[ratch] Scratch

let g:scratch_no_mappings = 1
" }}}3

" splitjoin {{{3
let g:splitjoin_align             = 1
let g:splitjoin_trailing_comma    = 1
let g:splitjoin_ruby_curly_braces = 0
let g:splitjoin_ruby_hanging_args = 0
" }}}3

" visual-multi {{{3
let g:VM_leader                     = '\'
let g:VM_default_mappings           = 0
let g:VM_sublime_mappings           = 0
let g:VM_mouse_mappings             = 0
let g:VM_extended_mappings          = 0
let g:VM_no_meta_mappings           = 1
let g:VM_reselect_first_insert      = 0
let g:VM_reselect_first_always      = 0
let g:VM_case_setting               = 'smart'
let g:VM_pick_first_after_n_cursors = 0
let g:VM_dynamic_synmaxcol          = 20
let g:VM_disable_syntax_in_imode    = 0
let g:VM_exit_on_1_cursor_left      = 0
let g:VM_manual_infoline            = 1

nmap <silent> (ctrln) <Plug>(VM-Find-Under)
xmap <silent> <C-n>   <Plug>(VM-Find-Subword-Under)

let g:VM_maps = {}
"
let g:VM_maps['Find Under']         = ''
let g:VM_maps['Find Subword Under'] = ''
let g:VM_maps['Skip Region']        = '<C-s>'
let g:VM_maps['Remove Region']      = '<C-q>'
let g:VM_maps['Start Regex Search'] = 'g/'
let g:VM_maps['Select All']         = '<A-a>'
let g:VM_maps['Add Cursor Down']    = '<A-S-j>'
let g:VM_maps['Add Cursor Up']      = '<A-S-k>'
let g:VM_maps['Select l']           = '<A-S-l>'
let g:VM_maps['Select h']           = '<A-S-h>'

let g:VM_maps['Find Next']          = ']'
let g:VM_maps['Find Prev']          = '['
let g:VM_maps['Goto Next']          = '}'
let g:VM_maps['Goto Prev']          = '{'
let g:VM_maps['Seek Next']          = '<C-d>'
let g:VM_maps['Seek Prev']          = '<C-u>'

let g:VM_maps['Surround']           = 'S'
let g:VM_maps['D']                  = 'D'
let g:VM_maps['J']                  = 'J'
let g:VM_maps['Dot']                = '.'
let g:VM_maps['c']                  = 'c'
let g:VM_maps['C']                  = 'C'
let g:VM_maps['Replace Pattern']    = 'R'
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history   = 1000
  let g:yankround_use_region_hl = 1
  let g:yankround_dir           = '~/.cache/vim/yankround'

  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "(ctrlp)"
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "(ctrln)"
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = [
\ 'markdown',
\ 'diff',
\ 'qf',
\ 'help',
\ 'gitcommit',
\ 'gitrebase',
\ 'denite',
\ ]
" }}}3

" brightest {{{3
let g:brightest#enable_highlight_all_window = 1
let g:brightest#highlight = {
\ 'group': 'BrighTestHighlight',
\ 'priority': 0
\ }
let g:brightest#ignore_syntax_list = ['Statement', 'Keyword', 'Boolean', 'Repeat']
" }}}3

" comfortable-motion {{{3
let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_enable = 0

function! s:toggle_comfortable_motion()
  if exists('g:comfortable_motion_enable') && g:comfortable_motion_enable == 1
    let g:comfortable_motion_enable = 0

    nunmap <C-d>
    nunmap <C-u>
    nunmap <C-f>
    nunmap <C-b>
  else
    let g:comfortable_motion_enable = 1

    nnoremap <silent> <C-d> :call comfortable_motion#flick(100)<CR>
    nnoremap <silent> <C-u> :call comfortable_motion#flick(-100)<CR>
    nnoremap <silent> <C-f> :call comfortable_motion#flick(200)<CR>
    nnoremap <silent> <C-b> :call comfortable_motion#flick(-200)<CR>
  endif
endfunction

command! ToggleComfortableMotion call <SID>toggle_comfortable_motion()
" }}}3

" context {{{3
let g:context_enabled = 0
" }}}3

" foldCC {{{3
if dein#tap('foldCC.vim')
  set foldtext=FoldCCtext()
endif
" }}}3

" highlightedundo {{{3
let g:highlightedundo#highlight_mode = 2

nmap <silent> u     <Plug>(highlightedundo-undo)
nmap <silent> <C-r> <Plug>(highlightedundo-redo)
" }}}3

" highlightedyank {{{3
if dein#tap('vim-highlightedyank')
  let g:highlightedyank_highlight_duration = 300

  " function! s:highlight_yank_enter(...) abort
  "   augroup highlight_yank
  "     autocmd!
  "     autocmd TextYankPost * call highlightedyank#debounce()
  "     autocmd TextYankPost * setlocal list listchars-=eol:$
  "     autocmd TextYankPost * call timer_start(g:highlightedyank_highlight_duration, function('s:highlight_yank_leave'))
  "   augroup END
  " endfunction
  "
  " function! s:highlight_yank_leave(...) abort
  "   augroup highlight_yank
  "     setlocal list listchars+=eol:$
  "   augroup END
  " endfunction
  "
  " call timer_start(g:highlightedyank_highlight_duration, function('s:highlight_yank_enter'))
endif
" }}}3

" indent-line {{{3
let g:indentLine_fileTypeExclude = ['json']
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ 'active': {
  \   'left': [
  \     ['mode', 'spell', 'paste'],
  \     ['filepath', 'filename'],
  \     ['special_mode', 'anzu', 'vm_regions'],
  \     [],
  \    ],
  \   'right': [
  \     ['lineinfo'],
  \     ['filetype', 'fileencoding', 'fileformat'],
  \     ['linter_ok', 'linter_informations', 'linter_warnings', 'linter_errors'],
  \   ],
  \ },
  \ 'inactive': {
  \   'left': [[], ['special_mode'], [], ['filepath', 'filename']],
  \   'right': [[], ['filetype', 'fileencoding', 'fileformat']],
  \ },
  \ 'tabline': {
  \   'left':  [['tabs']],
  \   'right': [],
  \ },
  \ 'tab': {
  \   'active':   ['tabwinnum', 'filename'],
  \   'inactive': ['tabwinnum', 'filename'],
  \ },
  \ 'component': {
  \   'spell': "%{&spell ? 'SPELL' : ''}",
  \   'paste': "%{&paste ? 'PASTE' : ''}",
  \  },
  \ 'component_function': {
  \   'mode':         'Lightline_mode',
  \   'special_mode': 'Lightline_special_mode',
  \   'filepath':     'Lightline_filepath',
  \   'filename':     'Lightline_filename',
  \   'filetype':     'Lightline_filetype',
  \   'lineinfo':     'Lightline_lineinfo',
  \   'fileencoding': 'Lightline_fileencoding',
  \   'fileformat':   'Lightline_fileformat',
  \   'anzu':         'anzu#search_status',
  \   'vm_regions':   'Lightline_vm_regions',
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum': 'Lightline_tab_win_num',
  \ },
  \ 'component_visible_condition': {
  \   'special_mode': "%{Lightline_special_mode() !=# ''}",
  \   'anzu':         "%{anzu#search_status !=# ''}",
  \   'vm_regions':   "%{Lightline_vm_regions() !=# ''}",
  \ },
  \ 'component_function_visible_condition': {
  \   'spell': '&spell',
  \   'paste': '&paste',
  \ },
  \ 'component_type': {
  \   'linter_errors':       'error',
  \   'linter_warnings':     'warning',
  \   'linter_informations': 'information',
  \   'linter_ok':           'ok',
  \ },
  \ 'component_expand': {
  \   'linter_errors':       'Lightline_coc_errors',
  \   'linter_warnings':     'Lightline_coc_warnings',
  \   'linter_informations': 'Lightline_coc_information',
  \   'linter_ok':           'Lightline_coc_ok',
  \ },
  \ 'enable': {
  \   'statusline': 1,
  \   'tabline':    1,
  \ },
  \ 'separator': { 'left': '', 'right': '' },
  \ 'subseparator': { 'left': '', 'right': '' }
  \ }

  " Disable lineinfo, fileencoding and fileformat
  let s:lightline_ignore_right_ft = [
  \ 'help',
  \ 'diff',
  \ 'man',
  \ 'fzf',
  \ 'fern',
  \ 'capture',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ft_to_mode_hash = {
  \ 'help':        'Help',
  \ 'diff':        'Diff',
  \ 'man':         'Man',
  \ 'fzf':         'FZF',
  \ 'fern':        'Fern',
  \ 'capture':     'Capture',
  \ 'gina-status': 'Git Status',
  \ 'gina-branch': 'Git Branch',
  \ 'gina-log':    'Git Log',
  \ 'gina-reflog': 'Git Reflog',
  \ 'gina-blame':  'Git Blame',
  \ }

  let s:lightline_ignore_modifiable_ft = [
  \ 'qf',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filename_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'fern',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filepath_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  function! Lightline_is_visible(width) abort
    return a:width < winwidth(0)
  endfunction

  function! Lightline_mode() abort
    return lightline#mode()
  endfunction

  function! Lightline_special_mode() abort
    let l:special_mode = get(s:lightline_ft_to_mode_hash, &filetype, '')
    let l:win = getwininfo(win_getid())[0]
    return l:special_mode !=# '' ? l:special_mode :
    \ exists('g:VM') && g:VM.is_active ? 'VISUAL MULTI' :
    \ anzu#search_status() !=# '' ? 'Anzu' :
    \ Lightline_mode() !=# '' ? '' :
    \ l:win.loclist ? 'Location List' :
    \ l:win.quickfix ? 'QuickFix' :
    \ ''
  endfunction

  function! Lightline_filepath() abort
    if !Lightline_is_visible(140)
      return ''
    endif

    if count(s:lightline_ignore_filepath_ft, &filetype) || expand('%:t') ==# '[Command Line]'
      return ''
    endif

    let l:path = fnamemodify(expand('%'), ':p:.:h')
    return l:path ==# '.' ? '' : l:path

    let l:not_home_prefix = match(l:path, '^/') != -1 ? '/' : ''
    let l:dirs            = split(l:path, '/')
    let l:last_dir        = remove(l:dirs, -1)
    call map(l:dirs, 'v:val[0]')

    return len(l:dirs) ? l:not_home_prefix . join(l:dirs, '/') . '/' . l:last_dir : l:last_dir
  endfunction

  function! Lightline_filename() abort
    let l:filename = fnamemodify(expand('%'), ':t')

    if count(s:lightline_ignore_filename_ft, &filetype)
      return ''
    elseif l:filename ==# ''
      return '[No Name]'
    elseif &modifiable
      return l:filename . (&modified ? ' [+]' : '')
    else
      return l:filename . ' [X]'
    endif
  endfunction

  function! Lightline_filetype() abort
    if has_key(s:lightline_ft_to_mode_hash, &filetype)
      return ''
    endif

    if &filetype ==? 'qf' && getwininfo(win_getid())[0].loclist
      return 'LocationList'
    elseif &filetype ==? 'qf' && getwininfo(win_getid())[0].quickfix
      return 'QuickFix'
    else
      return &filetype . ' ' . WebDevIconsGetFileTypeSymbol()
    endif
  endfunction

  function! Lightline_lineinfo() abort
    if !Lightline_is_visible(100)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ printf(' %3d:%2d / %d lines [%d%%]',line('.'), col('.'), line('$'), float2nr((1.0 * line('.')) / line('$') * 100.0)) :
    \ ''
  endfunction

  function! Lightline_fileencoding() abort
    if !Lightline_is_visible(140)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ strlen(&fileencoding) ?
    \   &fileencoding :
    \   &encoding :
    \ ''
  endfunction

  function! Lightline_fileformat() abort
    if !Lightline_is_visible(140)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ &fileformat :
    \ ''
  endfunction

  function! Lightline_tab_win_num(n) abort
    return a:n . ':' . len(tabpagebuflist(a:n))
  endfunction

  function! Lightline_coc_errors() abort
    return b:coc_diagnostic_info['error'] != 0 ? ' ' . b:coc_diagnostic_info['error'] : ''
  endfunction

  function! Lightline_coc_warnings() abort
    return b:coc_diagnostic_info['warning'] != 0 ? ' ' . b:coc_diagnostic_info['warning'] : ''
  endfunction

  function! Lightline_coc_information() abort
    return b:coc_diagnostic_info['information'] != 0 ? ' ' . b:coc_diagnostic_info['information'] : ''
  endfunction

  function! Lightline_coc_ok() abort
    return b:coc_diagnostic_info['error'] == 0 &&
    \ b:coc_diagnostic_info['warning'] == 0 &&
    \ b:coc_diagnostic_info['information'] == 0 ?
    \ ' ' : ''
  endfunction

  " function! Lightline_denite() abort
  "   return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  " endfunction

  function! Lightline_vm_regions() abort
    if exists('g:VM') && g:VM.is_active
      let l:index = b:VM_Selection.Vars.index + 1
      let l:max   = len(b:VM_Selection.Regions)
      return '(' . l:index . '/' . l:max . ')'
    else
      return ''
    endif
  endfunction

  AutoCmd User CocDiagnosticChange call lightline#update()
endif
" }}}3

" matchup {{{3
let g:matchup_matchparen_status_offscreen = 0
" }}}3

" rainbow {{{3
let g:rainbow_active           = 1
let g:rainbow_conf             = {}
let g:rainbow_conf.cterms      = ['']
let g:rainbow_conf.ctermfgs    = ['yellow', 'darkred', 'darkgreen', 'darkblue']
let g:rainbow_conf.guis        = ['']
let g:rainbow_conf.guifgs      = ['#BD9D0B', '#B3427E', '#5B9C14', '#3E7C94']
let g:rainbow_conf.operator    = '_,_'
let g:rainbow_conf.parentheses = ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold']

let g:rainbow_conf.separately = {
\ '*': {},
\ 'vim': {
\   'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\ },
\ 'html': {
\   'parentheses': ['start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\ },
\ 'erb': {
\   'parentheses': ['start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\ },
\ 'sh': {
\   'parentheses': [['\(^\|\s\)\S*()\s*{\?\($\|\s\)','_^{_','}'], ['\(^\|\s\)if\($\|\s\)','_\(^\|\s\)\(then\|else\|elif\)\($\|\s\)_','\(^\|\s\)fi\($\|\s\)'], ['\(^\|\s\)for\($\|\s\)','_\(^\|\s\)\(do\|in\)\($\|\s\)_','\(^\|\s\)done\($\|\s\)'], ['\(^\|\s\)while\($\|\s\)','_\(^\|\s\)\(do\)\($\|\s\)_','\(^\|\s\)done\($\|\s\)'], ['\(^\|\s\)case\($\|\s\)','_\(^\|\s\)\(\S*)\|in\|;;\)\($\|\s\)_','\(^\|\s\)esac\($\|\s\)']],
\ },
\ 'scss'        : 0,
\ 'css'         : 0,
\ 'help'        : 0,
\ 'man'         : 0,
\ 'diff'        : 0,
\ 'qf'          : 0,
\ 'fzf'         : 0,
\ 'denite'      : 0,
\ 'git'         : 0,
\ 'gitcommit'   : 0,
\ 'gina-status' : 0,
\ 'gina-commit' : 0,
\ 'gina-reflog' : 0,
\ 'gina-blame'  : 0,
\ 'capture'     : 0,
\ }
" }}}3

" smartnumber {{{3
let g:snumber_enable_startup = 1
" }}}3

" zenspace {{{3
let g:zenspace#default_mode = 'on'
" }}}3

" }}}2

" Util {{{2

" aho-bakaup {{{3
let g:bakaup_auto_backup = 1
let g:bakaup_backup_dir  = expand('~/.cache/vim/backup')
" }}}3

" automatic {{{
let g:automatic_config = [
\ {
\   'match': {
\     'filetype': 'help',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'man',
\     'autocmds': ['FileType'],
\   },
\   'set': {
\     'move': 'right',
\     'width': '35%',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'qf',
\     'autocmds': ['FileType'],
\   },
\ },
\ {
\   'match': {
\     'filetype': 'diff',
\   },
\   'set': {
\     'move': 'right',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'git',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-status',
\   },
\   'set': {
\     'move': 'topleft',
\     'height': '20%',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-commit',
\   },
\   'set': {
\     'move': 'topleft',
\     'height': '25%',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-branch',
\   },
\   'set': {
\     'move': 'topleft',
\     'height': '30%',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-log',
\   },
\   'set': {
\     'move': 'right',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-reflog',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'gina-grep',
\   },
\   'set': {
\     'move': 'right',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'capture',
\     'autocmds': ['FileType'],
\   },
\ }
\ ]
" }}}

" bbye {{{3
nnoremap <silent> <Leader>d :Bdelete!<CR>
" }}}3

" capture {{{3
AlterCommand!          cap[ture] Capture
AlterCommand! <cmdwin> cap[ture] Capture
AutoCmd FileType capture nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}3

" floaterm {{{3
let g:floaterm_width       = 0.8
let g:floaterm_height      = 0.8
let g:floaterm_winblend    = 15
let g:floaterm_position    = 'center'
let g:floaterm_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']

nnoremap <silent> <C-s> :<C-u>FloatermToggle<CR>

AutoCmd FileType floaterm call s:floaterm_settings()
AutoCmd FileType gitrebase call s:set_git_rebase_settings()

function! s:floaterm_settings() abort
  tnoremap <silent> <buffer> <C-s> <C-\><C-n>:FloatermToggle<CR>
  let b:highlight_cursor = 0
endfunction

function! s:set_git_rebase_settings() abort
  set winhighlight=Normal:GitRebase
  set winblend=30

  nnoremap <silent> <buffer> <Leader>d :bdelete!<Space><Bar><Space>close<CR>
endfunction
" }}}3

" mundo {{{3
nnoremap <silent> <Leader>u :<C-u>MundoToggle<CR>
" }}}3

" previm {{{3
let g:previm_open_cmd            = 'open -a "Google Chrome"'
let g:previm_disable_default_css = 1
let g:previm_custom_css_path     = '~/.config/previm/gfm.css'
" }}}3

" ref {{{3
AlterCommand!          refe Ref<Space>refe
AlterCommand! <cmdwin> refe Ref<Space>refe
" }}}3

" table-mode {{{3
let g:table_mode_corner='|'
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0
nnoremap <silent> <C-w><C-w> :call WindowSwap#EasyWindowSwap()<CR>
" }}}3

" }}}2

" Develop {{{2

" quickrun {{{3
AlterCommand!          r QuickRun
AlterCommand! <cmdwin> r QuickRun

let g:quickrun_config = {
\ '_' : {
\   'outputter' : 'error',
\   'outputter/error/success' : 'buffer',
\   'outputter/error/error'   : 'quickfix',
\   'outputter/buffer/split'  : ':botright 15split',
\   'outputter/buffer/close_on_empty' : 1,
\ }
\ }
" }}}3

" }}}2

" }}}1

" Correct Interference {{{1

" Mapping <Esc><Esc> {{{2
" nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <Bar> AnzuClearSearchStatus <Bar> call Set_default_keymap()<CR>
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <Bar> AnzuClearSearchStatus<CR>
" }}}

" keymaps {{{
" function! Set_default_keymap() abort
"   let g:keymap = 'Default'
"   call lightline#update()
" endfunction
"
" function! Set_quickfix_keymap() abort
"   let g:keymap = 'QuickFix'
"   call lightline#update()
"
"   nnoremap <silent> cp :<C-u>cprev<CR>
"   nnoremap <silent> cn :<C-u>cnext<CR>
" endfunction
"
" function! Set_locationlist_keymap() abort
"   let g:keymap = 'LocationList'
"   call lightline#update()
"
"   nnoremap <silent> cp :<C-u>lprev<CR>
"   nnoremap <silent> cn :<C-u>lnext<CR>
" endfunction
"
" AutoCmd FileType qf
" \ if getwininfo(win_getid())[0].loclist |
" \   call Set_default_keymap()      |
" \   call Set_locationlist_keymap() |
" \ elseif getwininfo(win_getid())[0].quickfix |
" \   call Set_default_keymap()  |
" \   call Set_quickfix_keymap() |
" \ endif
" }}}

" }}}1

" Load Colorscheme {{{1

syntax enable

" Highlight {{{2
AutoCmd ColorScheme * highlight Normal       ctermfg=145  ctermbg=235  guifg=#ABB2BF guibg=#26282F
AutoCmd ColorScheme * highlight NormalNC     ctermfg=144  ctermbg=234  guifg=#ABB2BF guibg=#282C34
AutoCmd ColorScheme * highlight CursorColumn ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
AutoCmd ColorScheme * highlight CursorLine   ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
AutoCmd ColorScheme * highlight CursorLineNr ctermfg=253  ctermbg=NONE guifg=#DADADA guibg=NONE
AutoCmd ColorScheme * highlight LineNr       ctermfg=241  ctermbg=NONE guifg=#626262 guibg=NONE
AutoCmd ColorScheme * highlight NonText      ctermfg=60   ctermbg=NONE guifg=#5F5F87 guibg=NONE
AutoCmd ColorScheme * highlight Search       ctermfg=68   ctermbg=232  guifg=#5F87D7 guibg=#080808
AutoCmd ColorScheme * highlight Todo         ctermfg=229  ctermbg=NONE guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme * highlight Visual       ctermfg=159  ctermbg=23   guifg=#AFFFFF guibg=#005F5F
AutoCmd ColorScheme * highlight DiffAdd      ctermfg=233  ctermbg=64   guifg=#C4C4C4 guibg=#3E5935
AutoCmd ColorScheme * highlight DiffDelete   ctermfg=233  ctermbg=95   guifg=#C4C4C4 guibg=#593535
AutoCmd ColorScheme * highlight DiffChange   ctermfg=233  ctermbg=143  guifg=#C4C4C4 guibg=#594D1A

" Gina (Vital.Vim.Buffer.ANSI)
AutoCmd ColorScheme * highlight AnsiColor0  ctermfg=0  guifg=#1E2132
AutoCmd ColorScheme * highlight AnsiColor1  ctermfg=1  guifg=#E27878
AutoCmd ColorScheme * highlight AnsiColor2  ctermfg=2  guifg=#B4BE82
AutoCmd ColorScheme * highlight AnsiColor3  ctermfg=3  guifg=#E2A478
AutoCmd ColorScheme * highlight AnsiColor4  ctermfg=4  guifg=#84A0C6
AutoCmd ColorScheme * highlight AnsiColor5  ctermfg=5  guifg=#A093C7
AutoCmd ColorScheme * highlight AnsiColor6  ctermfg=6  guifg=#89B8C2
AutoCmd ColorScheme * highlight AnsiColor7  ctermfg=7  guifg=#C6C8D1
AutoCmd ColorScheme * highlight AnsiColor8  ctermfg=8  guifg=#6B7089
AutoCmd ColorScheme * highlight AnsiColor9  ctermfg=9  guifg=#E98989
AutoCmd ColorScheme * highlight AnsiColor10 ctermfg=10 guifg=#C0CA8E
AutoCmd ColorScheme * highlight AnsiColor11 ctermfg=11 guifg=#F0C674
AutoCmd ColorScheme * highlight AnsiColor12 ctermfg=12 guifg=#91ACD1
AutoCmd ColorScheme * highlight AnsiColor13 ctermfg=13 guifg=#ADA0D3
AutoCmd ColorScheme * highlight AnsiColor14 ctermfg=14 guifg=#95C4CE
AutoCmd ColorScheme * highlight AnsiColor15 ctermfg=15 guifg=#D2D4DE

AutoCmd ColorScheme * highlight BrightestHighlight      ctermfg=72   ctermbg=NONE                      guifg=#5FAF87 guibg=NONE
AutoCmd ColorScheme * highlight EasyMotionMoveHLDefault ctermfg=9    ctermbg=236  cterm=underline,bold guifg=#E98989 guibg=#303030 gui=underline,bold
AutoCmd ColorScheme * highlight ExtraWhiteSpace         ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989
AutoCmd ColorScheme * highlight FloatermNF              ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#161821
AutoCmd ColorScheme * highlight GitRebase               ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#1F1F20
AutoCmd ColorScheme * highlight HighlightedyankRegion   ctermfg=1    ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme * highlight MatchParen              ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme * highlight MatchParenCur           ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme * highlight MatchWord               ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme * highlight MatchWordCur            ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme * highlight QuickScopePrimary       ctermfg=68   ctermbg=NONE                      guifg=#5F87D7 guibg=NONE
AutoCmd ColorScheme * highlight QuickScopeSecondary     ctermfg=72   ctermbg=NONE                      guifg=#5FAFAF guibg=NONE
AutoCmd ColorScheme * highlight ShotFBlank              ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme * highlight ShotFGraph              ctermfg=209  ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme * highlight YankRoundRegion         ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A
AutoCmd ColorScheme * highlight ZenSpace                ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989

AutoCmd ColorScheme * highlight CocErrorSign            ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme * highlight CocWarningSign          ctermfg=214  ctermbg=NONE                      guifg=#FFAF00 guibg=NONE
AutoCmd ColorScheme * highlight CocInfoSign             ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE

" Fix lightline
" AutoCmd ColorScheme * highlight StatusLine   ctermfg=0 ctermbg=none guifg=#1E2132 guibg=#C6C8D1
" AutoCmd ColorScheme * highlight StatusLineNC ctermfg=0 ctermbg=none guifg=#1E2132 guibg=#C6C8D1
" }}}2

" onedark {{{2
colorscheme onedark

"" ruby_hl_lvar.vim
hi! Identifier cterm=NONE ctermfg=10 guifg=#C0CA8E
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
