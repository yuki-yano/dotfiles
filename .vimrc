" Encoding {{{1
if has('vim_starting')
  set encoding=utf-8
  scriptencoding utf-8
endif
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
  call dein#add('1995eaton/vim-better-css-completion',        {'lazy': 1, 'on_ft': ['css', 'sass', 'scss'], 'on_event': 'InsertEnter'})
  call dein#add('1995eaton/vim-better-javascript-completion', {'lazy': 1, 'on_ft': ['javascript', 'typescript'], 'on_event': 'InsertEnter'})
  call dein#add('Chiel92/vim-autoformat',                     {'lazy': 1, 'on_cmd': 'Autoformat'})
  call dein#add('Galooshi/vim-import-js',                     {'lazy': 1, 'on_ft': 'javascript', 'on_event': 'InsertEnter'})
  call dein#add('Quramy/tsuquyomi',                           {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('Quramy/vim-js-pretty-template',              {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('Shougo/context_filetype.vim')
  call dein#add('Shougo/echodoc.vim',                         {'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('SpaceVim/vim-markdown',                      {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('Valloric/MatchTagAlways',                    {'lazy': 1, 'on_ft': ['html', 'xml']})
  call dein#add('Vimjas/vim-python-pep8-indent',              {'lazy': 1, 'on_ft': 'python'})
  call dein#add('ap/vim-css-color',                           {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('cakebaker/scss-syntax.vim',                  {'lazy': 1, 'on_ft': ['sass', 'scss']})
  call dein#add('chrisbra/vim-zsh',                           {'lazy': 1, 'on_ft': 'zsh'})
  call dein#add('davidhalter/jedi-vim',                       {'lazy': 1, 'on_ft': 'python'})
  call dein#add('digitaltoad/vim-pug',                        {'lazy': 1, 'on_ft': ['jade', 'pug']})
  call dein#add('elzr/vim-json',                              {'lazy': 1, 'on_ft': 'json'})
  call dein#add('fatih/vim-go',                               {'lazy': 1, 'on_ft': 'go'})
  call dein#add('fs111/pydoc.vim',                            {'lazy': 1, 'on_ft': 'python'})
  call dein#add('hail2u/vim-css3-syntax',                     {'lazy': 1, 'on_ft': 'css'})
  call dein#add('hashivim/vim-terraform',                     {'lazy': 1, 'on_ft': 'terraform'})
  call dein#add('heavenshell/vim-jsdoc',                      {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('heavenshell/vim-pydocstring',                {'lazy': 1, 'on_ft': 'python'})
  call dein#add('iamcco/markdown-preview.vim',                {'lazy': 1, 'on_ft': 'markdown', 'depends': 'open-browser.vim'})
  call dein#add('iamcco/mathjax-support-for-mkdp',            {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('jason0x43/vim-js-indent',                    {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('jodosha/vim-godebug',                        {'lazy': 1, 'on_ft': 'go'})
  call dein#add('joker1007/vim-markdown-quote-syntax',        {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('jparise/vim-graphql',                        {'lazy': 1, 'on_ft': 'graphql'})
  call dein#add('kchmck/vim-coffee-script',                   {'lazy': 1, 'on_ft': 'coffee'})
  call dein#add('kewah/vim-stylefmt',                         {'lazy': 1, 'on_ft': 'css'})
  call dein#add('lambdalisue/smartcl.vim')
  call dein#add('leafgarland/typescript-vim',                 {'lazy': 1, 'on_ft': 'typescript'})
  call dein#add('mattn/emmet-vim',                            {'lazy': 1, 'on_ft': ['html', 'eruby', 'javascript', 'typescript', 'vue']})
  call dein#add('maxmellon/vim-jsx-pretty',                   {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('mhinz/vim-lookup')
  call dein#add('mzlogin/vim-markdown-toc',                   {'lazy': 1, 'on_ft': 'markdown'})
  call dein#add('noprompt/vim-yardoc',                        {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('othree/csscomplete.vim',                     {'lazy': 1, 'on_ft': ['css', 'sass', 'scss']})
  call dein#add('othree/es.next.syntax.vim',                  {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('othree/html5.vim',                           {'lazy': 1, 'on_ft': ['html', 'eruby', 'markdown']})
  call dein#add('othree/javascript-libraries-syntax.vim',     {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('othree/jspc.vim',                            {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('othree/yajs.vim',                            {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('pangloss/vim-javascript',                    {'lazy': 1, 'on_ft': 'javascript'})
  call dein#add('plytophogy/vim-virtualenv',                  {'lazy': 1, 'on_ft': 'python'})
  call dein#add('pocke/iro.vim')
  call dein#add('posva/vim-vue',                              {'lazy': 1, 'on_ft': 'vue'})
  call dein#add('prettier/vim-prettier',                      {'lazy': 1, 'on_ft': ['javascript', 'typescript', 'vue', 'css', 'less', 'scss', 'json', 'graphql', 'markdown']})
  call dein#add('rust-lang/rust.vim',                         {'lazy': 1, 'on_ft': 'rust'})
  call dein#add('sgur/vim-editorconfig')
  call dein#add('sheerun/vim-polyglot')
  call dein#add('styled-components/vim-styled-components',    {'lazy': 1, 'on_ft': ['javascript', 'typescript']})
  call dein#add('syngan/vim-vimlint',                         {'lazy': 1, 'on_ft': 'vim'})
  call dein#add('tell-k/vim-autopep8',                        {'lazy': 1, 'on_ft': 'python'})
  call dein#add('tmhedberg/SimpylFold',                       {'lazy': 1, 'on_ft': 'python'})
  call dein#add('todesking/vint-syntastic',                   {'lazy': 1, 'on_ft': 'vim'})
  call dein#add('tpope/vim-bundler',                          {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('tpope/vim-rails',                            {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('tpope/vim-rake',                             {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('tweekmonster/exception.vim')
  call dein#add('vim-jp/syntax-vim-ex',                       {'lazy': 1, 'on_ft': 'vim'})
  call dein#add('vim-python/python-syntax',                   {'lazy': 1, 'on_ft': 'python'})
  call dein#add('vim-ruby/vim-ruby',                          {'lazy': 1, 'on_ft': ['ruby', 'eruby']})
  call dein#add('vim-scripts/python_match.vim',               {'lazy': 1, 'on_ft': 'python'})
  call dein#add('vimperator/vimperator.vim',                  {'lazy': 1, 'on_ft': 'vimperator'})
  call dein#add('vimtaku/hl_matchit.vim',                     {'lazy': 1, 'on_ft': 'ruby'})
  call dein#add('ynkdir/vim-vimlparser',                      {'lazy': 1, 'on_ft': 'vim'})
  call dein#add('yukiycino-dotfiles/gen_tags.vim')
  call dein#add('ywatase/mdt.vim',                            {'lazy': 1, 'on_ft': 'markdown', 'on_cmd': 'Mdt'})
  " }}}3

  " ALE {{{
  call dein#add('w0rp/ale', {'lazy': 1, 'on_ft': s:ale_filetypes})
  " }}}

  " Git {{{3
  call dein#add('airblade/vim-gitgutter')
  call dein#add('airblade/vim-rooter')
  call dein#add('cohama/agit.vim',               {'lazy': 1, 'on_cmd': ['Agit', 'AgitFile']})
  call dein#add('hotwatermorning/auto-git-diff', {'lazy': 1, 'on_ft': 'gitrebase'})
  call dein#add('lambdalisue/gina.vim')
  call dein#add('lambdalisue/vim-unified-diff')
  call dein#add('rhysd/committia.vim')

  call dein#add('rhysd/ghpr-blame.vim',          {'lazy': 1, 'on_cmd': 'GHPRBlame'})
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

  call dein#add('autozimu/LanguageClient-neovim', {
  \ 'on_ft': ['javascript', 'typescript', 'vue', 'rust'],
  \ 'rev': 'next',
  \ 'build': 'bash install.sh'})

  call dein#add('Shougo/deoplete-rct',         {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'ruby'})
  call dein#add('Shougo/neco-syntax',          {'lazy': 1, 'depends': 'deoplete.nvim'})
  call dein#add('Shougo/neco-vim',             {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'vim'})
  call dein#add('Shougo/neoinclude.vim',       {'lazy': 1, 'depends': 'deoplete.nvim'})
  call dein#add('carlitux/deoplete-ternjs',    {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': ['javascript', 'typescript']})
  call dein#add('fishbullet/deoplete-ruby',    {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'ruby'})
  call dein#add('fszymanski/deoplete-emoji',   {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': ['gitcommit', 'markdown']})
  call dein#add('mhartington/nvim-typescript', {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'typescript'})
  call dein#add('osyo-manga/vim-monster',      {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'ruby'})
  call dein#add('ozelentok/deoplete-gtags',    {'lazy': 1, 'depends': 'deoplete.nvim'})
  call dein#add('rhysd/github-complete.vim',   {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': ['gitcommit', 'markdown']})
  call dein#add('ujihisa/neco-look',           {'lazy': 1, 'depends': 'deoplete.nvim'})
  call dein#add('wellle/tmux-complete.vim',    {'lazy': 1, 'depends': 'deoplete.nvim'})
  call dein#add('wokalski/autocomplete-flow',  {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'javascript'})
  call dein#add('zchee/deoplete-go',           {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'go', 'build': 'make'})
  call dein#add('zchee/deoplete-jedi',         {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'python'})
  call dein#add('zchee/deoplete-zsh',          {'lazy': 1, 'depends': 'deoplete.nvim', 'on_ft': 'zsh'})

  call dein#add('blueyed/vim-auto-programming', {'rev': 'neovim'})
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/unite.vim')

  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/unite-outline')
  call dein#add('Shougo/vimfiler')
  call dein#add('hewes/unite-gtags')
  call dein#add('osyo-manga/unite-highlight')
  call dein#add('osyo-manga/unite-quickfix')
  call dein#add('ozelentok/denite-gtags')
  call dein#add('tacroe/unite-mark')
  call dein#add('tsukkee/unite-tag')

  call dein#add('SpaceVim/gtags.vim')

  call dein#add('Shougo/neosnippet')
  call dein#add('Shougo/neosnippet-snippets', {'depends': 'neosnippet'})

  set  runtimepath+=/usr/local/opt/fzf
  call dein#add('yuki-ycino/fzf-preview-mode.vim')
  " }}}3

  " NerdTree {{{3
  call dein#add('scrooloose/nerdtree',                     {'lazy': 1, 'on_cmd': 'NERDTreeToggle'})

  call dein#add('Xuyuanp/nerdtree-git-plugin',             {'lazy': 1, 'depends': 'nerdtree'})
  call dein#add('jistr/vim-nerdtree-tabs',                 {'lazy': 1, 'depends': 'nerdtree'})
  call dein#add('tiagofumo/vim-nerdtree-syntax-highlight', {'lazy': 1, 'depends': 'nerdtree'})
  " }}}3

  " Edit & Move & Search {{{3
  call dein#add('AndrewRadev/splitjoin.vim',              {'lazy': 1, 'on_cmd': ['SplitjoinJoin', 'SplitjoinSplit']})
  call dein#add('AndrewRadev/switch.vim',                 {'lazy': 1, 'on_cmd': 'Switch'})
  call dein#add('DeaR/vim-textobj-wiw',                   {'depends': 'vim-textobj-user'})
  call dein#add('LeafCage/yankround.vim')
  call dein#add('chrisbra/NrrwRgn',                       {'lazy': 1, 'on_cmd': ['NR', 'NW', 'WidenRegion', 'NRV', 'NUD', 'NRP', 'NRM', 'NRS', 'NRN', 'NRL']})
  call dein#add('cohama/lexima.vim',                      {'lazy': 1, 'on_event': 'InsertEnter', 'hook_source': 'call Hook_on_post_source_lexima()'})
  call dein#add('dhruvasagar/vim-table-mode',             {'lazy': 1, 'on_cmd': 'TableModeToggle'})
  call dein#add('dyng/ctrlsf.vim',                        {'lazy': 1, 'on_cmd': 'CtrlSF'})
  call dein#add('easymotion/vim-easymotion')
  call dein#add('godlygeek/tabular',                      {'lazy': 1, 'on_cmd': 'Tabularize'})
  call dein#add('h1mesuke/vim-alignta',                   {'lazy': 1, 'on_cmd': 'Alignta'})
  call dein#add('haya14busa/incsearch-fuzzy.vim',         {'lazy': 1, 'on_map': '<Plug>', 'depends': 'incsearch.vim'})
  call dein#add('haya14busa/incsearch.vim',               {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-asterisk',                {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-edgemotion',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('haya14busa/vim-metarepeat',              {'lazy': 1, 'on_map': ['go', 'g.']})
  call dein#add('haya14busa/vim-textobj-function-syntax', {'depends': 'vim-textobj-user'})
  call dein#add('junegunn/vim-easy-align')
  call dein#add('kana/vim-operator-replace',              {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('kana/vim-textobj-function',              {'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-indent',                {'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-line',                  {'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-user')
  call dein#add('kshenoy/vim-signature')
  call dein#add('machakann/vim-sandwich')
  call dein#add('mopp/vim-operator-convert-case')
  call dein#add('osyo-manga/vim-anzu',                    {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('osyo-manga/vim-jplus',                   {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('osyo-manga/vim-trip',                    {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('othree/eregex.vim')
  call dein#add('pbrisbin/vim-mkdir')
  call dein#add('rhysd/accelerated-jk')
  call dein#add('rhysd/clever-f.vim',                     {'lazy': 1, 'on_map': {'nvxo': '<Plug>'}})
  call dein#add('rhysd/vim-textobj-ruby',                 {'lazy': 1, 'on_ft': 'ruby', 'depends': 'vim-textobj-user'})
  call dein#add('rking/ag.vim',                           {'lazy': 1, 'on_cmd': 'Ag'})
  call dein#add('t9md/vim-textmanip',                     {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-qfreplace')
  call dein#add('thinca/vim-textobj-between',             {'depends': 'vim-textobj-user'})
  call dein#add('tommcdo/vim-exchange')
  call dein#add('tomtom/tcomment_vim',                    {'lazy': 1, 'on_cmd': ['TComment', 'TCommentBlock', 'TCommentInline', 'TCommentRight', 'TCommentBlock', 'TCommentAs']})
  call dein#add('tpope/vim-repeat',                       {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  call dein#add('tpope/vim-speeddating',                  {'lazy': 1, 'on_map': {'n': '<Plug>'}})
  " }}}3

  " Appearance {{{3
  call dein#add('AndrewRadev/linediff.vim',       {'lazy': 1, 'on_cmd': ['Linediff', 'LinediffReset']})
  call dein#add('LeafCage/foldCC.vim')
  call dein#add('Yggdroot/indentLine',            {'lazy': 1, 'on_cmd': 'IndentLinesToggle'})
  call dein#add('amix/vim-zenroom2',              {'lazy': 1, 'on_cmd': 'Goyo'})
  call dein#add('blueyed/vim-diminactive')
  call dein#add('edkolev/tmuxline.vim',           {'lazy': 1, 'on_cmd': ['Tmuxline', 'TmuxlineSimple', 'TmuxlineSnapshot']})
  call dein#add('gregsexton/MatchTag')
  call dein#add('haya14busa/vim-operator-flashy', {'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('itchyny/lightline.vim',          {'depends': ['vim-anzu', 'lightline-ale']})
  call dein#add('itchyny/vim-highlighturl')
  call dein#add('itchyny/vim-parenmatch')
  call dein#add('junegunn/goyo.vim',              {'lazy': 1, 'on_cmd': 'Goyo'})
  call dein#add('luochen1990/rainbow')
  call dein#add('maximbaz/lightline-ale')
  call dein#add('mhinz/vim-startify')
  call dein#add('mopp/smartnumber.vim',           {'lazy': 1, 'on_cmd': 'SNumbersToggleRelative'})
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('osyo-manga/vim-brightest')
  call dein#add('t9md/vim-quickhl')
  call dein#add('thinca/vim-zenspace')
  call dein#add('vim-scripts/AnsiEsc.vim')
  runtime macros/matchit.vim
  " }}}3

  " Util {{{3
  call dein#add('Shougo/deol.nvim',                       { 'lazy': 1, 'on_cmd': ['Deol', 'DeolCd', 'DeolEdit'], 'on_map': '<Plug>'})
  call dein#add('aiya000/aho-bakaup.vim')
  call dein#add('bogado/file-line')
  call dein#add('dietsche/vim-lastplace')
  call dein#add('haya14busa/vim-textobj-function-syntax', { 'depends': 'vim-textobj-user'})
  call dein#add('janko-m/vim-test',                       { 'lazy': 1, 'on_cmd': ['TestNearest','TestFile','TestSuite','TestLast','TestVisit']})
  call dein#add('kana/vim-niceblock',                     { 'lazy': 1, 'on_map': {'v': ['x', 'I', 'A'] }})
  call dein#add('haya14busa/vim-open-googletranslate', {'lazy': 1, 'on_cmd': 'OpenGoogleTranslate'})
  call dein#add('kana/vim-operator-user')
  call dein#add('kana/vim-submode',                       { 'depends': 'vim-operator-convert-case'})
  call dein#add('kana/vim-textobj-fold',                  { 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-indent',                { 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-underscore',            { 'depends': 'vim-textobj-user'})
  call dein#add('kana/vim-textobj-user')
  call dein#add('konfekt/fastfold')
  call dein#add('lambdalisue/session.vim',                { 'lazy': 1, 'on_cmd': ['SessionSave', 'SessionOpen', 'SessionRemove', 'SessionList', 'SessionClose']})
  call dein#add('lambdalisue/suda.vim')
  call dein#add('majutsushi/tagbar',                      { 'lazy': 1, 'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('mattn/benchvimrc-vim',                   { 'lazy': 1, 'on_cmd': 'BenchVimrc'})
  call dein#add('mbbill/undotree',                        { 'lazy': 1, 'on_cmd': 'UndotreeToggle'})
  call dein#add('mtth/scratch.vim',                       { 'lazy': 1, 'on_cmd': 'Scratch'})
  call dein#add('osyo-manga/vim-gift')
  call dein#add('pocke/vim-automatic',                    { 'depends': 'vim-gift'})
  call dein#add('qpkorr/vim-bufkill')
  call dein#add('rhysd/vim-textobj-ruby',                 { 'lazy': 1, 'on_ft': 'ruby', 'depends': 'vim-textobj-user'})
  call dein#add('simeji/winresizer',                      { 'lazy': 1, 'on_cmd': 'WinResizerStartResize'})
  call dein#add('szw/vim-maximizer',                      { 'lazy': 1, 'on_cmd': 'MaximizerToggle'})
  call dein#add('terryma/vim-expand-region',              { 'lazy': 1, 'on_map': '<Plug>'})
  call dein#add('thinca/vim-ref',                         { 'lazy': 1, 'on_cmd': 'Ref'})
  call dein#add('tweekmonster/startuptime.vim',           { 'lazy': 1, 'on_cmd': 'StartupTime'})
  call dein#add('tyru/capture.vim',                       { 'lazy': 1, 'on_cmd': 'Capture'})
  call dein#add('tyru/open-browser.vim')
  call dein#add('tyru/vim-altercmd')
  call dein#add('wesQ3/vim-windowswap',                   { 'lazy': 1, 'on_func': ['WindowSwap#EasyWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#MarkWindowSwap', 'WindowSwap#DoWindowSwap']})
  " }}}3

  " Library {{{3
  call dein#add('Shougo/vimproc.vim', {'build': 'make'})
  call dein#add('nixprime/cpsm',          {'build': 'env PY3=ON ./install.sh'})
  call dein#add('vim-scripts/L9')
  call dein#add('vim-scripts/cecutil')
  " }}}3

  " Color Theme {{{3
  call dein#add('altercation/vim-colors-solarized')
  call dein#add('cocopon/iceberg.vim')
  call dein#add('nanotech/jellybeans.vim')
  call dein#add('tomasr/molokai')
  call dein#add('w0ng/vim-hybrid')
  " }}}3

  " DevIcons {{{3
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

" }}}1

" Global Settings {{{1

" Easy autocmd {{{2
augroup MyVimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd MyVimrc <args>
" }}}2

" Encoding {{{2
set fileencodings=utf-8,sjis,cp932,euc-jp
set fileformats=unix,mac,dos
set termencoding=utf-8

if &modifiable
  set fileencoding=utf-8
endif
" }}}2

" Appearance {{{2
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
nnoremap <M-h> ^
nnoremap <M-l> $
nnoremap <C-o> <C-o>zzzv
nnoremap <C-i> <C-i>zzzv

"" Buffer
nnoremap <C-b> <C-^>

"" Window
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-l> :wincmd l<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-j> :wincmd j<CR>

"" Insert Mode
inoremap <C-h> <BS>
inoremap <C-d> <Del>

"" Select buffer
nnoremap B :<C-u>ls<CR>:buffer<Space>

"" Ignore registers
nnoremap x "_x

"" Indent
vnoremap < <gv
vnoremap > >gv|

"" Move CommandLine
noremap! <C-a> <Home>
noremap! <C-b> <Left>
noremap! <C-d> <Del>
noremap! <C-e> <End>
noremap! <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" tab
nnoremap <Leader>tt :<C-u>tablast <Bar> tabnew<CR>
nnoremap <Leader>tc :<C-u>tabclose<CR>

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

"" terminal
if has('nvim')
  tnoremap <silent> <Esc> <C-\><C-n>
endif
nnoremap <silent> <Leader>s :terminal<CR>
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
if $TERM ==# 'screen'
  set t_Co=256
endif
if !has('nvim')
  set term=xterm-256color
endif
" }}}2

" Disable Paste Mode {{{2
AutoCmd InsertLeave * setlocal nopaste
" }}}2

" Disable Auto Comment {{{2
AutoCmd FileType * setlocal formatoptions-=ro
" }}}2

" Highlight Annotation Comment {{{2
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|NOTE\|INFO\|XXX\|TEMP\):')
AutoCmd WinEnter,BufRead,BufNew,Syntax * highlight Todo ctermfg=229
" }}}2

" Misc {{{2
set completeopt=longest,menuone,preview
set noswapfile
set history=1000
set undodir=~/.vim_undo
set undofile
set viewoptions=cursor,folds
set hlsearch | nohlsearch
set ignorecase
set smartcase
set autoread
set belloff=all
set clipboard=unnamed,unnamedplus
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
set nostartofline
" }}}2

" Turn off default plugins. {{{2
let g:loaded_gzip            = 1
let g:loaded_tar             = 1
let g:loaded_tarPlugin       = 1
let g:loaded_zip             = 1
let g:loaded_zipPlugin       = 1
let g:loaded_rrhelper        = 1
let g:loaded_2html_plugin    = 1
let g:loaded_vimball         = 1
let g:loaded_vimballPlugin   = 1
let g:loaded_getscript       = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_logipat         = 1
let g:loaded_matchparen      = 1
let g:loaded_man             = 1
" }}}2

" Highlight Annotation Comment {{{2
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|NOTE\|INFO\|XXX\|TEMP\):')
AutoCmd WinEnter,BufRead,BufNew,Syntax * highlight Todo ctermfg=229
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

" Rename {{{2
command! -nargs=1 -complete=file Rename file <args> | call delete(expand('#'))
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

nnoremap <Leader>tm :<C-u>tablast <Bar> call <SID>move_to_new_tab()<CR>
" }}}2

" }}}1

" Other Settings {{{1

" FileType {{{2

" Intent {{{3
AutoCmd FileType go         setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType vim        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType sh         setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType zsh        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" iskeyword {{{3
AutoCmd FileType javascript setlocal iskeyword+=$ iskeyword+=? iskeyword+=/
AutoCmd FileType vue        setlocal iskeyword+=$ iskeyword+=& iskeyword+=- iskeyword+=? iskeyword+=/
AutoCmd FileType ruby       setlocal iskeyword+=@ iskeyword+=! iskeyword+=? iskeyword+=&
AutoCmd FileType html       setlocal iskeyword+=-
AutoCmd FileType scss       setlocal iskeyword+=$ iskeyword+=& iskeyword+=-
AutoCmd FileType sh         setlocal iskeyword+=$
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
AutoCmd FileType html       setlocal omnifunc=htmlcomplete#CompleteTags
AutoCmd FileType eruby      setlocal omnifunc=htmlcomplete#CompleteTags
AutoCmd FileType python     setlocal omnifunc=pythoncomplete#Complete
AutoCmd FileType css        setlocal omnifunc=csscomplete#CompleteCSS
AutoCmd FileType scss       setlocal omnifunc=csscomplete#CompleteCSS
AutoCmd FileType gitcommit  setlocal omnifunc=github_complete#complete
AutoCmd FileType markdown   setlocal omnifunc=github_complete#complete

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

" HTML {{{2
augroup HTML
  autocmd!
  autocmd FileType html call s:map_html_keys()
  function! s:map_html_keys()
    inoremap <silent> <buffer> \\ \
    inoremap <silent> <buffer> \& &amp;
    inoremap <silent> <buffer> \< &lt;
    inoremap <silent> <buffer> \> &gt;
    inoremap <silent> <buffer> \. ・
    inoremap <silent> <buffer> \- &#8212;
    inoremap <silent> <buffer> \<Space> &nbsp;
    inoremap <silent> <buffer> \` &#8216;
    inoremap <silent> <buffer> \' &#8217;
    inoremap <silent> <buffer> \2 &#8220;
    inoremap <silent> <buffer> \" &#8221;
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
nnoremap : q:
xnoremap : q:
nnoremap q: :
xnoremap q: :

nnoremap / q/
nnoremap q/ /

nnoremap ? q?
nnoremap q? ?

AutoCmd CmdWinEnter * set number | set norelativenumber
AutoCmd CmdwinEnter * call s:init_cmdwin()

function! s:init_cmdwin()
  inoremap <silent> <buffer> <expr> <CR>  pumvisible() ? "\<C-y>\<CR>"  : "\<CR>"
  inoremap <silent> <buffer> <expr> <Tab> pumvisible() ? "\<Tab>" : deoplete#mappings#manual_complete()

  nnoremap <buffer> <silent> dd :<C-u>rviminfo<CR>:call histdel(getcmdwintype(), line('.') - line('$'))<CR>:wviminfo!<CR>dd

  startinsert!
endfunction
" }}}1

" Plugin Settings {{{1

" Language {{{2

" ALE {{{3
let g:ale_linters = {
\ 'javascript': ['eslint', 'flow'],
\ 'typescript': ['eslint', 'tslint'],
\ 'vue':        ['eslint', 'flow'],
\ 'ruby':       ['rubocop'],
\ 'eruby':      [],
\ 'python':     ['autopep8', 'flake8', 'isort', 'mypy', 'yapf'],
\ 'go':         ['golint', 'go vet'],
\ 'rust':       ['rustc', 'cargo', 'rustfmt', 'rls'],
\ 'html':       ['htmlhint'],
\ 'css':        ['stylelint'],
\ 'scss':       ['stylelint'],
\ 'vim':        ['vint'],
\ 'sh':         ['shell', 'shellcheck'],
\ 'bash':       ['shell', 'shellcheck'],
\ 'zsh':        ['shell', 'shellcheck'],
\ }

let g:ale_linter_aliases = {
\ 'vue'  : 'css',
\ 'eruby': 'html',
\ }

let g:ale_sh_shellcheck_exclusions = 'SC1090,SC2155,SC2164,SC2190'

let g:ale_change_sign_column_color = 1
let g:ale_set_signs = 1
let g:ale_sign_error = "\uf057"
let g:ale_sign_warning = "\uf071"
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_emit_conflict_warnings = 0
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

" better-javascript-completion {{{
let g:vimjs#casesensistive = 1
let g:vimjs#chromeapis = 1
let g:vimjs#smartcomplete = 1
" }}}

" echodoc {{{3
let g:echodoc_enable_at_startup = 1
" }}}3

" emmet {{{3
let g:user_emmet_leader_key=','
let g:user_emmet_mode='in'
" }}}3

" gen_tags {{{3
" let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#gtags_auto_gen = 1
" }}}3

" go {{{3
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = 'goimports'
" }}}3

" html5 {{{3
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1
" }}}3

" iro {{{
if dein#tap('iro.vim')
  function! s:iro_clean()
    if &filetype !=# 'ruby'
      execute printf('ruby Iro.clean(%d)', winnr())
    endif
  endfunction

  AutoCmd BufEnter * call s:iro_clean()
endif
" }}}

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

" polyglot {{{3
let g:polyglot_disabled = ['javascript', 'ruby', 'python', 'vue', 'json', 'css', 'sass', 'scss', 'markdown']
" }}}3

" prettier {{{3
let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat = 0

function! s:prettier_settings()
  let g:prettier#exec_cmd_path = '~/dotfiles/node_modules/.bin/prettier'
  nnoremap <silent> <buffer> <Leader>a :<C-u>Prettier<CR>
endfunction

function! s:prettier_vue_settings()
  let g:prettier#exec_cmd_path = '~/dotfiles/node_modules/.bin/vue-prettier'
  nnoremap <silent> <buffer> <Leader>a :<C-u>Autoformat <Bar> Prettier<CR>
endfunction

AutoCmd FileType javascript              call s:prettier_settings()
AutoCmd FileType vue.html.javascript.css call s:prettier_vue_settings()
" }}}3

" ruby {{{3
let g:rubycomplete_rails                = 1
let g:rubycomplete_buffer_loading       = 1
let g:rubycomplete_classes_in_global    = 1
let g:rubycomplete_include_object       = 1
let g:rubycomplete_include_object_space = 1
" }}}3

" vim {{{3
let g:vimsyntax_noerror = 1
let g:vim_indent_cont = 0
" }}}3

" vue {{{
let g:vue_disable_pre_processors = 1
AutoCmd FileType vue syntax sync fromstart
AutoCmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css
" }}}

" }}}2

" Completion & Fuzzy Finder & vimfiler {{{2

" Denite & Unite {{{3
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
  call denite#custom#source('_', 'matchers', ['matcher_fuzzy', 'matcher_cpsm'])
  call denite#custom#source('file_mru', 'matchers', ['matcher_fuzzy', 'matcher_cpsm', 'matcher_project_files'])

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
  let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '-p', '~/.agignore', '-g', '']
  " nnoremap <silent> <Leader>p :<C-u>Unite file_rec/async:! -start-insert<CR>
  nnoremap <silent> <Leader>m :<C-u>Unite neomru/file -start-insert<CR>
  nnoremap <silent> <Leader>M :<C-u>Unite file_mru -start-insert<CR>
  " nnoremap <silent> <Leader>f :<C-u>Unite buffer file_mru file_rec/async:! -start-insert<CR>
  " nnoremap <silent> <Leader>b :<C-u>Unite buffer -start-insert<CR>

  "" jump
  nnoremap <silent> <Leader><C-o> :<C-u>Unite jump change -auto-preview -direction=botright<CR>

  "" ctags & gtags
  " nnoremap <silent> <Leader><C-]> :<C-u>UniteWithCursorWord gtags/context tag -direction=botright<CR>

  "" outline
  nnoremap <silent> <Leader>o :<C-u>Unite outline -auto-preview -direction=botright<CR>

  "" grep
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''

  call unite#custom_source('line', 'sorters', 'sorter_reverse')
  call unite#custom_source('grep', 'sorters', 'sorter_reverse')
  nnoremap <silent> <Leader>/          :<C-u>Unite line -direction=botright -buffer-name=search-buffer -start-insert -no-quit<CR>
  nnoremap <silent> <Leader>//         :<C-u>Unite line -direction=botright -buffer-name=search-buffer -start-insert -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader>*          :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader>**         :<C-u>UniteWithCursorWord line -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>/  :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -start-insert -no-quit<CR>
  nnoremap <silent> <Leader><Leader>// :<C-u>Unite grep -direction=botright -buffer-name=search-buffer -start-insert -no-quit -auto-preview<CR>
  nnoremap <silent> <Leader><Leader>*  :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit<CR>
  nnoremap <silent> <Leader><Leader>** :<C-u>UniteWithCursorWord grep -direction=botright -buffer-name=search-buffer -no-quit -auto-preview<CR>

  "" yank
  let g:unite_source_history_yank_enable = 1
  nnoremap <silent> <Leader><Leader>p :<C-u>Unite yankround<CR>

  "" quickfix
  let g:unite_quickfix_filename_is_pathshorten = 0
  call unite#custom_source('quickfix', 'sorters', 'sorter_reverse')
  call unite#custom_source('location_list', 'sorters', 'sorter_reverse')
  nnoremap <silent> <Leader>q :<C-u>Unite quickfix -direction=botright -no-quit<CR>
  nnoremap <silent> <Leader>l :<C-u>Unite location_list -direction=botright -no-quit<CR>

  "" session
  " nnoremap <Leader>ss :<C-u>UniteSessionSave<CR>
  " nnoremap <Leader>sl :<C-u>UniteSessionLoad<CR>

  "" resume
  " nnoremap <silent> <Leader>re :<C-u>Unite -resume<CR>
endif
" }}}3

" fzf {{{3
nnoremap <silent> <Leader>p :<C-u>ProjectFilesPreview<CR>
nnoremap <silent> <Leader>b :<C-u>BuffersPreview<CR>
" }}}3

" deoplete.nvim && neosnippet.vim {{{3
if has('nvim')
  if dein#tap('deoplete.nvim') && dein#tap('neosnippet')
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#enable_camel_case = 1
    let g:deoplete#auto_complete_delay = 0
    let g:deoplete#auto_complete_start_length = 1
    let g:deoplete#enable_refresh_always = 0
    let g:deoplete#tag#cache_limit_size = 5000000
    let g:deoplete#skip_chars = ['(', ')']

    call deoplete#custom#source('_', 'converters', [
    \ 'converter_remove_paren',
    \ 'converter_remove_overlap',
    \ 'converter_truncate_abbr',
    \ 'converter_truncate_menu',
    \ 'converter_auto_delimiter',
    \ ])

    let g:monster#completion#rcodetools#backend = 'async_rct_complete'
    let g:deoplete#sources#go#gocode_binary = $GOPATH . '/bin/gocode'
    let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

    call deoplete#custom#source('LanguageClient', 'rank', 1000)
    call deoplete#custom#source('around',         'rank',  900)
    call deoplete#custom#source('neosnippet',     'rank',  900)
    call deoplete#custom#source('ternjs',         'rank',  900)
    call deoplete#custom#source('flow',           'rank',  900)
    call deoplete#custom#source('rct',            'rank',  900)
    call deoplete#custom#source('ruby',           'rank',  900)
    call deoplete#custom#source('jedi',           'rank',  900)
    call deoplete#custom#source('go',             'rank',  900)
    call deoplete#custom#source('emoji',          'rank',  900)
    call deoplete#custom#source('vim',            'rank',  900)
    call deoplete#custom#source('zsh',            'rank',  900)
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
    call deoplete#custom#source('member',         'mark', '[member]')
    call deoplete#custom#source('buffer',         'mark', '[buffer]')
    call deoplete#custom#source('gtags',          'mark', '[gtags]')
    call deoplete#custom#source('tag',            'mark', '[tag]')
    call deoplete#custom#source('dictionary',     'mark', '[dict]')
    call deoplete#custom#source('omni',           'mark', '[omni]')
    call deoplete#custom#source('syntax',         'mark', '[syntax]')
    call deoplete#custom#source('tern',           'mark', '[tern]')
    call deoplete#custom#source('flow',           'mark', '[flow]')
    call deoplete#custom#source('rct',            'mark', '[rct]')
    call deoplete#custom#source('ruby',           'mark', '[ruby]')
    call deoplete#custom#source('jedi',           'mark', '[jedi]')
    call deoplete#custom#source('go',             'mark', '[go]')
    call deoplete#custom#source('emoji',          'mark', '[emoji]')
    call deoplete#custom#source('vim',            'mark', '[vim]')
    call deoplete#custom#source('zsh',            'mark', '[zsh]')
    call deoplete#custom#source('tmux',           'mark', '[tmux]')

    let g:deoplete#sources = {}
    let g:deoplete#sources._          = ['around', 'gtags', 'member', 'buffer', 'omni', 'syntax', 'dictionary', 'look', 'neosnippet', 'file']
    let g:deoplete#sources.javascript = ['ternjs', 'flow']
    let g:deoplete#sources.typescript = ['ternjs']
    let g:deoplete#sources.ruby       = ['rct', 'ruby']
    let g:deoplete#sources.python     = ['jedi']
    let g:deoplete#sources.go         = ['go']
    let g:deoplete#sources.markdown   = ['emoji']
    let g:deoplete#sources.gitcommit  = ['emoji']
    let g:deoplete#sources.vim        = ['vim']
    let g:deoplete#sources.zsh        = ['zsh']

    let g:deoplete#omni#input_patterns            = {}
    let g:deoplete#omni#input_patterns._          = ''
    let g:deoplete#omni#input_patterns.ruby       = '[^. *\t]\.\w*\|\h\w*::'
    let g:deoplete#omni#input_patterns.javascript = ''
    let g:deoplete#omni#input_patterns.typescript = ''
    let g:deoplete#omni#input_patterns.python     = ''
    let g:deoplete#omni#input_patterns.go         = ''
    let g:deoplete#omni#input_patterns.html       = '<[^>]*'
    let g:deoplete#omni#input_patterns.xml        = '<[^>]*'
    let g:deoplete#omni#input_patterns.css        = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
    let g:deoplete#omni#input_patterns.scss       = '^\s\+\w\+\|\w\+[):;]\?\s\+\w*\|[@!]'
    let g:deoplete#omni#input_patterns.gitcommit  = '[ ]#[ 0-9a-zA-Z]*'

    let g:deoplete#omni#functions            = {}
    let g:deoplete#omni#functions._          = ['autoprogramming#compwlete']
    let g:deoplete#omni#functions.javascript = ['jspc#omni', 'js#CompleteJS', 'javascriptcomplete#CompleteJS']
    let g:deoplete#omni#functions.typescript = ['tsuquyomi#complete', 'jspc#omni', 'js#CompleteJS', 'javascriptcomplete#CompleteJS']
    let g:deoplete#omni#functions.ruby       = ['rubycomplete#Complete', 'monster#omnifunc']
    let g:deoplete#omni#functions.python     = ['pythoncomplete#Complete']
    let g:deoplete#omni#functions.css        = ['csscomplete#CompleteCSS']
    let g:deoplete#omni#functions.scss       = ['csscomplete#CompleteCSS']
    let g:deoplete#omni#functions.gitcommit  = ['github_complete#complete']
    let g:deoplete#omni#functions.markdown   = ['github_complete#complete']

    " tern
    let g:tern_request_timeout = 1
    let g:tern_show_signature_in_pum = 0
    let g:tern#filetypes = [
    \ 'javascript',
    \ 'vue'
    \ ]

    let g:neosnippet#disable_runtime_snippets = { '_' : 1 }
    let g:neosnippet#snippets_directory = '~/.vim/bundle/repos/github.com/honza/vim-snippets/snippets/'

    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    inoremap <silent> <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
    inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
    inoremap <silent> <expr> '  pumvisible() ? deoplete#close_popup() : "'"
    imap <expr> <TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
    smap <expr> <TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

    function! s:my_cr_function()
      if neosnippet#expandable_or_jumpable()
        return  "\<Plug>(neosnippet_expand_or_jump)"
      else
        return "\<C-y>" . deoplete#smart_close_popup()
      endif
    endfunction

    inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
  endif
end
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
  "       \ 'explorer_columns': 'gitstatus:devicons'
  "       \ })
  let g:vimfiler_enable_auto_cd = 1
  let g:vimfiler_ignore_pattern = '^\%(.git\|.DS_Store\)$'
  let g:vimfiler_trashbox_directory = '~/.Trash'
  " nnoremap <silent> <Leader>e :<C-u>VimFilerExplorer -split -winwidth=35 -simple<CR>
  " nnoremap <silent> <Leader>% :<C-u>VimFilerExplorer -find -split -winwidth=35 -simple<CR>

  function! s:vimfiler_settings()
    nmap <buffer> R <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <C-l> <C-w>l
    nmap <buffer> <C-j> <C-w>j
  endfunction

  AutoCmd FileType vimfiler call s:vimfiler_settings()
endif
" }}}3

" NerdTree {{{3
let g:NERDTreeLimitedSyntax = 1
let g:NERDTreeWinSize=35
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeSyntaxDisableDefaultExtensions = 1
let g:NERDTreeSyntaxEnabledExtensions =  ['js', 'vue', 'rb', 'erb', 'py', 'json', 'html', 'css', 'scss', 'vim', 'sh']

nnoremap <silent> <Leader>e :NERDTreeTabsToggle<CR>
nnoremap <silent> <Leader>% :NERDTreeFind<CR>

AutoCmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
AutoCmd VimLeave * NERDTreeClose
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
  imap <buffer><C-n> <Plug>(committia-scroll-diff-down-half)
  imap <buffer><C-p> <Plug>(committia-scroll-diff-up-half)
endfunction
" }}}3

" git-gutter {{{3
if dein#tap('vim-gitgutter')
  let g:gitgutter_map_keys = 0
  nmap <silent> gp <Plug>GitGutterPrevHunk
  nmap <silent> gn <Plug>GitGutterNextHunk
  nnoremap <silent> <Leader>gg :<C-u>GitGutterToggle<CR>
  nnoremap <silent> <Leader>gh :<C-u>GitGutterLineHighlightsToggle<CR>
endif
" }}}3

" gina {{{3
call gina#custom#command#option('br', '-v', 'v')
call gina#custom#command#option('br', '--all')
call gina#custom#command#option(
\ '/\%(status\|commit\)',
\ '-u|--untracked-files'
\ )
call gina#custom#command#option(
\ 'status',
\ '-b|--branch'
\)
call gina#custom#command#option(
\ 'status',
\ '-s|--short'
\ )
call gina#custom#command#option(
\ 'diff',
\ '--opener',
\ 'split'
\ )
call gina#custom#action#alias(
\ 'branch', 'merge',
\ 'commit:merge'
\)
call gina#custom#action#alias(
\ 'branch', 'rebase',
\ 'commit:rebase'
\ )
call gina#custom#action#alias(
\ '/\%(blame\|log\|reflog\)',
\ 'preview',
\ 'show:commit:preview',
\ )
call gina#custom#mapping#nmap(
\ '/\%(blame\|log\|reflog\)',
\ 'p',
\ ':<C-u>call gina#action#call(''preview'')<CR>',
\ {'noremap': 1, 'silent': 1}
\ )
call gina#custom#mapping#nmap(
\ 'blame', '<C-l>',
\ '<C-w>l'
\)
call gina#custom#mapping#nmap(
\ 'blame', '<C-r>',
\ '<Plug>(gina-blame-redraw)'
\)

" Echo chunk info with j/k
call gina#custom#mapping#nmap(
\ 'blame', 'j',
\ 'j<Plug>(gina-blame-echo)'
\)
call gina#custom#mapping#nmap(
\ 'blame', 'k',
\ 'k<Plug>(gina-blame-echo)'
\)
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{
nmap j <Plug>(accelerated_jk_j)
nmap k <Plug>(accelerated_jk_k)
" }}}

" anzu & asterisk {{{3
let g:anzu_status_format = '(%i/%l)'

map n  <Plug>(anzu-n)zzzv
map N  <Plug>(anzu-N)zzzv
map *  <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch <bar> AnzuClearSearchStatus<CR>
" }}}3

" Ag {{{3
let g:ag_qhandler = 'Unite quickfix -direction=botright -auto-resize -no-quit'
let g:ag_apply_qmappings = 0
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

map  S  <Plug>(easymotion-s2)
nmap S  <Plug>(easymotion-overwin-f2)
map  sj <Plug>(easymotion-j)
map  sk <Plug>(easymotion-k)
map  sl <Plug>(easymotion-bd-jk)
nmap sl <Plug>(easymotion-overwin-line)
omap f <Plug>(easymotion-fl)
omap t <Plug>(easymotion-tl)
omap F <Plug>(easymotion-Fl)
omap T <Plug>(easymotion-Tl)
" }}}3

" eregex {{{
let g:eregex_default_enable = 0

nnoremap <Leader>R "syiwq:%S/<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>
nnoremap <Leader>r q:%S//g<Left><Left>
vnoremap <Leader>r "syq:%S/<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>
" }}}

" edgemotion {{{3
map <M-j> <Plug>(edgemotion-j)
map <M-k> <Plug>(edgemotion-k)
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
    let l:rules += [
    \ {'char': '&',                        'input': '&& '},
    \ {'char': '&',     'at': '\S\%#',     'input': ' && '},
    \ {'char': '&',     'at': '\s\%#',     'input': '&& '},
    \ {'char': '&',     'at': '&&\s\%#',   'input': '<BS><BS>'},
    \ {'char': '&',     'at': '&\%#',      'input': '&', 'priority': 10},
    \ {'char': '<C-h>', 'at': '\s&&\s\%#', 'input': '<BS><BS><BS><BS>'},
    \ {'char': '<C-h>', 'at': '&&\s\%#',   'input': '<BS><BS><BS>'},
    \ {'char': '<C-h>', 'at': '&&\%#',     'input': '<BS><BS>'},
    \ ]

    "" Bar
    let l:rules += [
    \ {'char': '<Bar>',                    'input': '|| '},
    \ {'char': '<Bar>', 'at': '\S\%#',     'input': ' || '},
    \ {'char': '<Bar>', 'at': '\s\%#',     'input': '|| '},
    \ {'char': '<Bar>', 'at': '||\s\%#',   'input': '<BS><BS>'},
    \ {'char': '<Bar>', 'at': '|\%#',      'input': '<Bar>', 'priority': 10},
    \ {'char': '<C-h>', 'at': '\s||\s\%#', 'input': '<BS><BS><BS><BS>'},
    \ {'char': '<C-h>', 'at': '||\s\%#',   'input': '<BS><BS><BS>'},
    \ {'char': '<C-h>', 'at': '||\%#',     'input': '<BS><BS>'},
    \ ]

    "" Parenthesis
    let l:rules += [
    \ {'char': '(',     'at': '(\%#)', 'input': '<Del>'},
    \ {'char': '(',     'at': '(\%#',  'input': '('},
    \ {'char': '<C-h>', 'at': '(\%#)', 'input': '<BS><Del>'},
    \ ]

    "" Brace
    let l:rules += [
    \ {'char': '{',     'at': '{\%#}', 'input': '<Del>'},
    \ {'char': '{',     'at': '{\%#',  'input': '{'},
    \ {'char': '<C-h>', 'at': '{\%#}', 'input': '<BS><Del>'},
    \ ]

    "" Bracket
    let l:rules += [
    \ {'char': '[',     'at': '\[\%#\]', 'input': '<Del>'},
    \ {'char': '[',     'at': '\[\%#',   'input': '['},
    \ {'char': '<C-h>', 'at': '\[\%#\]', 'input': '<BS><Del>'},
    \ ]

    "" Sinble Quote
    let l:rules += [
    \ {'char': "'",     'at': "'\\%#'", 'input': '<Del>'},
    \ {'char': "'",     'at': "'\\%#",  'input': "'"},
    \ {'char': "'",     'at': "''\\%#", 'input': "'"},
    \ {'char': '<C-h>', 'at': "'\\%#'", 'input': '<Del>'},
    \ ]

    "" Double Quote
    let l:rules += [
    \ {'char': '"',     'at': '"\%#"', 'input': '<Del>'},
    \ {'char': '"',     'at': '"\%#',  'input': '"'},
    \ {'char': '"',     'at': '""\%#', 'input': '"'},
    \ {'char': '<C-h>', 'at': '"\%#"', 'input': '<Del>'},
    \ ]

    "" vim
    let l:rules += [
    \ {'char': '{', 'at': '{\%#$', 'input': '{{<CR>', 'input_after': '<CR>" }}}', 'filetype': 'vim', 'priority': 10},
    \ ]

    "" ruby
    let l:rules += [
    \ {'char': '<bar>', 'at': 'do\%#',     'input': '<Space><bar><bar><Left>', 'input_after': '<CR>end', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<bar>', 'at': 'do\s\%#',   'input': '<bar><bar><Left>', 'input_after': '<CR>end', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<bar>', 'at': '{\%#}',     'input': '<Space><bar><bar><Left>', 'input_after': '<Space>', 'filetype': ['ruby', 'eruby']},
    \ {'char': '<bar>', 'at': '{\s\%#\s}', 'input': '<bar><bar><Left>', 'input_after': '<Space>', 'filetype': ['ruby', 'eruby']},
    \ ]

    for l:rule in l:rules
      call lexima#add_rule(l:rule)
    endfor
  endfunction
endif
" }}}3

" operator-replace {{{3
map _ <Plug>(operator-replace)
" }}}3

" qfreplace {{{3
AutoCmd FileType qf nnoremap <buffer> r :<C-u>Qfreplace<CR>
" }}}3

" sandwich {{{3
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
let g:sandwich#recipes += [
\   { 'buns': ['\/', '\/'] },
\   { 'buns': ['_', '_'] },
\ ]
" }}}3

" tcomment {{{3
noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" trip {{{
if dein#tap('trip.vim')
  nmap <C-a> <Plug>(trip-increment)
  nmap <C-x> <Plug>(trip-decrement)
endif
" }}}

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history = 1000
  let g:yankround_use_region_hl = 1

  AutoCmd ColorScheme * highlight YankRoundRegion ctermfg=209 ctermbg=237
  AutoCmd ColorScheme * highlight YankRoundRegion ctermfg=209 ctermbg=237

  nmap p  <Plug>(yankround-p)
  nmap P  <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : 'q:Denite file_rec -direction=topleft -mode=insert<CR>'
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : ''
  cmap <C-y> <Plug>(yankround-insert-register)
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
let g:better_whitespace_filetypes_blacklist = ['tag', 'help', 'vimfiler', 'unite', 'denite']
" }}}3

" brightest {{{
let g:brightest#highlight = {
\ 'group': 'BrightestUnderline'
\ }

let g:brightest#enable_filetypes = {
\ 'ruby' : 0
\ }
" }}}

" devicons {{{3
let g:webdevicons_enable = 1
let g:webdevicons_enable_unite = 0
let g:webdevicons_enable_denite = 0
let g:webdevicons_enable_vimfiler = 0
let g:WebDevIconsUnicodeDecorateFileNodes = 1
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
  \   'left': [ [ 'mode', 'denite', 'paste' ], [ 'branch' ], [ 'readonly', 'filepath', 'filename', 'anzu' ] ],
  \   'right': [
  \     [ 'lineinfo', 'percent' ],
  \     [ 'fileformat', 'fileencoding', 'filetype' ],
  \     [ 'linter_errors', 'linter_warnings', 'linter_ok', 'linter_disable' ]
  \   ]
  \ },
  \ 'inactive': {
  \   'left': [ [], [ 'branch' ], [ 'filepath', 'filename' ] ],
  \   'right': [
  \     [ 'lineinfo' ],
  \     [ 'fileformat', 'fileencoding', 'filetype' ]
  \   ]
  \ },
  \ 'tabline': {
  \   'left': [ [ 'tabs' ] ],
  \   'right': []
  \ },
  \ 'tab': {
  \   'active': [ 'tabnum', 'readonly', 'filename', 'modified' ],
  \   'inactive': [ 'tabnum', 'readonly', 'filename', 'modified' ]
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
  \ 'tab_component_function': {
  \   'readonly': 'LightlineTabReadonly',
  \ },
  \ 'component_function_visible_condition': {
  \   'modified': '&modified||!&modifiable',
  \   'readonly': '&readonly',
  \   'paste': '&paste',
  \ },
  \ 'component_type': {
  \   'linter_disable':  'ok',
  \   'linter_errors':   'error',
  \   'linter_warnings': 'warning',
  \   'linter_ok':       'ok',
  \ },
  \ 'component_expand': {
  \   'linter_disable':  'LightlineAleDisable',
  \   'linter_errors':   'lightline#ale#errors',
  \   'linter_warnings': 'lightline#ale#warnings',
  \   'linter_ok':       'LightlineAleOk',
  \ },
  \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2 " },
  \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3 " },
  \ 'enable': {
  \   'statusline': 1,
  \   'tabline': 1,
  \ }
  \ }

  let g:lightline#ale#indicator_errors   = "\uf421"
  let g:lightline#ale#indicator_warnings = "\uf420"
  let g:lightline#ale#indicator_ok       = "\uf4a1"

  function! LightlineReadonly()
    return &readonly ? "\ue0a2" : ''
  endfunction

  function! LightlineBranch()
    let l:branch = gina#component#repo#branch()
    return l:branch !=# "\ue0a0" ? "\ue0a0 " . l:branch : ''
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
      if dein#tap('vim-devicons')
        return &fileformat . ' ' . WebDevIconsGetFileFormatSymbol()
      else
        return &fileformat
      endif
    endif
  endfunction

  function! LightlineFiletype()
    if strlen(&filetype)
      if dein#tap('vim-devicons')
        return &filetype . ' ' . WebDevIconsGetFileTypeSymbol()
      else
        return &filetype
      endif
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

  function! LightlineDenite() abort
    return (&filetype !=# 'denite') ? '' : (substitute(denite#get_status_mode(), '[- ]', '', 'g'))
  endfunction

  function! LightlineTabReadonly(n) abort
    let l:winnr = tabpagewinnr(a:n)
    return gettabwinvar(a:n, l:winnr, '&readonly') ? "\ue0a2 " : ''
  endfunction

  function! LightlineAleOk() abort
    if count(s:ale_filetypes, &filetype) != 0
      return lightline#ale#ok()
    else
      return ''
    endif
  endfunction

  function! LightlineAleDisable() abort
    if count(s:ale_filetypes, &filetype) == 0
      return "\uf05e"
    else
      return ''
    endif
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
\ ['Calendar',          'Calendar'],
\ ]

" }}}3

" rainbow {{{3
let g:rainbow_active = 1
let g:rainbow_conf = {
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

" altercmd {{{
call altercmd#load()

AlterCommand! <cmdwin> w!!       w<Space>suda://%
AlterCommand! <cmdwin> dein      Dein
AlterCommand! <cmdwin> d[enite]  Denite
AlterCommand! <cmdwin> u[nite]   Unite
AlterCommand! <cmdwin> deol      Deol
AlterCommand! <cmdwin> ag        Ag!
AlterCommand! <cmdwin> git       Gina
AlterCommand! <cmdwin> gina      Gina
AlterCommand! <cmdwin> gs        Gina<Space>status
AlterCommand! <cmdwin> gci       Gina<Space>commit
AlterCommand! <cmdwin> gd        Gina<Space>diff
AlterCommand! <cmdwin> gdc       Gina<Space>diff<Space>--cached
AlterCommand! <cmdwin> blame     Gina<Space>blame
AlterCommand! <cmdwin> agit      Agit
AlterCommand! <cmdwin> root      Rooter
AlterCommand! <cmdwin> sw[tch]   Switch
AlterCommand! <cmdwin> alc       Ref<Space>webdict<Space>alc
AlterCommand! <cmdwin> tag       TagbarOpen<Space>j
AlterCommand! <cmdwin> nr        NR
AlterCommand! <cmdwin> scr[atch] Scratch
AlterCommand! <cmdwin> cap[ture] Capture
AlterCommand! <cmdwin> ss        SessionSave!
AlterCommand! <cmdwin> so        SessionOpen
AlterCommand! <cmdwin> sr        SessionRemove
AlterCommand! <cmdwin> sl        SessionList
AlterCommand! <cmdwin> sc        SessionClose
" }}}

" automatic {{{
function! s:my_temp_win_init(config, context)
  nnoremap <buffer> q :<C-u>q<CR>
endfunction

let g:automatic_default_set_config = {
\   'apply':  function('s:my_temp_win_init'),
\ }

let g:automatic_config = [
\   {
\     'match': { 'filetype': 'help' },
\   },
\   {
\     'match': { 'filetype': 'diff' },
\     'set': {
\       'move': 'topleft',
\       'height': '30%'
\     }
\   },
\   {
\     'match': { 'filetype': 'git' },
\   },
\   {
\     'match': { 'filetype': 'gina-status' },
\     'set': {
\       'move': 'topleft',
\       'height': '20%'
\     }
\   },
\   {
\     'match': { 'filetype': 'gina-branch' },
\   },
\   {
\     'match': { 'filetype': 'gina-log' },
\   },
\   {
\     'match' : {
\       'autocmds' : [ 'CmdwinEnter' ]
\     },
\     'set' : {
\       'is_close_focus_out' : 1,
\       'unsettings' : [ 'move', 'resize' ]
\     },
\   },
\ ]
" }}}

" bufkill {{{3
AutoCmd FileType *    nnoremap <silent> <Leader>d :BD<CR>
AutoCmd FileType help nnoremap <silent> <Leader>d :BW<CR>
AutoCmd FileType diff nnoremap <silent> <Leader>d :BW<CR>
AutoCmd FileType git  nnoremap <silent> <Leader>d :BW<CR>
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

" neoterm {{{3
let g:neoterm_position = 'vertical'
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

" submode & operator-convert-case {{{3
let g:submode_keep_leaving_key = 1

"" edit
call submode#enter_with('jump', 'n', '', 'g;', 'g;')
call submode#map('jump', 'n', '', ';', 'g;')

"" buffer
call submode#enter_with('changebuffer', 'n', '', 'g<C-p>', ':bprevious<CR>')
call submode#enter_with('changebuffer', 'n', '', 'g<C-n>', ':bnext<CR>')
call submode#map('changebuffer', 'n', '', '<C-n>', ':bprevious<CR>')
call submode#map('changebuffer', 'n', '', '<C-p>', ':bnext<CR>')

"" tab
call submode#enter_with('changetab', 'n', '', 'gh', 'gT')
call submode#enter_with('changetab', 'n', '', 'gl', 'gt')
call submode#map('changetab', 'n', '', 'h', 'gT')
call submode#map('changetab', 'n', '', 'l', 'gt')

"" operator-convert-case
call submode#enter_with('convert', 'n', '', '<leader>cl', ':ConvertCaseLoop<CR>')
call submode#map('convert', 'n', '', 'c', ':ConvertCaseLoop<CR>')
" }}}3

" tagbar {{{3
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
nnoremap <silent> <C-e> :WinResizerStartResize<CR>
" }}}3

" }}}2

" }}}1

" Load Colorscheme Later {{{1
syntax enable

" elflord {{{2
" silent! colorscheme elflord
" }}}2

" hybrid {{{2
" set background=dark
" let g:hybrid_custom_term_colors = 1
" let g:hybrid_reduced_contrast = 1
" silent! colorscheme hybrid
" }}}2

" iceberg {{{2
silent! colorscheme iceberg
highlight Search       ctermfg=none ctermbg=237
highlight LineNr       ctermfg=241
highlight CursorLineNr ctermbg=237 ctermfg=253
highlight CursorLine   ctermbg=235
highlight PmenuSel     cterm=reverse ctermfg=33 ctermbg=222
highlight Visual       ctermfg=159 ctermbg=23
" }}}2

" jellybeans {{{2
" silent! colorscheme jellybeans
" }}}2

" molokai {{{2
" silent! colorscheme molokai
" highlight Search   ctermfg=none ctermbg=237
" highlight Visual   ctermfg=159 ctermbg=23
" highlight Normal ctermbg=none
" }}}2

" solarized {{{2
" set background=dark
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
" colorscheme solarized
" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
