" Plugin Manager {{{1

" Select LSP {{{2
let s:enable_coc      = v:true
let s:enable_vim_lsp  = v:false
let s:enable_nvim_lsp = v:false

let s:enable_ddc = v:false
let s:enable_cmp = v:false
" }}}2

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
let g:dein#lazy_rplugins            = 1
let g:dein#install_github_api_token = $DEIN_GITHUB_TOKEN
" }}}2

" Load Plugin {{{2
if dein#load_state(s:DEIN_BASE_PATH)
  call dein#begin(s:DEIN_BASE_PATH)

  " Dein {{{3
  call dein#add('Shougo/dein.vim')

  call dein#add('haya14busa/dein-command.vim', {'on_cmd': ['Dein']})
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja')
  " }}}3

  " denops {{{3
  call dein#add('vim-denops/denops.vim')
  " }}}3

  " IDE {{{3
  if s:enable_coc
    call dein#add('neoclide/coc.nvim', {'rev': 'master', 'build': 'yarn install --frozen-lockfile'})
    " call dein#add('neoclide/coc.nvim', {'rev': 'release'})
  endif

  if s:enable_ddc
    call dein#add('Shougo/ddc.vim', {'on_event': ['InsertEnter'], 'hook_post_source': 'call SetupDdc()'})

    call dein#add('LumaKernel/ddc-file')
    call dein#add('LumaKernel/ddc-tabnine')
    call dein#add('Shougo/ddc-around')
    call dein#add('matsui54/ddc-buffer')

    call dein#add('Shougo/ddc-matcher_head')
    call dein#add('Shougo/ddc-sorter_rank')
    call dein#add('tani/ddc-fuzzy')

    call dein#add('Shougo/pum.vim')
    call dein#add('matsui54/denops-popup-preview.vim')
  endif

  if s:enable_vim_lsp
    call dein#add('prabirshrestha/vim-lsp')
    call dein#add('mattn/vim-lsp-settings')

    if s:enable_ddc
      call dein#add('shun/ddc-vim-lsp')
    endif
  endif

  if s:enable_nvim_lsp
    call dein#add('neovim/nvim-lspconfig')
    call dein#add('williamboman/nvim-lsp-installer')

    call dein#add('tami5/lspsaga.nvim')
  endif

  if s:enable_cmp
    call dein#add('hrsh7th/nvim-cmp')
    call dein#add('hrsh7th/vim-vsnip')

    call dein#add('hrsh7th/cmp-nvim-lsp')
    call dein#add('hrsh7th/cmp-buffer')
    call dein#add('quangnguyen30192/cmp-nvim-ultisnips')
  endif

  " call dein#add('Shougo/neco-vim')
  " call dein#add('Shougo/ddc-cmdline-history')

  " call dein#add('tsuyoshicho/vim-efm-langserver-settings')

  " call dein#add('hrsh7th/vim-vsnip-integ')
  " call dein#add('kitagry/asyncomplete-tabnine.vim', {'build': './install.sh'})
  " call dein#add('prabirshrestha/asyncomplete-lsp.vim')
  " call dein#add('prabirshrestha/asyncomplete.vim')
  " call dein#add('wellle/tmux-complete.vim')

  " call dein#add('github/copilot.vim')
  " }}}3

  " IME {{{3
  call dein#add('vim-skk/skkeleton', {'on_event': ['InsertEnter'], 'hook_post_source': 'call SetupSkkeleton()'})
  " }}}3

  " Language {{{3
  " call dein#add('HerringtonDarkholme/yats.vim')
  " call dein#add('chr4/nginx.vim')
  " call dein#add('hail2u/vim-css3-syntax')
  " call dein#add('jparise/vim-graphql', {'on_ft': ['graphql']})
  " call dein#add('leafgarland/typescript-vim')
  " call dein#add('mechatroner/rainbow_csv')
  " call dein#add('othree/yajs.vim')
  " call dein#add('peitalin/vim-jsx-typescript')
  " call dein#add('plasticboy/vim-markdown', {'on_ft': ['markdown']})
  " call dein#add('posva/vim-vue')
  " call dein#add('rhysd/vim-fixjson', {'on_ft': ['json']})
  " call dein#add('styled-components/vim-styled-components')
  " call dein#add('tpope/vim-rails')
  " call dein#add('yardnsm/vim-import-cost', {'build': 'npm install'})
  call dein#add('elzr/vim-json', {'on_ft': ['json']})
  call dein#add('heavenshell/vim-jsdoc', {'on_ft': ['typescript', 'typescriptreact', 'javascript'], 'build': 'make install'})
  call dein#add('pantharshit00/vim-prisma', {'on_ft': ['prisma'], 'merge_ftdetect': v:true})

  if has('nvim')
    call dein#add('nvim-treesitter/nvim-treesitter')

    " call dein#add('David-Kunz/treesitter-unit')
    " call dein#add('code-biscuits/nvim-biscuits')
    " call dein#add('haringsrob/nvim_context_vt')
    " call dein#add('lukas-reineke/indent-blankline.nvim')
    " call dein#add('nvim-treesitter/nvim-treesitter-refactor')
    " call dein#add('nvim-treesitter/nvim-treesitter-textobjects')
    " call dein#add('romgrk/nvim-treesitter-context')
    call dein#add('JoosepAlviste/nvim-ts-context-commentstring')
    call dein#add('p00f/nvim-ts-rainbow')
  endif
  " }}}3

  " Git {{{3
  " call dein#add('cohama/agit.vim')
  " call dein#add('hotwatermorning/auto-git-diff')
  " call dein#add('rhysd/conflict-marker.vim')
  " call dein#add('tpope/vim-fugitive')
  " call dein#add('wting/gitsessions.vim', {'on_cmd': ['GitSessionSave', 'GitSessionLoad']})
  call dein#add('lambdalisue/gina.vim')

  if has('nvim')
    " call dein#add('APZelos/blamer.nvim')
    " call dein#add('f-person/git-blame.nvim')
    " call dein#add('lewis6991/gitsigns.nvim')
    " call dein#add('rhysd/git-messenger.vim')
  endif
  " }}}3

  " Fuzzy Finder {{{3
  " call dein#add('Shougo/denite.nvim')

  call dein#add('junegunn/fzf', {'build': './install --bin'})
  " call dein#add('junegunn/fzf.vim')
  " call dein#add('antoinemadec/coc-fzf', {'rev': 'release'})

  if isdirectory(expand('~/repos/github.com/yuki-yano/fzf-preview.vim'))
    call dein#add('~/repos/github.com/yuki-yano/fzf-preview.vim')
  endif

  " if isdirectory(expand('~/workspace/coc-ultisnips-select'))
  "   call dein#add('~/workspace/coc-ultisnips-select')
  " endif

  " call dein#add('yuki-yano/fzf-preview.vim', {'rev': 'release/rpc'})

  if has('nvim')
    " call dein#add('nvim-lua/telescope.nvim')
    " call dein#add('kyazdani42/nvim-web-devicons')
  endif
  " }}}3

  " filer {{{3
  call dein#add('lambdalisue/fern.vim', {'on_cmd': ['Fern'], 'depends': ['fern-git-status.vim', 'fern-renderer-nerdfont.vim', 'nerdfont.vim', 'fern-preview.vim']})

  " call dein#add('LumaKernel/fern-mapping-fzf.vim')
  call dein#add('LumaKernel/fern-mapping-reload-all.vim', {'depends': ['fern.vim']})
  call dein#add('lambdalisue/fern-git-status.vim', {'lazy': 1, 'hook_post_source': 'call fern_git_status#init()'})
  call dein#add('lambdalisue/fern-renderer-nerdfont.vim', {'lazy': 1})
  call dein#add('lambdalisue/nerdfont.vim', {'lazy': 1})
  call dein#add('yuki-yano/fern-preview.vim', {'lazy': 1})

  if has('nvim')
    " call dein#add('Shougo/defx.nvim')
    " call dein#add('kristijanhusak/defx-icons')
    " call dein#add('kristijanhusak/defx-git')
    " call dein#add('kyazdani42/nvim-tree.lua')
  endif
  " }}}3

  " textobj & operator {{{3
  call dein#add('machakann/vim-sandwich', {'depends': ['vim-textobj-entire', 'vim-textobj-line', 'vim-textobj-functioncall', 'vim-textobj-url', 'vim-textobj-cursor-context']}) " ib, ab, is, as
  call dein#add('machakann/vim-swap') " g< g> gs i, a,

  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-operator-user')

  " call dein#add('kana/vim-textobj-fold') " iz az
  " call dein#add('kana/vim-textobj-indent') " ii ai
  " call dein#add('rhysd/vim-textobj-ruby') " ir ar
  " call dein#add('romgrk/equal.operator') " i=h a=h i=l a=l
  call dein#add('kana/vim-textobj-entire', {'on_map': {'ox': '<Plug>(textobj-entire'}}) " ie ae
  call dein#add('kana/vim-textobj-line', {'on_map': {'ox': '<Plug>(textobj-line'}}) " al il
  call dein#add('machakann/vim-textobj-functioncall', {'on_map': {'ox': '<Plug>(textobj-functioncall'}}) " if af ig ag
  call dein#add('mattn/vim-textobj-url', {'on_map': {'ox': '<Plug>(textobj-url'}}) " iu au
  call dein#add('thinca/vim-textobj-between', {'on_map': {'ox': '<Plug>(textobj-between'}}) " i{char} a{char}
  call dein#add('yuki-yano/vim-textobj-cursor-context', {'on_map': {'ox': '<Plug>(textobj-cursorcontext'}}) " ic ac

  call dein#add('mopp/vim-operator-convert-case', {'on_map': ['<Plug>(operator-convert-case']}) " cy
  call dein#add('yuki-yano/vim-operator-replace', {'on_map': ['<Plug>(operator-replace']})  " _
  " }}}3

  " Edit & Move & Search {{{3
  " call dein#add('AndrewRadev/splitjoin.vim')
  " call dein#add('AndrewRadev/tagalong.vim')
  " call dein#add('deris/vim-shot-f')
  " call dein#add('easymotion/vim-easymotion')
  " call dein#add('haya14busa/incsearch.vim')
  " call dein#add('haya14busa/is.vim')
  " call dein#add('haya14busa/vim-metarepeat')
  " call dein#add('hrsh7th/vim-seak')
  " call dein#add('inkarkat/vim-EnhancedJumps')
  " call dein#add('kana/vim-smartword', {'on_map': ['<Plug>']})
  " call dein#add('lambdalisue/reword.vim')
  " call dein#add('mg979/vim-visual-multi', {'rev': 'test'})
  " call dein#add('mtth/scratch.vim')
  " call dein#add('osyo-manga/vim-trip')
  " call dein#add('rhysd/accelerated-jk')
  " call dein#add('t9md/vim-choosewin')
  " call dein#add('t9md/vim-textmanip', {'on_map': ['<Plug>']})
  " call dein#add('tomtom/tcomment_vim')
  " call dein#add('tpope/vim-commentary')
  " call dein#add('unblevable/quick-scope')
  " call dein#add('vim-scripts/Align')
  " call dein#add('yuki-yano/zero.vim')
  call dein#add('Bakudankun/BackAndForward.vim', {'on_map': ['<Plug>(backandforward-']})
  call dein#add('LeafCage/yankround.vim')
  call dein#add('MattesGroeger/vim-bookmarks')
  call dein#add('SirVer/ultisnips', {'on_ft': ['snippets'], 'on_event': ['InsertEnter']})
  call dein#add('cohama/lexima.vim', {'rev': 'dev', 'on_event': ['InsertEnter', 'CmdlineEnter'], 'hook_post_source': 'call SetupLexima()'})
  call dein#add('haya14busa/vim-asterisk', {'on_map': ['<Plug>']})
  call dein#add('haya14busa/vim-edgemotion', {'on_map': ['<Plug>']})
  call dein#add('hrsh7th/vim-eft', {'on_map': {'nox': '<Plug>'}})
  call dein#add('hrsh7th/vim-searchx')
  call dein#add('junegunn/vim-easy-align', {'on_map': ['<Plug>(EasyAlign)']})
  call dein#add('lambdalisue/vim-backslash', {'on_ft': ['vim']})
  call dein#add('mattn/vim-maketable', {'on_cmd': ['MakeTable']})
  call dein#add('mhinz/vim-grepper', {'on_cmd': ['Grepper']})
  call dein#add('monaqa/dps-dial.vim')
  call dein#add('osyo-manga/vim-anzu', {'on_map': ['<Plug>']})
  call dein#add('osyo-manga/vim-jplus', {'on_map': ['<Plug>']})
  call dein#add('terryma/vim-expand-region', {'on_map': ['<Plug>(expand_region_']})
  call dein#add('thinca/vim-qfreplace', {'on_cmd': ['Qfreplace']})
  call dein#add('tommcdo/vim-exchange', {'on_map': ['<Plug>(Exchange']})
  call dein#add('tpope/vim-repeat')
  call dein#add('tyru/caw.vim')

  if isdirectory(expand('~/repos/github.com/yuki-yano/fuzzy-motion.vim'))
    call dein#add('~/repos/github.com/yuki-yano/fuzzy-motion.vim')
  endif

  if has('nvim')
    " call dein#add('b3nj5m1n/kommentary')
    " call dein#add('gabrielpoca/replacer.nvim')
    " call dein#add('ggandor/lightspeed.nvim')
    " call dein#add('monaqa/dial.nvim')
    " call dein#add('numToStr/Comment.nvim')
    " call dein#add('phaazon/hop.nvim')
    " call dein#add('rmagatti/auto-session')
    " call dein#add('windwp/nvim-spectre')
    " call dein#add('winston0410/smart-cursor.nvim')
    " call dein#add('yuki-yano/zero.nvim')
    call dein#add('booperlv/nvim-gomove')
    call dein#add('kevinhwang91/nvim-hlslens')
    call dein#add('nacro90/numb.nvim')
    call dein#add('windwp/nvim-ts-autotag')
  endif
  " }}}3

  " Appearance {{{3
  " call dein#add('RRethy/vim-hexokinase', {'build': 'make hexokinase'})
  " call dein#add('Yggdroot/indentLine')
  " call dein#add('andymass/vim-matchup')
  " call dein#add('luochen1990/rainbow')
  " call dein#add('mhinz/vim-startify')
  " call dein#add('miyakogi/seiya.vim')
  " call dein#add('ntpeters/vim-better-whitespace')
  " call dein#add('obcat/vim-highlightedput', {'on_map': ['<Plug>']})
  " call dein#add('ronakg/quickr-preview.vim')
  " call dein#add('wellle/context.vim')
  " call dein#add('yuttie/comfortable-motion.vim')
  call dein#add('itchyny/lightline.vim')
  call dein#add('lambdalisue/glyph-palette.vim')
  call dein#add('lambdalisue/readablefold.vim')
  call dein#add('machakann/vim-highlightedundo')
  call dein#add('machakann/vim-highlightedyank', {'on_event': ['TextYankPost']})
  call dein#add('mopp/smartnumber.vim')
  call dein#add('rbtnn/vim-layout')
  call dein#add('ryanoasis/vim-devicons')

  if has('nvim')
    " call dein#add('Xuyuanp/scrollbar.nvim')
    " call dein#add('dstein64/nvim-scrollview', {'on_event': ['WinScrolled']})
    " call dein#add('glepnir/indent-guides.nvim')
    " call dein#add('karb94/neoscroll.nvim')
    " call dein#add('vuki656/package-info.nvim')
    " call dein#add('windwp/floatline.nvim')
    call dein#add('folke/todo-comments.nvim')
    call dein#add('kevinhwang91/nvim-bqf', {'on_ft': ['qf']})
    call dein#add('kwkarlwang/bufresize.nvim')
    call dein#add('norcalli/nvim-colorizer.lua')
    call dein#add('rcarriga/nvim-notify')
  endif
  " }}}3

  " tmux {{{3
  " call dein#add('christoomey/vim-tmux-navigator')
  if has('nvim')
    call dein#add('aserowy/tmux.nvim')
  endif
  " }}}3

  " Util {{{3
  " call dein#add('antoinemadec/FixCursorHold.nvim')
  " call dein#add('dhruvasagar/vim-table-mode')
  " call dein#add('dstein64/vim-startuptime')
  " call dein#add('kristijanhusak/vim-carbon-now-sh')
  " call dein#add('lambdalisue/vim-pager')
  " call dein#add('liuchengxu/vim-which-key')
  " call dein#add('osyo-manga/vim-brightest')
  " call dein#add('osyo-manga/vim-gift')
  " call dein#add('pocke/vim-automatic')
  " call dein#add('previm/previm')
  " call dein#add('thinca/vim-localrc')
  " call dein#add('thinca/vim-ref')
  " call dein#add('tyru/vim-altercmd')
  " call dein#add('voldikss/vim-floaterm', {'on_cmd': ['FloatermToggle']})
  call dein#add('AndrewRadev/linediff.vim')
  call dein#add('aiya000/aho-bakaup.vim', {'on_event': ['BufWritePre', 'FileWritePre']})
  call dein#add('farmergreg/vim-lastplace')
  call dein#add('glidenote/memolist.vim')
  call dein#add('iamcco/markdown-preview.nvim', {'on_cmd': 'MarkdownPreview', 'build': 'sh -c "cd app && yarn install"'})
  call dein#add('itchyny/vim-qfedit', {'on_ft': ['qf']})
  call dein#add('jsfaint/gen_tags.vim')
  call dein#add('kana/vim-niceblock')
  call dein#add('lambdalisue/guise.vim')
  call dein#add('lambdalisue/suda.vim', {'on_cmd': ['SudaRead', 'SudaWrite']})
  call dein#add('lambdalisue/vim-manpager', {'on_cmd': ['Man'], 'on_map': ['<Plug>']})
  call dein#add('liuchengxu/vista.vim', {'on_cmd': ['Vista']})
  call dein#add('mbbill/undotree', {'on_cmd': ['UndotreeToggle']})
  call dein#add('moll/vim-bbye', {'on_cmd': ['Bdelete']})
  call dein#add('segeljakt/vim-silicon', {'on_cmd': ['Silicon']})
  call dein#add('thinca/vim-editvar', {'on_cmd': ['Editvar']})
  call dein#add('thinca/vim-quickrun', {'depends': ['vim-quickrun-neovim-job', 'open-browser']})
  call dein#add('tyru/capture.vim')
  call dein#add('tyru/open-browser.vim', {'lazy': 1})
  call dein#add('vim-test/vim-test', {'lazy': 1})
  call dein#add('wesQ3/vim-windowswap', {'on_func': ['WindowSwap#EasyWindowSwap']})

  if has('nvim')
    " call dein#add('lambdalisue/edita.vim')
    " call dein#add('lewis6991/impatient.nvim')
    " call dein#add('notomo/cmdbuf.nvim')
    " call dein#add('nvim-lua/plenary.nvim')
    " call dein#add('nvim-lua/popup.nvim')
    " call dein#add('romgrk/fzy-lua-native', {'lazy': 1, 'build': 'make'})
    call dein#add('akinsho/toggleterm.nvim')
    call dein#add('gelguy/wilder.nvim', {'on_event': ['CmdlineEnter'], 'hook_post_source': 'call SetUpWilder()'})
    call dein#add('rcarriga/vim-ultest', {'on_cmd': ['Ultest', 'UltestNearest', 'UltestSummary'], 'depends': ['vim-test']})
  endif

  " if $ENABLE_WAKATIME == 1
  "   call dein#add('wakatime/vim-wakatime')
  " endif
  " }}}3

  " Develop {{{3
  " call dein#add('hrsh7th/vim-vital-vs')
  " call dein#add('vim-jp/vital.vim')
  call dein#add('rbtnn/vim-vimscript_lasterror', {'on_cmd': ['VimscriptLastError']})
  call dein#add('thinca/vim-prettyprint')

  if has('nvim')
    call dein#add('lambdalisue/vim-quickrun-neovim-job', {'lazy': 1})
  endif
  " }}}3

  " Color Theme {{{3
  " call dein#add('NLKNguyen/papercolor-theme')
  " call dein#add('arcticicestudio/nord-vim')
  " call dein#add('cocopon/iceberg.vim')
  " call dein#add('high-moctane/gaming.vim')
  " call dein#add('icymind/NeoSolarized')
  " call dein#add('joshdick/onedark.vim')
  " call dein#add('taohexxx/lightline-solarized')
  call dein#add('sainnhe/edge')
  call dein#add('sainnhe/gruvbox-material')
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

"-------------------------------------------------------------------------------------------|
"  Modes     | Normal | Insert | Command | Visual | Select | Operator | Terminal | Lang-Arg |
" [nore]map  |    @   |   -    |    -    |   @    |   @    |    @     |    -     |    -     |
" n[nore]map |    @   |   -    |    -    |   -    |   -    |    -     |    -     |    -     |
" n[orem]ap! |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    -     |
" i[nore]map |    -   |   @    |    -    |   -    |   -    |    -     |    -     |    -     |
" c[nore]map |    -   |   -    |    @    |   -    |   -    |    -     |    -     |    -     |
" v[nore]map |    -   |   -    |    -    |   @    |   @    |    -     |    -     |    -     |
" x[nore]map |    -   |   -    |    -    |   @    |   -    |    -     |    -     |    -     |
" s[nore]map |    -   |   -    |    -    |   -    |   @    |    -     |    -     |    -     |
" o[nore]map |    -   |   -    |    -    |   -    |   -    |    @     |    -     |    -     |
" t[nore]map |    -   |   -    |    -    |   -    |   -    |    -     |    @     |    -     |
" l[nore]map |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    @     |
"-------------------------------------------------------------------------------------------"

"" Leader
let g:mapleader = "\<Space>"
nnoremap <Leader>         <Nop>
xnoremap <Leader>         <Nop>
nnoremap <Plug>(t)        <Nop>
nmap     t                <Plug>(t)
nnoremap <Plug>(dev)      <Nop>
xnoremap <Plug>(dev)      <Nop>
nmap     m                <Plug>(dev)
xmap     m                <Plug>(dev)
nnoremap <Plug>(fzf-p)    <Nop>
xnoremap <Plug>(fzf-p)    <Nop>
nmap     ;                <Plug>(fzf-p)
xmap     ;                <Plug>(fzf-p)
nnoremap ;;               ;
xnoremap ;;               ;
nnoremap <Plug>(bookmark) <Nop>
nmap     M                <Plug>(bookmark)


"" Zero (Move beginning toggle)
nnoremap <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'
onoremap <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'
xnoremap <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'
nnoremap ^ 0
onoremap ^ 0
xnoremap ^ 0

"" BackSpace
imap <C-h> <BS>
cmap <C-h> <BS>

"" <C-w>
iunmap <C-w>

"" Buffer
nnoremap <C-q> <C-^>

"" Save and reload (for treesitter)
nnoremap <silent> <Leader>R <Cmd>update<CR><Cmd>e!<CR>

"" Yank
function! s:yank_without_indent() abort
  normal! gvy
  let content = getreg(v:register, 1, v:true)
  let leading = min(map(filter(copy(content), { _, v -> len(v) != 0 }), { _, v -> len(matchstr(v, '^\s*')) }))
  call map(content, { _, v -> v[leading :] })
  call setreg(v:register, content, getregtype(v:register))
endfunction
xnoremap gy <Esc><Cmd>call <SID>yank_without_indent()<CR>

"" Disable s
noremap s <Nop>

"" Save
nnoremap <silent> <Leader>w <Cmd>update<CR>
nnoremap <silent> <Leader>W <Cmd>update!<CR>

"" Automatically indent with i and A
nnoremap <expr> i len(getline('.')) ? "i" : "\"_cc"
nnoremap <expr> A len(getline('.')) ? "A" : "\"_cc"

" Ignore registers
nnoremap x "_x

"" tagjump
nnoremap <silent> s<C-]> <Cmd>wincmd ]<CR>
nnoremap <silent> v<C-]> <Cmd>vertical wincmd ]<CR>
nnoremap <silent> t<C-]> <Cmd>tab wincmd ]<CR>
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
" Configure in lexima
" noremap! <C-f> <Right>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"" Indent
nnoremap < <<
nnoremap > >>
xnoremap < <gv
xnoremap > >gv|

"" Window
if has('nvim')
  function! s:focus_floating() abort
    if !empty(nvim_win_get_config(win_getid()).relative)
      wincmd p
      return
    endif
    for winnr in range(1, winnr('$'))
      let winid = win_getid(winnr)
      let conf = nvim_win_get_config(winid)
      if conf.focusable && !empty(conf.relative)
        call win_gotoid(winid)
        return
      endif
    endfor
    execute "normal! \<C-w>\<C-w>"
  endfunction
  nnoremap <silent> <C-w><C-w> <Cmd>call <SID>focus_floating()<CR>
endif

"" Tab
nnoremap <silent> <Plug>(t)t <Cmd>tablast <Bar> tabedit<CR>
nnoremap <silent> <Plug>(t)d <Cmd>tabclose<CR>
nnoremap <silent> <Plug>(t)h <Cmd>tabprevious<CR>
nnoremap <silent> <Plug>(t)l <Cmd>tabnext<CR>
nnoremap <silent> <Plug>(t)m <C-w>T

"" resize
nnoremap <silent> <Left>  <Cmd>vertical resize -1<CR>
nnoremap <silent> <Right> <Cmd>vertical resize +1<CR>
nnoremap <silent> <Up>    <Cmd>resize -1<CR>
nnoremap <silent> <Down>  <Cmd>resize +1<CR>

"" Macro
nnoremap Q @q

"" regexp
nnoremap <Leader>r :<C-u>%s/\v//g<Left><Left><Left>
xnoremap <Leader>r "sy:%s/\v<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>

"" Clipboard
nnoremap <silent> sc <Cmd>call system("pbcopy", @") <Bar> echo "Copied \" register to OS clipboard"<CR>
nnoremap <silent> sp <Cmd>let @" = substitute(system("pbpaste"), "\n\+$", "", "") <Bar> echo "Copied from OS clipboard to \" register"<CR>
xnoremap <silent> sp <Cmd>let @" = substitute(system("pbpaste"), "\n\+$", "", "") <Bar> echo "Copied from OS clipboard to \" register"<CR>
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

  set pumblend=10
  set wildoptions+=pum
endif

"" Appearance
set belloff=all
set cmdheight=1
set concealcursor=nc
set conceallevel=2
set diffopt=internal,filler,algorithm:histogram,indent-heuristic,vertical
set display=lastline
set fillchars=diff:/
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
set nofoldenable
set foldmethod=manual

"" FileType
set viewoptions=cursor,folds
set suffixesadd=.js,.ts,.rb
if has('nvim')
  let g:do_filetype_lua    = 1
  let g:did_load_filetypes = 0
endif

"" sign
set signcolumn=yes

"" Diff
AutoCmd InsertLeave * if &l:diff | diffupdate | endif

"" Undo
set undofile
if has('nvim')
  set undodir=~/.cache/nvim/undo/
else
  set undodir=~/.cache/vim/undo/
endif

"" Swap
set swapfile
set directory=~/.cache/vim/swap/

"" Term
set mouse=a
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

"" Session
set sessionoptions=tabpages

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

" }}}2

" }}}1

" Command & Function {{{1

" Vital {{{2
function! s:has(list, value) abort
  return index(a:list, a:value) isnot -1
endfunction

function! s:_get_unary_caller(f) abort
  return type(a:f) is type(function('function')) ? function('call') : function('s:_call_string_expr')
endfunction

function! s:_call_string_expr(expr, args) abort
  return map([a:args[0]], a:expr)[0]
endfunction

function! s:sort(list, f) abort
  if type(a:f) is type(function('function'))
    return sort(a:list, a:f)
  else
    let s:sort_expr = a:f
    return sort(a:list, 's:_compare_by_string_expr')
  endif
endfunction

function! s:_compare_by_string_expr(a, b) abort
  return eval(s:sort_expr)
endfunction

function! s:uniq(list) abort
  return s:uniq_by(a:list, 'v:val')
endfunction

function! s:uniq_by(list, f) abort
  let l:Call  = s:_get_unary_caller(a:f)
  let applied = []
  let result  = []
  for x in a:list
    let y = l:Call(a:f, [x])
    if !s:has(applied, y)
      call add(result, x)
      call add(applied, y)
    endif
    unlet x y
  endfor
  return result
endfunction

function! s:product(lists) abort
  let result = [[]]
  for pool in a:lists
    let tmp = []
    for x in result
      let tmp += map(copy(pool), 'x + [v:val]')
    endfor
    let result = tmp
  endfor
  return result
endfunction

function! s:permutations(list, ...) abort
  if a:0 > 1
    throw 'vital: Data.List: too many arguments'
  endif
  let r = a:0 == 1 ? a:1 : len(a:list)
  if r > len(a:list)
    return []
  elseif r < 0
    throw 'vital: Data.List: {r} must be non-negative integer'
  endif
  let n = len(a:list)
  let result = []
  for indices in s:product(map(range(r), 'range(n)'))
    if len(s:uniq(indices)) == r
      call add(result, map(indices, 'a:list[v:val]'))
    endif
  endfor
  return result
endfunction

function! s:combinations(list, r) abort
  if a:r > len(a:list)
    return []
  elseif a:r < 0
    throw 'vital: Data.List: {r} must be non-negative integer'
  endif
  let n = len(a:list)
  let result = []
  for indices in s:permutations(range(n), a:r)
    if s:sort(copy(indices), 'a:a - a:b') == indices
      call add(result, map(indices, 'a:list[v:val]'))
    endif
  endfor
  return result
endfunction
" }}}2

" Move cursor last position {{{2
" AutoCmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
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
    autocmd CursorMoved,WinLeave * call <SID>leave()
  augroup END
endfunction

function! s:leave() abort
  setlocal nocursorline nocursorcolumn
  augroup highlight_cursor
    autocmd!
    autocmd CursorHold * call <SID>enter()
    autocmd WinEnter * call timer_start(<SID>highlight_cursor_wait, function('<SID>enter'))
  augroup END
endfunction

" AutoCmd VimEnter * call timer_start(<SID>highlight_cursor_wait, function('<SID>enter'))

function! s:cursor_highlight_toggle() abort
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
function! s:auto_mkdir(dir, force) abort
  if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(a:dir, 'p')
  endif
endfunction
" }}}2

" SyntaxHighlightToggle {{{2
" function! s:syntax_highlight_toggle() abort
"   if exists('g:syntax_on')
"     syntax off
"   else
"     syntax enable
"   endif
" endfunction

" command! SyntaxHighlightToggle call <SID>syntax_highlight_toggle()
" }}}2

" QuickfixToggle {{{2
function! s:quickfix_toggle() abort
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    botright copen
    " call g:Set_quickfix_keymap()
  endif
endfunction

command! QuickfixToggle call <SID>quickfix_toggle()
nnoremap <silent> <Leader>q <Cmd>QuickfixToggle<CR>
" }}}2

" ToggleLocationList {{{2
function! s:location_list_toggle() abort
  let _ = winnr('$')
  lclose
  if _ == winnr('$')
    botright lopen
    " call g:Set_locationlist_keymap()
  endif
endfunction

command! LocationListToggle call <SID>location_list_toggle()
nnoremap <silent> <Leader>l <Cmd>LocationListToggle<CR>
" }}}2

" HelpEdit & HelpView {{{2
function! s:option_to_help_view() abort
  setlocal buftype=help nomodifiable readonly
  setlocal nolist
  setlocal colorcolumn=
  setlocal conceallevel=2
endfunction

function! s:option_to_help_edit() abort
  setlocal buftype= modifiable noreadonly
  setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
  setlocal colorcolumn=+1
  setlocal conceallevel=0
endfunction

command! HelpView call <SID>option_to_help_view()
command! HelpEdit call <SID>option_to_help_edit()
" }}}2

" HighlightInfo {{{2
function! s:get_syn_id(transparent) abort
  let synid = synID(line('.'), col('.'), 1)
  return a:transparent ? synIDtrans(synid) : synid
endfunction

function! s:get_syn_name(synid) abort
  return synIDattr(a:synid, 'name')
endfunction

function! s:get_highlight_info() abort
  execute 'highlight ' . s:get_syn_name(s:get_syn_id(0))
  execute 'highlight ' . s:get_syn_name(s:get_syn_id(1))
endfunction

command! HighlightInfo call <SID>get_highlight_info()
" }}}2

" Jump plugin  {{{2
function! s:plugin_name(line) abort
  try
    if len(matchlist(a:line, 'dein#add(''\(.\{-}\)''.*)')) != 0
      let matches = matchlist(a:line, 'dein#add(''\(.\{-}\)''.*)')
      return split(matches[1], '/')[-1]
    elseif len(matchlist(a:line, 'dein#tap(''\(.*\)'')')) != 0
      let matches = matchlist(a:line, 'dein#tap(''\(.*\)'')')
      return matches[1]
    else
      echomsg 'Plugin not found'
      return ''
    endif
  catch
    echomsg 'Plugin not found'
  endtry
endfunction

function! s:plugin_line(plugin_name, lines, start_line, end_line) abort
  let i = a:start_line
  while i < a:end_line
    if match(a:lines[i], 'dein#add(''.\+/' . a:plugin_name . '''.*)') != -1 || match(a:lines[i], 'dein#tap(''' . a:plugin_name . ''')') != -1
      call setpos('.', [0, i + 1, 0, 0])
      return v:true
    endif

    let i = i + 1
  endwhile

  return v:false
endfunction

function! s:plugin_lines(plugin_name, lines) abort
  let lines = []
  let i = 1
  while i < line('$')
    if match(a:lines[i], 'dein#add(''.\+/' . a:plugin_name . '''.*)') != -1 || match(a:lines[i], 'dein#tap(''' . a:plugin_name . ''')') != -1
      call add(lines, { 'filename': expand('%'), 'lnum': i + 1, 'text': a:lines[i] })
    endif

    let i = i + 1
  endwhile

  call setqflist([], 'r', { 'items': lines })
  copen
endfunction

function! s:jump_plugin(mode) abort
  let line = getline('.')
  let plugin_name = <SID>plugin_name(line)

  if plugin_name ==# ''
    return
  endif

  let current_line = line('.')
  let lines = getline(0, line('$'))

  if a:mode ==# 'next'
    let result = <SID>plugin_line(plugin_name, lines, current_line, len(lines))
    if !result
      call <SID>plugin_line(plugin_name, lines, 1, current_line)
    endif
  elseif a:mode ==# 'prev'
    let result = <SID>plugin_line(plugin_name, lines, 1, current_line)
    if !result
      call <SID>plugin_line(plugin_name, lines, current_line, len(lines))
    endif
  elseif a:mode ==# 'qf'
    call <SID>plugin_lines(plugin_name, lines)
  endif
endfunction

command! UsePluginPrev     call <SID>jump_plugin('prev')
command! UsePluginNext     call <SID>jump_plugin('next')
command! UsePluginQuickFix call <SID>jump_plugin('qf')

nnoremap <silent> [p        <Cmd>UsePluginPrev<CR>
nnoremap <silent> ]p        <Cmd>UsePluginNext<CR>
nnoremap <silent> <Leader>p <Cmd>UsePluginQuickFix<CR>
" }}}2

" View JSON {{{2
command! JSON set ft=json | call CocAction('format')
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
  let g:fzf_preview_command = 'bat --color=always --style=plain --theme="Monokai Extended Light" ''{-1}'''

  let $FZF_PREVIEW_PREVIEW_BAT_THEME_BAK = $FZF_PREVIEW_PREVIEW_BAT_THEME
  let $FZF_PREVIEW_PREVIEW_BAT_THEME = 'Monokai Extended Light'
  let $FZF_DEFAULT_OPTS_BAK = $FZF_DEFAULT_OPTS
  " Edge
  let $FZF_DEFAULT_OPTS = '--color=fg:#4b505b,bg:#fafafa,hl:#5079be,fg+:#4b505b,bg+:#fafafa,hl+:#3a8b84,info:#88909f,prompt:#d05858,pointer:#b05ccc,marker:#608e32,spinner:#d05858,header:#3a8b84'
  " PaperColor
  " let $FZF_DEFAULT_OPTS= '--color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f,fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f,info:#4271ae,prompt:#8959a8,pointer:#d7005f,marker:#4271ae,spinner:#4271ae,header:#4271ae'
  " Solarized
  " let $FZF_DEFAULT_OPTS = '--color=fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33,info:33,prompt:33,pointer:166,marker:166,spinner:33'
  let $BAT_THEME_BAK = $BAT_THEME
  let $BAT_THEME = 'Monokai Extended Light'

  if dein#tap('smartnumber.vim')
    SNumbersTurnOffRelative
  endif

  if dein#tap('comfortable-motion.vim')
    let g:comfortable_motion_enable = 0
    ComfortableMotionToggle
  endif

  if dein#tap('neoscroll.nvim')
    lua require('neoscroll').setup({ mappings = {"<C-u>", "<C-d>"}})
  endif
endfunction

command! ReviewStart call <SID>review_start()

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

  if dein#tap('smartnumber.vim')
    SNumbersTurnOnRelative
  endif

  if dein#tap('comfortable-motion.vim')
    let g:comfortable_motion_enable = 1
    ComfortableMotionToggle
  endif

  if dein#tap('neoscroll.nvim')
    nunmap <C-d>
    nunmap <C-u>
  endif
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

" Indent {{{3
AutoCmd FileType javascript      setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescript      setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType typescriptreact setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vue             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType ruby            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType eruby           setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType python          setlocal expandtab   shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType go              setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
AutoCmd FileType json            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType markdown        setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType html            setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType css             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType vim             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType sh              setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
AutoCmd FileType zsh             setlocal expandtab   shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" Fold {{{3
AutoCmd FileType javascript      setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType typescript      setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType typescriptreact setlocal foldmethod=syntax foldlevel=100
AutoCmd FileType ruby            setlocal foldmethod=syntax foldlevel=100
" }}}3

" iskeyword {{{3
AutoCmd FileType vue  setlocal iskeyword+=$ iskeyword+=& iskeyword+=- iskeyword+=? iskeyword-=/
AutoCmd FileType ruby setlocal iskeyword+=@ iskeyword+=! iskeyword+=? iskeyword+=&
AutoCmd FileType html setlocal iskeyword+=-
AutoCmd FileType css  setlocal iskeyword+=- iskeyword+=#
AutoCmd FileType vim  setlocal iskeyword+=-
AutoCmd FileType sh   setlocal iskeyword+=-
AutoCmd FileType zsh  setlocal iskeyword+=-
" }}}3

" }}}2

" Vim script {{{2
let g:vimsyn_embed = 'l'
" }}}2

" HTML & eruby {{{2
function! s:map_html_keys() abort
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
AutoCmd FileType qf   nnoremap <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType help nnoremap <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType diff nnoremap <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType man  nnoremap <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType git  nnoremap <silent> <nowait> <buffer> q <Cmd>quit<CR>
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
  nnoremap <buffer> <silent> <nowait> q <Cmd>quit<CR>
  inoremap <buffer> <C-c> <Esc>l<C-c>

  if dein#tap('coc.nvim')
    call coc#config('suggest.floatEnable', v:false)
    call coc#config('diagnostic.messageTarget', 'echo')
    call coc#config('signature.target', 'echo')
    call coc#config('coc.preferences.hoverTarget', 'echo')
  endif

  " nnoremap <silent> <buffer> dd <Cmd>rviminfo<CR><Cmd>call histdel(getcmdwintype(), line('.') - line('$'))<CR><Cmd>wviminfo!<CR>dd
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
" function! s:bulk_alter_command(original, altanative) abort
"   if exists(':AlterCommand')
"      execute 'AlterCommand ' . a:original . ' ' a:altanative
"      execute 'AlterCommand <cmdwin> ' . a:original . ' ' a:altanative
"   endif
" endfunction

" command! -nargs=+ BulkAlterCommand call <SID>bulk_alter_command(<f-args>)

if dein#tap('vim-altercmd')
  call altercmd#load()
endif
" }}}3

" impatient {{{3
if dein#tap('impatient.nvim')
  lua require('impatient')
endif
" }}}3

" }}}2

" Plugin Manager {{{2

" }}}2

" denops {{{2

" ddc {{{3
if dein#tap('ddc.vim')
  function! SetupDdc() abort
    call ddc#enable()

    if s:enable_vim_lsp
      call DdcSettings()
    endif
  endfunction

  function DdcSettings() abort
    if s:enable_vim_lsp
      let sources = ['vim-lsp']
    else 
      let sources = []
    endif
    let sources += ['tabnine', 'around', 'buffer', 'file']

    let source_options = {
    \ '_': {
    \   'matchers': ['matcher_fuzzy'],
    \   'sorters': ['sorter_fuzzy'],
    \   'converters': ['converter_fuzzy'],
    \ },
    \ 'tabnine': {
    \   'mark': 'TN',
    \   'maxCandidates': 5,
    \   'isVolatile': v:true,
    \ },
    \ 'around': {
    \   'mark': 'around',
    \ },
    \ 'buffer': {
    \   'mark': 'buffer',
    \ },
    \ 'file': {
    \   'mark': 'file',
    \   'matchers': ['matcher_head'],
    \   'sorters': ['sorter_rank'],
    \   'isVolatile': v:true,
    \   'forceCompletionPattern': '\S/\S*',
    \ },
    \ }

    if s:enable_vim_lsp
      call extend(source_options, {
      \ 'vim-lsp': {
      \   'mark': 'lsp',
      \ },
      \ })
    endif

    call ddc#custom#patch_global('autoCompleteEvents', ['InsertEnter', 'TextChangedI', 'TextChangedP'])
    call ddc#custom#patch_global('sources', sources)
    call ddc#custom#patch_global('sourceOptions', source_options)

    call ddc#custom#patch_global('completionMenu', 'pum.vim')
    call popup_preview#enable()

    inoremap <C-Space> <Cmd>call ddc#manual_complete()<CR>
    inoremap <C-n>     <Cmd>call pum#map#insert_relative(+1)<CR>
    inoremap <C-p>     <Cmd>call pum#map#insert_relative(-1)<CR>
    inoremap <C-y>     <Cmd>call pum#map#confirm()<CR>
    inoremap <C-e>     <Cmd>call pum#map#cancel()<CR>
  endfunction

  " function! EnableDdc() abort
  "   let b:coc_suggest_disable = v:true
  "   call DdcSettings()
  " endfunction

  " function! DisableDdc() abort
  "   let b:coc_suggest_disable = v:false
  "   call ddc#custom#patch_global('sourceOptions', {})
  " endfunction
endif
" }}}3

" skkeleton {{{3
if dein#tap('skkeleton')
  imap <C-j> <Plug>(skkeleton-toggle)
  cmap <C-j> <Plug>(skkeleton-toggle)

  function! SetupSkkeleton() abort
    call skkeleton#config({
    \ 'globalJisyo': expand('~/.vim/skk/SKK-JISYO.L'),
    \ 'eggLikeNewline': v:true,
    \ })
  endfunction

  if dein#tap('lexima.vim')
    inoremap <silent> <expr> <Space> skkeleton#is_enabled() ? "\<Space>" : lexima#expand('<SPACE>', 'i')
  endif

  " if s:enable_coc
  "   AutoCmd User skkeleton-enable-pre call EnableDdc()
  "   AutoCmd User skkeleton-disable-pre call DisableDdc()
  " endif
endif
" }}}3

" }}}2

" IDE {{{2

" coc {{{3
if dein#tap('coc.nvim')
  let g:coc_global_extensions = [
  \ 'coc-deno',
  \ 'coc-docker',
  \ 'coc-eslint',
  \ 'coc-git',
  \ 'coc-json',
  \ 'coc-lists',
  \ 'coc-markdownlint',
  \ 'coc-marketplace',
  \ 'coc-npm-version',
  \ 'coc-prettier',
  \ 'coc-prisma',
  \ 'coc-python',
  \ 'coc-react-refactor',
  \ 'coc-rg',
  \ 'coc-rust-analyzer',
  \ 'coc-sh',
  \ 'coc-solargraph',
  \ 'coc-spell-checker',
  \ 'coc-sql',
  \ 'coc-stylelintplus',
  \ 'coc-tabnine',
  \ 'coc-tsserver',
  \ 'coc-vimlsp',
  \ 'coc-word',
  \ 'coc-yaml',
  \ ]

  if !dein#tap('fzf-preview.vim')
    call add(g:coc_global_extensions, 'coc-fzf-preview')
  endif

  if !dein#tap('coc-ultisnips-select')
    call add(g:coc_global_extensions, 'coc-ultisnips-select')
  endif

  " Manual completion
  inoremap <silent> <expr> <C-Space> coc#refresh()

  " Snippet map
  " let g:coc_snippet_next = '<C-f>'
  " let g:coc_snippet_prev = '<C-b>'

  " keymap
  nnoremap <silent> K             <Cmd>call <SID>show_documentation()<CR>
  nmap     <silent> <Plug>(dev)p  <Plug>(coc-diagnostic-prev)
  nmap     <silent> <Plug>(dev)n  <Plug>(coc-diagnostic-next)
  nmap     <silent> <Plug>(dev)D  <Plug>(coc-definition)
  nmap     <silent> <Plug>(dev)I  <Plug>(coc-implementation)
  nmap     <silent> <Plug>(dev)rF <Plug>(coc-references)
  nmap     <silent> <Plug>(dev)rn <Plug>(coc-rename)
  nmap     <silent> <Plug>(dev)T  <Plug>(coc-type-definition)
  nmap     <silent> <Plug>(dev)a  <Plug>(coc-codeaction-selected)iw
  nmap     <silent> <Plug>(dev)A  <Plug>(coc-codeaction)
  nmap     <silent> <Plug>(dev)l  <Plug>(coc-codelens-action)
  xmap     <silent> <Plug>(dev)a  <Plug>(coc-codeaction-selected)
  nmap     <silent> <Plug>(dev)f  <Plug>(coc-format)
  xmap     <silent> <Plug>(dev)f  <Plug>(coc-format-selected)
  nmap     <silent> <Plug>(dev)gs <Plug>(coc-git-chunkinfo)

  nnoremap <silent> <expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent> <expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent> <expr> <C-d> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Del>"
  inoremap <silent> <expr> <C-u> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<C-u>"

  " nnoremap <Leader>e <Cmd>CocCommand explorer<CR>
  " nnoremap <Leader>E <Cmd>CocCommand explorer --reveal expand('%')<CR>

  nmap <silent> gp <Plug>(coc-git-prevchunk)
  nmap <silent> gn <Plug>(coc-git-nextchunk)

  function! s:organize_import_and_format() abort
    function! s:execute_format(...) abort
      if <SID>is_deno()
        call CocActionAsync('format')
      else
        call CocActionAsync('runCommand', 'eslint.executeAutofix', { err, actions -> CocActionAsync('runCommand', 'prettier.formatFile') })
      endif
    endfunction

    call CocActionAsync('runCommand', 'editor.action.organizeImport', function('<SID>execute_format'))
  endfunction

  command! OrganizeImport call <SID>organize_import_and_format()
  " command! CocMarkdownPreview CocCommand markdown-preview-enhanced.openPreview

  function! s:show_documentation() abort
    if index(['vim','help'], &filetype) >= 0
      execute 'h ' . expand('<cword>')
    elseif coc#rpc#ready()
      call CocActionAsync('doHover')
    endif
  endfunction

  function! s:coc_typescript_settings() abort
    setlocal tagfunc=CocTagFunc
    if <SID>is_deno()
      nmap <silent> <buffer> <Plug>(dev)f <Plug>(coc-format)
    else
      nnoremap <silent> <buffer> <Plug>(dev)f <Cmd>CocCommand eslint.executeAutofix<CR><Cmd>CocCommand prettier.formatFile<CR>
    endif
  endfunction

  function! s:coc_ts_ls_initialize() abort
    if <SID>is_deno()
      call coc#config('tsserver.enable', v:false)
      call coc#config('deno.enable', v:true)
    else
      call coc#config('tsserver.enable', v:true)
      call coc#config('deno.enable', v:false)
    endif
  endfunction

  function! s:is_deno() abort
    if exists('s:is_deno_cache') && s:is_deno_cache
      return s:is_deno_cache
    endif

    if filereadable('.git/is_deno') || !isdirectory('node_modules')
      let s:is_deno_cache = v:true
      return v:true
    else
      let s:is_deno_cache = v:false
      return v:false
    endif
  endfunction

  function! s:coc_rust_settings() abort
    setlocal tagfunc=CocTagFunc
    nnoremap <silent> <buffer> gK <Cmd>CocCommand rust-analyzer.openDocs<CR>
  endfunction

  " AutoCmd CursorHold * silent call CocActionAsync('highlight')
  AutoCmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  AutoCmd VimEnter * call <SID>coc_ts_ls_initialize()
  AutoCmd FileType typescript,typescriptreact call <SID>coc_typescript_settings()
  AutoCmd FileType rust call <SID>coc_rust_settings()
endif
" }}}3

" vim-lsp {{{3
if dein#tap('vim-lsp')
  let g:lsp_diagnostics_float_cursor         = 1
  let g:lsp_diagnostics_virtual_text_enabled = 0

  function! s:on_lsp_buffer_enabled() abort
    setlocal signcolumn=yes

    if exists('+tagfunc')
      setlocal tagfunc=lsp#tagfunc
    endif

    nmap <buffer> <Plug>(dev)d  <Plug>(lsp-definition)
    nmap <buffer> <Plug>(dev)r  <Plug>(lsp-references)
    nmap <buffer> <Plug>(dev)i  <Plug>(lsp-implementation)
    nmap <buffer> <Plug>(dev)t  <Plug>(lsp-type-definition)
    nmap <buffer> <Plug>(dev)rn <Plug>(lsp-rename)
    nmap <buffer> K             <Plug>(lsp-hover)
  endfunction

  AutoCmd User lsp_buffer_enabled call <SID>on_lsp_buffer_enabled()
endif
" }}}3

" nvim-lsp {{{3
if dein#tap('nvim-lspconfig')
lua <<EOF
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'mD',  '<Cmd>lua vim.lsp.buf.declaration()<CR>',        opts)
  buf_set_keymap('n', 'md',  '<Cmd>lua vim.lsp.buf.definition()<CR>',         opts)
  buf_set_keymap('n', 'K',   '<Cmd>lua vim.lsp.buf.hover()<CR>',              opts)
  buf_set_keymap('n', 'mi',  '<Cmd>lua vim.lsp.buf.implementation()<CR>',     opts)
  buf_set_keymap('n', 'mt',  '<Cmd>lua vim.lsp.buf.type_definition()<CR>',    opts)
  buf_set_keymap('n', 'mrn', '<Cmd>lua vim.lsp.buf.rename()<CR>',             opts)
  buf_set_keymap('n', 'ma',  '<Cmd>lua vim.lsp.buf.code_action()<CR>',        opts)
  buf_set_keymap('n', 'mrf', '<Cmd>lua vim.lsp.buf.references()<CR>',         opts)
  buf_set_keymap('n', 'mq',  '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', 'mf',  '<Cmd>lua vim.lsp.buf.formatting()<CR>',         opts)
end

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.on_server_ready(function(server)
    local opts = {}
    opts.on_attach = on_attach
    opts.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
end)
EOF
endif

if dein#tap('lspsaga.nvim')
  lua require('lspsaga').setup()
endif
" }}}3

" nvim-cmp {{{3
if dein#tap('nvim-cmp')
lua <<EOF
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  }, 
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
  }, {
    { name = 'buffer' },
  })
})
EOF
endif
" }}}3

" efm-langserver-settings {{{3
if dein#tap('vim-efm-langserver-settings')
  let g:efm_langserver_settings#filetype_whitelist = ['typescript']
endif
" }}}3

" asyncomplete {{{3
" let g:asyncomplete_auto_popup = 1
" imap <C-Space> <Plug>(asyncomplete_force_refresh)
" }}}3

" }}}2

" Language {{{2

" fixjson {{{3
if dein#tap('vim-fixjson')
  let g:fixjson_fix_on_save = 0
endif
" }}}3

" gen_tags {{{3
if dein#tap('gen_tags.vim')
  let g:gen_tags#ctags_auto_gen = 1
  let g:gen_tags#ctags_opts     = '--excmd=number'
  let g:loaded_gentags#gtags    = 1
endif
" }}}3

" import-cost {{{3
if dein#tap('vim-import-cost')
  AutoCmd InsertLeave *.js,*.jsx,*.ts,*.tsx ImportCost
  AutoCmd BufEnter *.js,*.jsx,*.ts,*.tsx    ImportCost
endif
" }}}3

" json {{{3
if dein#tap('vim-json')
  let g:vim_json_syntax_conceal = 0
endif
" }}}3

" markdown {{{3
if dein#tap('vim-markdown')
  let g:vim_markdown_folding_disabled        = 1
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_conceal                 = 0
  let g:vim_markdown_conceal_code_blocks     = 0
  let g:vim_markdown_auto_insert_bullets     = 0
  let g:vim_markdown_new_list_item_indent    = 0
endif
" }}}3

" rainbow_csv {{{3
if dein#tap('rainbow_csv')
  let g:disable_rainbow_key_mappings = 1
endif
" }}}3

" treesitter {{{3
if dein#tap('nvim-treesitter')
  " let g:indent_blankline_context_patterns = [
  " \ 'class',
  " \ 'function',
  " \ 'method',
  " \ '^if',
  " \ 'while',
  " \ 'for',
  " \ 'with',
  " \ 'func_literal',
  " \ 'block',
  " \ 'try',
  " \ 'except',
  " \ 'argument_list',
  " \ 'object',
  " \ 'dictionary',
  " \ 'element'
  " \ ]

lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "typescript",
    "tsx",
    "javascript",
    "graphql",
    "jsdoc",
    "rust",
    "ruby",
    "python",
    "json",
    "yaml",
    "markdown",
    "dockerfile",
    "vim",
    "lua",
    "html",
    "css",
    "comment",
  },
  highlight = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  rainbow = {
    enable = true,
  },
  -- refactor = {
  --   highlight_current_scope = {
  --     enable = true
  --   },
  -- },
}

-- require('nvim-biscuits').setup({
--   default_config = {
--     prefix_string = " => "
--   },
-- })

-- require "nvim-treesitter.highlight"
-- local hlmap = vim.treesitter.highlighter.hl_map

-- hlmap.error = nil
-- hlmap["punctuation.delimiter"] = "Delimiter"
-- hlmap["punctuation.bracket"] = nil

-- require('treesitter-context').setup{
--   enable = true,
--   throttle = true,
-- }

-- require('treesitter-unit').select()
-- require('treesitter-unit').enable_highlighting()

-- require("indent_blankline").setup {
--   show_current_context = true,
--   space_char_blankline = " ",
--   char = '▏', -- '▏', '┊', '│', '⎸'
-- }

-- require('nvim_context_vt').setup()
EOF

  " omap <silent> <Plug>(textobj-treesitter-unit-i) <Cmd><C-u>lua require('treesitter-unit').select(true)<CR>
  " xmap <silent> <Plug>(textobj-treesitter-unit-i) :lua require('treesitter-unit').select(true)<CR>
  " omap <silent> <Plug>(textobj-treesitter-unit-a) <Cmd>lua require('treesitter-unit').select()<CR>
  " xmap <silent> <Plug>(textobj-treesitter-unit-a) :lua require('treesitter-unit').select()<CR>

  " omap <silent> iu <Plug>(textobj-treesitter-unit-i)
  " xmap <silent> iu <Plug>(textobj-treesitter-unit-i)
  " omap <silent> au <Plug>(textobj-treesitter-unit-a)
  " xmap <silent> au <Plug>(textobj-treesitter-unit-a)


  function! s:treesitter_toggle() abort
    if g:treesitter_enable == 1
      let g:treesitter_enable = 0
      call <SID>treesitter_disable()
    else
      let g:treesitter_enable = 1
      call <SID>treesitter_enable()
    endif
  endfunction
  command! TreesitterToggle call <SID>treesitter_toggle()

  function! s:treesitter_enable() abort
    TSEnableAll highlight
    TSEnableAll context_commentstring
    TSEnableAll rainbow
  endfunction

  function! s:treesitter_disable() abort
    TSDisableAll highlight
    TSDisableAll context_commentstring
    TSDisableAll rainbow
  endfunction

  function! s:check_large_file() abort
    let max_file_size = 500 * 1000
    let fsize = getfsize(@%)
    let line_num = line('$')

    if fsize > max_file_size
      if input(printf('"%s" is too large file.(%s lines, %s byte) Continue? [y/N]', @%, line_num, fsize)) !~? '^y\%[es]$'
        if dein#tap('vim-bbye')
          Bwipeout
        else
          bwipeout
        endif
        return
      else
        syntax off
        call <SID>treesitter_disable()
      endif
    endif
  endfunction

  AutoCmd BufReadPre *.ts,*.tsx,*.js call <SID>check_large_file()

  " AutoCmd BufReadPre  *.ts,*.tsx,*.js call <SID>disable_syntax()
  " AutoCmd BufReadPost *.ts,*.tsx,*.js call <SID>set_syntax()
  " AutoCmd BufEnter    *.ts,*.tsx,*.js call <SID>enable_tsbuf()
  "
  " function! s:disable_syntax() abort
  "   syntax off
  "   TSDisableAll highlight
  "   TSDisableAll context_commentstring
  "   TSDisableAll rainbow
  " endfunction
  " 
  " function! s:enable_tsbuf() abort
  "   if exists('b:ts_buf') && b:ts_buf
  "     TSEnableAll highlight
  "     TSEnableAll context_commentstring
  "     TSEnableAll rainbow
  "     TSBufEnable highlight
  "     TSBufEnable context_commentstring
  "     TSBufEnable rainbow
  "   endif
  " endfunction
  "
  " function! s:set_syntax() abort
  "   let max_file_size = 500 * 1000
  "   let fsize = getfsize(@%)
  "   let line_num = line('$')
  "
  "   if fsize > max_file_size && input(printf('"%s" is too large file.(%s lines, %s byte) Continue? [y/N]', @%, line_num, fsize)) !~? '^y\%[es]$'
  "     bwipeout
  "     return
  "   endif
  "
  "   if fsize < max_file_size
  "     syntax on
  "     let b:ts_buf = v:true
  "   else
  "     syntax off
  "     let b:ts_buf = v:false
  "   endif
  " endfunction
endif
" }}}3

" vue {{{3
if dein#tap('vim-vue')
  AutoCmd FileType vue syntax sync fromstart
endif
" }}}3

" }}}2

" Completion & Fuzzy Finder {{{2

" Denite {{{3

if dein#tap('denite.nvim')
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

  AutoCmd FileType denite        call <SID>denite_settings()
  AutoCmd FileType denite-filter call <SID>denite_filter_settings()

  let s:menus = {}
  let s:menus.toggle = { 'description': 'Toggle Command' }

  " TODO: Add toggle command
  let s:menus.toggle.command_candidates = [
  \ ['Toggle Review            [ReviewToggle]',              'ReviewToggle'           ],
  \ ['Toggle CursorHighlight   [CursorHighlightToggle]',     'CursorHighlightToggle'  ],
  \ ['Toggle Context           [ContextToggleWindow]',       'ContextToggleWindow'    ],
  \ ['Toggle ComfortableMotion [ComfortableMotionToggle]',   'ComfortableMotionToggle'],
  \ ['Toggle IndentLine        [IndentLinesToggle]',         'IndentLinesToggle'      ],
  \ ['Toggle SyntaxHighlight   [SyntaxHighlightToggle]',     'SyntaxHighlightToggle'  ],
  \ ['Toggle TableMode         [TableMode]',                 'TableModeToggle'        ],
  \ ['Toggle RelNum            [SNToggle]',                  'SNToggle'               ],
  \ ]

  call denite#custom#var('menu', 'menus', s:menus)
endif

" }}}3

" fzf {{{3
if dein#tap('fzf')
  let g:fzf_files_options = '--layout=reverse'
  let g:fzf_layout      = { 'window': { 'width': 0.9, 'height': 0.9 } }
  " let g:fzf_history_dir = '~/.local/share/fzf-history'

  " Nord
  " let $FZF_DEFAULT_OPTS = '--color=hl:#81A1C1,hl+:#81A1C1,info:#EACB8A,prompt:#81A1C1,pointer:#B48DAC,marker:#A3BE8B,spinner:#B48DAC,header:#A3BE8B'
  " Gruvbox
  let $FZF_DEFAULT_OPTS = '--color=bg+:#1d2021,bg:#1d2021,spinner:#d8a657,hl:#a9b665,fg:#d4be98,header:#928374,info:#89b482,pointer:#7daea3,marker:#d8a657,fg+:#d4be98,prompt:#e78a4e,hl+:#89b482'
endif
" }}}3

" fzf-preview {{{3
if dein#tap('fzf-preview.vim')
  " let g:fzf_preview_rpc_debug = 1
  " let g:fzf_preview_direct_window_option = 'botright 20new'
  let g:fzf_preview_filelist_command    = 'fd --type file --hidden --exclude .git --strip-cwd-prefix'
  let g:fzf_preview_git_files_command   = 'git ls-files --exclude-standard | while read line; do if [[ ! -L $line ]] && [[ -f $line ]]; then echo $line; fi; done'
  let g:fzf_preview_grep_cmd            = 'rg --line-number --no-heading --color=never --sort=path --with-filename'
  let g:fzf_preview_mru_limit           = 5000
  let g:fzf_preview_use_dev_icons       = 1
  let g:fzf_preview_default_fzf_options = {
  \ '--reverse': v:true,
  \ '--preview-window': 'wrap',
  \ '--bind': 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview,ctrl-n:down,ctrl-p:up,ctrl-j:next-history,ctrl-k:previous-history'
  \ }

  let $BAT_THEME                        = 'gruvbox-dark'
  let $FZF_PREVIEW_PREVIEW_BAT_THEME    = 'gruvbox-dark'
  let $BAT_STYLE                        = 'plain'
  let g:fzf_preview_history_dir         = '~/.fzf'
  let $FZF_PREVIEW_PLUGIN_HELP_ROOT_DIR = '~/.vim/bundle/repos/github.com'

  nnoremap <silent> <Plug>(fzf-p)r     <Cmd>FzfPreviewProjectMruFilesRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)w     <Cmd>FzfPreviewProjectMrwFilesRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)a     <Cmd>FzfPreviewFromResourcesRpc --experimental-fast project_mru git<CR>
  nnoremap <silent> <Plug>(fzf-p)s     <Cmd>FzfPreviewGitStatusRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)gg    <Cmd>FzfPreviewGitActionsRpc<CR>
  nnoremap <silent> <Plug>(fzf-p)b     <Cmd>FzfPreviewBuffersRpc<CR>
  nnoremap <silent> <Plug>(fzf-p)B     <Cmd>FzfPreviewAllBuffersRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)<C-o> <Cmd>FzfPreviewJumpsRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)g;    <Cmd>FzfPreviewChangesRpc<CR>
  nnoremap <silent> <Plug>(fzf-p)/     <Cmd>FzfPreviewLinesRpc --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  nnoremap <silent> <Plug>(fzf-p)/     :<C-u>FzfPreviewProjectGrepRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort . <C-r>=expand('%')<CR><CR>
  nnoremap <silent> <Plug>(fzf-p)*     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
  xnoremap <silent> <Plug>(fzf-p)*     "sy:FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--exact --add-fzf-arg=--query="<C-r>=substitute(@s, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
  nnoremap <silent> <Plug>(fzf-p)n     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=substitute(@/, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
  nnoremap <silent> <Plug>(fzf-p)?     <Cmd>FzfPreviewBufferLinesRpc --resume --add-fzf-arg=--no-sort<CR>
  nnoremap <silent> <Plug>(fzf-p)q     <Cmd>FzfPreviewQuickFixRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)l     <Cmd>FzfPreviewLocationListRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p):     <Cmd>FzfPreviewCommandPaletteRpc --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)m     <Cmd>FzfPreviewBookmarksRpc --resume --experimental-fast<CR>
  nnoremap <silent> <Plug>(fzf-p)<C-]> :<C-u>FzfPreviewVistaCtagsRpc --experimental-fast --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
  nnoremap <silent> <Plug>(fzf-p)o     <Cmd>FzfPreviewVistaBufferCtagsRpc --experimental-fast<CR>

  nnoremap          <Plug>(fzf-p)f :<C-u>FzfPreviewProjectGrepRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>
  xnoremap          <Plug>(fzf-p)f "sy:FzfPreviewProjectGrepRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
  nnoremap <silent> <Plug>(fzf-p)F <Cmd>FzfPreviewProjectGrepRecallRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  nnoremap          <Plug>(fzf-p)h :<C-u>FzfPreviewGrepHelpRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>

  if dein#tap('coc.nvim')
    nnoremap <silent> <Plug>(fzf-p)p <Cmd>CocCommand fzf-preview.Yankround --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  else
    nnoremap <silent> <Plug>(fzf-p)p <Cmd>FzfPreviewYankroundRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  endif

  nnoremap <silent> <Plug>(dev)q  <Cmd>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
  nnoremap <silent> <Plug>(dev)Q  <Cmd>CocCommand fzf-preview.CocDiagnostics<CR>
  nnoremap <silent> <Plug>(dev)rf <Cmd>CocCommand fzf-preview.CocReferences<CR>
  nnoremap <silent> <Plug>(dev)d  <Cmd>CocCommand fzf-preview.CocDefinition<CR>
  nnoremap <silent> <Plug>(dev)t  <Cmd>CocCommand fzf-preview.CocTypeDefinition<CR>
  nnoremap <silent> <Plug>(dev)i  <Cmd>CocCommand fzf-preview.CocImplementations<CR>
  nnoremap <silent> <Plug>(dev)o  <Cmd>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>

  AutoCmd User fzf_preview#rpc#initialized call <SID>fzf_preview_settings()

  function! s:buffers_delete_from_lines(lines) abort
    for line in a:lines
      let matches = matchlist(line, '\[\(\d\+\)\]')
      if len(matches) >= 1
        execute 'Bdelete! ' . matches[1]
      endif
    endfor
  endfunction

  "" TODO: fzf Reflection
  " function! FzfColor() abort
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
  " \ 'fg':      ['fg', 'Normal'],
  " \ 'bg':      ['bg', 'Normal'],
  " \ 'hl':      ['fg', 'Comment'],
  " \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  " \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  " \ 'hl+':     ['fg', 'Statement'],
  " \ 'info':    ['fg', 'PreProc'],
  " \ 'border':  ['fg', 'Ignore'],
  " \ 'prompt':  ['fg', 'Conditional'],
  " \ 'pointer': ['fg', 'Exception'],
  " \ 'marker':  ['fg', 'Keyword'],
  " \ 'spinner': ['fg', 'Label'],
  " \ 'header':  ['fg', 'Comment']
  " \ }

  function! s:fzf_preview_settings() abort
    let g:fzf_preview_grep_preview_cmd = 'COLORTERM=truecolor ' . g:fzf_preview_grep_preview_cmd
    let g:fzf_preview_command = 'COLORTERM=truecolor ' . g:fzf_preview_command
    let g:fzf_preview_git_status_preview_command =  '[[ $(git diff --cached -- {-1}) != "" ]] && git diff --cached --color=always -- {-1} | delta || ' .
    \ '[[ $(git diff -- {-1}) != "" ]] && git diff --color=always -- {-1} | delta || ' .
    \ g:fzf_preview_command

    let g:fzf_preview_custom_processes['open-file'] = fzf_preview#remote#process#get_default_processes('open-file', 'rpc')
    let g:fzf_preview_custom_processes['open-file']['ctrl-s'] = g:fzf_preview_custom_processes['open-file']['ctrl-x']
    call remove(g:fzf_preview_custom_processes['open-file'], 'ctrl-x')

    let g:fzf_preview_custom_processes['open-file-with-tag-stack'] = fzf_preview#remote#process#get_default_processes('open-file-with-tag-stack', 'rpc')
    let g:fzf_preview_custom_processes['open-file-with-tag-stack']['ctrl-s'] = g:fzf_preview_custom_processes['open-file-with-tag-stack']['ctrl-x']
    call remove(g:fzf_preview_custom_processes['open-file-with-tag-stack'], 'ctrl-x')

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
endif
" }}}3

" coc-fzf {{{3
if dein#tap('coc-fzf')
  let g:coc_fzf_preview = 'right'
  let g:coc_fzf_opts    = ['--layout=reverse']
endif
" }}}3

" telescope {{{3
if dein#tap('telescope.nvim')
  " nnoremap <silent> <Plug>(ctrlp) <Cmd>lua require('telescope.builtin').git_files{}<CR>
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

" git-blame {{{3
if dein#tap('git-blame.nvim')
  let g:gitblame_enabled = 0 
endif
" }}}3

" git-messenger {{{3
if dein#tap('git-messenger.vim')
  let g:git_messenger_no_default_mappings = 1

  nnoremap <silent> gm <Cmd>GitMessenger<CR>
endif
" }}}3

" gina {{{3
if dein#tap('gina.vim')
  AutoCmd VimEnter * call <SID>gina_settings()

  function! s:gina_settings() abort
    call gina#custom#command#option('status', '--short')
    call gina#custom#command#option('/\%(status\|commit\|branch\)', '--opener', 'split')
    call gina#custom#command#option('diff', '--opener', 'vsplit')

    call gina#custom#command#option('/\%(status\|changes\)', '--ignore-submodules')
    call gina#custom#command#option('status', '--branch')
    call gina#custom#mapping#nmap('status', '<C-j>', '<Cmd>lua require("tmux").move_bottom()<CR>', {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('status', '<C-k>', '<Cmd>lua require("tmux").move_top()<CR>',    {'noremap': 1, 'silent': 1})

    call gina#custom#mapping#nmap('diff', '<CR>', '<Plug>(gina-diff-jump-vsplit)', {'silent': 1})

    call gina#custom#mapping#nmap('blame', '<C-l>', '<Cmd>lua require("tmux").move_right()<CR>',    {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('blame', '<C-r>', '<Plug>(gina-blame-redraw)', {'noremap': 1, 'silent': 1})
    call gina#custom#mapping#nmap('blame', 'j',     'j<Plug>(gina-blame-echo)')
    call gina#custom#mapping#nmap('blame', 'k',     'k<Plug>(gina-blame-echo)')

    call gina#custom#action#alias('/\%(blame\|log\|reflog\)', 'preview', 'topleft show:commit:preview')
    call gina#custom#mapping#nmap('/\%(blame\|log\|reflog\)', 'p',       "<Cmd>call gina#action#call('preview')<CR>", {'noremap': 1, 'silent': 1})

    call gina#custom#execute('/\%(ls\|log\|reflog\|grep\)',                 'setlocal noautoread')
    call gina#custom#execute('/\%(status\|branch\|ls\|log\|reflog\|grep\)', 'setlocal cursorline')

    call gina#custom#mapping#nmap('/\%(status\|commit\|branch\|ls\|log\|reflog\|grep\)', 'q', 'ZQ', {'nnoremap': 1, 'silent': 1})

    call gina#custom#mapping#nmap('log', 'yy', "<Cmd>call gina#action#call('yank:rev')<CR>", {'noremap': 1, 'silent': 1})
    " require floaterm
    call gina#custom#mapping#nmap('log', 'R', "<Cmd>call gina#action#call('yank:rev')<CR>:FloatermNew git rebase -i <C-r>\"<CR>", {'noremap': 1, 'silent': 1})
  endfunction
endif
" }}}3

" gitsessions {{{3
if dein#tap('gitsessions.vim')
  let g:gitsessions_disable_auto_load = 1
endif
" }}}3

" gitsigns {{{3
if dein#tap('gitsigns.nvim')
  nnoremap <silent> gp <Cmd>lua require('gitsigns').prev_hunk()<CR>
  nnoremap <silent> gn <Cmd>lua require('gitsigns').next_hunk()<CR>

lua <<EOF
require('gitsigns').setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '+', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'   },
    change       = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '-', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  word_diff = false,
  keymaps = {
    noremap = false,
  },
  current_line_blame = false,
}
EOF
endif
" }}}3

" }}}2

" filer {{{2

" defx {{{3
if dein#tap('defx.nvim')
  let g:defx_git#raw_mode        = 1
  let g:defx_icons_column_length = 2

  nnoremap <silent> <Leader><Leader>e :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft<CR>
  nnoremap <silent> <Leader><Leader>E :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft -search=`expand('%:p')`<CR>

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

    nnoremap <silent> <buffer> <expr> <nowait> p       defx#do_action('preview')
  endfunction

  AutoCmd FileType defx call <SID>defx_settings()
endif
" }}}3

" fern {{{3
if dein#tap('fern.vim')
  function! s:fern_reveal(dict) abort
    execute 'FernReveal' a:dict.relative_path
  endfunction

  let g:fern#disable_default_mappings             = 1
  let g:fern#drawer_width                         = 40
  let g:fern#renderer                             = 'nerdfont'
  let g:fern#renderer#nerdfont#padding            = '  '
  let g:fern#hide_cursor                          = 1
  let g:fern#mapping#fzf#disable_default_mappings = 1
  let g:Fern_mapping_fzf_file_sink                = function('s:fern_reveal')
  let g:Fern_mapping_fzf_dir_sink                 = function('s:fern_reveal')

  function! s:fern_preview_width() abort
    let width = float2nr(&columns * 0.8)
    let width = min([width, 200])
    return width
  endfunction

  let g:fern_preview_window_calculator = {
  \ 'width': function('s:fern_preview_width')
  \ }

  function! Fern_mapping_fzf_customize_option(spec) abort
      let a:spec.options .= ' --multi'
      " Note that fzf#vim#with_preview comes from fzf.vim
      if exists('*fzf#vim#with_preview')
        return fzf#vim#with_preview(a:spec)
      else
        return a:spec
      endif
  endfunction

  nnoremap <silent> <Leader>e <Cmd>Fern . -drawer<CR><C-w>=
  nnoremap <silent> <Leader>E <Cmd>Fern . -drawer -reveal=%<CR><C-w>=

  function! s:fern_settings() abort
    nnoremap <silent> <buffer>        <Plug>(fern-page-down-wrapper)                <C-d>
    nnoremap <silent> <buffer>        <Plug>(fern-page-up-wrapper)                  <C-u>
    nmap     <silent> <buffer> <expr> <Plug>(fern-page-down-or-scroll-down-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
    nmap     <silent> <buffer> <expr> <Plug>(fern-page-down-or-scroll-up-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")
    nnoremap <silent> <buffer>        <Plug>(fern-search-prev)                      N

    nmap <silent> <buffer> <expr> <Plug>(fern-expand-or-collapse)                 fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")
    nmap <silent> <buffer> <expr> <Plug>(fern-open-system-directory-or-open-file) fern#smart#leaf("\<Plug>(fern-action-open:select)", "\<Plug>(fern-action-open:system)")
    nmap <silent> <buffer> <expr> <Plug>(fern-quit-or-close-preview)              fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":q\<CR>")
    nmap <silent> <buffer> <expr> <Plug>(fern-wipe-or-close-preview)              fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":bwipe!\<CR>")
    nmap <silent> <buffer> <expr> <Plug>(fern-page-down-or-scroll-down-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
    nmap <silent> <buffer> <expr> <Plug>(fern-page-down-or-scroll-up-preview)     fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")
    nmap <silent> <buffer> <expr> <Plug>(fern-new-file-or-search-prev)            v:hlsearch ? "\<Plug>(fern-search-prev)" : "\<Plug>(fern-action-new-file)"

    nmap <silent> <buffer> <nowait> a       <Plug>(fern-choice)
    nmap <silent> <buffer> <nowait> <CR>    <Plug>(fern-open-system-directory-or-open-file)
    nmap <silent> <buffer> <nowait> t       <Plug>(fern-expand-or-collapse)
    nmap <silent> <buffer> <nowait> l       <Plug>(fern-open-or-enter)
    nmap <silent> <buffer> <nowait> h       <Plug>(fern-action-leave)
    nmap <silent> <buffer> <nowait> x       <Plug>(fern-action-mark:toggle)j
    xmap <silent> <buffer> <nowait> x       <Plug>(fern-action-mark:toggle)j
    nmap <silent> <buffer> <nowait> <Space> <Plug>(fern-action-mark:toggle)j
    xmap <silent> <buffer> <nowait> <Space> <Plug>(fern-action-mark:toggle)j
    nmap <silent> <buffer> <nowait> N       <Plug>(fern-new-file-or-search-prev)
    nmap <silent> <buffer> <nowait> K       <Plug>(fern-action-new-dir)
    nmap <silent> <buffer> <nowait> d       <Plug>(fern-action-trash)
    nmap <silent> <buffer> <nowait> r       <Plug>(fern-action-rename)
    nmap <silent> <buffer> <nowait> c       <Plug>(fern-action-copy)
    nmap <silent> <buffer> <nowait> C       <Plug>(fern-action-clipboard-copy)
    nmap <silent> <buffer> <nowait> m       <Plug>(fern-action-move)
    nmap <silent> <buffer> <nowait> M       <Plug>(fern-action-clipboard-move)
    nmap <silent> <buffer> <nowait> P       <Plug>(fern-action-clipboard-paste)
    nmap <silent> <buffer> <nowait> !       <Plug>(fern-action-hidden-toggle)
    nmap <silent> <buffer> <nowait> y       <Plug>(fern-action-yank)
    nmap <silent> <buffer> <nowait> <C-g>   <Plug>(fern-action-debug)
    nmap <silent> <buffer> <nowait> ?       <Plug>(fern-action-help)
    nmap <silent> <buffer> <nowait> <C-c>   <Plug>(fern-action-cancel)
    nmap <silent> <buffer> <nowait> .       <Plug>(fern-repeat)
    nmap <silent> <buffer> <nowait> q       <Plug>(fern-quit-or-close-preview)
    nmap <silent> <buffer> <nowait> Q       <Plug>(fern-wipe-or-close-preview)
    nmap <silent> <buffer> <nowait> p       <Plug>(fern-action-preview:toggle)
    nmap <silent> <buffer> <nowait> <C-p>   <Plug>(fern-action-preview:auto:toggle)
    nmap <silent> <buffer> <nowait> <C-d>   <Plug>(fern-page-down-or-scroll-down-preview)
    nmap <silent> <buffer> <nowait> <C-u>   <Plug>(fern-page-down-or-scroll-up-preview)
    nmap <silent> <buffer> <nowait> R       <Plug>(fern-action-reload:all)
    nmap <silent> <buffer> <nowait> ;f      <Plug>(fern-action-fzf-root-files)
    nmap <silent> <buffer> <nowait> ;d      <Plug>(fern-action-fzf-root-dirs)
    nmap <silent> <buffer> <nowait> ;a      <Plug>(fern-action-fzf-root-both)

    setlocal nonumber norelativenumber
    augroup fern-cursor-moved
      autocmd! * <buffer>
      autocmd CursorMoved <buffer> echo matchstr(getline('.'), '[-./[:alnum:]_]\+')
    augroup END
  endfunction

  AutoCmd FileType fern call <SID>fern_settings()
  AutoCmd FileType fern call glyph_palette#apply()
endif
" }}}3

" }}}2

" textobj & operator {{{2

" equal.operator {{{3
if dein#tap('equal.operator')
  let equal_operator_default_mappings = 0

  omap i=h <Plug>(operator-lhs)
  omap a=h <Plug>(operator-Lhs)
  xmap i=h <Plug>(visual-lhs)
  xmap a=h <Plug>(visual-Lhs)

  omap i=l <Plug>(operator-rhs)
  omap a=l <Plug>(operator-Rhs)
  xmap i=l <Plug>(visual-rhs)
  xmap a=l <Plug>(visual-Rhs)
endif
" }}}3

" operator-convert-case {{{3
if dein#tap('vim-operator-convert-case')
  nmap cy <Plug>(operator-convert-case-loop)
  xmap cy <Plug>(operator-convert-case-loop)
endif
" }}}3

" operator-replace {{{3
if dein#tap('vim-operator-replace')
  nmap _ <Plug>(operator-replace)
  xmap _ <Plug>(operator-replace)
  omap _ <Plug>(operator-replace)
endif
" }}}3

" swap {{{3
if dein#tap('vim-swap')
  nmap g< <Plug>(swap-prev)
  nmap g> <Plug>(swap-next)
  nmap gs <Plug>(swap-interactive)

  omap i, <Plug>(swap-textobject-i)
  xmap i, <Plug>(swap-textobject-i)
  omap a, <Plug>(swap-textobject-a)
  xmap a, <Plug>(swap-textobject-a)
endif
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

" textobj-cursorcontext {{{3
if dein#tap('vim-textobj-cursor-context')
  let g:textobj_cursorcontext_no_default_key_mappings = 1

  omap ic <Plug>(textobj-cursorcontext-i)
  omap ac <Plug>(textobj-cursorcontext-a)
  xmap ic <Plug>(textobj-cursorcontext-i)
  xmap ac <Plug>(textobj-cursorcontext-a)
endif
" }}}3

" textobj-entire {{{3
if dein#tap('vim-textobj-entire')
  let g:textobj_entire_no_default_key_mappings = 1

  omap ie <Plug>(textobj-entire-i)
  omap ae <Plug>(textobj-entire-a)
  xmap ie <Plug>(textobj-entire-i)
  xmap ae <Plug>(textobj-entire-a)
endif
" }}}3

" textobj-functioncall {{{3
if dein#tap('vim-textobj-functioncall')
  let g:textobj_functioncall_no_default_key_mappings = 1

  omap if <Plug>(textobj-functioncall-i)
  omap af <Plug>(textobj-functioncall-a)
  xmap if <Plug>(textobj-functioncall-i)
  xmap af <Plug>(textobj-functioncall-a)
endif
" }}}3

" textobj-line {{{3
if dein#tap('vim-textobj-line')
  let g:textobj_line_no_default_key_mappings = 1

  omap il <Plug>(textobj-line-i)
  omap al <Plug>(textobj-line-a)
  xmap il <Plug>(textobj-line-i)
  xmap al <Plug>(textobj-line-a)
endif
" }}}3

" textobj-url {{{3
if dein#tap('vim-textobj-url')
  let g:textobj_url_no_default_key_mappings = 1

  omap iu <Plug>(textobj-url-i)
  omap au <Plug>(textobj-url-a)
  xmap iu <Plug>(textobj-url-i)
  xmap au <Plug>(textobj-url-a)
endif
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{3
if dein#tap('accelerated-jk')
  nmap j <Plug>(accelerated_jk_j)
  nmap k <Plug>(accelerated_jk_k)
endif
" }}}3

" hlslens & asterisk & anzu {{{3
if dein#tap('nvim-hlslens') &&
   \ dein#tap('vim-asterisk') &&
   \ dein#tap('vim-anzu') &&
   \ dein#tap('vim-searchx')
  if has('nvim')
    let g:searchx = {}
    let g:searchx.auto_accept = v:true
    let g:searchx.markers = split('ASDFGHJKLQWERTYUIOPZXCVBNM', '.\zs')

    function! g:searchx.convert(input) abort
      if a:input !~# '\k'
        return '\V' .. a:input
      endif

      if dein#tap('fuzzy-motion.vim') && a:input =~# ';'
        let max_score = 0
        let fuzzy_input = ''

        for q in s:fuzzy_query(a:input)
          let targets = denops#request('fuzzy-motion', 'targets', [q])

          if len(targets) > 0 && targets[0].score > max_score
            let max_score = targets[0].score
            let fuzzy_input = join(split(q, ' '), '.\{-}')
          endif

          " let total_score = 0
          " for target in targets
          "   let total_score += target.score
          " endfor
          "
          " if total_score > max_score
          "   let max_score = total_score
          "   let fuzzy_input = join(split(q, ' '), '.\{-}')
          " endif
        endfor

        return fuzzy_input ==# '' ? a:input : fuzzy_input
      endif

      return a:input
    endfunction

    function! s:fuzzy_query(input) abort
      if match(a:input, ';') == -1
        return [a:input]
      endif

      let input = substitute(a:input, ';', '', 'g')
      let trigger_count = len(a:input) - len(input)

      let arr = range(1, len(input) - 1)

      let result = []
      for ps in s:combinations(arr, trigger_count)
        let ps = reverse(ps)
        let str = input
        for p in ps
          let str = str[0 : p - 1] . ' ' . str[p : -1]
        endfor
        let result += [str]
      endfor

      return result
    endfunction

    lua require('hlslens').setup({auto_enable = true})

    nnoremap / <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 1})<CR>
    nnoremap ? <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 0})<CR>
    onoremap / <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 1})<CR>
    onoremap ? <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 0})<CR>
    xnoremap / <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 1})<CR>
    xnoremap ? <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 0})<CR>

    nnoremap ' <Cmd>call searchx#select()<CR>

    nnoremap <silent> n  <Cmd>call searchx#next_dir()<CR><Cmd>call SearchInfo(1, 1)<CR>zzzv
    nnoremap <silent> N  <Cmd>call searchx#prev_dir()<CR><Cmd>call SearchInfo(1, 1)<CR>zzzv
    nnoremap <silent> *  <Cmd>call Asterisk(1)<CR><Cmd>call SearchInfo(1, 1)<CR>
    xnoremap <silent> *  <Cmd>call Asterisk(1)<CR><Cmd>call SearchInfo(1, 1)<CR>
    nnoremap <silent> g* <Cmd>call Asterisk(0)<CR><Cmd>call SearchInfo(1, 1)<CR>
    xnoremap <silent> g* <Cmd>call Asterisk(0)<CR><Cmd>call SearchInfo(1, 1)<CR>

    function! SearchInfo(hlslens_start, anzu_update) abort
      lua require('hlslens').enable()
      if a:hlslens_start
        lua require('hlslens').start()
      endif

      if a:anzu_update
        AnzuUpdateSearchStatus
      endif
    endfunction

    function! Asterisk(is_whole) abort
      call feedkeys(asterisk#do(mode(1), {'direction': 1, 'do_jump': 0, 'is_whole': a:is_whole}), 'nit')
    endfunction

    function! s:change_fuzzy_motion() abort
      let input = getcmdline()
      call feedkeys("\<Esc>", 'nit')
      call timer_start(0, { -> feedkeys("\<Cmd>FuzzyMotion\<CR>" . substitute(input, ';', '', 'g'), 'nit') })
    endfunction

    function! s:search_enter() abort
      lua require('hlslens').start(true)

      cnoremap <C-s> <Cmd>call <SID>change_fuzzy_motion()<CR>
    endfunction

    function! s:search_leave() abort
      AnzuUpdateSearchStatus

      try
        cunmap <C-j>
        cunmap <C-k>
        cunmap <C-s>
      catch /.*/
      endtry
    endfunction

    function! s:search_changed() abort
      lua require('hlslens').disable()
      lua require('hlslens').enable()
      lua require('hlslens').start(true)
    endfunction

    function! s:search_cancel() abort
      lua require('hlslens').disable()
      AnzuClearSearchStatus

      try
        cunmap <C-j>
        cunmap <C-k>
        cunmap <C-s>
      catch /.*/
      endtry
    endfunction

    function! s:search_accept() abort
      call feedkeys("\<Cmd>set hlsearch\<CR>", 'n')
    endfunction

    AutoCmd User SearchxEnter                      call <SID>search_enter()
    AutoCmd User SearchxLeave                      call <SID>search_leave()
    AutoCmd User SearchxInputChanged               call <SID>search_changed()
    AutoCmd User SearchxCancel                     call <SID>search_cancel()
    AutoCmd User SearchxAccept,SearchxAcceptReturn call <SID>search_accept()
  endif
endif
" }}}3

" BackAndForward {{{3
if dein#tap('BackAndForward.vim')
  nmap <C-b> <Plug>(backandforward-back)
  nmap <C-f> <Plug>(backandforward-forward)
endif
" }}}3

" bookmarks {{{3
if dein#tap('vim-bookmarks')
  let g:bookmark_no_default_key_mappings = 1
  let g:bookmark_save_per_working_dir    = 1

  nnoremap <silent> <Plug>(bookmark)m <Cmd>BookmarkToggle<CR>
  nnoremap <silent> <Plug>(bookmark)i <Cmd>BookmarkAnnotate<CR>
  nnoremap <silent> <Plug>(bookmark)n <Cmd>BookmarkNext<CR>
  nnoremap <silent> <Plug>(bookmark)p <Cmd>BookmarkPrev<CR>
  nnoremap <silent> <Plug>(bookmark)a <Cmd>BookmarkShowAll<CR>
  nnoremap <silent> <Plug>(bookmark)c <Cmd>BookmarkClear<CR>
  nnoremap <silent> <Plug>(bookmark)x <Cmd>BookmarkClearAll<CR>

  function! g:BMWorkDirFileLocation() abort
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
endif
" }}}3

" caw {{{3
if dein#tap('caw.vim')
  let g:caw_integrated_plugin = 'ts_context_commentstring'

  nmap <silent> <expr> <Leader>cc <SID>caw_hatpos_toggle()
  xmap <silent> <expr> <Leader>cc <SID>caw_hatpos_toggle()
  nmap <silent> <expr> <Leader>cw <SID>caw_wrap_toggle()
  xmap <silent> <expr> <Leader>cw <SID>caw_wrap_toggle()

  function! s:caw_hatpos_toggle() abort
    if dein#tap('nvim-ts-context-commentstring')
      lua require('ts_context_commentstring.internal').update_commentstring()
      call caw#update_comments_from_commentstring(&commentstring)
    endif

    return "\<Plug>(caw:hatpos:toggle)"
  endfunction

  function! s:caw_wrap_toggle() abort
    if dein#tap('nvim-ts-context-commentstring')
      lua require('ts_context_commentstring.internal').update_commentstring()
      call caw#update_comments_from_commentstring(&commentstring)
    endif

    " jsx
    if index(['typescript','typescriptreact'], &filetype) >= 0 && &commentstring !=# '{/* %s */}'
      let b:caw_wrap_oneline_comment = ['/*', '*/']
    endif

    return "\<Plug>(caw:wrap:toggle)"
  endfunction

  " function! s:caw_hatpos_toggle(mode) abort
  "   if dein#tap('nvim-ts-context-commentstring')
  "     lua require('ts_context_commentstring.internal').update_commentstring()
  "   endif
  "
  "   call caw#keymapping_stub(a:mode, 'hatpos', 'toggle')
  " endfunction

  " function! s:caw_wrap_toggle(mode) abort
  "   let b:caw_wrap_oneline_comment = ["/*", "*/"]
  "   call caw#keymapping_stub(a:mode, 'wrap', 'toggle')
  "   unlet b:caw_wrap_oneline_comment
  " endfunction

  " autocmd FileType typescript,typescriptreact let b:caw_wrap_oneline_comment = ['/*', '*/']
endif
" }}}3

" Comment {{{3
if dein#tap('Comment.nvim')
lua << EOF
require('Comment').setup(
  {
    mappings = {
      basic = true,
    },
    toggler = {
      line = '<Leader>cc',
      block = '<Leader>bc',
    },
    opleader = {
      line = '<Leader>c',
      block = '<Leader>b',
    },
    pre_hook = function(ctx)
      return require('ts_context_commentstring.internal').calculate_commentstring()
    end,
  }
)
EOF
endif
" }}}3

" dps-dial {{{3
if dein#tap('dps-dial.vim')
  nmap <C-a>  <Plug>(dps-dial-increment)
  nmap <C-x>  <Plug>(dps-dial-decrement)
  xmap <C-a>  <Plug>(dps-dial-increment)
  xmap <C-x>  <Plug>(dps-dial-decrement)
  xmap g<C-a> g<Plug>(dps-dial-increment)
  xmap g<C-x> g<Plug>(dps-dial-decrement) 

  function! s:dps_dial_settings() abort
    let g:dps_dial#augends = ['decimal-integer', 'boolean', 'and_or', 'const_let', 'case', 'date', 'date-slash', 'color']
    call extend(g:dps_dial#aliases, {
    \ 'boolean': {
    \   'kind': 'constant',
    \   'opts': {
    \     'elements': ['true', 'false'],
    \     'word': v:true,
    \     'cyclic': v:true,
    \   },
    \ },
    \ 'and_or': {
    \   'kind': 'constant',
    \   'opts': {
    \     'elements': ['&&', '||'],
    \     'word': v:false,
    \     'cyclic': v:true,
    \   },
    \ },
    \ 'const_let': {
    \   'kind': 'constant',
    \   'opts': {
    \     'elements': ['const', 'let'],
    \     'word': v:true,
    \     'cyclic': v:true,
    \   },
    \ },
    \ })
  endfunction

  AutoCmd User DenopsPluginPost:dial call <SID>dps_dial_settings()
endif
" }}}3

" easy-align {{{3
if dein#tap('vim-easy-align')
  xmap ga <Plug>(EasyAlign)

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
endif
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
  nnoremap <Leader>f <Cmd>EftToggle<CR>

  function! s:eft_toggle() abort
    if g:eft_enable == 1
      let g:eft_enable = 0
      call <SID>eft_disable()
    else
      let g:eft_enable = 1
      call <SID>eft_enable()
    endif
  endfunction
  command! EftToggle call <SID>eft_toggle()

  function! s:eft_enable() abort
    nmap ;; <Plug>(eft-repeat)
    xmap ;; <Plug>(eft-repeat)
    omap ;; <Plug>(eft-repeat)

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

  function! s:eft_disable() abort
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

" exchange {{{3
if dein#tap('vim-exchange')
  xmap <silent> X <Plug>(Exchange)
endif
" }}}3

" expand-region {{{3
if dein#tap('vim-expand-region')
  let g:expand_region_text_objects = {
  \ 'iw': 0,
  \ 'i"': 1,
  \ 'a"': 1,
  \ "i'": 1,
  \ "a'": 1,
  \ 'i`': 1,
  \ 'a`': 1,
  \ 'i(': 1,
  \ 'a(': 1,
  \ 'i[': 1,
  \ 'a[': 1,
  \ 'i{': 1,
  \ 'if': 1,
  \ 'af': 1,
  \ 'ig': 1,
  \ 'ag': 1,
  \ 'i$': 1,
  \ 'a$': 1,
  \ 'a{': 1,
  \ 'i<': 1,
  \ 'a<': 1,
  \ 'iu': 1,
  \ 'au': 1,
  \ 'il': 0,
  \ 'ii': 1,
  \ 'ai': 1,
  \ 'ic': 0,
  \ 'ac': 0,
  \ 'ie': 0,
  \ }

  xmap v <Plug>(expand_region_expand)
  xmap V <Plug>(expand_region_shrink)
endif
" }}}3

" edgemotion {{{3
if dein#tap('vim-edgemotion')
  nmap <silent> <Leader>j <Cmd>normal! m`<CR><Plug>(edgemotion-j)
  nmap <silent> <Leader>k <Cmd>normal! m`<CR><Plug>(edgemotion-k)
  xmap <silent> <Leader>j <Cmd>normal! m`<CR><Plug>(edgemotion-j)
  xmap <silent> <Leader>k <Cmd>normal! m`<CR><Plug>(edgemotion-k)
  omap <silent> <Leader>j <Cmd>normal! m`<CR><Plug>(edgemotion-j)
  omap <silent> <Leader>k <Cmd>normal! m`<CR><Plug>(edgemotion-k)
endif
" }}}3

" fuzzy-motion {{{3
if dein#tap('fuzzy-motion.vim')
  let g:fuzzy_motion_word_regexp_list = ['[0-9a-zA-Z_-]+',  '([0-9a-zA-Z_-]|[.])+', '([0-9a-zA-Z]|[()<>.-_#''"]|(\s=+\s)|(,\s)|(:\s)|(\s=>\s))+']

  nnoremap <silent> ss <Cmd>FuzzyMotion<CR>
  onoremap <silent> ss <Cmd>FuzzyMotion<CR>
  xnoremap <silent> ss <Cmd>FuzzyMotion<CR>
endif
" }}}3

" gomove {{{3
if dein#tap('nvim-gomove')
lua << EOF
require("gomove").setup {
  map_defaults = true,
  reindent_mode = 'none',
}
EOF

  xmap <silent> <C-h> <Plug>GoVSMLeft
  xmap <silent> <C-k> <Plug>GoVSMUp
  xmap <silent> <C-j> <Plug>GoVSMDown
  xmap <silent> <C-l> <Plug>GoVSMRight
endif
" }}}3

" grepper {{{3
if dein#tap('vim-grepper')
  let g:grepper = {
  \ 'tools': ['rg', 'git'],
  \ }

  let g:grepper.rg = {
  \ 'escape': '\^$.*+?()[]{}|',
  \ 'grepformat': '%f:%l:%c:%m,%f',
  \ 'grepprg': 'rg --with-filename --sort=path --no-heading --vimgrep'
  \ }

  nnoremap <silent> <Leader>g <Cmd>GrepperRg<CR>
endif
" }}}3

" hop {{{3
if dein#tap('hop.nvim')
lua << EOF
require'hop'.setup()
EOF
  nnoremap <silent> S  <Cmd>HopWord<CR>
  nnoremap <silent> ss <Cmd>HopWord<CR>
endif
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  nmap <silent> J         <Plug>(jplus)
  xmap <silent> J         <Plug>(jplus)
  nmap <silent> <Leader>J <Plug>(jplus-input)
  xmap <silent> <Leader>J <Plug>(jplus-input)
endif
" }}}3

" kommentary {{{3
if dein#tap('kommentary')
  let g:kommentary_create_default_mappings = v:false

  nmap <silent> <Leader>cc <Plug>kommentary_line_default
  nmap <silent> <Leader>c  <Plug>kommentary_motion_default
  xmap <silent> <Leader>cc <Plug>kommentary_visual_default

lua << EOF
require('kommentary.config').configure_language('typescriptreact', {
  single_line_comment_string = 'auto',
  multi_line_comment_strings = 'auto',
  hook_function = function()
    require('ts_context_commentstring.internal').update_commentstring()
  end,
})
EOF
endif
" }}}3

" lexima {{{3
if dein#tap('lexima.vim')
  " let g:lexima_map_escape = ''
  let g:lexima_enable_endwise_rules = 0

  function! SetupLexima() abort
    call <SID>setup_lexima_insert()
    call <SID>setup_lexima_cmdline()
  endfunction

  function! s:setup_lexima_insert() abort
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
    \ { 'char': '<C-f>',                   'input': '<Right>'                },
    \ { 'char': '<C-f>', 'at': '\%#\s*)',  'input': '<Left><C-o>f)<Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*\}', 'input': '<Left><C-o>f}<Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*\]', 'input': '<Left><C-o>f]<Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*>',  'input': '<Left><C-o>f><Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*`',  'input': '<Left><C-o>f`<Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*"',  'input': '<Left><C-o>f"<Right>',  },
    \ { 'char': '<C-f>', 'at': '\%#\s*''', 'input': '<Left><C-o>f''<Right>', },
    \ ]

    "" Insert semicolon at the end of the line
    let s:rules += [
    \ { 'char': ';', 'at': '(.*;\%#)$',   'input': '<BS><Right>;' },
    \ { 'char': ';', 'at': '^\s*;\%#)$',  'input': '<BS><Right>;' },
    \ { 'char': ';', 'at': '(.*;\%#\}$',  'input': '<BS><Right>;' },
    \ { 'char': ';', 'at': '^\s*;\%#\}$', 'input': '<BS><Right>;' },
    \ ]

    "" TypeScript
    let s:rules += [
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\s([a-zA-Z, ]*>\%#)',            'input': '<BS><Left><C-o>f)<Right>a=> {}<Esc>',                 },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\s([a-zA-Z]\+>\%#)',             'input': '<BS><Right> => {}<Left>',              'priority': 10 },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '[a-z]((.*>\%#.*))',              'input': '<BS><Left><C-o>f)a => {}<Esc>',                       },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '[a-z]([a-zA-Z]\+>\%#)',          'input': '<BS> => {}<Left>',                                    },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '(.*[a-zA-Z]\+<[a-zA-Z]\+>>\%#)', 'input': '<BS><Left><C-o>f)<Right>a=> {}<Left>',                },
    \ ]

    "" TSX with nvim-ts-autotag
    if dein#tap('nvim-ts-autotag')
      let s:rules += [
      \ { 'filetype': ['typescriptreact'], 'char': '>', 'input': '><Esc>:lua require(''nvim-ts-autotag.internal'').close_tag()<CR>a', },
      \ ]
    endif

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
  endfunction

  function! s:setup_lexima_cmdline() abort
    LeximaAlterCommand ee                 e!
    LeximaAlterCommand er                 update<Space><Bar><Space>e!
    LeximaAlterCommand dp                 diffput
    LeximaAlterCommand js\%[on]           JSON
    LeximaAlterCommand dein               Dein
    LeximaAlterCommand or\%[ganizeimport] OrganizeImport
    LeximaAlterCommand todo               CocCommand<Space>fzf-preview.TodoComments
    LeximaAlterCommand memo               CocCommand<Space>fzf-preview.MemoList
    LeximaAlterCommand git                Gina
    LeximaAlterCommand gina               Gina
    LeximaAlterCommand gs                 Gina<Space>status
    LeximaAlterCommand gci                Gina<Space>commit<Space>--no-verify
    LeximaAlterCommand gd                 Gina<Space>diff
    LeximaAlterCommand gdc                Gina<Space>diff<Space>--cached
    LeximaAlterCommand gco                Gina<Space>checkout
    LeximaAlterCommand log                Gina<Space>log
    LeximaAlterCommand blame              Gina<Space>blame
    LeximaAlterCommand bro\%[wse]         Gina<Space>browse<Space>--exact<Space>:
    LeximaAlterCommand grep               GrepperRg
    LeximaAlterCommand replacer           lua<Space>require('replacr').run()
    LeximaAlterCommand sc\%[ratch]        Scratch
    LeximaAlterCommand ss                 SaveProjectLayout
    LeximaAlterCommand sl                 LoadProjectLayout
    LeximaAlterCommand vis\%[ta]          Vista
    LeximaAlterCommand cap\%[ture]        Capture
    LeximaAlterCommand te\%[st]           Ultest
    LeximaAlterCommand tn\%[ear]          UltestNearest
    LeximaAlterCommand ts\%[ummary]       UltestSummary
    LeximaAlterCommand r\%[un]            QuickRun
  endfunction

  function! s:lexima_alter_command(original, altanative) abort
    let input_space = '<C-w>' . a:altanative . '<Space>'
    let input_cr    = '<C-w>' . a:altanative . '<CR>'

    let rule = {
    \ 'mode': ':',
    \ 'at': '^\(''<,''>\)\?' . a:original . '\%#',
    \ }

    call lexima#add_rule(extend(rule, { 'char': '<Space>', 'input': input_space }))
    call lexima#add_rule(extend(rule, { 'char': '<CR>',    'input': input_cr    }))
  endfunction

  command! -nargs=+ LeximaAlterCommand call <SID>lexima_alter_command(<f-args>)
endif
" }}}3

" lightspeed {{{3
if dein#tap('lightspeed.nvim')
  lua require('lightspeed').setup({})

  nmap <silent> ss <Plug>Lightspeed_s
  xmap <silent> ss <Plug>Lightspeed_s
  omap <silent> ss <Plug>Lightspeed_s
  nmap <silent> S  <Plug>Lightspeed_S
  xmap <silent> S  <Plug>Lightspeed_S
  omap <silent> S  <Plug>Lightspeed_S
endif
" }}}3

" numb {{{3
if dein#tap('numb.nvim')
lua << EOF
require('numb').setup()
EOF
endif
" }}}3

" quick-scope {{{3
" let g:qs_buftype_blacklist = ['terminal', 'nofile']
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich') &&
   \ dein#tap('vim-textobj-functioncall')
  let g:textobj_sandwich_no_default_key_mappings     = 1
  let g:textobj_functioncall_no_default_key_mappings = 1

  omap <silent> ib <Plug>(textobj-sandwich-auto-i)
  xmap <silent> ib <Plug>(textobj-sandwich-auto-i)
  omap <silent> ab <Plug>(textobj-sandwich-auto-a)
  xmap <silent> ab <Plug>(textobj-sandwich-auto-a)

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
  \   'buns':     ['${', '}'],
  \   'input':    ['$'],
  \   'filetype': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
  \ },
  \ {
  \   'buns':     ['#{', '}'],
  \   'input':    ['#'],
  \   'filetype': ['ruby', 'eruby'],
  \ },
  \ {
  \   'buns':     ['-> () {', '}'],
  \   'input':    ['->'],
  \   'kind':     ['add'],
  \   'filetype': ['ruby', 'eruby'],
  \ },
  \ {
  \   'buns':     ['<% ', ' %>'],
  \   'input':    ['%'],
  \   'filetype': ['eruby'],
  \ },
  \ {
  \   'buns':     ['<%= ', ' %>'],
  \   'input':    ['='],
  \   'filetype': ['eruby'],
  \ },
  \ ]

  let g:textobj_functioncall_patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '(',
  \   'ket'    : ')',
  \   'footer' : '',
  \ },
  \ ]

  omap <silent> if <Plug>(textobj-functioncall-innerparen-i)
  xmap <silent> if <Plug>(textobj-functioncall-innerparen-i)
  omap <silent> af <Plug>(textobj-functioncall-i)
  xmap <silent> af <Plug>(textobj-functioncall-i)

  let g:sandwich#magicchar#f#patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '(',
  \   'ket'    : ')',
  \   'footer' : '',
  \ },
  \ ]

  " nmap <silent> srf <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)ff

  let g:textobj_functioncall_generics_patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '<',
  \   'ket'    : '>',
  \   'footer' : '',
  \ },
  \ ]

  onoremap <silent> <Plug>(textobj-functioncall-generics-i) :<C-u>call textobj#functioncall#ip('o', g:textobj_functioncall_generics_patterns)<CR>
  xnoremap <silent> <Plug>(textobj-functioncall-generics-i) :<C-u>call textobj#functioncall#ip('x', g:textobj_functioncall_generics_patterns)<CR>
  onoremap <silent> <Plug>(textobj-functioncall-generics-a) :<C-u>call textobj#functioncall#i('o', g:textobj_functioncall_generics_patterns)<CR>
  xnoremap <silent> <Plug>(textobj-functioncall-generics-a) :<C-u>call textobj#functioncall#i('x', g:textobj_functioncall_generics_patterns)<CR>

  omap <silent> ig <Plug>(textobj-functioncall-generics-i)
  xmap <silent> ig <Plug>(textobj-functioncall-generics-i)
  omap <silent> ag <Plug>(textobj-functioncall-generics-a)
  xmap <silent> ag <Plug>(textobj-functioncall-generics-a)

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
  \   'external': ['i<', "\<Plug>(textobj-functioncall-generics-a)"],
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

  " nmap <silent> srg <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)gg

  let g:textobj_functioncall_ts_string_variable_patterns = [
  \ {
  \   'header' : '\$',
  \   'bra'    : '{',
  \   'ket'    : '}',
  \   'footer' : '',
  \ },
  \ ]

  onoremap <silent> <Plug>(textobj-functioncall-ts-string-variable-i) :<C-u>call textobj#functioncall#i('o', g:textobj_functioncall_ts_string_variable_patterns)<CR>
  xnoremap <silent> <Plug>(textobj-functioncall-ts-string-variable-i) :<C-u>call textobj#functioncall#i('x', g:textobj_functioncall_ts_string_variable_patterns)<CR>
  onoremap <silent> <Plug>(textobj-functioncall-ts-string-variable-a) :<C-u>call textobj#functioncall#a('o', g:textobj_functioncall_ts_string_variable_patterns)<CR>
  xnoremap <silent> <Plug>(textobj-functioncall-ts-string-variable-a) :<C-u>call textobj#functioncall#a('x', g:textobj_functioncall_ts_string_variable_patterns)<CR>

  omap <silent> i$ <Plug>(textobj-functioncall-ts-string-variable-i)
  xmap <silent> i$ <Plug>(textobj-functioncall-ts-string-variable-i)
  omap <silent> a$ <Plug>(textobj-functioncall-ts-string-variable-a)
  xmap <silent> a$ <Plug>(textobj-functioncall-ts-string-variable-a)
endif
" }}}3

" scratch {{{3
if dein#tap('scratch.vim')
  let g:scratch_no_mappings = 1
endif
" }}}3

" seak {{{3
if dein#tap('vim-seak')
  let g:seak_enabled     = v:true
  let g:seak_marks       = split('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '.\zs')
  let g:seak_auto_accept = { 'nohlsearch': v:true }
endif
" }}}3

" shot-f {{{3
if dein#tap('vim-shot-f')
  let g:shot_f_no_default_key_mappings = 1
  nmap <silent> f <Plug>(shot-f-f)
  nmap <silent> F <Plug>(shot-f-F)
endif
" }}}3

" smart-cursor {{{3
if dein#tap('smart-cursor.nvim')
  nnoremap <silent> o o<Esc>:lua require('smart-cursor').indent_cursor()<CR>i
  nnoremap <silent> O O<Esc>:lua require('smart-cursor').indent_cursor()<CR>i
endif
" }}}3

" smart-word {{{3
if dein#tap('vim-smartword')
  nmap w  <Plug>(smartword-w)
  nmap b  <Plug>(smartword-b)
  nmap e  <Plug>(smartword-e)
  nmap ge <Plug>(smartword-ge)
endif
" }}}3

" tcomment {{{3
if dein#tap('tcomment_vim')
  let g:tcomment_maps = 0

  noremap <silent> <Leader>cc :TComment<CR>
endif
" }}}3

" textmanip {{{3
if dein#tap('vim-textmanip')
  xmap <C-j> <Plug>(textmanip-move-down)
  xmap <C-k> <Plug>(textmanip-move-up)
  xmap <C-h> <Plug>(textmanip-move-left)
  xmap <C-l> <Plug>(textmanip-move-right)
endif
" }}}3

" ts-autotag {{{3
if dein#tap('nvim-ts-autotag')
  lua require('nvim-ts-autotag').setup()

  AutoCmd FileType typescript,typescriptreact iunmap <buffer> >
endif
" }}}3

" trip {{{3
if dein#tap('vim-trip')
  nmap <C-a> <Plug>(trip-increment)
  nmap <C-x> <Plug>(trip-decrement)
endif
" }}}3

" ultisnips {{{3
if dein#tap('ultisnips')
  let g:UltiSnipsSnippetDirectories  = ['~/.vim/ultisnips']

  AutoCmd BufNewFile,BufRead *.snippets setf snippets
endif
" }}}3

" vim-backslash {{{3
if dein#tap('vim-backslash')
  let g:vim_backslash_disable_default_mappings = 1

  function! s:vim_backslash_settings() abort
    nmap <silent> <buffer> o <Plug>(vim-backslash-o)
    nmap <silent> <buffer> O <Plug>(vim-backslash-O)

    imap <silent> <expr> <buffer> <CR> pumvisible() ? '<C-Y>' : vim_backslash#is_continuous_cr() ? '<Plug>(vim-backslash-smart-CR-i)' : lexima#expand('<CR>', 'i')
  endfunction

  AutoCmd FileType vim call <SID>vim_backslash_settings()
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
  nmap <silent> <expr> <C-p> yankround#is_active() ? '<Plug>(yankround-prev)' : '<Plug>(ctrlp)'
  nmap <silent> <expr> <C-n> yankround#is_active() ? '<Plug>(yankround-next)' : ""
endif
" }}}3

" zero {{{3
if dein#tap('zero.nvim')
  lua require('zero').setup()
endif
" }}}3

" }}}2

" Appearance {{{2

" better-whitespace {{{3
if dein#tap('vim-better-whitespace')
  let g:better_whitespace_filetypes_blacklist = [
  \ 'markdown',
  \ 'diff',
  \ 'qf',
  \ 'help',
  \ 'gitcommit',
  \ 'gitrebase',
  \ 'denite',
  \ ]
endif
" }}}3

" brightest {{{3
if dein#tap('vim-brightest')
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
endif
" }}}3

" bufresize {{{3
if dein#tap('bufresize.nvim')
  lua require("bufresize").setup()
endif
" }}}3

" choosewin {{{3
if dein#tap('vim-choosewin')
  let s:choosewin_nord = ['#81A1C1', '#4C566A']
  let g:choosewin_color_label = {
  \ 'gui': s:choosewin_nord + ['bold'],
  \ 'cterm': [4, 8]
  \ }
endif
" }}}3

" comfortable-motion {{{3
if dein#tap('comfortable-motion.vim')
  let g:comfortable_motion_no_default_key_mappings = 1
  let g:comfortable_motion_enable = 0

  function! s:comfortable_motion_toggle() abort
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
if dein#tap('context.vim')
  let g:context_enabled = 0
endif
" }}}3

" foldCC {{{3
if dein#tap('foldCC.vim')
  set foldtext=FoldCCtext()
endif
" }}}3

" highlightedput {{{3
if dein#tap('vim-highlightedput')
  nmap p <Plug>(highlightedput-p)
  xmap p <Plug>(highlightedput-p)
  nmap P <Plug>(highlightedput-P)
  xmap P <Plug>(highlightedput-P)
endif
" }}}3

" highlightedundo {{{3
if dein#tap('vim-highlightedundo')
  let g:highlightedundo_enable         = 1
  let g:highlightedundo#highlight_mode = 2

  function! s:highlightedundo_toggle() abort
    if g:highlightedundo_enable == 1
      let g:highlightedundo_enable = 0
      call <SID>highlightedundo_disable()
    else
      let g:highlightedundo_enable = 1
      call <SID>highlightedundo_enable()
    endif
  endfunction
  command! HighlightedundoToggle call <SID>highlightedundo_toggle()

  function! s:highlightedundo_enable() abort
    nmap <silent> u     <Plug>(highlightedundo-undo)
    nmap <silent> <C-r> <Plug>(highlightedundo-redo)
  endfunction

  function! s:highlightedundo_disable() abort
    nunmap u
    nunmap <C-r>
  endfunction

  AutoCmd VimEnter * call <SID>highlightedundo_enable()
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
  "     autocmd TextYankPost * call timer_start(g:highlightedyank_highlight_duration, function('<SID>highlight_yank_leave'))
  "   augroup END
  " endfunction
  "
  " function! s:highlight_yank_leave(...) abort
  "   augroup highlight_yank
  "     setlocal list listchars+=eol:$
  "   augroup END
  " endfunction
  "
  " call timer_start(g:highlightedyank_highlight_duration, function('<SID>highlight_yank_enter'))
endif
" }}}3

" indent-line {{{3
if dein#tap('indentLine')
  let g:indentLine_enabled = 0
  let g:indentLine_fileTypeExclude = ['json', 'defx', 'fern']
endif
" }}}3

" layout {{{3
if dein#tap('vim-layout')
  function! s:project_layout_file() abort
    return substitute(trim(system('git branch --show-current')), '/', '_', 'g') . '_layout.json'
  endfunction

  function! s:save_project_layout() abort
    if isdirectory(getcwd() . '/.git')
      call layout#save(getcwd() . '/.git/' . <SID>project_layout_file())
    else
      echoerr 'Not git project'
    endif
  endfunction

  function! s:load_project_layout() abort
    if filereadable(getcwd() . '/.git/' . <SID>project_layout_file())
      call layout#load(getcwd() . '/.git/' . <SID>project_layout_file())
    else
      echoerr 'Undefined layout file'
    endif
  endfunction

  command! SaveProjectLayout call <SID>save_project_layout()
  command! LoadProjectLayout call <SID>load_project_layout()
endif
" }}}3

" lightline {{{3
if dein#tap('lightline.vim')
  let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ 'active': {
  \   'left': [
  \     ['mode', 'spell', 'paste'],
  \     ['filepath', 'filename', 'modified_buffers'],
  \     ['special_mode', 'anzu', 'vm_regions'],
  \    ],
  \   'right': [
  \     ['lineinfo'],
  \     ['filetype', 'fileencoding', 'fileformat'],
  \     ['linter_ok', 'linter_informations', 'linter_warnings', 'linter_errors'],
  \     ['quickrun'],
  \     ['coc_status'],
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
  \   'mode':             'LightlineMode',
  \   'filepath':         'LightlineFilePath',
  \   'filename':         'LightlineFileName',
  \   'modified_buffers': 'LightlineModifiedBuffers',
  \   'filetype':         'LightlineFileType',
  \   'lineinfo':         'LightlineLineInfo',
  \   'fileencoding':     'LightlineFileEncoding',
  \   'fileformat':       'LightlineFileFormat',
  \   'special_mode':     'LightlineSpecialMode',
  \   'coc_status':       'LightlineCocStatus',
  \   'anzu':             'anzu#search_status',
  \   'quickrun':         'LightlineQuickrunRunnning',
  \   'vm_regions':       'Lightline_vm_regions',
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum': 'LightlineTabWinNum',
  \ },
  \ 'component_visible_condition': {
  \   'anzu':       "%{anzu#search_status !=# ''}",
  \   'vm_regions': "%{Lightline_vm_regions() !=# ''}",
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
  \   'quickrun':            'quickrun',
  \ },
  \ 'component_expand': {
  \   'linter_errors':       'LightlineCocErrors',
  \   'linter_warnings':     'LightlineCocWarnings',
  \   'linter_informations': 'LightlineCocInformations',
  \   'linter_hint':         'LightlineCocHint',
  \   'linter_ok':           'LightlineCocOk',
  \   'quickrun':            'LightlineQuickrunRunnning',
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

  function! LightlineIsVisible(width) abort
    return a:width < winwidth(0)
  endfunction

  function! LightlineMode() abort
    return lightline#mode()
  endfunction

  function! LightlineSpecialMode() abort
    let special_mode = get(s:lightline_ft_to_mode_hash, &filetype, '')
    let win = getwininfo(win_getid())[0]
    return special_mode !=# '' ? special_mode :
    \ anzu#search_status() !=# '' ? 'Anzu' :
    \ LightlineFileType() ==# '' ? '' :
    \ win.loclist ? '[Location List] ' . get(w:, 'quickfix_title', ''):
    \ win.quickfix ? '[QuickFix] ' . get(w:, 'quickfix_title', '') :
    \ ''
  endfunction

  function! LightlineFilePath() abort
    if count(s:lightline_ignore_filepath_ft, &filetype) || expand('%:t') ==# '[Command Line]'
      return ''
    endif

    let path = fnamemodify(expand('%'), ':p:.:h')
    return path ==# '.' ? '' : path

    let not_home_prefix = match(path, '^/') != -1 ? '/' : ''
    let dirs            = split(path, '/')
    let last_dir        = remove(dirs, -1)
    call map(dirs, 'v:val[0]')

    return len(dirs) ? not_home_prefix . join(dirs, '/') . '/' . last_dir : last_dir
  endfunction

  function! LightlineFileName() abort
    let filename = fnamemodify(expand('%'), ':t')

    if count(s:lightline_ignore_filename_ft, &filetype)
      return ''
    endif

    if filename ==# ''
      let filename = '[No Name]'
    endif

    if &modifiable && &modified
      let filename = filename . ' [+]'
    endif

    if !&modifiable
      let filename = filename . ' [X]'
    endif

    return filename
  endfunction

  function! LightlineModifiedBuffers() abort
    let modified_background_buffers = filter(range(1, bufnr('$')),
    \ { _, bufnr -> bufexists(bufnr) && buflisted(bufnr) && getbufvar(bufnr, 'buftype') ==# '' && filereadable(expand('#' . bufnr . ':p')) && bufnr != bufnr('%') && getbufvar(bufnr, '&modified') == 1 }
    \ )

    if count(s:lightline_ignore_filename_ft, &filetype)
      return ''
    endif

    if len(modified_background_buffers) > 0
      return '!' . len(modified_background_buffers)
    else
      return ''
    endif
  endfunction

  function! LightlineFileType() abort
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

  function! LightlineLineInfo() abort
    if !LightlineIsVisible(100)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ printf(' %3d:%2d / %d lines [%d%%]', line('.'), col('.'), line('$'), float2nr((1.0 * line('.')) / line('$') * 100.0)) :
    \ ''
  endfunction

  function! LightlineFileEncoding() abort
    if !LightlineIsVisible(140)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ strlen(&fileencoding) ?
    \   &fileencoding :
    \   &encoding :
    \ ''
  endfunction

  function! LightlineFileFormat() abort
    if !LightlineIsVisible(140)
      return ''
    endif

    return !count(s:lightline_ignore_right_ft, &filetype) ?
    \ &fileformat :
    \ ''
  endfunction

  function! LightlineTabWinNum(n) abort
    return a:n . ':' . len(tabpagebuflist(a:n))
  endfunction

  function! LightlineCocErrors() abort
    return b:coc_diagnostic_info['error'] != 0 ? ' ' . b:coc_diagnostic_info['error'] : ''
  endfunction

  function! LightlineCocWarnings() abort
    return b:coc_diagnostic_info['warning'] != 0 ? ' ' . b:coc_diagnostic_info['warning'] : ''
  endfunction

  function! LightlineCocInformations() abort
    return b:coc_diagnostic_info['information'] != 0 ? ' ' . b:coc_diagnostic_info['information'] : ''
  endfunction

  function! LightlineCocHint() abort
    return b:coc_diagnostic_info['hint'] != 0 ? ' ' . b:coc_diagnostic_info['hint'] : ''
  endfunction

  function! LightlineCocOk() abort
    return b:coc_diagnostic_info['error'] == 0 &&
    \ b:coc_diagnostic_info['warning'] == 0 &&
    \ b:coc_diagnostic_info['information'] == 0 ?
    \ ' ' : ''
  endfunction

  function! LightlineCocStatus() abort
    return get(g:, 'coc_status', '')
  endfunction

  function! LightlineQuickrunRunnning() abort
    return g:quickrun_running_message
  endfunction

  function! NearestMethodOrFunction() abort
    if !LightlineIsVisible(140)
      return ''
    endif
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction

  AutoCmd User CocDiagnosticChange call lightline#update()
endif
" }}}3

" matchup {{{3
if dein#tap('vim-matchup')
  let g:matchup_matchparen_status_offscreen = 0
endif
" }}}3

" neoscroll {{{3
if dein#tap('neoscroll.nvim')
  " lua require('neoscroll').setup({ mappings = {"<C-u>", "<C-d>"}})
endif
" }}}3

" nvim-colorizer {{{3
if dein#tap('nvim-colorizer.lua')
  lua require('colorizer').setup()
endif
" }}}3

" package-info {{{3
if dein#tap('package-info.nvim')
  lua require('package-info').setup()
endif
" }}}3

" quickr-preview {{{3
if dein#tap('quickr-preview.vim')
  let g:quickr_preview_keymaps = 0

  AutoCmd FileType qf nmap <silent> <buffer> p <Plug>(quickr_preview)
  AutoCmd FileType qf nmap <silent> <buffer> q <Plug>(quickr_preview_qf_close)
endif
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
  nnoremap <Leader>n <Cmd>SNToggle<CR>

  function! s:snumber_relative_toggle() abort
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

" todo-comments {{{3
if dein#tap('todo-comments.nvim')
lua << EOF
require("todo-comments").setup {
  signs = false
}
EOF
endif
" }}}3

" vista {{{3
if dein#tap('vista.vim')
  if dein#tap('coc.nvim')
    let g:vista_default_executive = 'coc'
  endif

  let g:vista_sidebar_width          = 50
  let g:vista_echo_cursor_strategy   = 'both'
  let g:vista_update_on_text_changed = 1
  let g:vista_blink                  = [1, 100]

  nnoremap <silent> <Leader>v <Cmd>Vista<CR>

  AutoCmd VimEnter * call vista#RunForNearestMethodOrFunction()
endif
" }}}3

" }}}2

" tmux {{{2
"
" tmux.nvim {{{3
if dein#tap('tmux.nvim')
lua << EOF
require("tmux").setup({
  copy_sync = {
    enable = false,
  },
  navigation = {
    enable_default_keybindings = true,
    cycle_navigation = true,
  },
  resize = {
    enable_default_keybindings = false,
  }
})
EOF
endif
" }}}3

" }}}2

" Util {{{2

" aho-bakaup {{{3
if dein#tap('aho-bakaup.vim')
  let g:bakaup_auto_backup = 1
  let g:bakaup_backup_dir  = expand('~/.cache/vim/backup')
endif
" }}}3

" automatic {{{
if dein#tap('vim-automatic')
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
endif
" }}}

" auto-session {{{3
if dein#tap('auto-session')
  if !isdirectory(expand('~/.cache/vim/auto-session'))
    call mkdir(expand('~/.cache/vim/auto-session'), 'p')
  endif
  let g:auto_session_root_dir = expand('~/.cache/vim/auto-session')
endif
" }}}3

" bbye {{{3
if dein#tap('vim-bbye')
  nnoremap <silent> <Leader>d <Cmd>Bdelete!<CR>
endif
" }}}3

" capture {{{3
if dein#tap('capture.vim')
  AutoCmd FileType capture nnoremap <silent> <buffer> q <Cmd>quit<CR>
endif
" }}}3

" dial {{{3
if dein#tap('dial.nvim')
  nmap <C-a>  <Plug>(dial-increment)
  nmap <C-x>  <Plug>(dial-decrement)
  xmap <C-a>  <Plug>(dial-increment)
  xmap <C-x>  <Plug>(dial-decrement)
  xmap g<C-a> <Plug>(dial-increment-additional)
  xmap g<C-x> <Plug>(dial-decrement-additional)
lua << EOF
local dial = require("dial")

dial.augends["custom#boolean"] = dial.common.enum_cyclic{
  name = "boolean",
  strlist = {"true", "false"},
}
dial.augends["custom#and_or"] = dial.common.enum_cyclic{
  name = "and_or",
  strlist = {"&&", "||"},
  ptn_format = "\\C\\M\\(%s\\)",
}
table.insert(dial.config.searchlist.normal, "custom#boolean")
table.insert(dial.config.searchlist.normal, "custom#and_or")
EOF
endif
" }}}3

" floaterm {{{3
if dein#tap('vim-floaterm')
  let g:floaterm_width       = 0.8
  let g:floaterm_height      = 0.8
  let g:floaterm_winblend    = 15
  let g:floaterm_position    = 'center'

  nnoremap <silent> <C-s> <Cmd>FloatermToggle<CR>

  AutoCmd FileType floaterm call <SID>floaterm_settings()
  AutoCmd FileType gitrebase call <SID>set_git_rebase_settings()

  function! s:floaterm_settings() abort
    tnoremap <silent> <buffer> <C-s> <C-\><C-n>:FloatermToggle<CR>
    let b:highlight_cursor = 0
  endfunction

  function! s:set_git_rebase_settings() abort
    set winhighlight=Normal:GitRebase
    set winblend=30

    nnoremap <silent> <buffer> <Leader>d :bdelete!<Space><Bar><Space>close<CR>
  endfunction
endif
" }}}3

" memolist {{{3
if dein#tap('memolist.vim')
  let g:memolist_path = '~/.config/memolist'
endif
" }}}3

" previm {{{3
if dein#tap('previm')
  let g:previm_open_cmd            = 'open -a "Firefox"'
  let g:previm_disable_default_css = 1
  let g:previm_custom_css_path     = '~/.config/previm/gfm.css'
endif
" }}}3

" silicon {{{3
if dein#tap('vim-silicon')
  let g:silicon = {
  \   'theme':           'Monokai Extended',
  \   'background':      '#97A1AC',
  \   'shadow-color':    '#555555',
  \   'line-number':     v:false,
  \   'round-corner':    v:true,
  \   'window-controls': v:true,
  \   'output':          '~/Downloads/silicon-{time:%Y-%m-%d-%H%M%S}.png',
  \ }
endif
" }}}3

" test {{{3
if dein#tap('vim-test') &&
   \ dein#tap('vim-ultest')
  let g:ultest_use_pty = 1
endif
" }}}3

" toggleterm {{{3
if dein#tap('toggleterm.nvim')
  lua require('toggleterm').setup{}

  nnoremap <silent> <C-s><C-s> <Cmd>ToggleTerm direction=float<CR>
  nnoremap <silent> <C-s>s     <Cmd>ToggleTerm direction=horizontal size=<C-r>=float2nr(&lines * 0.4)<CR><CR>
  nnoremap <silent> <C-s>v     <Cmd>ToggleTerm direction=vertical size=<C-r>=float2nr(&columns * 0.3)<CR><CR>
  nnoremap <silent> <C-s>p     <Cmd>ToggleTerm direction=float<CR>


  function! s:toggleterm_settings() abort
    tnoremap <silent> <nowait> <buffer> <C-s> <C-\><C-n>:close<CR>
  endfunction

  AutoCmd FileType toggleterm call <SID>toggleterm_settings()
endif
" }}}3

" undotree {{{3
if dein#tap('undotree')
  nnoremap <silent> <Leader>u <Cmd>UndotreeToggle<CR>
endif
" }}}3

" which-key {{{3
if dein#tap('vim-which-key')
  nnoremap <silent> <Leader><CR>      <Cmd>WhichKey '<Leader>'<CR>
  nnoremap <silent> <Plug>(dev)<CR>   <Cmd>WhichKey '<Plug>(dev)'<CR>
  nnoremap <silent> <Plug>(fzf-p)<CR> <Cmd>WhichKey '<Plug>(fzf-p)'<CR>
  nnoremap <silent> <Plug>(t)<CR>     <Cmd>WhichKey '<Plug>(t)'<CR>
  nnoremap <silent> s<CR>             <Cmd>WhichKey 's'<CR>
  nnoremap <silent> <bookmark><CR>    <Cmd>WhichKey '<bookmark>'<CR>
endif
" }}}3

" wilder {{{3
if dein#tap('wilder.nvim')
  function! SetUpWilder() abort
    call wilder#set_option('pipeline', [
    \ wilder#branch(
    \   wilder#python_file_finder_pipeline({
    \     'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H', '--strip-cwd-prefix'] : ['fd', '-tf', '--strip-cwd-prefix']},
    \     'dir_command': ['fd', '-td'],
    \   }),
    \   wilder#cmdline_pipeline({'fuzzy': 1}),
    \   [
    \     wilder#check({_, x -> empty(x)}),
    \     wilder#history(),
    \   ],
    \   wilder#python_search_pipeline({
    \     'pattern': wilder#python_fuzzy_pattern({
    \       'start_at_boundary': 0,
    \     }),
    \   }),
    \   wilder#vim_search_pipeline()
    \ ),
    \ ])

    let wilder_cmd_line_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'winblend': 20,
    \ 'highlighter': wilder#basic_highlighter(),
    \ 'highlights': {
    \   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#e27878', 'bold': v:true, 'underline': v:true}]),
    \   'selected_accent': wilder#make_hl('WilderSelectedAccent', 'PmenuSel', [{}, {}, {'foreground': '#e27878', 'bold': v:true, 'underline': v:true}]),
    \ },
    \ 'left': [wilder#popupmenu_devicons({'get_hl': wilder#devicons_get_hl_from_glyph_palette_vim()}), wilder#popupmenu_buffer_flags({'flags': ' '})],
    \ }))

    let wilder_search_renderer = wilder#wildmenu_renderer({
    \ 'highlighter': wilder#basic_highlighter(),
    \ 'separator': '  ',
    \ 'left': [' '],
    \ 'right': [' ', wilder#wildmenu_index()],
    \ })

    call wilder#setup({
    \ 'modes': [':', '/', '?'],
    \ 'accept_key': '<C-e>',
    \ })

    call wilder#set_option(
    \ 'renderer',
    \ wilder#renderer_mux({
    \   ':': wilder_cmd_line_renderer,
    \   '/': wilder_search_renderer,
    \   '?': wilder_search_renderer,
    \ })
    \ )
  endfunction
endif
" }}}3

" windowswap {{{3
if dein#tap('vim-windowswap')
  let g:windowswap_map_keys = 0
  nnoremap <silent> <Leader><C-w> :call WindowSwap#EasyWindowSwap()<CR>
endif
" }}}3

" }}}2

" Develop {{{2

" quickrun {{{3
if dein#tap('vim-quickrun')
  let s:notify_hook = {}
  let g:quickrun_running_message = ''
  let g:quickrun_notify_success_message = ''
  let g:quickrun_notify_error_message = ''

  function! s:notify_hook.on_ready(session, context) abort
    let g:quickrun_running_message = '[QuickRun] Running ' . a:session.config.command

    if dein#tap('lightline.vim')
      call lightline#update()
    endif
  endfunction

  function! s:notify_hook.on_finish(session, context) abort
    let g:quickrun_running_message = ''

    if dein#tap('lightline.vim')
      call lightline#update()
    endif
  endfunction

  function! s:notify_hook.on_success(session, context) abort
    let g:quickrun_notify_success_message = 'Success ' . a:session.config.command
    echohl String | echomsg '[QuickRun] ' . g:quickrun_notify_success_message | echohl None

    if dein#tap('nvim-notify')
      lua require('notify')(vim.g.quickrun_notify_success_message, 'info', { title = ' QuickRun' })
    endif
  endfunction

  function! s:notify_hook.on_success(session, context) abort
    let g:quickrun_notify_success_message = 'Success ' . a:session.config.command
    echohl String | echomsg '[QuickRun] ' . g:quickrun_notify_success_message | echohl None

    if dein#tap('nvim-notify')
      lua require('notify')(vim.g.quickrun_notify_success_message, 'info', { title = ' QuickRun' })
    endif
  endfunction

  function! s:notify_hook.on_failure(session, context) abort
    let g:quickrun_notify_error_message = 'Error ' . a:session.config.command
    echohl Error | echomsg '[QuickRun] ' . g:quickrun_notify_error_message | echohl None

    if dein#tap('nvim-notify')
      lua require('notify')(vim.g.quickrun_notify_error_message, 'error', { title = ' QuickRun' })
    endif
  endfunction

  function! s:notify_hook.sweep() abort
    let g:quickrun_notify_success_message = ''
    let g:quickrun_notify_error_message = ''
  endfunction

  let g:quickrun_config = {
  \ '_' : {
  \   'outputter': 'error',
  \   'outputter/error/success': 'buffer',
  \   'outputter/error/error':   'quickfix',
  \   'outputter/buffer/opener': ':botright 15split',
  \   'outputter/buffer/close_on_empty' : 1,
  \   'hooks' : [s:notify_hook],
  \ },
  \ 'deno' : {
  \   'command': 'deno',
  \   'cmdopt': '--no-check --allow-all --unstable',
  \   'exec': ['%c run %o %s'],
  \ },
  \ 'tsc' : {
  \   'command': 'tsc',
  \   'exec': ['yarn run --silent %C --project . --noEmit --incremental --tsBuildInfoFile .git/.tsbuildinfo 2>/dev/null'],
  \   'outputter': 'quickfix',
  \   'outputter/quickfix/errorformat': '%+A %#%f %#(%l\,%c): %m,%C%m',
  \ },
  \ 'eslint': {
  \   'command': 'eslint',
  \   'exec': ['yarn run --silent %C --format unix --ext .ts,.tsx %a 2>/dev/null'],
  \   'outputter': 'quickfix',
  \   'outputter/quickfix/errorformat': '%f:%l:%c:%m,%-G%.%#',
  \ },
  \ 'json-browser': {
  \   'exec': 'cat %s | jq',
  \   'outputter': 'browser',
  \   'outputter/browser/name': tempname() . '.json',
  \ },
  \ 'yq': {
  \   'exec': 'cat %s | yq eval --output-format=json',
  \ },
  \ 'yq-browser': {
  \   'exec': 'cat %s | yq eval --output-format=json',
  \   'outputter': 'browser',
  \   'outputter/browser/name': tempname() . '.json',
  \ },
  \ }

  if dein#tap('vim-quickrun-neovim-job')
    let g:quickrun_config._.runner = 'neovim_job'
  endif
endif
" }}}3

" }}}2

" Combination Settings {{{2
function! s:esc_esc() abort
  echo ''

  if dein#tap('vim-searchx')
    call searchx#clear()
  endif

  if dein#tap('nvim-hlslens')
    lua require('hlslens').disable()
  endif

  if dein#tap('vim-anzu')
    AnzuClearSearchStatus
  endif

  if dein#tap('coc.nvim')
    call coc#float#close_all()
  endif
endfunction

command! EscEsc call <SID>esc_esc()
nnoremap <silent> <Esc><Esc> <Cmd>nohlsearch<CR><Cmd>EscEsc<CR>
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

" }}}2

" }}}1

" Correct Interference {{{1

" keymaps {{{
" function! Set_default_keymap() abort let g:keymap = 'Default'
"   call lightline#update()
" endfunction
"
" function! Set_quickfix_keymap() abort
"   let g:keymap = 'QuickFix'
"   call lightline#update()
"
"   nnoremap <silent> cp <Cmd>cprev<CR>
"   nnoremap <silent> cn <Cmd>cnext<CR>
" endfunction
"
" function! Set_locationlist_keymap() abort
"   let g:keymap = 'LocationList'
"   call lightline#update()
"
"   nnoremap <silent> cp <Cmd>lprev<CR>
"   nnoremap <silent> cn <Cmd>lnext<CR>
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
AutoCmd ColorScheme nord,onedark,iceberg highlight Visual       ctermfg=NONE ctermbg=23   guifg=NONE    guibg=#1D4647
AutoCmd ColorScheme nord,onedark,iceberg highlight Incsearch    ctermfg=68   ctermbg=232  guifg=NONE    guibg=#175655
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
" AutoCmd ColorScheme gruvbox-material highlight NormalNC     ctermfg=144  ctermbg=234  guifg=#ABB2BF guibg=#282C34
AutoCmd ColorScheme gruvbox-material highlight Normal       ctermfg=233  ctermbg=NONE guifg=#d4be98 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight DiffText     ctermfg=NONE ctermbg=223  guifg=NONE    guibg=#716522
AutoCmd ColorScheme gruvbox-material highlight Folded       ctermfg=245  ctermbg=NONE guifg=#686f9a guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight IncSearch    ctermfg=68   ctermbg=232  guifg=NONE    guibg=#175655
AutoCmd ColorScheme gruvbox-material highlight Search       ctermfg=68   ctermbg=232  guifg=NONE    guibg=#213F72
AutoCmd ColorScheme gruvbox-material highlight SignColumn   ctermfg=0    ctermbg=NONE guifg=#32302f guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight Visual       ctermfg=NONE ctermbg=23   guifg=NONE    guibg=#1D4647
AutoCmd ColorScheme gruvbox-material highlight Pmenu        ctermfg=NONE ctermbg=238  guifg=NONE    guibg=#2C3538
AutoCmd ColorScheme gruvbox-material highlight PmenuSel     ctermfg=235  ctermbg=142  guifg=NONE    guibg=#3C6073

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
AutoCmd ColorScheme gruvbox-material highlight ExchangeRegion          ctermfg=68   ctermbg=232  cterm=underline,bold guifg=NONE    guibg=#2E3F29 gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight ExtraWhiteSpace         ctermfg=NONE ctermbg=1                         guifg=NONE    guibg=#E98989
AutoCmd ColorScheme gruvbox-material highlight FloatermNF              ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#161821
AutoCmd ColorScheme gruvbox-material highlight GitRebase               ctermfg=NONE ctermbg=234                       guifg=NONE    guibg=#1F1F20
AutoCmd ColorScheme gruvbox-material highlight HighlightedyankRegion   ctermfg=1    ctermbg=NONE                      guifg=#E27878 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight MatchParen              ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme gruvbox-material highlight MatchParenCur           ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme gruvbox-material highlight MatchWord               ctermfg=NONE ctermbg=NONE cterm=underline      guifg=NONE    guibg=NONE    gui=underline
AutoCmd ColorScheme gruvbox-material highlight MatchWordCur            ctermfg=NONE ctermbg=NONE cterm=bold           guifg=NONE    guibg=NONE    gui=bold
AutoCmd ColorScheme gruvbox-material highlight YankRoundRegion         ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A

AutoCmd ColorScheme gruvbox-material highlight CocErrorSign            ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocWarningSign          ctermfg=214  ctermbg=NONE                      guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocInfoSign             ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocFloating             ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2C3538
AutoCmd ColorScheme gruvbox-material highlight CocHoverFloating        ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocSuggestFloating      ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocSignatureFloating    ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocDiagnosticFloating   ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F

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

AutoCmd ColorScheme gruvbox-material highlight GitSignsChange    ctermfg=214  ctermbg=NONE guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocGitChangedSign ctermfg=214  ctermbg=NONE guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight link GitSignsCurrentLineBlame Comment

AutoCmd ColorScheme gruvbox-material highlight link HlSearchNear IncSearch
AutoCmd ColorScheme gruvbox-material highlight HlSearchLens            ctermfg=68   ctermbg=232                       guifg=#889eb5 guibg=#283642
AutoCmd ColorScheme gruvbox-material highlight HlSearchLensNear        ctermfg=68   ctermbg=232                       guifg=NONE    guibg=#213F72
AutoCmd ColorScheme gruvbox-material highlight HlSearchFloat           ctermfg=68   ctermbg=232                       guifg=NONE    guibg=#213F72

AutoCmd ColorScheme gruvbox-material highlight ScrollView              ctermbg=159                                                  guibg=#D0D0D0

AutoCmd ColorScheme gruvbox-material highlight VistaFloat ctermbg=237 guibg=#3a3a3a

AutoCmd ColorScheme gruvbox-material highlight SearchxMarkerCurrent ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight SearchxMarker        ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#FFAF60 guibg=NONE    gui=NONE

AutoCmd ColorScheme gruvbox-material highlight link SearchxIncSearch IncSearch

" TreeSitter
AutoCmd ColorScheme gruvbox-material highlight link TSPunctBracket Normal
AutoCmd ColorScheme gruvbox-material highlight link BiscuitColor   Comment

" }}}2

" nord {{{2

" let g:nord_uniform_diff_background = 1
" colorscheme nord

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
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \ ]

  let s:p.insert.left = [
  \ [s:nord0,      s:nord3],
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \]

  let s:p.visual.left = [
  \ [s:nord0,      s:nord5],
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \ ]

  let s:p.replace.left = [
  \ [s:nord0,      s:nord1],
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \ ]

  let s:p.inactive.left = [
  \ [s:blue_green, s:grey],
  \ [s:nord7,      s:grey],
  \ [s:blue_green, s:grey],
  \ [s:nord4,      s:grey],
  \ ]

  let s:p.normal.right   = [[s:nord7, s:nord0],   [s:nord7, s:grey]]
  let s:p.inactive.right = [[s:nord0, s:nord7],   [s:nord0, s:nord7]]
  let s:p.insert.right   = [[s:nord0, s:nord3],   [s:nord7, s:grey]]
  let s:p.replace.right  = [[s:nord0, s:nord1],   [s:nord7, s:grey]]
  let s:p.visual.right   = [[s:nord0, s:nord5],   [s:nord7, s:grey]]

  let s:p.normal.middle   = [[s:nord7, s:nord0]]
  let s:p.inactive.middle = [[s:nord7, s:grey]]

  let s:p.tabline.left   = [[s:nord7, s:nord8]]
  let s:p.tabline.tabsel = [[s:nord0, s:nord4]]
  let s:p.tabline.middle = [[s:nord7, s:nord0]]
  let s:p.tabline.right  = [[s:nord7, s:nord8]]

  let s:coc_diagnostic = [
  \ [s:grey, s:nord1],
  \ [s:grey, s:nord11],
  \ [s:grey, s:nord3],
  \ [s:grey, s:nord4],
  \ [s:grey, s:nord2],
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
let g:gruvbox_material_better_performance     = 1
let g:gruvbox_material_background             = 'hard'
let g:gruvbox_material_transparent_background = 1
let g:gruvbox_material_enable_bold            = 1
let g:gruvbox_material_enable_italic          = 1

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
  let s:blue_green = ['#00AFAF', 37]
  let s:warning    = ['#FFAF60', 214]
  let s:info       = ['#FFFFAF', 229]

  let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

  let s:p.normal.left = [
  \ [s:gruvbox0,   s:gruvbox4],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.insert.left = [
  \ [s:gruvbox0,   s:gruvbox3],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.visual.left = [
  \ [s:gruvbox0,   s:gruvbox5],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.replace.left = [
  \ [s:gruvbox0,   s:gruvbox1],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.inactive.left = [
  \ [s:blue_green, s:grey],
  \ [s:gruvbox7,   s:grey],
  \ [s:blue_green, s:grey],
  \ [s:gruvbox4,   s:grey],
  \ ]

  let s:p.normal.right   = [[s:gruvbox0, s:gruvbox4], [s:gruvbox7, s:grey]]
  let s:p.inactive.right = [[s:gruvbox0, s:gruvbox7], [s:gruvbox0, s:gruvbox7]]
  let s:p.insert.right   = [[s:gruvbox0, s:gruvbox3], [s:gruvbox7, s:grey]]
  let s:p.replace.right  = [[s:gruvbox0, s:gruvbox1], [s:gruvbox7, s:grey]]
  let s:p.visual.right   = [[s:gruvbox0, s:gruvbox5], [s:gruvbox7, s:grey]]

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

  let s:p.normal.quickrun  = [[s:gruvbox0, s:info]]
  let s:p.insert.quickrun  = [[s:gruvbox0, s:info]]
  let s:p.replace.quickrun = [[s:gruvbox0, s:info]]
  let s:p.visual.quickrun  = [[s:gruvbox0, s:info]]

  let g:lightline#colorscheme#gruvbox#palette = lightline#colorscheme#flatten(s:p)
endif
" }}}3

" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
