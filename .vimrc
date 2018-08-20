" Global Variables {{{1
let g:ale_filetypes = [
\ 'javascript',
\ 'typescript',
\ 'vue',
\ 'ruby',
\ 'eruby',
\ 'python',
\ 'go',
\ 'rust',
\ 'json',
\ 'html',
\ 'css',
\ 'scss',
\ 'vim',
\ 'sh',
\ 'bash',
\ 'zsh',
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
  " call dein#add('Quramy/tsuquyomi',                       {'lazy': 1, 'on_ft': 'typescript'})
  " call dein#add('pocke/iro.vim',                          {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('HerringtonDarkholme/yats.vim',           {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('MaxMEllon/vim-jsx-pretty',               {'lazy': 1, 'on_ft': 'javascript'})
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
  call dein#add('kchmck/vim-coffee-script',               {'lazy': 1, 'on_ft': 'coffee'})
  call dein#add('keith/tmux.vim',                         {'lazy': 1, 'on_ft': 'tmux'})
  call dein#add('mattn/emmet-vim',                        {'lazy': 1, 'on_ft': ['html', 'eruby', 'javascript', 'vue']})
  call dein#add('mhartington/nvim-typescript',            {'lazy': 1, 'on_ft': 'typescript', 'build': './install.sh'})
  call dein#add('noprompt/vim-yardoc',                    {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('othree/csscomplete.vim',                 {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('othree/es.next.syntax.vim',              {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/html5.vim',                       {'lazy': 1, 'on_ft': ['html', 'markdown', 'eruby']})
  call dein#add('othree/javascript-libraries-syntax.vim', {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/jspc.vim',                        {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('othree/yajs.vim',                        {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('pearofducks/ansible-vim',                {'lazy': 1, 'on_ft': ['ansible', 'ansible_templete', 'ansible_hosts']})
  call dein#add('plasticboy/vim-markdown',                {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('posva/vim-vue',                          {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('prettier/vim-prettier',                  {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'vue', 'css', 'scss', 'json', 'graphql', 'markdown']})
  call dein#add('rust-lang/rust.vim',                     {'lazy': 1, 'on_ft': 'rust'})
  call dein#add('slim-template/vim-slim',                 {'lazy': 1, 'on_ft': 'slim'})
  call dein#add('stephpy/vim-yaml',                       {'lazy': 1, 'on_ft': 'yaml'})
  call dein#add('tell-k/vim-autopep8',                    {'lazy': 1, 'on_ft': 'python'})
  call dein#add('tpope/vim-rails',                        {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('vim-ruby/vim-ruby',                      {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
  " }}}3

  " ALE {{{
  call dein#add('w0rp/ale', {'lazy': 1, 'on_ft': g:ale_filetypes})
  " }}}

  " Git {{{3
  call dein#add('ToruIwashita/git-switcher.vim', {'lazy': 1, 'on_cmd': ['Gsw', 'GswSave', 'GswLoad']})
  call dein#add('airblade/vim-gitgutter')
  call dein#add('airblade/vim-rooter',           {'lazy': 1, 'on_cmd': 'Rooter'})
  call dein#add('cohama/agit.vim',               {'lazy': 1, 'on_cmd': ['Agit', 'AgitFile', 'AgitGit', 'AgitDiff']})
  call dein#add('hotwatermorning/auto-git-diff', {'lazy': 1, 'on_ft': 'gitrebase'})
  call dein#add('lambdalisue/gina.vim',          {'lazy': 1, 'on_cmd': 'Gina', 'hook_source': 'call Hook_on_post_source_gina()'})
  call dein#add('lambdalisue/vim-unified-diff')
  call dein#add('rhysd/committia.vim',           {'lazy': 1, 'on_ft': 'gitcommit'})
  call dein#add('rhysd/conflict-marker.vim')
  " }}}3

  " Completion {{{3
  if has('nvim')
    call dein#add('Shougo/deoplete.nvim')

    call dein#add('Shougo/context_filetype.vim')
    call dein#add('Shougo/neco-syntax')
    call dein#add('Shougo/neco-vim')
    call dein#add('Shougo/neosnippet')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('jsfaint/gen_tags.vim')
    call dein#add('ujihisa/neco-look')
    call dein#add('wellle/tmux-complete.vim')

    " call dein#add('blueyed/vim-auto-programming', {'rev': 'neovim'})
    " call dein#add('fishbullet/deoplete-ruby',   {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
    call dein#add('autozimu/LanguageClient-neovim', {'lazy': 1, 'on_ft': ['typescript', 'ruby'], 'rev': 'next', 'build': 'bash install.sh'})
    call dein#add('carlitux/deoplete-ternjs',       {'lazy': 1, 'on_ft': 'javascript'})
    call dein#add('machakann/vim-Verdin',           {'lazy': 1, 'on_ft': 'vim'})
    call dein#add('wokalski/autocomplete-flow',     {'lazy': 1, 'on_ft': 'javascript'})
    call dein#add('zchee/deoplete-jedi',            {'lazy': 1, 'on_ft': 'python'})

    " call dein#add('ncm2/ncm2')
    " call dein#add('roxma/nvim-yarp')
    "
    " call dein#add('prabirshrestha/async.vim')
    " call dein#add('prabirshrestha/vim-lsp')
    " call dein#add('ncm2/ncm2-vim-lsp')
    "
    " call dein#add('ncm2/ncm2-bufword')
    " call dein#add('ncm2/ncm2-path')
    " call dein#add('ncm2/ncm2-tmux')
    " call dein#add('ncm2/ncm2-tagprefix')
    " call dein#add('filipekiss/ncm2-look.vim')
    " call dein#add('ncm2/ncm2-syntax')
    " call dein#add('ncm2/ncm2-jedi')
    " call dein#add('ncm2/ncm2-vim')
    " call dein#add('ncm2/ncm2-go')
    " call dein#add('yuki-ycino/ncm2-dictionary')
  endif
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/unite.vim')

  call dein#add('ozelentok/denite-gtags')
  call dein#add('hewes/unite-gtags')
  call dein#add('Shougo/neomru.vim')

  call dein#add('junegunn/fzf', {'build': './install --bin', 'merged': 0})
  call dein#add('junegunn/fzf.vim')
  call dein#add('yuki-ycino/fzf-preview.vim',
  \ {'lazy': 1,
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
  call dein#add('Shougo/vimfiler')
  call dein#add('cocopon/vaffle.vim')
  " }}}3

  " textobj & operator {{{3
  call dein#add('machakann/vim-sandwich', {
  \ 'lazy': 1,
  \ 'on_map': {
  \    'nv': ['sa', 'sr', 'sd'],
  \    'o': ['ib', 'is', 'ab', 'as']
  \ },
  \ 'hook_source': 'call Hook_on_post_source_sandwich()'
  \ })

  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-operator-user')

  call dein#add('kana/vim-textobj-entire',         {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['ie', 'ae']}})
  call dein#add('kana/vim-textobj-fold',           {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['iz', 'az']}})
  call dein#add('kana/vim-textobj-function',       {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['if', 'af', 'iF', 'aF']}})
  call dein#add('kana/vim-textobj-indent',         {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['ai', 'ii', 'aI',  'iI']}})
  call dein#add('kana/vim-textobj-line',           {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['al', 'il']}})
  call dein#add('machakann/vim-textobj-delimited', {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['id', 'ad', 'iD', 'aD']}})
  call dein#add('mattn/vim-textobj-url',           {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['au', 'iu']}})
  call dein#add('rhysd/vim-textobj-ruby',          {'lazy': 1, 'depends': 'vim-textobj-user', 'on_map': {'ox': ['ar', 'ir']}, 'on_ft': 'ruby'})

  call dein#add('haya14busa/vim-textobj-function-syntax', {'lazy': 1, 'on_source': 'vim-textobj-function'})

  call dein#add('kana/vim-operator-replace',      {'lazy': 1, 'depends': 'vim-operator-user', 'on_map': '<Plug>'})
  call dein#add('mopp/vim-operator-convert-case', {'lazy': 1, 'depends': 'vim-operator-user', 'on_map': '<Plug>'})
  " }}}3

  " Edit & Move & Search {{{3
  " call dein#add('justinmk/vim-sneak')
  " call dein#add('terryma/vim-multiple-cursors')
  " call dein#add('tyru/skk.vim',              {'lazy': 1, 'on_event': 'InsertEnter'})
  " call dein#add('vimtaku/vim-mlh',           {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('AndrewRadev/splitjoin.vim',     {'lazy': 1, 'on_cmd': ['SplitjoinJoin', 'SplitjoinSplit']})
  call dein#add('AndrewRadev/switch.vim',        {'lazy': 1, 'on_cmd': 'Switch'})
  call dein#add('Chiel92/vim-autoformat',        {'lazy': 1, 'on_cmd': 'Autoformat'})
  call dein#add('LeafCage/yankround.vim')
  call dein#add('chrisbra/NrrwRgn',              {'lazy': 1, 'on_cmd': ['NR', 'NW', 'WidenRegion', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL']})
  call dein#add('cohama/lexima.vim',             {'lazy': 1, 'on_event': 'InsertEnter', 'hook_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('dyng/ctrlsf.vim',               {'lazy': 1, 'on_cmd': ['CtrlSF', 'CtrlSFUpdate', 'CtrlSFOpen', 'CtrlSFToggle']})
  call dein#add('easymotion/vim-easymotion')
  call dein#add('editorconfig/editorconfig-vim', {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('godlygeek/tabular',             {'lazy': 1, 'on_cmd': 'Tabularize'})
  call dein#add('h1mesuke/vim-alignta',          {'lazy': 1, 'on_cmd': 'Alignta'})
  call dein#add('haya14busa/vim-asterisk',       {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion',     {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-metarepeat',     {'lazy': 1, 'on_map': ['go', 'g.', '<Plug>']})
  call dein#add('junegunn/vim-easy-align',       {'lazy': 1, 'on_cmd': 'EasyAlign'})
  call dein#add('mg979/vim-visual-multi',        {'rev': 'test'})
  call dein#add('mileszs/ack.vim',               {'lazy': 1, 'on_cmd': 'Ack'})
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('osyo-manga/vim-jplus',          {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/accelerated-jk',          {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('rhysd/clever-f.vim')
  call dein#add('terryma/vim-expand-region',     {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-qfreplace',          {'lazy': 1, 'on_cmd': 'Qfreplace'})
  call dein#add('tommcdo/vim-exchange',          {'lazy': 1, 'on_map': {'n': ['cx', 'cxc', 'cxx'], 'x': ['X']}})
  call dein#add('tomtom/tcomment_vim',           {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-speeddating',         {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('vim-scripts/Align',             {'lazy': 1, 'on_cmd': 'Align'})
  " }}}3

  " Appearance {{{3
  call dein#add('AndrewRadev/linediff.vim',       {'lazy': 1, 'on_cmd': ['Linediff', 'LinediffReset']})
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Shougo/echodoc.vim')
  call dein#add('Yggdroot/indentLine',            {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('itchyny/lightline.vim')
  call dein#add('itchyny/vim-highlighturl')
  call dein#add('itchyny/vim-parenmatch')
  call dein#add('luochen1990/rainbow')
  call dein#add('machakann/vim-highlightedyank')
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
  call dein#add('Shougo/junkfile.vim')
  call dein#add('SpaceVim/gtags.vim')
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bfredl/nvim-miniyank')
  call dein#add('bogado/file-line')
  call dein#add('dhruvasagar/vim-table-mode',          {'lazy': 1, 'on_cmd': 'TableModeToggle'})
  call dein#add('dietsche/vim-lastplace')
  call dein#add('haya14busa/vim-open-googletranslate', {'lazy': 1, 'on_cmd': 'OpenGoogleTranslate'})
  call dein#add('janko-m/vim-test',                    {'lazy': 1, 'on_cmd': ['TestNearest','TestFile','TestSuite','TestLast','TestVisit']})
  call dein#add('kana/vim-gf-user')
  call dein#add('kana/vim-niceblock',                  {'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
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

"" Cursor
noremap 0 ^
noremap ^ 0

"" Smart <C-f> <C-b>
noremap <expr> <C-f> max([winheight(0) - 2, 1]) . "\<C-d>" . (line('w$') >= line('$') ? "L" : "M")
noremap <expr> <C-b> max([winheight(0) - 2, 1]) . "\<C-u>" . (line('w0') <= 1 ? "H" : "M")

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

  AutoCmd CursorHold * rshada | wshada

  AutoCmd FocusGained * checktime

  tnoremap <Esc> <C-\><C-n>
  AutoCmd TermOpen * set nonumber | set norelativenumber

  " block cursor for insert
  set guicursor=
endif

"" Appearance
set belloff=all
set conceallevel=2
set concealcursor=niv
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
set pumheight=25
set scrolloff=5
set showmatch
set showtabline=2
set spellcapcheck=
set spelllang=en,cjk
set synmaxcol=300
set virtualedit=all
set matchpairs& matchpairs+=<:>

"" Indent
set nostartofline
set autoindent
set backspace=indent,eol,start
set breakindent
set expandtab
set shiftwidth=4
set smartindent
set tabstop=4

AutoCmd FileType * setlocal formatoptions-=ro
AutoCmd FileType * setlocal formatoptions+=jBn

"" viminfo
set viminfo='1000

"" Search & Complete
set completeopt=menu,menuone,noinsert,noselect
set ignorecase
set regexpengine=2
set smartcase
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan

"" Folding
set foldcolumn=1
set foldenable
set foldmethod=manual

"" history
set history=1000
set undodir=~/.vim_undo
set undofile

"" FileType
set autoread
set viewoptions=cursor,folds
set suffixesadd=.js,.ts,.rb

"" Diff
AutoCmd InsertLeave * if &l:diff | diffupdate | endif

"" Undo
set undofile
set undodir=~/.cache/vim/undo/

"" Swap File
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
set updatetime=500
set langnoremap

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

" highlight cursorline and cursorcolumn with timer {{{2
let s:highlight_cursor_wait = 500

function! s:enter(...) abort
  setlocal cursorline cursorcolumn
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

call timer_start(s:highlight_cursor_wait, function('s:enter'))
" }}}2

" Auto mkdir {{{2
AutoCmd BufWritePre * call <SID>auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
" }}}2

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
    call g:Set_quickfix_keymap()
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
    call g:Set_locationlist_keymap()
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
  let l:c = getchar()
  return get(s:compl_key_dict, l:c, nr2char(l:c))
endfunction

inoremap <expr> <C-x> <SID>hint_i_ctrl_x()
" }}}2

" Mark & Register {{{2
function! s:hint_cmd_output(prefix, cmd) abort
  redir => l:str
  :execute a:cmd
  redir END
  echo l:str
  return a:prefix . nr2char(getchar())
endfunction

nnoremap <expr> m  <SID>hint_cmd_output('m', 'marks')
nnoremap <expr> `  <SID>hint_cmd_output('`', 'marks')
nnoremap <expr> '  <SID>hint_cmd_output("'", 'marks')
nnoremap <expr> "  <SID>hint_cmd_output('"', 'registers')
" nnoremap <expr> q  <SID>hint_cmd_output('q', 'registers')
" nnoremap <expr> @  <SID>hint_cmd_output('@', 'registers')
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

command! HelpEdit call <SID>option_to_edit()
command! HelpView call <SID>option_to_view()
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

AutoCmd FileType javascript setlocal dictionary=~/dotfiles/.vim/dict/javascript.dict
AutoCmd FileType typescript setlocal dictionary=~/dotfiles/.vim/dict/javascript.dict
AutoCmd FileType ruby,eruby setlocal dictionary=~/dotfiles/.vim/dict/ruby.dict
" }}}3


" }}}2

" HTML & eruby {{{2
AutoCmd FileType html,eruby call <SID>map_html_keys()
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
  nnoremap <silent> <buffer> q :<C-u>quit<CR>
  inoremap <buffer> <C-c> <C-c>
  inoremap <buffer> <C-c> <Esc>l<C-c>

  " nnoremap <silent> <buffer> dd :<C-u>rviminfo<CR>:call histdel(getcmdwintype(), line('.') - line('$'))<CR>:wviminfo!<CR>dd
  startinsert!
endfunction
" }}}1

" set quit {{{1
AutoCmd FileType help    nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType man     nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType qf      nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType diff    nnoremap <silent> <buffer> q :<C-u>quit<CR>
AutoCmd FileType git     nnoremap <silent> <buffer> q :<C-u>quit<CR>
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
AlterCommand! <cmdwin> dein      Dein
AlterCommand! <cmdwin> reca[che] Dein<Space>recache-runtimepath
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
let g:gen_tags#use_cache_dir  = 0
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
  call denite#custom#source('_',        'matchers', ['matcher/fuzzy'])
  call denite#custom#source('file_mru', 'matchers', ['matcher/fuzzy', 'matcher/project_files'])
  call denite#custom#source('line',     'matchers', ['matcher/regexp'])
  call denite#custom#source('grep',     'matchers', ['matcher/regexp'])

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
  nnoremap <silent> <Leader><Leader>/ :<C-u>Denite grep -post-action=open<CR>
  nnoremap <silent> <Leader><Leader>* :<C-u>DeniteCursorWord grep -post-action=open<CR>

  "" outline
  " nnoremap <silent> <Leader>o :<C-u>Denite outline<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Denite jump change -auto-preview<CR>

  "" ctags & gtags
  nnoremap <silent> <Leader><C-]> :<C-u>DeniteCursorWord gtags_context<CR>
  " nnoremap <silent> <Leader><Leader><C-]> :<C-u>DeniteCursorWord gtags_grep<CR>

  "" yank
  nnoremap <silent> (ctrlp) :<C-u>Denite miniyank<CR>

  "" neosnippet
  nnoremap <silent> <C-s> :<C-u>Denite neosnippet<CR>

  "" resume
  nnoremap <silent> <Leader><C-r> :<C-u>Denite -resume<CR>
endif

" AlterCommand! <cmdwin> u[nite] Unite

if dein#tap('unite.vim')
  " Unite
  let g:unite_force_overwrite_statusline = 0
  let g:unite_source_rec_max_cache_files = 10000
  let g:unite_enable_auto_select         = 0
  let g:unite_data_directory             = expand('~/.cache/vim/unite')

  "" keymap
  function! s:unite_settings()
    nnoremap <silent> <buffer> <C-n>      j
    nnoremap <silent> <buffer> <C-p>      k
    nnoremap <silent> <buffer> <C-j>      <C-w>j
    nnoremap <silent> <buffer> <C-k>      <C-w>k
    nmap     <silent> <buffer> p          <Plug>(unite_smart_preview)
    nnoremap <silent> <buffer> <Esc><Esc> q
    inoremap <silent> <buffer> <Esc><Esc> <Esc>q
    imap     <silent> <buffer> <C-w>      <Plug>(unite_delete_backward_path)
  endfunction

  AutoCmd FileType unite call <SID>unite_settings()

  " gtags
  " nnoremap <silent> <Leader><C-]> :<C-u>UniteWithCursorWord gtags/context -direction=botright -no-quit<CR>

  " grep
  let g:unite_source_grep_command = 'rg'
  let g:unite_source_grep_default_opts = '--vimgrep --hidden'
  let g:unite_source_grep_recursive_opt = ''
  "
  call unite#custom_source('line', 'sorters', 'sorter_reverse')
  call unite#custom_source('grep', 'sorters', 'sorter_reverse')
  " nnoremap <silent> <Leader>/          :<C-u>Unite line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  " nnoremap <silent> <Leader>*          :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  " nnoremap <silent> <Leader><Leader>/  :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
  " nnoremap <silent> <Leader><Leader>*  :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit<CR>

  " yank
  " nnoremap <silent> <Leader><Leader>p :<C-u>Unite yankround<CR>
endif
" }}}3

" neomru {{{3
let g:neomru#file_mru_path       = expand('~/.cache/vim/neomru/file')
let g:neomru#dictionary_mru_path = expand('~/.cache/vim/neomru/dictionary')
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
nnoremap <silent> <Leader>g :<C-u>GitFilesPreview<CR>
nnoremap <silent> <Leader>b :<C-u>BuffersPreview<CR>
nnoremap <silent> <Leader>o :<C-u>ProjectMruFilesPreview<CR>
nnoremap <silent> <Leader>O :<C-u>MruFilesPreview<CR>
" }}}3

" deoplete.nvim && neosnippet.vim {{{3
if dein#tap('deoplete.nvim') && dein#tap('neosnippet')
  " Variables
  let g:deoplete#enable_at_startup          = 1
  let g:deoplete#enable_smart_case          = &smartcase
  let g:deoplete#enable_ignore_case         = &ignorecase
  let g:deoplete#enable_camel_case          = 1
  let g:deoplete#enable_on_insert_enter     = 0
  let g:deoplete#auto_complete_delay        = 50
  let g:deoplete#enable_refresh_always      = 1
  let g:deoplete#auto_complete_start_length = 2

  let g:deoplete#skip_chars              = ['(', ')', '<', '>']
  let g:deoplete#file#enable_buffer_path = 1
  let g:deoplete#keyword_patterns        = {}
  let g:deoplete#keyword_patterns._      = '[a-zA-Z_]\k*'

  let g:neosnippet#data_directory = expand("~/.cache/vim/neosnippet")

  " Keymap
  inoremap <silent> <expr> <BS>  deoplete#smart_close_popup() . "\<C-h>"
  inoremap <silent> <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
  inoremap <silent> <expr> <C-g> deoplete#undo_completion()
  inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<C-n>" : deoplete#mappings#manual_complete()
  function s:check_back_space() abort
    return !(col('.') - 1) || getline('.')[(col('.') - 1) - 1]  =~# '\s'
  endfunction

  " Togle neosnippet
  inoremap <silent> <C-s> <Esc>:call Toggle_deoplete_neosnippet()<CR>a

  function Toggle_deoplete_neosnippet() abort
    call deoplete#smart_close_popup()
    if !exists('g:deoplete_enable_neosnippet')
      let g:deoplete_enable_neosnippet = 1
    else
      let g:deoplete_enable_neosnippet = g:deoplete_enable_neosnippet ? 0 : 1
    endif

    call Deoplete_set_sources()
  endfunction

  "" disable & enable
  inoremap <silent> <expr> <C-c> pumvisible() ? deoplete#custom#buffer_option('auto_complete', v:false) : "\<C-c>"
  AutoCmd InsertLeave * call deoplete#custom#buffer_option('auto_complete', v:true)

  "" neosnippet
  imap <silent> <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <silent> <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <silent> <C-k> <Plug>(neosnippet_expand_target)
  imap <silent> <Tab> <Plug>(neosnippet_expand_or_jump)
  smap <silent> <Tab> <Plug>(neosnippet_expand_or_jump)
  xmap <silent> <Tab> <Plug>(neosnippet_expand_target)

  call deoplete#custom#source('_', 'converters', [
  \ 'converter_remove_paren',
  \ 'converter_remove_overlap',
  \ 'matcher_length',
  \ 'converter_truncate_abbr',
  \ 'converter_truncate_menu',
  \ 'converter_auto_delimiter',
  \ ])

  " Sources
  call deoplete#custom#source('LanguageClient', 'rank', 1100)
  call deoplete#custom#source('neosnippet',     'rank', 1000)
  call deoplete#custom#source('around',         'rank',  900)
  call deoplete#custom#source('buffer',         'rank',  900)
  call deoplete#custom#source('gtags',          'rank',  800)
  call deoplete#custom#source('omni',           'rank',  700)
  call deoplete#custom#source('typescript',     'rank',  700)
  call deoplete#custom#source('tern',           'rank',  700)
  call deoplete#custom#source('flow',           'rank',  700)
  call deoplete#custom#source('jedi',           'rank',  700)
  call deoplete#custom#source('go',             'rank',  700)
  call deoplete#custom#source('emoji',          'rank',  700)
  call deoplete#custom#source('vim',            'rank',  700)
  call deoplete#custom#source('syntax',         'rank',  600)
  call deoplete#custom#source('file',           'rank',  600)
  call deoplete#custom#source('tag',            'rank',  500)
  call deoplete#custom#source('member',         'rank',  500)
  call deoplete#custom#source('tmux-complete',  'rank',  300)
  call deoplete#custom#source('dictionary',     'rank',  200)
  call deoplete#custom#source('look',           'rank',  100)

  call deoplete#custom#source('LanguageClient', 'mark', '[LC]')
  call deoplete#custom#source('neosnippet',     'mark', '[snippet]')
  call deoplete#custom#source('around',         'mark', '[around]')
  call deoplete#custom#source('buffer',         'mark', '[buffer]')
  call deoplete#custom#source('gtags',          'mark', '[gtags]')
  call deoplete#custom#source('omni',           'mark', '[omni]')
  call deoplete#custom#source('syntax',         'mark', '[syntax]')
  call deoplete#custom#source('file',           'mark', '[file]')
  call deoplete#custom#source('tag',            'mark', '[tag]')
  call deoplete#custom#source('member',         'mark', '[member]')
  call deoplete#custom#source('dictionary',     'mark', '[dict]')
  call deoplete#custom#source('look',           'mark', '[look]')

  call deoplete#custom#source('typescript',     'mark', '[ts]')

  call deoplete#custom#source('tern',           'mark', '[tern]')
  call deoplete#custom#source('flow',           'mark', '[flow]')
  call deoplete#custom#source('jedi',           'mark', '[jedi]')
  call deoplete#custom#source('go',             'mark', '[go]')
  call deoplete#custom#source('emoji',          'mark', '[emoji]')
  call deoplete#custom#source('vim',            'mark', '[vim]')
  call deoplete#custom#source('tmux-complete',  'mark', '[tmux]')

  " max_candidates
  call deoplete#custom#source('LanguageClient', 'max_candidates', 10)
  call deoplete#custom#source('neosnippet',     'max_candidates', 10)
  call deoplete#custom#source('around',         'max_candidates', 10)
  call deoplete#custom#source('buffer',         'max_candidates', 10)
  call deoplete#custom#source('gtags',          'max_candidates', 10)
  call deoplete#custom#source('omni',           'max_candidates', 10)
  call deoplete#custom#source('typescript',     'max_candidates', 10)
  call deoplete#custom#source('tern',           'max_candidates', 10)
  call deoplete#custom#source('flow',           'max_candidates', 10)
  call deoplete#custom#source('jedi',           'max_candidates', 10)
  call deoplete#custom#source('go',             'max_candidates', 10)
  call deoplete#custom#source('emoji',          'max_candidates', 10)
  call deoplete#custom#source('vim',            'max_candidates', 10)
  call deoplete#custom#source('syntax',         'max_candidates', 10)
  call deoplete#custom#source('file',           'max_candidates', 10)
  call deoplete#custom#source('tag',            'max_candidates', 10)
  call deoplete#custom#source('member',         'max_candidates', 10)
  call deoplete#custom#source('tmux-complete',  'max_candidates', 10)
  call deoplete#custom#source('dictionary',     'max_candidates', 10)
  call deoplete#custom#source('look',           'max_candidates', 10)

  " call deoplete#custom#source('ruby', 'input_pattern', ['\.[a-zA-Z0-9_?!]+', '[a-zA-Z]\w*::\w*'])

  function! Deoplete_set_sources() abort
    if exists('g:deoplete_enable_neosnippet') && g:deoplete_enable_neosnippet
      let l:deoplete_sources = {}
      let l:deoplete_sources._          = ['neosnippet']
      let l:deoplete_sources.javascript = ['neosnippet']
      let l:deoplete_sources.typescript = ['neosnippet']
      let l:deoplete_sources.vue        = ['neosnippet']
      let l:deoplete_sources.ruby       = ['neosnippet']
      let l:deoplete_sources.eruby      = ['neosnippet']
      let l:deoplete_sources.python     = ['neosnippet']
      let l:deoplete_sources.go         = ['neosnippet']
      let l:deoplete_sources.rust       = ['neosnippet']
      let l:deoplete_sources.markdown   = ['neosnippet']
      let l:deoplete_sources.html       = ['neosnippet']
      let l:deoplete_sources.xml        = ['neosnippet']
      let l:deoplete_sources.css        = ['neosnippet']
      let l:deoplete_sources.scss       = ['neosnippet']
      let l:deoplete_sources.vim        = ['neosnippet']
      let l:deoplete_sources.zsh        = ['neosnippet']
    else
      let l:deoplete_default_sources = ['gtags', 'tag', 'around', 'buffer', 'omni', 'member', 'syntax', 'file', 'dictionary', 'look', 'tmux-complete']

      let l:deoplete_sources = {}
      let l:deoplete_sources._          = l:deoplete_default_sources
      let l:deoplete_sources.javascript = l:deoplete_default_sources + ['ternjs', 'flow']
      let l:deoplete_sources.typescript = l:deoplete_default_sources + ['typescript']
      let l:deoplete_sources.vue        = l:deoplete_default_sources + ['typescript']
      let l:deoplete_sources.ruby       = l:deoplete_default_sources + ['LanguageClient']
      let l:deoplete_sources.eruby      = l:deoplete_default_sources
      let l:deoplete_sources.python     = l:deoplete_default_sources + ['jedi']
      let l:deoplete_sources.go         = l:deoplete_default_sources + ['go']
      let l:deoplete_sources.rust       = l:deoplete_default_sources
      let l:deoplete_sources.markdown   = l:deoplete_default_sources + ['emoji']
      let l:deoplete_sources.html       = l:deoplete_default_sources
      let l:deoplete_sources.xml        = l:deoplete_default_sources
      let l:deoplete_sources.css        = l:deoplete_default_sources
      let l:deoplete_sources.scss       = l:deoplete_default_sources
      let l:deoplete_sources.vim        = l:deoplete_default_sources + ['vim']
      let l:deoplete_sources.zsh        = l:deoplete_default_sources
    endif

    call deoplete#custom#option('sources', l:deoplete_sources)
  endfunction
  AutoCmd VimEnter * call Deoplete_set_sources()

  let g:deoplete#omni#input_patterns            = {}
  let g:deoplete#omni#input_patterns._          = ''
  let g:deoplete#omni#input_patterns.javascript = ['\w+', '[^. \t0-9]\.([a-zA-Z_]\w*)?']
  let g:deoplete#omni#input_patterns.typescript = ['\w+', '[^. \t0-9]\.([a-zA-Z_]\w*)?']
  let g:deoplete#omni#input_patterns.vue        = ['\w+', '[^. \t0-9]\.([a-zA-Z_]\w*)?', '<[^>]*\s[[:alnum:]-]*', '\w+[):;]?\s+\w*', '[@!]']
  let g:deoplete#omni#input_patterns.ruby       = ['\w+', '[^. *\t]\.\w*', '[a-zA-Z_]\w*::']
  let g:deoplete#omni#input_patterns.eruby      = ['\w+', '[^. *\t]\.\w*', '[a-zA-Z_]\w*::', '<', '<[^>]*\s[[:alnum:]-]*']
  let g:deoplete#omni#input_patterns.python     = ['\w+', '[^. *\t]\.\h\w*\','\h\w*::']
  let g:deoplete#omni#input_patterns.html       = ['<', '<[^>]*\s[[:alnum:]-]*']
  let g:deoplete#omni#input_patterns.xml        = ['<', '<[^>]*\s[[:alnum:]-]*']
  let g:deoplete#omni#input_patterns.css        = ['\w+', '\w+[):;]?\s+\w*', '[@!]']
  let g:deoplete#omni#input_patterns.scss       = ['\w+', '\w+[):;]?\s+\w*', '[@!]']

  let g:deoplete#omni#functions            = {}
  let g:deoplete#omni#functions.javascript = ['jspc#omni', 'javascriptcomplete#CompleteJS']
  let g:deoplete#omni#functions.typescript = ['jspc#omni', 'javascriptcomplete#CompleteJS']
  let g:deoplete#omni#functions.vue        = ['jspc#omni', 'javascriptcomplete#CompleteJS', 'htmlcomplete#CompleteTags', 'csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.ruby       = ['rubycomplete#Complete']
  let g:deoplete#omni#functions.eruby      = ['rubycomplete#Complete', 'htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.python     = ['pythoncomplete#Complete']
  let g:deoplete#omni#functions.html       = ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.xml        = ['htmlcomplete#CompleteTags']
  let g:deoplete#omni#functions.css        = ['csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.scss       = ['csscomplete#CompleteCSS']
  let g:deoplete#omni#functions.vim        = ['Verdin#omnifunc']
endif
" }}}3

" ncm2 {{{3
" let g:ncm2#complete_length = [[1,1],[7,1]]
" let g:ncm2#popup_limit     = 5
"
" inoremap <silent>        <C-c> <Esc>
" inoremap <silent> <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
" imap     <silent>        <C-n> <Plug>(ncm2_manual_trigger)
"
" " omnifunc
" call ncm2#register_source({
" \ 'name': 'ruby',
" \ 'priority': 8,
" \ 'complete_length': 1,
" \ 'subscope_enable': 1,
" \ 'scope': ['ruby', 'eruby'],
" \ 'mark': 'ruby',
" \ 'word_pattern': '\w+',
" \ 'complete_pattern': ['\w+', '[^. *\t]\.\w*', '[a-zA-Z_]\w*::'],
" \ 'on_complete': ['ncm2#on_complete#delay', 180,
" \                 'ncm2#on_complete#omni', 'rubycomplete#Complete'],
" \ })
"
" " lsp
" call ncm2#override_source('typescript',              { 'priority': 9, 'mark': 'typescript', 'popup_limit': 10 })
" call ncm2#override_source('ncm2_vim_lsp_solargraph', { 'priority': 9, 'mark': 'solar',      'popup_limit': 10 })
"
" " Sources
" call ncm2#override_source('vim',        { 'priority': 8, 'mark': 'vim'                            })
" call ncm2#override_source('jedi',       { 'priority': 8, 'mark': 'jedi'                           })
" call ncm2#override_source('go',         { 'priority': 8, 'mark': 'go'                             })
" call ncm2#override_source('ruby',       { 'priority': 8, 'mark': 'ruby'                           })
"
" call ncm2#override_source('bufword',    { 'priority': 8, 'mark': 'buffer'                         })
" call ncm2#override_source('syntax',     { 'priority': 7, 'mark': 'syntax'                         })
" call ncm2#override_source('gtags',      { 'priority': 7, 'mark': 'gtags',    'complete_length': 3 })
" call ncm2#override_source('dictionary', { 'priority': 6, 'mark': 'dict',                          })
" call ncm2#override_source('tagprefix',  { 'priority': 5, 'mark': 'tag'                            })
" call ncm2#override_source('buflook',    { 'priority': 4, 'mark': 'look'                           })
" call ncm2#override_source('tmux',       { 'priority': 3, 'mark': 'tmux',     'complete_length': 3 })
" call ncm2#override_source('bufpath',    { 'priority': 2, 'mark': 'bufpath',  'complete_length': 3 })
" call ncm2#override_source('cwdpath',    { 'priority': 2, 'mark': 'cwdpath',  'complete_length': 3 })
"
" call ncm2#override_source('rootpath',  {'enable': 0})
"
" AutoCmd BufEnter     * call ncm2#enable_for_buffer()
" AutoCmd TextChangedI * call ncm2#auto_trigger()
"
" if executable('solargraph')
"   AutoCmd User lsp_setup call lsp#register_server({
"   \ 'name': 'solargraph',
"   \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
"   \ 'initialization_options': {"diagnostics": "true"},
"   \ 'whitelist': ['ruby'],
"   \ })
" endif
" }}}3

" LanguageClient {{{3
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
\ 'typescript': ['javascript-typescript-stdio'],
\ 'ruby': [ 'solargraph',  'stdio' ],
\ }
" }}}3

" Verdin {{{3
let g:Verdin#cooperativemode = 1
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

" vimfiler {{{3
let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_data_directory = expand('~/.cache/vim/vimfiler')
let g:vimfiler_execute_file_list    = {'jpg': 'open', 'jpeg': 'open', 'gif': 'open', 'png': 'open'}
let g:vimfiler_enable_auto_cd       = 1
let g:vimfiler_ignore_pattern       = '^\%(.git\|.DS_Store\)$'
let g:vimfiler_trashbox_directory   = '~/.Trash'

if dein#tap('lightline.vim')
  nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer -simple <Bar> call lightline#update()<CR>
  nnoremap <silent> <Leader>E :<C-u>VimFilerExplorer -simple -find <Bar> call lightline#update()<CR>
else
  nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer -simple<CR>
  nnoremap <silent> <Leader>E :<C-u>VimFilerExplorer -simple -find<CR>
endif

function! s:vimfiler_settings()
  nmap     <silent> <buffer> R     <Plug>(vimfiler_redraw_screen)
  nnoremap <silent> <buffer> <C-l> <C-w>l
  nnoremap <silent> <buffer> <C-j> <C-w>j
endfunction

AutoCmd FileType vimfiler call s:vimfiler_settings()
" }}}3

" vaffle {{{3
AlterCommand! <cmdwin> va[fle] Vaffle
AutoCmd FileType vaffle  nnoremap <silent> <buffer> q :<C-u>quit<CR>

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:vaffle_open_selected_split_position = ''
let g:vaffle_open_selected_vsplit_position = ''

command! VaffleExplorer vertical topleft vsplit +Vaffle | vertical resize 35 | setlocal winfixwidth
command! VaffleExplorerCurrent vertical topleft vsplit +Vaffle\ %:h | vertical resize 35 | setlocal winfixwidth

" nnoremap <silent> <Leader>e :VaffleExplorer<CR>
" nnoremap <silent> <Leader>E :VaffleExplorerCurrent<CR>

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

" easymotion & clever-f & sneak {{{3
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

  nmap <silent> S         <Plug>(easymotion-overwin-f2)
  nmap <silent> ss        <Plug>(easymotion-bd-f2)
  omap <silent> f         <Plug>(easymotion-fl)
  omap <silent> t         <Plug>(easymotion-tl)
  omap <silent> F         <Plug>(easymotion-Fl)
  omap <silent> T         <Plug>(easymotion-Tl)
  nmap <silent> <Leader>l <Plug>(easymotion-overwin-line)
  map  <silent> <Leader>l <Plug>(easymotion-bd-jk)

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

  " sneak
  " let g:sneak#prompt = 'Search by Sneak (2 characters) >'
  "
  " nmap <silent> ss <Plug>Sneak_s
  " nmap <silent> sS <Plug>Sneak_S
  " nmap <silent> ;  <Plug>Sneak_;
  " nmap <silent> ,  <Plug>Sneak_,
  " xmap <silent> ss <Plug>Sneak_s
  " xmap <silent> sS <Plug>Sneak_S
  " xmap <silent> ;  <Plug>Sneak_;
  " xmap <silent> ,  <Plug>Sneak_,
endif
" }}}3

" edgemotion {{{3
map <silent> <Leader>j <Plug>(edgemotion-j)
map <silent> <Leader>k <Plug>(edgemotion-k)
" }}}3

" expand-region {{{3
" ad: delimited
" ib: sandwich
let g:expand_region_text_objects = {
\ 'iw' : 0,
\ 'iW' : 0,
\ 'iu' : 0,
\ 'ad' : 0,
\ 'ib' : 1,
\ }

vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  nmap J  <Plug>(jplus)
  vmap J  <Plug>(jplus)
  nmap gJ <Plug>(jplus-input)
  vmap gJ <Plug>(jplus-input)
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
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*- \%#',        'input': '<BS><BS><BS>* ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*+ \%#',        'input': '<BS><BS><BS>- ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\s*\* \%#',       'input': '<BS><BS><BS>+ ',                                                               },
    \ { 'filetype': 'markdown', 'char': '<BS>',  'at': '^\(-\|+\|*\) \%#', 'input': '<C-w>',                                                                        },
    \ { 'filetype': 'markdown', 'char': '>',     'at': '^\s*\%#',          'input': '> ',                                                                           },
    \ ]

    "" vim
    let l:rules += [
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

" operator-convert-case {{{3
nmap <silent> <Leader>cc <Plug>(operator-convert-case-loop)
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

" splitjoin {{{3
let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping = ''

" nnoremap <silent> <Leader>j :SplitjoinJoin<CR>
" nnoremap <silent> <Leader>s :SplitjoinSplit<CR>
" }}}3

" switch {{{3
let g:switch_mapping = ''
nnoremap <silent> - :<C-u>Switch<CR>
" }}}3

" tcomment {{{3
noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" visual-multi {{{3
let g:VM_leader = '\'

let g:VM_default_mappings           = 1
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
let g:VM_manual_infoline            = 0

let g:VM_maps = {}
"
let g:VM_maps['Find Under']                  = '<C-n>'
let g:VM_maps['Find Subword Under']          = '<C-n>'
let g:VM_maps['Skip Region']                 = '<C-s>'
let g:VM_maps['Erase Regions']               = 'gr'
let g:VM_maps['Add Cursor At Pos']           = 'g<Space>'
let g:VM_maps['Add Cursor At Word']          = 'g<CR>'
let g:VM_maps['Start Regex Search']          = 'g/'
let g:VM_maps['Select All']                  = '<A-a>'
let g:VM_maps['Add Cursor Down']             = '<A-S-j>'
let g:VM_maps['Add Cursor Up']               = '<A-S-k>'

let g:VM_maps['Visual All']                  = '<A-S-a>'
let g:VM_maps['Visual Add']                  = '<A-a>'
let g:VM_maps['Visual Find']                 = '<C-f>'
let g:VM_maps['Visual Cursors']              = '<C-c>'
let g:VM_maps['Visual Star']                 = '*'
let g:VM_maps['Visual Hash']                 = '#'
let g:VM_maps['Visual Subtract']             = '<C-s>'

let g:VM_maps['Select l']                    = '<A-S-l>'
let g:VM_maps['Select h']                    = '<A-S-h>'
let g:VM_maps['Select w']                    = '<A-S-w>'
let g:VM_maps['Select b']                    = '<A-S-b>'

let g:VM_maps['Switch Mode']                 = '<Tab>'
let g:VM_maps['Toggle Block']                = '<BS>'
let g:VM_maps['Toggle Only This Region']     = '<CR>'

let g:VM_maps['Find I Word']                 = 's]'
let g:VM_maps['Find A Word']                 = 's['
let g:VM_maps['Find I Whole Word']           = 's}'
let g:VM_maps['Find A Subword']              = 's]'
let g:VM_maps['Find A Whole Subword']        = 's['

let g:VM_maps['Find Next']                   = ']'
let g:VM_maps['Find Prev']                   = '['
let g:VM_maps['Goto Next']                   = '}'
let g:VM_maps['Goto Prev']                   = '{'
let g:VM_maps['Seek Next']                   = '<C-f>'
let g:VM_maps['Seek Prev']                   = '<C-b>'
let g:VM_maps['Invert Direction']            = 'o'
let g:VM_maps['Remove Region']               = 'Q'
let g:VM_maps['Find Operator']               = 'm'

let g:VM_maps['Tools Menu']                  = '<leader>x'
let g:VM_maps['Show Registers']              = '<leader>"'
let g:VM_maps['Case Setting']                = '<C-c>'
let g:VM_maps['Toggle Whole Word']           = '<C-w>'
let g:VM_maps['Case Conversion Menu']        = '<leader>c'
let g:VM_maps['Search Menu']                 = '<leader>S'
let g:VM_maps['Rewrite Last Search']         = '<leader>r'
let g:VM_maps['Toggle Multiline']            = 'M'

let g:VM_maps['Surround']                    = 'S'
let g:VM_maps['Merge Regions']               = '<leader>m'
let g:VM_maps['Transpose']                   = '<leader>t'
let g:VM_maps['Duplicate']                   = '<leader>d'
let g:VM_maps['Align']                       = '<leader>a'
let g:VM_maps['Split Regions']               = '<leader>s'

let g:VM_maps['Run Normal']                  = 'zz'
let g:VM_maps['Run Last Normal']             = 'Z'
let g:VM_maps['Run Visual']                  = 'zv'
let g:VM_maps['Run Last Visual']             = '<M-z>'
let g:VM_maps['Run Ex']                      = 'zx'

let g:VM_maps['D']                           = 'D'
let g:VM_maps['Y']                           = 'Y'
let g:VM_maps['x']                           = 'x'
let g:VM_maps['X']                           = 'X'
let g:VM_maps['J']                           = 'J'
let g:VM_maps['~']                           = '~'
let g:VM_maps['Del']                         = '<del>'
let g:VM_maps['Dot']                         = '.'
let g:VM_maps['Increase']                    = '+'
let g:VM_maps['Decrease']                    = '-'
let g:VM_maps['a']                           = 'a'
let g:VM_maps['A']                           = 'A'
let g:VM_maps['i']                           = 'i'
let g:VM_maps['I']                           = 'I'
let g:VM_maps['o']                           = '<leader>o'
let g:VM_maps['O']                           = '<leader>O'
let g:VM_maps['c']                           = 'c'
let g:VM_maps['C']                           = 'C'
let g:VM_maps['Yank']                        = 'y'
let g:VM_maps['Delete']                      = 'd'
let g:VM_maps['Replace']                     = 'r'
let g:VM_maps['Replace Pattern']             = 'R'
let g:VM_maps['p Paste Regions']             = 'p'
let g:VM_maps['P Paste Regions']             = 'P'
let g:VM_maps['p Paste Normal']              = '<leader>p'
let g:VM_maps['P Paste Normal']              = '<leader>P'
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history   = 1000
  let g:yankround_use_region_hl = 1

  function! Hook_on_vimenter_event_yankround() abort
    nmap p <Plug>(yankround-p)
    xmap p <Plug>(yankround-p)
    nmap P <Plug>(yankround-P)
  endfunction

  AutoCmd VimEnter * call Hook_on_vimenter_event_yankround()
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = ['markdown', 'diff', 'qf', 'help', 'gitcommit', 'gitrebase', 'denite', 'tagbar', 'ctrlsf']
" }}}3

" choosewin {{{3
let g:choosewin_tabline_replace = 0
nnoremap <silent> <C-q> :<C-u>ChooseWin<CR>
" }}}3

" brightest {{{3
AlterCommand! <cmdwin> br[ight] BrightestToggle

let g:brightest#enable_on_CursorHold        = 1
let g:brightest#enable_highlight_all_window = 1
let g:brightest#highlight = {'group': 'BrighTestHighlight'}
let g:brightest#ignore_syntax_list = ['Statement', 'Keyword', 'Boolean', 'Repeat']
" }}}3

" fastfold {{{3
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes  = ['x', 'X', 'a', 'A', 'o', 'O', 'c', 'C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
nmap zuz <Plug>(FastFoldUpdate)
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
  \     ['mode', 'spell', 'paste'],
  \     ['visual_multi'],
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
  \   'left': [['mode'], [], [], ['filepath', 'filename', 'keymap']],
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
  \   'spell':        "%{&spell ? 'SPELL' : ''}",
  \   'paste':        "%{&paste ? 'PASTE' : ''}",
  \   'visual_multi': "%{exists('b:VM_Selection') && len(b:VM_Selection) ? 'Visual Multi' : ''}",
  \  },
  \ 'component_function': {
  \   'mode':         'Lightline_mode',
  \   'filepath':     'Lightline_filepath',
  \   'filename':     'Lightline_filename',
  \   'filetype':     'Lightline_filetype',
  \   'lineinfo':     'Lightline_lineinfo',
  \   'fileencoding': 'Lightline_fileencoding',
  \   'fileformat':   'Lightline_fileformat',
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
  \   'spell':        '&spell',
  \   'paste':        '&paste',
  \   'visual_multi': "exists('b:VM_Selection') && len(b:VM_Selection)",
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
  let s:lightline_ignore_right_ft = [
  \ 'help',
  \ 'diff',
  \ 'man',
  \ 'fzf',
  \ 'denite',
  \ 'unite',
  \ 'vimfiler',
  \ 'vaffle',
  \ 'tagbar',
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
  \ 'denite':      'Denite',
  \ 'unite':       'Unite',
  \ 'vimfiler':    'VimFiler',
  \ 'vaffle':      'Vaffle',
  \ 'tagbar':      'TagBar',
  \ 'capture':     'Capture',
  \ 'gina-status': 'Git Status',
  \ 'gina-branch': 'Git Branch',
  \ 'gina-log':    'Git Log',
  \ 'gina-reflog': 'Git Reflog',
  \ 'gina-blame':  'Git Blame',
  \ }

  let s:lightline_ignore_modifiable_ft = [
  \ 'qf',
  \ 'vimfiler',
  \ 'vaffle',
  \ 'tagbar',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filename_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'unite',
  \ 'vimfiler',
  \ 'vaffle',
  \ 'tagbar',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filepath_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'denite',
  \ 'unite',
  \ 'vimfiler',
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
    return l:win.loclist ? 'Location List' : l:win.quickfix ? 'QuickFix' : get(s:lightline_ft_to_mode_hash, &filetype, lightline#mode())
  endfunction

  function! Lightline_filepath() abort
    if count(s:lightline_ignore_filepath_ft, &filetype) || expand('%:t') ==# '[Command Line]'
      return ''
    endif

    let l:path            = expand('%:p:~:h')
    let l:not_home_prefix = match(l:path, '^/') != -1 ? '/' : ''
    let l:dirs            = split(l:path, '/')
    let l:last_dir        = remove(l:dirs, -1)
    call map(l:dirs, 'v:val[0]')

    return len(l:dirs) ? l:not_home_prefix . join(l:dirs, '/') . '/' . l:last_dir : l:last_dir
  endfunction

  function! Lightline_filename() abort
    let l:filename = expand('%:t')

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
    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \        printf('%d:%d | %d lines [%d%%]',line('.'), col('.'), line('$'), float2nr((1.0 * line('.')) / line('$') * 100.0)) :
    \        ''
  endfunction

  function! Lightline_fileencoding() abort
    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \         strlen(&fileencoding) ?
    \           &fileencoding :
    \           &encoding :
    \         ''
  endfunction

  function! Lightline_fileformat() abort
    return !count(s:lightline_ignore_right_ft, &filetype) ?
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
    return count(g:ale_filetypes, &filetype) ? lightline#ale#errors() : ''
  endfunction

  function! Lightline_ale_warnings() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#warnings() : ''
  endfunction

  function! Lightline_ale_ok() abort
    return count(g:ale_filetypes, &filetype) ? lightline#ale#ok() : ''
  endfunction

  function! Lightline_denite() abort
    return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  endfunction

  function! Lightline_keymap() abort
    return !has_key(s:lightline_ft_to_mode_hash, &filetype) ?
    \ 'Map [' . g:keymap . ']' :
    \ ''
  endfunction
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
\ ['Check Health',          'checkhealth'],
\ ['Recache Runtimepath',   'Dein recache-runtimepath'],
\ ['Update Remote Plugins', 'call dein#remote_plugins()'],
\ ['Git Status',            'Gina status'],
\ ['Git Log',               'Gina Log'],
\ ['Git Diff',              'Gina diff'],
\ ['Git Diff Cached',       'Gina diff --cached'],
\ ['Git Commit',            'Gina commit'],
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
let g:bakaup_backup_dir  = expand('~/.cache/vim/backup')
" }}}3

" automatic {{{
" function! s:automatic_win_init(config, context)
"   nnoremap <silent> <buffer> q :<C-u>q<CR>
" endfunction
"
" let g:automatic_default_set_config = {
" \ 'apply': function('<SID>automatic_win_init'),
" \ }

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
\   'match': { 'filetype': 'gina-grep' },
\   'set': {
\     'move': 'right',
\   },
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
\ ]
" }}}

" bufkill {{{3
nnoremap <silent> <Leader>d :BD<CR>

AutoCmd FileType help   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType diff   nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType git    nnoremap <silent> <buffer> <Leader>d :BW<CR>
AutoCmd FileType vaffle nnoremap <silent> <buffer> <Leader>d :BW<CR>
" }}}3

" capture {{{3
AlterCommand! <cmdwin> cap[ture] Capture
AutoCmd FileType capture nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}3

" dispatch {{{3
AlterCommand! <cmdwin> dis[patch] Dispatch
AlterCommand! <cmdwin> fo[cus]    Focus
AlterCommand! <cmdwin> st[art]    Start

AlterCommand! <cmdwin> stree      Start!<Space>stree
AlterCommand! <cmdwin> fork       Start!<Space>fork
" }}}3

" junkfile {{{3
AlterCommand! <cmdwin> jnote  JunkfileNote
AlterCommand! <cmdwin> jdaily JunkfileDaily
AlterCommand! <cmdwin> junk   Unite<Space>junkfile/new<Space>junkfile<Space>-start-insert

command! -nargs=1 JunkfileNote call junkfile#open(strftime('%Y-%m-%d_') . <q-args>, '.md')
command! JunkfileDaily call junkfile#open_immediately(strftime('%Y-%m-%d.md'))
let g:junkfile#directory = '~/.config/junkfile/_posts'
" }}}3


" maximizer {{{3
nnoremap <silent> <Leader>z :<C-u>MaximizerToggle<CR>
" }}}3

" miniyank {{{3
let g:miniyank_maxitems = 100
let g:miniyank_filename = expand('~/.cache/vim/miniyank.mpack')
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
AutoCmd FileType scratch nnoremap <silent> <buffer> q :<C-u>quit<CR>

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

" Mapping <Esc><Esc> {{{2
function! EscEscReset(...) abort
  AnzuClearSearchStatus
  call g:Set_default_keymap()
  highlight CursorColumn ctermfg=none ctermbg=235
  highlight CursorLine   ctermfg=none ctermbg=235
endfunction
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <Bar> call EscEscReset()<CR>
augroup esc_esc_reset
  autocmd!
  autocmd VimEnter * call timer_start(500, function('EscEscReset'))
augroup END
" }}}

" keymaps {{{

function! Set_default_keymap() abort
  let g:keymap = 'Default'
  call lightline#update()

  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "(ctrlp)"
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "(ctrln)"
  nnoremap <silent> (ctrlp) :<C-u>Denite miniyank<CR>
  nmap     <silent> (ctrln) <Plug>(VM-Find-Under)

  map  <silent> ; <Plug>(easymotion-next)
  map  <silent> , <Plug>(easymotion-prev)
endfunction

function! Set_quickfix_keymap() abort
  let g:keymap = 'QuickFix'
  call lightline#update()

  nnoremap <silent> (ctrlp) :<C-u>cprev<CR>
  nnoremap <silent> (ctrln) :<C-u>cnext<CR>
endfunction

function! Set_locationlist_keymap() abort
  let g:keymap = 'LocationList'
  call lightline#update()

  nnoremap <silent> (ctrlp) :<C-u>lprev<CR>
  nnoremap <silent> (ctrln) :<C-u>lnext<CR>
endfunction

function! Set_denite_keymap() abort
  let g:keymap = 'Denite'
  call lightline#update()

  nnoremap <silent> (ctrlp) :<C-u>Denite -resume -immediately -select=-1<CR>
  nnoremap <silent> (ctrln) :<C-u>Denite -resume -immediately -select=+1<CR>
endfunction

function! Set_visual_multi_keymap() abort
  let g:keymap = 'VisualMulti'
  call lightline#update()

  unmap ;
  unmap ,
  call vm#themes#init()
  call vm#plugs#init()
  call vm#maps#default()
  nmap <silent> (ctrln) <Plug>(VM-Find-Under)
  xmap <silent> (ctrln) <Plug>(VM-Find-Subword-Under)
  nnoremap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "(ctrlp)"
  nnoremap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "(ctrln)"
endfunction

nnoremap <silent> <Leader>kq :call Set_quickfix_keymap()<CR>
nnoremap <silent> <Leader>kl :call Set_locationlist_keymap()<CR>
nnoremap <silent> <Leader>kd :call Set_denite_keymap()<CR>
nnoremap <silent> <Leader>km :call Set_visual_multi_keymap()<CR>

AutoCmd BufEnter * call Set_default_keymap()
AutoCmd FileType qf
\ if getwininfo(win_getid())[0].loclist |
\   highlight CursorColumn ctermfg=none ctermbg=235 |
\   highlight CursorLine   ctermfg=none ctermbg=235 |
\   call Set_default_keymap()      |
\   call Set_locationlist_keymap() |
\ elseif getwininfo(win_getid())[0].quickfix |
\   highlight CursorColumn ctermfg=none ctermbg=235 |
\   highlight CursorLine   ctermfg=none ctermbg=235 |
\   call Set_default_keymap()  |
\   call Set_quickfix_keymap() |
\ endif
" }}}

" }}}1

" Load Colorscheme {{{1

syntax enable

" Highlight {{{2
AutoCmd ColorScheme * highlight CursorColumn ctermfg=none ctermbg=235
AutoCmd ColorScheme * highlight CursorLine   ctermfg=none ctermbg=235
AutoCmd ColorScheme * highlight CursorLineNr ctermfg=253  ctermbg=none
AutoCmd ColorScheme * highlight LineNr       ctermfg=241  ctermbg=none
AutoCmd ColorScheme * highlight NonText      ctermfg=60   ctermbg=none
AutoCmd ColorScheme * highlight Search       ctermfg=68   ctermbg=232
AutoCmd ColorScheme * highlight Todo         ctermfg=229  ctermbg=none
AutoCmd ColorScheme * highlight Visual       ctermfg=159  ctermbg=23

AutoCmd ColorScheme * highlight ALEError                ctermfg=0    ctermbg=203
AutoCmd ColorScheme * highlight ALEWarning              ctermfg=0    ctermbg=229
AutoCmd ColorScheme * highlight BrighTestHighlight      ctermfg=none ctermbg=none cterm=underline
AutoCmd ColorScheme * highlight CleverFDefaultLabel     ctermfg=9    ctermbg=236  cterm=underline,bold
AutoCmd ColorScheme * highlight DeniteLine              ctermfg=111  ctermbg=236
AutoCmd ColorScheme * highlight EasyMotionMoveHLDefault ctermfg=9    ctermbg=236  cterm=underline,bold
AutoCmd ColorScheme * highlight HighlightedyankRegion   ctermfg=1    ctermbg=none
AutoCmd ColorScheme * highlight MatchParen              ctermfg=247  ctermbg=none
AutoCmd ColorScheme * highlight MatchWord               ctermfg=none ctermbg=none cterm=underline,bold
AutoCmd ColorScheme * highlight YankRoundRegion         ctermfg=209  ctermbg=237
AutoCmd ColorScheme * highlight deniteSource_grepFile   ctermfg=6    ctermbg=none
AutoCmd ColorScheme * highlight deniteSource_grepLineNR ctermfg=247  ctermbg=none

" Fix lightline
AutoCmd ColorScheme * highlight StatusLine   ctermfg=0 ctermbg=7
AutoCmd ColorScheme * highlight StatusLineNC ctermfg=0 ctermbg=7
" }}}2

" iceberg {{{2
colorscheme iceberg
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
