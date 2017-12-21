" Plugin Manager {{{1

" Install & Load Dein {{{2
let s:DEIN_BASE_PATH = '~/.vim/bundle/'
let s:DEIN_PATH      = expand(s:DEIN_BASE_PATH . 'repos/github.com/Shougo/dein.vim')
if !isdirectory(s:DEIN_PATH)
  if (executable('git') == 1) && (confirm('Install dein.vim or Launch vim immediately', "&Yes\n&No", 1) == 1)
    execute '!git clone --depth=1 https://github.com/Shougo/dein.vim' s:DEIN_PATH
  endif
endif

let &runtimepath .= ',' . s:DEIN_PATH
let g:dein#install_process_timeout = 300
" }}}2

" Load Plugin {{{2
if dein#load_state(s:DEIN_BASE_PATH)
  call dein#begin(s:DEIN_BASE_PATH)

  " Dein {{{3
  call dein#add('Shougo/dein.vim')
  call dein#add('haya14busa/dein-command.vim', {'lazy': 1, 'on_cmd': 'Dein'})
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja')
  " }}}3

  " Language {{{3
  call dein#add('Chiel92/vim-autoformat',                  {'lazy': 1, 'on_cmd': 'Autoformat'})
  call dein#add('Shougo/context_filetype.vim')
  call dein#add('Shougo/echodoc.vim',                      {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('Valloric/MatchTagAlways',                 {'lazy': 1, 'on_ft': ['html', 'xml', 'erb']})
  call dein#add('Vimjas/vim-python-pep8-indent',           {'lazy': 1, 'on_ft': 'python'})
  call dein#add('ap/vim-css-color',                        {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('cakebaker/scss-syntax.vim',               {'lazy': 1, 'on_ft': ['sass', 'scss']})
  call dein#add('cespare/vim-toml',                        {'lazy': 1, 'on_ft': 'toml'})
  call dein#add('davidhalter/jedi-vim',                    {'lazy': 1, 'on_ft': 'python'})
  call dein#add('editorconfig/editorconfig-vim',           {'lazy': 1})
  call dein#add('ekalinin/Dockerfile.vim',                 {'lazy': 1, 'on_ft': 'dockerfile'})
  call dein#add('elzr/vim-json',                           {'lazy': 1, 'on_ft': 'json'})
  call dein#add('fatih/vim-go',                            {'lazy': 1, 'on_ft': 'go'})
  call dein#add('hail2u/vim-css3-syntax',                  {'lazy': 1, 'on_ft': 'css'})
  call dein#add('hashivim/vim-terraform',                  {'lazy': 1, 'on_ft': 'terraform'})
  call dein#add('heavenshell/vim-pydocstring',             {'lazy': 1, 'on_ft': 'python'})
  call dein#add('kchmck/vim-coffee-script',                {'lazy': 1, 'on_ft': 'coffee'})
  call dein#add('kewah/vim-stylefmt',                      {'lazy': 1, 'on_ft': 'css'})
  call dein#add('mattn/emmet-vim',                         {'lazy': 1, 'on_ft': ['html', 'eruby.html', 'javascript', 'vue', 'vue.html.javascript.css']})
  call dein#add('maxmellon/vim-jsx-pretty',                {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('mkomitee/vim-gf-python',                  {'lazy': 1, 'on_ft': 'python'})
  call dein#add('moll/vim-node',                           {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('nsf/gocode',                              {'lazy': 1, 'on_ft': 'go', 'rtp': 'nvim', 'build': 'vim/symlink.sh'})
  call dein#add('othree/csscomplete.vim',                  {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('othree/es.next.syntax.vim',               {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/html5.vim',                        {'lazy': 1, 'on_ft': ['html', 'eruby']})
  call dein#add('othree/javascript-libraries-syntax.vim',  {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/jspc.vim',                         {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('pangloss/vim-javascript',                 {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('posva/vim-vue',                           {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('rhysd/vim-gfm-syntax',                    {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('slim-template/vim-slim',                  {'lazy': 1, 'on_ft': 'slim'})
  call dein#add('soramugi/auto-ctags.vim')
  call dein#add('styled-components/vim-styled-components', {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('tell-k/vim-autopep8',                     {'lazy': 1, 'on_ft': 'python'})
  call dein#add('thinca/vim-ft-help_fold',                 {'lazy': 1, 'on_ft': 'help'})
  call dein#add('tmhedberg/SimpylFold',                    {'lazy': 1, 'on_ft': 'python'})
  call dein#add('tmux-plugins/vim-tmux',                   {'lazy': 1, 'on_ft': 'tmux'})
  call dein#add('vim-jp/syntax-vim-ex',                    {'lazy': 1, 'on_ft': 'vim'})
  call dein#add('vim-python/python-syntax',                {'lazy': 1, 'on_ft': 'python'})
  call dein#add('vim-ruby/vim-ruby',                       {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
  call dein#add('vim-scripts/python_match.vim',            {'lazy': 1, 'on_ft': 'python'})
  call dein#add('vimperator/vimperator.vim',               {'lazy': 1, 'on_ft': 'vimperator'})
  call dein#add('vimtaku/hl_matchit.vim',                  {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('w0rp/ale',                                {'lazy': 1, 'on_ft': ['javascript', 'ruby', 'vue', 'css']})
  call dein#add('ywatase/mdt.vim',                         {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('zebult/auto-gtags.vim')
  " }}}3

  " Git {{{3
  call dein#add('airblade/vim-gitgutter')
  call dein#add('cohama/agit.vim', {'lazy': 1, 'on_cmd': ['Agit', 'AgitFile']})
  call dein#add('lambdalisue/gina.vim', {'lazy': 1, 'on_cmd': 'Gina', 'on_map': '<Plug>', 'on_event': 'BufWritePost', 'hook_post_source': 'call Hook_on_post_source_gina()'})
  call dein#add('lambdalisue/vim-unified-diff')
  call dein#add('rhysd/committia.vim')
  " }}}3

  " Completion {{{3
  call dein#add('Shougo/deoplete.nvim', {'lazy': 1, 'on_event': 'InsertEnter', 'hook_post_source': 'call Hook_on_post_source_deoplete()'})
  if !has('nvim')
    call dein#add('roxma/nvim-yarp',          {'lazy': 1, 'on_event': 'InsertEnter'})
    call dein#add('roxma/vim-hug-neovim-rpc', {'lazy': 1, 'on_event': 'InsertEnter'})
  endif

  let s:lazy_deoplete = {'lazy': 1, 'on_source': 'deoplete.nvim'}
  call dein#add('Shougo/neco-vim',            s:lazy_deoplete)
  call dein#add('carlitux/deoplete-ternjs',   s:lazy_deoplete)
  call dein#add('ozelentok/deoplete-gtags',   s:lazy_deoplete)
  call dein#add('ujihisa/neco-look',          s:lazy_deoplete)
  call dein#add('wokalski/autocomplete-flow', s:lazy_deoplete)
  call dein#add('zchee/deoplete-jedi',        s:lazy_deoplete)
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/denite.nvim')

  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/neoyank.vim')
  call dein#add('Shougo/unite-session')
  call dein#add('Shougo/vimfiler')
  call dein#add('chemzqm/denite-extra')
  call dein#add('hewes/unite-gtags')
  call dein#add('osyo-manga/unite-highlight')
  call dein#add('osyo-manga/unite-quickfix')
  call dein#add('ozelentok/denite-gtags')
  call dein#add('tsukkee/unite-tag')

  call dein#add('lighttiger2505/gtags.vim')

  call dein#add('Shougo/neosnippet')
  call dein#add('honza/vim-snippets')

  call dein#add('nixprime/cpsm', {'build': 'env PY3=ON ./install.sh'})
  " }}}3

  " Edit & Move & Search {{{3
  call dein#add('LeafCage/yankround.vim',         {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('chrisbra/NrrwRgn',               {'lazy': 1, 'on_cmd': ['NR', 'NW', 'WidenRegion', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL']})
  call dein#add('cohama/lexima.vim',              {'lazy': 1, 'on_event': 'InsertEnter', 'hook_post_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('dhruvasagar/vim-table-mode',     {'lazy': 1, 'on_cmd': 'TableModeToggle'})
  call dein#add('easymotion/vim-easymotion',      {'lazy': 1, 'on_map': {'nvxo': '<Plug>'}})
  call dein#add('godlygeek/tabular',              {'lazy': 1, 'on_cmd': 'Tabularize'})
  call dein#add('h1mesuke/vim-alignta',           {'lazy': 1, 'on_cmd': 'Alignta'})
  call dein#add('haya14busa/incsearch.vim',       {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-asterisk',        {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-metarepeat',      {'lazy': 1, 'on_map': ['go', 'g.']})
  call dein#add('junegunn/vim-easy-align',        {'lazy': 1, 'on_map': {'v': '<Plug>'}})
  call dein#add('jwhitley/vim-matchit')
  call dein#add('kana/vim-operator-replace',      {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('mopp/vim-operator-convert-case')
  call dein#add('osyo-manga/vim-anzu',            {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('osyo-manga/vim-jplus',           {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('osyo-manga/vim-over',            {'lazy': 1, 'on_cmd': 'OverCommandLine'})
  call dein#add('rhysd/clever-f.vim',             {'lazy': 1, 'on_map': {'nvxo': '<Plug>'}})
  call dein#add('rking/ag.vim',                   {'lazy': 1, 'on_cmd': 'Ag'})
  call dein#add('thinca/vim-qfreplace',           {'lazy': 1, 'on_cmd': ['Qfreplace', 'Unite', 'UniteWithCursorWord', 'Vimfiler', 'VimFilerExplorer']})
  call dein#add('thinca/vim-visualstar',          {'lazy': 1, 'on_map': {'v': '<Plug>'}})
  call dein#add('tomtom/tcomment_vim',            {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat',               {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('tpope/vim-speeddating',          {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('tpope/vim-surround')
  " }}}3

  " Appearance {{{3
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Yggdroot/indentLine',            {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('cocopon/iceberg.vim')
  call dein#add('edkolev/tmuxline.vim',           {'lazy': 1, 'on_cmd': ['Tmuxline', 'TmuxlineSimple', 'TmuxlineSnapshot']})
  call dein#add('gregsexton/MatchTag')
  call dein#add('haya14busa/vim-operator-flashy', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('itchyny/lightline.vim')
  call dein#add('itchyny/vim-cursorword')
  call dein#add('itchyny/vim-highlighturl')
  call dein#add('itchyny/vim-parenmatch')
  call dein#add('luochen1990/rainbow')
  call dein#add('mopp/smartnumber.vim',           {'lazy': 1, 'on_cmd': 'SNumbersToggleRelative'})
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('thinca/vim-zenspace')
  call dein#add('vim-scripts/AnsiEsc.vim')
  call dein#add('vimtaku/hl_matchit.vim')
  " }}}3

  " Util {{{3
  call dein#add('Shougo/deol.nvim',             {'lazy': 1, 'on_cmd': ['Deol', 'DeolCd', 'DeolEdit'], 'on_map': '<Plug>'})
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bogado/file-line')
  call dein#add('daisuzu/translategoogle.vim',  {'lazy': 1, 'on_cmd': 'Trans'})
  call dein#add('dietsche/vim-lastplace')
  call dein#add('itchyny/vim-extracmd')
  call dein#add('janko-m/vim-test',             {'lazy': 1, 'on_cmd': ['TestNearest','TestFile','TestSuite','TestLast','TestVisit']})
  call dein#add('kana/vim-niceblock',           {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('kana/vim-operator-user')
  call dein#add('kana/vim-submode')
  call dein#add('kana/vim-textobj-user')
  call dein#add('kassio/neoterm')
  call dein#add('konfekt/fastfold')
  call dein#add('lambdalisue/suda.vim')
  call dein#add('majutsushi/tagbar',            {'lazy': 1, 'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('mattn/benchvimrc-vim',         {'lazy': 1, 'on_cmd': 'BenchVimrc'})
  call dein#add('mbbill/undotree',              {'lazy': 1, 'on_cmd': 'UndotreeToggle'})
  call dein#add('mtth/scratch.vim',             {'lazy': 1, 'on_cmd': 'Scratch'})
  call dein#add('qpkorr/vim-bufkill')
  call dein#add('simeji/winresizer',            {'lazy': 1, 'on_cmd': 'WinResizerStartResize'})
  call dein#add('szw/vim-maximizer',            {'lazy': 1, 'on_cmd': 'MaximizerToggle'})
  call dein#add('terryma/vim-expand-region',    {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-ref',               {'lazy': 1, 'on_cmd': 'Ref'})
  call dein#add('tweekmonster/startuptime.vim', {'lazy': 1, 'on_cmd': 'StartupTime'})
  call dein#add('tyru/capture.vim',             {'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('wesQ3/vim-windowswap',         {'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  " }}}3

  " Library {{{3
  call dein#add('Shougo/vimproc.vim', {'build': 'make'})
  call dein#add('vim-scripts/L9')
  call dein#add('vim-scripts/cecutil')
  " }}}3

  "  After Load {{{3
  call dein#add('ryanoasis/vim-devicons')
  " }}}3

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
" }}}2

" Install Plugin {{{2
if dein#check_install() && (confirm('Would you like to download some plugins ?', "&Yes\n&No", 1) == 1)
  call dein#install()
endif
" }}}2

" My Plugin {{{2
if has('vim_starting')
  set runtimepath+=~/.vim/plugins/lightline-iceberg-yano
endif
" }}}2

" }}}1

" Settings {{{1

" Encoding {{{2
set encoding=utf-8
set fileencodings=utf-8,sjis,cp932,euc-jp
set fileformats=unix,mac,dos
" }}}2

" Appearance {{{2
set cmdheight=2
set nocursorline
set diffopt=filler,icase,vertical
set display=lastline
set helplang=ja
set laststatus=2
set listchars=tab:>\ ,trail:\ ,extends:<,precedes:<
set matchtime=1
set previewheight=18
set pumheight=15
set showmatch
set showtabline=2
" }}}2

" Folding {{{2
set foldcolumn=1
set foldenable
set foldmethod=manual
" }}}2

" Terminal {{{2
if has('nvim')
  tnoremap <silent> <ESC> <C-\><C-n>
endif
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
let mapleader = " "

"" Setting for Neovim
if has('nvim')
  let g:python_host_prog = expand('~/.pyenv/shims/python2')
  let g:python3_host_prog = expand('~/.pyenv/shims/python3')

  nmap <BS> <C-W>h
endif

"" Window
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-l> :wincmd l<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> = <C-w>=

"" Insert Mode
inoremap <C-h> <BS>
inoremap <C-d> <Del>

"" Select buffer
nnoremap B :<C-u>ls<CR>:buffer<Space>

"" Ignore registers
nnoremap x "_x

"" Yank & Paste
nnoremap <silent> <Leader>pp :<C-u>set paste!<CR>

" Repeat the previous macro.
nnoremap Q @@

"" Move CommandLine
noremap! <C-a> <Home>
noremap! <C-b> <Left>
noremap! <C-d> <Del>
noremap! <C-e> <End>
noremap! <C-f> <Right>
noremap! <M-f> <S-Right>
noremap! <M-b> <S-Left>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" tab
nnoremap <Leader>tc :tablast <Bar> tabnew<CR>
nnoremap <Leader>td :tabclose<CR>

"" Save & Quit
nnoremap <silent> <Leader>w :<C-u>w<CR>

" }}}2

" Indent {{{2
set autoindent
set backspace=2
set breakindent
set expandtab
set shiftwidth=4
set smartindent
set tabstop=4
" }}}2

" Term {{{2
if $TERM == 'screen'
  set t_Co=256
endif
" }}}2

" Misc {{{2
set completeopt=longest,menuone,preview
set noswapfile
set history=10000
set undodir=~/.vim_undo
set undofile
set viewoptions=cursor,folds
set hlsearch
set ignorecase
set smartcase
set autoread
set belloff=all
set clipboard+=unnamed
set completeopt=longest,menuone,preview
set ignorecase
set langnoremap
set lazyredraw
set ttyfast
set matchpairs+=<:>
set regexpengine=2
set shell=/bin/bash
set suffixesadd=.js,.rb,.ts,.json,.md
set timeoutlen=750
set ttimeoutlen=10
set virtualedit=all
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
set synmaxcol=300

" Turn off default plugins.
let g:loaded_2html_plugin  = 1
let g:loaded_gzip          = 1
let g:loaded_rrhelper      = 1
let g:loaded_tar           = 1
let g:loaded_tarPlugin     = 1
let g:loaded_vimballPlugin = 1
let g:loaded_zip           = 1
let g:loaded_zipPlugin     = 1
let g:loaded_matchparen    = 1
" }}}2

" }}}1

" Command {{{1

" GoogleTranslation {{{2
function! TransRange() range
  let texts = []
  for n in range(a:firstline, a:lastline)
    let line = getline(n)
    call substitute(line, '\n\+$', ' ', '')
    call add(texts, line)
  endfor
  15new | put!=translategoogle#command(join(texts))
endfunction

command! -range Trans <line1>,<line2>call TransRange()
" }}}2

" ToggleHiglight {{{2
noremap <silent> <Leader>h :<C-u>call <SID>ToggleHiglight()<CR>
function! s:ToggleHiglight()
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
  endif
endfunction
" }}}2

" TrimEndLines {{{2
function! s:TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
" }}}2

" MoveToNewTab {{{2
nnoremap <Leader>tm :<C-u>tablast <Bar> call <SID>MoveToNewTab()<CR>
function! s:MoveToNewTab()
  tab split
  tabprevious

  if winnr('$') > 1
    close
  elseif bufnr('$') > 1
    buffer #
  endif

  tabnext
endfunction
" }}}2

" AutoCursorline {{{2
let s:cursorline_lock = 0
function! s:AutoCursorline(event)
  if a:event ==# 'WinEnter'
    setlocal cursorline
    let s:cursorline_lock = 2
  elseif a:event ==# 'WinLeave'
    setlocal nocursorline
  elseif a:event ==# 'CursorMoved'
    if s:cursorline_lock
      if 1 < s:cursorline_lock
        let s:cursorline_lock = 1
      else
        setlocal nocursorline
        let s:cursorline_lock = 0
      endif
    endif
  elseif a:event ==# 'CursorHold'
    setlocal cursorline
    let s:cursorline_lock = 1
  endif
endfunction
" }}}2

" }}}1

" autocmd {{{1
augroup MyVimrc
  autocmd!

  " Auto Load
  autocmd InsertEnter,WinEnter * checktime

  " Line Number
  autocmd BufNewFile,BufRead,FileType * set number
  if has('nvim')
    autocmd TermOpen * set nonumber | set norelativenumber
  endif

  " Intent
  autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
  autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
  autocmd FileType markdown   setlocal sw=4 sts=4 ts=4 et
  autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType sh         setlocal sw=4 sts=4 ts=4 et
  autocmd FileType sql        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et

  " Filetype
  autocmd BufNewFile,BufRead         *.erb set filetype=eruby.html
  autocmd BufNewFile,BufRead          *.js set filetype=javascript
  autocmd BufNewFile,BufRead          *.md set filetype=markdown
  autocmd BufNewFile,BufRead         *.vue set filetype=vue.html.javascript.css
  autocmd BufNewFile,BufRead        *.cson set filetype=coffee
  autocmd BufNewFile,BufRead  *.{yml,yaml} set filetype=yaml
  autocmd BufNewFile,BufRead      .babelrc set filetype=json
  autocmd BufNewFile,BufRead     .eslintrc set filetype=json
  autocmd BufNewFile,BufRead  .stylelintrc set filetype=yaml
  autocmd BufNewFile,BufRead .tern-project set filetype=json
  autocmd BufNewFile,BufRead        .pryrc set filetype=ruby
  autocmd BufNewFile,BufRead       Gemfile set filetype=ruby
  autocmd BufNewFile,BufRead   Vagrantfile set filetype=ruby
  autocmd BufNewFile,BufRead    Schemafile set filetype=ruby

  " Completion
  autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType ruby          setlocal omnifunc=
  autocmd FileType eruby.html    setlocal omnifunc=
  autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType javascript    setlocal dict=~/dotfiles/.vim/dict/javascript.dict
  autocmd FileType ruby,eruby    setlocal dict=~/dotfiles/.vim/dict/rails.dict

  " Disable Paste Mode
  autocmd InsertLeave * setlocal nopaste

  " Remove Tailing Space
  autocmd BufWritePre * call s:TrimEndLines()
  " Auto CursorLine
  autocmd CursorMoved,CursorMovedI * call s:AutoCursorline('CursorMoved')
  autocmd CursorHold,CursorHoldI * call s:AutoCursorline('CursorHold')
  autocmd WinEnter * call s:AutoCursorline('WinEnter')
  autocmd WinLeave * call s:AutoCursorline('WinLeave')
augroup END
" }}}1

" Plugin Settings {{{1

" Language {{{2

" ALE {{{3
let g:ale_linters = {
      \ 'html': [],
      \ 'css': ['stylelint'],
      \ 'javascript': ['eslint', 'flow'],
      \ 'vue': ['eslint', 'flow'],
      \ 'ruby': ['rubocop'],
      \ 'eruby': []
      \ }
let g:ale_sign_column_always = 1
let g:ale_sign_error = "\uf421"
let g:ale_sign_warning = "\uf420"
let g:ale_statusline_format = ["\uf421 %d", "\uf420 %d", "\uf4a1"]
let g:ale_linter_aliases = {'vue': 'css'}
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_emit_conflict_warnings = 0

highlight ALEWarningSign ctermfg=229
highlight ALEErrorSign ctermfg=203
highlight ALEWarning ctermfg=0 ctermbg=229
highlight ALEError ctermfg=0 ctermbg=203
" }}}3

" autoformat {{{3
nnoremap <Leader>a :<C-u>Autoformat<CR>

" ruby
let g:formatters_ruby = ['rubocop']

" erb
let g:formatdef_htmlbeautifier = '"SRC=/tmp/erb-temp-${RANDOM}.erb; cat > $SRC; htmlbeautifier $SRC; cat $SRC; rm -f $SRC"'
let g:formatters_eruby         = ['htmlbeautifier']
let g:formatters_eruby_html    = ['htmlbeautifier']

" eslint
let g:formatdef_prettier = '"cat | prettier --stdin"'
let g:formatters_javascript = ['prettier']

" stylefmt
let g:formatdef_stylefmt = '"cat | stylefmt -f -"'
let g:formatters_css = ['stylefmt']

" vue.js
let g:formatters_vue_html_javascript_css = []
let g:formatdef_vuefmt = '"cat > vuefmt-temp.vue; ruby -e ''File.read(\"vuefmt-temp.vue\").gsub(%r{<template(.*?)>(.*)</template>}m) { |_| File.write(\"vuefmt-temp-template.xml\", \"<template#{$1}>#{$2}</template>\"); `touch \"vuefmt-temp-template.xml\"` unless File.exist?(\"vuefmt-temp-template.xml\")}''; cat vuefmt-temp-template.xml | htmlbeautifier; echo \"\"; touch vuefmt-temp-js.js; ruby -e ''File.read(\"vuefmt-temp.vue\").gsub(%r{<script>\n(.*)</script>}m) { |_| File.write(\"vuefmt-temp-js.js\", \"#{$1}\"); }''; eslint --fix vuefmt-temp-js.js >/dev/null 2>&1; echo \"<script>\"; cat vuefmt-temp-js.js; echo \"</script>\"; echo \"\"; ruby -e ''style = File.read(\"vuefmt-temp.vue\").gsub(%r{<style(.*?)>(.*?)</style>}m).each { |tag| css = $2; puts \"<style#{$1}>\"; print `echo \"#{css}\" | stylefmt --stdin-filename tmp`.chomp; puts \"</style>\"; puts\"\" }''; rm -f vuefmt-temp-js.js; rm -f vuefmt-temp-template.xml; rm -f vuefmt-temp.vue;"'
let g:formatters_vue = ['vuefmt']
" }}}3

" auto-ctags {{{3
let g:auto_ctags = 1
" }}}3

" auto-gtags {{{3
let g:auto_update_gtags = 1
" }}}3

" echodoc {{{3
let g:echodoc_enable_at_startup = 1
" }}}3

" emmet {{{3
let g:user_emmet_leader_key=','
let g:user_emmet_mode='in'
" }}}3

" go {{{3
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
" }}}3

" html5 {{{3
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1
" }}}3

" javascript {{{3
let g:jsx_ext_required = 0
let g:javascript_plugin_flow = 1
" }}}3

" json {{{3
let g:vim_json_syntax_conceal = 0
" }}}3

" jsx-pretty {{{3
let g:vim_jsx_pretty_colorful_config = 1
" }}}3

" ruby {{{3
let g:rubycomplete_rails                = 1
let g:rubycomplete_buffer_loading       = 1
let g:rubycomplete_classes_in_global    = 1
let g:rubycomplete_include_object       = 1
let g:rubycomplete_include_object_space = 1
" }}}3

" }}}2

" Completion & Fuzzy Match & vimfiler {{{2

" Denite & Unite {{{3
if dein#tap("denite.nvim")
  " Denite

  " highlight
  call denite#custom#option('default', 'prompt', '>')
  call denite#custom#option('default', 'mode', 'normal')
  call denite#custom#option('default', 'highlight_matched', 'Search')
  call denite#custom#option('default', 'highlight_mode_normal', 'CursorLineNr')
  call denite#custom#option('default', 'highlight_mode_insert', 'CursorLineNr')

  " keymap
  call denite#custom#map('normal', '<Esc>', '<denite:quit>', 'noremap')
  call denite#custom#map('normal', '<C-g>', '<denite:quit>', 'noremap')
  call denite#custom#map('normal', '<C-n>', '<denite:move_to_next_line>', 'noremap')
  call denite#custom#map('normal', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map('normal', '<C-h>', '<denite:wincmd:h>', 'noremap')
  call denite#custom#map('normal', '<C-j>', '<denite:wincmd:j>', 'noremap')
  call denite#custom#map('normal', '<C-k>', '<denite:wincmd:k>', 'noremap')
  call denite#custom#map('normal', '<C-l>', '<denite:wincmd:l>', 'noremap')
  call denite#custom#map('insert', '<Esc>', '<denite:enter_mode:normal>', 'noremap')
  call denite#custom#map('insert', '<C-g>', '<denite:enter_mode:normal>', 'noremap')
  call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
  call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

  " option
  call denite#custom#source('buffer,file_mru,file_old,file_rec,grep,line', 'matchers', ['matcher_cpsm', 'matcher_fuzzy'])
  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
        \[
        \ '*~', '*.o', '*.exe', '*.bak',
        \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
        \ '.hg/', '.git/', '.bzr/', '.svn/',
        \ 'node_modules', 'vendor/bundle',
        \ 'tags', 'tags-*', '.png', 'jp[e]g', '.gif',
        \ '*.min.*'
        \])
  call denite#custom#var('file_rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep',     'command', ['ag'])
  call denite#custom#var('grep',     'recursive_opts', [])
  call denite#custom#var('grep',     'pattern_opt', [])
  call denite#custom#var('grep',     'default_opts', ['--follow', '--no-group', '--no-color'])

  " file & buffer
  " nnoremap <silent> <Leader>p  :<C-u>Denite file_rec -direction=botright -mode=insert<CR>
  nnoremap <silent> <Leader>m :<C-u>Denite file_mru -direction=botright -mode=insert<CR>
  nnoremap <silent> <Leader>f :<C-u>Denite buffer file_rec -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Denite buffer -direction=topleft -mode=insert<CR>

  " grep
  " nnoremap <silent> <Leader>/ :<C-u>Denite line -auto-preview<CR>
  " nnoremap <silent> <Leader>* :<C-u>DeniteCursorWord line -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep -auto-preview<CR>

  " tag
  " nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord tag -auto-preview<CR>

  " outline
  nnoremap <silent> <Leader>o :<C-u>Denite outline<CR>

  " ctags & gtags
  nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord gtags_context -direction=botright<CR>

  " yank
  " nnoremap <silent> <Leader>p :<C-u>Denite neoyank -direction=topleft<CR>

  " quickfix
  " nnoremap <silent> <Leader>l :Denite location_list -no-quit -auto-resize<CR>
  " nnoremap <silent> <Leader>q :Denite quickfix -no-quit -auto-resize<CR>

  " session
  " nnoremap <silent> <Leader>sl :<C-u>Denite session<CR>

  " resume
  nnoremap <silent> <Leader>dre :<C-u>Denite -resume<CR>
endif

if dein#tap("unite.vim")
  " Unite

  "" keymap
  function! s:unite_settings()
    nnoremap <silent> <buffer> <C-n>      j
    nnoremap <silent> <buffer> <C-p>      k
    nnoremap <silent> <buffer> <C-j>      <C-w>j
    nnoremap <silent> <buffer> <C-k>      <C-w>k
    nnoremap <silent> <buffer> <ESC><ESC> q
    inoremap <silent> <buffer> <ESC><ESC> <ESC>q
    imap     <silent> <buffer> <C-w> <Plug>(unite_delete_backward_path)
  endfunction

  augroup unite
    autocmd!
    autocmd FileType unite call s:unite_settings()
  augroup END

  "" file & buffer
  call unite#filters#matcher_default#use(['matcher_fuzzy'])
  call unite#custom#source('buffer,file, file_rec/async', 'sorters', 'sorter_rank')

  let g:unite_source_rec_max_cache_files = 10000
  let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '-p', '~/.agignore', '-g', '']
  " nnoremap <silent> <Leader>p :<C-u>Unite file_rec/async:! -start-insert<CR>
  " nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:! -start-insert<CR>
  nnoremap <silent> <Leader>b :<C-u>Unite buffer -start-insert<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Unite jump change -auto-preview -direction=botright<CR>

  " ctags & gtags
  " nnoremap <silent> <Leader><C-]> :<C-u>UniteWithCursorWord gtags/context tag -direction=botright<CR>

  "" outline
  " nnoremap <silent> <Leader>o :<C-u>Unite outline -auto-preview -direction=botright<CR>

  "" grep
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''

  call unite#custom_source('line', 'sorters', 'sorter_reverse')
  nnoremap <silent> <Leader>/          :<C-u>Unite line -direction=botright -buffer-name=search-buffer -start-insert -no-quit<CR>
  nnoremap <silent> <Leader>//         :<C-u>Unite line -direction=botright -buffer-name=search-buffer -start-insert -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader>*          :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader>**         :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>/  :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -start-insert -no-quit<CR>
  nnoremap <silent> <Leader><Leader>// :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -start-insert -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>*  :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader><Leader>** :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>

  " yank & buffer
  let g:unite_source_history_yank_enable = 1
  nnoremap <silent> <Leader>p :<C-u>Unite yankround<CR>

  " quickfix
  nnoremap <silent> <Leader>q :<C-u>Unite quickfix -direction=botright -no-quit<CR>
  nnoremap <silent> <Leader>l :<C-u>Unite location_list -direction=botright -no-quit<CR>

  " session
  nnoremap <Leader>ss :<C-u>UniteSessionSave<CR>
  nnoremap <Leader>sl :<C-u>UniteSessionLoad<CR>

  " snippets
  nnoremap <silent> <Leader>sn :<C-u>Unite neosnippet -direction=botright -start-insert<CR>

  " tab
  nnoremap <silent> <Leader>ut :<C-u>Unite tab<CR>

  " resume
  nnoremap <silent> <Leader>ure :<C-u>Unite -resume<CR>

  " Dein
  nnoremap <silent> <Leader>dein :<C-u>Unite dein -start-insert<CR>
endif
" }}}3

" deoplete.nvim && neosnippet.vim {{{3
if has('nvim')
  if dein#tap("deoplete.nvim")
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#enable_camel_case = 1
    let g:deoplete#auto_complete_delay = 0
    let g:deoplete#auto_complete_start_length = 1
    let g:deoplete#file#enable_buffer_path = 1
    let g:deoplete#tag#cache_limit_size = 5000000

    let g:deoplete#sources = {}
    let g:deoplete#sources._          = ['buffer', 'omni', 'look']
    let g:deoplete#sources.javascript = ['ternjs', 'flow', 'gtags', 'tag', 'omni', 'buffer', 'neosnippet', 'dictionary', 'look']
    let g:deoplete#sources.ruby       = ['gtags', 'tag', 'buffer', 'neosnippet', 'dictionary', 'look']
    let g:deoplete#sources.python     = ['jedi', 'buffer', 'gtags', 'tag', 'omni', 'neosnippet', 'look']
    let g:deoplete#sources.vim        = ['vim', 'buffer', 'gtags', 'tag', 'look']

    let g:deoplete#omni#input_patterns = {}
    let g:deoplete#omni#input_patterns._ = ''
    let g:deoplete#omni#input_patterns.ruby = ''
    let g:deoplete#omni#input_patterns.javascript = ''
    let g:deoplete#omni#input_patterns.python = ''
    let g:deoplete#omni#input_patterns.css  = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
    let g:deoplete#omni#input_patterns.scss = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'

    let g:deoplete#omni#functions = {}
    let g:deoplete#omni#functions.javascript = ['jspc#omni', 'javascriptcomplete#CompleteJS']
    let g:deoplete#omni#functions.ruby = ['rubycomplete#Complete']
    let g:deoplete#omni#functions.python = ['pythoncomplete#Complete']
    let g:deoplete#omni#functions.css = ['csscomplete#CompleteCSS']

    " tern
    let g:tern_request_timeout = 1
    let g:tern_show_signature_in_pum = 0
    let g:tern#filetypes = [
          \ 'javascript',
          \ 'vue'
          \ ]

    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

    function! s:my_cr_function()
      if !pumvisible()
        return "\<CR>"
      endif

      if neosnippet#jumpable()
        return neosnippet#mappings#expand_or_jump_impl()
      elseif neosnippet#expandable()
        return neosnippet#mappings#expand_impl()
      else
        return "\<C-y>" . deoplete#smart_close_popup()
      endif
    endfunction

    inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()

    function! Hook_on_post_source_deoplete() abort
      call deoplete#custom#source('neosnippet', 'rank', 1100)
      call deoplete#custom#source('ternjs',     'rank', 1000)
      call deoplete#custom#source('flow',       'rank', 900)
      call deoplete#custom#source('jedi',       'rank', 800)
      call deoplete#custom#source('vim',        'rank', 700)
      call deoplete#custom#source('buffer',     'rank', 600)
      call deoplete#custom#source('gtags',      'rank', 500)
      call deoplete#custom#source('tag',        'rank', 400)
      call deoplete#custom#source('omni',       'rank', 300)
      call deoplete#custom#source('dictionary', 'rank', 200)
      call deoplete#custom#source('look',       'rank', 100)

      call deoplete#custom#source('buffer',     'mark', '[buffer]')
      call deoplete#custom#source('tag',        'mark', '[tag]')
      call deoplete#custom#source('dictionary', 'mark', '[dict]')
      call deoplete#custom#source('omni',       'mark', '[omni]')
    endfunction
  endif
end

let g:neosnippet#disable_runtime_snippets = { '_' : 1 }
let g:neosnippet#enable_snipmate_compatibility = 0
let g:neosnippet#snippets_directory = '~/.vim/bundle/repos/github.com/honza/vim-snippets/snippets/'
imap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<TAB>"

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
" }}}3

" neomru {{{3
let g:neomru#file_mru_ignore_pattern = '^gina:\/\/.*$'
" }}}3

" vimfiler {{{3
if dein#tap("vimfiler")
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_tree_opened_icon = '▾'
  let g:vimfiler_tree_closed_icon = '▸'
  let g:vimfiler_marked_file_icon = '✓'
  let g:vimfiler_execute_file_list = {'jpg': 'open', 'jpeg': 'open', 'gif': 'open', 'png': 'open'}
  call vimfiler#custom#profile('default', 'context', {
        \ 'explorer' : 1,
        \ 'winwidth' : 35,
        \ 'split' : 1,
        \ 'simple' : 1,
        \ })
  let g:vimfiler_enable_auto_cd = 1
  let g:vimfiler_ignore_pattern = '^\%(.git\|.DS_Store\)$'
  let g:vimfiler_trashbox_directory = '~/.Trash'
  nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer<CR>
  nnoremap <silent> <Leader>% :<C-u>VimFilerExplorer -find<CR>

  function! s:vimfiler_settings()
    nmap <buffer> R <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <C-l> <C-w>l
    nmap <buffer> <C-j> <C-w>j
  endfunction

  augroup vimfiler
    autocmd!
    autocmd FileType vimfiler call s:vimfiler_settings()
  augroup END
endif
" }}}3

" }}}2

" Git {{{2

" agit {{{3
let g:agit_preset_views = {
      \ 'default': [
      \   {'name': 'log'},
      \   {'name': 'stat',
      \    'layout': 'botright vnew'},
      \   {'name': 'diff',
      \    'layout': 'belowright {winheight(".") * 3 / 4}new'}
      \ ],
      \ 'file': [
      \   {'name': 'filelog'},
      \   {'name': 'stat',
      \    'layout': 'botright vnew'},
      \   {'name': 'diff',
      \    'layout': 'belowright {winheight(".") * 3 / 4}new'}
      \ ]}
" }}}3

" committia {{{3
let g:committia_open_only_vim_starting = 0
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info)
  setlocal spell
  imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
  imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
endfunction
" }}}3

" git-gutter {{{3
if dein#tap("vim-gitgutter")
  let g:gitgutter_map_keys = 0
  nmap <silent> gp <Plug>GitGutterPrevHunk
  nmap <silent> gn <Plug>GitGutterNextHunk
  nmap <silent> <Leader>hs <Plug>GitGutterStageHunk
  nmap <silent> <Leader>hu <Plug>GitGutterUndoHunk
  nnoremap <silent> <Leader>gg :<C-u>GitGutterToggle<CR>
  nnoremap <silent> <Leader>gh :<C-u>GitGutterLineHighlightsToggle<CR>
endif
" }}}3

" gina {{{3
function! Hook_on_post_source_gina() abort
  let cmd_opt = {'noremap': 1, 'silent': 1}
  call gina#custom#mapping#nmap('branch', 'n', '<Plug>(gina-branch-new)')
endfunction

nnoremap <silent> <Leader>gs  :<C-u>Gina status<CR>
nnoremap <silent> <Leader>gd  :<C-u>Gina diff<CR>
nnoremap <silent> <Leader>gdc :<C-u>Gina diff --cached<CR>
nnoremap <silent> <Leader>gci :<C-u>Gina commit<CR>

function! s:gina_blame_settings()
  nmap <buffer> <C-l> <C-w>l
  nmap <buffer> <C-r> <Plug>(gina-blame-redraw)
endfunction

augroup gina
  autocmd!
  autocmd FileType gina-blame  call s:gina_blame_settings()
  autocmd FileType gina-commit setlocal spell
augroup END
" }}}3

" }}}2

" Edit & Move & Search {{{2

" incsearch & anzu & asterisk {{{3
if dein#tap("incsearch.vim")
  let g:anzu_status_format = "(%i/%l)"

  map  /  <Plug>(incsearch-forward)
  map  ?  <Plug>(incsearch-backward)
  map  g/ <Plug>(incsearch-stay)
  map  n  <Plug>(anzu-n)zzzv
  map  N  <Plug>(anzu-N)zzzv
  nmap *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)
  nmap #  <Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)
  nmap g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)
  nmap g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)
  nmap <silent> <Esc><Esc> <Plug>(anzu-clear-search-status)<Plug>(anzu-clear-sign-matchline):nohlsearch<CR>
endif
" }}}3

" ag {{{3
let g:ag_qhandler = ''
nnoremap <Leader>ag :<C-u>Ag!<space><space><bar><space>Unite quickfix -direction=botright -no-quit<Home><Right><Right><Right><Right>
" }}}3

" clever-f {{{3
let g:clever_f_not_overwrites_standard_mappings = 0

map f <Plug>(clever-f-f)
map F <Plug>(clever-f-F)
map t <Plug>(clever-f-t)
map T <Plug>(clever-f-T)
" }}}3

" easy-align {{{3
vmap <Enter> <Plug>(EasyAlign)
" }}}3

" easymotion {{{3
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'HJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_use_upper = 1
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1
highlight link EasyMotionIncSearch Search
highlight link EasyMotionMoveHL Search

map [EasyMotion] <Nop>
map ; [EasyMotion]

nmap [EasyMotion]f <Plug>(easymotion-overwin-f2)
vmap [EasyMotion]f <Plug>(easymotion-bd-f2)
map  [EasyMotion]j <Plug>(easymotion-j)
map  [EasyMotion]k <Plug>(easymotion-k)
map  [EasyMotion]l <Plug>(easymotion-bd-jk)
nmap [EasyMotion]l <Plug>(easymotion-overwin-line)
map  [EasyMotion]w <Plug>(easymotion-bd-w)
nmap [EasyMotion]w <Plug>(easymotion-overwin-w)

" Move line
omap f <Plug>(easymotion-fl)
omap F <Plug>(easymotion-Fl)
omap t <Plug>(easymotion-tl)
omap T <Plug>(easymotion-Tl)
" }}}3

" edgemotion {{{3
map <M-j> <Plug>(edgemotion-j)
map <M-k> <Plug>(edgemotion-k)
" }}}3

" jplus {{{3
if dein#tap("vim-jplus")
  nmap J         <Plug>(jplus)
  vmap J         <Plug>(jplus)
  nmap <Leader>J <Plug>(jplus-input)
  vmap <Leader>J <Plug>(jplus-input)
endif
" }}}3

" lexima {{{3
if dein#tap("lexima.vim")
  function! Hook_on_post_source_lexima() abort
    let rules = []

    let rules += [
          \ {'char': '(',     'at': '(\%#)',   'input': '<Del>'},
          \ {'char': '{',     'at': '{\%#}',   'input': '<Del>'},
          \ {'char': '[',     'at': '\[\%#\]', 'input': '<Del>'},
          \ {'char': '{',     'at': '{\%#$',   'input': '{{<CR>}}}', 'filetype': 'vim'},
          \ {'char': '<C-h>', 'at': '(\%#)',   'input': '<BS><Del>'},
          \ {'char': '<C-h>', 'at': '{\%#}',   'input': '<BS><Del>'},
          \ {'char': '<C-h>', 'at': '\[\%#\]', 'input': '<BS><Del>'},
          \ {'char': '<C-h>', 'at': "'\\%#'",  'input': '<Del>'},
          \ {'char': '<C-h>', 'at': '"\%#"',   'input': '<Del>'},
          \ {'char': "'",     'at': "'\\%#'",  'input': '<Del>'},
          \ {'char': '"',     'at': '"\%#"',   'input': '<Del>'},
          \ {'char': "'",     'at': "'\\%#",   'input': ''},
          \ {'char': '"',     'at': '"\%#',    'input': ''},
          \ {'char': '(',     'at': '(\%#',    'input': ''},
          \ {'char': '{',     'at': '{\%#',    'input': ''},
          \ {'char': '[',     'at': '[\%#',    'input': ''},
          \ ]

    for rule in rules
      call lexima#add_rule(rule)
    endfor
  endfunction
endif
" }}}3

" operator-convert-case.vim {{{3
nmap <Leader>cl :<C-u>ConvertCaseLoop<CR>b
" }}}3

" operator-replace {{{3
map _ <Plug>(operator-replace)
" }}}3

" over {{{3
nnoremap <silent> <Leader>R :<C-u>OverCommandLine<CR>%s/<C-r><C-w>//g<Left><Left>
nnoremap <silent> <Leader>r :<C-u>OverCommandLine<CR>%s//g<Left><Left>
vnoremap <silent> <Leader>r y:<C-u>OverCommandLine<CR>%s/<C-r>=substitute(@0, '/', '\\/', 'g')<CR>//g<Left><Left>
" }}}3

" tcomment {{{3
noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" yankround & Unite {{{3
if dein#tap("yankround.vim")
  let g:neoyank#limit = 10000
  nmap p <Plug>(yankround-p)
  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : ':<C-u>Unite file_rec/async:! -start-insert<CR>'
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : ''
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = ['tag', 'help', 'vimfiler', 'unite', 'denite']
" }}}3

" devicons {{{3
let g:webdevicons_enable = 1
let g:webdevicons_enable_unite = 1
let g:webdevicons_enable_vimfiler = 1
let g:WebDevIconsUnicodeDecorateFileNodes = 1
" }}}3

" fastfold {{{3
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
" }}}3

" foldCC {{{3
if dein#tap("foldCC.vim")
  set foldtext=FoldCCtext()
endif
" }}}3

" hl_matchit {{{3
let g:hl_matchit_enable_on_vim_startup = 1
" }}}3

" indent-line {{{3
let g:indentLine_enabled = 0
let g:indentLine_fileTypeExclude = ['json']
nnoremap <silent> <Leader>i :<C-u>:IndentLinesToggle<CR>
" }}}3

" lightline {{{3
if dein#tap("lightline.vim")
  let g:lightline = {
        \ 'colorscheme': 'iceberg_tigberd',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'denite', 'paste' ], [ 'branch' ], ['readonly', 'filepath', 'filename', 'anzu' ] ],
        \   'right': [
        \     [ 'lineinfo', 'percent' ],
        \     [ 'fileformat', 'fileencoding', 'filetype' ],
        \     [ 'ale_error', 'ale_warning', 'ale_ok', 'ale_not_loaded' ]
        \   ]
        \ },
        \ 'inactive': {
        \   'left': [ [], [ 'branch' ], [ 'filepath' ], [ 'filename' ] ],
        \   'right': [
        \     [ 'lineinfo' ],
        \     [ 'fileformat', 'fileencoding', 'filetype' ]
        \   ]
        \ },
        \ 'component': {
        \   'lineinfo': "\ue0a1 %3l[%L]:%-2v",
        \ },
        \ 'component_function': {
        \   'readonly':     'LightlineReadonly',
        \   'branch':       'LightlineBranch',
        \   'filepath':     'LightlineFilepath',
        \   'filename':     'LightlineFilename',
        \   'filetype':     'LightlineFiletype',
        \   'fileformat':   'LightlineFileformat',
        \   'fileencoding': 'LightlineFileencoding',
        \   'mode':         'LightlineMode',
        \   'anzu':         'anzu#search_status',
        \   'denite':       'LightlineDenite',
        \ },
        \ 'component_expand': {
        \   'ale_error':      'LightlineAleError',
        \   'ale_warning':    'LightlineAleWarning',
        \   'ale_ok':         'LightlineAleOk',
        \   'ale_not_loaded': 'LightlineAleNotLoaded',
        \ },
        \ 'component_type': {
        \   'ale_error':      'error',
        \   'ale_warning':    'warning',
        \   'ale_ok':         'ok',
        \   'ale_not_loaded': 'ok',
        \ },
        \ 'component_function_visible_condition': {
        \   'modified': '&modified||!&modifiable',
        \   'readonly': '&readonly',
        \   'paste': '&paste',
        \ },
        \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2 " },
        \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3 " },
        \ 'enable': {
        \ 'statusline': 1,
        \ 'tabline': 1
        \ }
        \ }

  function! LightlineReadonly()
    return &readonly ? "\ue0a2" : ''
  endfunction

  function! LightlineBranch()
    let branch = systemlist("git rev-parse --abbrev-ref HEAD")[0]
    return branch !=# "\ue0a0" ? "\ue0a0 " . branch : ''
    return ''
  endfunction

  function! LightlineFilepath()
    if &filetype ==# 'vimfilter' || &filetype ==# 'unite' || &buftype ==# 'terminal' || winwidth(0) < 70
      let l:path_string = ''
    else
      let l:path_string = substitute(expand('%:h'), $HOME, '~', '')
    endif

    let l:dirs = split(l:path_string, '/')
    if len(l:dirs) ==# 0
      return ''
    endif

    let l:last_dir = remove(l:dirs, -1)
    call map(l:dirs, 'v:val[0]')

    if len(l:dirs) ==# 0
      return l:last_dir
    else
      return join(l:dirs, '/') . '/' . l:last_dir
    endif
  endfunction

  function! LightlineModified()
    if &filetype =~# 'help\|vimfiler'
      return ''
    elseif &modified
      return " \uf040"
    else
      return ''
    endif
  endfunction

  function! LightlineFilename()
    if &filetype ==# 'vimfiler'
      return vimfiler#get_status_string()
    elseif &filetype ==# 'unite'
      return unite#get_status_string()
    elseif &filetype ==# 'denite'
      return denite#get_status_sources() . denite#get_status_path() . denite#get_status_linenr()
    elseif &filetype ==# 'tagbar'
      return g:lightline.fname
    elseif '' !=# expand('%:t')
      return expand('%:t') . LightlineModified()
    else
      return '[No Name]'
    endif
  endfunction

  function! LightlineFileformat()
    if winwidth(0) < 120
      return ''
    else
      return &fileformat . ' ' . WebDevIconsGetFileFormatSymbol()
    endif
  endfunction

  function! LightlineFiletype()
    if strlen(&filetype)
      return &filetype . ' ' . WebDevIconsGetFileTypeSymbol()
    else
      return 'no ft'
    endif
  endfunction

  function! LightlineFileencoding()
    if winwidth(0) < 120
      return ''
    endif
    return (strlen(&fileencoding) ? &fileencoding : &encoding)
  endfunction

  function! LightlineMode()
    let l:fname = expand('%:t')
    if l:fname =~# 'unite'
      return 'Unite'
    elseif l:fname =~# 'vimfiler'
      return 'Vimfiler'
    else
      return lightline#mode()
    endif
  endfunction

  function! Lightline_denite() abort
    return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  endfunction

  function! LightlineAleError() abort
    return s:ale_string(0)
  endfunction

  function! LightlineAleWarning() abort
    return s:ale_string(1)
  endfunction

  function! LightlineAleOk() abort
    return s:ale_string(2)
  endfunction

  function! LightlineAleNotLoaded() abort
    if !exists('g:ale_buffer_info')
      return "\uf204"
    else
      return ''
    endif
  endfunction

  function! s:ale_string(mode)
    if !exists('g:ale_buffer_info')
      return ''
    endif

    let l:buffer = bufnr('%')
    let l:counts = ale#statusline#Count(l:buffer)
    let [l:error_format, l:warning_format, l:no_errors] = g:ale_statusline_format

    if a:mode == 0 " Error
      let l:errors = l:counts.error + l:counts.style_error
      return l:errors ? printf(l:error_format, l:errors) : ''
    elseif a:mode == 1 " Warning
      let l:warnings = l:counts.warning + l:counts.style_warning
      return l:warnings ? printf(l:warning_format, l:warnings) : ''
    elseif a:mode == 2
      let l:errors = l:counts.error + l:counts.style_error
      let l:warnings = l:counts.warning + l:counts.style_warning
      return l:errors == 0 && l:warnings == 0 ? l:no_errors : ''
    endif
  endfunction
endif

augroup lightline
  autocmd!
  autocmd FileType unite,denite,qf,vimfiler let b:cursorword=0
  autocmd User ALELint call lightline#update()
augroup END
" }}}3

" MatchTagAlways {{{3
let g:mta_filetypes = {
      \ 'html' : 1,
      \ 'xhtml' : 1,
      \ 'xml' : 1,
      \ 'erb' : 1
      \}
" }}}3

" operator-flashy {{{3
if dein#tap("vim-operator-flashy")
  map y <Plug>(operator-flashy)
  nmap Y <Plug>(operator-flashy)$
endif
" }}}3

" parenmatch {{{3
let g:loaded_matchparen = 1
" }}}3

" rainbow {{{3
let g:rainbow_active = 1
let g:rainbow_conf = {
      \   'guifgs' : [ '#666666', '#0087ff', '#ff005f', '#875fd7', '#d78700', '#00af87' ],
      \   'ctermfgs': [ '110', '150', '109', '216', '140', '203' ],
      \   'separately' : {
      \       '*':   {},
      \       'vim': {},
      \       'css': 0,
      \   }
      \ }
" }}}3

" smartnumber {{{3
let g:snumber_enable_startup = 1
nnoremap <silent> <Leader>n :SNumbersToggleRelative<CR>
" }}}3

" zenspace {{{3
let g:zenspace#default_mode = 'on'
" }}}3

" }}}2

" Util {{{2

" aho-bakaup.vim {{{3
let g:bakaup_auto_backup = 1
" }}}3

" bufkill {{{3
augroup bufkill
  autocmd!
  autocmd FileType *    nnoremap <silent> <Leader>d :BD<CR>
  autocmd FileType help nnoremap <silent> <Leader>d :BW<CR>
  autocmd FileType diff nnoremap <silent> <Leader>d :BW<CR>
  autocmd FileType git  nnoremap <silent> <Leader>d :BW<CR>
augroup END
" }}}3

" expand-region {{{3
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
let g:expand_region_text_objects_ruby = {
      \ 'im' :0,
      \ 'am' :0
      \ }
" }}}3

" extracmd {{{3
if dein#tap("vim-extracmd")
  call extracmd#set('w!!',          'w !sudo tee > /dev/null %')
  call extracmd#set('dein',         'Dein')
  call extracmd#set('u[nite]',      'Unite')
  call extracmd#set('d[enite]',     'Denite')
  call extracmd#set('ag',           'Ag!')
  call extracmd#set('gina',         'Gina')
  call extracmd#set('git',          'Gina')
  call extracmd#set('gci',          'Gina commit')
  call extracmd#set('blame',        'Gina blame :%')
  call extracmd#set('agit',         'Agit')
  call extracmd#set('agf',          'AgitFile')
  call extracmd#set('alc',          'Ref webdict alc')
  call extracmd#set('tag',          'TagbarOpen j<CR>')
  call extracmd#set('nr',           'NR<CR>')
  call extracmd#set('sctartch',     'Scratch<CR>')
  call extracmd#set('capture',      'Capture')
  call extracmd#set('editorconfig', 'Dein source editorconfig-vim')
  call extracmd#set('json',         '%!python -m json.tool<CR>')
endif
" }}}3

" maximizer {{{3
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
" }}}3

" neoterm {{{3
let g:neoterm_position = 'vertical'
nnoremap <silent> <Leader>tig :<C-u>T tig<CR>
" }}}3

" ref {{{3
let g:ref_source_webdict_sites = {
      \ 'alc' : {
      \   'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
      \   }
      \ }
function! g:ref_source_webdict_sites.alc.filter(output)
  return join(split(a:output, "\n")[42 :], "\n")
endfunction
" }}}3

" scratch {{{3
let g:scratch_no_mappings = 1
" }}}3

" submode {{{3
let g:submode_keep_leaving_key = 1

"" edit
call submode#enter_with('changebuf', 'n', '', 'g;', 'g;')
call submode#map('changebuf', 'n', '', ';', 'g;')

"" buffer
call submode#enter_with('changebuf', 'n', '', 'gh', ':bp<CR>')
call submode#enter_with('changebuf', 'n', '', 'gl', ':bn<CR>')
call submode#map('changebuf', 'n', '', 'h', ':bp<CR>')
call submode#map('changebuf', 'n', '', 'l', ':bn<CR>')

"" tab
call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
call submode#map('changetab', 'n', '', 't', 'gt')
call submode#map('changetab', 'n', '', 'T', 'gT')
" }}}3

" tagbar {{{3
function! Tagbar_status_func(current, sort, fname, ...) abort
  let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction
let g:tagbar_status_func = 'Tagbar_status_func'
" }}}3

" test {{{3
let test#strategy = 'neoterm'
" }}}3

" undotree {{{3
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>
" }}}3

" winresizer {{{3
nnoremap <silent> <C-e> :WinResizerStartResize<CR>
" }}}3

" }}}2

" }}}1

" Load Colorscheme Later {{{1
syntax enable
silent! colorscheme iceberg
highlight Search       ctermfg=none ctermbg=237
highlight LineNr       ctermfg=241
highlight CursorLineNr ctermbg=237 ctermfg=253
highlight CursorLine   ctermbg=235
highlight PmenuSel     cterm=reverse ctermfg=33 ctermbg=222
highlight Visual       ctermfg=159 ctermbg=23
" }}}1

" vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
