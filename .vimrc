" vim-plug {{{

filetype off

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-plug', {'dir': '~/.vim/plugged/vim-plug/autoload'}

function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" Doc {{{
Plug 'vim-jp/vimdoc-ja'
" }}}

" Language {{{
Plug 'Chiel92/vim-autoformat'
Plug 'Valloric/MatchTagAlways', { 'for': ['html', 'xml', 'erb'] }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'ap/vim-css-color', { 'for': ['css', 'sass', 'scss'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': ['sass', 'scss'] }
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'ekalinin/Dockerfile.vim', { 'for': 'dockerfile' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'hashivim/vim-terraform', { 'for': 'terraform' }
Plug 'heavenshell/vim-pydocstring', { 'for': 'python' }
Plug 'jsfaint/gen_tags.vim'
Plug 'kewah/vim-stylefmt', { 'for': 'css' }
Plug 'mattn/emmet-vim', { 'for': ['html', 'eruby.html', 'javascript', 'vue', 'vue.html.javascript.css'] }
Plug 'maxmellon/vim-jsx-pretty', { 'for': 'javascript' }
Plug 'mkomitee/vim-gf-python', { 'for': 'python' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'nsf/gocode', { 'for': 'go', 'rtp': 'nvim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'othree/csscomplete.vim', { 'for': ['css', 'sass', 'scss'] }
Plug 'othree/es.next.syntax.vim', { 'for': 'javascript' }
Plug 'othree/html5.vim', { 'for': ['html', 'eruby'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': 'javascript' }
Plug 'othree/jspc.vim', { 'for': 'javascript' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'posva/vim-vue', { 'for': 'vue' }
Plug 'rhysd/vim-gfm-syntax', { 'for': 'markdown' }
Plug 'styled-components/vim-styled-components', { 'for': 'javascript' }
Plug 'tell-k/vim-autopep8', { 'for': 'python' }
Plug 'thinca/vim-ft-help_fold', { 'for': 'help' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
Plug 'vim-jp/syntax-vim-ex', { 'for': 'vim' }
Plug 'vim-python/python-syntax', { 'for': 'python' }
Plug 'vim-ruby/vim-ruby', { 'for': ['ruby', 'eruby'] }
Plug 'vim-scripts/python_match.vim', { 'for': 'python' }
Plug 'vimperator/vimperator.vim', { 'for': 'vimperator' }
Plug 'vimtaku/hl_matchit.vim', { 'for': 'ruby' }
Plug 'w0rp/ale'
Plug 'ywatase/mdt.vim', { 'for': 'markdown' }
" }}}

" Git {{{
Plug 'airblade/vim-gitgutter'
Plug 'cohama/agit.vim'
Plug 'lambdalisue/gina.vim'
Plug 'lambdalisue/vim-unified-diff'
Plug 'rhysd/committia.vim'
" }}}

" Completion & Fuzzy Match & vimfiler {{{
Plug 'Shougo/denite.nvim'
Plug 'Shougo/deoplete.nvim', Cond(has('nvim'), { 'do': ':UpdateRemotePlugins', 'on': [] })
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neco-vim'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neoyank.vim'
Plug 'Shougo/unite-session'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler'
Plug 'Valloric/YouCompleteMe', Cond(!has('nvim'), { 'do': './install.py' })
Plug 'carlitux/deoplete-ternjs', Cond(has('nvim'), { 'for': ['javascript'] })
Plug 'chemzqm/denite-extra'
Plug 'hewes/unite-gtags'
Plug 'honza/vim-snippets'
Plug 'lighttiger2505/gtags.vim'
Plug 'osyo-manga/unite-highlight'
Plug 'osyo-manga/unite-quickfix'
Plug 'ozelentok/denite-gtags'
Plug 'rking/ag.vim', { 'on': 'Ag' }
Plug 'tsukkee/unite-tag'
Plug 'ujihisa/neco-look'
Plug 'wokalski/autocomplete-flow', Cond(has('nvim'), { 'for': 'javascript' })
Plug 'zchee/deoplete-go', Cond(has('nvim'), { 'for': 'go', 'do': 'make' })
Plug 'zchee/deoplete-jedi', Cond(has('nvim'), { 'for': 'python' })
" }}}

" Edit & Move & Search {{{
Plug 'LeafCage/yankround.vim'
Plug 'chrisbra/NrrwRgn', { 'on': 'NR' }
Plug 'cohama/lexima.vim'
Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle' }
Plug 'dietsche/vim-lastplace'
Plug 'easymotion/vim-easymotion'
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'h1mesuke/vim-alignta'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/vim-asterisk'
Plug 'haya14busa/vim-metarepeat'
Plug 'houtsnip/vim-emacscommandline'
Plug 'junegunn/vim-easy-align'
Plug 'jwhitley/vim-matchit'
Plug 'kana/vim-operator-replace'
Plug 'osyo-manga/vim-anzu'
Plug 'osyo-manga/vim-jplus'
Plug 'osyo-manga/vim-over'
Plug 'rhysd/clever-f.vim'
Plug 'thinca/vim-qfreplace', { 'on': 'Qfreplace' }
Plug 'thinca/vim-visualstar'
Plug 'tomtom/tcomment_vim', { 'on': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs'] }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
" }}}

" Appearance {{{
Plug 'LeafCage/foldCC.vim'
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesToggle' }
Plug 'cocopon/iceberg.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'gregsexton/MatchTag'
Plug 'haya14busa/vim-operator-flashy'
Plug 'inside/vim-search-pulse'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-cursorword'
Plug 'itchyny/vim-highlighturl'
Plug 'itchyny/vim-parenmatch'
Plug 'luochen1990/rainbow'
Plug 'ntpeters/vim-better-whitespace'
Plug 'thinca/vim-zenspace'
Plug 'vim-scripts/AnsiEsc.vim'
Plug 'vim-scripts/CursorLineCurrentWindow'
Plug 'vimtaku/hl_matchit.vim'
" }}}

" Util {{{
Plug 'Shougo/junkfile.vim'
Plug 'aiya000/aho-bakaup.vim'
Plug 'bogado/file-line'
Plug 'daisuzu/translategoogle.vim'
Plug 'itchyny/vim-extracmd'
Plug 'janko-m/vim-test'
Plug 'jez/vim-superman'
Plug 'kana/vim-gf-user'
Plug 'kana/vim-niceblock'
Plug 'kana/vim-operator-user'
Plug 'kana/vim-submode'
Plug 'kana/vim-textobj-user'
Plug 'kassio/neoterm'
Plug 'konfekt/fastfold'
Plug 'majutsushi/tagbar'
Plug 'mattn/benchvimrc-vim', { 'on': 'BenchVimrc' }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'mhinz/vim-startify'
Plug 'mtth/scratch.vim', { 'on': 'Scratch' }
Plug 'qpkorr/vim-bufkill'
Plug 'simeji/winresizer'
Plug 'szw/vim-maximizer', { 'on': 'MaximizerToggle' }
Plug 'terryma/vim-expand-region'
Plug 'thinca/vim-ambicmd'
Plug 'thinca/vim-ref'
Plug 'tweekmonster/startuptime.vim', { 'on': 'StartupTime' }
Plug 'tyru/capture.vim', { 'on': 'Capture' }
Plug 'tyru/vim-altercmd'
" }}}

" Library {{{
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'vim-scripts/L9'
Plug 'vim-scripts/cecutil'
" }}}

" 他のプラグインとの都合上最後に読み込む
Plug 'ryanoasis/vim-devicons'
" lessの場合は使用しない
if !exists("loaded_less")
  Plug 'bagrat/vim-workspace'
endif

" My Plugin {{{
set runtimepath+=~/.vim/plugins/lightline-iceberg-tigberd
" }}}

let s:plug = {
      \ "plugs": get(g:, 'plugs', {})
      \ }
function! s:plug.is_installed(name)
  return has_key(self.plugs, a:name) ? isdirectory(self.plugs[a:name].dir) : 0
endfunction

call plug#end()

filetype plugin indent on

" }}}

" Settings {{{

"" Leader
let mapleader = " "

"" Encoding.
if has('vim_starting')
  set encoding=utf-8
  set fileencodings=utf-8,sjis,cp932,euc-jp
  set fileformats=unix,mac,dos
endif

"" Appearance
set cmdheight=1
set cursorline
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


if has('nvim')
  autocmd TermOpen * set nonumber | set norelativenumber
endif
autocmd BufNewFile,BufRead,FileType * set number


"" Folding
set foldcolumn=1
set foldenable
set foldmethod=manual

"" Swap
set noswapfile

"" History
set history=10000
set undodir=~/.vim_undo
set undofile
set viewoptions=cursor,folds

" Search
set hlsearch
set ignorecase
set smartcase

"" Indent
set autoindent
set expandtab
set smartindent
set cindent
set backspace=2
set tabstop=2 shiftwidth=2 softtabstop=0

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

"" Others.
set autoread
set belloff=all
set clipboard+=unnamed
set completeopt=longest,menuone,preview
set ignorecase
set langnoremap
set lazyredraw
set matchpairs+=<:>
set regexpengine=2
set shell=/bin/bash
set suffixesadd=.js,.rb,.ts,.json,.md
set timeoutlen=750
set ttimeoutlen=10
set updatetime=500
set virtualedit=all
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
set synmaxcol=300

"" Map
if has('nvim')
  nmap <BS> <C-W>h
endif
inoremap <C-h> <BS>
inoremap <C-d> <Del>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <Leader>W :<C-u>wall<CR>
nnoremap <silent> <Leader>q :<C-u>q<CR>
nnoremap <silent> <Leader>w :<C-u>w<CR>
nnoremap B :b<Space>
nnoremap x "_x
nnoremap <silent> <Leader>tr :<C-u>terminal<CR>

"" Move CommandLine
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-d> <Del>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" terminal
if has('nvim')
  tnoremap <silent> <ESC> <C-\><C-n>
endif

"" Language
set complete+=k
set completeopt=longest,menuone,preview

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

autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType ruby          setlocal omnifunc=
autocmd FileType eruby.html    setlocal omnifunc=
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType javascript    setlocal dict=~/dotfiles/.vim/dict/javascript.dict
autocmd FileType ruby,eruby    setlocal dict=~/dotfiles/.vim/dict/rails.dict

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

"" Color
if $TERM == 'screen'
  set t_Co=256
endif

set background=dark
silent! colorscheme iceberg
autocmd ColorScheme * hi LineNr ctermfg=241
autocmd ColorScheme * hi CursorLineNr ctermbg=237 ctermfg=253
autocmd ColorScheme * hi CursorLine ctermbg=235
autocmd ColorScheme * hi Search  ctermfg=none ctermbg=237
autocmd ColorScheme * hi PmenuSel cterm=reverse ctermfg=33 ctermbg=222
autocmd VimEnter    * hi Visual ctermfg=159 ctermbg=23
syntax enable

" }}}

" Command {{{

" GoogleTranslation {{{
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
" }}}

" ToggleHiglight {{{
noremap <silent><Leader>h :<C-u>call <SID>ToggleHiglight()<CR>
function! s:ToggleHiglight()
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
  endif
endfunction
" }}}

" TrimEndLines {{{
function! TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
autocmd BufWritePre * call TrimEndLines()
" }}}

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
hi ALEWarning ctermfg=0 ctermbg=229
hi ALEError ctermfg=0 ctermbg=203
" }}}

" autoformat {{{
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
" }}}

" emmet {{{
let g:user_emmet_leader_key=','
let g:user_emmet_mode='in'
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

" ruby {{{
let g:rubycomplete_rails                = 1
let g:rubycomplete_buffer_loading       = 1
let g:rubycomplete_classes_in_global    = 1
let g:rubycomplete_include_object       = 1
let g:rubycomplete_include_object_space = 1
" }}}

" }}}

" Completion & Fuzzy Match & vimfiler {{{

" Denite & Unite {{{
if s:plug.is_installed("denite.nvim")
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
  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
        \[
        \ '*~', '*.o', '*.exe', '*.bak',
        \ '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
        \ '.hg/', '.git/', '.bzr/', '.svn/', 'node_modules',
        \ 'tags', 'tags-*', '.png', 'jp[e]g', '.gif',
        \ '*.min.*'
        \])
  call denite#custom#var('file_rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'default_opts', ['--follow', '--no-group', '--no-color'])

  " file & buffer
  nnoremap <silent> <Leader>p  :<C-u>Denite file_rec -direction=botright -mode=insert<CR>
  nnoremap <silent> <Leader>f  :<C-u>Denite buffer file_rec -direction=topleft -mode=insert<CR>
  nnoremap <silent> <Leader>b  :<C-u>Denite buffer -direction=topleft -mode=insert<CR>

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
  " nnoremap <silent> <Leader>l :Denite location_list -no-quit -auto-resize<CR>
  " nnoremap <silent> <Leader>q :Denite quickfix -no-quit -auto-resize<CR>

  " session
  " nnoremap <silent> <Leader>sl :<C-u>Denite session<CR>

  " resume
  nnoremap <silent> dr :<C-u>Denite -resume<CR>
endif

if s:plug.is_installed("unite.vim")
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

  let g:unite_source_rec_max_cache_files = 10000
  let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '-p', '~/.agignore', '-g', '']
  " nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:! -start-insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Unite buffer -start-insert<CR>

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
  nnoremap <silent> <Leader>P :<C-u>Unite yankround<CR>

  " quickfix
  nnoremap <silent> <Leader>q :<C-u>Unite quickfix -direction=botright -no-quit<CR>
  nnoremap <silent> <Leader>l :<C-u>Unite location_list -direction=botright -no-quit<CR>

  " session
  nnoremap <Leader>ss :<C-u>UniteSessionSave<CR>
  nnoremap <Leader>sl :<C-u>UniteSessionLoad<CR>

  " snippets
  nnoremap <silent> <Leader>sn :<C-u>Unite neosnippet -direction=botright -start-insert<CR>
endif
" }}}

" YouCompleteMe && deoplete.nvim && neosnippet.vim {{{
if !has('nvim')
  if s:plug.is_installed("YouCompleteMe")
    let g:ycm_seed_identifiers_with_syntax = 0
    autocmd InsertEnter * call plug#load('YouCompleteMe')
  endif
else
  if s:plug.is_installed("deoplete.nvim")
    autocmd InsertEnter * call plug#load('deoplete.nvim')

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
    let g:deoplete#sources.ruby = ['buffer', 'syntax', 'neosnippet', 'dictionary', 'look']
    " let g:deoplete#sources.ruby = ['buffer', 'omni', 'syntax', 'neosnippet', 'dictionary', 'look']
    let g:deoplete#sources.python = ['jedi', 'buffer', 'omni', 'syntax', 'neosnippet', 'look']
    let g:deoplete#sources.scala = ['buffer', 'omni', 'syntax', 'neosnippet', 'look']
    let g:deoplete#sources.go = ['go', 'buffer', 'syntax', 'neosnippet', 'look']
    let g:deoplete#sources.vim = ['vim', 'buffer', 'syntax', 'look']

    let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
    let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
    let g:deoplete#sources#go#use_cache = 1

    let g:deoplete#omni#input_patterns = {}
    let g:deoplete#omni#input_patterns._ = ''
    let g:deoplete#omni#input_patterns.ruby = ''
    let g:deoplete#omni#input_patterns.javascript = ''
    let g:deoplete#omni#input_patterns.python = ''
    let g:deoplete#omni#input_patterns.go = ''
    let g:deoplete#omni#input_patterns.scala = ['[^. *\t]\.\w*', '[:\[,] ?\w*', '^import .*']
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
    inoremap <silent><expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
  endif
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

" vimfiler {{{
if s:plug.is_installed("vimfiler")
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
endif
" }}}

" }}}

" Git {{{

" agit {{{
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
" }}}

" committia {{{
let g:committia_open_only_vim_starting = 0
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info)
  setlocal spell
  imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
  imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
endfunction
" }}}

" git-gutter {{{
if s:plug.is_installed("vim-gitgutter")
  let g:gitgutter_map_keys = 0
  nmap <silent> gp <Plug>GitGutterPrevHunk
  nmap <silent> gn <Plug>GitGutterNextHunk
  nmap <silent> <Leader>gs <Plug>GitGutterStageHunk
  nmap <silent> <Leader>gu <Plug>GitGutterUndoHunk
  nmap <silent> <Leader>gv <Plug>GitGutterPreviewHunk
endif
" }}}

" gina {{{
nnoremap <silent> <Leader>gs  :<C-u>Gina status<CR>
nnoremap <silent> <Leader>gd  :<C-u>Gina diff<CR>
nnoremap <silent> <Leader>gdc :<C-u>Gina diff --cached<CR>
nnoremap <silent> <Leader>gci :<C-u>Gina commit<CR>
autocmd FileType gina-blame call s:gina_blame_settings()
function! s:gina_blame_settings()
  nmap <buffer> <C-l> <C-w>l
  nmap <buffer> <C-r> <Plug>(gina-blame-redraw)
endfunction
" }}}

" }}}

" Edit & Move & Search {{{

" incsearch & anzu & asterisk & search-pulse {{{
if s:plug.is_installed("incsearch.vim")
  let g:vim_search_pulse_disable_auto_mappings = 1
  let g:vim_search_pulse_mode = 'pattern'
  let g:anzu_status_format = "(%i/%l)"
  autocmd  User PrePulse  set cursorcolumn
  autocmd  User PostPulse set nocursorcolumn

  map  /  <Plug>(incsearch-forward)
  map  ?  <Plug>(incsearch-backward)
  map  n  <Plug>(anzu-n)zzzv<Plug>Pulse
  map  N  <Plug>(anzu-N)zzzv<Plug>Pulse
  nmap *  <Plug>(asterisk-z*)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
  nmap #  <Plug>(asterisk-z#)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
  nmap g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
  nmap g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status-with-echo)<Plug>Pulse
  nmap <silent> <Esc><Esc> <Plug>(anzu-clear-search-status)<Plug>(anzu-clear-sign-matchline):nohlsearch<CR>
endif
" }}}

" easy-align {{{
vmap <Enter> <Plug>(EasyAlign)
" }}}

" easymotion {{{
let g:EasyMotion_smartcase = 1
let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'HJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_use_upper = 1
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1
hi link EasyMotionIncSearch Search
hi link EasyMotionMoveHL Search
nmap s <Plug>(easymotion-overwin-f2)
vmap s <Plug>(easymotion-bd-f2)
" }}}

" jplus {{{
if s:plug.is_installed("vim-jplus")
  nmap J <Plug>(jplus)
  vmap J <Plug>(jplus)
  nmap <Leader>J <Plug>(jplus-input)
  vmap <Leader>J <Plug>(jplus-input)
endif
" }}}

" lexima {{{
function! Hook_on_post_source_lexima() abort
  let rules = []

  let rules += [
        \ {'char': '(', 'at': '(\%#)',   'input': '<Del>'},
        \ {'char': '{', 'at': '{\%#}',   'input': '<Del>'},
        \ {'char': '[', 'at': '\[\%#\]', 'input': '<Del>'},
        \ {'char': "'", 'at': "'\%#'",   'input': '<Del>'},
        \ {'char': '"', 'at': '"\%#"',   'input': '<Del>'},
        \ ]

  for rule in rules
    call lexima#add_rule(rule)
  endfor
endfunction

call Hook_on_post_source_lexima()
" }}}

" operator-replace {{{
map _ <Plug>(operator-replace)
" }}}

" over {{{
nnoremap <silent> <Leader>R :<C-u>OverCommandLine<CR>%s/<C-r><C-w>//g<Left><Left>
nnoremap <silent> <Leader>r :<C-u>OverCommandLine<CR>%s//g<Left><Left>
vnoremap <silent> <Leader>r y:<C-u>OverCommandLine<CR>%s/<C-r>=substitute(@0, '/', '\\/', 'g')<CR>//g<Left><Left>
" }}}

" tcomment {{{
noremap <silent> <Leader>c :TComment<CR>
" }}}

" yankround {{{
if s:plug.is_installed("yankround.vim")
  let g:neoyank#limit = 10000
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap <silent><expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : ":WSPrev<CR>"
  nmap <silent><expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : ":WSNext<CR>"
endif
" }}}

" }}}

" Appearance {{{

" better-whitespace {{{
let g:better_whitespace_filetypes_blacklist = ['tag', 'help', 'vimfiler', 'unite']
" }}}

" cursorword {{{
autocmd FileType unite,denite,qf,vimfiler let b:cursorword=0
" }}}

" devicons {{{
let g:webdevicons_enable = 1
let g:webdevicons_enable_unite = 1
let g:webdevicons_enable_vimfiler = 1
let g:WebDevIconsUnicodeDecorateFileNodes = 1
" }}}

" fastfold {{{
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
" }}}

" foldCC {{{
if s:plug.is_installed("foldCC.vim")
  set foldtext=FoldCCtext()
endif
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
if s:plug.is_installed("lightline.vim")
  let g:lightline = {
        \ 'colorscheme': 'iceberg_tigberd',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'gina' ], ['readonly', 'filepath', 'filename', 'anzu' ] ],
        \   'right': [
        \     [ 'lineinfo' ],
        \     [ 'fileformat', 'fileencoding', 'filetype' ],
        \     [ 'ale_error', 'ale_warning', 'ale_ok' ]
        \   ]
        \ },
        \ 'inactive': {
        \   'left': [ [], [ 'gina' ], [ 'filepath' ], [ 'filename' ] ],
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
        \   'gina':         'LightlineGina',
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

  function! LightlineGina()
    let branch = gina#component#repo#branch()
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

  function! LightlineAleError() abort
    return s:ale_string(0)
  endfunction

  function! LightlineAleWarning() abort
    return s:ale_string(1)
  endfunction

  function! LightlineAleOk() abort
    return s:ale_string(2)
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
" }}}

" MatchTagAlways {{{
let g:mta_filetypes = {
      \ 'html' : 1,
      \ 'xhtml' : 1,
      \ 'xml' : 1,
      \ 'erb' : 1
      \}
" }}}

" operator-flashy {{{
if s:plug.is_installed("vim-operator-flashy")
  map y <Plug>(operator-flashy)
  nmap Y <Plug>(operator-flashy)$
endif
" }}}

" parenmatch {{{
let g:loaded_matchparen = 1
" }}}

" rainbow {{{
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
" }}}

" workspace & bufkill {{{
if s:plug.is_installed("vim-workspace")
  function! g:WorkspaceSetCustomColors()
    hi WorkspaceFill           ctermfg=0 ctermbg=0   guibg=#999999 guifg=#999999
    hi WorkspaceBufferCurrent  ctermfg=0 ctermbg=67  guibg=#00FF00 guifg=#000000
    hi WorkspaceBufferActive   ctermfg=0 ctermbg=243 guibg=#999999 guifg=#00FF00
    hi WorkspaceBufferHidden   ctermfg=0 ctermbg=241 guibg=#999999 guifg=#000000
  endfunction

  let g:workspace_use_devicons = 1
  let g:workspace_powerline_separators = 1
  let g:workspace_tab_icon = "\uf00a"
  let g:workspace_left_trunc_icon = "\uf0a8"
  let g:workspace_right_trunc_icon = "\uf0a9"

  autocmd FileType *    nnoremap <silent> <Leader>d :BD<CR>
  autocmd FileType help nnoremap <silent> <Leader>d :BW<CR>
  autocmd FileType diff nnoremap <silent> <Leader>d :BW<CR>
  autocmd FileType git  nnoremap <silent> <Leader>d :BW<CR>

  nnoremap <silent> <Leader>tc :tabe<CR>
  nnoremap <silent> <Leader>tn :tabnext<CR>
  nnoremap <silent> <Leader>tp :tabprevious<CR>
  nnoremap <silent> <Leader>td :tabclose<CR>
  nnoremap <silent> <Leader>ts :tabs<CR>
endif
" }}}

" zenspace {{{
let g:zenspace#default_mode = 'on'
" }}}

" }}}

" Util {{{

" aho-bakaup.vim {{{
let g:bakaup_auto_backup = 1
" }}}

" expand-region {{{
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
let g:expand_region_text_objects_ruby = {
      \ 'im' :0,
      \ 'am' :0
      \ }
" }}}

" extracmd {{{
if s:plug.is_installed("vim-extracmd")
  call extracmd#set('w!!',      'w !sudo tee > /dev/null %')
  call extracmd#set('gina',     'Gina')
  call extracmd#set('gci',      'Gina commit')
  call extracmd#set('blame',    'Gina blame :%')
  call extracmd#set('agit',     'Agit')
  call extracmd#set('alc',      'Ref webdict alc')
  call extracmd#set('tag',      'TagbarOpen j<CR>')
  call extracmd#set('j',        'Unite jump change -auto-preview<CR>')
  call extracmd#set('tab',      'Unite tab<CR>')
  call extracmd#set('nr',       'NR<CR>')
  call extracmd#set('sctartch', 'Scratch<CR>')
  call extracmd#set('json',     '%!python -m json.tool<CR>')
endif
" }}}

" maximizer {{{
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
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

" scratch {{{
let g:scratch_no_mappings = 1
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
      \ 'dir'
      \ ]
let g:startify_change_to_vcs_root = 1
" }}}

" test {{{
let test#strategy = 'neoterm'
" }}}

" undotree {{{
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}

" }}}

" }}}

" vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
