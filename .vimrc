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
let g:dein#install_max_processes = 20
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
  " call dein#add('pocke/iro.vim',                          {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('Chiel92/vim-autoformat',                 {'lazy': 1, 'on_cmd': 'Autoformat'})
  call dein#add('MaxMEllon/vim-jsx-pretty',               {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('Quramy/tsuquyomi',                       {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('Shougo/context_filetype.vim')
  call dein#add('Shougo/echodoc.vim',                     {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('SpaceVim/gtags.vim')
  call dein#add('Vimjas/vim-python-pep8-indent',          {'lazy': 1, 'on_ft': 'python'})
  call dein#add('ap/vim-css-color',                       {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('cakebaker/scss-syntax.vim',              {'lazy': 1, 'on_ft': ['sass', 'scss']})
  call dein#add('cespare/vim-toml',                       {'lazy': 1, 'on_ft': 'toml'})
  call dein#add('chrisbra/vim-zsh',                       {'lazy': 1, 'on_ft': 'zsh'})
  call dein#add('davidhalter/jedi-vim',                   {'lazy': 1, 'on_ft': 'python'})
  call dein#add('ekalinin/Dockerfile.vim',                {'lazy': 1, 'on_ft': 'Dockerfile'})
  call dein#add('elzr/vim-json',                          {'lazy': 1, 'on_ft': 'json'})
  call dein#add('fatih/vim-go',                           {'lazy': 1, 'on_ft': 'go'})
  call dein#add('hail2u/vim-css3-syntax',                 {'lazy': 1, 'on_ft': 'css'})
  call dein#add('hashivim/vim-terraform',                 {'lazy': 1, 'on_ft': 'terraform'})
  call dein#add('heavenshell/vim-jsdoc',                  {'lazy': 1, 'on_ft': ['javascript', 'typescript'], 'on_cmd': 'JsDoc'})
  call dein#add('itspriddle/vim-marked',                  {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('jparise/vim-graphql',                    {'lazy': 1, 'on_ft': 'graphql'})
  call dein#add('jsfaint/gen_tags.vim')
  call dein#add('kchmck/vim-coffee-script',               {'lazy': 1, 'on_ft': 'coffee'})
  call dein#add('keith/tmux.vim',                         {'lazy': 1, 'on_ft': 'tmux'})
  call dein#add('leafgarland/typescript-vim',             {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('mattn/emmet-vim',                        {'lazy': 1, 'on_ft': ['html', 'eruby', 'javascript', 'vue']})
  call dein#add('noprompt/vim-yardoc',                    {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('othree/csscomplete.vim',                 {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('othree/es.next.syntax.vim',              {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/html5.vim',                       {'lazy': 1, 'on_ft': ['html', 'eruby', 'markdown']})
  call dein#add('othree/javascript-libraries-syntax.vim', {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/jspc.vim',                        {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('othree/yajs.vim',                        {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('pearofducks/ansible-vim',                {'lazy': 1, 'on_ft': ['ansible', 'ansible_templete', 'ansible_hosts']})
  call dein#add('plasticboy/vim-markdown',                {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('plytophogy/vim-virtualenv',              {'lazy': 1, 'on_ft': 'python'})
  call dein#add('posva/vim-vue',                          {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('prettier/vim-prettier',                  {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'vue', 'css', 'scss', 'json', 'graphql', 'markdown']})
  call dein#add('rust-lang/rust.vim',                     {'lazy': 1, 'on_ft': 'rust'})
  call dein#add('sgur/vim-editorconfig',                  {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('slim-template/vim-slim',                 {'lazy': 1, 'on_ft': 'slim'})
  call dein#add('stephpy/vim-yaml',                       {'lazy': 1, 'on_ft': 'yaml'})
  call dein#add('tell-k/vim-autopep8',                    {'lazy': 1, 'on_ft': 'python'})
  call dein#add('tpope/vim-rails',                        {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('vim-ruby/vim-ruby',                      {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
  " }}}3

  " ALE {{{
  let s:ale_filetypes = ['javascript', 'typescript', 'vue', 'ruby', 'eruby', 'python', 'go', 'rust', 'json', 'html', 'css', 'scss', 'vim', 'sh', 'bash', 'zsh']
  call dein#add('w0rp/ale', {'lazy': 1, 'on_ft': s:ale_filetypes})
  " }}}

  " Git {{{3
  call dein#add('ToruIwashita/git-switcher.vim')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('airblade/vim-rooter',           {'lazy': 1, 'on_cmd': 'Rooter'})
  call dein#add('cohama/agit.vim',               {'lazy': 1, 'on_cmd': ['Agit', 'AgitFile', 'AgitGit', 'AgitDiff']})
  call dein#add('hotwatermorning/auto-git-diff', {'lazy': 1, 'on_ft': 'gitrebase'})
  call dein#add('lambdalisue/gina.vim')
  call dein#add('lambdalisue/vim-unified-diff')
  call dein#add('rhysd/committia.vim',           {'lazy': 1, 'on_ft': 'gitcommit'})
  call dein#add('rhysd/conflict-marker.vim')
  " }}}3

  " Completion {{{3
  if has('nvim')
    call dein#add('Shougo/deoplete.nvim')

    " call dein#add('autozimu/LanguageClient-neovim', {'rev': 'next', 'build': 'bash install.sh'})
    " call dein#add('blueyed/vim-auto-programming', {'rev': 'neovim'})
    call dein#add('Shougo/neco-syntax')
    call dein#add('Shougo/neco-vim')
    call dein#add('Shougo/neosnippet')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('carlitux/deoplete-ternjs')
    call dein#add('fishbullet/deoplete-ruby')
    call dein#add('fszymanski/deoplete-emoji')
    call dein#add('ujihisa/neco-look')
    call dein#add('wellle/tmux-complete.vim')
    call dein#add('wokalski/autocomplete-flow')
    call dein#add('zchee/deoplete-jedi')
  endif
  " }}}3

  " Fuzzy Finder {{{3
  " call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/unite.vim')

  call dein#add('ozelentok/denite-gtags')

  call dein#local('/usr/local/opt/', {}, ['fzf'])
  call dein#add('junegunn/fzf.vim')
  call dein#add('yuki-ycino/fzf-preview.vim')
  " call dein#local('~/repos/github.com/yuki-ycino', {}, ['fzf-preview.vim'])
  " }}}3

  " filer {{{3
  " call dein#add('Shougo/vimfiler')
  call dein#add('cocopon/vaffle.vim')
  " }}}3

  " Edit & Move & Search {{{3
  " call dein#add('tyru/skk.vim',                           {'lazy': 1, 'on_event': 'InsertEnter'})
  " call dein#add('vimtaku/vim-mlh',                        {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('AndrewRadev/switch.vim',                 {'lazy': 1, 'on_cmd': 'Switch'})
  call dein#add('LeafCage/yankround.vim')
  call dein#add('chrisbra/NrrwRgn',                       {'lazy': 1, 'on_cmd': ['NR', 'NW', 'WidenRegion', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL']})
  call dein#add('cohama/lexima.vim',                      {'lazy': 1, 'on_event': 'InsertEnter', 'hook_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('dyng/ctrlsf.vim',                        {'lazy': 1, 'on_cmd': ['CtrlSF', 'CtrlSFUpdate', 'CtrlSFOpen', 'CtrlSFToggle']})
  call dein#add('easymotion/vim-easymotion')
  call dein#add('godlygeek/tabular',                      {'lazy': 1, 'on_cmd': 'Tabularize'})
  call dein#add('h1mesuke/vim-alignta',                   {'lazy': 1, 'on_cmd': 'Alignta'})
  call dein#add('haya14busa/vim-asterisk',                {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-metarepeat',              {'lazy': 1, 'on_map': ['go', 'g.']})
  call dein#add('haya14busa/vim-textobj-function-syntax', {'lazy': 1, 'depends': 'vim-textobj-function'})
  call dein#add('junegunn/vim-easy-align',                {'lazy': 1, 'on_cmd': 'EasyAlign'})
  call dein#add('justinmk/vim-sneak')
  call dein#add('kana/vim-operator-replace',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('kana/vim-textobj-entire',                {'lazy': 1, 'on_map': {'ox': ['ie', 'ae']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-fold',                  {'lazy': 1, 'on_map': {'ox': ['iz', 'az']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-function',              {'lazy': 1, 'on_map': {'ox': ['if', 'af', 'iF', 'aF']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-indent',                {'lazy': 1, 'on_map': {'ox': ['ai', 'ii', 'aI',  'iI']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-line',                  {'lazy': 1, 'on_map': {'ox': ['al', 'il']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-user')
  call dein#add('machakann/vim-sandwich',                 {'lazy': 1, 'on_map': {'nv': ['sa', 'sr', 'sd'], 'o': ['ib', 'is', 'ab', 'as']}, 'hook_source': 'call Hook_on_post_source_sandwich()'})
  call dein#add('mattn/vim-textobj-url',                  {'lazy': 1, 'on_map': {'ox': ['au', 'iu']}, 'depends': 'vim-textobj-user'})
  call dein#add('mileszs/ack.vim',                        {'lazy': 1, 'on_cmd': 'Ack'})
  call dein#add('mopp/vim-operator-convert-case')
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('osyo-manga/vim-jplus',                   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/accelerated-jk',                   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/clever-f.vim')
  call dein#add('rhysd/vim-textobj-ruby',                 {'lazy': 1, 'on_ft': 'ruby', 'depends': 'vim-textobj-user'})
  call dein#add('terryma/vim-expand-region',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('terryma/vim-multiple-cursors')
  call dein#add('thinca/vim-qfreplace',                   {'lazy': 1, 'on_cmd': 'Qfreplace'})
  call dein#add('tommcdo/vim-exchange',                   {'lazy': 1, 'on_map': {'n': ['cx', 'cxc', 'cxx'], 'x': ['X']}})
  call dein#add('tomtom/tcomment_vim',                    {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-speeddating',                  {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('vim-scripts/Align',                      {'lazy': 1, 'on_cmd': 'Align'})
  " }}}3

  " Appearance {{{3
  call dein#add('AndrewRadev/linediff.vim',       {'lazy': 1, 'on_cmd': ['Linediff', 'LinediffReset']})
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Yggdroot/indentLine',            {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('haya14busa/vim-operator-flashy', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('itchyny/lightline.vim')
  call dein#add('itchyny/vim-highlighturl')
  call dein#add('itchyny/vim-parenmatch')
  call dein#add('lambdalisue/smartcl.vim')
  call dein#add('luochen1990/rainbow')
  call dein#add('maximbaz/lightline-ale')
  call dein#add('mhinz/vim-startify')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('osyo-manga/vim-brightest')
  call dein#add('t9md/vim-choosewin',             {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('t9md/vim-quickhl',               {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-zenspace')
  " }}}3

  " tmux {{{3
  call dein#add('christoomey/vim-tmux-navigator')
  " }}}3

  " Util {{{3
  " call dein#add('thinca/vim-quickrun',                 {'lazy': 1, 'on_cmd': 'QuickRun'})
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bfredl/nvim-miniyank')
  call dein#add('bogado/file-line')
  call dein#add('dietsche/vim-lastplace')
  call dein#add('haya14busa/vim-open-googletranslate', {'lazy': 1, 'on_cmd': 'OpenGoogleTranslate'})
  call dein#add('janko-m/vim-test',                    {'lazy': 1, 'on_cmd': ['TestNearest','TestFile','TestSuite','TestLast','TestVisit']})
  call dein#add('kana/vim-gf-user')
  call dein#add('kana/vim-niceblock',                  {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('kana/vim-operator-user')
  call dein#add('konfekt/fastfold')
  call dein#add('lambdalisue/session.vim',             {'lazy': 1, 'on_cmd': ['SessionSave', 'SessionOpen', 'SessionRemove', 'SessionList', 'SessionClose']})
  call dein#add('lambdalisue/vim-manpager',            {'lazy': 1, 'on_cmd': ['Man', 'MANPAGER'], 'depends': 'vim-plugin-AnsiEsc'})
  call dein#add('lambdalisue/vim-pager',               {'lazy': 1, 'on_cmd': 'PAGER', 'depends': 'vim-plugin-AnsiEsc'})
  call dein#add('majutsushi/tagbar',                   {'lazy': 1, 'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('mattn/webapi-vim')
  call dein#add('mbbill/undotree',                     {'lazy': 1, 'on_cmd': 'UndotreeToggle'})
  call dein#add('mtth/scratch.vim',                    {'lazy': 1, 'on_cmd': ['Scratch', 'ScratchInsert', 'ScratchPreview', 'ScratchSelection']})
  call dein#add('nonylene/vim-keymaps')
  call dein#add('osyo-manga/vim-gift')
  call dein#add('pocke/vim-automatic',                 {'depends': 'vim-gift'})
  call dein#add('powerman/vim-plugin-AnsiEsc')
  call dein#add('qpkorr/vim-bufkill')
  call dein#add('simeji/winresizer',                   {'lazy': 1, 'on_cmd': 'WinResizerStartResize'})
  call dein#add('szw/vim-maximizer',                   {'lazy': 1, 'on_cmd': 'MaximizerToggle'})
  call dein#add('thinca/vim-localrc')
  call dein#add('thinca/vim-ref',                      {'lazy': 1, 'on_cmd': 'Ref'})
  call dein#add('tpope/vim-dispatch',                  {'lazy': 1, 'on_cmd': ['Dispatch', 'Focus', 'Start']})
  call dein#add('tweekmonster/startuptime.vim',        {'lazy': 1, 'on_cmd': 'StartupTime'})
  call dein#add('tyru/capture.vim',                    {'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('tyru/open-browser.vim',               {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('tyru/vim-altercmd')
  call dein#add('wesQ3/vim-windowswap',                {'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  call dein#add('yssl/QFEnter')
  " }}}3

  " develop {{{3
  call dein#add('haya14busa/vim-debugger', {'lazy': 1, 'on_func': 'debugger#init'})
  call dein#add('thinca/vim-editvar',      {'lazy': 1, 'on_cmd': 'Editvar', 'on_func': 'editvar#open'})
  call dein#add('thinca/vim-prettyprint',  {'lazy': 1, 'on_cmd': ['PrettyPrint', 'PP'], 'on_func': ['PrettyPrint', 'PP']})
  call dein#add('tweekmonster/exception.vim')
  call dein#add('vim-jp/vital.vim',        {'lazy': 1, 'on_cmd': 'Vitalize'})
  " }}}3

  " Library {{{3
  " call dein#add('Shougo/vimproc.vim', {'build': 'make'})
  call dein#add('vim-scripts/L9')
  call dein#add('vim-scripts/cecutil')
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
noremap <Leader>      <Nop>
noremap <LocalLeader> <Nop>
let g:mapleader = "\<Space>"
let g:maplocalleader = '\'

" BackSpace
imap <C-h> <BS>
cmap <C-h> <BS>

"" Save
nnoremap <silent> <Leader>w :<C-u>update<CR>
nnoremap <silent> <Leader>W :<C-u>update!<CR>

"" Cursor
noremap 0 ^
noremap ^ 0

"" Automatically indent with i
nnoremap <expr> i len(getline('.')) ? "i" : "cc"

" Ignore registers
nnoremap x "_x

"" Buffer
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>

"" incsearch
nnoremap / /\v

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
vnoremap < <gv
vnoremap > >gv|

"" Tab
nnoremap gt :<C-u>tablast <Bar> tabedit<CR>
nnoremap gd :<C-u>tabclose<CR>
nnoremap gh :<C-u>tabprevious<CR>
nnoremap gl :<C-u>tabNext<CR>

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
" }}}2

" Set Options {{{2

" NeoVim {{{3
if has('nvim')
  let g:python_host_prog  = $HOME . '/.pyenv/shims/python2'
  let g:python3_host_prog = $HOME . '/.pyenv/shims/python3'

  set inccommand=nosplit

  tnoremap <Esc> <C-\><C-n>
  AutoCmd TermOpen * set nonumber | set norelativenumber

  " block cursor for insert
  " set guicursor=
endif
" }}}3

" Appearance {{{3
set belloff=all
set conceallevel=2
set diffopt=filler,icase,vertical
set display=lastline
set helplang=ja
set hidden
set hlsearch | nohlsearch
set laststatus=2
set list listchars=tab:^\ ,trail:_,eol:$,extends:>,precedes:<
set matchtime=1
set nocursorline
set number
set previewheight=18
set pumheight=15
set scrolloff=5
set showmatch
set showtabline=2
set spellcapcheck=
set spelllang=en,cjk
set synmaxcol=300
set virtualedit=all
" }}}3

" Enable cursorcolumn in insert mode {{{3
AutoCmd InsertEnter * setlocal cursorcolumn
AutoCmd InsertLeave * setlocal nocursorcolumn
" }}}3

" Format Options {{{
AutoCmd Filetype formatoptions setlocal formatoptions-=ro | setlocal formatoptions+=jBn
" }}}

" viminfo {{{3
set viminfo='1000
" }}}3

" Cursor {{{3
set nostartofline
" }}}3

" Indent {{{3
set autoindent
set backspace=indent,eol,start
set breakindent
set expandtab
set shiftwidth=4
set smartindent
set tabstop=4
" }}}3

" Search & Complete {{{3
set completeopt=longest,menuone,preview
set ignorecase
set regexpengine=2
set smartcase
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
" }}}3

" Folding {{{3
set foldcolumn=1
set foldenable
set foldmethod=manual
" }}}3

" history {{{3
set history=1000
set undodir=~/.vim_undo
set undofile
" }}}3

" File {{{3
set autoread
set noswapfile
set viewoptions=cursor,folds
set suffixesadd=.js,.ts,.rb
" }}}3

" Term {{{3
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
" }}}3

" Automatically Disable Paste Mode {{{3
AutoCmd InsertLeave * setlocal nopaste
" }}}3

" Highlight Annotation Comment {{{3
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|OPTIMIZE\|HACK\|REVIEW\|NOTE\|INFO\|TEMP\):')
" }}}3

" Clipboard {{{3
" set clipboard=unnamed,unnamedplus
" }}}3

" Misc {{{3
set updatetime=500
set matchpairs& matchpairs+=<:>
set langnoremap
" }}}3

" Turn off default plugins. {{{3
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
" }}}3

" }}}2

" }}}1

" Command & Function {{{1

" ToggleHiglight {{{2
function! s:toggle_highlight()
  if exists('g:syntax_on')
    syntax off
  else
    syntax enable
  endif
endfunction

command! ToggleHighlight call <SID>toggle_highlight()
" }}}2

" ToggleQuickfix {{{2
function! s:toggle_quickfix()
  let l:_ = winnr('$')
  cclose
  if l:_ == winnr('$')
    botright copen
  endif
endfunction

command! ToggleQuickfix call <SID>toggle_quickfix()
nnoremap <silent> <Leader>q :ToggleQuickfix<CR>
" }}}2

" ToggleLocationList {{{2
function! s:toggle_location_list()
  let l:_ = winnr('$')
  lclose
  if l:_ == winnr('$')
    botright lopen
  endif
endfunction

command! ToggleLocationList call <SID>toggle_location_list()
nnoremap <silent> <Leader>l :ToggleLocationList<CR>
" }}}2

" ins-completion menu {{{2
let s:compl_key_dict = {
\  char2nr("\<C-l>"): "\<C-x>\<C-l>",
\  char2nr("\<C-n>"): "\<C-x>\<C-n>",
\  char2nr("\<C-p>"): "\<C-x>\<C-p>",
\  char2nr("\<C-k>"): "\<C-x>\<C-k>",
\  char2nr("\<C-t>"): "\<C-x>\<C-t>",
\  char2nr("\<C-i>"): "\<C-x>\<C-i>",
\  char2nr("\<C-]>"): "\<C-x>\<C-]>",
\  char2nr("\<C-f>"): "\<C-x>\<C-f>",
\  char2nr("\<C-d>"): "\<C-x>\<C-d>",
\  char2nr("\<C-v>"): "\<C-x>\<C-v>",
\  char2nr("\<C-u>"): "\<C-x>\<C-u>",
\  char2nr("\<C-o>"): "\<C-x>\<C-o>",
\  char2nr('s'):      "\<C-x>s",
\  char2nr("\<C-s>"): "\<C-x>s",
\ }

let s:hint_i_ctrl_x_msg = [
\  '<C-l>: While lines',
\  '<C-n>: keywords in the current file',
\  "<C-k>: keywords in 'dictionary'",
\  "<C-t>: keywords in 'thesaurus'",
\  '<C-i>: keywords in the current and included files',
\  '<C-]>: tags',
\  '<C-f>: file names',
\  '<C-d>: definitions or macros',
\  '<C-v>: Vim command-line',
\  "<C-u>: User defined completion ('completefunc')",
\  "<C-o>: omni completion ('omnifunc')",
\  "s: Spelling suggestions ('spell')"
\ ]

function! s:hint_i_ctrl_x() abort
  echo join(s:hint_i_ctrl_x_msg, "\n")
  let c = getchar()
  return get(s:compl_key_dict, c, nr2char(c))
endfunction

inoremap <expr> <C-x> <SID>hint_i_ctrl_x()
" }}}2

" Mark & Register {{{2
function! s:hint_cmd_output(prefix, cmd) abort
  redir => str
  :execute a:cmd
  redir END
  echo str
  return a:prefix . nr2char(getchar())
endfunction

nnoremap <expr> m  <SID>hint_cmd_output('m', 'marks')
nnoremap <expr> `  <SID>hint_cmd_output('`', 'marks')
nnoremap <expr> '  <SID>hint_cmd_output("'", 'marks')
nnoremap <expr> "  <SID>hint_cmd_output('"', 'registers')
nnoremap <expr> q  <SID>hint_cmd_output('q', 'registers')
nnoremap <expr> @  <SID>hint_cmd_output('@', 'registers')
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

nnoremap <silent> gm :<C-u>tablast <Bar> call <SID>move_to_new_tab()<CR>
" }}}2

" Preserve {{{2
function! s:preserve(command)
  let l:lastsearch = @/
  let l:view = winsaveview()
  execute a:command
  let @/ = l:lastsearch
  call winrestview(l:view)
endfunction

command! -complete=command -nargs=* Preserve call <SID>preserve(<q-args>)
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

command! -buffer HelpEdit call <SID>option_to_edit()
command! -buffer HelpView call <SID>option_to_view()
" }}}2

" Accelerate {{{2
function! s:accelerate() abort
  :IndentLinesDisable
  :RainbowToggleOff
  :BrightestDisable
  :ALEDisable
endfunction

function! s:disable_accelerate() abort
  :IndentLinesEnable
  :RainbowToggleOn
  :BrightestEnable
  :ALEEnable
endfunction

command! Accelerate        call <SID>accelerate()
command! DisableAccelerate call <SID>disable_accelerate()
" }}}2

" VimShowHlGroup {{{2
command! ShowHlGroup echo synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
" }}}2
"
" }}}1

" FileType Settings {{{1

" FileType {{{2

" Intent {{{3
AutoCmd FileType javascript setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType ruby       setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType eruby      setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType python     setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType go         setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType rust       setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType json       setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType markdown   setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType html       setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType css        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType scss       setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vim        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType sh         setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType zsh        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" iskeyword {{{3
AutoCmd FileType javascript setlocal iskeyword+=$ iskeyword+=? iskeyword+=/
AutoCmd FileType vue        setlocal iskeyword+=$ iskeyword+=& iskeyword+=- iskeyword+=? iskeyword+=/
AutoCmd FileType ruby       setlocal iskeyword+=@ iskeyword+=! iskeyword+=? iskeyword+=&
AutoCmd FileType html       setlocal iskeyword+=-
AutoCmd FileType css        setlocal iskeyword+=-
AutoCmd FileType scss       setlocal iskeyword+=$ iskeyword+=& iskeyword+=-
AutoCmd FileType sh         setlocal iskeyword+=$ iskeyword+=-
AutoCmd FileType zsh        setlocal iskeyword+=$
" }}}3

" Set Filetype {{{3
AutoCmd BufNewFile,BufRead             *.js set filetype=javascript
AutoCmd BufNewFile,BufRead            *.erb set filetype=eruby
AutoCmd BufNewFile,BufRead           *.cson set filetype=coffee
AutoCmd BufNewFile,BufRead         .babelrc set filetype=json
AutoCmd BufNewFile,BufRead        .eslintrc set filetype=json
AutoCmd BufNewFile,BufRead     .stylelintrc set filetype=json
AutoCmd BufNewFile,BufRead      .prettierrc set filetype=json
AutoCmd BufNewFile,BufRead    .tern-project set filetype=json
AutoCmd BufNewFile,BufRead           .pryrc set filetype=ruby
AutoCmd BufNewFile,BufRead          Gemfile set filetype=ruby
AutoCmd BufNewFile,BufRead      Vagrantfile set filetype=ruby
AutoCmd BufNewFile,BufRead       Schemafile set filetype=ruby
AutoCmd BufNewFile,BufRead .gitconfig.local set filetype=gitconfig

" Reassign Filetype
AutoCmd BufWritePost *
\ if &filetype ==# '' && exists('b:ftdetect') |
\  unlet! b:ftdetect |
\  filetype detect |
\ endif
" }}}3

" Completion {{{3
set completefunc=autoprogramming#complete

AutoCmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
AutoCmd FileType typescript setlocal omnifunc=tsuquyomi#complete
AutoCmd FileType ruby       setlocal omnifunc=rubycomplete#Complete
AutoCmd FileType html,eruby setlocal omnifunc=htmlcomplete#CompleteTags
AutoCmd FileType python     setlocal omnifunc=pythoncomplete#Complete
AutoCmd FileType css        setlocal omnifunc=csscomplete#CompleteCSS
AutoCmd FileType scss       setlocal omnifunc=csscomplete#CompleteCSS

AutoCmd FileType javascript setlocal dict=~/dotfiles/.vim/dict/javascript.dict
AutoCmd FileType typescript setlocal dict=~/dotfiles/.vim/dict/javascript.dict
AutoCmd FileType ruby,eruby setlocal dict=~/dotfiles/.vim/dict/rails.dict
" }}}3


" }}}2

" HTML & eruby {{{2
augroup HTML
  autocmd!
  autocmd FileType html,eruby call <SID>map_html_keys()
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

    let b:match_words .= ',{:},(:)'
  endfunction
augroup END
" }}}2

" vim {{{2
AutoCmd FileType vim set keywordprg=:help
" }}}2

" shell {{{2
AutoCmd FileType sh,bash,zsh set keywordprg=man
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

  inoremap <silent> <buffer> <expr> <CR>  pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
  inoremap <silent> <buffer> <expr> <Tab> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()

  inoremap <buffer> <expr> <C-r><C-w> "\<C-c>\<C-r>\<C-w>" . &g:cedit

  " nnoremap <silent> <buffer> dd :<C-u>rviminfo<CR>:call histdel(getcmdwintype(), line('.') - line('$'))<CR>:wviminfo!<CR>dd
  startinsert!
endfunction
" }}}1

" Plugin Settings {{{1

" Eager Load {{{2

" altercmd {{{3
if dein#tap('vim-altercmd')
  call altercmd#load()

  AlterCommand! <cmdwin> hi            ToggleHighlight
  AlterCommand! <cmdwin> sp            setlocal<Space>spell!
  AlterCommand! <cmdwin> show[hlgroup] ShowHlGroup
  AlterCommand! <cmdwin> acc[elarate]  Accelerate
  AlterCommand! <cmdwin> dacc[elarate] DisableAccelerate
endif
" }}}3

" }}}2

" Plugin Manager {{{2

" Dein {{{3
AlterCommand! <cmdwin> dein Dein
" }}}3

" }}}2

" Language {{{2

" ALE {{{3
let g:ale_linters = {
\ 'javascript': ['eslint', 'flow'],
\ 'typescript': ['tslint', 'tsserver'],
\ 'vue':        ['eslint', 'flow'],
\ 'ruby':       ['rubocop'],
\ 'eruby':      [],
\ 'python':     ['autopep8', 'flake8', 'isort', 'mypy', 'yapf'],
\ 'go':         ['golint'],
\ 'rust':       ['rustc', 'cargo', 'rustfmt', 'rls'],
\ 'json':       ['jsonlint', 'jq'],
\ 'html':       ['htmlhint'],
\ 'css':        ['stylelint'],
\ 'scss':       ['stylelint'],
\ 'vim':        ['vint'],
\ 'sh':         ['shell', 'shellcheck'],
\ 'bash':       ['shell', 'shellcheck'],
\ 'zsh':        ['shell', 'shellcheck'],
\ }
let g:ale_ruby_rubocop_executable = 'bundle'

let g:ale_linter_aliases = {
\ 'vue'  : 'css',
\ 'eruby': 'html',
\ }

let g:ale_set_highlights           = 0
let g:ale_sign_column_always       = 1
let g:ale_change_sign_column_color = 1
let g:ale_lint_on_text_changed     = 'never'
let g:ale_lint_on_insert_leave     = 0
let g:ale_echo_msg_format          = '[%linter%] %s'
" }}}3

" autoformat {{{3
noremap <silent> <Leader>a :<C-u>Autoformat<CR>

" ruby
let g:formatters_ruby = ['rubocop']

" eruby
let g:formatdef_htmlbeautifier = '"cat | htmlbeautifier"'
let g:formatters_eruby         = ['htmlbeautifier']

" css & scss
let g:formatdef_prettier = '"cat | prettier --stdin"'
let g:formatters_css  = ['prettier']
let g:formatters_scss = ['prettier']

" vue.js
" Prettierはvim-prettierに任せる
let g:formatdef_vue_format = '"cat | htmlbeautifier"'
let g:formatters_vue       = ['vue_format']

" json
let g:formatdef_jq    = '"cat | jq ."'
let g:formatters_json = ['fixjson', 'jq']

" python
let g:formatters_python = ['autopep8', 'yapf']
" }}}3

" echodoc {{{3
set cmdheight=2
let g:echodoc_enable_at_startup = 1
" }}}3

" gen_tags {{{3
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#gtags_auto_gen = 1
" }}}3

" go {{{3
let g:go_fmt_command = 'goimports'

let g:go_highlight_functions         = 1
let g:go_highlight_methods           = 1
let g:go_highlight_structs           = 1
let g:go_highlight_interfaces        = 1
let g:go_highlight_operators         = 1
let g:go_highlight_build_constraints = 1
let g:go_addtags_transform           = 'camelcase'
" }}}3

" html5 {{{3
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete          = 1
let g:html5_microdata_attributes_complete     = 1
let g:html5_aria_attributes_complete          = 1
" }}}3

" javascript-libraries-syntax {{{3
let g:used_javascript_libs = 'jquery,react,vue'
" }}}3

" jsdoc {{{3
let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_input_description  = 1
let g:jsdoc_underscore_private = 1
let g:jsdoc_enable_es6         = 1
" }}}3

" json {{{3
let g:vim_json_syntax_conceal = 0
" }}}3

" markdown {{{3
let g:vim_markdown_folding_disabled     = 1
let g:vim_markdown_conceal              = 0
let g:vim_markdown_frontmatter          = 1
let g:vim_markdown_json_frontmatter     = 1
let g:vim_markdown_new_list_item_indent = 2
" }}}3

" marked {{{3
AlterCommand! <cmdwin> mark[ed] MarkedOpen
" }}}3

" prettier {{{3
let g:prettier#exec_cmd_async = 1

function! s:prettier_settings()
  let g:prettier#exec_cmd_path = $HOME . '/dotfiles/node_modules/.bin/prettier'
  nnoremap <silent> <buffer> <Leader>a :<C-u>Prettier<CR>
endfunction

function! s:prettier_vue_settings()
  let g:prettier#exec_cmd_path = '~/dotfiles/node_modules/.bin/vue-prettier'
  nnoremap <silent> <buffer> <Leader>a :<C-u>Autoformat <Bar> Prettier<CR>
endfunction

AutoCmd FileType javascript call <SID>prettier_settings()
AutoCmd FileType vue        call <SID>prettier_vue_settings()
" }}}3

" ruby {{{3
let g:rubycomplete_rails                = 1
let g:rubycomplete_buffer_loading       = 1
let g:rubycomplete_classes_in_global    = 1
let g:rubycomplete_include_object       = 1
let g:rubycomplete_include_object_space = 1
" }}}3

" rust {{{3
let g:rustfmt_autosave = 1
" }}}3

" typescript {{{3
let g:typescript_indent_disable = 1
" }}}3

" vim {{{3
let g:vimsyntax_noerror = 1
let g:vim_indent_cont   = 0
" }}}3

" vue {{{
let g:vue_disable_pre_processors = 1
AutoCmd FileType vue syntax sync fromstart
" }}}

" zsh {{{3
let g:zsh_fold_enable = 1
" }}}3

" }}}2

" Completion & Fuzzy Finder & vimfiler {{{2

" Denite & Unite {{{3

AlterCommand! <cmdwin> d[enite] Denite
AlterCommand! <cmdwin> dr       Denite<Space>-resume

if dein#tap('denite.nvim')
  " Denite

  "" highlight
  call denite#custom#option('default', 'prompt', '>')
  call denite#custom#option('default', 'mode', 'insert')
  call denite#custom#option('default', 'highlight_matched', 'Keyword')
  call denite#custom#option('default', 'highlight_mode_normal', 'CursorLineNr')
  call denite#custom#option('default', 'highlight_mode_insert', 'CursorLineNr')
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
  call denite#custom#source('_',        'matchers', ['matcher/fuzzy'])
  call denite#custom#source('line',     'matchers', ['matcher/regexp'])
  call denite#custom#source('file_mru', 'matchers', ['matcher/fuzzy', 'matcher/project_files'])

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

  call denite#custom#var('file_rec', 'command', [ 'rg', '--files', '--glob', '!.git', ''])
  call denite#custom#var('grep', 'command', ['rg'])
  call denite#custom#var('grep', 'default_opts', ['--vimgrep', '--no-heading'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])

  "" file & buffer
  " nnoremap <silent> <Leader>p :<C-u>Denite file_rec -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Denite buffer -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>m :<C-u>Denite file_mru -direction=topleft -mode=insert<CR>

  "" grep
  nnoremap <silent> <Leader>/         :<C-u>Denite line<CR>
  nnoremap <silent> <Leader>*         :<C-u>DeniteCursorWord line<CR>
  nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep<CR>
  nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep<CR>

  "" outline
  " nnoremap <silent> <Leader>o :<C-u>Denite outline<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Denite jump change -direction=botright<CR>

  "" ctags & gtags
  nnoremap <silent> <Leader><C-]>         :<C-u>DeniteCursorWord gtags_context -direction=botright<CR>
  " nnoremap <silent> <Leader><Leader><C-]> :<C-u>DeniteCursorWord gtags_grep -direction=botright<CR>

  "" yank
  nnoremap <silent> <SID>(ctrlp) :<C-u>Denite miniyank<CR>

  "" resume
  nnoremap <silent> <Leader>dr :<C-u>Denite -resume<CR>
endif

" AlterCommand! <cmdwin> u[nite] Unite

" if dein#tap('unite.vim')
"   " Unite
"
"   "" keymap
"   function! s:unite_settings()
"     nnoremap <silent> <buffer> <C-n>      j
"     nnoremap <silent> <buffer> <C-p>      k
"     nnoremap <silent> <buffer> <C-j>      <C-w>j
"     nnoremap <silent> <buffer> <C-k>      <C-w>k
"     nnoremap <silent> <buffer> <Esc><Esc> q
"     inoremap <silent> <buffer> <Esc><Esc> <Esc>q
"     imap     <silent> <buffer> <C-w>      <Plug>(unite_delete_backward_path)
"   endfunction
"
"   AutoCmd FileType unite call <SID>unite_settings()
"
"   " file & buffer
"   call unite#custom#source('buffer,file_rec,file_rec/async,file_rec/git', 'matchers', ['converter_relative_word', 'matcher_fuzzy'])
"   call unite#custom#source('neomru/file', 'matchers', ['converter_relative_word', 'matcher_project_files', 'matcher_fuzzy'])
"   call unite#custom#source('file_mru', 'matchers', ['converter_relative_word', 'matcher_fuzzy'])
"
"   let g:unite_source_rec_max_cache_files = 10000
"   let g:unite_enable_auto_select = 0
"   let g:unite_source_rec_async_command = ['rg', '--files', '--follow', '--glob', '!.git/*']
"
"   nnoremap <silent> <Leader>p :<C-u>Unite file_rec/async:!<CR>
"   nnoremap <silent> <Leader>m :<C-u>Unite neomru/file<CR>
"   nnoremap <silent> <Leader>M :<C-u>Unite file_mru<CR>
"   nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:!<CR>
"   nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>
"
"   " grep
"   let g:unite_source_grep_command = 'rg'
"   let g:unite_source_grep_default_opts = '--vimgrep --hidden'
"   let g:unite_source_grep_recursive_opt = ''
"
"   call unite#custom_source('line', 'sorters', 'sorter_reverse')
"   call unite#custom_source('grep', 'sorters', 'sorter_reverse')
"   nnoremap <silent> <Leader>/          :<C-u>Unite line -direction=botright -buffer-name=search-buffer -no-quit<CR>
"   nnoremap <silent> <Leader>//         :<C-u>Unite line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
"   nnoremap <silent> <Leader>*          :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit<CR>
"   nnoremap <silent> <Leader>**         :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
"   nnoremap <silent> <Leader><Leader>/  :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
"   nnoremap <silent> <Leader><Leader>// :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
"   nnoremap <silent> <Leader><Leader>*  :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
"   nnoremap <silent> <Leader><Leader>** :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
"
"   " yank
"   nnoremap <silent> <Leader><Leader>p :<C-u>Unite yankround<CR>
" endif
" }}}3

" fzf {{{3
" Delete History
" function! s:fzf_delete_history() abort
"   call fzf#run({
"   \ 'source': <SID>command_history(),
"   \ 'options': '--multi --prompt="DeleteHistory>"',
"   \ 'sink': function('<SID>delete_history'),
"   \ 'window': 'top split new'
"   \ })
"   execute 'resize' float2nr(0.3 * &lines)
" endfunction
"
" function! s:command_history() abort
"   let l:out = ''
"   redir => l:out
"   silent! history
"   redir END
"
"   return map(reverse(split(l:out, '\n')), "substitute(substitute(v:val, '\^\>', '', ''), '\^\\\s\\\+', '', '')")
" endfunction
"
" function! s:delete_history(command) abort
"   call histdel(':', str2nr(get(split(a:command, '  '), 0)))
"   wviminfo
" endfunction
"
" command! FzfDeleteHistory call s:fzf_delete_history()
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
nnoremap <silent> <leader>gf :FzfOpenGf<CR>
" }}}3

" fzf-preview {{{3
AlterCommand! <cmdwin> fg[rep] ProjectGrepPreview

let g:fzf_preview_filelist_command = 'rg --files --hidden --follow --glob "!.git/*"'

nnoremap <silent> <Leader>p :<C-u>ProjectFilesPreview<CR>
nnoremap <silent> <Leader>b :<C-u>BuffersPreview<CR>
nnoremap <silent> <Leader>o :<C-u>ProjectOldFilesPreview<CR>
nnoremap <silent> <Leader>O :<C-u>OldFilesPreview<CR>
" }}}3

" deoplete.nvim && neosnippet.vim {{{3
if dein#tap('deoplete.nvim') && dein#tap('neosnippet')
  let g:deoplete#enable_at_startup          = 1
  let g:deoplete#enable_smart_case          = 1
  let g:deoplete#enable_camel_case          = 1
  let g:deoplete#enable_ignore_case         = 0
  let g:deoplete#auto_complete_delay        = 0
  let g:deoplete#enable_refresh_always      = 1
  let g:deoplete#file#enable_buffer_path    = 1
  let g:deoplete#max_list                   = 10000
  let g:deoplete#auto_complete_start_length = 1
  let g:deoplete#tag#cache_limit_size       = 5000000

  inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()

  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)

  call deoplete#custom#source('_', 'converters', [
  \ 'converter_remove_paren',
  \ 'converter_remove_overlap',
  \ 'converter_truncate_abbr',
  \ 'converter_truncate_menu',
  \ 'converter_auto_delimiter',
  \ ])

  let g:deoplete#sources#go#gocode_binary = $GOPATH . '/bin/gocode'
  let g:deoplete#sources#go#sort_class    = ['package', 'func', 'type', 'var', 'const']

  " call deoplete#custom#source('LanguageClient', 'rank', 1100)
  call deoplete#custom#source('neosnippet',     'rank',  1100)
  call deoplete#custom#source('around',         'rank',  1000)
  call deoplete#custom#source('buffer',         'rank',  900)
  call deoplete#custom#source('gtags',          'rank',  800)
  call deoplete#custom#source('tern',           'rank',  700)
  call deoplete#custom#source('flow',           'rank',  700)
  call deoplete#custom#source('ruby',           'rank',  700)
  call deoplete#custom#source('jedi',           'rank',  700)
  call deoplete#custom#source('go',             'rank',  700)
  call deoplete#custom#source('emoji',          'rank',  700)
  call deoplete#custom#source('vim',            'rank',  700)
  call deoplete#custom#source('syntax',         'rank',  600)
  call deoplete#custom#source('tag',            'rank',  500)
  call deoplete#custom#source('member',         'rank',  500)
  call deoplete#custom#source('omni',           'rank',  400)
  call deoplete#custom#source('tmux-complete',  'rank',  300)
  call deoplete#custom#source('file',           'rank',  300)
  call deoplete#custom#source('dictionary',     'rank',  200)
  call deoplete#custom#source('look',           'rank',  100)

  " call deoplete#custom#source('LanguageClient', 'mark', '[LC]')
  call deoplete#custom#source('neosnippet',     'mark', '[snippet]')
  call deoplete#custom#source('around',         'mark', '[around]')
  call deoplete#custom#source('buffer',         'mark', '[buffer]')
  call deoplete#custom#source('gtags',          'mark', '[gtags]')
  call deoplete#custom#source('syntax',         'mark', '[syntax]')
  call deoplete#custom#source('tag',            'mark', '[tag]')
  call deoplete#custom#source('member',         'mark', '[member]')
  call deoplete#custom#source('omni',           'mark', '[omni]')
  call deoplete#custom#source('file',           'mark', '[file]')
  call deoplete#custom#source('dictionary',     'mark', '[dict]')

  call deoplete#custom#source('tern',           'mark', '[tern]')
  call deoplete#custom#source('flow',           'mark', '[flow]')
  call deoplete#custom#source('ruby',           'mark', '[ruby]')
  call deoplete#custom#source('jedi',           'mark', '[jedi]')
  call deoplete#custom#source('go',             'mark', '[go]')
  call deoplete#custom#source('emoji',          'mark', '[emoji]')
  call deoplete#custom#source('vim',            'mark', '[vim]')
  call deoplete#custom#source('tmux-complete',  'mark', '[tmux]')

  let s:deoplete_default_sources = ['neosnippet', 'around', 'gtags', 'tag', 'member', 'buffer', 'omni', 'syntax', 'file', 'dictionary', 'look'] " LanguageClient
  let g:deoplete#sources = {}
  let g:deoplete#sources._          = s:deoplete_default_sources
  " let g:deoplete#sources.javascript = s:deoplete_default_sources + ['LanguageClient', 'ternjs', 'flow']
  " let g:deoplete#sources.typescript = s:deoplete_default_sources + ['LanguageClient', 'ternjs']
  " let g:deoplete#sources.vue        = s:deoplete_default_sources + ['LanguageClient', 'ternjs']
  let g:deoplete#sources.javascript = s:deoplete_default_sources + ['ternjs', 'flow']
  let g:deoplete#sources.typescript = s:deoplete_default_sources + ['ternjs']
  let g:deoplete#sources.vue        = s:deoplete_default_sources + ['ternjs']
  let g:deoplete#sources.ruby       = s:deoplete_default_sources + ['ruby']
  let g:deoplete#sources.eruby      = s:deoplete_default_sources + ['ruby']
  let g:deoplete#sources.python     = s:deoplete_default_sources + ['jedi']
  let g:deoplete#sources.go         = s:deoplete_default_sources + ['go']
  " let g:deoplete#sources.rust       = s:deoplete_default_sources + ['LanguageClient']
  let g:deoplete#sources.markdown   = s:deoplete_default_sources + ['emoji']
  let g:deoplete#sources.html       = s:deoplete_default_sources
  let g:deoplete#sources.xml        = s:deoplete_default_sources
  let g:deoplete#sources.css        = s:deoplete_default_sources
  let g:deoplete#sources.scss       = s:deoplete_default_sources
  let g:deoplete#sources.vim        = s:deoplete_default_sources + ['vim']
  let g:deoplete#sources.zsh        = s:deoplete_default_sources
  let g:deoplete#sources.gitcommit  = s:deoplete_default_sources + ['emoji']

  let g:deoplete#omni#input_patterns            = {}
  let g:deoplete#omni#input_patterns._          = ''
  let g:deoplete#omni#input_patterns.javascript = ''
  let g:deoplete#omni#input_patterns.typescript = ''
  let g:deoplete#omni#input_patterns.vue        = ''
  let g:deoplete#omni#input_patterns.ruby       = ''
  let g:deoplete#omni#input_patterns.eruby      = ''
  let g:deoplete#omni#input_patterns.python     = ''
  let g:deoplete#omni#input_patterns.go         = ''
  let g:deoplete#omni#input_patterns.rust       = ''
  let g:deoplete#omni#input_patterns.markdown   = ''
  let g:deoplete#omni#input_patterns.html       = ''
  let g:deoplete#omni#input_patterns.xml        = ''
  let g:deoplete#omni#input_patterns.css        = ''
  let g:deoplete#omni#input_patterns.scss       = ''
  let g:deoplete#omni#input_patterns.vim        = ''
  let g:deoplete#omni#input_patterns.zsh        = ''
  let g:deoplete#omni#input_patterns.gitcommit  = ''
  " let g:deoplete#omni#input_patterns.javascript = '[^. \t0-9]\.([a-zA-Z_]\w*)?'
  " let g:deoplete#omni#input_patterns.typescript = '[^. \t0-9]\.([a-zA-Z_]\w*)?'
  " let g:deoplete#omni#input_patterns.vue        = ['[^. \t0-9]\.([a-zA-Z_]\w*)?', '<[^>]*', '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]']
  " let g:deoplete#omni#input_patterns.ruby       = '[^. *\t]\.\w*\|\h\w*::'
  " let g:deoplete#omni#input_patterns.eruby      = ''
  " let g:deoplete#omni#input_patterns.python     = ['[^. ]\.\w*', 'import \w*', 'from \w*']
  " let g:deoplete#omni#input_patterns.go         = '[^.[:digit:] *\t]\.\w*'
  " let g:deoplete#omni#input_patterns.rust       = '(\.|::)\w*'
  " let g:deoplete#omni#input_patterns.markdown   = ''
  " let g:deoplete#omni#input_patterns.html       = '<[^>]*'
  " let g:deoplete#omni#input_patterns.xml        = '<[^>]*'
  " let g:deoplete#omni#input_patterns.css        = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
  " let g:deoplete#omni#input_patterns.scss       = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
  " let g:deoplete#omni#input_patterns.vim        = '\.\w*'
  " let g:deoplete#omni#input_patterns.zsh        = '[^. \t0-9]\.\w*'
  " let g:deoplete#omni#input_patterns.gitcommit  = '.+'

  let s:deoplete_default_omni_sources      = []
  let g:deoplete#omni#functions            = {}
  let g:deoplete#omni#functions._          = s:deoplete_default_omni_sources
  let g:deoplete#omni#functions.javascript = s:deoplete_default_omni_sources + ['jspc#omni', 'javascriptcomplete#CompleteJS']
  let g:deoplete#omni#functions.typescript = s:deoplete_default_omni_sources + ['tsuquyomi#complete', 'jspc#omni', 'javascriptcomplete#CompleteJS']
  let g:deoplete#omni#functions.vue        = s:deoplete_default_omni_sources + ['jspc#omni', 'javascriptcomplete#CompleteJS', 'htmlcomplete#CompleteTags', 'csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.ruby       = s:deoplete_default_omni_sources + ['rubycomplete#Complete']
  let g:deoplete#omni#functions.eruby      = s:deoplete_default_omni_sources + ['rubycomplete#Complete', 'htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.python     = s:deoplete_default_omni_sources + ['pythoncomplete#Complete']
  let g:deoplete#omni#functions.go         = s:deoplete_default_omni_sources
  let g:deoplete#omni#functions.rust       = s:deoplete_default_omni_sources
  let g:deoplete#omni#functions.html       = s:deoplete_default_omni_sources + ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.xml        = s:deoplete_default_omni_sources + ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.css        = s:deoplete_default_omni_sources + ['csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.scss       = s:deoplete_default_omni_sources + ['csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.vim        = s:deoplete_default_omni_sources
  let g:deoplete#omni#functions.zsh        = s:deoplete_default_omni_sources
endif
" }}}3

" LanguageClient {{{3
" let g:LanguageClient_autoStart = 1
" let g:LanguageClient_serverCommands = {
" \ 'vue': ['vls'],
" \ 'html': [],
" \ 'css': [],
" \ 'javascript': ['javascript-typescript-stdio'],
" \ 'typescript': ['javascript-typescript-stdio'],
" \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
" \ }
" }}}3

" }}}2

" Git {{{2

" agit {{{3
AlterCommand! <cmdwin> agit       Agit
AlterCommand! <cmdwin> agitf[ile] AgitFile

let g:agit_preset_views = {
\ 'default': [
\   {'name': 'log'},
\   {
\     'name':   'stat',
\     'layout': 'botright vnew'
\   },
\   {
\     'name':   'diff',
\     'layout': 'belowright {winheight(".") * 3 / 4}new'
\   },
\ ],
\ 'file': [
\   {'name': 'filelog'},
\   {
\    'name':   'stat',
\    'layout': 'botright vnew'
\   },
\   {
\     'name':   'diff',
\     'layout': 'belowright {winheight(".") * 3 / 4}new'
\   },
\ ],
\ }
" }}}3

" committia {{{3
let g:committia_open_only_vim_starting = 0
let g:committia_hooks                  = {}
" }}}3

" git-gutter {{{3
AlterCommand! <cmdwin> gah GitGutterStageHunk
AlterCommand! <cmdwin> grh GitGutterUndoHunk

let g:gitgutter_map_keys = 0
nmap gn <Plug>GitGutterNextHunk
nmap gp <Plug>GitGutterPrevHunk
" }}}3

" git-switcher {{{3
AlterCommand! <cmdwin> gss GswSave
AlterCommand! <cmdwin> gsl GswLoad
" }}}3

" gina {{{3
AlterCommand! <cmdwin> git   Gina
AlterCommand! <cmdwin> gina  Gina
AlterCommand! <cmdwin> gs    Gina<Space>status
AlterCommand! <cmdwin> ga    Gina<Space>patch
AlterCommand! <cmdwin> gci   Gina<Space>commit
AlterCommand! <cmdwin> gd    Gina<Space>diff
AlterCommand! <cmdwin> gdc   Gina<Space>diff<Space>--cached
AlterCommand! <cmdwin> blame Gina<Space>blame

if dein#tap('gina.vim')
  call gina#custom#command#option('status', '--short')

  call gina#custom#command#option('/\%(status\|commit\|branch\)', '--opener', 'split')
  call gina#custom#command#option('/\%(diff\|log\)', '--opener', 'vsplit')

  call gina#custom#command#option('/\%(status\|changes\)', '--ignore-submodules')
  call gina#custom#command#option('status', '--branch')
  call gina#custom#command#option('branch', '-v', 'v')
  call gina#custom#command#option('branch', '--all')

  call gina#custom#mapping#nmap('status', '<C-j>', '<C-w>j',                {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('status', '<C-k>', '<C-w>k',                {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('status', '<C-^>', ':<C-u>Gina commit<CR>', {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('commit', '<C-^>', ':<C-u>Gina status<CR>', {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('branch', '<C-k>', '<C-w>k', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('branch', 'g<CR>', '<Plug>(gina-commit-checkout-track)')
  call gina#custom#mapping#nmap('branch', 'nn',    '<Plug>(gina-branch-new)')
  call gina#custom#mapping#nmap('branch', 'dd',    '<Plug>(gina-branch-delete)')
  call gina#custom#mapping#nmap('branch', 'DD',    '<Plug>(gina-branch-delete-force)')

  call gina#custom#mapping#nmap('blame', '<C-l>', '<C-w>l', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', '<C-r>', '<Plug>(gina-blame-redraw)', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', 'j', 'j<Plug>(gina-blame-echo)')
  call gina#custom#mapping#nmap('blame', 'k', 'k<Plug>(gina-blame-echo)')

  call gina#custom#action#alias('/\%(blame\|log\|reflog\)', 'preview', 'topleft show:commit:preview')
  call gina#custom#mapping#nmap('/\%(blame\|log\|reflog\)', 'p', ":<C-u>call gina#action#call('preview')<CR>", {'noremap': 1, 'silent': 1})

  call gina#custom#execute('/\%(ls\|log\|reflog\|grep\)', 'setlocal noautoread')
endif
" }}}3

" }}}2

" filer {{{2

" vimfiler {{{3
" let g:vimfiler_safe_mode_by_default = 0
" let g:vimfiler_execute_file_list    = {'jpg': 'open', 'jpeg': 'open', 'gif': 'open', 'png': 'open'}
" let g:vimfiler_enable_auto_cd       = 1
" let g:vimfiler_ignore_pattern       = '^\%(.git\|.DS_Store\)$'
" let g:vimfiler_trashbox_directory   = '~/.Trash'
" nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer -split -winwidth=35 -simple<CR>
" nnoremap <silent> <Leader>E :<C-u>VimFilerExplorer -find -split -winwidth=35 -simple<CR>
"
" function! s:vimfiler_settings()
"   nmap     <buffer> R     <Plug>(vimfiler_redraw_screen)
"   nnoremap <silent> <buffer> <C-l> <C-w>l
"   nnoremap <silent> <buffer> <C-j> <C-w>j
" endfunction
"
" AutoCmd FileType vimfiler call s:vimfiler_settings()
" }}}3

" vaffle {{{3
AlterCommand! <cmdwin> va[fle] Vaffle

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:vaffle_open_selected_split_position = ''
let g:vaffle_open_selected_vsplit_position = ''

command! VaffleExplorer vertical topleft vsplit +Vaffle | vertical resize 35 | setlocal winfixwidth
command! VaffleExplorerCurrent vertical topleft vsplit +Vaffle\ %:h | vertical resize 35 | setlocal winfixwidth

nnoremap <silent> <Leader>e :VaffleExplorer<CR>
nnoremap <silent> <Leader>E :VaffleExplorerCurrent<CR>

function! s:customize_vaffle_mappings() abort
  nmap <silent> <buffer> <nowait> <Space> <Plug>(vaffle-toggle-current)
  nmap <silent> <buffer> <nowait> s       <Plug>(vaffle-open-selected-split)
  nmap <silent> <buffer> <nowait> v       <Plug>(vaffle-open-selected-vsplit)
endfunction

AutoCmd Filetype vaffle call <SID>customize_vaffle_mappings()
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{3
if dein#tap('accelerated-jk')
  nmap j <Plug>(accelerated_jk_j)
  nmap k <Plug>(accelerated_jk_k)
endif
" }}}3

" ack {{{3
AlterCommand! <cmdwin> ag  Ack!
AlterCommand! <cmdwin> ack Ack!

let g:ackprg = 'ag --vimgrep'
" }}}3

" ctrlsf {{{3
AlterCommand! <cmdwin> grep CtrlSF<Space>-R
AlterCommand! <cmdwin> csu  CtrlSFUpdate
AlterCommand! <cmdwin> cst  CtrlSFToggle
AlterCommand! <cmdwin> cso  CtrlSFOpen

let g:ctrlsf_auto_close = {
\ 'normal' : 0,
\ 'compact': 0,
\ }

let g:ctrlsf_mapping = {
\ 'open': [
\   '<CR>',
\   'o',
\ ],
\ 'openb':   'O',
\ 'popenf':  'P',
\ 'pquit':   'q',
\ 'popen':   'p',
\ 'quit':    'q',
\ 'chgmode': 'M',
\ 'next':    '<C-n>',
\ 'prev':    '<C-p>',
\ 'split':   '',
\ 'vsplit':  '',
\ 'stop':    '<C-c>',
\ }

let g:ctrlsf_populate_qflist = 1
let g:ctrlsf_position        = 'right'
let g:ctrlsf_winsize         = '30%'
" }}}3

" anzu & asterisk & search-pulse {{{3
if dein#tap('vim-anzu') && dein#tap('vim-asterisk')
  map n  <Plug>(anzu-n)zzzv
  map N  <Plug>(anzu-N)zzzv
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
endif
" }}}3

" easy-align {{{3
vnoremap <Enter> :EasyAlign<CR>

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

" easymotion & clever-f & sneak & keymaps {{{3
if dein#tap('vim-easymotion') && dein#tap('clever-f.vim') && dein#tap('vim-sneak') && dein#tap('vim-keymaps')
  " EasyMotion
  let g:EasyMotion_do_mapping       = 0
  let g:EasyMotion_smartcase        = 1
  let g:EasyMotion_startofline      = 0
  let g:EasyMotion_keys             = 'HJKLASDFGYUIOPQWERTNMZXCVB'
  let g:EasyMotion_use_upper        = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
  let g:EasyMotion_prompt           = 'Search by EasyMotion ({n} character(s)) > '

  map  S  <Plug>(easymotion-s2)
  nmap S  <Plug>(easymotion-overwin-f2)
  omap f  <Plug>(easymotion-fl)
  omap t  <Plug>(easymotion-tl)
  omap F  <Plug>(easymotion-Fl)
  omap T  <Plug>(easymotion-Tl)

  " clever-f
  let g:clever_f_not_overwrites_standard_mappings = 0

  " sneak
  let g:sneak#prompt = 'Search by Sneak (2 characters) >'

  " keymaps
  let g:keymaps =  [
  \ {
  \   'name': 'Empty',
  \   'keymap': {},
  \ },
  \ {
  \   'name': 'Default',
  \   'keymap': {
  \     'nmap': {
  \       'f':  ':KeyMapSet CleverF<CR><Plug>(clever-f-f)',
  \       'F':  ':KeyMapSet CleverF<CR><Plug>(clever-f-F)',
  \       't':  ':KeyMapSet CleverF<CR><Plug>(clever-f-t)',
  \       'T':  ':KeyMapSet CleverF<CR><Plug>(clever-f-T)',
  \       'ss': ':KeyMapSet Sneak<CR><Plug>Sneak_s',
  \       'sS': ':KeyMapSet Sneak<CR><Plug>Sneak_S',
  \     },
  \     'vmap': {
  \       'f':  '<Esc>:KeyMapSet CleverF<CR>gv<Plug>(clever-f-f)',
  \       'F':  '<Esc>:KeyMapSet CleverF<CR>gv<Plug>(clever-f-F)',
  \       't':  '<Esc>:KeyMapSet CleverF<CR>gv<Plug>(clever-f-t)',
  \       'T':  '<Esc>:KeyMapSet CleverF<CR>gv<Plug>(clever-f-T)',
  \       'ss': '<Esc>:KeyMapSet Sneak<CR>gv<Plug>Sneak_s',
  \       'sS': '<Esc>:KeyMapSet Sneak<CR>gv<Plug>Sneak_S',
  \     },
  \     'omap': {
  \       'ss': '<Plug>Sneak_s',
  \       'sS': '<Plug>Sneak_S',
  \     },
  \   },
  \ },
  \ {
  \   'name': 'CleverF',
  \   'keymap': {
  \     'nmap': {
  \       'f': '<Plug>(clever-f-f)',
  \       'F': '<Plug>(clever-f-F)',
  \       ';': '<Plug>(clever-f-f)',
  \       ',': '<Plug>(clever-f-F)',
  \     },
  \     'vmap': {
  \       'f': '<Plug>(clever-f-f)',
  \       'F': '<Plug>(clever-f-F)',
  \       ';': '<Plug>(clever-f-f)',
  \       ',': '<Plug>(clever-f-F)',
  \     },
  \   },
  \ },
  \ {
  \   'name': 'Sneak',
  \   'keymap': {
  \     'nmap': {
  \       ';':  '<Plug>Sneak_;',
  \       ',':  '<Plug>Sneak_,',
  \       'ss': '<Plug>Sneak_;',
  \       'sS': '<Plug>Sneak_,',
  \     },
  \     'vmap': {
  \       ';':  '<Plug>Sneak_;',
  \       ',':  '<Plug>Sneak_,',
  \       'ss': '<Plug>Sneak_;',
  \       'sS': '<Plug>Sneak_,',
  \     },
  \   },
  \ },
  \ ]

  AutoCmd VimEnter * KeyMapSet Default
endif
" }}}3

" edgemotion {{{3
map <silent> <Leader>j <Plug>(edgemotion-j)
map <silent> <Leader>k <Plug>(edgemotion-k)
" }}}3

" expand-region {{{3
vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  nmap J         <Plug>(jplus)
  vmap J         <Plug>(jplus)
  nmap <Leader>J <Plug>(jplus-input)
  vmap <Leader>J <Plug>(jplus-input)
endif
" }}}3

" lexima {{{3
if dein#tap('lexima.vim')
  let g:lexima_map_escape = ''

  function! Hook_on_post_source_lexima()
    let l:rules = []

    "" Ampersand
    " let l:rules += [
    " \ {'char': '&',                        'input': '&& '},
    " \ {'char': '&',     'at': '\S\%#',     'input': ' && '},
    " \ {'char': '&',     'at': '\s\%#',     'input': '&& '},
    " \ {'char': '&',     'at': '&&\s\%#',   'input': '<BS><BS>'},
    " \ {'char': '&',     'at': '&\%#',      'priority': 10},
    " \ {'char': '<BS>', 'at': '\s&&\s\%#', 'input': '<BS><BS><BS><BS>'},
    " \ {'char': '<BS>', 'at': '&&\s\%#',   'input': '<BS><BS><BS>'},
    " \ {'char': '<BS>', 'at': '&&\%#',     'input': '<BS><BS>'},
    " \ ]

    "" Bar
    " let l:rules += [
    " \ {'char': '<Bar>',                    'input': '|| '},
    " \ {'char': '<Bar>', 'at': '\S\%#',     'input': ' || '},
    " \ {'char': '<Bar>', 'at': '\s\%#',     'input': '|| '},
    " \ {'char': '<Bar>', 'at': '||\s\%#',   'input': '<BS><BS><BS><BS>|'},
    " \ {'char': '<Bar>', 'at': '|\%#',      'input': '<Bar>', 'priority': 10},
    " \ {'char': '<BS>', 'at': '\s||\s\%#', 'input': '<BS><BS><BS><BS>'},
    " \ {'char': '<BS>', 'at': '||\s\%#',   'input': '<BS><BS><BS>'},
    " \ {'char': '<BS>', 'at': '||\%#',     'input': '<BS><BS>'},
    " \ ]

    "" Parenthesis
    let l:rules += [
    \ { 'char': '(',    'at': '(\%#)', 'input': '<Del>',     },
    \ { 'char': '(',    'at': '(\%#',                        },
    \ { 'char': '<BS>', 'at': '(\%#)', 'input': '<BS><Del>', },
    \ ]

    "" Brace
    let l:rules += [
    \ { 'char': '{',    'at': '{\%#}', 'input': '<Del>',     },
    \ { 'char': '{',    'at': '{\%#',                        },
    \ { 'char': '<BS>', 'at': '{\%#}', 'input': '<BS><Del>', },
    \ ]

    "" Bracket
    let l:rules += [
    \ { 'char': '[',    'at': '\[\%#\]', 'input': '<Del>',     },
    \ { 'char': '[',    'at': '\[\%#',                         },
    \ { 'char': '<BS>', 'at': '\[\%#\]', 'input': '<BS><Del>', },
    \ ]

    "" Sinble Quote
    let l:rules += [
    \ { 'char': "'",    'at': "'\\%#'", 'input': '<Del>', },
    \ { 'char': "'",    'at': "'\\%#",                    },
    \ { 'char': "'",    'at': "''\\%#",                   },
    \ { 'char': '<BS>', 'at': "'\\%#'", 'input': '<Del>', },
    \ ]

    "" Double Quote
    let l:rules += [
    \ { 'char': '"',    'at': '"\%#"', 'input': '<Del>', },
    \ { 'char': '"',    'at': '"\%#',                    },
    \ { 'char': '"',    'at': '""\%#',                   },
    \ { 'char': '<BS>', 'at': '"\%#"', 'input': '<Del>', },
    \ ]

    "" Back Quote
    let l:rules += [
    \ { 'char': '`',    'at': '`\%#`', 'input': '<Del>', },
    \ { 'char': '`',    'at': '`\%#',                    },
    \ { 'char': '`',    'at': '``\%#',                   },
    \ { 'char': '<BS>', 'at': '`\%#`', 'input': '<Del>', },
    \ ]

    "" ruby
    let l:rules += [
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': 'do\%#',     'input': '<Space><Bar>', 'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': 'do\s\%#',   'input': '<Bar>',        'input_after': '<Bar><CR>end', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': '{\%#}',     'input': '<Space><Bar>', 'input_after': '<Bar><Space>', },
    \ { 'filetype': ['ruby', 'eruby'], 'char': '<Bar>', 'at': '{\s\%#\s}', 'input': '<Bar>',        'input_after': '<Bar><Space>', },
    \ ]

    "" eruby
    let l:rules += [
    \ { 'filetype': 'eruby', 'char': '%',    'at': '<\%#',         'input': '%<Space>',                        'input_after': '<Space>%>',                 },
    \ { 'filetype': 'eruby', 'char': '=',    'at': '<%\%#',        'input': '=<Space>',                        'input_after': '<Space>%>',                 },
    \ { 'filetype': 'eruby', 'char': '=',    'at': '<%\s\%#\s%>',  'input': '<Left>=',                                                                     },
    \ { 'filetype': 'eruby', 'char': '=',    'at': '<%\%#.\+%>',                                                                           'priority': 10, },
    \ { 'filetype': 'eruby', 'char': '<BS>', 'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
    \ { 'filetype': 'eruby', 'char': '<BS>', 'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
    \ ]

    "" markdown
    let l:rules += [
    \ { 'filetype': 'markdown', 'char': '`',     'at': '``\%#',                                                       'input_after': '<CR><CR>```', 'priority': 10, },
    \ { 'filetype': 'markdown', 'char': '#',     'at': '^\%#\%(#\)\@!',    'input': '# '                                                                            },
    \ { 'filetype': 'markdown', 'char': '#',     'at': '#\s\%#',           'input': '<BS># ',                                                                       },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^#\s\%#',          'input': '<BS><BS>'                                                                      },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '##\s\%#',          'input': '<BS><BS> ',                                                                    },
    \ { 'filetype': 'markdown', 'char': '+',     'at': '^\s*\%#',          'input': '+ ',                                                                           },
    \ { 'filetype': 'markdown', 'char': '-',     'at': '^\s*\%#',          'input': '- ',                                                                           },
    \ { 'filetype': 'markdown', 'char': '*',     'at': '^\s*\%#',          'input': '* ',                                                                           },
    \ { 'filetype': 'markdown', 'char': '-',     'at': '^\s*- \%#',        'input': '<Left><Left><Tab><Del>+<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '-',     'at': '^\s*+ \%#',        'input': '<Left><Left><Tab><Del>*<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '-',     'at': '^\s*\* \%#',       'input': '<Left><Left><Tab><Del>-<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '<TAB>', 'at': '^\s*- \%#',        'input': '<Left><Left><Tab><Del>+<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '<TAB>', 'at': '^\s*+ \%#',        'input': '<Left><Left><Tab><Del>*<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '<TAB>', 'at': '^\s*\* \%#',       'input': '<Left><Left><Tab><Del>-<Right>',                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*- \%#',        'input': '<BS><BS><BS>* ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*+ \%#',        'input': '<BS><BS><BS>- ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*\* \%#',       'input': '<BS><BS><BS>+ ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\(-\|+\|*\) \%#', 'input': '<C-w>',                                                                        },
    \ { 'filetype': 'markdown', 'char': '>',     'at': '^\s*\%#',          'input': '> ',                                                                           },
    \ ]

    "" vim
    let l:rules += [
    \ { 'filetype': 'vim', 'char': '"', 'at': '^\s*\%#$',  'input': '" '                                              },
    \ { 'filetype': 'vim', 'char': '{', 'at': '^".*{\%#$', 'input': '{{', 'input_after': '<CR>" }}}', 'priority': 10, },
    \ ]

    for l:rule in l:rules
      call lexima#add_rule(l:rule)
    endfor
  endfunction

  function! Clear_lexima() abort
    let b:lexima_disabled = 1
    call lexima#clear_rules()
  endfunction

  function! Resetting_lexima() abort
    let b:lexima_disabled = 0
    call lexima#set_default_rules()
    call Hook_on_post_source_lexima()
  endfunction
endif
" }}}3

" metarepeat {{{3
" nmap <silent> <expr> <SID>(ctrln) v:hlsearch == ? "\<Plug>(metarepeat-preset-occurence)" : "*"
" }}}3

" multiple-cursor {{{3
let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_key      = 'g<C-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

nnoremap <silent> <SID>(ctrln) :<C-u> :call multiple_cursors#new("n", 1)<CR>

function! Multiple_cursors_before() abort
  call Correct_interference_multiple_cursor_before()
endfunction

function! Multiple_cursors_after() abort
  call Correct_interference_multiple_cursor_after()
endfunction
" }}}3

" operator-convert-case {{{3
nnoremap <silent> <Leader>cl :<C-u>ConvertCaseLoop<CR>
" }}}3

" operator-replace {{{3
map _ <Plug>(operator-replace)
" }}}3

" qfreplace {{{3
AutoCmd FileType qf nnoremap <silent> <buffer> r :<C-u>Qfreplace<CR>
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich')
  function! Hook_on_post_source_sandwich() abort
    let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
    let g:sandwich#recipes += [
    \ {'buns': ['\/', '\/']},
    \ {'buns': ['_', '_']},
    \ {'buns': ['`', '`']},
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
  endfunction
endif
" }}}3

" skk {{{3
" let g:skk_control_j_key = ''
" let g:skk_large_jisyo = expand('~/.config/nvim/dict/SKK-JISYO.L')
" }}}3

" switch {{{3
let g:switch_mapping = ''
nnoremap <silent> - :<C-u>Switch<CR>
" " }}}3

" tcomment {{{3
noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history   = 1000
  let g:yankround_use_region_hl = 1

  function! Hook_on_vimenter_event_yankround() abort
    nmap p <Plug>(yankround-p)
    xmap p <Plug>(yankround-p)
    nmap P <Plug>(yankround-P)

    nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "<SID>(ctrlp)"
    nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "<SID>(ctrln)"
  endfunction

  AutoCmd VimEnter * call Hook_on_vimenter_event_yankround()
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = ['markdown', 'diff', 'qf', 'help', 'gitcommit', 'denite', 'tagbar', 'ctrlsf']
" }}}3

" choosewin {{{3
let g:choosewin_tabline_replace = 0
nnoremap <silent> <C-q> :<C-u>ChooseWin<CR>
" }}}3

" brightest {{{3
AlterCommand! <cmdwin> br[ight] BrightestToggle

let g:brightest#enable_on_CursorHold        = 1
let g:brightest#enable_highlight_all_window = 1
let g:brightest#highlight = {'group': 'BrighTestBgLight'}
let g:brightest#ignore_syntax_list = ['Statement', 'Keyword', 'Boolean', 'Repeat']
" }}}3

" fastfold {{{3
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes  = ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
nmap zuz <Plug>(FastFoldUpdate)
" }}}3

" foldCC {{{3
if dein#tap('foldCC.vim')
  set foldtext=FoldCCtext()
endif
" }}}3

" hl_matchit {{{3
let g:hl_matchit_enable_on_vim_startup = 1
" }}}3

" indent-line {{{3
let g:indentLine_enabled         = 0
let g:indentLine_fileTypeExclude = ['json']
nnoremap <silent> <Leader>i :<C-u>:IndentLinesToggle<CR>
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'iceberg_yano',
  \ 'active': {
  \   'left': [
  \     ['mode', 'paste'],
  \     ['denite', 'filepath', 'filename', 'anzu'],
  \     ['keymap'],
  \    ],
  \   'right': [
  \     ['lineinfo'],
  \     ['filetype', 'fileencoding', 'fileformat'],
  \     ['linter_errors', 'linter_warnings', 'linter_ok', 'linter_unload'],
  \   ],
  \ },
  \ 'inactive': {
  \   'left': [['mode'], [], ['filepath', 'filename']],
  \   'right': [[], ['filetype', 'fileencoding', 'fileformat']],
  \ },
  \ 'tabline': {
  \   'left':  [['tabs']],
  \   'right': [['branch'], ['gitstatus']],
  \ },
  \ 'tab': {
  \   'active':   ['tabwinnum', 'filename'],
  \   'inactive': ['tabwinnum', 'filename'],
  \ },
  \ 'component': {
  \   'paste':        "%{&paste ? 'PASTE' : ''}",
  \  },
  \ 'component_function': {
  \   'mode':         'Lightline_mode',
  \   'filepath':     'Lightline_filepath',
  \   'filename':     'Lightline_filename',
  \   'filetype':     'Lightline_filetype',
  \   'lineinfo':     'Lightline_lineinfo',
  \   'fileencoding': 'Lightline_fileencoding',
  \   'fileformat':   'Lightline_fileformat',
  \   'branch':       'gina#component#repo#preset',
  \   'gitstatus':    'Lightline_git_status',
  \   'anzu':         'anzu#search_status',
  \   'denite':       'Lightline_denite',
  \   'keymap':       'Lightline_keymap',
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum':   'Lightline_tab_win_num',
  \ },
  \ 'component_visible_condition': {
  \   'filepath':     'Lightline_is_visible()',
  \   'lineinfo':     'Lightline_is_visible()',
  \   'fileencoding': 'Lightline_is_visible()',
  \   'fileformat':   'Lightline_is_visible()',
  \   'keymap':       'Lightline_is_visible()',
  \ },
  \ 'component_function_visible_condition': {
  \   'paste':    '&paste',
  \   'spell':    '&spell',
  \ },
  \ 'component_type': {
  \   'linter_errors':   'error',
  \   'linter_warnings': 'warning',
  \   'linter_ok':       'ok',
  \ },
  \ 'component_expand': {
  \   'linter_errors':   'Lightline_ale_errors',
  \   'linter_warnings': 'Lightline_ale_warnings',
  \   'linter_ok':       'Lightline_ale_ok',
  \ },
  \ 'enable': {
  \   'statusline': 1,
  \   'tabline':    1,
  \ },
  \ }

  let g:lightline#ale#indicator_errors   = 'E'
  let g:lightline#ale#indicator_warnings = 'W'
  let g:lightline#ale#indicator_ok       = 'OK'

  " Disable lineinfo, fileencoding and fileformat
  let g:lightline_ignore_right_ft = [
  \ 'help',
  \ 'man',
  \ 'fzf',
  \ 'denite',
  \ 'vaffle',
  \ 'tagbar',
  \ 'capture',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]


  let g:lightline_ft_to_mode_hash = {
  \ 'help':        'Help',
  \ 'man':         'Man',
  \ 'fzf':         'FZF',
  \ 'denite':      'Denite',
  \ 'vaffle':      'Vaffle',
  \ 'tagbar':      'TagBar',
  \ 'capture':     'Capture',
  \ 'gina-status': 'Git Status',
  \ 'gina-branch': 'Git Branch',
  \ 'gina-log':    'Git Log',
  \ 'gina-reflog': 'Git Reflog',
  \ 'gina-blame':  'Git Blame',
  \ }

  let g:lightline_ignore_modifiable_ft = [
  \ 'qf',
  \ 'vaffle',
  \ 'tagbar',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let g:lightline_ignore_filename_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'vaffle',
  \ 'tagbar',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let g:lightline_ignore_filepath_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'vaffle',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  function! Lightline_is_visible() abort
    return 80 < winwidth(0)
  endfunction

  function! Lightline_mode() abort
    let l:win = getwininfo(win_getid())[0]
    return l:win.loclist ? 'Location List' : l:win.quickfix ? 'QuickFix' : get(g:lightline_ft_to_mode_hash, &filetype, lightline#mode())
  endfunction

  function! Lightline_filepath() abort
    let l:path = filereadable(expand('%:p:~')) ? '' : expand('%:p:~:h')
    let l:dirs     = split(l:path, '/')
    let l:last_dir = remove(l:dirs, -1)
    call map(l:dirs, 'v:val[0]')

    if count(g:lightline_ignore_filepath_ft, &filetype) || !len(l:dirs) || expand('%:t') ==# '[Command Line]'
      return ''
    endif

    return !len(l:dirs) ? l:last_dir : join(l:dirs, '/') . '/' . l:last_dir
  endfunction

  function! Lightline_filename() abort
    let l:filename = expand('%:t')

    if count(g:lightline_ignore_filename_ft, &filetype)
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
    return !has_key(g:lightline_ft_to_mode_hash, &filetype) ?
    \ &filetype :
    \ ''
  endfunction

  function! Lightline_lineinfo() abort
    return !count(g:lightline_ignore_right_ft, &filetype) ?
    \        printf('%d/%d [%d%%]',line('.'), line('$'), float2nr((1.0 * line('.')) / line('$') * 100.0)) :
    \        ''
  endfunction

  function! Lightline_fileencoding() abort
    return !count(g:lightline_ignore_right_ft, &filetype) ?
    \         strlen(&fileencoding) ?
    \           &fileencoding :
    \           &encoding :
    \         ''
  endfunction

  function! Lightline_fileformat() abort
    return !count(g:lightline_ignore_right_ft, &filetype) ?
    \         &fileformat :
    \        ''
  endfunction

  "%{(strlen(&fileencoding) ? &fileencoding : &encoding)}",
  "%{}",
  "
  function! Lightline_tab_win_num(n) abort
    return a:n . ':' . len(tabpagebuflist(a:n))
  endfunction

  function! Lightline_ale_errors() abort
    return count(s:ale_filetypes, &filetype) ? lightline#ale#errors() : ''
  endfunction

  function! Lightline_ale_warnings() abort
    return count(s:ale_filetypes, &filetype) ? lightline#ale#warnings() : ''
  endfunction

  function! Lightline_ale_ok() abort
    return count(s:ale_filetypes, &filetype) ? lightline#ale#ok() : ''
  endfunction

  function! Lightline_git_status() abort
    if gina#component#repo#branch() ==# ''
      return ''
    else
      let l:staged     = gina#component#status#staged()
      let l:unstaged   = gina#component#status#unstaged()
      let l:conflicted = gina#component#status#conflicted()
      return printf(
      \ 'S: %s, U: %s, C: %s',
      \ l:staged ==# '' ? 0 : l:staged,
      \ l:unstaged ==# '' ? 0 : l:unstaged,
      \ l:conflicted ==# '' ? 0 : l:conflicted,
      \ )
    endif
  endfunction

  function! Lightline_denite() abort
    return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  endfunction

  function! Lightline_keymap() abort
    return "Map [" . keymaps#get_current_keymap_name() . "]"
  endfunction
endif
" }}}3

" operator-flashy {{{3
if dein#tap('vim-operator-flashy')
  map  y <Plug>(operator-flashy)
  nmap Y <Plug>(operator-flashy)$
endif
" }}}3

" parenmatch {{{3
let g:loaded_matchparen = 1
let g:parenmatch_highlight = 0
" }}}3

" quickhl {{{3
nmap <Leader>m <Plug>(quickhl-manual-this)
xmap <Leader>m <Plug>(quickhl-manual-this)
nmap <Leader>M <Plug>(quickhl-manual-reset)
xmap <Leader>M <Plug>(quickhl-manual-reset)
" }}}3

" startify {{{3
let g:startify_custom_header = [
\ '╦ ╦┌┐┌┬  ┬┌┬┐┬┌┬┐┌─┐┌┬┐  ╔═╗┬  ┬ ┬┌─┐┬┌┐┌  ╦ ╦┌─┐┬─┐┬┌─┌─┐',
\ '║ ║││││  │││││ │ ├┤  ││  ╠═╝│  │ ││ ┬││││  ║║║│ │├┬┘├┴┐└─┐',
\ '╚═╝┘└┘┴─┘┴┴ ┴┴ ┴ └─┘─┴┘  ╩  ┴─┘└─┘└─┘┴┘└┘  ╚╩╝└─┘┴└─┴ ┴└─┘',
\ ]

let g:startify_list_order = [
\ ['   Project:'],
\ 'dir',
\ ['   Recent Files:'],
\ 'files',
\ ['   Commands:'],
\ 'commands'
\ ]
let g:startify_change_to_vcs_root = 1

let g:startify_commands = [
\ ['git status',        'Gina status'],
\ ['git log',           'Agit'],
\ ['git file log',      'AgitFile'],
\ ['git diff',          'Gina diff'],
\ ['git diff --cached', 'Gina diff --cached'],
\ ['git blame',         'Gina blame'],
\ ]

" }}}3

" rainbow {{{3
let g:rainbow_active = 1
let g:rainbow_conf = {}
let g:rainbow_conf.ctermfgs = ['darkred', 'darkcyan', 'darkblue', 'darkmagenta']
let g:rainbow_conf.operator = '_,_'
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
\ 'vaffle'      : 0,
\ 'git'         : 0,
\ 'gitcommit'   : 0,
\ 'gina-status' : 0,
\ 'gina-commit' : 0,
\ 'gina-reflog' : 0,
\ 'gina-blame'  : 0,
\ 'tagbar'      : 0,
\ 'quickrun'    : 0,
\ 'capture'     : 0,
\ 'ctrlsf'      : 0,
\ }
" }}}3

" zenspace {{{3
let g:zenspace#default_mode = 'on'
" }}}3

" }}}2

" Util {{{2

" aho-bakaup {{{3
let g:bakaup_auto_backup = 1
let g:bakaup_backup_dir  = expand('~/.config/nvim/backup')
" }}}3

" automatic {{{
function! s:my_temp_win_init(config, context)
  nnoremap <silent> <buffer> q :<C-u>q<CR>
endfunction

let g:automatic_default_set_config = {
\ 'apply': function('s:my_temp_win_init'),
\ }

let g:automatic_config = [
\ {
\   'match': { 'filetype': 'help' },
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
\   'match': { 'filetype': 'diff' },
\   'set': {
\     'move': 'right',
\   },
\ },
\ {
\   'match': {
\     'filetype': 'vaffle',
\     'autocmds': ['FileType'],
\   },
\ },
\ {
\   'match': { 'filetype': 'git' },
\ },
\ {
\   'match': { 'filetype': 'gina-status' },
\   'set': {
\     'move': 'topleft',
\     'height': '20%',
\   },
\ },
\ {
\   'match': { 'filetype': 'gina-commit' },
\   'set': {
\     'move': 'topleft',
\     'height': '25%',
\   },
\ },
\ {
\   'match': { 'filetype': 'gina-branch' },
\   'set': {
\     'move': 'topleft',
\     'height': '30%',
\   },
\ },
\ {
\   'match': { 'filetype': 'gina-log' },
\ },
\ {
\   'match': { 'filetype': 'gina-reflog' },
\ },
\ {
\   'match': {
\     'filetype': 'scratch',
\     'autocmds': ['FileType'],
\   },
\ },
\ {
\   'match': {
\     'filetype': 'capture',
\     'autocmds': ['FileType'],
\   },
\ },
\ {
\   'match': {
\     'filetype': 'ref-webdict',
\     'autocmds': ['FileType'],
\   },
\ },
\ {
\   'match' : {
\     'autocmds': ['CmdwinEnter'],
\   },
\   'set' : {
\     'is_close_focus_out' : 1,
\     'unsettings' : ['move', 'resize'],
\   },
\ },
\ ]
" }}}

" bufkill {{{3
AutoCmd FileType *      nnoremap <silent> <buffer> <Leader>d :BD<CR>
AutoCmd FileType help   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType diff   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType git    nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType vaffle nnoremap <silent> <buffer> <Leader>d :BW<CR>
" }}}3

" capture {{{3
AlterCommand! <cmdwin> cap[ture] Capture
" }}}3

" dispatch {{{3
AlterCommand! <cmdwin> dis[patch] Dispatch
AlterCommand! <cmdwin> fo[cus]    Focus
AlterCommand! <cmdwin> st[art]    Start

AlterCommand! <cmdwin> stree      Start!<Space>stree
AlterCommand! <cmdwin> fork       Start!<Space>fork
" }}}3

" maximizer {{{3
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
" }}}3

" miniyank {{{3
let g:miniyank_maxitems = 100
" }}}3

" open-browser {{{3
let g:netrw_nogx = 1
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)
" }}}3
"
" open-googletranslate {{{3
let g:opengoogletranslate#openbrowsercmd = 'electron-open --without-focus'
command! -range Trans <line1>,<line2>OpenGoogleTranslate
" }}}3

" quickrun {{{
" AlterCommand! <cmdwin> qrun QuickRun
"
" let g:quickrun_config = {
" \ '_' : {
" \   'runner': 'vimproc',
" \   'runner/vimproc/updatetime': 40,
" \   'outputter': 'error',
" \   'outputter/error/success': 'buffer',
" \   'outputter/error/error': 'quickfix',
" \ }
" \ }
" let g:quickrun_no_default_key_mappings = 1
" }}}

" ref {{{3
AlterCommand! <cmdwin> alc Ref<Space>webdict<Space>alc

let g:ref_source_webdict_sites = {
\ 'alc' : {
\   'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
\   }
\ }
" }}}3

" session {{{3
AlterCommand! <cmdwin> ss SessionSave!
AlterCommand! <cmdwin> sl SessionOpen
" }}}3

" scratch {{{3
AlterCommand! <cmdwin> sc[ratch] Scratch

let g:scratch_no_mappings = 1
" }}}3

" tagbar {{{3
AlterCommand! <cmdwin> tag TagbarOpen<Space>j

let g:tagbar_autoshowtag = 1
let g:tagbar_autofocus   = 1
let g:tagbar_sort        = 0

function! Tagbar_status_func(current, sort, fname, ...) abort
  let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction
let g:tagbar_status_func = 'Tagbar_status_func'
" }}}3

" undotree {{{3
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0
nnoremap <silent> <C-w><C-w> :call WindowSwap#EasyWindowSwap()<CR>
" }}}3

" winresizer {{{3
nnoremap <silent> <Leader><C-w> :WinResizerStartResize<CR>
" }}}3

" }}}2

" }}}1

" Correct Interference {{{1

" Multiple Cursor & lexima {{{2
function! Correct_interference_multiple_cursor_before() abort
  let b:deoplete_disable_auto_complete = 1
  call Clear_lexima()
endfunction

function! Correct_interference_multiple_cursor_after() abort
  let b:deoplete_disable_auto_complete = 0
  call Resetting_lexima()
endfunction
" }}}2

" Mapping <Esc><Esc> {{{2
function! EscEscReset() abort
  AnzuClearSearchStatus
  KeyMapSet Default
endfunction
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <Bar> call EscEscReset()<CR>
" }}}

" }}}1

" Load Colorscheme Later {{{1
AutoCmd ColorScheme * highlight Visual       ctermfg=159  ctermbg=23
AutoCmd ColorScheme * highlight Search       ctermfg=68   ctermbg=232
AutoCmd ColorScheme * highlight LineNr       ctermfg=241
AutoCmd ColorScheme * highlight CursorLineNr ctermfg=253  ctermbg=235
AutoCmd ColorScheme * highlight CursorLine                ctermbg=235
AutoCmd ColorScheme * highlight NonText      ctermfg=60
AutoCmd ColorScheme * highlight StatusLine   ctermfg=0    ctermbg=234
AutoCmd ColorScheme * highlight StatusLineNC ctermfg=0    ctermbg=234
AutoCmd ColorScheme * highlight Todo         ctermfg=229

AutoCmd ColorScheme * highlight link ParenMatch     MatchParen
AutoCmd ColorScheme * highlight ALEWarning          ctermfg=0    ctermbg=229
AutoCmd ColorScheme * highlight ALEError            ctermfg=0    ctermbg=203
AutoCmd ColorScheme * highlight BrighTestBgLight    ctermfg=none ctermbg=236
AutoCmd ColorScheme * highlight CleverFDefaultLabel ctermfg=9    ctermbg=236 cterm=bold
AutoCmd ColorScheme * highlight Sneak               ctermfg=132  ctermbg=236 cterm=bold
AutoCmd ColorScheme * highlight YankRoundRegion     ctermfg=209  ctermbg=237

syntax enable

" iceberg {{{2
colorscheme iceberg
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
