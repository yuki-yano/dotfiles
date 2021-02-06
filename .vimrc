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
let g:dein#install_max_processes    = 20
let g:dein#install_process_timeout  = 300
let g:dein#install_github_api_token = $DEIN_GITHUB_TOKEN
" }}}2

" Load Plugin {{{2
if dein#load_state(s:DEIN_BASE_PATH)
  call dein#begin(s:DEIN_BASE_PATH)

  " Dein {{{3
  call dein#add('Shougo/dein.vim',             {'merged': 0})
  call dein#add('haya14busa/dein-command.vim', {'merged': 0})
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja', {'merged': 0})
  " }}}3

  " IDE {{{3
  call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'master', 'build': 'yarn install --frozen-lockfile'})
  " call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})

  " call dein#add('tsuyoshicho/vim-efm-langserver-settings', {'merged': 0})

  " call dein#add('prabirshrestha/vim-lsp',              {'merged': 0})
  " call dein#add('mattn/vim-lsp-settings',              {'merged': 0})
  " call dein#add('prabirshrestha/asyncomplete.vim',     {'merged': 0})
  " call dein#add('prabirshrestha/asyncomplete-lsp.vim', {'merged': 0})
  " call dein#add('kitagry/asyncomplete-tabnine.vim',    {'merged': 0, 'build': './install.sh'  })
  " call dein#add('Shougo/deoplete.nvim',                {'merged': 0})
  " call dein#add('lighttiger2505/deoplete-vim-lsp',     {'merged': 0})
  " call dein#add('tbodt/deoplete-tabnine',              {'merged': 0, 'build': 'bash install.sh'})
  " call dein#add('hrsh7th/vim-vsnip',                   {'merged': 0})
  " call dein#add('hrsh7th/vim-vsnip-integ',             {'merged': 0})
  " }}}3

  " Language {{{3
  " call dein#add('HerringtonDarkholme/yats.vim',            {'merged': 0})
  " call dein#add('hail2u/vim-css3-syntax',                  {'merged': 0})
  " call dein#add('mechatroner/rainbow_csv',                 {'merged': 0})
  " call dein#add('othree/yajs.vim',                         {'merged': 0})
  " call dein#add('peitalin/vim-jsx-typescript',             {'merged': 0})
  " call dein#add('posva/vim-vue',                           {'merged': 0})
  " call dein#add('styled-components/vim-styled-components', {'merged': 0})
  " call dein#add('tpope/vim-rails',                         {'merged': 0})
  " call dein#add('yardnsm/vim-import-cost',                 {'merged': 0, 'build': 'npm install'})
  call dein#add('elzr/vim-json',                {'merged': 0})
  call dein#add('heavenshell/vim-jsdoc',        {'merged': 0, 'build': 'make install'})
  call dein#add('jparise/vim-graphql',          {'merged': 0})
  call dein#add('leafgarland/typescript-vim',   {'merged': 0})
  call dein#add('plasticboy/vim-markdown',      {'merged': 0})
  call dein#add('rhysd/vim-fixjson',            {'merged': 0})
  call dein#add('rust-lang/rust.vim',           {'merged': 0})

  if has('nvim')
    call dein#add('nvim-treesitter/nvim-treesitter',          {'merged': 0})
    " call dein#add('p00f/nvim-ts-rainbow',                     {'merged': 0})
    " call dein#add('nvim-treesitter/nvim-treesitter-refactor', {'merged': 0})
    " call dein#add('romgrk/nvim-treesitter-context',           {'merged': 0})
  endif
  " }}}3

  " Git {{{3
  call dein#add('hotwatermorning/auto-git-diff', {'merged': 0})
  call dein#add('lambdalisue/gina.vim',          {'merged': 0})
  call dein#add('rhysd/committia.vim',           {'merged': 0})
  call dein#add('rhysd/conflict-marker.vim',     {'merged': 0})
  call dein#add('tpope/vim-fugitive',            {'merged': 0})
  call dein#add('wting/gitsessions.vim',         {'merged': 0})

  if has('nvim')
    " call dein#add('APZelos/blamer.nvim',     {'merged': 0})
    " call dein#add('f-person/git-blame.nvim', {'merged': 0})
    call dein#add('rhysd/git-messenger.vim', {'merged': 0})
  endif
  " }}}3

  " Fuzzy Finder {{{3
  call dein#add('Shougo/denite.nvim', {'merged': 0})

  call dein#add('junegunn/fzf',         {'merged': 0, 'build': './install --bin'})
  call dein#add('junegunn/fzf.vim',     {'merged': 0})
  call dein#add('antoinemadec/coc-fzf', {'merged': 0, 'rev': 'release'})

  if isdirectory(expand('~/repos/github.com/yuki-ycino/fzf-preview.vim'))
    call dein#add('~/repos/github.com/yuki-ycino/fzf-preview.vim', {'merged': 0})
  endif

  " call dein#add('yuki-ycino/fzf-preview.vim', {'merged': 0, 'rev': 'release/rpc'})

  if has('nvim')
    call dein#add('nvim-lua/popup.nvim',          {'merged': 0})
    call dein#add('nvim-lua/plenary.nvim',        {'merged': 0})
    call dein#add('nvim-lua/telescope.nvim',      {'merged': 0})
    call dein#add('kyazdani42/nvim-web-devicons', {'merged': 0})
  endif
  " }}}3

  " filer {{{3
  call dein#add('lambdalisue/fern.vim',                   {'merged': 0})
  call dein#add('lambdalisue/fern-git-status.vim',        {'merged': 0})
  call dein#add('lambdalisue/fern-renderer-nerdfont.vim', {'merged': 0})
  call dein#add('lambdalisue/glyph-palette.vim',          {'merged': 0})
  call dein#add('lambdalisue/nerdfont.vim',               {'merged': 0})

  if has('nvim')
    call dein#add('Shougo/defx.nvim',          {'merged': 0})
    call dein#add('kristijanhusak/defx-icons', {'merged': 0})
    call dein#add('kristijanhusak/defx-git',   {'merged': 0})
  endif
  " }}}3

  " textobj & operator {{{3
  call dein#add('machakann/vim-sandwich', {'merged': 0})
  call dein#add('machakann/vim-swap',     {'merged': 0}) " g< g> i, a,

  call dein#add('kana/vim-textobj-user',  {'merged': 0})
  call dein#add('kana/vim-operator-user', {'merged': 0})

  " call dein#add('rhysd/vim-textobj-ruby',             {'merged': 0}) " ir ar
  " call dein#add('thinca/vim-textobj-between',         {'merged': 0}) " i{char} a{char}
  call dein#add('kana/vim-textobj-entire',            {'merged': 0}) " ie ae
  call dein#add('kana/vim-textobj-fold',              {'merged': 0}) " iz az
  call dein#add('kana/vim-textobj-indent',            {'merged': 0}) " ii ai
  call dein#add('kana/vim-textobj-line',              {'merged': 0}) " al il
  call dein#add('machakann/vim-textobj-functioncall', {'merged': 0}) " if af
  call dein#add('mattn/vim-textobj-url',              {'merged': 0}) " iu au
  call dein#add('romgrk/equal.operator',              {'merged': 0}) " i=h a=h i=l a=l

  call dein#add('mopp/vim-operator-convert-case',  {'merged': 0}) " cy
  call dein#add('yuki-ycino/vim-operator-replace', {'merged': 0}) " _
  " }}}3

  " Edit & Move & Search {{{3
  " call dein#add('AndrewRadev/splitjoin.vim',     {'merged': 0})
  " call dein#add('AndrewRadev/tagalong.vim',      {'merged': 0})
  " call dein#add('deris/vim-shot-f',              {'merged': 0})
  " call dein#add('haya14busa/incsearch.vim',      {'merged': 0})
  " call dein#add('haya14busa/is.vim',             {'merged': 0})
  " call dein#add('haya14busa/vim-metarepeat',     {'merged': 0})
  " call dein#add('inkarkat/vim-EnhancedJumps',    {'merged': 0})
  " call dein#add('lambdalisue/reword.vim',        {'merged': 0})
  " call dein#add('mg979/vim-visual-multi',        {'merged': 0, 'rev': 'test'})
  " call dein#add('mtth/scratch.vim',              {'merged': 0})
  " call dein#add('rhysd/accelerated-jk',          {'merged': 0})
  " call dein#add('t9md/vim-choosewin',            {'merged': 0})
  " call dein#add('tomtom/tcomment_vim',           {'merged': 0})
  " call dein#add('unblevable/quick-scope',        {'merged': 0})
  " call dein#add('vim-scripts/Align',             {'merged': 0})
  call dein#add('Bakudankun/BackAndForward.vim', {'merged': 0})
  call dein#add('LeafCage/yankround.vim',        {'merged': 0})
  call dein#add('MattesGroeger/vim-bookmarks',   {'merged': 0})
  call dein#add('cohama/lexima.vim',             {'merged': 0})
  call dein#add('easymotion/vim-easymotion',     {'merged': 0})
  call dein#add('haya14busa/vim-asterisk',       {'merged': 0})
  call dein#add('haya14busa/vim-edgemotion',     {'merged': 0})
  call dein#add('hrsh7th/vim-eft',               {'merged': 0})
  call dein#add('junegunn/vim-easy-align',       {'merged': 0})
  call dein#add('mhinz/vim-grepper',             {'merged': 0})
  call dein#add('osyo-manga/vim-jplus',          {'merged': 0})
  call dein#add('osyo-manga/vim-trip',           {'merged': 0})
  call dein#add('terryma/vim-expand-region',     {'merged': 0})
  call dein#add('thinca/vim-qfreplace',          {'merged': 0})
  call dein#add('tommcdo/vim-exchange',          {'merged': 0})
  call dein#add('tpope/vim-repeat',              {'merged': 0})
  call dein#add('tyru/caw.vim',                  {'merged': 0})

  if has('nvim')
    call dein#add('gabrielpoca/replacer.nvim', {'merged': 0})
    call dein#add('kevinhwang91/nvim-hlslens', {'merged': 0})
    call dein#add('monaqa/dial.nvim',          {'merged': 0})
  endif
  " }}}3

  " Appearance {{{3
  " call dein#add('RRethy/vim-hexokinase',          {'merged': 0, 'build': 'make hexokinase'})
  " call dein#add('andymass/vim-matchup',           {'merged': 0})
  " call dein#add('mhinz/vim-startify',             {'merged': 0})
  " call dein#add('wellle/context.vim',             {'merged': 0})
  " call dein#add('yuttie/comfortable-motion.vim',  {'merged': 0})
  call dein#add('Yggdroot/indentLine',            {'merged': 0})
  call dein#add('itchyny/lightline.vim',          {'merged': 0})
  call dein#add('lambdalisue/readablefold.vim',   {'merged': 0})
  call dein#add('luochen1990/rainbow',            {'merged': 0})
  call dein#add('machakann/vim-highlightedundo',  {'merged': 0})
  call dein#add('machakann/vim-highlightedyank',  {'merged': 0})
  call dein#add('mopp/smartnumber.vim',           {'merged': 0})
  call dein#add('ntpeters/vim-better-whitespace', {'merged': 0})
  call dein#add('ronakg/quickr-preview.vim',      {'merged': 0})
  call dein#add('ryanoasis/vim-devicons',         {'merged': 0})

  if has('nvim')
    " call dein#add('glepnir/indent-guides.nvim',  {'merged': 0})
    " call dein#add('Xuyuanp/scrollbar.nvim',      {'merged': 0})
    call dein#add('dstein64/nvim-scrollview',    {'merged': 0})
    call dein#add('norcalli/nvim-colorizer.lua', {'merged': 0})
  endif
  " }}}3

  " tmux {{{3
  call dein#add('christoomey/vim-tmux-navigator', {'merged': 0})
  " }}}3

  " Util {{{3
  " call dein#add('dhruvasagar/vim-table-mode',       {'merged': 0})
  " call dein#add('dstein64/vim-startuptime',         {'merged': 0})
  " call dein#add('jsfaint/gen_tags.vim',             {'merged': 0})
  " call dein#add('kristijanhusak/vim-carbon-now-sh', {'merged': 0})
  " call dein#add('osyo-manga/vim-brightest',         {'merged': 0})
  " call dein#add('osyo-manga/vim-gift',              {'merged': 0})
  " call dein#add('pocke/vim-automatic',              {'merged': 0})
  " call dein#add('thinca/vim-localrc',               {'merged': 0})
  " call dein#add('thinca/vim-ref',                   {'merged': 0})
  call dein#add('AndrewRadev/linediff.vim',         {'merged': 0})
  call dein#add('aiya000/aho-bakaup.vim',           {'merged': 0})
  call dein#add('antoinemadec/FixCursorHold.nvim',  {'merged': 0})
  call dein#add('itchyny/vim-qfedit',               {'merged': 0})
  call dein#add('kana/vim-niceblock',               {'merged': 0})
  call dein#add('lambdalisue/suda.vim',             {'merged': 0})
  call dein#add('lambdalisue/vim-manpager',         {'merged': 0})
  call dein#add('lambdalisue/vim-pager',            {'merged': 0})
  call dein#add('liuchengxu/vim-which-key',         {'merged': 0})
  call dein#add('liuchengxu/vista.vim',             {'merged': 0})
  call dein#add('mbbill/undotree',                  {'merged': 0})
  call dein#add('moll/vim-bbye',                    {'merged': 0})
  call dein#add('previm/previm',                    {'merged': 0})
  call dein#add('segeljakt/vim-silicon',            {'merged': 0})
  call dein#add('tyru/capture.vim',                 {'merged': 0})
  call dein#add('tyru/open-browser.vim',            {'merged': 0})
  call dein#add('tyru/vim-altercmd',                {'merged': 0})
  call dein#add('voldikss/vim-floaterm',            {'merged': 0})
  call dein#add('wesQ3/vim-windowswap',             {'merged': 0})

  if $ENABLE_WAKATIME == 1
    call dein#add('wakatime/vim-wakatime', {'merged': 0})
  endif
  " }}}3

  " Develop {{{3
  call dein#add('hrsh7th/vim-vital-vs',                {'merged': 0})
  call dein#add('lambdalisue/vim-quickrun-neovim-job', {'merged': 0})
  call dein#add('rbtnn/vim-vimscript_lasterror',       {'merged': 0})
  call dein#add('thinca/vim-prettyprint',              {'merged': 0})
  call dein#add('thinca/vim-quickrun',                 {'merged': 0})
  call dein#add('vim-jp/vital.vim',                    {'merged': 0})
  " }}}3

  " Color Theme {{{3
  call dein#add('NLKNguyen/papercolor-theme',   {'merged': 0})
  call dein#add('arcticicestudio/nord-vim',     {'merged': 0})
  call dein#add('cocopon/iceberg.vim',          {'merged': 0})
  call dein#add('high-moctane/gaming.vim',      {'merged': 0})
  call dein#add('icymind/NeoSolarized',         {'merged': 0})
  call dein#add('joshdick/onedark.vim',         {'merged': 0})
  call dein#add('sainnhe/edge',                 {'merged': 0})
  call dein#add('sainnhe/gruvbox-material',     {'merged': 0})
  call dein#add('taohexxx/lightline-solarized', {'merged': 0})
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
augroup vimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd vimrc <args>
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
noremap <Leader> <Nop>
noremap <dev>    <Nop>
map     m        <dev>

"" Move beginning toggle
noremap <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'

"" Move beginning and ending
noremap <silent> <expr> <Leader>h getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'
noremap                 <Leader>l $

"" BackSpace
imap <C-h> <BS>
cmap <C-h> <BS>

"" Buffer
nnoremap <C-q> <C-^>

"" Yank
nnoremap Y y$

"" Disable s
noremap s <Nop>

"" Save
nnoremap <silent> <Leader>w :<C-u>update<CR>
nnoremap <silent> <Leader>W :<C-u>update!<CR>

"" Automatically indent with i and A
nnoremap <expr> i len(getline('.')) ? "i" : "\"_cc"
nnoremap <expr> A len(getline('.')) ? "A" : "\"_cc"

" Ignore registers
nnoremap x "_x

"" incsearch
" nnoremap / /\v
" nnoremap ? ?\v
cnoremap <expr> / empty(getcmdline()) <Bar><Bar> getcmdline() ==# '\v' ? '<C-u>\<' : getcmdline() ==# '\<' ? '\><Left><Left>' : '/'
cnoremap <expr> ? empty(getcmdline()) <Bar><Bar> getcmdline() ==# '\v' ? '<C-u>\<' : getcmdline() ==# '\<' ? '\><Left><Left>' : '?'

nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>

"" tagjump
nnoremap <silent> s<C-]> :<C-u>wincmd ]<CR>
nnoremap <silent> v<C-]> :<C-u>vertical wincmd ]<CR>
nnoremap <silent> t<C-]> :<C-u>tab wincmd ]<CR>
nnoremap <silent> r<C-]> <C-w>}

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

"" Window
if has('nvim')
  function! s:focus_floating() abort
    if !empty(nvim_win_get_config(win_getid()).relative)
      wincmd p
      return
    endif
    for winnr in range(1, winnr('$'))
      let l:winid = win_getid(winnr)
      let l:conf = nvim_win_get_config(winid)
      if l:conf.focusable && !empty(l:conf.relative)
        call win_gotoid(l:winid)
        return
      endif
    endfor
    execute "normal! \<C-w>\<C-w>"
  endfunction
  nnoremap <silent> <C-w><C-w> :<C-u>call <SID>focus_floating()<CR>
endif

"" Tab
nnoremap <t> <Nop>
nmap     t     <t>
nnoremap <silent> <t>t :<C-u>tablast <Bar> tabedit<CR>
nnoremap <silent> <t>d :<C-u>tabclose<CR>
nnoremap <silent> <t>h :<C-u>tabprevious<CR>
nnoremap <silent> <t>l :<C-u>tabnext<CR>
nnoremap <silent> <t>m <C-w>T

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
  let g:loaded_python_provider = 0
  let g:loaded_perl_provider   = 0
  let g:loaded_ruby_provider   = 0
  let g:python3_host_prog      = $HOME . '/.pyenv/shims/python'

  set inccommand=nosplit

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
" set list listchars=tab:^\ ,trail:_,extends:>,precedes:<,eol:$
set list listchars=tab:^\ ,trail:_,extends:>,precedes:<
set matchpairs+=<:>
set matchtime=1
set number
set pumheight=40
set scrolloff=5
set showtabline=2
set spellcapcheck=
set spelllang=en,cjk
set synmaxcol=300
set termguicolors
set virtualedit=all
set guifont=SF\ Mono\ Square:h18

"" Indent
set autoindent
set backspace=indent,eol,start
set breakindent
set expandtab
set nostartofline
set shiftwidth=2
set smartindent
set tabstop=2

set formatoptions-=ro
set formatoptions+=jBn

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
AutoCmd FocusGained * checktime

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
AutoCmd WinEnter,BufRead,BufNew,Syntax * silent! call matchadd('Todo', '\(TODO\|FIXME\|REVIEW\|NOTE\|INFO\|REF\):')

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

" AutoCmd VimEnter * call timer_start(s:highlight_cursor_wait, function('s:enter'))

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
    call mkdir(a:dir, 'p')
  endif
endfunction
" }}}2

" SyntaxHighlightToggle {{{2
function! s:syntax_highlight_toggle()
  if exists('g:syntax_on')
    syntax off
  else
    syntax enable
  endif
endfunction

command! SyntaxHighlightToggle call <SID>syntax_highlight_toggle()
" }}}2

" QuickfixToggle {{{2
function! s:quickfix_toggle()
  let l:_ = winnr('$')
  cclose
  if l:_ == winnr('$')
    botright copen
    " call g:Set_quickfix_keymap()
  endif
endfunction

command! QuickfixToggle call <SID>quickfix_toggle()
nnoremap <silent> <Leader>q :<C-u>QuickfixToggle<CR>
" }}}2

" ToggleLocationList {{{2
function! s:location_list_toggle()
  let l:_ = winnr('$')
  lclose
  if l:_ == winnr('$')
    botright lopen
    " call g:Set_locationlist_keymap()
  endif
endfunction

command! LocationListToggle call <SID>location_list_toggle()
nnoremap <silent> <Leader><Leader>q :<C-u>LocationListToggle<CR>
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

" Review {{{2
let g:review_status = v:false

function! s:review_start() abort
  let g:review_status = v:true

  colorscheme edge
  set background=light
  let g:lightline.colorscheme = 'edge'
  call lightline#disable()
  call lightline#enable()

  let g:fzf_preview_command_bak = g:fzf_preview_command
  let g:fzf_preview_command = 'bat --color=always --style=plain --theme="papercolor-light" ''{-1}'''

  let $FZF_PREVIEW_PREVIEW_BAT_THEME_BAK = $FZF_PREVIEW_PREVIEW_BAT_THEME
  let $FZF_PREVIEW_PREVIEW_BAT_THEME = 'papercolor-light'
  let $FZF_DEFAULT_OPTS_BAK = $FZF_DEFAULT_OPTS
  " Edge
  let $FZF_DEFAULT_OPTS= '--color=fg:#4b505b,bg:#fafafa,hl:#5079be,fg+:#4b505b,bg+:#fafafa,hl+:#3a8b84,info:#88909f,prompt:#d05858,pointer:#b05ccc,marker:#608e32,spinner:#d05858,header:#3a8b84'
  " PaperColor
  " let $FZF_DEFAULT_OPTS= '--color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f,fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f,info:#4271ae,prompt:#8959a8,pointer:#d7005f,marker:#4271ae,spinner:#4271ae,header:#4271ae'
  " Solarized
  " let $FZF_DEFAULT_OPTS = '--color=fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33,info:33,prompt:33,pointer:166,marker:166,spinner:33'
  let $BAT_THEME_BAK = $BAT_THEME
  let $BAT_THEME = 'papercolor-light'

  SNumbersTurnOffRelative

  " let g:comfortable_motion_enable = 0
  " ComfortableMotionToggle

  set list listchars=tab:^\ ,trail:_,extends:>,precedes:<
endfunction

command! ReviewStart call s:review_start()

function! s:review_end() abort
  let g:review_status = v:false

  colorscheme gruvbox-material
  set background=dark
  let g:lightline.colorscheme = 'gruvbox'
  call lightline#disable()
  call lightline#enable()

  let g:fzf_preview_command = g:fzf_preview_command_bak
  let $FZF_PREVIEW_PREVIEW_BAT_THEME = $FZF_PREVIEW_PREVIEW_BAT_THEME_BAK
  let $FZF_DEFAULT_OPTS = $FZF_DEFAULT_OPTS_BAK
  let $BAT_THEME = $BAT_THEME_BAK

  SNumbersTurnOnRelative

  " let g:comfortable_motion_enable = 1
  " ComfortableMotionToggle

  set list listchars=tab:^\ ,trail:_,extends:>,precedes:<,eol:$
endfunction

command! ReviewEnd call <SID>review_end()

function! s:review_toggle() abort
  if g:review_status
    ReviewEnd
  else
    ReviewStart
  endif
endfunction

command! ReviewToggle call <SID>review_toggle()
" }}}2

" }}}1

" FileType Settings {{{1

" FileType {{{2

" Set filetype {{{3
AutoCmd BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx
" }}}3

" Indent {{{3
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

" }}}2

" Vim script {{{2
let g:vimsyn_embed = 'l'
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

" Set quit {{{2
AutoCmd FileType help nnoremap <silent> <nowait> <buffer> q :<C-u>quit<CR>
AutoCmd FileType diff nnoremap <silent> <nowait> <buffer> q :<C-u>quit<CR>
AutoCmd FileType man  nnoremap <silent> <nowait> <buffer> q :<C-u>quit<CR>
AutoCmd FileType git  nnoremap <silent> <nowait> <buffer> q :<C-u>quit<CR>
" }}}2

" }}}1

" Command Line Window {{{1
set cedit=\<C-c>

" nnoremap : q:
" xnoremap : q:
" nnoremap q: :
" xnoremap q: :

AutoCmd CmdwinEnter * call <SID>init_cmdwin()
AutoCmd CmdwinLeave * call <SID>deinit_cmdwin()

function! s:init_cmdwin() abort
  setlocal number | setlocal norelativenumber
  nnoremap <buffer> <CR> <CR>
  nnoremap <buffer> <silent> <nowait> q :<C-u>quit<CR>
  inoremap <buffer> <C-c> <Esc>l<C-c>

  if dein#tap('coc.nvim')
    call coc#config('suggest.floatEnable', v:false)
    call coc#config('diagnostic.messageTarget', 'echo')
    call coc#config('signature.target', 'echo')
    call coc#config('coc.preferences.hoverTarget', 'echo')
  endif

  " nnoremap <silent> <buffer> dd :<C-u>rviminfo<CR>:call histdel(getcmdwintype(), line('.') - line('$'))<CR>:wviminfo!<CR>dd
  startinsert!
endfunction

function! s:deinit_cmdwin() abort
  if dein#tap('coc.nvim')
    call coc#config('suggest.floatEnable', v:true)
    call coc#config('diagnostic.messageTarget', 'float')
    call coc#config('signature.target', 'float')
    call coc#config('coc.preferences.hoverTarget', 'float')
  endif
endfunction
" }}}1

" Plugin Settings {{{1

" Eager Load {{{2

" altercmd {{{3
function! s:bulk_alter_command(original, altanative) abort
  if exists(':AlterCommand')
     execute 'AlterCommand ' . a:original . ' ' a:altanative
     execute 'AlterCommand <cmdwin> ' . a:original . ' ' a:altanative
  endif
endfunction

command! -nargs=+ BulkAlterCommand call <SID>bulk_alter_command(<f-args>)

if dein#tap('vim-altercmd')
  call altercmd#load()
  BulkAlterCommand ee       e!
  BulkAlterCommand co[de]   VSCode
  BulkAlterCommand fo[rk]   !fork
endif
" }}}3

" }}}2

" Plugin Manager {{{2

" dein {{{3
BulkAlterCommand dein Dein
" }}}

" }}}2

" IDE {{{2

" coc {{{3
if dein#tap('coc.nvim')
  BulkAlterCommand OR   OrganizeImport
  BulkAlterCommand jest       Jest
  BulkAlterCommand jc[urrent] JestCurrent
  BulkAlterCommand js[ingle]  JestSingle

let g:coc_global_extensions = [
\ 'coc-eslint',
\ 'coc-explorer',
\ 'coc-git',
\ 'coc-jest',
\ 'coc-json',
\ 'coc-markdownlint',
\ 'coc-marketplace',
\ 'coc-prettier',
\ 'coc-python',
\ 'coc-react-refactor',
\ 'coc-rust-analyzer',
\ 'coc-sh',
\ 'coc-snippets',
\ 'coc-solargraph',
\ 'coc-spell-checker',
\ 'coc-tsserver',
\ 'coc-vimlsp',
\ 'coc-word',
\ 'coc-yaml',
\ ]

  if !dein#tap('fzf-preview.vim')
    call add(g:coc_global_extensions, 'coc-fzf-preview')
  endif

  " Manual completion
  inoremap <silent> <expr> <C-Space> coc#refresh()

  " Snippet map
  let g:coc_snippet_next = '<C-f>'
  let g:coc_snippet_prev = '<C-b>'

  " keymap
  nnoremap <silent> K       :<C-u>call <SID>show_documentation()<CR>
  nmap     <silent> <dev>p  <Plug>(coc-diagnostic-prev)
  nmap     <silent> <dev>n  <Plug>(coc-diagnostic-next)
  nmap     <silent> <dev>d  <Plug>(coc-definition)
  nmap     <silent> <dev>I  <Plug>(coc-implementation)
  nmap     <silent> <dev>rn <Plug>(coc-rename)
  nmap     <silent> <dev>T  <Plug>(coc-type-definition)
  nmap     <silent> <dev>a  <Plug>(coc-codeaction-selected)
  nmap     <silent> <dev>A  <Plug>(coc-codeaction)
  nmap     <silent> <dev>l  <Plug>(coc-codelens-action)
  xmap     <silent> <dev>a  <Plug>(coc-codeaction-selected)
  nmap     <silent> <dev>f  <Plug>(coc-format)
  xmap     <silent> <dev>f  <Plug>(coc-format-selected)
  nmap     <silent> <dev>gs <Plug>(coc-git-chunkinfo)

  nnoremap <silent> <expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent> <expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent> <expr> <C-d> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
  inoremap <silent> <expr> <C-u> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<Left>"

  " nnoremap <Leader>e :<C-u>CocCommand explorer<CR>
  " nnoremap <Leader>E :<C-u>CocCommand explorer --reveal expand('%')<CR>

  nmap <silent> gp <Plug>(coc-git-prevchunk)
  nmap <silent> gn <Plug>(coc-git-nextchunk)

  function! s:organize_import_and_eslint() abort
    augroup eslint_with_organize_import
      autocmd!
      autocmd TextChanged * CocCommand eslint.executeAutofix
    augroup END

    function! s:orgamize_import_callback(fail, success) abort
      autocmd! eslint_with_organize_import
    endfunction

    call CocAction('runCommand', 'editor.action.organizeImport', function('<SID>orgamize_import_callback'))
  endfunction

  command! OrganizeImport          call CocAction('runCommand', 'editor.action.organizeImport')
  command! OrganizeImportAndESLint call <SID>organize_import_and_eslint()

  AutoCmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
      call CocActionAsync('doHover')
    else
      execute '!' . &keywordprg . ' ' . expand('<cword>')
    endif
  endfunction

  function! s:coc_float() abort
    call coc#config('diagnostic.messageTarget', 'float')
    call coc#config('signature.target', 'float')
    call coc#config('coc.preferences.hoverTarget', 'float')
  endfunction

  function! s:coc_echo() abort
    call coc#config('diagnostic.messageTarget', 'echo')
    call coc#config('signature.target', 'echo')
    call coc#config('coc.preferences.hoverTarget', 'echo')
  endfunction

  command! CocFloat call <SID>coc_float()
  command! CocEcho  call <SID>coc_echo()

  function! s:coc_typescript_settings() abort
    setlocal tagfunc=CocTagFunc
    nnoremap <silent> <buffer> <dev>f :<C-u>CocCommand eslint.executeAutofix<CR>
  endfunction

  function! s:coc_rust_settings() abort
    setlocal tagfunc=CocTagFunc
    nnoremap <silent> <buffer> gK :<C-u>CocCommand rust-analyzer.openDocs<CR>
  endfunction

  command! Jest        :call CocAction('runCommand', 'jest.projectTest')
  command! JestCurrent :call CocAction('runCommand', 'jest.fileTest', ['%'])
  command! JestSingle  :call CocAction('runCommand', 'jest.singleTest')

  " AutoCmd CursorHold * silent call CocActionAsync('highlight')
  AutoCmd FileType typescript,typescript.tsx call s:coc_typescript_settings()
  AutoCmd FileType rust call s:coc_rust_settings()
endif
" }}}3

" efm-langserver-settings {{{3
if dein#tap('vim-efm-langserver-settings')
  let g:efm_langserver_settings#filetype_whitelist = ['ruby', 'json', 'vim', 'sh', 'zsh']
endif
" }}}3

" deoplete.nvim {{{3
" if dein#tap('deoplete.nvim')
"   " Default Settings
"   let g:deoplete#enable_at_startup = 1
"
"   call deoplete#custom#option({
"   \ 'min_pattern_length': 2,
"   \ 'camel_case': v:true,
"   \ 'skip_chars': ['(', ')', '<', '>'],
"   \ })
"
"   " Keymap
"   inoremap <silent> <expr> <BS>  deoplete#smart_close_popup() . "\<C-h>"
"   inoremap <silent> <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
"
"   inoremap <silent> <expr> <C-n> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : deoplete#manual_complete()
"   inoremap <silent> <expr> <C-g> pumvisible() ? deoplete#smart_close_popup() : "\<C-g>"
"   inoremap <silent> <expr> <C-Space> deoplete#manual_complete()
"
"   function! s:check_back_space() abort
"     let col = col('.') - 1
"     return !col || getline('.')[col - 1]  =~# '\s'
"   endfunction
"
"   " tmux-complete
"   " let g:tmuxcomplete#trigger = ''
"
"   " vsnip
"   " imap <expr> <C-Space>   vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<C-Space>"
"   " smap <expr> <C-Space>   vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<C-Space>"
"   " xmap <expr> <C-Space>   vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<C-Space>"
"   " imap <expr> <C-f>       vsnip#available(1)  ? "\<Plug>(vsnip-jump-next)"      : "\<C-f>"
"   " smap <expr> <C-f>       vsnip#available(1)  ? "\<Plug>(vsnip-jump-next)"      : "\<C-f>"
"   " xmap <expr> <C-f>       vsnip#available(1)  ? "\<Plug>(vsnip-jump-next)"      : "\<C-f>"
"   " imap <expr> <C-b>       vsnip#available(-1) ? "\<Plug>(vsnip-jump-prev)"      : "\<C-b>"
"   " smap <expr> <C-b>       vsnip#available(-1) ? "\<Plug>(vsnip-jump-prev)"      : "\<C-b>"
"   " xmap <expr> <C-b>       vsnip#available(-1) ? "\<Plug>(vsnip-jump-prev)"      : "\<C-b>"
"
"   call deoplete#custom#source('_', 'converters', [
"   \ 'converter_remove_paren',
"   \ 'converter_remove_overlap',
"   \ 'converter_truncate_abbr',
"   \ 'converter_truncate_menu',
"   \ 'converter_auto_delimiter',
"   \ ])
"
"   " Sources
"   " call deoplete#custom#source('typescript', 'rank', 1500)
"   " call deoplete#custom#source('typescript', 'mark', '[TS]')
"   " call deoplete#custom#source('typescript', 'max_candidates', 8)
"
"   " call deoplete#custom#source('lsp', 'rank', 1400)
"   " call deoplete#custom#source('lsp', 'mark', '[LSP]')
"   " call deoplete#custom#source('lsp', 'max_candidates', 8)
"
"   " call deoplete#custom#source('LanguageClient', 'rank', 1400)
"   " call deoplete#custom#source('LanguageClient', 'mark', '[LC]')
"   " call deoplete#custom#source('LanguageClient', 'max_candidates', 8)
"
"   " call deoplete#custom#source('denite', 'rank', 1400)
"   " call deoplete#custom#source('denite', 'mark', '[denite]')
"   " call deoplete#custom#source('denite', 'max_candidates', 5)
"
"   " call deoplete#custom#source('vim', 'rank', 1300)
"   " call deoplete#custom#source('vim', 'mark', '[vim]')
"   " call deoplete#custom#source('vim', 'max_candidates', 5)
"
"   " call deoplete#custom#source('vsnip', 'rank', 1300)
"   " call deoplete#custom#source('vsnip', 'mark', '[Snip]')
"   " call deoplete#custom#source('vsnip', 'max_candidates', 5)
"
"   call deoplete#custom#source('tabnine', 'rank', 1200)
"   call deoplete#custom#source('tabnine', 'mark', '[TabNine]')
"   call deoplete#custom#source('tabnine', 'max_candidates', 10)
"   call deoplete#custom#source('tabnine', 'dup', v:true)
"
"   call deoplete#custom#source('around', 'rank', 1000)
"   call deoplete#custom#source('around', 'mark', '[Around]')
"   call deoplete#custom#source('around', 'max_candidates', 5)
"
"   call deoplete#custom#source('buffer', 'rank', 800)
"   call deoplete#custom#source('buffer', 'mark', '[Buffer]')
"   call deoplete#custom#source('buffer', 'max_candidates', 5)
"
"   " call deoplete#custom#source('tag', 'rank', 700)
"   " call deoplete#custom#source('tag', 'mark', '[tag]')
"   " call deoplete#custom#source('tag', 'max_candidates', 5)
"
"   " call deoplete#custom#source('omni', 'rank', 600)
"   " call deoplete#custom#source('omni', 'mark', '[omni]')
"   " call deoplete#custom#source('omni', 'max_candidates', 5)
"
"   call deoplete#custom#source('syntax', 'rank', 400)
"   call deoplete#custom#source('syntax', 'mark', '[Syntax]')
"   call deoplete#custom#source('syntax', 'max_candidates', 5)
"
"   call deoplete#custom#source('file', 'rank', 300)
"   call deoplete#custom#source('file', 'mark', '[File]')
"   call deoplete#custom#source('file', 'max_candidates', 5)
"   call deoplete#custom#source('file', 'dup', v:true)
"
"   " call deoplete#custom#source('tmux-complete', 'rank', 200)
"   " call deoplete#custom#source('tmux-complete', 'mark', '[tmux]')
"   " call deoplete#custom#source('tmux-complete', 'max_candidates', 5)
"
"   " call deoplete#custom#source('webcomplete', 'rank', 100)
"   " call deoplete#custom#source('webcomplete', 'mark', '[web]')
"   " call deoplete#custom#source('webcomplete', 'max_candidates', 5)
"
"   " call deoplete#custom#source('look', 'rank', 100)
"   " call deoplete#custom#source('look', 'mark', '[look]')
"   " call deoplete#custom#source('look', 'max_candidates', 5)
"
"   let s:deoplete_default_sources = ['tabnine', 'file', 'around', 'buffer']
"
"   let s:deoplete_sources                    = {}
"   let s:deoplete_sources['_']               = s:deoplete_default_sources
"   let s:deoplete_sources['javascript']      = s:deoplete_default_sources + ['']
"   let s:deoplete_sources['typescript']      = s:deoplete_default_sources + ['']
"   let s:deoplete_sources['typescript.tsx']  = s:deoplete_default_sources + ['']
"   let s:deoplete_sources['typescriptreact'] = s:deoplete_default_sources + ['']
" endif
" }}}3

" asyncomplete {{{3
" let g:asyncomplete_auto_popup = 1
" imap <C-Space> <Plug>(asyncomplete_force_refresh)
" }}}3

" }}}2

" Language {{{2

" fixjson {{{3
let g:fixjson_fix_on_save = 0
" }}}3

" gen_tags {{{3
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#ctags_opts     = '--excmd=number'
let g:loaded_gentags#gtags    = 1
" }}}3

" import-cost {{{3
if dein#tap('vim-import-cost') && has('nvim')
  " AutoCmd InsertLeave *.js,*.jsx,*.ts,*.tsx ImportCost
  " AutoCmd BufEnter *.js,*.jsx,*.ts,*.tsx    ImportCost
  " AutoCmd CursorHold *.js,*.jsx,*.ts,*.tsx  ImportCost
endif
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

" rainbow_csv {{{3
if dein#tap('rainbow_csv')
  let g:disable_rainbow_key_mappings = 1
endif
" }}}3

" treesitter {{{3
if dein#tap('nvim-treesitter') && has('nvim')
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"typescript", "tsx", "javascript", "css", "graphql", "jsdoc", "rust", "ruby", "bash", "json", "yaml", "toml"},
  highlight = {
    enable = true,
  },
  rainbow = {
    enable = true,
  },
  refactor = {
    highlight_current_scope = {
      -- enable = true
    },
  },
}

require "nvim-treesitter.highlight"
local hlmap = vim.treesitter.highlighter.hl_map

hlmap.error = nil
hlmap["punctuation.delimiter"] = "Delimiter"
hlmap["punctuation.bracket"] = nil
EOF
endif
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
BulkAlterCommand d[enite] Denite

if dein#tap('denite.nvim') && has('nvim')
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
    nnoremap <silent> <expr> <buffer>          i       denite#do_map('open_filter_buffer')
    nnoremap <silent> <expr> <buffer>          <CR>    denite#do_map('do_action')
    nnoremap <silent> <expr> <buffer>          <Tab>   denite#do_map('choose_action')
    nnoremap <silent> <expr> <buffer>          <C-g>   denite#do_map('quit')
    nnoremap <silent> <expr> <buffer>          q       denite#do_map('quit')
    nnoremap <silent> <expr> <buffer>          ZQ      denite#do_map('quit')
    nnoremap <silent>        <buffer>          <C-n>   j
    nnoremap <silent>        <buffer>          <C-p>   k
    nnoremap <silent> <expr> <buffer> <nowait> <Space> denite#do_map('toggle_select') . 'j'
    nnoremap <silent> <expr> <buffer>          d       denite#do_map('do_action', 'delete')
    nnoremap <silent> <expr> <buffer>          p       denite#do_map('do_action', 'preview')
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
  BulkAlterCommand to[ggle] Denite<Space>menu:toggle
  let s:menus = {}
  let s:menus.toggle = { 'description': 'Toggle Command' }
  let s:menus.toggle.command_candidates = [
  \ ['Toggle Review            [ReviewToggle]',              'ReviewToggle'           ],
  \ ['Toggle RelNum            [SNToggle]',                  'SNToggle'               ],
  \ ['Toggle CursorHighlight   [CursorHighlightToggle]',     'CursorHighlightToggle'  ],
  \ ['Toggle Context           [ContextToggleWindow]',       'ContextToggleWindow'    ],
  \ ['Toggle ComfortableMotion [ComfortableMotionToggle]',   'ComfortableMotionToggle'],
  \ ['Toggle IndentLine        [IndentLinesToggle]',         'IndentLinesToggle'      ],
  \ ['Toggle SyntaxHighlight   [SyntaxHighlightToggle]',     'SyntaxHighlightToggle'  ],
  \ ['Toggle TableMode         [TableMode]',                 'TableModeToggle'        ],
  \ ]
  call denite#custom#var('menu', 'menus', s:menus)
endif

" }}}3

" fzf & coc-fzf {{{3
let g:fzf_files_options = '--layout=reverse'
let g:fzf_layout      = { 'window': { 'width': 0.9, 'height': 0.9 } }
let g:coc_fzf_preview = 'right'
let g:coc_fzf_opts    = ['--layout=reverse']
let $BAT_THEME        = 'gruvbox'
let $BAT_STYLE        = 'plain'

" Nord
" let $FZF_DEFAULT_OPTS = '--color=hl:#81A1C1,hl+:#81A1C1,info:#EACB8A,prompt:#81A1C1,pointer:#B48DAC,marker:#A3BE8B,spinner:#B48DAC,header:#A3BE8B'
" Gruvbox
let $FZF_DEFAULT_OPTS = '--color=bg+:#1d2021,bg:#1d2021,spinner:#d8a657,hl:#a9b665,fg:#d4be98,header:#928374,info:#89b482,pointer:#7daea3,marker:#d8a657,fg+:#d4be98,prompt:#e78a4e,hl+:#89b482'
" }}}3

" fzf-preview {{{3
" let g:fzf_preview_rpc_debug = 1
let g:fzf_preview_git_files_command   = 'git ls-files --exclude-standard | while read line; do if [[ ! -L $line ]] && [[ -f $line ]]; then echo $line; fi; done'
let g:fzf_preview_grep_cmd            = 'rg --line-number --no-heading --color=never --sort=path'
let g:fzf_preview_mru_limit           = 5000
let g:fzf_preview_use_dev_icons       = 1
let g:fzf_preview_default_fzf_options = {
\ '--reverse': v:true,
\ '--preview-window': 'wrap',
\ '--exact': v:true,
\ '--no-sort': v:true,
\ }
let $FZF_PREVIEW_PREVIEW_BAT_THEME  = 'gruvbox'

noremap <fzf-p> <Nop>
map     ;       <fzf-p>
noremap ;;      ;

nnoremap <silent> <fzf-p>r     :<C-u>FzfPreviewFromResourcesRpc buffer project_mru<CR>
nnoremap <silent> <fzf-p>w     :<C-u>FzfPreviewProjectMrwFilesRpc<CR>
nnoremap <silent> <fzf-p>a     :<C-u>FzfPreviewFromResourcesRpc project_mru git<CR>
nnoremap <silent> <fzf-p>s     :<C-u>FzfPreviewGitStatusRpc<CR>
nnoremap <silent> <fzf-p>gg    :<C-u>FzfPreviewGitActionsRpc<CR>
nnoremap <silent> <fzf-p>b     :<C-u>FzfPreviewBuffersRpc<CR>
nnoremap <silent> <fzf-p>B     :<C-u>FzfPreviewAllBuffersRpc<CR>
nnoremap <silent> <fzf-p><C-o> :<C-u>FzfPreviewJumpsRpc<CR>
nnoremap <silent> <fzf-p>g;    :<C-u>FzfPreviewChangesRpc<CR>
nnoremap <silent> <fzf-p>/     :<C-u>FzfPreviewLinesRpc --resume --add-fzf-arg=--no-sort<CR>
nnoremap <silent> <fzf-p>*     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
xnoremap <silent> <fzf-p>*     "sy:FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=substitute(@s, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
nnoremap <silent> <fzf-p>n     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=substitute(@/, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
nnoremap <silent> <fzf-p>?     :<C-u>FzfPreviewBufferLinesRpc --resume --add-fzf-arg=--no-sort<CR>
nnoremap <silent> <fzf-p>q     :<C-u>FzfPreviewQuickFixRpc<CR>
nnoremap <silent> <fzf-p>l     :<C-u>FzfPreviewLocationListRpc<CR>
nnoremap <silent> <fzf-p>:     :<C-u>FzfPreviewCommandPaletteRpc<CR>
nnoremap <silent> <fzf-p>m     :<C-u>FzfPreviewBookmarksRpc --resume<CR>
nnoremap <silent> <fzf-p><C-]> :<C-u>FzfPreviewVistaCtagsRpc --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
nnoremap <silent> <fzf-p>o     :<C-u>FzfPreviewVistaBufferCtagsRpc<CR>

nnoremap          <fzf-p>f     :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
xnoremap          <fzf-p>f     "sy:CocCommand fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <silent> <fzf-p>p     :<C-u>CocCommand fzf-preview.Yankround<CR>

nnoremap <silent> <dev>q  :<C-u>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
nnoremap <silent> <dev>Q  :<C-u>CocCommand fzf-preview.CocDiagnostics<CR>
nnoremap <silent> <dev>rf :<C-u>CocCommand fzf-preview.CocReferences<CR>
nnoremap <silent> <dev>t  :<C-u>CocCommand fzf-preview.CocTypeDefinitions<CR>

AutoCmd User fzf_preview#rpc#initialized call s:fzf_preview_settings()

function! s:buffers_delete_from_lines(lines) abort
  for line in a:lines
    let matches = matchlist(line, '\[\(\d\+\)\]')
    if len(matches) >= 1
      execute 'Bdelete! ' . matches[1]
    endif
  endfor
endfunction

"" TODO: fzf Reflection
" function! FzfColor()
"   if !exists('g:fzf_colors')
"     return ''
"   endif
"
"   let lines = filter(split(execute('script'), '\n'), { _, v -> v =~# 'junegunn/fzf/plugin/fzf.vim' })
"   if len(lines) < 1
"     return ''
"   endif
"
"   let file_nums = matchlist(lines[0], '^\s*\(\d\+\)')
"   if len(file_nums) <= 1
"     return ''
"   endif
"
"   let func_name = "\<SNR\>" . file_nums[1] . '_defaults()'
"   if !exists('*' . func_name)
"     return ''
"   endif
"
"   let option = matchlist(execute('echo ' . func_name), '''--color=\(.\+\)''')
"   if len(option) <= 1
"     return ''
"   endif
"
"   return option[1]
" endfunction
"
" let g:fzf_colors = {
"\ 'fg':      ['fg', 'Normal'],
"\ 'bg':      ['bg', 'Normal'],
"\ 'hl':      ['fg', 'Comment'],
"\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"\ 'hl+':     ['fg', 'Statement'],
"\ 'info':    ['fg', 'PreProc'],
"\ 'border':  ['fg', 'Ignore'],
"\ 'prompt':  ['fg', 'Conditional'],
"\ 'pointer': ['fg', 'Exception'],
"\ 'marker':  ['fg', 'Keyword'],
"\ 'spinner': ['fg', 'Label'],
"\ 'header':  ['fg', 'Comment']
"\ }

function! s:fzf_preview_settings() abort
  let g:fzf_preview_grep_preview_cmd = 'COLORTERM=truecolor ' . g:fzf_preview_grep_preview_cmd
  let g:fzf_preview_command = 'COLORTERM=truecolor ' . g:fzf_preview_command
  let g:fzf_preview_git_status_preview_command =  '[[ $(git diff --cached -- {-1}) != "" ]] && git diff --cached --color=always -- {-1} | delta || ' .
  \ '[[ $(git diff -- {-1}) != "" ]] && git diff --color=always -- {-1} | delta || ' .
  \ g:fzf_preview_command

  let g:fzf_preview_custom_processes['open-file'] = fzf_preview#remote#process#get_default_processes('open-file', 'rpc')
  let g:fzf_preview_custom_processes['open-file']['ctrl-s'] = g:fzf_preview_custom_processes['open-file']['ctrl-x']
  call remove(g:fzf_preview_custom_processes['open-file'], 'ctrl-x')

  let g:fzf_preview_custom_processes['open-buffer'] = fzf_preview#remote#process#get_default_processes('open-buffer', 'rpc')
  let g:fzf_preview_custom_processes['open-buffer']['ctrl-s'] = g:fzf_preview_custom_processes['open-buffer']['ctrl-x']
  call remove(g:fzf_preview_custom_processes['open-buffer'], 'ctrl-q')
  let g:fzf_preview_custom_processes['open-buffer']['ctrl-x'] = get(function('s:buffers_delete_from_lines'), 'name')

  let g:fzf_preview_custom_processes['open-bufnr'] = fzf_preview#remote#process#get_default_processes('open-bufnr', 'rpc')
  let g:fzf_preview_custom_processes['open-bufnr']['ctrl-s'] = g:fzf_preview_custom_processes['open-bufnr']['ctrl-x']
  call remove(g:fzf_preview_custom_processes['open-bufnr'], 'ctrl-q')
  let g:fzf_preview_custom_processes['open-bufnr']['ctrl-x'] = get(function('s:buffers_delete_from_lines'), 'name')

  let g:fzf_preview_custom_processes['git-status'] = fzf_preview#remote#process#get_default_processes('git-status', 'rpc')
  let g:fzf_preview_custom_processes['git-status']['ctrl-s'] = g:fzf_preview_custom_processes['git-status']['ctrl-x']
  call remove(g:fzf_preview_custom_processes['git-status'], 'ctrl-x')
endfunction

AutoCmd FileType fzf let b:highlight_cursor = 0
" if has('nvim')
"   AutoCmd FileType fzf set winblend=15
" endif
" }}}3

" telescope {{{3
if dein#tap('telescope.nvim')
  nnoremap <silent> (ctrlp) <cmd>lua require'telescope.builtin'.git_files{}<CR>
endif
" }}}3

" }}}2

" Git {{{2

" blamer {{{3
if dein#tap('blamer.nvim')
  let g:blamer_enabled = 1
  let g:blamer_show_in_visual_modes = 0
endif
" }}}3

" git-messenger {{{3
if dein#tap('git-messenger.vim')
  nnoremap <silent> gm :<C-u>GitMessenger<CR>
endif
" }}}3

" gina {{{3
BulkAlterCommand git   Gina
BulkAlterCommand gina  Gina
BulkAlterCommand gs    Gina<Space>status
BulkAlterCommand gci   Gina<Space>commit<Space>--no-verify
BulkAlterCommand gd    Gina<Space>diff
BulkAlterCommand gdc   Gina<Space>diff<Space>--cached
BulkAlterCommand gco   Gina<Space>checkout
BulkAlterCommand log   Gina<Space>log
BulkAlterCommand blame Gina<Space>blame

AutoCmd VimEnter * call s:gina_settings()

function! s:gina_settings()
  call gina#custom#command#option('status', '--short')
  call gina#custom#command#option('/\%(status\|commit\|branch\)', '--opener', 'split')
  call gina#custom#command#option('diff', '--opener', 'vsplit')

  call gina#custom#command#option('/\%(status\|changes\)', '--ignore-submodules')
  call gina#custom#command#option('status', '--branch')
  call gina#custom#mapping#nmap('status', '<C-j>', ':TmuxNavigateDown<CR>', {'noremap': 1, 'silent': 1})
  call gina#custom#mapping#nmap('status', '<C-k>', ':TmuxNavigateUp<CR>',   {'noremap': 1, 'silent': 1})

  call gina#custom#mapping#nmap('diff', '<CR>', '<Plug>(gina-diff-jump-vsplit)', {'silent': 1})

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
BulkAlterCommand gss GitSessionSave
BulkAlterCommand gsl GitSessionLoad
BulkAlterCommand gsd GitSessionDelete

let g:gitsessions_disable_auto_load = 1
" }}}3

" }}}2

" filer {{{2

" defx {{{3
let g:defx_git#raw_mode        = 1
let g:defx_icons_column_length = 2

if has('nvim')
  nnoremap <silent> <Leader><Leader>e :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft<CR>
  nnoremap <silent> <Leader><Leader>E :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft -search=`expand('%:p')`<CR>
endif

let g:defx_ignore_filtype = ['denite', 'defx']

function! s:defx_settings() abort
  nnoremap <silent> <buffer> <expr> <nowait> j       line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent> <buffer> <expr> <nowait> k       line('.') == 1 ? 'G' : 'k'
  nnoremap <silent> <buffer> <expr> <nowait> t       defx#do_action('open_or_close_tree')
  nnoremap <silent> <buffer> <expr> <nowait> h       defx#do_action('cd', ['..'])
  nnoremap <silent> <buffer> <expr> <nowait> l       defx#is_directory() ? defx#do_action('open_tree') : 0
  nnoremap <silent> <buffer> <expr> <nowait> L       defx#do_action('open_tree_recursive')
  nnoremap <silent> <buffer> <expr> <nowait> .       defx#do_action('toggle_ignored_files')
  nnoremap <silent> <buffer> <expr> <nowait> ~       defx#do_action('cd')

  nnoremap <silent> <buffer> <expr> <nowait> <CR>    defx#is_directory() ? 0 : defx#do_action('open', 'choose')
  nnoremap <silent> <buffer> <expr> <nowait> x       defx#do_action('toggle_select') . 'j'
  nnoremap <silent> <buffer> <expr> <nowait> <Space> defx#do_action('toggle_select') . 'j'
  nnoremap <silent> <buffer> <expr> <nowait> *       defx#do_action('toggle_select_all')
  nnoremap <silent> <buffer> <expr> <nowait> N       defx#do_action('new_file')
  nnoremap <silent> <buffer> <expr> <nowait> N       defx#do_action('new_multiple_files')
  nnoremap <silent> <buffer> <expr> <nowait> K       defx#do_action('new_directory')
  nnoremap <silent> <buffer> <expr> <nowait> c       defx#do_action('copy')
  nnoremap <silent> <buffer> <expr> <nowait> m       defx#do_action('move')
  nnoremap <silent> <buffer> <expr> <nowait> p       defx#do_action('paste')
  nnoremap <silent> <buffer> <expr> <nowait> d       defx#do_action('remove')
  nnoremap <silent> <buffer> <expr> <nowait> r       defx#do_action('rename')
  nnoremap <silent> <buffer> <expr> <nowait> yy      defx#do_action('yank_path')

  nnoremap <silent> <buffer> <expr> <nowait> q       defx#do_action('quit')
  nnoremap <silent> <buffer> <expr> <nowait> R       defx#do_action('redraw')
  nnoremap <silent> <buffer> <expr> <nowait> <C-g>   defx#do_action('print')
endfunction

AutoCmd FileType defx call s:defx_settings()
" }}}3

" fern {{{3
let g:fern#disable_default_mappings  = 1
let g:fern#drawer_width              = 40
let g:fern#renderer                  = 'nerdfont'
let g:fern#renderer#nerdfont#padding = '  '
let g:fern#smart_cursor              = 'hide'

" if !has('nvim')
nnoremap <silent> <Leader>e :<C-u>Fern . -drawer<CR><C-w>=
nnoremap <silent> <Leader>E :<C-u>Fern . -drawer -reveal=%<CR><C-w>=
" endif

function! s:fern_settings() abort
  nmap <silent> <buffer> <expr> <Plug>(fern-expand-or-collapse)                 fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")
  nmap <silent> <buffer> <expr> <Plug>(fern-open-system-directory-or-open-file) fern#smart#leaf( "\<Plug>(fern-action-open:select)", "\<Plug>(fern-action-open:system)")

  nmap <silent> <buffer> <nowait> a     <Plug>(fern-choice)
  nmap <silent> <buffer> <nowait> <CR>  <Plug>(fern-open-system-directory-or-open-file)
  nmap <silent> <buffer> <nowait> t     <Plug>(fern-expand-or-collapse)
  nmap <silent> <buffer> <nowait> l     <Plug>(fern-open-or-enter)
  nmap <silent> <buffer> <nowait> h     <Plug>(fern-action-leave)
  nmap <silent> <buffer> <nowait> x     <Plug>(fern-action-mark:toggle)
  vmap <silent> <buffer> <nowait> x     <Plug>(fern-action-mark:toggle)
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

  setlocal nonumber norelativenumber
  AutoCmd CursorMoved <buffer> echo matchstr(getline('.'), '[-./[:alnum:]_]\+')
endfunction

AutoCmd FileType fern call s:fern_settings()
AutoCmd FileType fern call glyph_palette#apply()
" }}}3

" }}}2

" textobj & operator {{{2

" equal.operator {{{3
let equal_operator_default_mappings = 0

omap i=h <Plug>(operator-lhs)
omap a=h <Plug>(operator-Lhs)
xmap i=h <Plug>(visual-lhs)
xmap a=h <Plug>(visual-Lhs)

omap i=l <Plug>(operator-rhs)
omap a=l <Plug>(operator-Rhs)
xmap i=l <Plug>(visual-rhs)
xmap a=l <Plug>(visual-Rhs)
" }}}3

" operator-convert-case {{{3
nmap cy <Plug>(operator-convert-case-loop)
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
if dein#tap('vim-textobj-between')
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
endif
" }}}3

" textobj-functioncall {{{3
let g:textobj_functioncall_patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '(',
  \   'ket'    : ')',
  \   'footer' : '',
  \ },
  \ {
  \   'header' : '\<\h\k*',
  \   'bra'    : '<',
  \   'ket'    : '>',
  \   'footer' : '',
  \ },
  \ ]
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{3
if dein#tap('accelerated-jk')
  nmap j <Plug>(accelerated_jk_j)
  nmap k <Plug>(accelerated_jk_k)
endif
" }}}3

" hlslens & asterisk {{{3
if dein#tap('nvim-hlslens') && dein#tap('vim-asterisk')
  " let g:incsearch#magic = '\v'

  " map /  <Plug>(incsearch-forward)
  " map ?  <Plug>(incsearch-backward)

  if has('nvim')
    lua require('hlslens').setup({auto_enable = true})

    nnoremap <silent> n  :<C-u>execute('normal! ' . v:count1 . 'n')<CR>:lua require('hlslens').start()<CR>zzzv
    nnoremap <silent> N  :<C-u>execute('normal! ' . v:count1 . 'N')<CR>:lua require('hlslens').start()<CR>zzzv
    map      <silent> *  <Plug>(asterisk-z*):lua require('hlslens').start()<CR>
    map      <silent> #  <Plug>(asterisk-z#):lua require('hlslens').start()<CR>
    map      <silent> g* <Plug>(asterisk-gz*):lua require('hlslens').start()<CR>
    map      <silent> g# <Plug>(asterisk-gz#):lua require('hlslens').start()<CR>

    nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>:lua require('hlslens').disable()<CR>
  endif
endif
" }}}3

" BackAndForward {{{3
nmap <C-b> <Plug>(backandforward-back)
nmap <C-f> <Plug>(backandforward-forward)
" }}}3

" bookmarks {{{3
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_save_per_working_dir    = 1

noremap <bookmark> <Nop>
map     M          <bookmark>

nnoremap <silent> <bookmark>m :<C-u>BookmarkToggle<CR>
nnoremap <silent> <bookmark>i :<C-u>BookmarkAnnotate<CR>
nnoremap <silent> <bookmark>n :<C-u>BookmarkNext<CR>
nnoremap <silent> <bookmark>p :<C-u>BookmarkPrev<CR>
nnoremap <silent> <bookmark>a :<C-u>BookmarkShowAll<CR>
nnoremap <silent> <bookmark>c :<C-u>BookmarkClear<CR>
nnoremap <silent> <bookmark>x :<C-u>BookmarkClearAll<CR>

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
if dein#tap('caw.vim')
  let g:caw_no_default_keymappings = 0

  nmap <silent> <Leader>c  <Plug>(caw:hatpos:toggle:operator)
  nmap <silent> <Leader>cc <Plug>(caw:hatpos:toggle)
  xmap <silent> <Leader>cc <Plug>(caw:hatpos:toggle)
  nmap <silent> <Leader>C  <Plug>(caw:wrap:toggle:operator)
  nmap <silent> <Leader>CC <Plug>(caw:wrap:toggle)
  xmap <silent> <Leader>CC <Plug>(caw:wrap:toggle)
endif
" }}}3

" easy-align {{{3
vnoremap ga :EasyAlign<CR>

let g:easy_align_delimiters = {
\ '>': {
\   'pattern':       '===\|<=>\|=\~[#?]\?\|=>\|[:+/*!%^=><&|.-?]*=[#?]\?\|[-=]>\|<[-=]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left': 1,
\ },
\ '/': {
\   'pattern':         '//\+\|/\*\|\*/',
\   'left_margin':     1,
\   'right_margin':    1,
\   'stick_to_left':   0,
\   'delimiter_align': 'l',
\   'ignore_groups':   ['!Comment']
\ },
\ ']': {
\   'pattern':       '[[\]]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left': 0,
\  },
\ ')': {
\   'pattern':       '[()]',
\   'left_margin':   0,
\   'right_margin':  0,
\   'stick_to_left': 0,
\ },
\ '#': {
\   'pattern':       '#',
\   'left_margin':   1,
\   'right_margin':  1,
\   'stick_to_left': 0,
\   'ignore_groups': ['String'],
\ },
\ '"': {
\   'left_margin':   1,
\   'right_margin':  1,
\   'stick_to_left': 0,
\   'pattern':       '"',
\   'ignore_groups': ['String'],
\ },
\ ';': {
\   'pattern':       ';',
\   'left_margin':   0,
\   'right_margin':  1,
\   'stick_to_left': 1,
\ }
\ }
" }}}3

" easymotion {{{3
if dein#tap('vim-easymotion')
  " EasyMotion
  let g:EasyMotion_do_mapping       = 0
  let g:EasyMotion_smartcase        = 1
  let g:EasyMotion_startofline      = 0
  let g:EasyMotion_keys             = 'HJKLASDFGYUIOPQWERTNMZXCVB'
  let g:EasyMotion_use_upper        = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
  let g:EasyMotion_prompt           = 'Search by EasyMotion ({n} character(s)) > '

  nmap <silent> S  <Plug>(easymotion-overwin-f)
  omap <silent> S  <Plug>(easymotion-bd-f)
  xmap <silent> S  <Plug>(easymotion-bd-f)
  nmap <silent> ss <Plug>(easymotion-overwin-w)
  omap <silent> ss <Plug>(easymotion-bd-w)
  xmap <silent> ss <Plug>(easymotion-bd-w)
  " omap <silent> f  <Plug>(easymotion-fl)
  " omap <silent> t  <Plug>(easymotion-tl)
  " omap <silent> F  <Plug>(easymotion-Fl)
  " omap <silent> T  <Plug>(easymotion-Tl)
endif
" }}}3

" eft {{{3
if dein#tap('vim-eft')
  let g:eft_enable = 1
  nnoremap <Leader>f :<C-u>EftToggle<CR>

  function s:eft_toggle()
    if g:eft_enable == 1
      let g:eft_enable = 0
      call <SID>eft_disable()
    else
      let g:eft_enable = 1
      call <SID>eft_enable()
    endif
  endfunction
  command! EftToggle call <SID>eft_toggle()

  function s:eft_enable()
    nmap ;; <Plug>(eft-repeat)
    xmap ;; <Plug>(eft-repeat)

    nmap f <Plug>(eft-f)
    xmap f <Plug>(eft-f)
    omap f <Plug>(eft-f)
    nmap F <Plug>(eft-F)
    xmap F <Plug>(eft-F)
    omap F <Plug>(eft-F)

    " nmap t <Plug>(eft-t)
    xmap t <Plug>(eft-t)
    omap t <Plug>(eft-t)
    " nmap T <Plug>(eft-T)
    xmap T <Plug>(eft-T)
    omap T <Plug>(eft-T)
  endfunction

  function s:eft_disable()
    nnoremap ;; ;
    nnoremap ;; ;

    nunmap f
    xunmap f
    ounmap f
    nunmap F
    xunmap F
    ounmap F

    xunmap t
    ounmap t
    xunmap T
    ounmap T
  endfunction

  AutoCmd VimEnter * call <SID>eft_enable()
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
\ 'ii': 0,
\ 'ai': 0,
\ 'ie': 0,
\ }

" let g:expand_region_text_objects_ruby = {
" \ 'iw': 0,
" \ 'i"': 0,
" \ 'a"': 0,
" \ "i'": 0,
" \ "a'": 0,
" \ 'i(': 0,
" \ 'a(': 0,
" \ 'i[': 0,
" \ 'a[': 0,
" \ 'i{': 0,
" \ 'a{': 0,
" \ 'il': 0,
" \ 'ir': 0,
" \ 'ar': 0,
" \ 'ie': 0,
" \ }

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
BulkAlterCommand gr[ep] Grepper

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

" lexima {{{3
if dein#tap('lexima.vim')
  let g:lexima_map_escape = ''
  let g:lexima_enable_endwise_rules = 0

  let s:rules = []

  "" Parenthesis
  let s:rules += [
  \ { 'char': '<C-h>', 'at': '(\%#)', 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': '(\%#)', 'input': '<BS><Del>', },
  \ ]

  "" Brace
  let s:rules += [
  \ { 'char': '<C-h>', 'at': '{\%#}', 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': '{\%#}', 'input': '<BS><Del>', },
  \ ]

  "" Bracket
  let s:rules += [
  \ { 'char': '<C-h>', 'at': '\[\%#\]', 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': '\[\%#\]', 'input': '<BS><Del>', },
  \ ]

  "" Sinble Quote
  let s:rules += [
  \ { 'char': '<C-h>', 'at': "'\\%#'", 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': "'\\%#'", 'input': '<BS><Del>', },
  \ ]

  "" Double Quote
  let s:rules += [
  \ { 'char': '<C-h>', 'at': '"\%#"', 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': '"\%#"', 'input': '<BS><Del>', },
  \ ]

  "" Back Quote
  let s:rules += [
  \ { 'char': '<C-h>', 'at': '`\%#`', 'input': '<BS><Del>', },
  \ { 'char': '<BS>',  'at': '`\%#`', 'input': '<BS><Del>', },
  \ ]

  "" Move closing parenthesis
  let s:rules += [
  \ { 'char': '<C-f>', 'at': '\%#\s*)',  'input': '<Left><C-o>f)<Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*\}', 'input': '<Left><C-o>f}<Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*\]', 'input': '<Left><C-o>f]<Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*>',  'input': '<Left><C-o>f><Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*`',  'input': '<Left><C-o>f`<Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*"',  'input': '<Left><C-o>f"<Right>'  },
  \ { 'char': '<C-f>', 'at': '\%#\s*''', 'input': '<Left><C-o>f''<Right>' },
  \ ]

  "" TypeScript
  let s:rules += [
  \ { 'filetype': ['typescript', 'typescript.tsx', 'typescriptreact', 'javascript'], 'char': '>',     'at': '(\%#)',                                      'input': '(',                              'input_after': ') => {}', },
  \ { 'filetype': ['typescript', 'typescript.tsx', 'typescriptreact', 'javascript'], 'char': '<C-f>', 'at': '\%#)\s=>',                                   'input': '<C-o>f{<Right>',                                           },
  \ { 'filetype': ['typescript', 'typescript.tsx', 'typescriptreact', 'javascript'], 'char': '{',     'at': '^import\s\(type\s\)\?\%#',                   'input': '{<Space><Space>} from ""<Left>',                           },
  \ { 'filetype': ['typescript', 'typescript.tsx', 'typescriptreact', 'javascript'], 'char': '<C-b>', 'at': '^import\s\(type\s\)\?{\s\s}\sfrom ".*\%#"$', 'input': '<C-o>F}<Left>',                                            },
  \ { 'filetype': ['typescript', 'typescript.tsx', 'typescriptreact', 'javascript'], 'char': '$',     'at': '$\%#',                                       'input': '{}<Left>',                                                 },
  \ ]

  "" ruby
  let s:rules += [
  \ { 'filetype': 'ruby', 'char': '<CR>',  'at': '^\s*\%(module\|def\|class\|if\|unless\)\s\w\+\((.*)\)\?\%#$', 'input': '<CR>',         'input_after': 'end',          },
  \ { 'filetype': 'ruby', 'char': '<CR>',  'at': '^\s*\%(begin\)\s*\%#',                                        'input': '<CR>',         'input_after': 'end',          },
  \ { 'filetype': 'ruby', 'char': '<CR>',  'at': '\%(^\s*#.*\)\@<!do\%(\s*|.*|\)\?\s*\%#',                      'input': '<CR>',         'input_after': 'end',          },
  \ { 'filetype': 'ruby', 'char': '<Bar>', 'at': 'do\%#',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><CR>end', },
  \ { 'filetype': 'ruby', 'char': '<Bar>', 'at': 'do\s\%#',                                                     'input': '<Bar>',        'input_after': '<Bar><CR>end', },
  \ { 'filetype': 'ruby', 'char': '<Bar>', 'at': '{\%#}',                                                       'input': '<Space><Bar>', 'input_after': '<Bar><Space>', },
  \ { 'filetype': 'ruby', 'char': '<Bar>', 'at': '{\s\%#\s}',                                                   'input': '<Bar>',        'input_after': '<Bar><Space>', },
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
endif
" }}}3

" quick-scope {{{3
" let g:qs_buftype_blacklist = ['terminal', 'nofile']
" }}}3

" replacer {{{3
BulkAlterCommand replacer lua<Space>require(\"replacer\").run()
" }}}3

" reword {{{3
BulkAlterCommand rew[ord] %Reword
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich')
  omap is <Plug>(textobj-sandwich-query-i)
  omap as <Plug>(textobj-sandwich-query-a)
  xmap is <Plug>(textobj-sandwich-query-i)
  xmap as <Plug>(textobj-sandwich-query-a)

  omap i/ <Plug>(textobj-sandwich-literal-query-i)/
  omap a/ <Plug>(textobj-sandwich-literal-query-a)/
  xmap i/ <Plug>(textobj-sandwich-literal-query-i)/
  xmap a/ <Plug>(textobj-sandwich-literal-query-a)/

  omap i_ <Plug>(textobj-sandwich-literal-query-i)_
  omap a_ <Plug>(textobj-sandwich-literal-query-a)_
  xmap i_ <Plug>(textobj-sandwich-literal-query-i)_
  xmap a_ <Plug>(textobj-sandwich-literal-query-a)_

  omap i- <Plug>(textobj-sandwich-literal-query-i)-
  omap a- <Plug>(textobj-sandwich-literal-query-a)-
  xmap i- <Plug>(textobj-sandwich-literal-query-i)-
  xmap a- <Plug>(textobj-sandwich-literal-query-a)-

  omap i<Space> <Plug>(textobj-sandwich-literal-query-i)<Space>
  omap a<Space> <Plug>(textobj-sandwich-literal-query-a)<Space>
  xmap i<Space> <Plug>(textobj-sandwich-literal-query-i)<Space>
  xmap a<Space> <Plug>(textobj-sandwich-literal-query-a)<Space>

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
  \   '__filetype__': 'javascript, typescript',
  \   'buns':     ['${', '}'],
  \   'input':    ['$'],
  \   'filetype': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'typescript.tsx'],
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

  let g:sandwich#recipes += [
  \ {
  \   'buns': ['InputGenerics()', '">"'],
  \   'expr': 1,
  \   'cursor': 'inner_tail',
  \   'kind': ['add', 'replace'],
  \   'action': ['add'],
  \   'input': ['g']
  \ },
  \ {
  \   'external': ['i<', "\<Plug>(textobj-functioncall-a)"],
  \   'noremap': 0,
  \   'kind': ['delete', 'replace', 'query'],
  \   'input': ['g']
  \ },
  \ ]

  function! InputGenerics() abort
    let genericsname = input('Generics Name: ', '')
    if genericsname ==# ''
      throw 'OperatorSandwichCancel'
    endif
    return genericsname . '<'
  endfunction

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
BulkAlterCommand sc[ratch] Scratch

let g:scratch_no_mappings = 1
" }}}3

" shot-f {{{3
" if dein#tap('vim-shot-f')
"   let g:shot_f_no_default_key_mappings = 1
"   nmap <silent> f <Plug>(shot-f-f)
"   nmap <silent> F <Plug>(shot-f-F)
" endif
" }}}3

" tcomment {{{3
" let g:tcomment_maps = 0
"
" noremap <silent> <Leader>cc :TComment<CR>
" }}}3

" trip {{{3
if dein#tap('vim-trip')
  nmap <C-a> <Plug>(trip-increment)
  nmap <C-x> <Plug>(trip-decrement)
endif
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history   = 10000
  let g:yankround_use_region_hl = 1
  let g:yankround_dir           = '~/.cache/vim/yankround'

  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap <silent> <expr> <C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "(ctrlp)"
  nmap <silent> <expr> <C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : ""
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
let g:brightest#enable_filetypes = {
\ '_':          1,
\ 'fern':       0,
\ 'cocactions': 0,
\ }

let g:brightest#highlight = {
\ 'group': 'BrighTestHighlight',
\ 'priority': 0
\ }
let g:brightest#ignore_syntax_list = ['Statement', 'Keyword', 'Boolean', 'Repeat']
" }}}3

" choosewin {{{3
let s:choosewin_nord = ['#81A1C1', '#4C566A']
let g:choosewin_color_label = {
\ 'gui': s:choosewin_nord + ['bold'],
\ 'cterm': [4, 8]
\ }
" }}}3

" comfortable-motion {{{3
if dein#tap('comfortable-motion.vim')
  let g:comfortable_motion_no_default_key_mappings = 1
  let g:comfortable_motion_enable = 0

  function! s:comfortable_motion_toggle()
    if g:comfortable_motion_enable == 1
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

  command! ComfortableMotionToggle call <SID>comfortable_motion_toggle()
endif
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
if dein#tap('vim-highlightedundo')
  let g:highlightedundo#highlight_mode = 2

  nmap <silent> u     <Plug>(highlightedundo-undo)
  nmap <silent> <C-r> <Plug>(highlightedundo-redo)
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
if dein#tap('indentLine')
  let g:indentLine_enabled = 0
  let g:indentLine_fileTypeExclude = ['json', 'defx', 'fern']
endif
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ 'active': {
  \   'left': [
  \     ['mode', 'spell', 'paste'],
  \     ['filepath', 'filename'],
  \     ['special_mode', 'vm_regions'],
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
  \   'filepath':     'Lightline_filepath',
  \   'filename':     'Lightline_filename',
  \   'filetype':     'Lightline_filetype',
  \   'lineinfo':     'Lightline_lineinfo',
  \   'fileencoding': 'Lightline_fileencoding',
  \   'fileformat':   'Lightline_fileformat',
  \   'special_mode': 'Lightline_special_mode',
  \   'vm_regions':   'Lightline_vm_regions',
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum': 'Lightline_tab_win_num',
  \ },
  \ 'component_visible_condition': {
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
  \   'linter_hint':         'Lightline_coc_hint',
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
  \ 'qf',
  \ 'help',
  \ 'diff',
  \ 'man',
  \ 'fzf',
  \ 'defx',
  \ 'fern',
  \ 'coc-explorer',
  \ 'capture',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ft_to_mode_hash = {
  \ 'help':         'Help',
  \ 'diff':         'Diff',
  \ 'man':          'Man',
  \ 'fzf':          'FZF',
  \ 'defx':         'Defx',
  \ 'fern':         'Fern',
  \ 'coc-explorer': 'Explorer',
  \ 'capture':      'Capture',
  \ 'gina-status':  'Git Status',
  \ 'gina-branch':  'Git Branch',
  \ 'gina-log':     'Git Log',
  \ 'gina-reflog':  'Git Reflog',
  \ 'gina-blame':   'Git Blame',
  \ }

  let s:lightline_ignore_modifiable_ft = [
  \ 'qf',
  \ 'help',
  \ 'man',
  \ 'fzf',
  \ 'defx',
  \ 'fern',
  \ 'coc-explorer',
  \ 'capture',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filename_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'defx',
  \ 'fern',
  \ 'coc-explorer',
  \ 'gina-status',
  \ 'gina-branch',
  \ 'gina-log',
  \ 'gina-reflog',
  \ 'gina-blame',
  \ ]

  let s:lightline_ignore_filepath_ft = [
  \ 'qf',
  \ 'fzf',
  \ 'defx',
  \ 'fern',
  \ 'coc-explorer',
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
    \ Lightline_filetype() ==# '' ? '' :
    \ l:win.loclist ? '[Location List] ' . get(w:, 'quickfix_title', ''):
    \ l:win.quickfix ? '[QuickFix] ' . get(w:, 'quickfix_title', '') :
    \ ''
  endfunction

  function! Lightline_filepath() abort
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
      return &filetype . ' ' . WebDevIconsGetFileTypeSymbol() . ' '
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

  function! Lightline_coc_hint() abort
    return b:coc_diagnostic_info['hint'] != 0 ? ' ' . b:coc_diagnostic_info['hint'] : ''
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

  function! NearestMethodOrFunction() abort
    if !Lightline_is_visible(140)
      return ''
    endif
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction

  AutoCmd User CocDiagnosticChange call lightline#update()
endif
" }}}3

" matchup {{{3
let g:matchup_matchparen_status_offscreen = 0
" }}}3

" nvim-colorizer {{{3
if dein#tap('nvim-colorizer.lua')
  lua require'colorizer'.setup()
endif
" }}}3

" quickr-preview {{{3
let g:quickr_preview_keymaps = 0

AutoCmd FileType qf nmap <silent> <buffer> p <Plug>(quickr_preview)
AutoCmd FileType qf nmap <silent> <buffer> q <Plug>(quickr_preview_qf_close)
" }}}3

" rainbow {{{3
if dein#tap('rainbow')
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
endif
" }}}3

" scrollbar {{{3
if dein#tap('scrollbar.nvim')
  AutoCmd BufEnter    * silent! lua require('scrollbar').show()
  AutoCmd BufLeave    * silent! lua require('scrollbar').clear()

  AutoCmd CursorMoved * silent! lua require('scrollbar').show()
  AutoCmd VimResized  * silent! lua require('scrollbar').show()

  AutoCmd FocusGained * silent! lua require('scrollbar').show()
  AutoCmd FocusLost   * silent! lua require('scrollbar').clear()
endif
" }}}3

" smartnumber {{{3
if dein#tap('smartnumber.vim')
  let g:snumber_enable_startup = 1
  let g:snumber_enable_relative = 1
  nnoremap <Leader>n :<C-u>SNToggle<CR>

  function! s:snumber_relative_toggle()
    if g:snumber_enable_relative == 1
      windo SNumbersTurnOffRelative
      let g:snumber_enable_relative = 0
    else
      windo SNumbersTurnOnRelative
      let g:snumber_enable_relative = 1
    endif
  endfunction

  command! SNToggle call <SID>snumber_relative_toggle()
endif
" }}}3

" vista {{{3
if dein#tap('vista.vim')
  let g:vista_default_executive = 'ctags'
  AutoCmd VimEnter * call vista#RunForNearestMethodOrFunction()
endif
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
if dein#tap('vim-bbye')
  nnoremap <silent> <Leader>d :<C-u>Bdelete!<CR>
endif
" }}}3

" capture {{{3
BulkAlterCommand cap[ture] Capture
AutoCmd FileType capture nnoremap <silent> <buffer> q :<C-u>quit<CR>
" }}}3

" dial {{{3
if dein#tap('dial.nvim')
  nmap <C-a>  <Plug>(dial-increment)
  nmap <C-x>  <Plug>(dial-decrement)
  vmap <C-a>  <Plug>(dial-increment)
  vmap <C-x>  <Plug>(dial-decrement)
  vmap g<C-a> <Plug>(dial-increment-additional)
  vmap g<C-x> <Plug>(dial-decrement-additional)
endif
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

" previm {{{3
let g:previm_open_cmd            = 'open -a "Vivaldi"'
let g:previm_disable_default_css = 1
let g:previm_custom_css_path     = '~/.config/previm/gfm.css'
" }}}3

" silicon {{{3
let g:silicon = {
\   'theme':           'Monokai Extended',
\   'background':      '#97A1AC',
\   'shadow-color':    '#555555',
\   'line-number':     v:false,
\   'round-corner':    v:true,
\   'window-controls': v:true,
\   'output':          '~/Downloads/silicon-{time:%Y-%m-%d-%H%M%S}.png',
\ }
" }}}3

" undotree {{{3
nnoremap <silent> <Leader>u :<C-u>UndotreeToggle<CR>
" }}}3

" which-key {{{3
if dein#tap('vim-which-key')
  nnoremap <silent> <Leader><CR>   :<C-u>WhichKey '<Leader>'<CR>
  nnoremap <silent> <dev><CR>      :<C-u>WhichKey '<dev>'<CR>
  nnoremap <silent> <fzf-p><CR>    :<C-u>WhichKey '<fzf-p>'<CR>
  nnoremap <silent> <t><CR>        :<C-u>WhichKey '<t>'<CR>
  nnoremap <silent> s<CR>          :<C-u>WhichKey 's'<CR>
  nnoremap <silent> <bookmark><CR> :<C-u>WhichKey '<bookmark>'<CR>
endif
" }}}3

" windowswap {{{3
let g:windowswap_map_keys = 0
nnoremap <silent> <Leader><C-w> :call WindowSwap#EasyWindowSwap()<CR>
" }}}3

" }}}2

" Develop {{{2

" quickrun {{{3
BulkAlterCommand r QuickRun

let g:quickrun_config = {
\ '_' : {
\   'outputter' : 'error',
\   'outputter/error/success' : 'buffer',
\   'outputter/error/error'   : 'quickfix',
\   'outputter/buffer/split'  : ':botright 15split',
\   'outputter/buffer/close_on_empty' : 1,
\ },
\ 'tsc' : {
\   'command': 'tsc',
\   'exec': ['%C --project . --noEmit --incremental --tsBuildInfoFile .git/.tsbuildinfo'],
\   'outputter' : 'quickfix',
\   'outputter/quickfix/errorformat' : '%+A %#%f %#(%l\,%c): %m,%C%m',
\ },
\ 'yq' : {
\   'exec': 'cat %s | yq eval --tojson',
\ },
\ 'yq-browser' : {
\   'exec': 'cat %s | yq eval --tojson',
\   'outputter' : 'browser',
\   'outputter/browser/name' : tempname() . '.json',
\ },
\ }

if has('nvim')
  let g:quickrun_config._.runner = 'neovim_job'
endif
" }}}3

" }}}2

" Removed Plugin {{{2

" " splitjoin {{{3
" let g:splitjoin_align             = 1
" let g:splitjoin_trailing_comma    = 1
" let g:splitjoin_ruby_curly_braces = 0
" let g:splitjoin_ruby_hanging_args = 0
" " }}}3

" " visual-multi {{{3
" let g:VM_set_statusline             = 0
" let g:VM_leader                     = '\'
" let g:VM_default_mappings           = 0
" let g:VM_sublime_mappings           = 0
" let g:VM_mouse_mappings             = 0
" let g:VM_extended_mappings          = 0
" let g:VM_no_meta_mappings           = 1
" let g:VM_reselect_first_insert      = 0
" let g:VM_reselect_first_always      = 0
" let g:VM_case_setting               = 'smart'
" let g:VM_pick_first_after_n_cursors = 0
" let g:VM_dynamic_synmaxcol          = 20
" let g:VM_disable_syntax_in_imode    = 0
" let g:VM_exit_on_1_cursor_left      = 0
" let g:VM_manual_infoline            = 1
"
" nmap <silent> (ctrln) <Plug>(VM-Find-Under)
" xmap <silent> <C-n>   <Plug>(VM-Find-Subword-Under)
"
" let g:VM_maps = {}
" "
" let g:VM_maps['Find Under']         = ''
" let g:VM_maps['Find Subword Under'] = ''
" let g:VM_maps['Skip Region']        = '<C-s>'
" let g:VM_maps['Remove Region']      = '<C-q>'
" let g:VM_maps['Start Regex Search'] = 'g/'
" let g:VM_maps['Select All']         = '<A-a>'
" let g:VM_maps['Add Cursor Down']    = '<A-S-j>'
" let g:VM_maps['Add Cursor Up']      = '<A-S-k>'
" let g:VM_maps['Select l']           = '<A-S-l>'
" let g:VM_maps['Select h']           = '<A-S-h>'
"
" let g:VM_maps['Find Next']          = ']'
" let g:VM_maps['Find Prev']          = '['
" let g:VM_maps['Goto Next']          = '}'
" let g:VM_maps['Goto Prev']          = '{'
" let g:VM_maps['Seek Next']          = '<C-d>'
" let g:VM_maps['Seek Prev']          = '<C-u>'
"
" let g:VM_maps['Surround']           = 'S'
" let g:VM_maps['D']                  = 'D'
" let g:VM_maps['J']                  = 'J'
" let g:VM_maps['Dot']                = '.'
" let g:VM_maps['c']                  = 'c'
" let g:VM_maps['C']                  = 'C'
" let g:VM_maps['Replace Pattern']    = 'R'
" " }}}3

" " ref {{{3
" BulkAlterCommand refe Ref<Space>refe
" " }}}3

" }}}2

" }}}1

" Correct Interference {{{1

" keymaps {{{ function! Set_default_keymap() abort let g:keymap = 'Default'
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

AutoCmd ColorScheme nord,onedark,iceberg highlight Normal       ctermfg=145  ctermbg=235  guifg=#ABB2BF guibg=#26282F
AutoCmd ColorScheme nord,onedark,iceberg highlight NormalNC     ctermfg=144  ctermbg=234  guifg=#ABB2BF guibg=#282C34
AutoCmd ColorScheme nord,onedark,iceberg highlight CursorColumn ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
AutoCmd ColorScheme nord,onedark,iceberg highlight CursorLine   ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
AutoCmd ColorScheme nord,onedark,iceberg highlight CursorLineNr ctermfg=253  ctermbg=NONE guifg=#DADADA guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight LineNr       ctermfg=241  ctermbg=NONE guifg=#626262 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight NonText      ctermfg=60   ctermbg=NONE guifg=#5F5F87 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Identifier   ctermfg=10   ctermbg=NONE guifg=#C0CA8E guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Search       ctermfg=68   ctermbg=232  guifg=NONE    guibg=#213F72
AutoCmd ColorScheme nord,onedark,iceberg highlight SignColumn   ctermfg=0    ctermbg=NONE guifg=#3B4252 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Todo         ctermfg=229  ctermbg=NONE guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Visual       ctermfg=NONE ctermbg=23   guifg=NONE    guibg=#1D4647
AutoCmd ColorScheme nord,onedark,iceberg highlight Folded       ctermfg=245  ctermbg=NONE guifg=#686f9a guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight DiffAdd      ctermfg=233  ctermbg=64   guifg=#C4C4C4 guibg=#456D4F
AutoCmd ColorScheme nord,onedark,iceberg highlight DiffDelete   ctermfg=233  ctermbg=95   guifg=#C4C4C4 guibg=#593535
AutoCmd ColorScheme nord,onedark,iceberg highlight DiffChange   ctermfg=233  ctermbg=143  guifg=#C4C4C4 guibg=#594D1A

" AutoCmd ColorScheme gruvbox-material highlight CursorColumn ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
" AutoCmd ColorScheme gruvbox-material highlight CursorLine   ctermfg=NONE ctermbg=236  guifg=NONE    guibg=#353535
" AutoCmd ColorScheme gruvbox-material highlight CursorLineNr ctermfg=253  ctermbg=NONE guifg=#DADADA guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight DiffAdd      ctermfg=233  ctermbg=64   guifg=#C4C4C4 guibg=#456D4F
" AutoCmd ColorScheme gruvbox-material highlight DiffChange   ctermfg=233  ctermbg=143  guifg=#C4C4C4 guibg=#594D1A
" AutoCmd ColorScheme gruvbox-material highlight DiffDelete   ctermfg=233  ctermbg=95   guifg=#C4C4C4 guibg=#593535
" AutoCmd ColorScheme gruvbox-material highlight Identifier   ctermfg=10   ctermbg=NONE guifg=#C0CA8E guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight LineNr       ctermfg=241  ctermbg=NONE guifg=#626262 guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight NonText      ctermfg=60   ctermbg=NONE guifg=#5F5F87 guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight Normal       ctermfg=145  ctermbg=235  guifg=#ABB2BF guibg=#26282F
" AutoCmd ColorScheme gruvbox-material highlight NormalNC     ctermfg=144  ctermbg=234  guifg=#ABB2BF guibg=#282C34
AutoCmd ColorScheme gruvbox-material highlight DiffText     ctermfg=NONE ctermbg=223  guifg=NONE    guibg=#716522
AutoCmd ColorScheme gruvbox-material highlight Folded       ctermfg=245  ctermbg=NONE guifg=#686f9a guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Search       ctermfg=68   ctermbg=232  guifg=NONE    guibg=#213F72
AutoCmd ColorScheme gruvbox-material highlight SignColumn   ctermfg=0    ctermbg=NONE guifg=#32302f guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Todo         ctermfg=229  ctermbg=NONE guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Visual       ctermfg=NONE ctermbg=23   guifg=NONE    guibg=#1D4647

" Gina (Vital.Vim.Buffer.ANSI)
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor0  ctermfg=0  guifg=#2E3440
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor1  ctermfg=1  guifg=#3B4252
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor2  ctermfg=2  guifg=#434C5E
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor3  ctermfg=3  guifg=#4C566A
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor4  ctermfg=4  guifg=#D8DEE9
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor5  ctermfg=5  guifg=#E5E9F0
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor6  ctermfg=6  guifg=#ECEFF4
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor7  ctermfg=7  guifg=#8FBCBB
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor8  ctermfg=8  guifg=#88C0D0
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor9  ctermfg=9  guifg=#81A1C1
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor10 ctermfg=10 guifg=#5E81AC
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor11 ctermfg=11 guifg=#BF616A
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor12 ctermfg=12 guifg=#D08770
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor13 ctermfg=13 guifg=#EBCB8B
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor14 ctermfg=14 guifg=#A3BE8C
AutoCmd ColorScheme nord,onedark,iceberg highlight AnsiColor15 ctermfg=15 guifg=#B48EAD

AutoCmd ColorScheme gruvbox-material highlight AnsiColor0  ctermfg=0  guifg=#2E3440
AutoCmd ColorScheme gruvbox-material highlight AnsiColor1  ctermfg=1  guifg=#32302f
AutoCmd ColorScheme gruvbox-material highlight AnsiColor2  ctermfg=2  guifg=#434C5E
AutoCmd ColorScheme gruvbox-material highlight AnsiColor3  ctermfg=3  guifg=#4C566A
AutoCmd ColorScheme gruvbox-material highlight AnsiColor4  ctermfg=4  guifg=#D8DEE9
AutoCmd ColorScheme gruvbox-material highlight AnsiColor5  ctermfg=5  guifg=#d4be98
AutoCmd ColorScheme gruvbox-material highlight AnsiColor6  ctermfg=6  guifg=#ECEFF4
AutoCmd ColorScheme gruvbox-material highlight AnsiColor7  ctermfg=7  guifg=#8FBCBB
AutoCmd ColorScheme gruvbox-material highlight AnsiColor8  ctermfg=8  guifg=#89b482
AutoCmd ColorScheme gruvbox-material highlight AnsiColor9  ctermfg=9  guifg=#7daea3
AutoCmd ColorScheme gruvbox-material highlight AnsiColor10 ctermfg=10 guifg=#5E81AC
AutoCmd ColorScheme gruvbox-material highlight AnsiColor11 ctermfg=11 guifg=#ea6962
AutoCmd ColorScheme gruvbox-material highlight AnsiColor12 ctermfg=12 guifg=#D08770
AutoCmd ColorScheme gruvbox-material highlight AnsiColor13 ctermfg=13 guifg=#d8a657
AutoCmd ColorScheme gruvbox-material highlight AnsiColor14 ctermfg=14 guifg=#a9b665
AutoCmd ColorScheme gruvbox-material highlight AnsiColor15 ctermfg=15 guifg=#d3869b

" Plugin highlight
" AutoCmd ColorScheme nord,onedark,iceberg highlight ShotFBlank              ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
" AutoCmd ColorScheme nord,onedark,iceberg highlight ShotFGraph              ctermfg=209  ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight EasyMotionMoveHLDefault ctermfg=9    ctermbg=236  cterm=underline,bold guifg=#E98989 guibg=#303030 gui=underline,bold
AutoCmd ColorScheme nord,onedark,iceberg highlight EftChar                 ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme nord,onedark,iceberg highlight EftSubChar              ctermfg=68   ctermbg=NONE cterm=underline,bold guifg=#5F87D7 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme nord,onedark,iceberg highlight ExtraWhiteSpace         ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989
AutoCmd ColorScheme nord,onedark,iceberg highlight FloatermNF              ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#161821
AutoCmd ColorScheme nord,onedark,iceberg highlight GitRebase               ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#1F1F20
AutoCmd ColorScheme nord,onedark,iceberg highlight HighlightedyankRegion   ctermfg=1    ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight MatchParen              ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme nord,onedark,iceberg highlight MatchParenCur           ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme nord,onedark,iceberg highlight MatchWord               ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme nord,onedark,iceberg highlight MatchWordCur            ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme nord,onedark,iceberg highlight QuickScopePrimary       ctermfg=68   ctermbg=NONE                      guifg=#5F87D7 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight QuickScopeSecondary     ctermfg=72   ctermbg=NONE                      guifg=#5FAFAF guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight YankRoundRegion         ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A
AutoCmd ColorScheme nord,onedark,iceberg highlight ZenSpace                ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989

AutoCmd ColorScheme nord,onedark,iceberg highlight CocErrorSign            ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight CocWarningSign          ctermfg=214  ctermbg=NONE                      guifg=#FFAF00 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight CocInfoSign             ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE

AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Untracked      ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Modified       ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Staged         ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Deleted        ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Renamed        ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight Defx_git_Unmerged       ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE

AutoCmd ColorScheme nord,onedark,iceberg highlight FernGitStatusWorktree   ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight FernGitStatusIndex      ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight FernGitStatusUnmerged   ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight FernGitStatusUntracked  ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme nord,onedark,iceberg highlight link FernGitStatusIgnored Comment

AutoCmd ColorScheme nord,onedark,iceberg highlight ScrollView              ctermbg=159                                                  guibg=#D0D0D0

" TreeSitter
AutoCmd ColorScheme nord,onedark,iceberg highlight link TSPunctBracket Normal

" AutoCmd ColorScheme gruvbox-material highlight QuickScopePrimary       ctermfg=68   ctermbg=NONE                      guifg=#5F87D7 guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight QuickScopeSecondary     ctermfg=72   ctermbg=NONE                      guifg=#5FAFAF guibg=NONE
" AutoCmd ColorScheme gruvbox-material highlight ShotFBlank              ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
" AutoCmd ColorScheme gruvbox-material highlight ShotFGraph              ctermfg=209  ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight BrightestHighlight      ctermfg=NONE ctermbg=236                       guifg=NONE    guibg=#32302f
AutoCmd ColorScheme gruvbox-material highlight EasyMotionMoveHLDefault ctermfg=9    ctermbg=236  cterm=underline,bold guifg=#E98989 guibg=#303030 gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight EftChar                 ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight EftSubChar              ctermfg=68   ctermbg=NONE cterm=underline,bold guifg=#5F87D7 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight ExtraWhiteSpace         ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989
AutoCmd ColorScheme gruvbox-material highlight FloatermNF              ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#161821
AutoCmd ColorScheme gruvbox-material highlight GitRebase               ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#1F1F20
AutoCmd ColorScheme gruvbox-material highlight HighlightedyankRegion   ctermfg=1    ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight MatchParen              ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme gruvbox-material highlight MatchParenCur           ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme gruvbox-material highlight MatchWord               ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme gruvbox-material highlight MatchWordCur            ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme gruvbox-material highlight YankRoundRegion         ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A
AutoCmd ColorScheme gruvbox-material highlight ZenSpace                ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989

AutoCmd ColorScheme gruvbox-material highlight CocErrorSign            ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocWarningSign          ctermfg=214  ctermbg=NONE                      guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocInfoSign             ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE

AutoCmd ColorScheme gruvbox-material highlight Defx_git_Untracked      ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Defx_git_Modified       ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Defx_git_Staged         ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Defx_git_Deleted        ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Defx_git_Renamed        ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Defx_git_Unmerged       ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE

AutoCmd ColorScheme gruvbox-material highlight FernGitStatusWorktree   ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight FernGitStatusIndex      ctermfg=2    ctermbg=NONE                      guifg=#b4be82 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight FernGitStatusUnmerged   ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight FernGitStatusUntracked  ctermfg=1    ctermbg=NONE                      guifg=#e27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight link FernGitStatusIgnored Comment

AutoCmd ColorScheme gruvbox-material highlight HlSearchLensCur         ctermfg=68   ctermbg=232                       guifg=NONE    guibg=#213F72
AutoCmd ColorScheme gruvbox-material highlight HlSearchLens            ctermfg=68   ctermbg=232                       guifg=#889eb5 guibg=#283642
AutoCmd ColorScheme gruvbox-material highlight HlSearchCur             ctermfg=68   ctermbg=232                       guifg=NONE    guibg=#213F72

AutoCmd ColorScheme gruvbox-material highlight ScrollView              ctermbg=159                                                  guibg=#D0D0D0

" TreeSitter
AutoCmd ColorScheme gruvbox-material highlight link TSPunctBracket Normal

" }}}2

" nord {{{2

let g:nord_uniform_diff_background = 1
colorscheme nord

" lightline highlight {{{3
if dein#tap('lightline.vim')
  let s:nord0       = ['#3B4252', 0]
  let s:nord1       = ['#BF616A', 1]
  let s:nord2       = ['#A3BE8C', 2]
  let s:nord3       = ['#EBCB8B', 3]
  let s:nord4       = ['#81A1C1', 4]
  let s:nord5       = ['#B48EAD', 5]
  let s:nord6       = ['#88C0D0', 6]
  let s:nord7       = ['#E5E9F0', 7]
  let s:nord8       = ['#4C566A', 8]
  let s:nord9       = ['#B04B57', 9]
  let s:nord10      = ['#93B379', 10]
  let s:nord11      = ['#D08770', 11]
  let s:nord12      = ['#5E81AC', 12]
  let s:nord13      = ['#A4799D', 13]
  let s:nord14      = ['#8FBCBB', 14]
  let s:nord15      = ['#ECEFF4', 15]
  " let s:white       = ['#AFAFAF', 145]
  " let s:black       = ['#262626', 235]
  let s:grey        = ['#3A3A3A', 237]
  " let s:red         = ['#FF5F87', 204]
  " let s:blue        = ['#00AFFF', 39]
  " let s:green       = ['#75A174', 108]
  " let s:yellow      = ['#D7AF87', 180]
  " let s:orange      = ['#D78700', 172]
  let s:blue_green  = ['#00AFAF', 37 ]

  let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

  let s:p.normal.left = [
  \ [s:nord0,      s:nord4],
  \ [s:nord7,      s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:nord4,      s:grey ],
  \ ]

  let s:p.insert.left = [
  \ [s:nord0,      s:nord3 ],
  \ [s:nord7,      s:grey  ],
  \ [s:blue_green, s:grey  ],
  \ [s:nord4,      s:grey  ],
  \]

  let s:p.visual.left = [
  \ [s:nord0,      s:nord5],
  \ [s:nord7,      s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:nord4,      s:grey ],
  \ ]

  let s:p.replace.left = [
  \ [s:nord0,      s:nord1],
  \ [s:nord7,      s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:nord4,      s:grey ],
  \ ]

  let s:p.inactive.left = [
  \ [s:blue_green, s:grey],
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \ ]

  let s:p.normal.right   = [[s:nord7, s:nord0],   [s:nord7, s:grey ]]
  let s:p.inactive.right = [[s:nord0, s:nord7],   [s:nord0, s:nord7]]
  let s:p.insert.right   = [[s:nord0, s:nord3],   [s:nord7, s:grey ]]
  let s:p.replace.right  = [[s:nord0, s:nord1],   [s:nord7, s:grey ]]
  let s:p.visual.right   = [[s:nord0, s:nord5],   [s:nord7, s:grey ]]

  let s:p.normal.middle   = [[s:nord7, s:nord0]]
  let s:p.inactive.middle = [[s:nord7, s:grey]]

  let s:p.tabline.left   = [[s:nord7, s:nord8]]
  let s:p.tabline.tabsel = [[s:nord0, s:nord4]]
  let s:p.tabline.middle = [[s:nord7, s:nord0]]
  let s:p.tabline.right  = [[s:nord7, s:nord8]]

  let s:coc_diagnostic = [
  \ [s:grey, s:nord1 ],
  \ [s:grey, s:nord11],
  \ [s:grey, s:nord3 ],
  \ [s:grey, s:nord4 ],
  \ [s:grey, s:nord2 ],
  \ ]

  let s:p.normal.error        = s:coc_diagnostic[0:0]
  let s:p.insert.error        = s:coc_diagnostic[0:0]
  let s:p.replace.error       = s:coc_diagnostic[0:0]
  let s:p.visual.error        = s:coc_diagnostic[0:0]
  let s:p.normal.warning      = s:coc_diagnostic[1:1]
  let s:p.insert.warning      = s:coc_diagnostic[1:1]
  let s:p.replace.warning     = s:coc_diagnostic[1:1]
  let s:p.visual.warning      = s:coc_diagnostic[1:1]
  let s:p.normal.information  = s:coc_diagnostic[2:2]
  let s:p.insert.information  = s:coc_diagnostic[2:2]
  let s:p.replace.information = s:coc_diagnostic[2:2]
  let s:p.visual.information  = s:coc_diagnostic[2:2]
  let s:p.normal.hint         = s:coc_diagnostic[2:2]
  let s:p.insert.hint         = s:coc_diagnostic[2:2]
  let s:p.replace.hint        = s:coc_diagnostic[2:2]
  let s:p.visual.hint         = s:coc_diagnostic[2:2]
  let s:p.normal.ok           = s:coc_diagnostic[3:3]
  let s:p.insert.ok           = s:coc_diagnostic[3:3]
  let s:p.replace.ok          = s:coc_diagnostic[3:3]
  let s:p.visual.ok           = s:coc_diagnostic[3:3]

  let g:lightline#colorscheme#nord#palette = lightline#colorscheme#flatten(s:p)
endif

" }}}3

" }}}2

" gruvbox-material {{{2

let g:gruvbox_material_background             = 'hard'
let g:gruvbox_material_transparent_background = 1
let g:gruvbox_material_enable_bold            = 1
let g:gruvbox_material_disable_italic_comment = 1

colorscheme gruvbox-material

" lightline highlight {{{3
if dein#tap('lightline.vim')
  let s:gruvbox0   = ['#32302f', 0]
  let s:gruvbox1   = ['#ea6962', 1]
  let s:gruvbox2   = ['#a9b665', 2]
  let s:gruvbox3   = ['#d8a657', 3]
  let s:gruvbox4   = ['#7daea3', 4]
  let s:gruvbox5   = ['#d3869b', 5]
  let s:gruvbox6   = ['#89b482', 6]
  let s:gruvbox7   = ['#d4be98', 7]
  let s:grey       = ['#3A3A3A', 237]
  let s:blue_green = ['#00AFAF', 37 ]
  let s:warning    = ['#FFAF60', 214]
  let s:info       = ['#FFFFAF', 229]

  let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

  let s:p.normal.left = [
  \ [s:gruvbox0,   s:gruvbox4],
  \ [s:gruvbox7,   s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:gruvbox4,   s:grey ],
  \ ]

  let s:p.insert.left = [
  \ [s:gruvbox0,   s:gruvbox3 ],
  \ [s:gruvbox7,   s:grey  ],
  \ [s:blue_green, s:grey  ],
  \ [s:gruvbox4,   s:grey  ],
  \]

  let s:p.visual.left = [
  \ [s:gruvbox0,   s:gruvbox5],
  \ [s:gruvbox7,   s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:gruvbox4,   s:grey ],
  \ ]

  let s:p.replace.left = [
  \ [s:gruvbox0,   s:gruvbox1],
  \ [s:gruvbox7,   s:grey ],
  \ [s:blue_green, s:grey ],
  \ [s:gruvbox4,   s:grey ],
  \ ]

  let s:p.inactive.left = [
  \ [s:blue_green, s:grey],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.normal.right   = [[s:gruvbox0, s:gruvbox4],   [s:gruvbox7, s:grey ]]
  let s:p.inactive.right = [[s:gruvbox0, s:gruvbox7],   [s:gruvbox0, s:gruvbox7]]
  let s:p.insert.right   = [[s:gruvbox0, s:gruvbox3],   [s:gruvbox7, s:grey ]]
  let s:p.replace.right  = [[s:gruvbox0, s:gruvbox1],   [s:gruvbox7, s:grey ]]
  let s:p.visual.right   = [[s:gruvbox0, s:gruvbox5],   [s:gruvbox7, s:grey ]]

  let s:p.normal.middle   = [[s:gruvbox7, s:gruvbox0]]
  let s:p.inactive.middle = [[s:gruvbox7, s:grey]]

  let s:p.tabline.left   = [[s:gruvbox7, s:grey]]
  let s:p.tabline.tabsel = [[s:gruvbox0, s:gruvbox4]]
  let s:p.tabline.middle = [[s:gruvbox7, s:gruvbox0]]
  let s:p.tabline.right  = [[s:gruvbox7, s:grey]]

  let s:coc_diagnostic = [
  \ [s:grey, s:gruvbox1],
  \ [s:grey, s:warning],
  \ [s:grey, s:info],
  \ [s:grey, s:gruvbox4],
  \ ]

  let s:p.normal.error        = s:coc_diagnostic[0:0]
  let s:p.insert.error        = s:coc_diagnostic[0:0]
  let s:p.replace.error       = s:coc_diagnostic[0:0]
  let s:p.visual.error        = s:coc_diagnostic[0:0]
  let s:p.normal.warning      = s:coc_diagnostic[1:1]
  let s:p.insert.warning      = s:coc_diagnostic[1:1]
  let s:p.replace.warning     = s:coc_diagnostic[1:1]
  let s:p.visual.warning      = s:coc_diagnostic[1:1]
  let s:p.normal.information  = s:coc_diagnostic[2:2]
  let s:p.insert.information  = s:coc_diagnostic[2:2]
  let s:p.replace.information = s:coc_diagnostic[2:2]
  let s:p.visual.information  = s:coc_diagnostic[2:2]
  let s:p.normal.hint         = s:coc_diagnostic[2:2]
  let s:p.insert.hint         = s:coc_diagnostic[2:2]
  let s:p.replace.hint        = s:coc_diagnostic[2:2]
  let s:p.visual.hint         = s:coc_diagnostic[2:2]
  let s:p.normal.ok           = s:coc_diagnostic[3:3]
  let s:p.insert.ok           = s:coc_diagnostic[3:3]
  let s:p.replace.ok          = s:coc_diagnostic[3:3]
  let s:p.visual.ok           = s:coc_diagnostic[3:3]

  let g:lightline#colorscheme#gruvbox#palette = lightline#colorscheme#flatten(s:p)
endif
" }}}3

" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
