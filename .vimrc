" vim-plug {{{

filetype off

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-plug', {'dir': '~/.vim/plugged/vim-plug/autoload'}

" Doc {{{
Plug 'vim-jp/vimdoc-ja'
" }}}

" Language {{{
" Plug 'ensime/ensime-vim', { 'for': ['scala'], 'do': ':UpdateRemotePlugins' }
Plug 'Chiel92/vim-autoformat'
Plug 'Shougo/context_filetype.vim'
Plug 'Valloric/MatchTagAlways', { 'for': ['html', 'xml', 'erb'] }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': ['python'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': ['sass', 'scss'] }
Plug 'cespare/vim-toml', { 'for': ['toml'] }
Plug 'csscomb/vim-csscomb', { 'for': ['css', 'sass', 'scss'] }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'derekwyatt/vim-sbt', { 'for': ['sbt'] }
Plug 'derekwyatt/vim-scala', { 'for': ['scala'] }
Plug 'ecomba/vim-ruby-refactoring', { 'for': ['ruby'] }
Plug 'editorconfig/editorconfig-vim'
Plug 'ekalinin/Dockerfile.vim', { 'for': ['dockerfile'] }
Plug 'elzr/vim-json', { 'for': ['json'] }
Plug 'fatih/vim-go', { 'for': ['go'] }
Plug 'fleischie/vim-styled-components', { 'for': ['javascript'] }
Plug 'gre/play2vim', { 'for': ['scala'] }
Plug 'hail2u/vim-css3-syntax', { 'for': ['css'] }
Plug 'hashivim/vim-terraform', { 'for': ['terraform'] }
Plug 'heavenshell/vim-pydocstring', { 'for': 'python' }
Plug 'jsfaint/gen_tags.vim'
Plug 'kchmck/vim-coffee-script', { 'for': ['coffee'] }
Plug 'kchmck/vim-coffee-script', { 'for': ['coffee'] }
Plug 'keith/rspec.vim', { 'for': ['ruby'] }
Plug 'kewah/vim-stylefmt', { 'for': ['css'] }
Plug 'leafgarland/typescript-vim', { 'for': ['typescript'] }
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim', { 'for': ['html', 'eruby.html', 'javascript', 'vue', 'vue.html.javascript.css'] }
Plug 'maxmellon/vim-jsx-pretty', { 'for': ['javascript'] }
Plug 'mdreves/vim-scaladoc', { 'for': ['scala'] }
Plug 'mkomitee/vim-gf-python', { 'for': 'python' }
Plug 'moll/vim-node', { 'for': ['javascript'] }
Plug 'nsf/gocode', { 'for': ['go'], 'rtp': 'nvim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'othree/csscomplete.vim', { 'for': ['css', 'sass', 'scss'] }
Plug 'othree/es.next.syntax.vim', { 'for': ['javascript'] }
Plug 'othree/html5.vim', { 'for': ['html', 'eruby'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript'] }
Plug 'othree/jspc.vim', { 'for': ['javascript'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript'] }
Plug 'pearofducks/ansible-vim', { 'for': ['ansible'] }
Plug 'posva/vim-vue', { 'for': ['vue'] }
Plug 'raimon49/requirements.txt.vim', { 'for': 'requirements' }
Plug 'rhysd/vim-gfm-syntax', { 'for': ['markdown'] }
Plug 'rhysd/vim-textobj-ruby', { 'for': ['ruby'] }
Plug 'slim-template/vim-slim', { 'for': ['slim'] }
Plug 'tell-k/vim-autopep8', { 'for': ['python'] }
Plug 'thinca/vim-ft-help_fold', { 'for': ['help'] }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
Plug 'tmux-plugins/vim-tmux', { 'for': ['tmux'] }
Plug 'tpope/vim-bundler', { 'for': ['ruby'] }
Plug 'tpope/vim-endwise', { 'for': ['ruby'] }
Plug 'tpope/vim-markdown', { 'for': ['markdown'] }
Plug 'tpope/vim-rails', { 'for': ['ruby', 'eruby'] }
Plug 'vim-jp/syntax-vim-ex', { 'for': ['vim'] }
Plug 'vim-python/python-syntax', { 'for': ['python'] }
Plug 'vim-ruby/vim-ruby', { 'for': ['ruby', 'eruby'] }
Plug 'vim-scripts/python_match.vim', { 'for': ['python'] }
Plug 'vimperator/vimperator.vim', { 'for': ['vimperator'] }
Plug 'vimtaku/hl_matchit.vim', { 'for': ['ruby'] }
Plug 'cohama/agit.vim'
Plug 'idanarye/vim-merginal', { 'branch': 'develop' }
Plug 'w0rp/ale', { 'branch': 'v1.3.x' }
" }}}
" Git {{{
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'cohama/agit.vim'
Plug 'idanarye/vim-merginal', { 'branch': 'develop' }
Plug 'jreybert/vimagit'
Plug 'lambdalisue/gina.vim'
Plug 'lambdalisue/vim-gita'
Plug 'lambdalisue/vim-improve-diff'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Completion & Fuzzy Match & vimfiler {{{
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/echodoc.vim'
  Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript'] }
  Plug 'wokalski/autocomplete-flow', { 'for': ['javascript'] }
  Plug 'zchee/deoplete-go', { 'for': ['go'], 'do': 'make' }
  Plug 'zchee/deoplete-jedi', { 'for': ['python'] }
else
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
endif
Plug 'Shougo/denite.nvim'
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neco-vim'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neoyank.vim'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'hewes/unite-gtags'
Plug 'honza/vim-snippets'
Plug 'kmnk/vim-unite-giti'
Plug 'mattn/googlesuggest-complete-vim'
Plug 'mopp/googlesuggest-source.vim'
Plug 'osyo-manga/unite-highlight'
Plug 'osyo-manga/unite-quickfix'
Plug 'rafi/vim-denite-session'
Plug 'rking/ag.vim'
Plug 'tsukkee/unite-tag'
Plug 'ujihisa/neco-look'
" }}}

" Edit & Move & Search {{{
Plug 'AndrewRadev/switch.vim'
Plug 'LeafCage/yankround.vim'
Plug 'chrisbra/NrrwRgn'
Plug 'dhruvasagar/vim-table-mode'
Plug 'dietsche/vim-lastplace'
Plug 'dyng/ctrlsf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'haya14busa/vim-metarepeat'
Plug 'houtsnip/vim-emacscommandline'
Plug 'itmammoth/doorboy.vim'
Plug 'junegunn/vim-easy-align'
Plug 'kana/vim-operator-replace'
Plug 'osyo-manga/vim-anzu'
Plug 'osyo-manga/vim-jplus'
Plug 'osyo-manga/vim-over'
Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'thinca/vim-qfreplace'
Plug 'thinca/vim-visualstar'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
" }}}

" Appearance {{{
Plug 'LeafCage/foldCC.vim'
Plug 'Yggdroot/indentLine'
Plug 'cocopon/iceberg.vim'
Plug 'gregsexton/MatchTag'
Plug 'haya14busa/vim-operator-flashy'
Plug 'inside/vim-search-pulse'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/thumbnail.vim'
Plug 'itchyny/vim-cursorword'
Plug 'itchyny/vim-highlighturl'
Plug 'itchyny/vim-parenmatch'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ryanoasis/vim-devicons'
Plug 't9md/vim-quickhl'
Plug 'taohex/lightline-buffer'
Plug 'thinca/vim-zenspace'
Plug 'vim-scripts/AnsiEsc.vim'
Plug 'vim-scripts/CursorLineCurrentWindow'
Plug 'vimtaku/hl_matchit.vim'
" }}}

" Util {{{
if has('nvim')
  Plug 'kassio/neoterm'
endif
Plug 'Shougo/junkfile.vim'
Plug 'bagrat/vim-workspace'
Plug 'benizi/vim-automkdir'
Plug 'bogado/file-line'
Plug 'chrisbra/Recover.vim'
Plug 'itchyny/calendar.vim'
Plug 'itchyny/vim-external'
Plug 'itchyny/vim-extracmd'
Plug 'itchyny/vim-qfedit'
Plug 'itchyny/vim-tmpbuffer'
Plug 'itchyny/vim-winfix'
Plug 'jez/vim-superman'
Plug 'kana/vim-niceblock'
Plug 'kana/vim-operator-user'
Plug 'kana/vim-submode'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-user'
Plug 'konfekt/fastfold'
Plug 'mattesgroeger/vim-bookmarks'
Plug 'mattn/webapi-vim'
Plug 'mbbill/undotree'
Plug 'myusuf3/numbers.vim'
Plug 'mhinz/vim-startify'
Plug 'mtth/scratch.vim'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'osyo-manga/vim-textobj-multiblock'
Plug 'rhysd/conflict-marker.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'rhysd/clever-split.vim'
Plug 'roxma/vim-paste-easy'
Plug 'simeji/winresizer'
Plug 'szw/vim-maximizer'
Plug 'terryma/vim-expand-region'
Plug 'thinca/vim-ref'
Plug 'tpope/vim-sleuth'
Plug 'tweekmonster/startuptime.vim'
Plug 'tyru/capture.vim'
Plug 'wellle/targets.vim'
" }}}

" Library {{{
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'nixprime/cpsm', { 'do': 'env PY3=ON ./install.sh'}
Plug 'JazzCore/ctrlp-cmatcher', {'do' : './install.sh'}
Plug 'vim-scripts/L9'
Plug 'vim-scripts/cecutil'
" }}}

" My Plugin {{{
set runtimepath+=~/.vim/plugins/lightline-iceberg-tigberd
" }}}

call plug#end()

filetype plugin indent on

" }}}

" Basic {{{

"" Python3 support
let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = expand('$HOME') . '/.pyenv/shims/python'

"" Ruby support
let g:ruby_host_prog = expand('$HOME') . '/.pyenv/shims/ruby'

"" Leader
let mapleader = " "

"" Set Option
set nobackup
set autoread
set hidden
set formatoptions=lmoq
set vb t_vb=
set browsedir=buffer
set showcmd
set showmode
set backspace=2
set clipboard+=unnamed
set mouse=a
set guioptions+=a
if !has('nvim')
  set ttymouse=xterm2
endif
set laststatus=2
set ruler
set showmatch
set matchtime=1
set number
set virtualedit=block
set lazyredraw
set ttyfast
set wrapscan
set ignorecase
set incsearch
set hlsearch
set undodir=$HOME/.vim/undodir
set undofile
set shell=/bin/bash
set previewheight=18
set tags+=tags
set showtabline=2
set display=lastline
set pumheight=15

set swapfile directory=/var/tmp,/tmp
autocmd SwapExists * let v:swapchoice = 'o'

"" Map
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap B :b<Space>
if has('nvim')
  nmap <BS> <C-W>h
endif
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h
inoremap <C-d> <Del>
imap <C-h> <BS>
nnoremap x "_x
nnoremap ,p "0p<CR>
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz
nnoremap g; g;zz

"" Move CommandLine
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" Completion
set wildmenu
set wildmode=longest,full
set history=1000
set complete+=k
set completeopt=longest,menuone,preview

autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType ruby          setlocal omnifunc=rubycomplete#Complete
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType scala         setlocal omnifunc=EnCompleteFunc

autocmd FileType javascript    setlocal dict=~/dotfiles/.vim/dict/javascript.dict
autocmd FileType ruby,eruby    setlocal dict=~/dotfiles/.vim/dict/rails.dict

noremap <silent><Leader>h :<C-u>call <SID>ToggleHiglight()<CR>
function! s:ToggleHiglight()
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
  endif
endfunction

function TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction

au BufWritePre * call TrimEndLines()

" }}}

" Indent {{{

set autoindent
set expandtab
set smartindent
set cindent

set tabstop=2 shiftwidth=2 softtabstop=0

if has("autocmd")
  filetype plugin on
  filetype indent on

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
endif

" }}}

" Color {{{
if $TERM == 'screen'
  set t_Co=256
endif

set background=dark
set cursorline
silent! colorscheme iceberg
autocmd ColorScheme * hi LineNr ctermfg=241
autocmd ColorScheme * hi CursorLineNr ctermbg=237 ctermfg=253
autocmd ColorScheme * hi CursorLine ctermbg=235
autocmd ColorScheme * hi Search  ctermfg=none ctermbg=237
autocmd ColorScheme * hi PmenuSel cterm=reverse ctermfg=33 ctermbg=222
autocmd VimEnter    * hi Visual ctermfg=159 ctermbg=23

syntax enable

" }}}

" Mode {{{

autocmd BufNewFile,BufRead        *.erb  set filetype=eruby.html
autocmd BufNewFile,BufRead         *.js  set filetype=javascript
autocmd BufNewFile,BufRead         *.md  set filetype=markdown
autocmd BufNewFile,BufRead        *.vue  set filetype=vue.html.javascript.css
autocmd BufNewFile,BufRead        *.ssp  set filetype=html
autocmd BufNewFile,BufRead       *.cson  set filetype=coffee
autocmd BufNewFile,BufRead     .babelrc  set filetype=json
autocmd BufNewFile,BufRead    .eslintrc  set filetype=yaml
autocmd BufNewFile,BufRead .stylelintrc  set filetype=yaml
autocmd BufNewFile,BufRead .tern-project set filetype=json
autocmd BufNewFile,BufRead       .pryrc  set filetype=ruby
autocmd BufNewFile,BufRead      Gemfile  set filetype=ruby
autocmd BufNewFile,BufRead  Vagrantfile  set filetype=ruby
autocmd BufNewFile,BufRead   Schemafile  set filetype=ruby

" }}}

" Plugin Settings {{{

" Language {{{

" ALE {{{
let g:ale_linters = {
      \ 'html': [],
      \ 'css': ['stylelint'],
      \ 'javascript': ['eslint', 'flow'],
      \ 'vue': ['eslint', 'flow'],
      \ 'ruby': ['rubocop'],
      \ 'eruby': [],
      \ 'scala': ['scalac']
      \ }
let g:ale_sign_column_always = 1
let g:ale_sign_error = "\uf421"
let g:ale_sign_warning = "\uf420"
let g:ale_statusline_format = ["\uf421 %d", "\uf420 %d", "\uf4a1"]
let g:ale_linter_aliases = {'vue': 'css'}
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_emit_conflict_warnings = 0

hi ALEWarningSign ctermfg=229
hi ALEErrorSign ctermfg=203
" }}}

" autoformat {{{
" autocmd BufWrite *.rb       Autoformat
" autocmd BufWrite *.js       Autoformat
" autocmd BufWrite *.json     Autoformat
" autocmd BufWrite *.html     Autoformat
" autocmd BufWrite *.html.erb Autoformat
" autocmd BufWrite *.css      Autoformat
" autocmd BufWrite *.sass     Autoformat
" autocmd BufWrite *.scss     Autoformat
" autocmd BufWrite *.vue      Autoformat
" autocmd BufWrite *.scala    Autoformat

" autocmd BufWrite Rakefile Autoformat
" autocmd BufWrite Gemfile  Autoformat
" autocmd BufWrite .vimrc   Autoformat
" autocmd BufWrite .zshrc   Autoformat

nnoremap <Leader>a :<C-u>Autoformat<CR>

" erb
let g:formatdef_htmlbeautifier = '"SRC=/tmp/erb-temp-${RANDOM}.erb; cat > $SRC; htmlbeautifier $SRC; cat $SRC; rm -f $SRC"'
let g:formatters_eruby      = ['htmlbeautifier']
let g:formatters_eruby_html = ['htmlbeautifier']

" eslint
let g:formatdef_prettier_eslint = '"cat | prettier-eslint --stdin"'
let g:formatters_javascript = ['prettier_eslint']

" stylefmt
let g:formatdef_stylefmt = '"cat | stylefmt -f -"'
let g:formatters_css = ['stylefmt']

" vue.js
let g:formatters_vue_html_javascript_css = []
let g:formatdef_vuefmt = '"cat > vuefmt-temp.vue; ruby -e ''File.read(\"vuefmt-temp.vue\").gsub(%r{<template(.*?)>(.*)</template>}m) { |_| File.write(\"vuefmt-temp-template.xml\", \"<template#{$1}>#{$2}</template>\"); `touch \"vuefmt-temp-template.xml\"` unless File.exist?(\"vuefmt-temp-template.xml\")}''; cat vuefmt-temp-template.xml | htmlbeautifier; echo \"\"; touch vuefmt-temp-js.js; ruby -e ''File.read(\"vuefmt-temp.vue\").gsub(%r{<script>\n(.*)</script>}m) { |_| File.write(\"vuefmt-temp-js.js\", \"#{$1}\"); }''; eslint --fix vuefmt-temp-js.js >/dev/null 2>&1; echo \"<script>\"; cat vuefmt-temp-js.js; echo \"</script>\"; echo \"\"; ruby -e ''style = File.read(\"vuefmt-temp.vue\").gsub(%r{<style(.*?)>(.*?)</style>}m).each { |tag| css = $2; puts \"<style#{$1}>\"; print `echo \"#{css}\" | stylefmt --stdin-filename tmp`.chomp; puts \"</style>\"; puts\"\" }''; rm -f vuefmt-temp-js.js; rm -f vuefmt-temp-template.xml; rm -f vuefmt-temp.vue;"'
let g:formatters_vue = ['vuefmt']

" scala
let g:formatdef_scalafmt = "'cat | scalafmt --stdin'"
let g:formatters_scala = ['scalafmt']
" }}}

" emmet {{{
let g:user_emmet_leader_key=','
let g:user_emmet_mode='in'
" }}}

" ensime {{{
" autocmd BufWritePost *.scala silent :EnTypeCheck
" let ensime_server_v2=1
" }}}

" gen_tags {{{
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#gtags_auto_gen = 1
" }}}

" go {{{
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
" }}}

" html5 {{{
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1
" }}}

" javascript {{{
let g:jsx_ext_required = 0
let g:javascript_plugin_flow = 1
" }}}

" json {{{
let g:vim_json_syntax_conceal = 0
" }}}

" jsx-pretty {{{
let g:vim_jsx_pretty_colorful_config = 1
" }}}

" }}}

" Completion & Fuzzy Match & vimfiler {{{

" Denite & Unite & ctrlp {{{
" ctrlp
hi CtrlPMatch ctermfg=74
let g:ctrlp_map = '<Leader>p'
let g:ctrlp_user_command='ag %s -i --nocolor --nogroup -g ""'
let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
let g:ctrlp_prompt_mappings = {
      \ 'PrtBS()':              ['<BS>', '<C-h>'],
      \ 'PrtSelectMove("j")':   ['<C-n>', '<DOWN>'],
      \ 'PrtSelectMove("k")':   ['<C-p>', '<UP>'],
      \ 'PrtHistory(-1)':       ['<C-j>'],
      \ 'PrtHistory(1)':        ['<C-k>'],
      \ 'ToggleRegex()':        ['<C-r>'],
      \ 'ToggleType(1)':        ['<C-up>'],
      \ 'ToggleType(-1)':       ['<C-down>'],
      \ 'PrtCurLeft()':         ['<C-b>', '<LEFT>', '<C-^>'],
      \ 'PrtCurRight()':        ['<C-f>', '<RIGHT>'],
      \ 'MarkToOpen()':         ['<C-space>'],
      \ 'PrtExit()':            ['<esc>', '<C-c>', '<C-g>', '<C-]>']
      \ }

let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v([\/]\.(git|hg|svn)$|[\/]bundle$|[\/]node_modules$)',
      \ 'file': '\v\.(exe|so|dll|gif|png|jpeg|jpg|pdf|mp3|cache)$'
      \ }

let g:ctrlp_status_func = {
      \ 'main': 'CtrlPStatusFunc_1',
      \ 'prog': 'CtrlPStatusFunc_2',
      \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  let g:lightline.ctrlp_marked = a:marked
  return lightline#statusline(0)
endfunction
function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

try
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
  call denite#custom#map('insert', '<Esc>', '<denite:enter_mode:normal>', 'noremap')
  call denite#custom#map('insert', '<C-g>', '<denite:enter_mode:normal>', 'noremap')
  call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
  call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

  " option
  call denite#custom#source(
        \ 'buffer,file_mru,file_rec,grep,line',
        \ 'matchers', ['matcher_cpsm'])
  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
        \[
        \ '*~', '*.o', '*.exe', '*.bak',
        \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
        \ '.hg/', '.git/', '.bzr/', '.svn/', 'node_modules',
        \ 'tags', 'tags-*', '.png', 'jp[e]g', '.gif'
        \])
  call denite#custom#var('file_rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'default_opts', ['--follow', '--no-group', '--no-color'])

  " file & buffer
  " nnoremap <silent> <Leader>f  :<C-u>Denite buffer file_rec -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>b  :<C-u>Denite buffer -direction=topleft<CR>

  " grep
  " nnoremap <silent> <Leader>/ :<C-u>Denite line -auto-preview<CR>
  " nnoremap <silent> <Leader>* :<C-u>DeniteCursorWord line -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep -auto-preview<CR>

  " tag
  " nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord tag -auto-preview<CR>

  " outline
  nnoremap <silent> <Leader>o :<C-u>Denite outline<CR>

  " yank
  " nnoremap <silent> <Leader>P :<C-u>Denite neoyank -direction=topleft<CR>

  " quickfix
  " nnoremap <silent> <Leader>q :Unite quickfix -direction=botright -no-quit<CR>
  " nnoremap <silent> <Leader>l :Denite location_list -no-quit -auto-resize<CR>

  " session
  " nnoremap <silent> <Leader>sl :<C-u>Denite session<CR>

  " Unite

  "" keymap
  autocmd FileType unite call s:unite_my_settings()
  function! s:unite_my_settings()
    nnoremap <silent><buffer> <C-n> j
    nnoremap <silent><buffer> <C-p> k
    nmap <silent><buffer> <ESC><ESC> q
    imap <silent><buffer> <ESC><ESC> <ESC>q
    imap <buffer><C-w> <Plug>(unite_delete_backward_path)
  endfunction

  "" file & buffer
  call unite#filters#matcher_default#use(['matcher_fuzzy'])
  call unite#custom#source('buffer,file, file_rec/async', 'sorters', 'sorter_rank')
  call unite#custom#source('file_rec/async', 'ignore_pattern', '\(png\|gif\|jpeg\|jpg\)$')
  call unite#custom#source('file_rec/async', 'matcher', ['matcher_cpsm'])

  let g:unite_source_rec_max_cache_files = 10000
  let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '-p', '~/.agignore', '-g', '']
  nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:! -start-insert<CR>
  nnoremap <silent> <Leader>b :<C-u>Unite buffer -start-insert<CR>

  "" jump
  " nnoremap <silent> <Leader>j :<C-u>Unite jump -auto-preview -direction=botright<CR>

  " ctags & gtags
  nnoremap <silent> <Leader><C-]> :<C-u>UniteWithCursorWord gtags/context tag -auto-preview -direction=botright<CR>

  "" outline
  " nnoremap <silent> <Leader>o :<C-u>Unite outline -auto-preview -direction=botright<CR>

  "" grep
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''

  call unite#custom_source('line', 'sorters', 'sorter_reverse')
  nnoremap <silent> <Leader>/         :<C-u>Unite line -auto-preview -direction=botright -buffer-name=search-buffer -no-quit -start-insert<CR>
  nnoremap <silent> <Leader>*         :<C-u>UniteWithCursorWord line -auto-preview -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader><Leader>/ :<C-u>Unite grep:. -auto-preview -direction=botright -buffer-name=search-buffer -no-quit -start-insert<CR>
  nnoremap <silent> <Leader><Leader>* :<C-u>UniteWithCursorWord grep:. -auto-preview -direction=botright -buffer-name=search-buffer -no-quit<CR>

  " yank & buffer
  let g:unite_source_history_yank_enable = 1
  nnoremap <silent> <Leader>P :<C-u>Unite yankround<CR>

  " quickfix
  " call unite#custom_source('quickfix', 'sorters', 'sorter_reverse')
  " call unite#custom_source('location_list', 'sorters', 'sorter_reverse')
  " nnoremap <silent> <Leader>q :Unite quickfix -direction=botright -no-quit<CR>
  nnoremap <silent> <Leader>l :<C-u>Unite location_list -direction=botright -no-quit<CR>

  " mark
  " nnoremap <silent> <Leader>m :Unite mark -auto-preview -direction=botright<CR>

  " snippets
  nnoremap <silent> <Leader>sn :<C-u>Unite neosnippet -direction=botright -start-insert<CR>

  " giti
  nnoremap <silent> <Leader>gg :<C-u>Unite giti/status -direction=botright -winheight=10 -no-start-insert -no-quit<CR>

  " agit
  let s:agit_file = { 'description' : 'open the file''s history in agit.vim' }
  function! s:agit_file.func(candidate)
    execute 'AgitFile' '--file='.a:candidate.action__path
  endfunction
  call unite#custom#action('file', 'agit-file', s:agit_file)
catch /E117.*/
  echo "Denite & Unite is not installed. Please :PlugInstall"
endtry
" }}}

" YouCompleteMe && deoplete.nvim && neosnippet.vim {{{
if !has('nvim')
  let g:ycm_seed_identifiers_with_syntax = 0
  autocmd InsertEnter * call plug#load('YouCompleteMe')
else
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#enable_camel_case = 1
  let g:deoplete#auto_complete_delay = 0
  let g:deoplete#auto_complete_start_length = 1
  let g:deoplete#file#enable_buffer_path = 1
  let g:deoplete#tag#cache_limit_size = 10000
  let g:deoplete#sources = {}
  let g:deoplete#sources._ = ['buffer', 'omni', 'look']
  let g:deoplete#sources.javascript = ['ternjs', 'flow', 'omni', 'buffer', 'syntax', 'neosnippet', 'dictionary', 'look']
  let g:deoplete#sources.ruby = ['buffer', 'omni', 'syntax', 'neosnippet', 'dictionary', 'look']
  let g:deoplete#sources.python = ['jedi', 'buffer', 'omni', 'syntax', 'neosnippet', 'look']
  let g:deoplete#sources.scala = ['buffer', 'omni', 'syntax', 'neosnippet', 'look']
  let g:deoplete#sources.go = ['go', 'buffer', 'syntax', 'neosnippet', 'look']
  let g:deoplete#sources.vim = ['vim', 'buffer', 'syntax', 'look']

  let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
  let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
  let g:deoplete#sources#go#use_cache = 1

  let g:deoplete#omni#input_patterns = {}
  let g:deoplete#omni#input_patterns._ = ''
  let g:deoplete#omni#input_patterns.ruby = ['[^. *\t]\.\w*', '[a-zA-Z_]\w*::']
  let g:deoplete#omni#input_patterns.javascript = ''
  let g:deoplete#omni#input_patterns.python = ''
  let g:deoplete#omni#input_patterns.go = ''
  let g:deoplete#omni#input_patterns.scala = ['[^. *\t]\.\w*', '[:\[,] ?\w*', '^import .*']
  let g:deoplete#omni#input_patterns.css  = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
  let g:deoplete#omni#input_patterns.scss = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
  let g:deoplete#omni#input_patterns.html = '<[^>]*'
  let g:deoplete#omni#input_patterns.md = '<[^>]*'

  let g:deoplete#omni#functions = {}
  let g:deoplete#omni#functions._ = ['googlesuggest#Complete']
  let g:deoplete#omni#functions.javascript = ['jspc#omni', 'javascriptcomplete#CompleteJS']
  let g:deoplete#omni#functions.ruby = ['rubycomplete#Complete']
  let g:deoplete#omni#functions.python = ['pythoncomplete#Complete']
  let g:deoplete#omni#functions.html = ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.markdown = ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.css = ['csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.scala = ['EnCompleteFunc']

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
  inoremap <silent><expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
end

let g:neosnippet#disable_runtime_snippets = { '_' : 1 }
let g:neosnippet#enable_snipmate_compatibility = 0
let g:neosnippet#snippets_directory = '~/.vim/plugged/vim-snippets/snippets'
imap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" : "\<TAB>"

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
" }}}

" googlesuggest-complete-vim {{{
set completefunc=googlesuggest#Complete
" }}}

" vimfiler {{{
try
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
  autocmd FileType vimfiler call s:vimfiler_settings()
  function! s:vimfiler_settings()
    nmap <buffer> R <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <C-l> <C-w>l
    nmap <buffer> <C-j> <C-w>j
  endfunction
catch /E117.*/
  echo "vimfiler is not installed. Please :PlugInstall"
endtry
" }}}

" }}}

" Git {{{

" git-gutter {{{
nmap <silent> gp <Plug>GitGutterPrevHunk
nmap <silent> gn <Plug>GitGutterNextHunk
" }}}

" gita {{{
let g:gita#suppress_warning = 1
" }}}

" gina {{{
nnoremap <silent> <Leader>gs :<C-u>Gina status<CR>
nnoremap <silent> <Leader>gd :<C-u>Gina diff<CR>
" }}}

" rooter {{{
nnoremap <silent> <Leader>cd :<C-u>Rooter<CR>
" }}}

" }}}

" Edit & Move & Search {{{

" incsearch & easymotion & anzu & asterisk & search-pulse {{{
let g:vim_search_pulse_disable_auto_mappings = 1
let g:vim_search_pulse_mode = 'pattern'
let g:EasyMotion_smartcase = 1
let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'HJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_use_upper = 1
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1
let g:anzu_status_format = "(%i/%l)"
hi link EasyMotionIncSearch Search
hi link EasyMotionMoveHL Search
autocmd  User PrePulse  set cursorcolumn
autocmd  User PostPulse set nocursorcolumn

map  f  <Plug>(easymotion-bd-fl)
map  t  <Plug>(easymotion-bd-tl)
map  /  <Plug>(incsearch-forward)
map  ?  <Plug>(incsearch-backward)
map  z/ <Plug>(incsearch-fuzzy-/)
map  z? <Plug>(incsearch-fuzzy-?)
nmap g/ <Plug>(easymotion-sn)
xmap g/ <Plug>(easymotion-sn)
omap g/ <Plug>(easymotion-tn)
map  n  <Plug>(easymotion-next)<Plug>(anzu-n)zzzv<Plug>Pulse
map  N  <Plug>(easymotion-prev)<Plug>(anzu-N)zzzv<Plug>Pulse
nmap *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
nmap #  <Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
nmap g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
nmap g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
nmap <silent> <Esc><Esc> <Plug>(anzu-clear-search-status)<Plug>(anzu-clear-sign-matchline):nohlsearch<CR>

nmap s <Plug>(easymotion-overwin-f2)
vmap s <Plug>(easymotion-bd-f2)
map  <Leader>j <Plug>(easymotion-j)
map  <Leader>k <Plug>(easymotion-k)
" }}}

" doorboy {{{
let g:doorboy_nomap_quotations = { 'javascript': ['/'] }
" }}}

" easy-align {{{
vmap <Enter> <Plug>(EasyAlign)
" }}}

" jplus {{{
nmap J <Plug>(jplus)
vmap J <Plug>(jplus)
nmap <Leader>J <Plug>(jplus-input)
vmap <Leader>J <Plug>(jplus-input)
" }}}

" multiple-cursors {{{
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-c>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

function! Multiple_cursors_before()
  let b:deoplete_disable_auto_complete = 1
endfunction
function! Multiple_cursors_after()
  let b:deoplete_disable_auto_complete = 0
endfunction
" }}}

" operator-replace {{{
map _ <Plug>(operator-replace)
" }}}

" over {{{
nnoremap <silent> <Leader>R :<C-u>OverCommandLine<CR>%s/<C-r><C-w>//g<Left><Left>
nnoremap <silent> <Leader>r :<C-u>OverCommandLine<CR>%s//g<Left><Left>
vnoremap <silent> <Leader>r y:<C-u>OverCommandLine<CR>%s/<C-r>=substitute(@0, '/', '\\/', 'g')<CR>//g<Left><Left>
" }}}

" quickhl {{{
nmap <Leader>m         <Plug>(quickhl-manual-this)
xmap <Leader>m         <Plug>(quickhl-manual-this)
nmap <Leader><Leader>m <Plug>(quickhl-manual-reset)
xmap <Leader><Leader>m <Plug>(quickhl-manual-reset)
" }}}

" switch {{{
" 便利だけど挙動が怪しい
nnoremap <silent> <C-s> :<C-u>Switch<CR>
" }}}

" yankround {{{
let g:neoyank#limit = 10000
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap <silent><expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "WSPrev<CR>"
nmap <silent><expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "WSNext<CR>"
" }}}

" }}}

" Appearance {{{

" better-whitespace {{{
let g:better_whitespace_filetypes_blacklist = ['vimfiler', 'unite']
" }}}

" cursorword {{{
autocmd FileType unite,denite,qf,vimfiler,thumbnail,calendar let b:cursorword=0
" }}}

" devicons {{{
let g:webdevicons_enable = 1
let g:webdevicons_enable_unite = 1
let g:webdevicons_enable_vimfiler = 1
let g:WebDevIconsUnicodeDecorateFileNodes = 1

" アップデートでctrlpがフォーク先だと判定されないので仮対応
let g:ctrlp_mruf_map_string = 1
" }}}

" fastfold {{{
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
" }}}

" foldCC {{{
set foldtext=FoldCCtext()
" }}}

" hl_matchit {{{
let g:hl_matchit_enable_on_vim_startup = 1
" }}}

" indent-line {{{
let g:indentLine_enabled = 0
let g:indentLine_fileTypeExclude = ['json']
nnoremap <silent> <Leader>i :<C-u>:IndentLinesToggle<CR>
" }}}

" lightline {{{
let g:lightline = {
      \ 'colorscheme': 'iceberg_tigberd',
      \ 'mode_map': {'c': 'NORMAL'},
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive' ], ['readonly', 'filepath', 'filename', 'anzu' ] ],
      \   'right': [
      \     [ 'lineinfo' ],
      \     [ 'fileformat', 'fileencoding', 'filetype' ],
      \     [ 'ale_error', 'ale_warning', 'ale_ok' ]
      \   ]
      \ },
      \ 'inactive': {
      \   'left': [ [], [ 'fugitive' ], [ 'filepath' ], [ 'filename' ] ],
      \   'right': [
      \     [ 'lineinfo' ],
      \     [ 'fileformat', 'fileencoding', 'filetype' ]
      \   ]
      \ },
      \ 'component': {
      \   'lineinfo': "\ue0a1 %3l:%-2v",
      \ },
      \ 'component_function': {
      \   'readonly':     'LightlineReadonly',
      \   'fugitive':     'LightlineFugitive',
      \   'filepath':     'LightlineFilepath',
      \   'filename':     'LightlineFilename',
      \   'filetype':     'LightlineFiletype',
      \   'fileformat':   'LightlineFileformat',
      \   'fileencoding': 'LightlineFileencoding',
      \   'mode':         'LightlineMode',
      \   'anzu':         'anzu#search_status'
      \ },
      \ 'component_expand': {
      \   'ale_error':     'LightlineAleError',
      \   'ale_warning':   'LightlineAleWarning',
      \   'ale_ok':        'LightlineAleOk',
      \ },
      \ 'component_type': {
      \   'ale_error':   'error',
      \   'ale_warning': 'warning',
      \   'ale_ok':      'ok',
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
      \ 'tabline': 0
      \ }
      \ }

autocmd User ALELint call lightline#update()

function! LightlineReadonly()
  return &readonly ? "\ue0a2" : ''
endfunction

function! LightlineFugitive()
  if exists('*fugitive#head')
    let branch = fugitive#head()
    return branch !=# "\ue0a0" ? "\ue0a0 " . branch : ''
  endif
  return ''
endfunction

function! LightlineFilepath()
  if &filetype ==# 'vimfilter' || &filetype ==# 'unite' || winwidth(0) < 70
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
  if expand('%:t') == 'ControlP'
    return g:lightline.ctrlp_prev . ' ' . g:lightline.subseparator.left . ' ' .
          \ g:lightline.ctrlp_item . ' ' . g:lightline.subseparator.left . ' ' .
          \ g:lightline.ctrlp_next
  endif
  if &filetype ==# 'vimfiler'
    return vimfiler#get_status_string()
  elseif &filetype ==# 'unite'
    return unite#get_status_string()
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

function! LightlineAleError()
  return s:ale_string(0)
endfunction

function! LightlineAleWarning()
  return s:ale_string(1)
endfunction

function! LightlineAleOk()
  return s:ale_string(2)
endfunction

function! s:ale_string(mode)
  if !exists('g:ale_buffer_info')
    return ''
  endif

  let l:buffer = bufnr('%')
  let [l:error_count, l:warning_count] = ale#statusline#Count(l:buffer)
  let [l:error_format, l:warning_format, l:no_errors] = g:ale_statusline_format

  if a:mode == 0
    return l:error_count ? printf(l:error_format, l:error_count) : ''
  elseif a:mode == 1
    return l:warning_count ? printf(l:warning_format, l:warning_count) : ''
  endif

  return l:error_count == 0 && l:warning_count == 0 ? l:no_errors : ''
endfunction
" }}}

" MatchTagAlways {{{
let g:mta_filetypes = {
      \ 'html' : 1,
      \ 'xhtml' : 1,
      \ 'xml' : 1,
      \ 'erb' : 1,
      \ 'jinja' : 1
      \}
" }}}

" operator-flashy {{{
map y <Plug>(operator-flashy)
nmap Y <Plug>(operator-flashy)$
" }}}

" parenmatch {{{
let g:loaded_matchparen = 1
" }}}

" thumbnail {{{
map <silent> <Leader>th <Plug>(thumbnail)
" }}}

" workspace {{{
function g:WorkspaceSetCustomColors()
  hi WorkspaceFill           ctermfg=0 ctermbg=0   guibg=#000000
  hi WorkspaceBufferCurrent  ctermfg=0 ctermbg=67  guibg=#000000
  hi WorkspaceBufferActive   ctermfg=0 ctermbg=243 guibg=#000000
  hi WorkspaceBufferHidden   ctermfg=0 ctermbg=241 guibg=#000000
endfunction

let g:workspace_use_devicons = 1
let g:workspace_powerline_separators = 1
let g:workspace_tab_icon = "\uf00a"
let g:workspace_left_trunc_icon = "\uf0a8"
let g:workspace_right_trunc_icon = "\uf0a9"
noremap <Leader>d :BD<CR>
" }}}

" zenspace {{{
let g:zenspace#default_mode = 'on'
" }}}

" }}}

" Util {{{

" calendar {{{
nnoremap <silent> <Leader>ca :<C-u>Calendar<CR>
" }}}

" expand-region {{{
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
let g:expand_region_text_objects_ruby = {
      \ 'im' :0,
      \ 'am' :0
      \ }
" }}}

" external {{{
map <Leader>O <Plug>(external-explorer)
map <Leader>B <Plug>(external-browser)
" }}}

" extracmd {{{
try
  call extracmd#set('<silent>', 'w!!', 'w !sudo tee > /dev/null %')
  call extracmd#set('<silent>', 'gd', 'Tmpbuffer git diff <bar> set filetype=diff')
  call extracmd#set('<silent>', 'gdc', 'Tmpbuffer git diff --cached <bar> set filetype=diff')
  call extracmd#set('git', 'Magit')
  call extracmd#set('gita', 'Gita')
  call extracmd#set('gina', 'Gina')
  call extracmd#set('blame', 'Gita blame')
  call extracmd#set('log', 'Agit')
  call extracmd#set('branch', 'Merginal')
  call extracmd#set('di', 'Ref webdict alc <C-R><C-W><CR>')
  call extracmd#set('alc', 'Ref webdict alc')
  call extracmd#set('tag', 'TagbarOpen j<CR>')
  call extracmd#set('num', 'NumbersToggle<CR>')
  call extracmd#set('j', 'Unite jump change -auto-preview<CR>')
  call extracmd#set('tab', 'Unite tab<CR>')
  call extracmd#set('sf', 'CtrlSF')
catch /E117.*/
  echo "extracmd is not installed. Please :PlugInstall"
endtry
" }}}

" maximizer {{{
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
" }}}

" neoterm {{{
nnoremap <silent> <Leader>tn :<C-u>:Tnew<CR>
nnoremap <silent> <Leader>tt :<C-u>:Ttoggle<CR>
nnoremap <silent> <Leader>tc :<C-u>:TcloseAll<CR>
" }}}

" ref {{{
let g:ref_source_webdict_sites = {
      \ 'alc' : {
      \   'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
      \   }
      \ }
function! g:ref_source_webdict_sites.alc.filter(output)
  return join(split(a:output, "\n")[42 :], "\n")
endfunction
" }}}

" signature {{{
let g:SignatureMap = {
      \ 'ToggleMarkAtLine'   : "mm",
      \ 'GotoNextLineAlpha'  :  "mn",
      \ 'GotoPrevLineAlpha'  :  "mp",
      \ }
" }}}

" startify {{{
let g:startify_custom_header = [
      \'          ______                                       _',
      \'          | ___ \                                     | |',
      \'          | |_/ /  ___ __   __  ___  _ __  ___   __ _ | |',
      \'          |    /  / _ \\ \ / / / _ \| /__|/ __| / _` || |',
      \'          | |\ \ |  __/ \ V / |  __/| |   \__ \| (_| || |',
      \'          \_| \_| \___|  \_/   \___||_|   |___/ \__,_||_|',
      \]

let g:startify_list_order = [
      \ ['   Recent Files:'],
      \ 'files',
      \ ['   Project:'],
      \ 'dir',
      \ ['   Sessions:'],
      \ 'sessions',
      \ ['   Commands:'],
      \ 'commands',
      \ ]
let g:startify_change_to_vcs_root = 1
" }}}

" submode {{{
function! s:my_x()
  undojoin
  normal! "_x
endfunction
nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
call submode#enter_with('my_x', 'n', '', 'x', '"_x')
call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')
" }}}

" undotree {{{
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}

" }}}

" }}}

" vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
