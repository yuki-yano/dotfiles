" Global Variables {{{1
let g:ale_filetypes = [
\ 'javascript',
\ 'typescript',
\ 'typescript.tsx',
\ 'vue',
\ 'ruby',
\ 'eruby',
\ 'go',
\ 'json',
\ 'yaml',
\ 'html',
\ 'css',
\ 'scss',
\ 'dockerfile',
\ 'vim',
\ 'sh',
\ 'bash',
\ ]
" }}}1

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
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja')
  " }}}3

  " Language {{{3
  call dein#add('MaxMEllon/vim-jsx-pretty',                {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('elzr/vim-json',                           {'lazy': 1, 'on_ft': 'json'})
  call dein#add('fatih/vim-go',                            {'lazy': 1, 'on_ft': 'go'})
  call dein#add('hail2u/vim-css3-syntax',                  {'lazy': 1, 'on_ft': ['css', 'javascript', 'typescript']})
  call dein#add('itspriddle/vim-marked',                   {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('leafgarland/typescript-vim',              {'lazy': 1, 'on_ft': ['typescript', 'vue']})
  call dein#add('mhartington/nvim-typescript',             {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'typescript.tsx', 'vue'], 'build': './install.sh'})
  call dein#add('othree/yajs.vim',                         {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('posva/vim-vue',                           {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('styled-components/vim-styled-components', {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('tpope/vim-endwise',                       {'lazy': 1, 'on_ft': 'ruby'})
  " }}}3

  " ALE {{{
  call dein#add('w0rp/ale', {'lazy': 1, 'on_ft': g:ale_filetypes})
  " }}}

  " Git {{{3
  call dein#add('ToruIwashita/git-switcher.vim', {'lazy': 1, 'on_cmd': ['Gsw', 'GswSave', 'GswLoad']})
  call dein#add('airblade/vim-gitgutter')
  call dein#add('lambdalisue/gina.vim',          {'lazy': 1, 'on_cmd': 'Gina', 'on_func': 'gina#core#get', 'hook_post_source': 'call Hook_on_post_source_gina()'})
  call dein#add('rhysd/git-messenger.vim',       {'lazy': 1, 'on_cmd': 'GitMessenger', 'on_map': '<Plug>'})
  " }}}3

  " Completion {{{3
  if has('nvim')
    call dein#add('Shougo/deoplete.nvim')
    call dein#add('prabirshrestha/async.vim')
    call dein#add('prabirshrestha/vim-lsp')
    " call dein#add('autozimu/LanguageClient-neovim', {'lazy': 1, 'on_ft': ['vue', 'ruby'], 'rev': 'next', 'build': 'bash install.sh'})

    call dein#add('tbodt/deoplete-tabnine', {'build': 'bash install.sh'})

    call dein#add('Shougo/echodoc.vim')
    call dein#add('Shougo/neco-syntax')
    call dein#add('Shougo/neco-vim')
    call dein#add('jsfaint/gen_tags.vim')
    call dein#add('lighttiger2505/deoplete-vim-lsp')
    call dein#add('thalesmello/webcomplete.vim')
    call dein#add('ujihisa/neco-look')
    call dein#add('wellle/tmux-complete.vim')

    call dein#add('Shougo/neosnippet')
  endif
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim')

  call dein#add('Shougo/neomru.vim')
  call dein#add('ozelentok/denite-gtags')

  call dein#add('junegunn/fzf', {'build': './install --bin', 'merged': 0})
  call dein#add('yuki-ycino/fzf-preview.vim', {
  \ 'lazy': 1,
  \ 'on_cmd': [
  \ 'ProjectFilesPreview',
  \ 'GitFilesPreview',
  \ 'BuffersPreview',
  \ 'ProjectOldFilesPreview',
  \ 'ProjectMruFilesPreview',
  \ 'OldFilesPreview',
  \ 'MruFilesPreview',
  \ 'ProjectGrepPreview',
  \ ],
  \ })
  " call dein#local('~/repos/github.com/yuki-ycino', {}, ['fzf-preview.vim'])
  " }}}3

  " filer {{{3
  call dein#add('lambdalisue/fila.vim', {'lazy': 1, 'on_cmd': 'Fila'})
  " }}}3

  " textobj & operator {{{3
  call dein#add('machakann/vim-sandwich')

  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-operator-user')

  call dein#add('kana/vim-textobj-entire') " ie ae
  call dein#add('kana/vim-textobj-line') " al il
  call dein#add('rhysd/vim-textobj-ruby') " ir ar
  call dein#add('thinca/vim-textobj-between') " i{char} a{char}

  call dein#add('yuki-ycino/vim-operator-replace', {'lazy': 1, 'depends': 'vim-operator-user', 'on_map': '<Plug>'})
  " }}}3

  " Edit & Move & Search {{{3
  call dein#add('Chiel92/vim-autoformat')
  call dein#add('LeafCage/yankround.vim')
  call dein#add('cohama/lexima.vim',         {'lazy': 1, 'on_event': 'InsertEnter', 'hook_post_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('easymotion/vim-easymotion')
  call dein#add('haya14busa/incsearch.vim')
  call dein#add('gabesoft/vim-ags')
  call dein#add('haya14busa/vim-asterisk',   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion')
  call dein#add('haya14busa/vim-metarepeat', {'lazy': 1, 'on_map': ['go', 'g.', '<Plug>']})
  call dein#add('junegunn/vim-easy-align',   {'lazy': 1, 'on_cmd': 'EasyAlign'})
  call dein#add('mg979/vim-visual-multi',    {'rev': 'test'})
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('osyo-manga/vim-jplus',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/accelerated-jk',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/clever-f.vim')
  call dein#add('terryma/vim-expand-region', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-qfreplace',      {'lazy': 1, 'on_cmd': 'Qfreplace'})
  call dein#add('tommcdo/vim-exchange',      {'lazy': 1, 'on_map': {'n': ['cx', 'cxc', 'cxx'], 'x': ['X']}})
  call dein#add('tomtom/tcomment_vim',       {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat')
  call dein#add('wincent/ferret')
  " }}}3

  " Appearance {{{3
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Yggdroot/indentLine', {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('andymass/vim-matchup')
  call dein#add('itchyny/lightline.vim')
  call dein#add('kamykn/spelunker.vim')
  call dein#add('luochen1990/rainbow')
  call dein#add('machakann/vim-highlightedyank')
  call dein#add('maximbaz/lightline-ale')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('osyo-manga/vim-brightest')
  " }}}3

  " tmux {{{3
  call dein#add('christoomey/vim-tmux-navigator')
  " }}}3

  " Util {{{3
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bogado/file-line')
  call dein#add('dhruvasagar/vim-table-mode',   {'lazy': 1, 'on_cmd': 'TableModeToggle'})
  call dein#add('kana/vim-niceblock',           {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('lambdalisue/vim-manpager',     {'lazy': 1, 'on_cmd': ['Man', 'MANPAGER']})
  call dein#add('lambdalisue/vim-pager',        {'lazy': 1, 'on_cmd': 'PAGER'})
  call dein#add('mbbill/undotree',              {'lazy': 1, 'on_cmd': 'UndotreeToggle'})
  call dein#add('osyo-manga/vim-gift')
  call dein#add('pocke/vim-automatic',          {'depends': 'vim-gift'})
  call dein#add('qpkorr/vim-bufkill')
  call dein#add('thinca/vim-localrc')
  call dein#add('tweekmonster/startuptime.vim', {'lazy': 1, 'on_cmd': 'StartupTime'})
  call dein#add('tyru/capture.vim',             {'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('tyru/vim-altercmd')
  call dein#add('wesQ3/vim-windowswap',         {'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  call dein#add('yssl/QFEnter')
  " }}}3

  " develop {{{3
  call dein#add('thinca/vim-prettyprint')
  " }}}3

  " Color Theme {{{3
  call dein#add('cocopon/iceberg.vim')
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

"" Cursor
noremap <Leader>l $
noremap <Leader>h ^
noremap 0 ^
noremap ^ 0

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
set diffopt=filler,vertical
set display=lastline
set helplang=ja
set hidden
set hlsearch
set laststatus=2
set list listchars=tab:^\ ,trail:_,eol:$,extends:>,precedes:<
set matchpairs+=<:>
set matchtime=1
set number
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
  if g:highlight_cursor
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

" ToggleHighLight {{{2
function! s:highlight_toggle()
  if exists('g:syntax_on')
    syntax off
  else
    syntax enable
  endif
endfunction

command! HighlightToggle call <SID>highlight_toggle()
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

" MoveToNewTab {{{2
function! s:move_to_new_tab()
  tab split
  tabprevious

  if winnr('$') > 1
    close
  elseif bufnr('$') > 1
    buffer #
  endif

  tabnext
endfunction

command! MoveToNewTab call <SID>move_to_new_tab()
nnoremap <silent> gm :<C-u>MoveToNewTab<CR>
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

" VimShowHlGroup {{{2
command! ShowHlGroup echo synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
" }}}2

" VSCode {{{2
command! VSCode execute printf('!code -r "%s"', expand('%'))
" }}}2

" }}}1

" FileType Settings {{{1

" FileType {{{2

" Intent {{{3
AutoCmd FileType javascript     setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript     setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript.tsx setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vue            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType ruby           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType eruby          setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType python         setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType go             setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType rust           setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType json           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType markdown       setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType html           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType css            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType scss           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vim            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType sh             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType zsh            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" iskeyword {{{3
AutoCmd FileType vue  setlocal iskeyword+=$ iskeyword+=& iskeyword+=- iskeyword+=? iskeyword-=/
AutoCmd FileType ruby setlocal iskeyword+=@ iskeyword+=! iskeyword+=? iskeyword+=&
AutoCmd FileType html setlocal iskeyword+=-
AutoCmd FileType css  setlocal iskeyword+=- iskeyword+=#
AutoCmd FileType scss setlocal iskeyword+=- iskeyword+=# iskeyword+=$
AutoCmd FileType vim  setlocal iskeyword+=-
AutoCmd FileType sh   setlocal iskeyword+=$ iskeyword+=-
AutoCmd FileType zsh  setlocal iskeyword+=$ iskeyword+=-
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
AutoCmd FileType qf   nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType diff nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType man  nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType git  nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}2

" }}}1

" Command Line Window {{{1
set cedit=\<C-c>

nnoremap : q:
xnoremap : q:
nnoremap q: :
xnoremap q: :

AutoCmd CmdwinEnter * call <SID>init_cmdwin()

function! s:init_cmdwin() abort
  set number | set norelativenumber
  nnoremap <buffer> <Enter> <Enter>
  nnoremap <buffer> <silent> q :<C-u>quit<CR>
  inoremap <buffer> <C-c> <C-c>
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
  AlterCommand! <cmdwin> show[hlgroup] ShowHlGroup
  AlterCommand! <cmdwin> vs[code] VSCode
  AlterCommand! <cmdwin> co[de]   VSCode
endif
" }}}3

" }}}2

" Plugin Manager {{{2

" }}}2

" Language {{{2

" ALE {{{3
let g:ale_linters = {
\ 'javascript':     ['eslint'],
\ 'typescript':     ['tsserver', 'eslint', 'tslint'],
\ 'typescript.tsx': ['tsserver', 'eslint', 'tslint'],
\ 'vue':            ['vls', 'eslint'],
\ 'ruby':           ['rubocop'],
\ 'go':             ['bingo'],
\ 'json':           ['jsonlint'],
\ 'dockerfile':     ['hadolint'],
\ 'vim':            ['vint'],
\ 'sh':             ['shellcheck'],
\ 'bash':           ['shellcheck'],
\ }

let g:ale_set_highlights           = 0
let g:ale_sign_column_always       = 1
let g:ale_change_sign_column_color = 1
let g:ale_lint_on_text_changed     = 'never'
let g:ale_lint_on_insert_leave     = 0
let g:ale_echo_msg_format          = '[%linter%] %s'
let g:ale_virtualtext_cursor       = 1

let g:ale_sign_error         = ''
let g:ale_sign_warning       = ''
let g:ale_sign_info          = ''
let g:ale_sign_style_error   = ''
let g:ale_sign_style_warning = ''

let g:ale_go_bingo_executable = 'gopls'
" }}}3

" autoformat {{{3
function! s:autoformat_all() abort
  let l:formatter_global_var_name = 'g:formatters_' . &filetype

  if !exists(l:formatter_global_var_name)
    Autoformat
    return
  endif

  let l:formatter_buffer_var_name = 'b:formatters_' . &filetype
  let l:formatters = []
  execute 'let l:formatters = ' . l:formatter_global_var_name

  for l:formatter in l:formatters
    execute 'let ' . l:formatter_buffer_var_name . '= ["' . l:formatter . '"]'
    Autoformat
  endfor

  execute 'unlet ' . l:formatter_buffer_var_name
endfunction
command! AutoformatAll call <SID>autoformat_all()
noremap <Leader>a :<C-u>AutoformatAll<CR>

" html formatter
let g:formatdef_htmlbeautifier = '"htmlbeautifier --keep-blank-lines 2"'

" JavaScript
let g:formatters_javascript = ['prettier']

" TypeScript
let g:formatters_typescript = ['prettier']

" Vue
let g:formatters_vue = ['prettier']

" Ruby
let g:formatters_ruby = ['rubocop']

" eruby
let g:formatters_eruby = ['htmlbeautifier']

" HTML
let g:formatters_html = ['prettier']

" CSS
let g:formatters_css = ['prettier']

" SCSS
let g:formatters_scss = ['prettier']

" json
let g:formatters_json = ['fixjson', 'prettier']

" GraphQL
let g:formatters_graphql = ['prettier']

" Markdown
let g:formatters_markdown = ['prettier']
" }}}3

" endwise {{{3
let g:endwise_no_mappings = 1
" }}}3

" gen_tags {{{3
let g:gen_tags#use_cache_dir  = 0
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#gtags_auto_gen = 1
" }}}3

" go {{{3
let g:go_fmt_command                 = 'goimports'
let g:go_def_mode                    = 'godef'
let g:go_def_mapping_enabled         = 0
let g:go_highlight_functions         = 1
let g:go_highlight_methods           = 1
let g:go_highlight_structs           = 1
let g:go_highlight_operators         = 1
let g:go_term_enabled                = 1
let g:go_highlight_build_constraints = 1
let g:go_template_autocreate         = 0
let g:go_gocode_unimported_packages  = 1
" }}}3

" json {{{3
let g:vim_json_syntax_conceal = 0
" }}}3

" marked {{{3
AlterCommand! <cmdwin> mark[ed] MarkedOpen
" }}}3

" nvim-typescript {{{3
let g:nvim_typescript#diagnostics_enable = 0
let g:nvim_typescript#type_info_on_hold  = 1
let g:nvim_typescript#signature_complete = 1
let g:nvim_typescript#javascript_support = 1
let g:nvim_typescript#vue_support        = 1

function s:ts_settings() abort
  nnoremap <silent> <buffer> K              :<C-u>TSDefPreview<CR>
  nnoremap <silent> <buffer> gK             :<C-u>TSTypeDef<CR>
  nnoremap <silent> <buffer> <LocalLeader>p :<C-u>TSRefs<CR>
  nnoremap <silent> <buffer> <LocalLeader>r :<C-u>TSRename<CR>
  nnoremap <silent> <buffer> <LocalLeader>o :<C-u>Denite TSDocumentSymbol -auto-preview<CR>
endfunction

AutoCmd FileType javascript,typescript,typescript.tsx,vue call s:ts_settings()
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

" echodoc {{{3
let g:echodoc#enable_at_startup = 1
" let g:echodoc#type              = 'virtual'
" }}}3

" Denite {{{3
AlterCommand! <cmdwin> d[enite] Denite
AlterCommand! <cmdwin> dr       Denite<Space>-resume

if dein#tap('denite.nvim')
  " Denite

  "" highlight
  call denite#custom#option('default', 'prompt', '>')
  call denite#custom#option('default', 'mode', 'insert')
  call denite#custom#option('default', 'highlight_matched', 'Keyword')
  call denite#custom#option('default', 'highlight_mode_normal', 'DeniteLine')
  call denite#custom#option('default', 'highlight_mode_insert', 'DeniteLine')
  call denite#custom#option('default', 'statusline', v:false)

  "" keymap
  call denite#custom#map('normal', 't',     '<denite:do_action:tabopen>',     'noremap')
  call denite#custom#map('normal', '<C-n>', '<denite:move_to_next_line>',     'noremap')
  call denite#custom#map('normal', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map('normal', '<Esc>', '<denite:quit>',                  'noremap')
  call denite#custom#map('normal', '<C-g>', '<denite:quit>',                  'noremap')
  call denite#custom#map('normal', '<C-h>', '<denite:wincmd:h>',              'noremap')
  call denite#custom#map('normal', '<C-j>', '<denite:wincmd:j>',              'noremap')
  call denite#custom#map('normal', '<C-k>', '<denite:wincmd:k>',              'noremap')
  call denite#custom#map('normal', '<C-l>', '<denite:wincmd:l>',              'noremap')
  call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>',     'noremap')
  call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map('insert', '<Esc>', '<denite:enter_mode:normal>',     'noremap')
  call denite#custom#map('insert', '<C-g>', '<denite:enter_mode:normal>',     'noremap')

  "" Emacs bind
  call denite#custom#map('insert', '<C-f>', '<denite:move_caret_to_right>',            'noremap')
  call denite#custom#map('insert', '<C-b>', '<denite:move_caret_to_left>',             'noremap')
  call denite#custom#map('insert', '<C-a>', '<denite:move_caret_to_head>',             'noremap')
  call denite#custom#map('insert', '<C-e>', '<denite:move_caret_to_tail>',             'noremap')
  call denite#custom#map('insert', '<BS>',  '<denite:smart_delete_char_before_caret>', 'noremap')
  call denite#custom#map('insert', '<C-h>', '<denite:smart_delete_char_before_caret>', 'noremap')
  call denite#custom#map('insert', '<C-w>', '<denite:delete_word_before_caret>',       'noremap')
  call denite#custom#map('insert', '<C-k>', '<denite:delete_char_after_caret>',        'noremap')

  "" option
  call denite#custom#source('_',        'matchers', ['matcher/regexp'])
  call denite#custom#source('file_mru', 'matchers', ['matcher/fuzzy', 'matcher/project_files'])
  call denite#custom#source('line',     'matchers', ['matcher/regexp'])
  call denite#custom#source('grep',     'matchers', ['matcher/regexp'])
  call denite#custom#source('menu',     'matchers', ['matcher/regexp'])

  call denite#custom#source('file_mru', 'converters', ['converter/relative_abbr'])
  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
  \ [
  \  '*~', '*.o', '*.exe', '*.bak',
  \  '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
  \  '.hg/', '.git/', '.bzr/', '.svn/',
  \  'node_modules', 'vendor/bundle', '__pycache__/', 'venv/',
  \  'tags', 'tags-*', '.png', 'jp[e]g', '.gif',
  \  '*.min.*'
  \ ])

  call denite#custom#var('file_rec', 'command',        [ 'rg', '--files', '--glob', '!.git', ''])
  call denite#custom#var('grep',     'command',        ['rg'])
  call denite#custom#var('grep',     'default_opts',   ['--vimgrep', '--no-heading'])
  call denite#custom#var('grep',     'recursive_opts', [])
  call denite#custom#var('grep',     'pattern_opt',    ['--regexp'])
  call denite#custom#var('grep',     'separator',      ['--'])
  call denite#custom#var('grep',     'final_opts',     [])

  "" file & buffer
  " nnoremap <silent> <Leader>p :<C-u>Denite file/rec -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Denite buffer   -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>m :<C-u>Denite file_mru -direction=topleft -mode=insert<CR>

  "" grep
  nnoremap <silent> <Leader>/         :<C-u>Denite line<CR>
  nnoremap <silent> <Leader>*         :<C-u>DeniteCursorWord line<CR>
  nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep -post-action=open<CR>
  nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep -post-action=open<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Denite jump -auto-preview<CR>

  "" change
  nnoremap <silent> <Leader>; :<C-u>Denite change -auto-preview<CR>

  "" ctags & gtags
  nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord gtags_context tag -auto-preview<CR>

  "" menu
  let s:menus = {}
  let s:menus.toggle = { 'description': 'Toggle Command' }
  let s:menus.toggle.command_candidates = [
  \ ['Toggle CursorHighlight [CursorHighlightToggle]', 'CursorHighlightToggle'],
  \ ['Toggle IndentLine      [IndentLinesToggle]',     'IndentLinesToggle'    ],
  \ ['Toggle Highlight       [HighlightToggle]',       'HighlightToggle'      ],
  \ ['Toggle Spell           [setlocal spell!]',       'setlocal spell!'      ],
  \ ['Toggle ALE             [ALEToggle]',             'ALEToggle'            ],
  \ ['Toggle TableMode       [TableMode]',             'TableModeToggle'      ],
  \ ]
  call denite#custom#var('menu', 'menus', s:menus)
  nnoremap <silent> <Leader>t :<C-u>Denite menu:toggle<CR>
endif

" }}}3

" neomru {{{3
let g:neomru#file_mru_path       = expand('~/.cache/vim/neomru/file')
let g:neomru#dictionary_mru_path = expand('~/.cache/vim/neomru/dictionary')
" }}}3

" fzf {{{3
" Set default register
function! s:fzf_set_register()
  call fzf#run({
  \ 'source': <SID>get_register_history(),
  \ 'options': '--with-nth 2.. --prompt="RegisterHistory>"',
  \ 'sink': function('<SID>register_history_sink'),
  \ 'window': 'top split new',
  \ })
  execute 'resize' float2nr(0.3 * &lines)
endfunction

function! s:get_register_history()
  let l:histories = map(copy(g:_yankround_cache), 'split(v:val, "\t", 1)')
  return map(l:histories, 'v:val[0] . " "  . v:val[1]')
endfunction

function! s:register_history_sink(line)
  let l:parts = split(a:line, ' ', 1)
  call setreg('"', join(l:parts[1:], ' '), l:parts[0])
endfunction

command! FzfSetRegister call <SID>fzf_set_register()
nnoremap <silent> (ctrlp) :<C-u>FzfSetRegister<CR>

" Delete History
function! s:fzf_delete_history() abort
  call fzf#run({
  \ 'source': <SID>command_history(),
  \ 'options': '--multi --prompt="DeleteHistory>"',
  \ 'sink': function('<SID>delete_history'),
  \ 'window': 'top split new'
  \ })
  execute 'resize' float2nr(0.3 * &lines)
endfunction

function! s:command_history() abort
  let l:out = ''
  redir => l:out
  silent! history
  redir END

  return map(reverse(split(l:out, '\n')), "substitute(substitute(v:val, '\^\>', '', ''), '\^\\\s\\\+', '', '')")
endfunction

function! s:delete_history(command) abort
  call histdel(':', str2nr(get(split(a:command, '  '), 0)))
  wviminfo
endfunction

command! FzfDeleteHistory call s:fzf_delete_history()
" nnoremap <silent> <Leader>h :<C-u>FzfDeleteHistory<CR>

" Open File at Cursor
function! s:fzf_open_gf()
  let s:file_path = tolower(expand('<cfile>'))

  if s:file_path ==# ''
    echo '[Error] <cfile> return empty string.'
    return 0
  endif

  call fzf#run({
  \ 'source': 'rg --files --hidden --follow --glob "!.git/*"',
  \ 'sink': 'e',
  \ 'options': '-x --multi --prompt="CursorFiles>" --query=' . shellescape(s:file_path),
  \ 'window': 'top split new'})
  execute 'resize' float2nr(0.3 * &lines)
endfunction

command! FzfOpenGf call s:fzf_open_gf()
" nnoremap <silent> <leader>gf :FzfOpenGf<CR>
" }}}3

" fzf-preview {{{3
AlterCommand! <cmdwin> fg[rep] ProjectGrepPreview

let g:fzf_preview_filelist_command = 'rg --files --hidden --follow --glob "!.git/*"'
let g:fzf_preview_grep_preview_cmd = 'preview_fzf_grep'

nnoremap <silent> <Leader>p       :<C-u>ProjectFilesPreview<CR>
nnoremap <silent> <Leader>g       :<C-u>GitFilesPreview<CR>
nnoremap <silent> <Leader>b       :<C-u>BuffersPreview<CR>
nnoremap <silent> <Leader>o       :<C-u>ProjectMruFilesPreview<CR>
nnoremap <silent> <Leader>O       :<C-u>MruFilesPreview<CR>
nnoremap          <Enter>         :<C-u>ProjectGrepPreview<Space>
nnoremap          <Leader><Enter> "syiw:ProjectGrepPreview<Space><C-r>=substitute(@s, '/', '\\/', 'g')<CR>
xnoremap          <Enter>         "sy:ProjectGrepPreview<Space><C-r>=substitute(@s, '/', '\\/', 'g')<CR>
" }}}3

" deoplete.nvim & neosnippet {{{3
if dein#tap('deoplete.nvim') && dein#tap('neosnippet')
  " Default Settings
  let g:deoplete#enable_at_startup = 1

  call deoplete#custom#option({
  \ 'min_pattern_length': 2,
  \ 'camel_case': v:true,
  \ 'skip_chars': ['(', ')', '<', '>'],
  \ })

  " Keymap
  inoremap <silent> <expr> <BS>  deoplete#smart_close_popup() . "\<C-h>"
  inoremap <silent> <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"

  inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : deoplete#mappings#manual_complete()
  inoremap <silent> <expr> <C-g> pumvisible() ? deoplete#smart_close_popup() : "\<C-g>"
  inoremap <silent> <expr> <C-l> deoplete#refresh()

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " neosnippet
  let g:neosnippet#disable_runtime_snippets = { '_' : 1 }
  let g:neosnippet#snippets_directory = '~/.vim/snippets'

  imap <expr> <silent> <C-k> pumvisible() ? "\<Plug>(neosnippet_expand_or_jump)" : deoplete#smart_close_popup() . "\<Plug>(neosnippet_expand_or_jump)"
  smap <expr> <silent> <C-k> pumvisible() ? "\<Plug>(neosnippet_expand_or_jump)" : deoplete#smart_close_popup() . "\<Plug>(neosnippet_expand_or_jump)"
  xmap <expr> <silent> <C-k> pumvisible() ? "\<Plug>(neosnippet_expand_or_jump)" : deoplete#smart_close_popup() . "\<Plug>(neosnippet_expand_or_jump)"

  call deoplete#custom#source('_', 'converters', [
  \ 'converter_remove_paren',
  \ 'converter_remove_overlap',
  \ 'matcher_length',
  \ 'converter_truncate_abbr',
  \ 'converter_truncate_menu',
  \ 'converter_auto_delimiter',
  \ ])

  " Sources
  call deoplete#custom#source('typescript', 'rank', 1500)
  call deoplete#custom#source('typescript', 'mark', '[TS]')
  call deoplete#custom#source('typescript', 'max_candidates', 8)

  call deoplete#custom#source('lsp', 'rank', 1400)
  call deoplete#custom#source('lsp', 'mark', '[lsp]')
  call deoplete#custom#source('lsp', 'max_candidates', 8)

  " call deoplete#custom#source('LanguageClient', 'rank', 1400)
  " call deoplete#custom#source('LanguageClient', 'mark', '[LC]')
  " call deoplete#custom#source('LanguageClient', 'max_candidates', 8)

  call deoplete#custom#source('vim', 'rank', 1300)
  call deoplete#custom#source('vim', 'mark', '[vim]')
  call deoplete#custom#source('vim', 'max_candidates', 5)

  call deoplete#custom#source('tabnine', 'rank', 1200)
  call deoplete#custom#source('tabnine', 'mark', '[tabnine]')
  call deoplete#custom#source('tabnine', 'max_candidates', 10)

  " call deoplete#custom#source('around', 'rank', 1000)
  " call deoplete#custom#source('around', 'mark', '[around]')
  " call deoplete#custom#source('around', 'max_candidates', 5)

  " call deoplete#custom#source('buffer', 'rank', 800)
  " call deoplete#custom#source('buffer', 'mark', '[buffer]')
  " call deoplete#custom#source('buffer', 'max_candidates', 5)

  " call deoplete#custom#source('tag', 'rank', 700)
  " call deoplete#custom#source('tag', 'mark', '[tag]')
  " call deoplete#custom#source('tag', 'max_candidates', 5)

  call deoplete#custom#source('omni', 'rank', 600)
  call deoplete#custom#source('omni', 'mark', '[omni]')
  call deoplete#custom#source('omni', 'max_candidates', 5)

  call deoplete#custom#source('neosnippet', 'rank', 500)
  call deoplete#custom#source('neosnippet', 'mark', '[snippet]')
  call deoplete#custom#source('neosnippet', 'max_candidates', 5)

  call deoplete#custom#source('syntax', 'rank', 400)
  call deoplete#custom#source('syntax', 'mark', '[syntax]')
  call deoplete#custom#source('syntax', 'max_candidates', 5)

  call deoplete#custom#source('file', 'rank', 300)
  call deoplete#custom#source('file', 'mark', '[file]')
  call deoplete#custom#source('file', 'max_candidates', 5)

  call deoplete#custom#source('tmux-complete', 'rank', 200)
  call deoplete#custom#source('tmux-complete', 'mark', '[tmux]')
  call deoplete#custom#source('tmux-complete', 'max_candidates', 5)

  call deoplete#custom#source('webcomplete', 'rank', 100)
  call deoplete#custom#source('webcomplete', 'mark', '[web]')
  call deoplete#custom#source('webcomplete', 'max_candidates', 5)

  call deoplete#custom#source('look', 'rank', 100)
  call deoplete#custom#source('look', 'mark', '[look]')
  call deoplete#custom#source('look', 'max_candidates', 5)

  let s:deoplete_default_sources = ['tabnine', 'neosnippet', 'syntax', 'file', 'tmux-complete', 'webcomplete', 'look']

  let s:deoplete_sources                   = {}
  let s:deoplete_sources['_']              = s:deoplete_default_sources
  let s:deoplete_sources['javascript']     = s:deoplete_default_sources + ['typescript']
  let s:deoplete_sources['typescript']     = s:deoplete_default_sources + ['typescript']
  let s:deoplete_sources['typescript.tsx'] = s:deoplete_default_sources + ['typescript']
  let s:deoplete_sources['vue']            = s:deoplete_default_sources + ['typescript', 'lsp']
  let s:deoplete_sources['ruby']           = s:deoplete_default_sources + ['lsp']
  let s:deoplete_sources['go']             = s:deoplete_default_sources + ['lsp']
  let s:deoplete_sources['css']            = s:deoplete_default_sources + ['omni']
  let s:deoplete_sources['scss']           = s:deoplete_default_sources + ['omni']
  let s:deoplete_sources['vim']            = s:deoplete_default_sources + ['vim']
  call deoplete#custom#option('sources', s:deoplete_sources)

  let s:deoplete_omni_functions         = {}
  let s:deoplete_omni_functions['css']  = ['csscomplete#CompleteCSS']
  let s:deoplete_omni_functions['scss'] = ['csscomplete#CompleteCSS']
  call deoplete#custom#source('omni', 'functions', s:deoplete_omni_functions)
endif
" }}}3

" LanguageClient {{{3
" let g:LanguageClient_diagnosticsEnable = 0
" let g:LanguageClient_useFloatingHover  = 1
"
" let g:LanguageClient_serverCommands = {
" \ 'ruby': ['solargraph', 'stdio'],
" \ }
"
" function! s:language_client_settings() abort
"   nnoremap <silent> <buffer> <LocalLeader>m             :<C-u>call LanguageClient_contextMenu()<CR>
"   nnoremap <silent> <buffer> K                          :<C-u>call LanguageClient#textDocument_definition()<CR>
"   nnoremap <silent> <buffer> gK                         :<C-u>call LanguageClient#textDocument_hover()<CR>
"   nnoremap <silent> <buffer> <LocalLeader>p             :<C-u>call LanguageClient#textDocument_references()<CR>
"   nnoremap <silent> <buffer> <LocalLeader>r             :<C-u>call LanguageClient#textDocument_rename()<CR>
"   nnoremap <silent> <buffer> <LocalLeader><LocalLeader> :<C-u>call LanguageClient#textDocument_codeAction()<CR>
" endfunction
"
" AutoCmd FileType ruby call s:language_client_settings()
" }}}3

" lsp {{{3
let g:lsp_diagnostics_enabled = 0

if executable('vls')
  AutoCmd User lsp_setup call lsp#register_server({
  \ 'name': 'vue-language-server',
  \ 'cmd': {server_info->['vls']},
  \ 'whitelist': ['vue'],
  \ 'initialization_options': {
  \   'config': {
  \     'html': {},
  \     'vetur': {
  \       'validation': {},
  \      },
  \   },
  \ },
  \ })
endif

if executable('solargraph')
  AutoCmd User lsp_setup call lsp#register_server({
  \ 'name': 'solargraph',
  \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
  \ 'whitelist': ['ruby'],
  \ })
endif

if executable('gopls')
  AutoCmd User lsp_setup call lsp#register_server({
  \ 'name': 'go-lang',
  \ 'cmd': {server_info->['gopls']},
  \ 'whitelist': ['go'],
  \ })
endif

function! s:lsp_settings() abort
  nnoremap <silent> <buffer> K                          :<C-u>LspDefinition<CR>
  nnoremap <silent> <buffer> gK                         :<C-u>LspHover<CR>
  nnoremap <silent> <buffer> <LocalLeader>p             :<C-u>LspReferences<CR>
  nnoremap <silent> <buffer> <LocalLeader>r             :<C-u>LspRename<CR>
  nnoremap <silent> <buffer> <LocalLeader><LocalLeader> :<C-u>LspCodeAction<CR>
endfunction

AutoCmd FileType ruby,go call s:lsp_settings()
" }}}3

" lexima {{{3
if dein#tap('lexima.vim')

  let g:lexima_map_escape = ''

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
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': 'do\%#',     'input': '<Space><Bar>', 'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': 'do\s\%#',   'input': '<Bar>',        'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': '{\%#}',     'input': '<Space><Bar>', 'input_after': '<Bar><Space>', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': '{\s\%#\s}', 'input': '<Bar>',        'input_after': '<Bar><Space>', },
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

" git-gutter {{{3
AlterCommand! <cmdwin> ga GitGutterStageHunk
AlterCommand! <cmdwin> gr GitGutterUndoHunk

let g:gitgutter_map_keys = 0
nmap gn <Plug>GitGutterNextHunk
nmap gp <Plug>GitGutterPrevHunk
" }}}3

" git-messenger {{{3
let g:git_messenger_no_default_mappings = v:true
nmap <Leader>m <Plug>(git-messenger)
" }}}3

" git-switcher {{{3
AlterCommand! <cmdwin> gsw Gsw
AlterCommand! <cmdwin> gss GswSave
AlterCommand! <cmdwin> gsl GswLoad
" }}}3

" gina {{{3
AlterCommand! <cmdwin> git   Gina
AlterCommand! <cmdwin> gina  Gina
AlterCommand! <cmdwin> gs    Gina<Space>status
AlterCommand! <cmdwin> gp    Gina<Space>patch
AlterCommand! <cmdwin> gci   Gina<Space>commit
AlterCommand! <cmdwin> gd    Gina<Space>diff
AlterCommand! <cmdwin> gdc   Gina<Space>diff<Space>--cached
AlterCommand! <cmdwin> blame Gina<Space>blame

if dein#tap('gina.vim')
  function! Hook_on_post_source_gina()
    call gina#custom#command#option('status', '--short')

    call gina#custom#command#option('/\%(status\|commit\|branch\)', '--opener', 'split')
    call gina#custom#command#option('/\%(diff\|log\)', '--opener',  'vsplit')

    call gina#custom#command#option('/\%(status\|changes\)', '--ignore-submodules')
    call gina#custom#command#option('status', '--branch')
    call gina#custom#command#option('branch', '-v', 'v')
    call gina#custom#command#option('branch', '--all')

    call gina#custom#mapping#nmap('status', '<C-j>', '<C-w>j',                {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('status', '<C-k>', '<C-w>k',                {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('status', '<C-^>', ':<C-u>Gina commit<CR>', {'noremap': 1, 'silent': 1})

    call gina#custom#mapping#vmap('show',   'p',     ':diffput<CR>',          {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#vmap('show',   'o',     ':diffget<CR>',          {'noremap': 1, 'silent': 1})

    call gina#custom#mapping#nmap('commit', '<C-^>', ':<C-u>Gina status<CR>', {'noremap': 1, 'silent': 1})

    call gina#custom#mapping#nmap('branch', '<C-k>', '<C-w>k', {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('branch', 'g<CR>', '<Plug>(gina-commit-checkout-track)')
    call gina#custom#mapping#nmap('branch', 'nn',    '<Plug>(gina-branch-new)')
    call gina#custom#mapping#nmap('branch', 'dd',    '<Plug>(gina-branch-delete)')
    call gina#custom#mapping#nmap('branch', 'DD',    '<Plug>(gina-branch-delete-force)')

    call gina#custom#mapping#nmap('blame',  '<C-l>', '<C-w>l',                    {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('blame',  '<C-r>', '<Plug>(gina-blame-redraw)', {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('blame',  'j',     'j<Plug>(gina-blame-echo)')
    call gina#custom#mapping#nmap('blame',  'k',     'k<Plug>(gina-blame-echo)')

    call gina#custom#action#alias('/\%(blame\|log\|reflog\)', 'preview', 'topleft show:commit:preview')
    call gina#custom#mapping#nmap('/\%(blame\|log\|reflog\)', 'p',       ":<C-u>call gina#action#call('preview')<CR>", {'noremap': 1, 'silent': 1})

    call gina#custom#execute('/\%(ls\|log\|reflog\|grep\)',                 'setlocal noautoread')
    call gina#custom#execute('/\%(status\|branch\|ls\|log\|reflog\|grep\)', 'setlocal cursorline')

    call gina#custom#mapping#nmap('/\%(status\|commit\|branch\|ls\|log\|reflog\|grep\)', 'q', 'ZQ', {'nnoremap': 1, 'silent': 1})
  endfunction
endif
" }}}3

" }}}2

" filer {{{2

" fila {{{3
let g:fila#viewer#skip_default_mappings = 1
let g:fila#viewer#drawer#width          = 40

nnoremap <silent> <Leader>e :<C-u>Fila . -drawer <CR>
nnoremap <silent> <Leader>E :<C-u>Fila . -drawer -reveal=<C-r>=expand('%')<CR><CR>

function! s:fila_settings() abort
  nmap <buffer> <CR>  <Plug>(fila-action-edit-select)
  nmap <buffer> t     <Plug>(fila-action-expand-or-collapse)
  nmap <buffer> l     <Plug>(fila-action-enter-or-edit)
  nmap <buffer> h     <Plug>(fila-action-leave)
  nmap <buffer> .     <Plug>(fila-action-hidden-toggle)
  nmap <buffer> x     <Plug>(fila-action-mark-toggle)
  vmap <buffer> x     <Plug>(fila-action-mark-toggle)
  nmap <buffer> N     <Plug>(fila-action-new-file)
  nmap <buffer> K     <Plug>(fila-action-new-directory)
  nmap <buffer> dd    <Plug>(fila-action-delete)
  nmap <buffer> r     <Plug>(fila-action-move)
  nmap <buffer> cc    <Plug>(fila-action-copy)
  nmap <buffer> p     <Plug>(fila-action-paste)
  nmap <buffer> R     <Plug>(fila-action-reload)
  nmap <buffer> <C-g> <Plug>(fila-action-echo)

  nnoremap <silent> <buffer> q :<C-u>call fila#viewer#drawer#close()<CR>
  nnoremap <silent> <buffer> Q :<C-u>call fila#viewer#drawer#quit()<CR>
endfunction

AutoCmd FileType fila call s:fila_settings()
" }}}3

" }}}2

" textobj & operator {{{2

" operator-replace {{{3
map _ <Plug>(operator-replace)
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

" ags {{{3
AlterCommand! <cmdwin> ag  Ags
AlterCommand! <cmdwin> age AgsEditSearchResult
AutoCmd FileType agsv,agse nnoremap <silent> <buffer> q :<C-u>quit<CR>
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

" clever-f & shot-f {{{3
if dein#tap('vim-easymotion') && dein#tap('clever-f.vim')
  " EasyMotion
  let g:EasyMotion_do_mapping       = 0
  let g:EasyMotion_smartcase        = 1
  let g:EasyMotion_startofline      = 0
  let g:EasyMotion_keys             = 'HJKLASDFGYUIOPQWERTNMZXCVB'
  let g:EasyMotion_use_upper        = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
  let g:EasyMotion_prompt           = 'Search by EasyMotion ({n} character(s)) > '

  nmap <silent> S  <Plug>(easymotion-bd-f2)
  omap <silent> S  <Plug>(easymotion-bd-f2)
  xmap <silent> S  <Plug>(easymotion-bd-f2)
  nmap <silent> ss <Plug>(easymotion-bd-f2)
  omap <silent> ss <Plug>(easymotion-bd-f2)
  xmap <silent> ss <Plug>(easymotion-bd-f2)
  omap <silent> f  <Plug>(easymotion-fl)
  omap <silent> t  <Plug>(easymotion-tl)
  omap <silent> F  <Plug>(easymotion-Fl)
  omap <silent> T  <Plug>(easymotion-Tl)

  " clever-f
  let g:clever_f_not_overwrites_standard_mappings = 0

  nmap <silent> f <Plug>(clever-f-f)
  nmap <silent> F <Plug>(clever-f-F)
  nmap <silent> t <Plug>(clever-f-t)
  nmap <silent> T <Plug>(clever-f-T)
  xmap <silent> f <Plug>(clever-f-f)
  xmap <silent> F <Plug>(clever-f-F)
  xmap <silent> t <Plug>(clever-f-t)
  xmap <silent> T <Plug>(clever-f-T)
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

" ferret {{{3
AlterCommand! <cmdwin> rg  Ack<Space>--smart-case
AlterCommand! <cmdwin> ack Ack<Space>--smart-case

let g:FerretMap      = 0
let g:FerretHlsearch = 1
let g:FerretAutojump = 0
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  nmap J  <Plug>(jplus)
  vmap J  <Plug>(jplus)
  nmap gJ <Plug>(jplus-input)
  vmap gJ <Plug>(jplus-input)
endif
" }}}3

" qfreplace {{{3
AutoCmd FileType qf nnoremap <silent> <buffer> r :<C-u>Qfreplace<CR>
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
endif
" }}}3

" tcomment {{{3
let g:tcomment_maps = 0

noremap <silent> <Leader>cc :TComment<CR>
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
let g:better_whitespace_filetypes_blacklist = ['markdown', 'diff', 'qf', 'help', 'gitcommit', 'gitrebase', 'denite', 'ctrlsf']
" }}}3

" brightest {{{3
AlterCommand! <cmdwin> br[ight] BrightestToggle

let g:brightest#enable_on_CursorHold        = 1
let g:brightest#enable_highlight_all_window = 1
let g:brightest#highlight = {'group': 'BrighTestHighlight'}
" let g:brightest#ignore_syntax_list = ['Statement', 'Keyword', 'Boolean', 'Repeat']
" }}}3

" foldCC {{{3
if dein#tap('foldCC.vim')
  set foldtext=FoldCCtext()
endif
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
let g:indentLine_enabled         = 0
let g:indentLine_fileTypeExclude = ['json']
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'iceberg_yano',
  \ 'active': {
  \   'left': [
  \     ['mode', 'spell', 'paste'],
  \     ['denite', 'filepath', 'filename'],
  \     ['special_mode', 'anzu', 'vm_regions'],
  \     [],
  \    ],
  \   'right': [
  \     ['lineinfo'],
  \     ['filetype', 'fileencoding', 'fileformat'],
  \     ['linter_errors', 'linter_warnings', 'linter_ok', 'linter_checking', 'linter_disable'],
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
  \   'denite':       'Lightline_denite',
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
  \   'linter_errors':   'error',
  \   'linter_warnings': 'warning',
  \   'linter_ok':       'ok',
  \   'linter_checking': 'checking',
  \   'linter_disable':  'disable',
  \ },
  \ 'component_expand': {
  \   'linter_errors':   'Lightline_ale_errors',
  \   'linter_warnings': 'Lightline_ale_warnings',
  \   'linter_ok':       'Lightline_ale_ok',
  \   'linter_checking': 'Lightline_ale_checking',
  \   'linter_disable':  'Lightline_ale_disable',
  \ },
  \ 'enable': {
  \   'statusline': 1,
  \   'tabline':    1,
  \ },
  \ 'separator': { 'left': '', 'right': '' },
  \ 'subseparator': { 'left': '', 'right': '' }
  \ }

  " lightline-ale
  let g:lightline#ale#indicator_errors   = ' '
  let g:lightline#ale#indicator_warnings = ' '
  let g:lightline#ale#indicator_ok       = ' '
  let g:lightline#ale#indicator_checking = ' '

  " Disable lineinfo, fileencoding and fileformat
  let s:lightline_ignore_right_ft = [
  \ 'help',
  \ 'diff',
  \ 'man',
  \ 'fzf',
  \ 'denite',
  \ 'fila',
  \ 'capture',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ 'agsv',
  \ 'agse',
  \ ]

  let s:lightline_ft_to_mode_hash = {
  \ 'help':        'Help',
  \ 'diff':        'Diff',
  \ 'man':         'Man',
  \ 'fzf':         'FZF',
  \ 'denite':      'Denite',
  \ 'fila':        'Fila',
  \ 'capture':     'Capture',
  \ 'gina-status': 'Git Status',
  \ 'gina-branch': 'Git Branch',
  \ 'gina-log':    'Git Log',
  \ 'gina-reflog': 'Git Reflog',
  \ 'gina-blame':  'Git Blame',
  \ 'agsv':        'AgsView',
  \ 'agse':        'AgsEdit',
  \ }

  let s:lightline_ignore_modifiable_ft = [
  \ 'qf',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ 'agsv',
  \ ]

  let s:lightline_ignore_filename_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'fila',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ 'agsv',
  \ 'agse',
  \ ]

  let s:lightline_ignore_filepath_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'fila',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ 'agsv',
  \ 'agse',
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
    return !has_key(s:lightline_ft_to_mode_hash, &filetype) ?
    \ &filetype :
    \ ''
  endfunction

  function! Lightline_lineinfo() abort
    if !Lightline_is_visible(120)
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

  function! Lightline_ale_errors() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#errors() : ''
  endfunction

  function! Lightline_ale_warnings() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#warnings() : ''
  endfunction

  function! Lightline_ale_ok() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#ok() : ''
  endfunction

  function! Lightline_ale_checking() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#checking() : ''
  endfunction

  function! Lightline_ale_disable() abort
    " return count(g:ale_filetypes, &filetype) ? '' : 'Linter Disable'
    return count(g:ale_filetypes, &filetype) ? '' : ''
  endfunction

  function! Lightline_denite() abort
    return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  endfunction

  function! Lightline_vm_regions() abort
    if exists('g:VM') && g:VM.is_active
      let l:index = b:VM_Selection.Vars.index + 1
      let l:max   = len(b:VM_Selection.Regions)
      return '(' . l:index . '/' . l:max . ')'
    else
      return ''
    endif
  endfunction
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
\ 'denite'      : 0,
\ 'git'         : 0,
\ 'gitcommit'   : 0,
\ 'gina-status' : 0,
\ 'gina-commit' : 0,
\ 'gina-reflog' : 0,
\ 'gina-blame'  : 0,
\ 'capture'     : 0,
\ 'agsv'        : 0,
\ 'agse'        : 0,
\ }
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

" bufkill {{{3
let g:BufKillCreateMappings = 0
nnoremap <silent> <Leader>d :BD<CR>

AutoCmd FileType help   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType diff   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType git    nnoremap <silent> <buffer> <Leader>d :BW<CR>
" }}}3

" capture {{{3
AlterCommand! <cmdwin> cap[ture] Capture
AutoCmd FileType capture nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}3

" miniyank {{{3
let g:miniyank_maxitems = 2000
let g:miniyank_filename = expand('~/.cache/vim/miniyank.mpack')
" }}}3

" table-mode {{{3
let g:table_mode_corner='|'
" }}}3

" undotree {{{3
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0
nnoremap <silent> <C-w><C-w> :call WindowSwap#EasyWindowSwap()<CR>
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
AutoCmd ColorScheme * highlight CursorColumn ctermfg=none ctermbg=236  guifg=none    guibg=#303030
AutoCmd ColorScheme * highlight CursorLine   ctermfg=none ctermbg=236  guifg=none    guibg=#303030
AutoCmd ColorScheme * highlight CursorLineNr ctermfg=253  ctermbg=none guifg=#DADADA guibg=none
AutoCmd ColorScheme * highlight LineNr       ctermfg=241  ctermbg=none guifg=#626262 guibg=none
AutoCmd ColorScheme * highlight NonText      ctermfg=60   ctermbg=none guifg=#5F5F87 guibg=none
AutoCmd ColorScheme * highlight Search       ctermfg=68   ctermbg=232  guifg=#5F87D7 guibg=#080808
AutoCmd ColorScheme * highlight Todo         ctermfg=229  ctermbg=none guifg=#FFFFAF guibg=none
AutoCmd ColorScheme * highlight Visual       ctermfg=159  ctermbg=23   guifg=#AFFFFF guibg=#005F5F

AutoCmd ColorScheme * highlight ALEError                ctermfg=0    ctermbg=203                       guifg=#1E2132 guibg=#FF5F5F
AutoCmd ColorScheme * highlight ALEWarning              ctermfg=0    ctermbg=229                       guifg=#1E2132 guibg=#FFFFAF
AutoCmd ColorScheme * highlight BrightestHighlight      ctermfg=30   ctermbg=none                      guifg=#008787 guibg=none
AutoCmd ColorScheme * highlight CleverFDefaultLabel     ctermfg=9    ctermbg=236  cterm=underline,bold guifg=#E98989 guibg=#303030 gui=underline,bold
AutoCmd ColorScheme * highlight DeniteLine              ctermfg=111  ctermbg=236                       guifg=#87AFFF guibg=#303030
AutoCmd ColorScheme * highlight EasyMotionMoveHLDefault ctermfg=9    ctermbg=236  cterm=underline,bold guifg=#E98989 guibg=#303030 gui=underline,bold
AutoCmd ColorScheme * highlight ExtraWhiteSpace         ctermfg=none ctermbg=1                         guifg=none    guibg=#E98989
AutoCmd ColorScheme * highlight HighlightedyankRegion   ctermfg=1    ctermbg=none                      guifg=#E27878 guibg=none
AutoCmd ColorScheme * highlight MatchParen              ctermfg=none ctermbg=none cterm=underline      guifg=none    guibg=none    gui=underline
AutoCmd ColorScheme * highlight MatchParenCur           ctermfg=none ctermbg=none cterm=bold           guifg=none    guibg=none    gui=bold
AutoCmd ColorScheme * highlight MatchWord               ctermfg=none ctermbg=none cterm=underline      guifg=none    guibg=none    gui=underline
AutoCmd ColorScheme * highlight MatchWordCur            ctermfg=none ctermbg=none cterm=bold           guifg=none    guibg=none    gui=bold
AutoCmd ColorScheme * highlight YankRoundRegion         ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A
AutoCmd ColorScheme * highlight ZenSpace                ctermfg=none ctermbg=1                         guifg=none    guibg=#E98989
AutoCmd ColorScheme * highlight deniteSource_grepFile   ctermfg=6    ctermbg=none                      guifg=#89B8C2 guibg=none
AutoCmd ColorScheme * highlight deniteSource_grepLineNR ctermfg=247  ctermbg=none                      guifg=#9E9E9E guibg=none

" Fix lightline
" AutoCmd ColorScheme * highlight StatusLine   ctermfg=0 ctermbg=none guifg=#1E2132 guibg=#C6C8D1
" AutoCmd ColorScheme * highlight StatusLineNC ctermfg=0 ctermbg=none guifg=#1E2132 guibg=#C6C8D1
" }}}2

" iceberg {{{2
colorscheme iceberg
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
