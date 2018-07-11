" Encoding {{{1
if has('vim_starting')
  set encoding=utf-8
  set fileencodings=utf-8,sjis,cp932,euc-jp
  set fileformats=unix,mac,dos
  set termencoding=utf-8
endif

scriptencoding utf-8
" }}}1

" Variable Definition {{{1
let s:ale_filetypes = ['javascript', 'typescript', 'vue', 'ruby', 'eruby', 'python', 'go', 'rust', 'json', 'html', 'css', 'scss', 'vim', 'sh', 'bash', 'zsh']
" }}}1

" Plugin Manager {{{1

" Install & Load Dein {{{2
let s:DEIN_BASE_PATH = $HOME . '/.vim/bundle/'
let s:DEIN_PATH      = expand(s:DEIN_BASE_PATH . 'repos/github.com/Shougo/dein.vim')
if !isdirectory(s:DEIN_PATH)
  if (executable('git') == 1) && (confirm('Install dein.vim or Launch vim immediately', "&Yes\n&No", 1) == 1)
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
  call dein#add('Chiel92/vim-autoformat',                 {'lazy': 1, 'on_cmd': 'Autoformat'})
  call dein#add('MaxMEllon/vim-jsx-pretty',               {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('Quramy/tsuquyomi',                       {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('Shougo/context_filetype.vim')
  call dein#add('Shougo/echodoc.vim',                     {'lazy': 1, 'on_event': 'InsertEnter'})
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
  call dein#add('pocke/iro.vim',                          {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('posva/vim-vue',                          {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('prettier/vim-prettier',                  {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'vue', 'css', 'scss', 'json', 'graphql', 'markdown']})
  call dein#add('rhysd/fixjson',                          {'lazy': 1, 'on_ft': 'json'})
  call dein#add('rust-lang/rust.vim',                     {'lazy': 1, 'on_ft': 'rust'})
  call dein#add('sgur/vim-editorconfig',                  {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('slim-template/vim-slim',                 {'lazy': 1, 'on_ft': 'slim'})
  call dein#add('stephpy/vim-yaml',                       {'lazy': 1, 'on_ft': 'yaml'})
  call dein#add('tell-k/vim-autopep8',                    {'lazy': 1, 'on_ft': 'python'})
  call dein#add('tpope/vim-rails',                        {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('vim-ruby/vim-ruby',                      {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
  call dein#add('vimtaku/hl_matchit.vim',                 {'lazy': 1, 'on_ft': 'ruby'})
  " }}}3

  " ALE {{{
  call dein#add('w0rp/ale', {'lazy': 1, 'on_ft': s:ale_filetypes})
  " }}}

  " Git {{{3
  call dein#add('airblade/vim-gitgutter')
  call dein#add('airblade/vim-rooter',           {'lazy': 1, 'on_cmd': 'Rooter'})
  call dein#add('cohama/agit.vim',               {'lazy': 1, 'on_cmd': ['Agit', 'AgitFile', 'AgitGit', 'AgitDiff']})
  call dein#add('hotwatermorning/auto-git-diff', {'lazy': 1, 'on_ft': 'gitrebase'})
  call dein#add('lambdalisue/gina.vim')
  call dein#add('lambdalisue/vim-unified-diff')
  call dein#add('rhysd/committia.vim',           {'lazy': 1, 'on_ft': 'gitcommit'})
  call dein#add('rhysd/conflict-marker.vim')

  call dein#add('ToruIwashita/git-switcher.vim', {'lazy': 1, 'on_cmd': [
  \ 'Gsw',
  \ 'GswRemore',
  \ 'GswPrev',
  \ 'GswSave',
  \ 'GswLoad',
  \ 'GswMove',
  \ 'GswRemove',
  \ 'GswRemoveMergedBranches',
  \ 'GswSessionList',
  \ 'GswSessionList',
  \ 'GswPrevBranchName',
  \ 'GswClearState',
  \ 'GswDeleteSession',
  \ 'GswDeleteSessionsIfBranchNotExists',
  \ 'GswBranch',
  \ 'GswMergedBranch',
  \ 'GswBranchRemote',
  \ 'GswFetch',
  \ 'GswPull'
  \ ]})
  " }}}3

  " Completion {{{3
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  call dein#add('autozimu/LanguageClient-neovim', {'rev': 'next', 'build': 'bash install.sh'})

  call dein#add('Shougo/neco-syntax')
  call dein#add('Shougo/neco-vim')
  call dein#add('carlitux/deoplete-ternjs')
  call dein#add('fishbullet/deoplete-ruby')
  call dein#add('fszymanski/deoplete-emoji')
  call dein#add('ujihisa/neco-look')
  " call dein#add('uplus/deoplete-solargraph')
  call dein#add('wellle/tmux-complete.vim')
  call dein#add('wokalski/autocomplete-flow')
  call dein#add('zchee/deoplete-jedi')

  " call dein#add('blueyed/vim-auto-programming', {'rev': 'neovim'})
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/unite.vim')

  " call dein#add('osyo-manga/unite-quickfix')
  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/unite-outline')
  call dein#add('ozelentok/denite-gtags')

  call dein#add('SpaceVim/gtags.vim')

  call dein#add('Shougo/neosnippet')
  call dein#add('Shougo/neosnippet-snippets')

  set  runtimepath+=/usr/local/opt/fzf
  call dein#add('junegunn/fzf.vim')
  call dein#add('yuki-ycino/fzf-preview.vim')
  " call dein#local('~/repos/github.com/yuki-ycino', {}, ['fzf-preview.vim'])
  " }}}3

  " filer {{{3
  call dein#add('Shougo/vimfiler', {'lazy': 1, 'on_cmd': [
  \ 'VimFiler',
  \ 'VimFilerCreate',
  \ 'VimFilerSimple',
  \ 'VimFilerSplit',
  \ 'VimFilerTab',
  \ 'VimFilerDouble',
  \ 'VimFilerCurrentDir',
  \ 'VimFilerBufferDir',
  \ 'VimFilerExplorer',
  \ 'VimFilerClose',
  \ 'VimFilerEdit',
  \ 'VimFilerWrite',
  \ 'VimFilerSource',
  \ 'VimFilerRead',
  \ ]})

  call dein#add('cocopon/vaffle.vim')
  " }}}3

  " Edit & Move & Search {{{3
  " call dein#add('tyru/skk.vim',                           {'lazy': 1, 'on_event': 'InsertEnter'})
  " call dein#add('vimtaku/vim-mlh',                        {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('DeaR/vim-textobj-wiw',                   {'lazy': 1, 'on_map': {'n': [',w', ',b', ',e', ',ge'], 'ox': ['i,w', 'a,w']}, 'depends': 'vim-textobj-user'})
  call dein#add('LeafCage/yankround.vim',                 {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('chrisbra/NrrwRgn',                       {'lazy': 1, 'on_cmd': ['NR', 'NW', 'WidenRegion', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL']})
  call dein#add('cohama/lexima.vim',                      {'lazy': 1, 'on_event': 'InsertEnter', 'hook_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('easymotion/vim-easymotion')
  call dein#add('godlygeek/tabular',                      {'lazy': 1, 'on_cmd': 'Tabularize'})
  call dein#add('haya14busa/incsearch.vim',               {'lazy': 1, 'on_map': '<Plug>', 'on_source': 'vim-asterisk'})
  call dein#add('haya14busa/vim-asterisk',                {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-metarepeat',              {'lazy': 1, 'on_map': ['go', 'g.']})
  call dein#add('haya14busa/vim-textobj-function-syntax', {'lazy': 1, 'depends': 'vim-textobj-function'})
  call dein#add('junegunn/vim-easy-align',                {'lazy': 1, 'on_cmd': 'EasyAlign'})
  call dein#add('kana/vim-operator-replace',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('kana/vim-textobj-function',              {'lazy': 1, 'on_map': {'ox': ['if', 'af', 'iF', 'aF']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-indent',                {'lazy': 1, 'on_map': {'ox': ['ai', 'ii', 'aI',  'iI']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-line',                  {'lazy': 1, 'on_map': {'ox': ['al', 'il']}, 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-user')
  call dein#add('machakann/vim-sandwich',                 {'lazy': 1, 'on_map': {'nv': ['sa', 'sr', 'sd' ], 'o': ['ib', 'is', 'ab', 'as']}, 'hook_source': 'call Hook_on_post_source_sandwich()'})
  call dein#add('mileszs/ack.vim')
  call dein#add('mopp/vim-operator-convert-case',         {'lazy': 1, 'on_cmd': 'ConvertCaseLoop'})
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('osyo-manga/vim-jplus',                   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('othree/eregex.vim',                      {'lazy': 1, 'on_cmd': 'S'})
  call dein#add('rhysd/accelerated-jk',                   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/clever-f.vim',                     {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/vim-textobj-ruby',                 {'lazy': 1, 'on_ft': 'ruby', 'depends': 'vim-textobj-user'})
  call dein#add('thinca/vim-qfreplace',                   {'lazy': 1, 'on_cmd': 'Qfreplace'})
  call dein#add('tommcdo/vim-exchange',                   {'lazy': 1, 'on_map': {'n': ['cx', 'cxc', 'cxx'], 'x': ['X']}})
  call dein#add('tomtom/tcomment_vim',                    {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat',                       {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('tpope/vim-speeddating',                  {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  " }}}3

  " Appearance {{{3
  call dein#add('AndrewRadev/linediff.vim',       {'lazy': 1, 'on_cmd': ['Linediff', 'LinediffReset']})
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Yggdroot/indentLine',            {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('gregsexton/MatchTag')
  call dein#add('haya14busa/vim-operator-flashy', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('itchyny/lightline.vim')
  call dein#add('itchyny/vim-cursorword')
  call dein#add('itchyny/vim-highlighturl')
  call dein#add('itchyny/vim-parenmatch')
  call dein#add('luochen1990/rainbow')
  call dein#add('maximbaz/lightline-ale')
  call dein#add('mhinz/vim-startify')
  call dein#add('mopp/smartnumber.vim',           {'lazy': 1, 'on_cmd': 'SNumbersToggleRelative'})
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('t9md/vim-quickhl',               {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-zenspace')
  runtime macros/matchit.vim
  " }}}3

  " tmux {{{3
  call dein#add('benmills/vimux')
  call dein#add('christoomey/vim-tmux-navigator')
  " }}}3

  " develop {{{3
  call dein#add('haya14busa/vim-debugger', {'lazy': 1, 'on_func': 'debugger#init'})
  call dein#add('thinca/vim-editvar',      {'lazy': 1, 'on_cmd': 'Editvar', 'on_func': 'editvar#open'})
  call dein#add('thinca/vim-prettyprint',  {'lazy': 1, 'on_cmd': ['PrettyPrint', 'PP'], 'on_func': ['PrettyPrint', 'PP']})
  call dein#add('tweekmonster/exception.vim')
  call dein#add('vim-jp/vital.vim',        {'lazy': 1, 'on_cmd': 'Vitalize'})
  " }}}3

  " Util {{{3
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bogado/file-line')
  call dein#add('dietsche/vim-lastplace')
  call dein#add('haya14busa/vim-open-googletranslate', {'lazy': 1, 'on_cmd': 'OpenGoogleTranslate'})
  call dein#add('janko-m/vim-test',                    {'lazy': 1, 'on_cmd': ['TestNearest','TestFile','TestSuite','TestLast','TestVisit']})
  call dein#add('kana/vim-gf-user')
  call dein#add('kana/vim-niceblock',                  {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('kana/vim-operator-user')
  call dein#add('kana/vim-submode')
  call dein#add('kana/vim-tabpagecd')
  call dein#add('konfekt/fastfold')
  call dein#add('lambdalisue/session.vim',             {'lazy': 1, 'on_cmd': ['SessionSave', 'SessionOpen', 'SessionRemove', 'SessionList', 'SessionClose']})
  call dein#add('lambdalisue/vim-manpager',            {'lazy': 1, 'on_cmd': ['Man', 'MANPAGER'], 'depends': 'vim-plugin-AnsiEsc'})
  call dein#add('lambdalisue/vim-pager',               {'lazy': 1, 'on_cmd': 'PAGER', 'depends': 'vim-plugin-AnsiEsc'})
  call dein#add('majutsushi/tagbar',                   {'lazy': 1, 'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('mattn/webapi-vim')
  call dein#add('mbbill/undotree',                     {'lazy': 1, 'on_cmd': 'UndotreeToggle'})
  call dein#add('mtth/scratch.vim',                    {'lazy': 1, 'on_cmd': ['Scratch', 'ScratchInsert', 'ScratchPreview', 'ScratchSelection']})
  call dein#add('osyo-manga/vim-gift')
  call dein#add('pocke/vim-automatic',                 {'depends': 'vim-gift'})
  call dein#add('powerman/vim-plugin-AnsiEsc')
  call dein#add('qpkorr/vim-bufkill')
  call dein#add('simeji/winresizer',                   {'lazy': 1, 'on_cmd': 'WinResizerStartResize'})
  call dein#add('szw/vim-maximizer',                   {'lazy': 1, 'on_cmd': 'MaximizerToggle'})
  call dein#add('terryma/vim-expand-region',           {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-localrc')
  call dein#add('thinca/vim-quickrun',                 {'lazy': 1, 'on_cmd': 'QuickRun'})
  call dein#add('thinca/vim-ref',                      {'lazy': 1, 'on_cmd': 'Ref'})
  call dein#add('tpope/vim-unimpaired')
  call dein#add('tweekmonster/startuptime.vim',        {'lazy': 1, 'on_cmd': 'StartupTime'})
  call dein#add('tyru/capture.vim',                    {'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('tyru/vim-altercmd')
  call dein#add('wesQ3/vim-windowswap',                {'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  call dein#add('yssl/QFEnter')
  " }}}3

  " Library {{{3
  call dein#add('Shougo/vimproc.vim', {'build': 'make'})
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
if dein#check_install() && (confirm('Would you like to download some plugins ?', "&Yes\n&No", 1) == 1)
  call dein#install()
endif
" }}}2

" }}}1

" Global Settings {{{1

" Easy autocmd {{{2
augroup MyVimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd MyVimrc <args>
" }}}2

" Appearance {{{2
set hidden
set number
set nocursorline
set diffopt=filler,icase,vertical
set display=lastline
set helplang=ja
set laststatus=2
set list listchars=tab:^\ ,trail:_,eol:$,extends:>,precedes:<
set matchtime=1
set previewheight=18
set pumheight=15
set showmatch
set showtabline=2
set spelllang=en,cjk
" }}}2

" Folding {{{2
set foldcolumn=1
set foldenable
set foldmethod=manual
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

"" Setting for Neovim
if has('nvim')
  let g:python_host_prog  = $HOME . '/.pyenv/shims/python2'
  let g:python3_host_prog = $HOME . '/.pyenv/shims/python3'
endif

"" Move
set nostartofline
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
nnoremap <C-o> <C-o>zzzv
nnoremap <C-i> <C-i>zzzv

"" Edit
nnoremap dw de
nnoremap cw ce

"" CommandLine
noremap! <C-a> <Home>
noremap! <C-b> <Left>
noremap! <C-d> <Del>
noremap! <C-e> <End>
noremap! <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" Buffer
nnoremap <silent> <C-p> :bprevious<CR>
nnoremap <silent> <C-n> :bnext<CR>

"" increment & decrement
noremap <silent> + <C-a>
noremap <silent> - <C-x>

"" Ignore registers
nnoremap x "_x

"" Select buffer
nnoremap B :<C-u>ls<CR>:buffer<Space>

"" Indent
vnoremap < <gv
vnoremap > >gv|

"" Tab
nnoremap <silent> gt :<C-u>tablast <Bar> tabedit<CR>
nnoremap <silent> gd :<C-u>tabclose<CR>
"" submode
" nnoremap <silent> gh :<C-u>tabprevious<CR>
" nnoremap <silent> gl :<C-u>tabNext<CR>
nnoremap <silent> g1 :<C-u>1tabnext<CR>
nnoremap <silent> g2 :<C-u>2tabnext<CR>
nnoremap <silent> g3 :<C-u>3tabnext<CR>
nnoremap <silent> g4 :<C-u>4tabnext<CR>
nnoremap <silent> g5 :<C-u>5tabnext<CR>
nnoremap <silent> g6 :<C-u>6tabnext<CR>
nnoremap <silent> g7 :<C-u>7tabnext<CR>
nnoremap <silent> g8 :<C-u>8tabnext<CR>
nnoremap <silent> g9 :<C-u>9tabnext<CR>

"" resize
nnoremap <silent> <Left> :vertical resize -1<CR>
nnoremap <silent> <Right> :vertical resize +1<CR>
nnoremap <silent> <Up> :resize -1<CR>
nnoremap <silent> <Down> :resize +1<CR>

"" Save
nnoremap <silent> <Leader>w :<C-u>update<CR>
nnoremap <silent> <Leader>W :<C-u>update!<CR>

"" redraw
nnoremap <silent> <Leader><C-l> :<C-u>redraw!<CR>

"" Macro
nnoremap Q @q

"" mark
nnoremap ' `
noremap ]' ]`
noremap ]` ]'
noremap [' [`
noremap [` ['

"" spellcheck
map <silent> <leader>ss :set spell!<CR>

"" terminal
if has('nvim')
  tnoremap <silent> <Esc> <C-\><C-n>
endif
" }}}2

" Set Options {{{2

" viminfo {{{3
set viminfo='1000
" }}}3

" Appearance {{{3
set conceallevel=2
set hlsearch | nohlsearch
set belloff=all
set virtualedit=all
set synmaxcol=300
" }}}3

" Same column move {{{3
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
set ignorecase
set smartcase
set completeopt=longest,menuone,preview
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
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
if $TERM ==# 'screen'
  set t_Co=256
endif
if !has('nvim')
  set term=xterm-256color
endif
" }}}3

" Disable Paste Mode {{{3
AutoCmd InsertLeave * setlocal nopaste
" }}}3

" Disable Auto Comment {{{3
AutoCmd FileType * setlocal formatoptions-=ro
" }}}3

" Highlight Annotation Comment {{{3
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|OPTIMIZE\|HACK\|REVIEW\|NOTE\|INFO\|TEMP\):')
AutoCmd WinEnter,BufRead,BufNew,Syntax * highlight Todo ctermfg=229
" }}}3

" Clipboard {{{3
set clipboard=unnamed,unnamedplus
" }}}3

" Misc {{{3
set updatetime=100
set matchpairs& matchpairs+=<:>
set langnoremap
set regexpengine=2
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

" Command {{{1

" ToggleHiglight {{{2
function! s:toggle_highlight()
  if exists('g:syntax_on')
    syntax off
  else
    syntax enable
  endif
endfunction

command! ToggleHighlight call s:toggle_highlight()
nnoremap <silent> <Leader>th :ToggleHighlight<CR>
" }}}2

" ToggleQuickfix {{{2
function! s:toggle_quickfix()
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    botright copen
  endif
endfunction

command! ToggleQuickfix call s:toggle_quickfix()
nnoremap <silent> <Leader>q :ToggleQuickfix<CR>
" }}}2

" ToggleLocationList {{{2
function! s:toggle_location_list()
  let _ = winnr('$')
  lclose
  if _ == winnr('$')
    botright lopen
  endif
endfunction

command! ToggleLocationList call s:toggle_location_list()
nnoremap <silent> <Leader>l :ToggleLocationList<CR>
" }}}2

" Preserve {{{2
function! s:preserve(command)
  let l:lastsearch = @/
  let l:view = winsaveview()
  execute a:command
  let @/ = l:lastsearch
  call winrestview(l:view)
endfunction

command! -complete=command -nargs=* Preserve call s:preserve(<q-args>)
" }}}2

" TrimEndLine {{{2
function! s:trim_end_line()
  let l:save_cursor = getpos('.')
  normal! :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', l:save_cursor)
endfunction

" AutoCmd BufWritePre * call s:trim_end_line()
command! TrimEndLine call s:trim_end_line()
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

nnoremap gm :<C-u>tablast <Bar> call <SID>move_to_new_tab()<CR>
" }}}2

" HelpEdit & HelpView {{{
function! s:option_to_view()
  setlocal buftype=help nomodifiable readonly
  setlocal nolist
  if exists('+colorcolumn')
    setlocal colorcolumn=
  endif
  if has('conceal')
    setlocal conceallevel=2
  endif
endfunction

function! s:option_to_edit()
  setlocal buftype= modifiable noreadonly
  setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
  if exists('+colorcolumn')
    setlocal colorcolumn=+1
  endif
  if has('conceal')
    setlocal conceallevel=0
  endif
endfunction

command! -buffer -bar HelpEdit call s:option_to_edit()
command! -buffer -bar HelpView call s:option_to_view()
" }}}

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
AutoCmd BufNewFile,BufRead            *.js  set filetype=javascript
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

" Terminal {{{2
if has('nvim')
  AutoCmd TermOpen * set nonumber | set norelativenumber
endif
" }}}2

" HTML & eruby {{{2
augroup HTML
  autocmd!
  autocmd FileType html,eruby call s:map_html_keys()
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

AutoCmd CmdwinEnter * call s:init_cmdwin()

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

let g:ale_change_sign_column_color = 1
let g:ale_set_signs = 1
let g:ale_echo_msg_format = '[%linter%] %s'
highlight ALEWarning ctermfg=0 ctermbg=229
highlight ALEError   ctermfg=0 ctermbg=203
" }}}3

" autoformat {{{3
nnoremap <Leader>a :<C-u>Autoformat<CR>

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
let g:formatters_vue = ['vue_format']

" json
let g:formatdef_jq = '"cat | jq ."'
let g:formatters_json = ['jq']
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

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_addtags_transform = 'camelcase'
" }}}3

" html5 {{{3
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1
" }}}3

" javascript-libraries-syntax {{{3
let g:used_javascript_libs = 'jquery,react,vue'
" }}}3

" jsdoc {{{3
let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_input_description = 1
let g:jsdoc_underscore_private = 1
let g:jsdoc_enable_es6 = 1
" }}}3

" json {{{3
let g:vim_json_syntax_conceal = 0
" }}}3

" markdown {{{3
let g:vim_markdown_conceal = 0
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_new_list_item_indent = 2
" }}}3

" markdown-preview {{{3
let g:mkdp_browserfunc = 'openbrowser#open'
" }}}3

" markdown-quote-syntax {{{3
let g:markdown_quote_syntax_filetypes = {
\ 'javascript' : {
\    'start' : 'javascript',
\ },
\ 'ruby' : {
\    'start' : 'ruby',
\ },
\ 'python' : {
\    'start' : 'python',
\ },
\ 'json' : {
\    'start' : 'json',
\ },
\ 'css' : {
\    'start' : '\\%(css\\|scss\\)',
\ },
\ 'sh' : {
\    'start' : 'sh',
\ },
\}

" }}}3

" marked {{{3
AlterCommand! <cmdwin> mark[ed] MarkedOpen
" }}}3

" MatchTagAlways {{{
let g:mta_filetypes = {
\ 'html' : 1,
\ 'xml'  : 1,
\ 'eruby': 1,
\}
" }}}

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

AutoCmd FileType javascript call s:prettier_settings()
AutoCmd FileType vue        call s:prettier_vue_settings()
" }}}3

" racer {{{3
let g:racer_experimental_completer = 1
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
let g:vim_indent_cont = 0
" }}}3

" vim-lookup {{{3
AutoCmd FileType vim nnoremap <buffer><silent> <C-]>  :call lookup#lookup()<CR>
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

if dein#tap('denite.nvim')
  " Denite

  "" highlight
  call denite#custom#option('default', 'prompt', '>')
  call denite#custom#option('default', 'mode', 'normal')
  call denite#custom#option('default', 'highlight_matched', 'Search')
  call denite#custom#option('default', 'highlight_mode_normal', 'CursorLineNr')
  call denite#custom#option('default', 'highlight_mode_insert', 'CursorLineNr')

  "" keymap
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

  "" option
  call denite#custom#source('_', 'matchers', ['matcher_fuzzy'])
  call denite#custom#source('file_mru', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])

  call denite#custom#source('file_mru', 'converters', ['converter_relative_abbr'])
  call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
  \ [
  \  '*~', '*.o', '*.exe', '*.bak',
  \  '.DS_Store', '*.pyc', '*.sw[po]', '*.class',
  \  '.hg/', '.git/', '.bzr/', '.svn/',
  \  'node_modules', 'vendor/bundle', '__pycache__/', 'venv/',
  \  'tags', 'tags-*', '.png', 'jp[e]g', '.gif',
  \  '*.min.*'
  \ ])

  call denite#custom#var('file_rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'default_opts', ['--follow', '--no-group', '--no-color'])

  "" file & buffer
  " nnoremap <silent> <Leader>p :<C-u>Denite file_rec -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Denite buffer -direction=topleft -mode=insert<CR>
  " nnoremap <silent> <Leader>m :<C-u>Denite file_mru -direction=topleft -mode=insert<CR>

  "" grep
  " nnoremap <silent> <Leader>/ :<C-u>Denite line -auto-preview<CR>
  " nnoremap <silent> <Leader>* :<C-u>DeniteCursorWord line -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep -auto-preview<CR>
  " nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep -auto-preview<CR>

  "" outline
  " nnoremap <silent> <Leader>o :<C-u>Denite outline<CR>

  "" jump
  " nnoremap <silent> <Leader><C-o> :<C-u>Denite jump change -auto-preview -direction=botright<CR>

  "" ctags & gtags
  nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord gtags_context -direction=botright<CR>
  nnoremap <silent> <Leader>gd    :<C-u>Denite gtags_grep -direction=botright<CR>

  "" yank
  " nnoremap <silent> <Leader>p :<C-u>Denite register -direction=topleft<CR>

  "" quickfix
  " nnoremap <silent> <Leader>l :Denite location_list -no-quit -auto-resize<CR>
  " nnoremap <silent> <Leader>q :Denite quickfix -no-quit -auto-resize<CR>

  "" session
  " nnoremap <silent> <Leader>sl :<C-u>Denite session<CR>

  "" resume
  nnoremap <silent> <Leader>dr :<C-u>Denite -resume<CR>
endif

AlterCommand! <cmdwin> u[nite] Unite

if dein#tap('unite.vim')
  " Unite

  "" keymap
  function! s:unite_settings()
    nnoremap <silent> <buffer> <C-n>      j
    nnoremap <silent> <buffer> <C-p>      k
    nnoremap <silent> <buffer> <C-j>      <C-w>j
    nnoremap <silent> <buffer> <C-k>      <C-w>k
    nnoremap <silent> <buffer> <Esc><Esc> q
    inoremap <silent> <buffer> <Esc><Esc> <Esc>q
    imap     <silent> <buffer> <C-w> <Plug>(unite_delete_backward_path)
  endfunction

  AutoCmd FileType unite call s:unite_settings()

  "" file & buffer
  call unite#custom#source('buffer,file_rec,file_rec/async,file_rec/git', 'matchers', ['converter_relative_word', 'matcher_fuzzy'])
  call unite#custom#source('neomru/file', 'matchers', ['converter_relative_word', 'matcher_project_files', 'matcher_fuzzy'])
  call unite#custom#source('file_mru', 'matchers', ['converter_relative_word', 'matcher_fuzzy'])

  let g:unite_source_rec_max_cache_files = 10000
  let g:unite_enable_auto_select = 0
  let g:unite_source_rec_async_command = ['rg', '--files', '--follow', '--glob', '!.git/*']
  " nnoremap <silent> <Leader>p :<C-u>Unite file_rec/async:!<CR>
  " nnoremap <silent> <Leader>m :<C-u>Unite neomru/file<CR>
  " nnoremap <silent> <Leader>M :<C-u>Unite file_mru<CR>
  " nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:!<CR>
  " nnoremap <silent> <Leader>b :<C-u>Unite buffer<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Unite jump change -auto-preview -direction=botright<CR>

  "" outline
  nnoremap <silent> <Leader>o :<C-u>Unite outline -vertical -direction=botright -winwidth=40 -no-quit<CR>

  "" grep
  let g:unite_source_grep_command = 'rg'
  let g:unite_source_grep_default_opts = '--vimgrep --hidden'
  let g:unite_source_grep_recursive_opt = ''

  call unite#custom_source('line', 'sorters', 'sorter_reverse')
  call unite#custom_source('grep', 'sorters', 'sorter_reverse')
  nnoremap <silent> <Leader>/          :<C-u>Unite line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader>//         :<C-u>Unite line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader>*          :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader>**         :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>/  :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader><Leader>// :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>*  :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader><Leader>** :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>

  "" yank
  let g:unite_source_history_yank_enable = 1
  nnoremap <silent> <Leader><Leader>p :<C-u>Unite yankround<CR>

  "" quickfix
  " let g:unite_quickfix_filename_is_pathshorten = 0
  " call unite#custom_source('quickfix', 'sorters', 'sorter_reverse')
  " call unite#custom_source('location_list', 'sorters', 'sorter_reverse')
  " nnoremap <silent> <Leader>q :<C-u>Unite quickfix -direction=botright -no-quit<CR>
  " nnoremap <silent> <Leader>l :<C-u>Unite location_list -direction=botright -no-quit<CR>

  "" session
  " nnoremap <Leader>ss :<C-u>UniteSessionSave<CR>
  " nnoremap <Leader>sl :<C-u>UniteSessionLoad<CR>

  "" resume
  " nnoremap <silent> <Leader>re :<C-u>Unite -resume<CR>
endif
" }}}3

" fzf {{{
nnoremap <silent> <leader>f :FZFOpenFile<CR>
command! FZFOpenFile call FZFOpenFileFunc()

function! FZFOpenFileFunc()
  let s:file_path = expand('<cfile>')

  if s:file_path ==# ''
    echo '[Error] <cfile> return empty string.'
    return 0
  endif

  call fzf#run({
  \ 'source': 'rg --files --hidden --follow --glob "!.git/*"',
  \ 'sink': 'e',
  \ 'options': '-x +s --query=' . shellescape(s:file_path),
  \ 'window': 'top split new'})
endfunction
" }}}

" fzf-preview {{{3
let g:fzf_preview_filelist_command = 'rg --files --hidden --follow --glob "!.git/*"'

nnoremap <silent> <Leader>p  :<C-u>ProjectFilesPreview<CR>
nnoremap <silent> <Leader>b  :<C-u>BuffersPreview<CR>
nnoremap <silent> <Leader>m  :<C-u>ProjectOldFilesPreview<CR>
nnoremap <silent> <Leader>M  :<C-u>OldFilesPreview<CR>
nnoremap <silent> <Leader>gf :<C-u>ProjectGrepPreview<CR>
" }}}3

" deoplete.nvim && neosnippet.vim {{{3
if dein#tap('deoplete.nvim') && dein#tap('neosnippet')
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#enable_camel_case = 1
  let g:deoplete#enable_ignore_case = 0
  let g:deoplete#auto_complete_delay = 0
  let g:deoplete#enable_refresh_always = 0
  let g:deoplete#file#enable_buffer_path = 1
  let g:deoplete#max_list = 10000
  let g:deoplete#auto_complete_start_length = 3
  let g:deoplete#tag#cache_limit_size = 5000000

  call deoplete#custom#source('_', 'converters', [
  \ 'converter_remove_paren',
  \ 'converter_remove_overlap',
  \ 'converter_truncate_abbr',
  \ 'converter_truncate_menu',
  \ 'converter_auto_delimiter',
  \ ])

  let g:deoplete#sources#go#gocode_binary = $GOPATH . '/bin/gocode'
  let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

  call deoplete#custom#source('LanguageClient', 'rank', 1000)
  call deoplete#custom#source('around',         'rank',  900)
  call deoplete#custom#source('neosnippet',     'rank',  900)
  call deoplete#custom#source('ternjs',         'rank',  900)
  call deoplete#custom#source('flow',           'rank',  900)
  call deoplete#custom#source('ruby',           'rank',  900)
  " call deoplete#custom#source('solargraph',     'rank',  900)
  call deoplete#custom#source('jedi',           'rank',  900)
  call deoplete#custom#source('go',             'rank',  900)
  call deoplete#custom#source('racer',          'rank',  900)
  call deoplete#custom#source('emoji',          'rank',  900)
  call deoplete#custom#source('vim',            'rank',  900)
  call deoplete#custom#source('gtags',          'rank',  800)
  call deoplete#custom#source('tag',            'rank',  700)
  call deoplete#custom#source('member',         'rank',  600)
  call deoplete#custom#source('buffer',         'rank',  500)
  call deoplete#custom#source('omni',           'rank',  400)
  call deoplete#custom#source('syntax',         'rank',  400)
  call deoplete#custom#source('tmux',           'rank',  300)
  call deoplete#custom#source('file',           'rank',  300)
  call deoplete#custom#source('dictionary',     'rank',  200)
  call deoplete#custom#source('look',           'rank',  100)

  call deoplete#custom#source('LanguageClient', 'mark', '[LC]')
  call deoplete#custom#source('around',         'mark', '[around]')
  call deoplete#custom#source('neosnippet',     'mark', '[snippet]')
  call deoplete#custom#source('member',         'mark', '[member]')
  call deoplete#custom#source('buffer',         'mark', '[buffer]')
  call deoplete#custom#source('gtags',          'mark', '[gtags]')
  call deoplete#custom#source('tag',            'mark', '[tag]')
  call deoplete#custom#source('dictionary',     'mark', '[dict]')
  call deoplete#custom#source('omni',           'mark', '[omni]')
  call deoplete#custom#source('syntax',         'mark', '[syntax]')
  call deoplete#custom#source('tern',           'mark', '[tern]')
  call deoplete#custom#source('flow',           'mark', '[flow]')
  call deoplete#custom#source('ruby',           'mark', '[ruby]')
  " call deoplete#custom#source('solargraph',     'mark', '[solar]')
  call deoplete#custom#source('jedi',           'mark', '[jedi]')
  call deoplete#custom#source('go',             'mark', '[go]')
  call deoplete#custom#source('racer',          'mark', '[racer]')
  call deoplete#custom#source('emoji',          'mark', '[emoji]')
  call deoplete#custom#source('vim',            'mark', '[vim]')
  call deoplete#custom#source('tmux',           'mark', '[tmux]')

  let s:deoplete_default_sources = ['around', 'tag', 'member', 'buffer', 'omni', 'syntax', 'file', 'dictionary', 'neosnippet', 'gtags', 'tmux', 'look'] " LanguageClient
  let g:deoplete#sources = {}
  let g:deoplete#sources._          = s:deoplete_default_sources
  let g:deoplete#sources.javascript = s:deoplete_default_sources + ['LanguageClient', 'ternjs', 'flow']
  let g:deoplete#sources.typescript = s:deoplete_default_sources + ['LanguageClient', 'ternjs']
  let g:deoplete#sources.vue        = s:deoplete_default_sources + ['LanguageClient', 'ternjs']
  " let g:deoplete#sources.javascript = s:deoplete_default_sources + ['ternjs', 'flow']
  " let g:deoplete#sources.typescript = s:deoplete_default_sources + ['ternjs']
  " let g:deoplete#sources.vue        = s:deoplete_default_sources + ['ternjs']
  let g:deoplete#sources.ruby       = s:deoplete_default_sources + ['ruby']
  let g:deoplete#sources.eruby      = s:deoplete_default_sources + ['ruby']
  " let g:deoplete#sources.ruby       = s:deoplete_default_sources + ['ruby', 'solargraph']
  " let g:deoplete#sources.eruby      = s:deoplete_default_sources + ['ruby', 'solargraph']
  let g:deoplete#sources.python     = s:deoplete_default_sources + ['jedi']
  let g:deoplete#sources.go         = s:deoplete_default_sources + ['go']
  let g:deoplete#sources.rust       = s:deoplete_default_sources + ['LanguageClient', 'racer']
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

  let s:deoplete_default_omni_sources = []
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

  inoremap <silent> <CR> <C-r>=<SID>deoplete_cr_function()<CR>
  inoremap <silent> <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
  inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
  inoremap <silent> <expr> ' pumvisible() ? deoplete#close_popup() : "'"
  imap <expr> <Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
  smap <expr> <Tab> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"

  function! s:deoplete_cr_function()
    if neosnippet#expandable_or_jumpable()
      return "\<Plug>(neosnippet_expand_or_jump)"
    else
      return "\<C-y>" . deoplete#smart_close_popup()
    endif
  endfunction

  inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
endif
" }}}3

" LanguageClient {{{3
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
\ 'vue': ['vls'],
\ 'html': [],
\ 'css': [],
\ 'javascript': ['javascript-typescript-stdio'],
\ 'typescript': ['javascript-typescript-stdio'],
\ 'rust': ['rustup', 'run', 'nightly', 'rls'],
\ }
" }}}3

" }}}2

" Git {{{2

" agit {{{3
AlterCommand! <cmdwin> agit       Agit
AlterCommand! <cmdwin> agitf[ile] AgitFile

if dein#tap('agit.vim')
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
endif
" }}}3

" committia {{{3
let g:committia_open_only_vim_starting = 0
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info)
  imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
  imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
endfunction
" }}}3

" git-gutter {{{3
if dein#tap('vim-gitgutter')
  let g:gitgutter_map_keys = 0
  nmap gn <Plug>GitGutterNextHunk
  nmap gp <Plug>GitGutterPrevHunk
endif
" }}}3

" git-switcher {{{3
AlterCommand! <cmdwin> gss GswSave
AlterCommand! <cmdwin> gsl GswLoad
" }}}3

" gina {{{3
AlterCommand! <cmdwin> git   Gina
AlterCommand! <cmdwin> gina  Gina
AlterCommand! <cmdwin> gs    Gina<Space>status
AlterCommand! <cmdwin> gci   Gina<Space>commit
AlterCommand! <cmdwin> gd    Gina<Space>diff
AlterCommand! <cmdwin> gdc   Gina<Space>diff<Space>--cached
AlterCommand! <cmdwin> blame Gina<Space>blame

if dein#tap('gina.vim')
  call gina#custom#command#option('status', '--short')
  call gina#custom#command#option('status', '--opener', 'split')
  call gina#custom#mapping#nmap('status', '<C-j>', '<C-w>j', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('status', '<C-k>', '<C-w>k', {'noremap': 1, 'silent': 1})

  call gina#custom#command#option('branch', '--opener', 'split')
  call gina#custom#mapping#nmap('branch', 'g<CR>', '<Plug>(gina-commit-checkout-track)')

  call gina#custom#command#option('diff',   '--opener', 'vsplit')
  call gina#custom#command#option('log',    '--opener', 'vsplit')

  call gina#custom#action#alias('/\%(blame\|log\|reflog\)', 'preview', 'topleft show:commit:preview')
  call gina#custom#mapping#nmap('/\%(blame\|log\|reflog\)', 'p', ":<C-u>call gina#action#call('preview')<CR>", {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', '<C-l>', '<C-w>l', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('blame', '<C-r>', '<Plug>(gina-blame-redraw)', {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('blame', 'j', 'j<Plug>(gina-blame-echo)')
  call gina#custom#mapping#nmap('blame', 'k', 'k<Plug>(gina-blame-echo)')
endif
" }}}3

" }}}2

" filer {{{2

" vimfiler {{{3
if dein#tap('vimfiler')
  " let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_execute_file_list = {'jpg': 'open', 'jpeg': 'open', 'gif': 'open', 'png': 'open'}
  " call vimfiler#custom#profile('default', 'context', {
  "       \ 'explorer' : 1,
  "       \ 'winwidth' : 35,
  "       \ 'split' : 1,
  "       \ 'simple' : 1,
  "       \ })
  let g:vimfiler_enable_auto_cd = 1
  let g:vimfiler_ignore_pattern = '^\%(.git\|.DS_Store\)$'
  let g:vimfiler_trashbox_directory = '~/.Trash'
  nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer -split -winwidth=35 -simple<CR>
  nnoremap <silent> <Leader>E :<C-u>VimFilerExplorer -find -split -winwidth=35 -simple<CR>

  function! s:vimfiler_settings()
    nmap <buffer> R <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <C-l> <C-w>l
    nmap <buffer> <C-j> <C-w>j
  endfunction

  AutoCmd FileType vimfiler call s:vimfiler_settings()
endif
" }}}3

" vaffle {{{3
AlterCommand! <cmdwin> va[fle] Vaffle
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
nnoremap <silent> <Leader>ga "syiwq:Ack! <C-r>=substitute(@s, '/', '\\/', 'g')<CR>
" }}}3

" incsearch & anzu & asterisk {{{3
if dein#tap('incsearch.vim')
  let g:incsearch#magic = '\v'
  let g:anzu_status_format = '(%i/%l)'

  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

  AutoCmd VimEnter * call s:incsearch_keymap()
  function! s:incsearch_keymap()
    IncSearchNoreMap <C-d> <Over>(incsearch-scroll-f)
    IncSearchNoreMap <C-u> <Over>(incsearch-scroll-b)
  endfunction
endif

if dein#tap('vim-anzu') && dein#tap('vim-asterisk')
  map n  <Plug>(anzu-n)zzzv
  map N  <Plug>(anzu-N)zzzv
  map *  <Plug>(asterisk-z*)
  map #  <Plug>(asterisk-z#)
  map g* <Plug>(asterisk-gz*)
  map g# <Plug>(asterisk-gz#)
  nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <Bar> AnzuClearSearchStatus<CR>
endif
" }}}3

" clever-f {{{3
let g:clever_f_not_overwrites_standard_mappings = 0

nmap f <Plug>(clever-f-f)
vmap f <Plug>(clever-f-f)
nmap F <Plug>(clever-f-F)
vmap F <Plug>(clever-f-F)
nmap t <Plug>(clever-f-t)
vmap t <Plug>(clever-f-t)
nmap T <Plug>(clever-f-T)
vmap T <Plug>(clever-f-T)
" }}}3

" easy-align {{{3
vnoremap <Enter> :EasyAlign!<CR>

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

map  S  <Plug>(easymotion-s2)
nmap S  <Plug>(easymotion-overwin-f2)
map  sl <Plug>(easymotion-bd-jk)
nmap sl <Plug>(easymotion-overwin-line)
omap f  <Plug>(easymotion-fl)
omap t  <Plug>(easymotion-tl)
omap F  <Plug>(easymotion-Fl)
omap T  <Plug>(easymotion-Tl)
" }}}3

" edgemotion {{{3
map <silent> <Leader>j <Plug>(edgemotion-j)
map <silent> <Leader>k <Plug>(edgemotion-k)
" }}}3

" eregex {{{3
let g:eregex_default_enable = 0

nnoremap <Leader>R "syiwq:%S/<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>
nnoremap <Leader>r q:%S//g<Left><Left>
vnoremap <Leader>r "syq:%S/<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>
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
  function! Hook_on_post_source_lexima() abort
    let l:rules = []

    "" Ampersand
    " let l:rules += [
    " \ {'char': '&',                        'input': '&& '},
    " \ {'char': '&',     'at': '\S\%#',     'input': ' && '},
    " \ {'char': '&',     'at': '\s\%#',     'input': '&& '},
    " \ {'char': '&',     'at': '&&\s\%#',   'input': '<BS><BS>'},
    " \ {'char': '&',     'at': '&\%#',      'priority': 10},
    " \ {'char': '<C-h>', 'at': '\s&&\s\%#', 'input': '<BS><BS><BS><BS>'},
    " \ {'char': '<C-h>', 'at': '&&\s\%#',   'input': '<BS><BS><BS>'},
    " \ {'char': '<C-h>', 'at': '&&\%#',     'input': '<BS><BS>'},
    " \ ]

    "" Bar
    " let l:rules += [
    " \ {'char': '<Bar>',                    'input': '|| '},
    " \ {'char': '<Bar>', 'at': '\S\%#',     'input': ' || '},
    " \ {'char': '<Bar>', 'at': '\s\%#',     'input': '|| '},
    " \ {'char': '<Bar>', 'at': '||\s\%#',   'input': '<BS><BS><BS><BS>|'},
    " \ {'char': '<Bar>', 'at': '|\%#',      'input': '<Bar>', 'priority': 10},
    " \ {'char': '<C-h>', 'at': '\s||\s\%#', 'input': '<BS><BS><BS><BS>'},
    " \ {'char': '<C-h>', 'at': '||\s\%#',   'input': '<BS><BS><BS>'},
    " \ {'char': '<C-h>', 'at': '||\%#',     'input': '<BS><BS>'},
    " \ ]

    "" Parenthesis
    let l:rules += [
    \ {'char': '(',     'at': '(\%#)', 'input': '<Del>'},
    \ {'char': '(',     'at': '(\%#'},
    \ {'char': '<C-h>', 'at': '(\%#)', 'input': '<BS><Del>'},
    \ ]

    "" Brace
    let l:rules += [
    \ {'char': '{',     'at': '{\%#}', 'input': '<Del>'},
    \ {'char': '{',     'at': '{\%#'},
    \ {'char': '<C-h>', 'at': '{\%#}', 'input': '<BS><Del>'},
    \ ]

    "" Bracket
    let l:rules += [
    \ {'char': '[',     'at': '\[\%#\]', 'input': '<Del>'},
    \ {'char': '[',     'at': '\[\%#'},
    \ {'char': '<C-h>', 'at': '\[\%#\]', 'input': '<BS><Del>'},
    \ ]

    "" Sinble Quote
    let l:rules += [
    \ {'char': "'",     'at': "'\\%#'", 'input': '<Del>'},
    \ {'char': "'",     'at': "'\\%#"},
    \ {'char': "'",     'at': "''\\%#"},
    \ {'char': '<C-h>', 'at': "'\\%#'", 'input': '<Del>'},
    \ ]

    "" Double Quote
    let l:rules += [
    \ {'char': '"',     'at': '"\%#"', 'input': '<Del>'},
    \ {'char': '"',     'at': '"\%#'},
    \ {'char': '"',     'at': '""\%#'},
    \ {'char': '<C-h>', 'at': '"\%#"', 'input': '<Del>'},
    \ ]

    "" Back Quote
    let l:rules += [
    \ {'char': '`', 'at': '`'},
    \ ]

    "" ruby
    let l:rules += [
    \ {'char': '&', 'filetype': ['ruby', 'eruby'], 'priority': 10},
    \ {'char': '<Bar>', 'at': 'do\%#',     'input': '<Space><Bar><Bar><Left>', 'input_after': '<CR>end', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<Bar>', 'at': 'do\s\%#',   'input': '<Bar><Bar><Left>',        'input_after': '<CR>end', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<Bar>', 'at': '{\%#}',     'input': '<Space><Bar><Bar><Left>', 'input_after': '<Space>', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<Bar>', 'at': '{\s\%#\s}', 'input': '<Bar><Bar><Left>',        'input_after': '<Space>', 'filetype': ['ruby', 'eruby']},
    \ ]

    "" markdown
    let l:rules += [
    \ {'char': '`', 'at': '``\%#', 'input_after': '<CR><CR>```', 'filetype': 'markdown', 'priority': 10},
    \ ]

    "" vim
    let l:rules += [
    \ {'char': '&',                'filetype': 'vim', 'priority': 10},
    \ {'char': '&', 'at': '\S\%#', 'filetype': 'vim', 'priority': 10},
    \ {'char': '&', 'at': '\s\%#', 'filetype': 'vim', 'priority': 10},
    \ {'char': '&', 'at': '&\%#',                     'priority': 10},
    \ {'char': '{', 'at': '{\%#$', 'input': '{{<CR>', 'input_after': '<CR>" }}}', 'filetype': 'vim', 'priority': 10},
    \ ]

    for l:rule in l:rules
      call lexima#add_rule(l:rule)
    endfor
  endfunction
endif
" }}}3

" NrrwRgn {{{3
AlterCommand! <cmdwin> nr NR
" }}}3

" operator-replace {{{3
map _ <Plug>(operator-replace)
" }}}3

" qfreplace {{{3
AutoCmd FileType qf nnoremap <buffer> r :<C-u>Qfreplace<CR>
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich')
  function! Hook_on_post_source_sandwich() abort
    let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
    let g:sandwich#recipes += [
    \   { 'buns': ['\/', '\/'] },
    \   { 'buns': ['_', '_'] },
    \   { 'buns': ['`', '`'] },
    \ ]
  endfunction
endif
" }}}3

" skk {{{
let g:skk_control_j_key = ''
let g:skk_large_jisyo = expand('~/.config/nvim/dict/SKK-JISYO.L')
" }}}

" tcomment {{{3
noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history = 1000
  let g:yankround_use_region_hl = 1

  AutoCmd ColorScheme * highlight YankRoundRegion ctermfg=209 ctermbg=237
  AutoCmd ColorScheme * highlight YankRoundRegion ctermfg=209 ctermbg=237

  nmap p     <Plug>(yankround-p)
  nmap P     <Plug>(yankround-P)
  cmap <C-r> <Plug>(yankround-insert-register)
  cmap <C-y> <Plug>(yankround-pop)

  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "q:bprevious\<CR>"
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "q:bnext\<CR>"
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = ['markdown', 'diff', 'qf', 'tag', 'help', 'gitcommit', 'vimfiler', 'vimfiler:explorer', 'unite', 'denite']
" }}}3

" fastfold {{{3
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
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
let g:indentLine_enabled = 0
let g:indentLine_fileTypeExclude = ['json']
nnoremap <silent> <Leader>i :<C-u>:IndentLinesToggle<CR>
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'iceberg_yano',
  \ 'mode_map': {'c': 'NORMAL'},
  \ 'active': {
  \   'left': [
  \     [ 'mode', 'paste' ],
  \     [ 'readonly', 'filepath', 'filename', 'anzu' ]
  \    ],
  \   'right': [
  \     [ 'percent', 'lineinfo' ],
  \     [ 'fileformat', 'fileencoding', 'filetype' ],
  \     [ 'linter_errors', 'linter_warnings', 'linter_ok', 'linter_unload' ]
  \   ]
  \ },
  \ 'inactive': {
  \   'left': [ [], [], [ 'filepath', 'filename' ] ],
  \   'right': [
  \     [ 'percent', 'lineinfo' ],
  \     [ 'fileformat', 'fileencoding', 'filetype' ],
  \   ]
  \ },
  \ 'tabline': {
  \   'left': [ [ 'branch' ], [ 'gitstatus' ], [ 'tabs' ] ],
  \   'right': [ [] ],
  \ },
  \ 'tab': {
  \   'active':   [ 'tabwinnum', 'readonly', 'filename', 'modified' ],
  \   'inactive': [ 'tabwinnum', 'readonly', 'filename', 'modified' ]
  \ },
  \ 'component': {
  \   'fileformat':   "%{ Lightline_is_visible() ? &fileformat : '' }",
  \   'fileencoding': "%{ Lightline_is_visible() ? (strlen(&fileencoding) ? &fileencoding : &encoding) : ''}",
  \   'lineinfo':     "%{ !Lightline_is_visible() ? '' : printf('%03d:%03d', line('.'), col('.')) }",
  \   'percent':      "%{ !Lightline_is_visible() ? '' : printf('%3d%%', float2nr((1.0 * line('.')) / line('$') * 100.0)) }",
  \   'readonly':     "%{&readonly ? 'RO' : ''}",
  \   'paste':        "%{&paste ? 'PASTE' : ''}",
  \  },
  \ 'component_function': {
  \   'mode':      'lightline#mode',
  \   'filepath':  'Lightline_filepath',
  \   'filename':  'Lightline_filename',
  \   'branch':    'gina#component#repo#preset',
  \   'gitstatus': 'Lightline_git_status',
  \   'anzu':      'anzu#search_status',
  \ },
  \ 'tab_component': {
  \   'readonly': "gettabwinvar(a:n, tabpagewinnr(a:n), '&readonly') ? 'RO' : ''",
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum':   'Lightline_tab_win_num',
  \ },
  \ 'component_visible_condition': {
  \   'lineinfo':     'Lightline_is_visible()',
  \   'fileencoding': 'Lightline_is_visible()',
  \   'fileformat':   'Lightline_is_visible()',
  \   'percent':      'Lightline_is_visible()',
  \ },
  \ 'component_function_visible_condition': {
  \   'modified': '&modified||!&modifiable',
  \   'readonly': '&readonly',
  \   'paste':    '&paste',
  \   'spell':    '&spell',
  \ },
  \ 'component_type': {
  \   'linter_unload':   'unload',
  \   'linter_errors':   'error',
  \   'linter_warnings': 'warning',
  \   'linter_ok':       'ok',
  \ },
  \ 'component_expand': {
  \   'linter_unload':   'Lightline_ale_unload',
  \   'linter_errors':   'lightline#ale#errors',
  \   'linter_warnings': 'lightline#ale#warnings',
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

  function! Lightline_is_visible() abort
    return 60 <= winwidth(0)
  endfunction

  function! Lightline_filepath() abort
    let l:path_string = filereadable(expand('%:p:~')) || winwidth(0) < 60 ? '' : expand('%:p:~:h')
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

  function! Lightline_filename() abort
    if expand('%:t') !=# ''
      return expand('%:t') . (&modified ? ' +' : '')
    else
      return '[No Name]'
    endif
  endfunction

  function! Lightline_tab_win_num(n) abort
    return a:n . ':' . len(tabpagebuflist(a:n))
  endfunction

  function! Lightline_ale_ok() abort
    return count(s:ale_filetypes, &filetype) != 0 ? lightline#ale#ok() : ''
  endfunction

  function! Lightline_ale_unload() abort
    return count(s:ale_filetypes, &filetype) == 0 ? 'UNUSE' : ''
  endfunction

  function! Lightline_git_status() abort
    if gina#component#repo#branch() ==# ''
      return ''
    endif

    let l:staged     = gina#component#status#staged()
    let l:unstaged   = gina#component#status#unstaged()
    let l:conflicted = gina#component#status#conflicted()
    return printf(
    \ 'S: %s, U: %s, C: %s',
    \ l:staged ==# '' ? 0 : l:staged,
    \ l:unstaged ==# '' ? 0 : l:unstaged,
    \ l:conflicted ==# '' ? 0 : l:conflicted,
    \)
  endfunction
endif
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
if dein#tap('vim-operator-flashy')
  map  y <Plug>(operator-flashy)
  nmap Y <Plug>(operator-flashy)$
endif
" }}}3

" parenmatch {{{3
let g:loaded_matchparen = 1
" }}}3

" quickhl {{{3
nmap <Leader>h <Plug>(quickhl-manual-this)
xmap <Leader>h <Plug>(quickhl-manual-this)
nmap <Leader>H <Plug>(quickhl-manual-reset)
xmap <Leader>H <Plug>(quickhl-manual-reset)
" }}}3

" startify {{{3
let g:startify_custom_header = [
\ '╦ ╦┌┐┌┬  ┬┌┬┐┬┌┬┐┌─┐┌┬┐  ╔═╗┬  ┬ ┬┌─┐┬┌┐┌  ╦ ╦┌─┐┬─┐┬┌─┌─┐',
\ '║ ║││││  │││││ │ ├┤  ││  ╠═╝│  │ ││ ┬││││  ║║║│ │├┬┘├┴┐└─┐',
\ '╚═╝┘└┘┴─┘┴┴ ┴┴ ┴ └─┘─┴┘  ╩  ┴─┘└─┘└─┘┴┘└┘  ╚╩╝└─┘┴└─┴ ┴└─┘',
\]

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
if dein#tap('rainbow')
  let g:rainbow_active = 1
  let g:rainbow_conf = {}
  let g:rainbow_conf.ctermfgs = [ '110', '150', '109', '216', '140', '203' ]
  let g:rainbow_conf.diff = 0
endif
" }}}3

" smartnumber {{{3
let g:snumber_enable_startup = 1
nnoremap <silent> <Leader>n :SNumbersToggleRelative<CR>
" }}}3

" zenspace {{{3
let g:zenspace#default_mode = 'on'
" }}}3

" }}}2

" tmux {{{2

" vimux {{{3
nnoremap <silent> <Leader>vp :<C-u>VimuxPromptCommand<CR>
nnoremap <silent> <Leader>vl :<C-u>VimuxRunLastCommand<CR>
nnoremap <silent> <Leader>vi :<C-u>VimuxInspectRunner<CR>
nnoremap <silent> <Leader>vz :<C-u>VimuxZoomRunner<CR>
nnoremap <silent> <Leader>vc :<C-u>VimuxCloseRunner<CR>
" }}}3

" }}}2

" Util {{{2

" aho-bakaup {{{3
let g:bakaup_auto_backup = 1
let g:bakaup_backup_dir = expand('~/.config/nvim/backup')
" }}}3

" automatic {{{
function! s:my_temp_win_init(config, context)
  nnoremap <silent> <buffer> q :<C-u>q<CR>
endfunction

let g:automatic_default_set_config = {
\   'apply':  function('s:my_temp_win_init'),
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
\   'match': { 'filetype': 'qf' },
\ },
\ {
\   'match': { 'filetype': 'diff' },
\   'set': {
\     'move': 'right',
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
\   }
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
AutoCmd FileType *      nnoremap <silent> <Leader>d :BD<CR>
AutoCmd FileType help   nnoremap <silent> <Leader>d :BW<CR>
AutoCmd FileType diff   nnoremap <silent> <Leader>d :BW<CR>
AutoCmd FileType git    nnoremap <silent> <Leader>d :BW<CR>
AutoCmd FileType vaffle nnoremap <silent> <Leader>d :BW<CR>
" }}}3

" capture {{{3
AlterCommand! <cmdwin> cap[ture] Capture
" }}}3

" expand-region {{{3
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
let g:expand_region_text_objects_ruby = {
\ 'im' :0,
\ 'am' :0
\ }
" }}}3

" maximizer {{{3
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
" }}}3

" open-googletranslate {{{3
let g:opengoogletranslate#openbrowsercmd = 'electron-open --without-focus'
command! -range Trans <line1>,<line2>OpenGoogleTranslate
" }}}3

" quickrun {{{
let g:quickrun_config={'_': {'split': 'vertical rightbelow'}}
nnoremap <silent> \r :QuickRun<CR>
" }}}

" ref {{{3
AlterCommand! <cmdwin> alc Ref<Space>webdict<Space>alc

if dein#tap('vim-ref')
  let g:ref_source_webdict_sites = {
  \ 'alc' : {
  \   'url' : 'http://eow.alc.co.jp/%s/UTF-8/'
  \   }
  \ }
endif
" }}}3

" session {{{3
AlterCommand! <cmdwin> ss SessionSave!
AlterCommand! <cmdwin> so SessionOpen
" }}}3

" scratch {{{3
AlterCommand! <cmdwin> sc[ratch] Scratch

if dein#tap('scratch.vim')
  let g:scratch_no_mappings = 1
endif
" }}}3

" submode & operator-convert-case {{{3
if dein#tap('vim-submode')
  let g:submode_keep_leaving_key = 1

  "" jump
  call submode#enter_with('jump', 'n', '', 'g;', 'g;')
  call submode#map('jump', 'n', '', ';', 'g;')

  "" tab
  call submode#enter_with('changetab', 'n', '', 'gh', ':<C-u>tabprevious<CR>')
  call submode#enter_with('changetab', 'n', '', 'gl', ':<C-u>tabnext<CR>')
  call submode#map('changetab', 'n', '', 'h', ':<C-u>tabprevious<CR>')
  call submode#map('changetab', 'n', '', 'l', ':<C-u>tabnext<CR>')

  "" operator-convert-case
  call submode#enter_with('convert', 'n', '', '<leader>cl', ':ConvertCaseLoop<CR>')
  call submode#map('convert', 'n', '', 'c', ':ConvertCaseLoop<CR>')
endif
" }}}3

" tagbar {{{3
AlterCommand! <cmdwin> tag TagbarOpen<Space>j
" }}}3

" undotree {{{3
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0
nnoremap <silent> <C-w><C-w> :call WindowSwap#EasyWindowSwap()<CR>
" }}}3

" winresizer {{{3
nnoremap <silent> <Leader><C-e> :WinResizerStartResize<CR>
" }}}3

" }}}2

" }}}1

" Load Colorscheme Later {{{1
syntax enable

" iceberg {{{2
silent! colorscheme iceberg
highlight Search       ctermfg=none ctermbg=237
highlight LineNr       ctermfg=241
highlight CursorLineNr ctermbg=237 ctermfg=253
highlight CursorLine   ctermbg=235
highlight PmenuSel     cterm=reverse ctermfg=33 ctermbg=222
highlight Visual       ctermfg=159 ctermbg=23
highlight NonText      ctermfg=60
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
