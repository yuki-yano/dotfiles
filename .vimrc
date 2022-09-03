" Plugin Manager {{{1

" Select LSP {{{2
let g:enable_coc      = v:true
let g:enable_vim_lsp  = v:false
let g:enable_nvim_lsp = v:false

let g:enable_ddc = v:false
let g:enable_cmp = v:true

let g:enable_nvim_lsp = g:enable_nvim_lsp && has('nvim')
let g:enable_cmp      = g:enable_cmp && has('nvim')
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
  call dein#add('haya14busa/dein-command.vim', { 'on_cmd': ['Dein'] })
  " }}}3

  " Doc {{{3
  call dein#add('vim-jp/vimdoc-ja')
  " }}}3

  " denops {{{3
  call dein#add('vim-denops/denops.vim')

  call dein#add('Shougo/ddu.vim')
  call dein#add('Shougo/ddu-source-line')
  call dein#add('Shougo/ddu-kind-file')
  call dein#add('Shougo/ddu-filter-matcher_substring')
  call dein#add('Shougo/ddu-source-file')
  call dein#add('Shougo/ddu-ui-ff')

  if isdirectory(expand('~/repos/github.com/yuki-yano/ddu-filter-fzf'))
    call dein#add('~/repos/github.com/yuki-yano/ddu-filter-fzf')
  endif
  " }}}3

  " IDE {{{3
  if g:enable_coc || (g:enable_cmp && !isdirectory(expand($HOME . '.config/github-copilot')))
    call dein#add('github/copilot.vim')
  endif

  if g:enable_coc
    call dein#add('neoclide/coc.nvim', {'build': 'yarn install --frozen-lockfile'})
    if isdirectory(expand('~/repos/github.com/yuki-yano/coc-copilot'))
      call dein#add('~/repos/github.com/yuki-yano/coc-copilot')
    endif

    " call dein#add('neoclide/coc.nvim', {'rev': 'release'})
    " if isdirectory(expand('~/repos/github.com/yuki-yano/coc.nvim'))
    "   call dein#add('~/repos/github.com/yuki-yano/coc.nvim')
    " endif
  endif

  if g:enable_ddc
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

  if g:enable_vim_lsp
    call dein#add('prabirshrestha/vim-lsp')
    call dein#add('mattn/vim-lsp-settings')

    if g:enable_ddc
      call dein#add('shun/ddc-vim-lsp')
    endif
  endif

  if g:enable_nvim_lsp
    call dein#add('neovim/nvim-lspconfig')
    call dein#add('williamboman/mason.nvim')
    call dein#add('williamboman/mason-lspconfig.nvim')

    call dein#add('b0o/SchemaStore.nvim')
    call dein#add('j-hui/fidget.nvim')
    call dein#add('ray-x/lsp_signature.nvim')
    call dein#add('tami5/lspsaga.nvim')
  endif

  if g:enable_cmp
    call dein#add('hrsh7th/nvim-cmp')

    call dein#add('hrsh7th/cmp-buffer')
    call dein#add('hrsh7th/cmp-cmdline')
    call dein#add('hrsh7th/cmp-nvim-lsp')
    call dein#add('hrsh7th/cmp-path')
    call dein#add('onsails/lspkind-nvim')
    call dein#add('quangnguyen30192/cmp-nvim-ultisnips')
    call dein#add('tzachar/cmp-fuzzy-path')
    call dein#add('tzachar/cmp-tabnine', {'build': './install.sh'})
    call dein#add('zbirenbaum/copilot-cmp')
    call dein#add('zbirenbaum/copilot.lua')
  endif

  " call dein#add('Shougo/neco-vim')
  " call dein#add('Shougo/ddc-cmdline-history')

  " call dein#add('tsuyoshicho/vim-efm-langserver-settings')

  " call dein#add('hrsh7th/vim-vsnip-integ')
  " call dein#add('kitagry/asyncomplete-tabnine.vim', {'build': './install.sh'})
  " call dein#add('prabirshrestha/asyncomplete-lsp.vim')
  " call dein#add('prabirshrestha/asyncomplete.vim')
  " call dein#add('wellle/tmux-complete.vim')
  " }}}3

  " IME {{{3
  " call dein#add('vim-skk/skkeleton', {'on_event': ['InsertEnter'], 'hook_post_source': 'call SetupSkkeleton()'})
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
  call dein#add('elzr/vim-json')
  call dein#add('heavenshell/vim-jsdoc', {'build': 'make install'})
  call dein#add('pantharshit00/vim-prisma', {'merge_ftdetect': 1})

  if has('nvim')
    call dein#add('nvim-treesitter/nvim-treesitter')

    " call dein#add('SmiteshP/nvim-gps')
    " call dein#add('code-biscuits/nvim-biscuits')
    " call dein#add('ggandor/leap-ast.nvim')
    " call dein#add('ggandor/leap.nvim')
    " call dein#add('haringsrob/nvim_context_vt')
    " call dein#add('nvim-treesitter/nvim-treesitter-refactor')
    " call dein#add('nvim-treesitter/nvim-treesitter-textobjects')
    call dein#add('David-Kunz/treesitter-unit')
    call dein#add('JoosepAlviste/nvim-ts-context-commentstring')
    call dein#add('lukas-reineke/indent-blankline.nvim')
    call dein#add('m-demare/hlargs.nvim')
    call dein#add('mfussenegger/nvim-treehopper')
    call dein#add('nvim-treesitter/nvim-treesitter-context')
    call dein#add('p00f/nvim-ts-rainbow')
    call dein#add('yioneko/nvim-yati')
  endif
  " }}}3

  " Git {{{3
  " call dein#add('cohama/agit.vim')
  " call dein#add('hotwatermorning/auto-git-diff')
  " call dein#add('rhysd/conflict-marker.vim')
  " call dein#add('tpope/vim-fugitive')
  " call dein#add('wting/gitsessions.vim', {'on_cmd': ['GitSessionSave', 'GitSessionLoad']})
  call dein#add('lambdalisue/gina.vim', {'on_cmd': ['Gina'], 'on_func': ['fzf#run']})

  if has('nvim')
    " call dein#add('APZelos/blamer.nvim')
    " call dein#add('f-person/git-blame.nvim')
    " call dein#add('rhysd/git-messenger.vim')
    call dein#add('lewis6991/gitsigns.nvim')
  endif
  " }}}3

  " Fuzzy Finder {{{3
  " call dein#add('Shougo/denite.nvim')

  call dein#add('junegunn/fzf', {'build': './install --bin', 'merged': 0})
  " call dein#add('junegunn/fzf.vim', {'merged': 0})
  " call dein#add('antoinemadec/coc-fzf', {'rev': 'release'})

  if isdirectory(expand('~/repos/github.com/yuki-yano/fzf-preview.vim'))
    call dein#add('~/repos/github.com/yuki-yano/fzf-preview.vim')
  endif

  " if isdirectory(expand('~/repos/github.com/yuki-yano/coc-ultisnips-select'))
  "   call dein#add('~/repos/github.com/yuki-yano/coc-ultisnips-select')
  " endif

  " call dein#add('yuki-yano/fzf-preview.vim', {'rev': 'release/rpc'})

  if has('nvim')
    call dein#add('nvim-lua/telescope.nvim')
  endif
  " }}}3

  " filer {{{3
  call dein#add('lambdalisue/fern.vim', {'on_cmd': ['Fern'], 'depends': ['fern-mapping-reload-all.vim', 'fern-git-status.vim', 'fern-hijack.vim', 'fern-renderer-nerdfont.vim', 'nerdfont.vim', 'fern-preview.vim']})

  " call dein#add('LumaKernel/fern-mapping-fzf.vim')
  call dein#add('LumaKernel/fern-mapping-reload-all.vim', {'lazy': 1})
  call dein#add('lambdalisue/fern-git-status.vim', {'lazy': 1, 'hook_post_source': 'call fern_git_status#init()'})
  call dein#add('lambdalisue/fern-hijack.vim')
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
  call dein#add('machakann/vim-sandwich') " ib, ab, is, as
  call dein#add('machakann/vim-swap', {'on_map': {'nox': '<Plug>'}}) " g< g> gs i, a,

  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-operator-user')

  " call dein#add('kana/vim-textobj-fold') " iz az
  " call dein#add('kana/vim-textobj-indent', {'on_map': {'ox': '<Plug>(textobj-indent'}}) " ii ai
  " call dein#add('mattn/vim-textobj-url', {'on_map': {'ox': '<Plug>(textobj-url'}}) " iu au
  " call dein#add('rhysd/vim-textobj-ruby') " ir ar
  " call dein#add('romgrk/equal.operator') " i=h a=h i=l a=l
  call dein#add('kana/vim-textobj-entire', {'on_map': {'ox': '<Plug>(textobj-entire'}}) " ie ae
  call dein#add('kana/vim-textobj-line', {'on_map': {'ox': '<Plug>(textobj-line'}}) " al il
  call dein#add('machakann/vim-textobj-functioncall', {'on_map': {'ox': '<Plug>(textobj-functioncall'}}) " if af ig ag
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
  " call dein#add('hrsh7th/vim-searchx', {'on_func': ['searchx#start', 'searchx#select', 'searchx#next_dir', 'searchx#prev_dir']})
  " call dein#add('inkarkat/vim-EnhancedJumps')
  " call dein#add('kana/vim-smartword', {'on_map': ['<Plug>']})
  " call dein#add('lambdalisue/reword.vim')
  " call dein#add('mg979/vim-visual-multi', {'rev': 'test'})
  " call dein#add('mhinz/vim-grepper', {'on_cmd': ['Grepper']})
  " call dein#add('monaqa/dps-dial.vim', {'on_map': ['<Plug>(dps-dial-']})
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
  call dein#add('MattesGroeger/vim-bookmarks', {'on_cmd': ['BookmarkToggle', 'BookmarkAnnotate', 'BookmarkNext', 'BookmarkPrev', 'BookmarkShowAll', 'BookmarkClear', 'BookmarkClearAll']})
  call dein#add('SirVer/ultisnips', {'on_ft': ['snippets'], 'on_event': ['InsertEnter']})
  call dein#add('cohama/lexima.vim', {'on_event': ['InsertEnter', 'CmdlineEnter'], 'hook_post_source': 'call SetupLexima()', 'rev': 'feature/feedkeys'})
  call dein#add('haya14busa/vim-asterisk', {'on_map': ['<Plug>']})
  call dein#add('haya14busa/vim-edgemotion', {'on_map': ['<Plug>']})
  call dein#add('hrsh7th/vim-eft', {'on_map': {'nox': '<Plug>'}})
  call dein#add('junegunn/vim-easy-align', {'on_map': ['<Plug>(EasyAlign)']})
  call dein#add('kyoh86/vim-ripgrep')
  call dein#add('lambdalisue/vim-backslash', {'on_ft': ['vim'], 'on_map': ['<Plug>']})
  call dein#add('mattn/vim-maketable', {'on_cmd': ['MakeTable']})
  call dein#add('osyo-manga/vim-anzu', {'on_map': ['<Plug>']})
  call dein#add('osyo-manga/vim-jplus', {'on_map': ['<Plug>']})
  call dein#add('terryma/vim-expand-region', {'on_map': ['<Plug>(expand_region_']})
  call dein#add('thinca/vim-qfreplace', {'on_cmd': ['Qfreplace']})
  call dein#add('tommcdo/vim-exchange', {'on_map': ['<Plug>(Exchange']})
  call dein#add('tpope/vim-repeat')
  call dein#add('tyru/caw.vim', {'on_map': ['<Plug>']})
  call dein#add('yuki-yano/deindent-yank.vim', {'on_map': ['<Plug>']})

  if isdirectory(expand('~/repos/github.com/yuki-yano/fuzzy-motion.vim'))
    call dein#add('~/repos/github.com/yuki-yano/fuzzy-motion.vim', {'on_cmd': ['FuzzyMotion'], 'on_func': ['fuzzy_motion#targets']})
  endif

  if has('nvim')
    " call dein#add('b3nj5m1n/kommentary')
    " call dein#add('delphinus/emcl.nvim')
    " call dein#add('gabrielpoca/replacer.nvim')
    " call dein#add('gbprod/yanky.nvim')
    " call dein#add('ggandor/lightspeed.nvim')
    " call dein#add('numToStr/Comment.nvim')
    " call dein#add('phaazon/hop.nvim')
    " call dein#add('rlane/pounce.nvim', {'on_cmd': ['Pounce']})
    " call dein#add('rmagatti/auto-session')
    " call dein#add('windwp/nvim-spectre')
    " call dein#add('winston0410/smart-cursor.nvim')
    " call dein#add('yuki-yano/zero.nvim')
    call dein#add('booperlv/nvim-gomove', {'on_map': ['<Plug>Go'], 'hook_post_source': 'call SetupGomove()'})
    call dein#add('kevinhwang91/nvim-hlslens')
    call dein#add('monaqa/dial.nvim')
    call dein#add('nacro90/numb.nvim', {'on_event': ['CmdlineEnter'], 'hook_post_source': 'call SetupNumb()'})
    call dein#add('ray-x/sad.nvim')
    call dein#add('tkmpypy/chowcho.nvim')
    call dein#add('windwp/nvim-ts-autotag')

    if isdirectory(expand('~/repos/github.com/yuki-yano/tsnip.nvim'))
      call dein#add('~/repos/github.com/yuki-yano/tsnip.nvim', {'depends': ['nui.nvim'], 'on_event': ['InsertEnter'], 'on_cmd': ['TSnip']})
    endif
  endif
  " }}}3

  " Appearance {{{3
  " call dein#add('RRethy/vim-hexokinase', {'build': 'make hexokinase'})
  " call dein#add('Yggdroot/indentLine')
  " call dein#add('lambdalisue/readablefold.vim')
  " call dein#add('luochen1990/rainbow')
  " call dein#add('mhinz/vim-startify')
  " call dein#add('miyakogi/seiya.vim')
  " call dein#add('mopp/smartnumber.vim')
  " call dein#add('ntpeters/vim-better-whitespace')
  " call dein#add('obcat/vim-highlightedput', {'on_map': ['<Plug>']})
  " call dein#add('ronakg/quickr-preview.vim')
  " call dein#add('utubo/vim-auto-hide-cmdline')
  " call dein#add('wellle/context.vim')
  " call dein#add('yuttie/comfortable-motion.vim')
  call dein#add('andymass/vim-matchup')
  call dein#add('itchyny/lightline.vim')
  call dein#add('lambdalisue/glyph-palette.vim')
  call dein#add('machakann/vim-highlightedundo', {'on_map': ['<Plug>']})
  call dein#add('machakann/vim-highlightedyank', {'on_event': ['TextYankPost']})
  call dein#add('rbtnn/vim-layout', {'on_func': ['layout#save', 'layout#load']})
  call dein#add('ryanoasis/vim-devicons')

  if has('nvim')
    " call dein#add('Maan2003/lsp_lines.nvim')
    " call dein#add('Xuyuanp/scrollbar.nvim')
    " call dein#add('dstein64/nvim-scrollview', {'on_event': ['WinScrolled']})
    " call dein#add('glepnir/indent-guides.nvim')
    " call dein#add('karb94/neoscroll.nvim')
    " call dein#add('mvllow/modes.nvim')
    " call dein#add('nvim-lualine/lualine.nvim')
    " call dein#add('vuki656/package-info.nvim')
    " call dein#add('windwp/floatline.nvim')
    call dein#add('B4mbus/todo-comments.nvim')
    call dein#add('akinsho/bufferline.nvim')
    call dein#add('anuvyklack/hydra.nvim')
    call dein#add('b0o/incline.nvim')
    call dein#add('bennypowers/nvim-regexplainer')
    call dein#add('kevinhwang91/nvim-bqf', {'on_ft': ['qf']})
    call dein#add('kevinhwang91/nvim-ufo')
    call dein#add('kwkarlwang/bufresize.nvim')
    call dein#add('norcalli/nvim-colorizer.lua')
    call dein#add('petertriho/nvim-scrollbar')
    call dein#add('rcarriga/nvim-notify')
    call dein#add('stevearc/aerial.nvim')
  endif
  " }}}3

  " tmux {{{3
  " call dein#add('christoomey/vim-tmux-navigator')
  if has('nvim')
    call dein#add('aserowy/tmux.nvim')
  endif
  " }}}3

  " Util {{{3
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
  " call dein#add('vim-test/vim-test')
  " call dein#add('voldikss/vim-floaterm', {'on_cmd': ['FloatermToggle']})
  call dein#add('AndrewRadev/linediff.vim', {'on_cmd': ['Linediff']})
  call dein#add('aiya000/aho-bakaup.vim', {'on_event': ['BufWritePre', 'FileWritePre']})
  call dein#add('farmergreg/vim-lastplace')
  call dein#add('glidenote/memolist.vim', {'on_cmd': ['MemoNew', 'MemoList']})
  call dein#add('iamcco/markdown-preview.nvim', {'on_cmd': 'MarkdownPreview', 'build': 'sh -c "cd app && yarn install"'})
  call dein#add('itchyny/vim-qfedit', {'on_ft': ['qf']})
  call dein#add('jsfaint/gen_tags.vim')
  call dein#add('kana/vim-niceblock')
  call dein#add('lambdalisue/file-protocol.vim')
  call dein#add('lambdalisue/guise.vim')
  call dein#add('lambdalisue/suda.vim', {'on_cmd': ['SudaRead', 'SudaWrite']})
  call dein#add('lambdalisue/vim-manpager', {'on_cmd': ['ASMANPAGER']})
  call dein#add('lambdalisue/vim-quickrun-neovim-job')
  call dein#add('liuchengxu/vista.vim')
  call dein#add('mbbill/undotree', {'on_cmd': ['UndotreeToggle']})
  call dein#add('moll/vim-bbye', {'on_cmd': ['Bdelete']})
  call dein#add('segeljakt/vim-silicon', {'on_cmd': ['Silicon']})
  call dein#add('thinca/vim-ambicmd', {'on_func': ['ambicmd#expand']})
  call dein#add('thinca/vim-editvar', {'on_cmd': ['Editvar']})
  call dein#add('thinca/vim-quickrun')
  call dein#add('thinca/vim-scouter', {'on_cmd': ['Scouter']})
  call dein#add('tyru/capture.vim')
  call dein#add('tyru/open-browser.vim')
  call dein#add('wesQ3/vim-windowswap', {'on_func': ['WindowSwap#EasyWindowSwap']})

  if has('nvim')
    " call dein#add('lambdalisue/edita.vim')
    " call dein#add('lewis6991/impatient.nvim')
    " call dein#add('notomo/cmdbuf.nvim')
    " call dein#add('nvim-lua/popup.nvim')
    " call dein#add('nvim-neotest/neotest-vim-test')
    " call dein#add('rcarriga/vim-ultest', {'on_cmd': ['Ultest', 'UltestNearest', 'UltestSummary'], 'depends': ['vim-test']})
    " call dein#add('romgrk/fzy-lua-native', {'lazy': 1, 'build': 'make'})
    call dein#add('MunifTanjim/nui.nvim')
    call dein#add('akinsho/toggleterm.nvim')
    call dein#add('antoinemadec/FixCursorHold.nvim')
    call dein#add('haydenmeade/neotest-jest')
    call dein#add('kevinhwang91/promise-async')
    call dein#add('kyazdani42/nvim-web-devicons')
    call dein#add('nvim-lua/plenary.nvim')
    call dein#add('nvim-neotest/neotest')
    call dein#add('nvim-telescope/telescope-fzf-native.nvim', {'build': 'make'})
    call dein#add('ray-x/guihua.lua')
    call dein#add('tzachar/fuzzy.nvim')
  endif

  if $ENABLE_WAKATIME == 1
    call dein#add('wakatime/vim-wakatime')
  endif

  if !g:enable_cmp && has('nvim')
    call dein#add('gelguy/wilder.nvim', {'on_event': ['CmdlineEnter'], 'hook_post_source': 'call SetUpWilder()'})
  endif
  " }}}3

  " Develop {{{3
  " call dein#add('hrsh7th/vim-vital-vs')
  " call dein#add('vim-jp/vital.vim')
  call dein#add('rbtnn/vim-vimscript_lasterror', {'on_cmd': ['VimscriptLastError']})
  call dein#add('thinca/vim-prettyprint')
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
  call dein#add('ellisonleao/gruvbox.nvim')
  " }}}3

  call dein#end()
  call dein#save_state()
endif
" }}}2

" Install Plugin {{{2
if dein#check_install() && confirm('Would you like to download some plugins ?', "&Yes\n&No", 1)
  call dein#install()
endif
" }}}2

" }}}1

" Global Settings {{{1

" FileType {{{2
filetype plugin indent on
syntax enable
" }}}2

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

" Keymap {{{2
function! s:keymap(force_map, modes, ...) abort
  let arg = join(a:000, ' ')
  let cmd = (a:force_map || arg =~? '<Plug>') ? 'map' : 'noremap'
  for mode in split(a:modes, '.\zs')
    if index(split('nvsxoilct', '.\zs'), mode) < 0
      echoerr 'Invalid mode is detected: ' . mode
      continue
    endif
    execute mode . cmd arg
  endfor
endfunction

command! -nargs=+ -bang Keymap call <SID>keymap(<bang>0, <f-args>)
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
Keymap nx  <Leader>         <Nop>
Keymap n   <Plug>(t)        <Nop>
Keymap n   t                <Plug>(t)
Keymap nx  <Plug>(lsp)      <Nop>
Keymap nx  m                <Plug>(lsp)
Keymap nx  <Plug>(fzf-p)    <Nop>
Keymap nx  ;                <Plug>(fzf-p)
Keymap nx  ;;               ;
Keymap n   <Plug>(bookmark) <Nop>
Keymap n   M                <Plug>(bookmark)
Keymap nox s                <Nop>
Keymap n   <Plug>(ctrl-n)   <Nop>
Keymap n   <C-n>            <Plug>(ctrl-n)
Keymap n   <Plug>(ctrl-p)   <Nop>
Keymap n   <C-p>            <Plug>(ctrl-p)


"" Zero (Move beginning toggle)
Keymap nox <expr> 0 getline('.')[0 : col('.') - 2] =~# '^\s\+$' ? '0' : '^'
Keymap nox ^ 0

"" Neovim default <C-w>
iunmap <C-w>

"" Buffer
Keymap n <C-q> <C-^>

"" Save
Keymap n <silent> <Leader>w <Cmd>update<CR>
Keymap n <silent> <Leader>W <Cmd>update!<CR>

"" Automatically indent with i and A
Keymap n <expr> i  len(getline('.')) ? 'i' : '"_cc'
Keymap n <expr> A  len(getline('.')) ? 'A' : '"_cc'
Keymap n        gi i

"" Ignore registers
Keymap n x "_x

"" operator snake case & camel case
function! s:search_line(pattern, num, opt)
  for i in range(a:num)
    call search(a:pattern, a:opt, line('.'))
  endfor
endfunction

Keymap o s <Cmd>call <SID>search_line('[A-Z_]', v:count1, '')<CR>

"" tagjump
Keymap n <silent> s<C-]> <Cmd>wincmd ]<CR>
Keymap n <silent> v<C-]> <Cmd>vertical wincmd ]<CR>
Keymap n <silent> t<C-]> <Cmd>tab wincmd ]<CR>
Keymap n <silent> r<C-]> <C-w>}

"" QuickFix
Keymap n [c :cprevious<CR>
Keymap n ]c :cnext<CR>
Keymap n [q :colder<CR>
Keymap n ]q :cnewer<CR>

"" Location List
Keymap n [l :lprevious<CR>
Keymap n ]l :lnext<CR>

"" Insert and cmdline
Keymap ic <C-h> <BS>
Keymap ic <C-d> <Del>

Keymap i <C-a> <C-g>U<Home>
" Keymap i <C-e> <C-g>U<End>
Keymap i <C-b> <C-g>U<Left>
" Configure in lexima
" Keymap i <C-f> <C-g>U<Right>

Keymap c <C-b> <Left>
Keymap c <C-f> <Right>
Keymap c <C-a> <Home>
Keymap c <C-n> <Down>
Keymap c <C-p> <Up>

"" Indent
Keymap n < <<
Keymap n > >>
Keymap x < <gv
Keymap x > >gv|

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
  Keymap n <silent> <C-w><C-w> <Cmd>call <SID>focus_floating()<CR>
endif

"" Tab
Keymap n <silent> <Plug>(t)t <Cmd>tablast <Bar> tabedit<CR>
Keymap n <silent> <Plug>(t)d <Cmd>tabclose<CR>
Keymap n <silent> <Plug>(t)h <Cmd>tabprevious<CR>
Keymap n <silent> <Plug>(t)l <Cmd>tabnext<CR>
Keymap n <silent> <Plug>(t)m <C-w>T

"" resize
Keymap n <silent> <Left>  <Cmd>vertical resize -1<CR>
Keymap n <silent> <Right> <Cmd>vertical resize +1<CR>
Keymap n <silent> <Up>    <Cmd>resize -1<CR>
Keymap n <silent> <Down>  <Cmd>resize +1<CR>

"" Macro
Keymap n Q @q

"" regexp
Keymap n <Leader>r :<C-u>%s/\v//g<Left><Left><Left>
Keymap x <Leader>r "sy:%s/\v<C-r>=substitute(@s, '/', '\\/', 'g')<CR>//g<Left><Left>

"" Clipboard
Keymap n  <silent> sc <Cmd>call system('pbcopy', @") <Bar> echo 'Copied " register to OS clipboard'<CR>
Keymap nx <silent> sp <Cmd>let @" = substitute(system('pbpaste'), "\n\+$", '', '') <Bar> echo 'Copied from OS clipboard to " register'<CR>
" }}}2

" Set Options {{{2

"" NeoVim
if has('nvim')
  let g:loaded_python_provider = 0
  let g:loaded_perl_provider   = 0
  let g:loaded_ruby_provider   = 0
  let g:python3_host_prog      = $HOME . '/.pyenv/shims/python'

  set inccommand=nosplit

  Keymap t <Esc> <C-\><C-n>
  AutoCmd TermOpen * set nonumber norelativenumber

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
" set list listchars=tab:^\ ,trail:_,extends:>,precedes:<,eol:$
set belloff=all
set cmdheight=1
set concealcursor=nc
set conceallevel=2
set diffopt=internal,filler,algorithm:histogram,indent-heuristic,vertical
set display=lastline
set fillchars=diff:/,eob:\\x20
set foldtext=''
set guifont=SF\ Mono\ Square:h18
set helplang=ja
set hidden
set hlsearch
set list listchars=tab:^\ ,trail:_,extends:>,precedes:<
set matchpairs+=<:>
set matchtime=1
set noshowmode
set pumheight=40
set scrolloff=5
set showtabline=2
set spellcapcheck=
set spelllang=en,cjk
set synmaxcol=300
set termguicolors
set virtualedit=all
language messages C
language time C

if has('nvim')
  set laststatus=3
else
  set laststatus=2
endif

"" Indent
set autoindent
set backspace=indent,eol,start
set breakindent
set expandtab
set nostartofline
set shiftwidth=2
set smartindent
set tabstop=2

function s:set_format_options() abort
  set formatoptions-=c formatoptions-=r formatoptions-=o
  set formatoptions+=jBn
endfunction
AutoCmd BufWinEnter * call <SID>set_format_options()

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
let g:loaded_matchit           = 1

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

" LineNumber {{{2
let g:enable_number          = v:true
let g:enable_relative_number = v:true
set number relativenumber

Keymap n <Leader>n <Cmd>ToggleNumber<CR>

function! s:set_number(...) abort
  if a:0 == 0
    let winnrs = range(1, winnr('$'))
  else
    let winnrs = [winnr()]
  endif

  for winnr in winnrs
    let winid = win_getid(winnr)
    if nvim_win_get_config(winid).relative !=# ''
      break
    endif

    if !g:enable_number && !g:enable_relative_number
      call setwinvar(winid, '&number', 0)
      call setwinvar(winid, '&relativenumber', 0)
    elseif g:enable_number && !g:enable_relative_number
      call setwinvar(winid, '&number', 1)
      call setwinvar(winid, '&relativenumber', 0)
    elseif g:enable_number && g:enable_relative_number
      call setwinvar(winid, '&number', 1)
      call setwinvar(winid, '&relativenumber', 1)
    endif
  endfor
endfunction

function! s:toggle_number() abort
  if !g:enable_number && !g:enable_relative_number
    let g:enable_number = v:true
  elseif g:enable_number && !g:enable_relative_number
    let g:enable_relative_number = v:true
  elseif g:enable_number && g:enable_relative_number
    let g:enable_number = v:false
    let g:enable_relative_number = v:false
  endif
  call <SID>set_number()
endfunction

function! s:enable_number() abort
  let g:enable_number = v:true
  let g:enable_relative_number = v:false
  call <SID>set_number()
endfunction

function! s:enable_relative_number() abort
  let g:enable_number = v:true
  let g:enable_relative_number = v:false
  call <SID>set_number()
endfunction


function! s:disable_number() abort
  let g:enable_number = v:false
  let g:enable_relative_number = v:false
  call <SID>set_number()
endfunction

command! ToggleNumber         call <SID>toggle_number()
command! EnableNumber         call <SID>enable_number()
command! EnableRelativeNumber call <SID>enable_relative_number()
command! DisableNumber        call <SID>disable_number()

AutoCmd InsertEnter * if filereadable(expand('#' . bufnr('') . ':p')) | set number norelativenumber | endif
AutoCmd InsertLeave * if filereadable(expand('#' . bufnr('') . ':p')) | call <SID>set_number(1) | endif
" }}}2

" ToggleQuickfix {{{2
function! s:quickfix_toggle() abort
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    botright copen
  endif
endfunction

command! QuickfixToggle call <SID>quickfix_toggle()
Keymap n <silent> <Leader>q <Cmd>QuickfixToggle<CR>
" }}}2

" ToggleLocationList {{{2
function! s:location_list_toggle() abort
  let _ = winnr('$')
  lclose
  if _ == winnr('$')
    try
      botright lopen
    catch
      echohl ErrorMsg
      echomsg 'No LocationList'
      echohl None
    endtry
  endif
endfunction

command! LocationListToggle call <SID>location_list_toggle()
Keymap n <silent> <Leader>l <Cmd>LocationListToggle<CR>
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

" MouseCursor {{{2
function! s:on_focus_gained() abort
  autocmd CursorMoved,CursorMovedI,ModeChanged,WinScrolled * ++once call <SID>eneble_left_mouse()
  Keymap ni <LeftMouse> <Cmd>call <SID>eneble_left_mouse()<CR>
endfunction

function! s:eneble_left_mouse() abort
  Keymap ni <LeftMouse> <LeftMouse>
endfunction

function! s:on_focus_lost() abort
  Keymap ni <LeftMouse> <Nop>
endfunction

AutoCmd FocusGained * call <SID>on_focus_gained()
AutoCmd FocusLost   * call <SID>on_focus_lost()
" }}}2

" JumpPlugin  {{{2
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
      normal! m`
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

Keymap n <silent> [p        <Cmd>UsePluginPrev<CR>
Keymap n <silent> ]p        <Cmd>UsePluginNext<CR>
Keymap n <silent> <Leader>p <Cmd>UsePluginQuickFix<CR>
" }}}2

" View JSON {{{2
command! JSON setfiletype json | call CocAction('format')
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

  if exists(':EnableNumber')
    EnableNumber
  endif

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

  if exists(':EnableRelativeNumber')
    EnableRelativeNumber
  endif

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
AutoCmd FileType snippet         setlocal noexpandtab shiftwidth=2 softtabstop=2 tabstop=2
" }}}3

" Fold {{{3
AutoCmd FileType javascript      setlocal foldlevel=100
AutoCmd FileType typescript      setlocal foldlevel=100
AutoCmd FileType typescriptreact setlocal foldlevel=100
AutoCmd FileType vim             setlocal foldlevel=100
AutoCmd FileType markdown        setlocal foldlevel=100
" }}}3

" ConcealLevel {{{3
AutoCmd FileType markdown setlocal conceallevel=0
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
  Keymap i <silent> <buffer> \\ \
  Keymap i <silent> <buffer> \& &amp;
  Keymap i <silent> <buffer> \< &lt;
  Keymap i <silent> <buffer> \> &gt;
  Keymap i <silent> <buffer> \- &#8212;
  Keymap i <silent> <buffer> \<Space> &nbsp;
  Keymap i <silent> <buffer> \` &#8216;
  Keymap i <silent> <buffer> \' &#8217;
  Keymap i <silent> <buffer> \" &#8221;
endfunction
AutoCmd FileType html,eruby call <SID>map_html_keys()
" }}}2

" Set quit {{{2
AutoCmd FileType qf   Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType help Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType diff Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType man  Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
AutoCmd FileType git  Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>

AutoCmd FileType markdown Keymap n <silent> <buffer> <expr> <nowait> q &previewwindow ? '<Cmd>quit<CR>' : 'q'
" }}}2

" }}}1

" Command Line Window {{{1
set cedit=\<C-c>

" Keymap nx : q:
" Keymap nx q: :

AutoCmd CmdwinEnter * call <SID>init_cmdwin()

function! s:init_cmdwin() abort
  set number norelativenumber
  Keymap n <buffer> <CR> <CR>
  Keymap n <buffer> <silent> <nowait> q <Cmd>quit<CR>
  Keymap i <buffer> <C-c> <Esc>l<C-c>

  " Keymap n <silent> <buffer> dd <Cmd>rviminfo<CR><Cmd>call histdel(getcmdwintype(), line('.') - line('$'))<CR><Cmd>wviminfo!<CR>dd
  startinsert!
endfunction
" }}}1

" Plugin Settings {{{1

" Eager Load {{{2

" nvim-web-devicons {{{3
if dein#tap('nvim-web-devicons')
lua << EOF
local black      = '#32302f'
local red        = '#ea6962'
local green      = '#a9b665'
local yellow     = '#d8a657'
local blue       = '#7daea3'
local magenta    = '#d3869b'
local cyan       = '#89b482'
local white      = '#d4be98'
local grey       = '#807569'
local background = '#1D2021'
local empty      = '#1C1C1C'
local info       = '#FFFFAF'
local vert_split = '#504945'

require('nvim-web-devicons').setup({
  override = {
    ['.babelrc'] = {
      icon = ' ﬥ',
      color = yellow,
      cterm_color = '185',
      name = 'Babelrc',
    },
    ['.gitignore'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'GitIgnore',
    },
    ['.vimrc'] = {
      icon = ' ',
      color = green,
      cterm_color = '29',
      name = 'Vimrc',
    },
    ['.zshenv'] = {
      icon = ' ',
      color = white,
      cterm_color = '113',
      name = 'Zshenv',
    },
    ['.zshrc'] = {
      icon = ' ',
      color = white,
      cterm_color = '113',
      name = 'Zshrc',
    },
    ['Brewfile'] = {
      icon = ' ',
      color = green,
      cterm_color = '113',
      name = 'Brewfile',
    },
    ['COMMIT_EDITMSG'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'GitCommit',
    },
    ['Dockerfile'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'Dockerfile',
    },
    ['Gemfile$'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Gemfile',
    },
    ['LICENSE'] = {
      icon = ' ',
      color = white,
      cterm_color = '179',
      name = 'LICENSE',
    },
    ['ai'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Ai',
    },
    ['bash'] = {
      icon = ' ',
      color = green,
      cterm_color = '113',
      name = 'Bash',
    },
    ['bmp'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Bmp',
    },
    ['coffee'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Coffee',
    },
    ['conf'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Conf',
    },
    ['config.ru'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'ConfigRu',
    },
    ['css'] = {
      icon = ' ',
      color = blue,
      cterm_color = '39',
      name = 'Css',
    },
    ['csv'] = {
      icon = ' ',
      color = blue,
      cterm_color = '113',
      name = 'Csv',
    },
    ['diff'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'Diff',
    },
    ['doc'] = {
      icon = '  ',
      color = blue,
      cterm_color = '25',
      name = 'Doc',
    },
    ['dockerfile'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'Dockerfile',
    },
    ['ejs'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Ejs',
    },
    ['erb'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Erb',
    },
    ['favicon.ico'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Favicon',
    },
    ['gemspec'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Gemspec',
    },
    ['gif'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Gif',
    },
    ['git'] = {
      icon = ' ',
      color = magenta,
      cterm_color = '202',
      name = 'GitLogo',
    },
    ['go'] = {
      icon = ' ',
      color = blue,
      cterm_color = '67',
      name = 'Go',
    },
    ['htm'] = {
      icon = ' ',
      color = magenta,
      cterm_color = '166',
      name = 'Htm',
    },
    ['html'] = {
      icon = ' ',
      color = magenta,
      cterm_color = '202',
      name = 'Html',
    },
    ['ico'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Ico',
    },
    ['ini'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Ini',
    },
    ['jpeg'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Jpeg',
    },
    ['jpg'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Jpg',
    },
    ['js'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Js',
    },
    ['json'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'Json',
    },
    ['jsx'] = {
      icon = ' ',
      color = blue,
      cterm_color = '67',
      name = 'Jsx',
    },
    ['license'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '185',
      name = 'License',
    },
    ['lua'] = {
      icon = ' ',
      color = blue,
      cterm_color = '74',
      name = 'Lua',
    },
    ['makefile'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Makefile',
    },
    ['markdown'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '67',
      name = 'Markdown',
    },
    ['md'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '67',
      name = 'Markdown',
    },
    ['mdx'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '67',
      name = 'Mdx',
    },
    ['mjs'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '221',
      name = 'Mjs',
    },
    ['node_modules'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '161',
      name = 'NodeModules',
    },
    ['package.json'] = {
      icon = ' ',
      color = yellow,
      name = 'PackageJson'
    },
    ['package-lock.json'] = {
      icon = ' ',
      color = yellow,
      name = 'PackageLockJson'
    },
    ['pdf'] = {
      icon = '  ',
      color = red,
      cterm_color = '124',
      name = 'Pdf',
    },
    ['png'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Png',
    },
    ['psd'] = {
      icon = ' ',
      color = blue,
      cterm_color = '67',
      name = 'Psd',
    },
    ['py'] = {
      icon = '',
      color = yellow,
      cterm_color = '61',
      name = 'Py',
    },
    ['rake'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Rake',
    },
    ['Rakefile'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Rakefile',
    },
    ['rb'] = {
      icon = ' ',
      color = red,
      cterm_color = '52',
      name = 'Rb',
    },
    ['rs'] = {
      icon = ' ',
      color = white,
      cterm_color = '180',
      name = 'Rs',
    },
    ['scss'] = {
      icon = ' ',
      color = magenta,
      cterm_color = '204',
      name = 'Scss',
    },
    ['sh'] = {
      icon = ' ',
      color = white,
      cterm_color = '59',
      name = 'Sh',
    },
    ['sql'] = {
      icon = ' ',
      color = white,
      cterm_color = '188',
      name = 'Sql',
    },
    ['sqlite'] = {
      icon = ' ',
      color = white,
      cterm_color = '188',
      name = 'Sql',
    },
    ['svg'] = {
      icon = 'ﰟ ',
      color = yellow,
      cterm_color = '215',
      name = 'Svg',
    },
    ['tex'] = {
      icon = 'ﭨ ',
      color = green,
      cterm_color = '58',
      name = 'Tex',
    },
    ['toml'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Toml',
    },
    ['ts'] = {
      icon = ' ',
      color = blue,
      cterm_color = '67',
      name = 'Ts',
    },
    ['tsx'] = {
      icon = ' ',
      color = blue,
      cterm_color = '67',
      name = 'Tsx',
    },
    ['txt'] = {
      icon = ' ',
      color = green,
      cterm_color = '113',
      name = 'Txt',
    },
    ['vim'] = {
      icon = ' ',
      color = green,
      cterm_color = '29',
      name = 'Vim',
    },
    ['vue'] = {
      icon = '  ',
      color = green,
      cterm_color = '107',
      name = 'Vue',
    },
    ['webp'] = {
      icon = ' ',
      color = cyan,
      cterm_color = '140',
      name = 'Webp',
    },
    ['xml'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '173',
      name = 'Xml',
    },
    ['yaml'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Yaml',
    },
    ['yml'] = {
      icon = ' ',
      color = white,
      cterm_color = '66',
      name = 'Yml',
    },
    ['zsh'] = {
      icon = ' ',
      color = green,
      cterm_color = '113',
      name = 'Zsh',
    },
    ['.env'] = {
      icon = ' ',
      color = yellow,
      cterm_color = '226',
      name = 'Env',
    },
    ['prisma'] = {
      icon = ' ',
      color = white,
      cterm_color = 'white',
      name = 'Prisma',
    },
  },
})
require('nvim-web-devicons').set_default_icon(' ', white)
EOF
endif
" }}}3

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

" denops {{{2

" ddc {{{3
if dein#tap('ddc.vim')
  function! SetupDdc() abort
    call DdcSettings()
  endfunction

  function DdcSettings() abort
    call ddc#enable()

    if g:enable_vim_lsp
      let sources = ['vim-lsp']
    else
      let sources = []
    endif
    let sources += ['tsnip', 'tabnine', 'around', 'buffer', 'file', 'copilot']

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

    if g:enable_vim_lsp
      call extend(source_options, {
      \ 'vim-lsp': {
      \   'mark': 'lsp',
      \ },
      \ })
    endif

    call ddc#custom#patch_global('autoCompleteEvents', ['InsertEnter', 'TextChangedI', 'TextChangedP'])
    call ddc#custom#patch_global('sources', sources)
    call ddc#custom#patch_global('sourceOptions', source_options)
    call ddc#custom#patch_global('backspaceCompletion', v:true)

    call ddc#custom#patch_global('completionMenu', 'pum.vim')
    call popup_preview#enable()

    Keymap i <C-Space> <Cmd>call ddc#map#manual_complete()<CR>
    Keymap i <C-n>     <Cmd>call pum#map#insert_relative(+1)<CR>
    Keymap i <C-p>     <Cmd>call pum#map#insert_relative(-1)<CR>
    Keymap i <C-y>     <Cmd>call pum#map#confirm()<CR>
    Keymap i <C-e>     <Cmd>call pum#map#cancel()<CR>

    AutoCmd InsertEnter * Keymap i <expr> <CR> pum#visible() ? '<Cmd>call pum#map#confirm()<CR>' : lexima#expand('<CR>', 'i')
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
  Keymap ic <C-j> <Plug>(skkeleton-toggle)

  function! SetupSkkeleton() abort
    call skkeleton#config({
    \ 'globalJisyo': expand('~/.vim/skk/SKK-JISYO.L'),
    \ 'eggLikeNewline': v:true,
    \ })
  endfunction

  if dein#tap('lexima.vim')
    Keymap i <silent> <expr> <Space> skkeleton#is_enabled() ? '<Space>' : lexima#expand('<SPACE>', 'i')
  endif

  " if g:enable_coc
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
  \ 'coc-eslint',
  \ 'coc-json',
  \ 'coc-lists',
  \ 'coc-lua',
  \ 'coc-markdownlint',
  \ 'coc-npm-version',
  \ 'coc-prettier',
  \ 'coc-prisma',
  \ 'coc-pyright',
  \ 'coc-rust-analyzer',
  \ 'coc-sh',
  \ 'coc-solargraph',
  \ 'coc-spell-checker',
  \ 'coc-stylelintplus',
  \ 'coc-tabnine',
  \ 'coc-tsnip',
  \ 'coc-tsserver',
  \ 'coc-ultisnips-select',
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

  Keymap i <silent> <expr> <C-Space> <SID>coc_refresh()
  function! s:coc_refresh() abort
    if dein#tap('copilot.vim')
      call copilot#Next()
      call copilot#Previous()
    endif

    return coc#refresh()
  endfunction

  " Snippet map
  " let g:coc_snippet_next = '<C-f>'
  " let g:coc_snippet_prev = '<C-b>'

  " keymap
  Keymap n <silent> K             <Cmd>call <SID>coc_show_documentation()<CR>
  Keymap n <silent> <Leader>K     <Cmd>call CocActionAsync('doHover', 'preview')<CR>
  Keymap n <silent> <Plug>(lsp)p  <Plug>(coc-diagnostic-prev)
  Keymap n <silent> <Plug>(lsp)n  <Plug>(coc-diagnostic-next)
  Keymap n <silent> <Plug>(lsp)D  <Plug>(coc-definition)
  Keymap n <silent> <Plug>(lsp)I  <Plug>(coc-implementation)
  Keymap n <silent> <Plug>(lsp)rF <Plug>(coc-references)
  Keymap n <silent> <Plug>(lsp)rn <Plug>(coc-rename)
  Keymap n <silent> <Plug>(lsp)T  <Plug>(coc-type-definition)
  Keymap n <silent> <Plug>(lsp)a  <Plug>(coc-codeaction-selected)iw
  Keymap n <silent> <Plug>(lsp)A  <Plug>(coc-codeaction)
  Keymap n <silent> <Plug>(lsp)l  <Plug>(coc-codelens-action)
  Keymap n <silent> <Plug>(lsp)f  <Plug>(coc-format)
  Keymap n <silent> <Plug>(lsp)gs <Plug>(coc-git-chunkinfo)

  Keymap n <silent> <expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : '<C-d>'
  Keymap n <silent> <expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : '<C-u>'
  Keymap i <silent> <expr> <C-d> coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(1)<CR>' : '<Del>'
  Keymap i <silent> <expr> <C-u> coc#float#has_scroll() ? '<Cmd>call coc#float#scroll(0)<CR>' : '<C-u>'

  " Keymap n <Leader>e <Cmd>CocCommand explorer<CR>
  " Keymap n <Leader>E <Cmd>CocCommand explorer --reveal expand('%')<CR>

  Keymap n <silent> gp <Plug>(coc-git-prevchunk)
  Keymap n <silent> gn <Plug>(coc-git-nextchunk)

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

  function! s:coc_show_documentation() abort
    if dein#tap('nvim-ufo') && luaeval('require("ufo").peekFoldedLinesUnderCursor()')
      return
    endif

    if index(['vim', 'help'], &filetype) >= 0
      execute 'h ' . expand('<cword>')
    elseif coc#rpc#ready()
      call CocActionAsync('doHover')
    endif
  endfunction

  function! s:coc_typescript_settings() abort
    setlocal tagfunc=CocTagFunc
    if <SID>is_deno()
      Keymap n <silent> <buffer> <Plug>(lsp)f <Plug>(coc-format)
    else
      Keymap n <silent> <buffer> <Plug>(lsp)f <Cmd>CocCommand eslint.executeAutofix<CR><Cmd>CocCommand prettier.formatFile<CR>
    endif
  endfunction

  function! s:coc_ts_ls_initialize() abort
    if <SID>is_deno()
      call coc#config('tsserver.enable', v:false)
      call coc#config('deno.enable', v:true)
      call coc#config('prettier.enable', v:false)
    else
      call coc#config('tsserver.enable', v:true)
      call coc#config('deno.enable', v:false)
      call coc#config('prettier.enable', v:true)
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
    Keymap n <silent> <buffer> gK <Cmd>CocCommand rust-analyzer.openDocs<CR>
  endfunction

  function! s:coc_pum_lexima_enter() abort
    let key = lexima#expand('<CR>', 'i')
    call coc#on_enter()
    return "\<C-g>u" . key
  endfunction

  " Initialize coc completion map
  Keymap i <expr> <CR> coc#pum#visible() ? '' : ''

  " Resetting coc completion map
  AutoCmd InsertEnter,CmdlineLeave * Keymap i <silent> <expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : ''
  AutoCmd InsertEnter,CmdlineLeave * Keymap i <silent> <expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : ''
  AutoCmd InsertEnter,CmdlineLeave * Keymap i <silent> <expr> <CR>  coc#pum#visible() ? coc#pum#confirm() : <SID>coc_pum_lexima_enter()

  AutoCmd CursorHold  *                          silent call CocActionAsync('highlight')
  AutoCmd User        CocJumpPlaceholder         call CocActionAsync('showSignatureHelp')
  AutoCmd VimEnter    *                          call <SID>coc_ts_ls_initialize()
  AutoCmd FileType    typescript,typescriptreact call <SID>coc_typescript_settings()
  AutoCmd FileType    rust                       call <SID>coc_rust_settings()
  AutoCmd FileType    vim                        setlocal tagfunc=CocTagFunc
  AutoCmd FileType    lua                        setlocal tagfunc=CocTagFunc
  AutoCmd BufEnter    deno:/*.ts                 filetype detect
endif
" }}}3

" copilot {{{3
if dein#tap('copilot.vim')
  AutoCmd InsertEnter * Keymap i <silent> <expr> <Tab> copilot#Accept()

  " Debug
  " Keymap i <C-g> <Cmd>PP b:_copilot<CR>
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

    Keymap n <buffer> K             <Plug>(lsp-hover)
    Keymap n <buffer> <Plug>(lsp)d  <Plug>(lsp-definition)
    Keymap n <buffer> <Plug>(lsp)r  <Plug>(lsp-references)
    Keymap n <buffer> <Plug>(lsp)i  <Plug>(lsp-implementation)
    Keymap n <buffer> <Plug>(lsp)t  <Plug>(lsp-type-definition)
    Keymap n <buffer> <Plug>(lsp)rn <Plug>(lsp-rename)
  endfunction

  AutoCmd User lsp_buffer_enabled call <SID>on_lsp_buffer_enabled()
endif
" }}}3

" nvim-lsp {{{3
if dein#tap('nvim-lspconfig') &&
   \ dein#tap('mason.nvim') &&
   \ dein#tap('mason-lspconfig.nvim') &&
   \ dein#tap('lspsaga.nvim')
  Keymap n <silent> K             <Cmd>call <SID>nvim_lsp_show_documentation()<CR>
  Keymap n <silent> <Plug>(lsp)a  <Cmd>Lspsaga code_action<CR>
  Keymap n <silent> <Plug>(lsp)rn <Cmd>Lspsaga rename<CR>
  Keymap n <silent> <Plug>(lsp)n  <Cmd>Lspsaga diagnostic_jump_next<CR>
  Keymap n <silent> <Plug>(lsp)p  <Cmd>Lspsaga diagnostic_jump_prev<CR>

  Keymap n <silent> <Plug>(lsp)I <Cmd>lua vim.lsp.buf.implementation()<CR>
  Keymap n <silent> <Plug>(lsp)T <Cmd>lua vim.lsp.buf.type_definition()<CR>
  Keymap n <silent> <Plug>(lsp)q <Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
  Keymap n <silent> <Plug>(lsp)f <Cmd>lua vim.lsp.buf.format()<CR>

  function! s:nvim_lsp_show_documentation() abort
    if index(['vim', 'help'], &filetype) >= 0
      execute 'h ' . expand('<cword>')
    else
      lua require('lspsaga.hover').render_hover_doc()
    endif
  endfunction

  AutoCmd CursorHold * Lspsaga show_line_diagnostics

lua <<EOF
local lsp_config = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local lsp_saga = require('lspsaga')

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
})

require('lsp_signature').setup({ hint_enable = false })
require('fidget').setup()

mason.setup({
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗'
    }
  }
})

mason_lspconfig.setup({
  ensure_installed = {
    'tsserver',
    'eslint',
    'denols',
    'prismals',
    'vimls',
    'jsonls',
    'yamlls',
  },
  automatic_installation = true,
})

mason_lspconfig.setup_handlers({
  function(server_name)
    local opts = {
      capabilities = require('cmp_nvim_lsp').update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )
    }

    if server_name == 'tsserver' then
      opts.settings = {
        format = { enable = false }
      }
    end

    if server_name == 'eslint' then
      opts.settings = {
        format = { enable = true }
      }
    end

    if server_name == 'jsonls' then
      opts.settings = {
        json = { schemas = require('schemastore').json.schemas() }
      }
    end

    if server_name == 'yamlls' then
      opts.settings = {
        yaml = { schemas = require('schemastore').json.schemas() }
      }
    end

    lsp_config[server_name].setup(opts)
  end
})

lsp_config['denols'].setup({
  root_dir = lsp_config.util.root_pattern('deno.json'),
  init_options = {
    lint = true,
    unstable = true,
    suggest = {
      imports = {
        hosts = {
          ['https://deno.land'] = true,
          ['https://cdn.nest.land'] = true,
          ['https://crux.land'] = true,
        },
      },
    },
  },
})

lsp_config['tsserver'].setup({
  root_dir = lsp_config.util.root_pattern('package.json'),
})

lsp_saga.setup({
  error_sign = " ",
  warn_sign  = " ",
  hint_sign  = " ",
  infor_sign = " ",
})
EOF
endif
" }}}3

" nvim-cmp {{{3
if dein#tap('nvim-cmp') &&
   \ dein#tap('lspkind-nvim')
  Keymap c <silent> <C-Space> <Cmd>lua require('cmp').complete()<CR>
  Keymap c <silent> <C-u>     <Cmd>lua require('cmp').mapping.scroll_docs(-4)<CR>
  Keymap c <silent> <C-d>     <Cmd>lua require('cmp').mapping.scroll_docs(4)<CR>
lua <<EOF
local cmp = require('cmp')
local lspkind = require('lspkind')

local mapping = cmp.mapping.preset.insert({
  ['<C-u>']     = cmp.mapping.scroll_docs(-4),
  ['<C-d>']     = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>']     = cmp.mapping.close(),
  ['<CR>']      = cmp.mapping.confirm({ select = true }),
})

cmp.setup({
  enabled = not vim.g.enable_coc,
  mapping = vim.g.enable_coc and {} or mapping,
  window = {
    completion    = cmp.config.window.bordered({ winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None' }),
    documentation = cmp.config.window.bordered({ winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None' }),
  },
  sources = cmp.config.sources({
    { name = 'ultisnips'   },
    { name = 'nvim_lsp'    },
    { name = 'cmp_tabnine' },
    { name = 'buffer'      },
    { name = 'path'        },
    { name = 'copilot'     },
  }),
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = lspkind.cmp_format({
      with_text = false,
      menu = {
        ultisnips   = '[ultisnips]',
        nvim_lsp    = '[LSP]',
        cmp_tabnine = '[Tabnine]',
        buffer      = '[Buffer]',
        path        = '[Path]',
        copilot     = '[Copilot]',
      },
    }),
  },
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
})

local incsearch_settings = {
  mapping = cmp.mapping.preset.cmdline({
    ['<C-n>'] = vim.NIL,
    ['<C-p>'] = vim.NIL,
    ['<C-e>'] = vim.NIL,
  }),
  sources = {
    { name = 'buffer' },
  },
  formatting = {
    fields = { 'abbr' },
    format = lspkind.cmp_format({ with_text = false })
  },
  incseach_redraw_keys = '<C-r><BS>',
}

cmp.setup.cmdline('/', incsearch_settings)
cmp.setup.cmdline('?', incsearch_settings)
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    ['<C-n>'] = vim.NIL,
    ['<C-p>'] = vim.NIL,
    ['<C-e>'] = vim.NIL,
  }),
  sources = cmp.config.sources({
    { name = 'cmdline' },
    {
      name = 'fuzzy_path',
      trigger_characters = { ' ', '.', '/', '~' },
      options = {
        fd_cmd = {
          'fd',
          '--hidden',
          '--max-depth',
          '20',
          '--full-path',
          '--exclude',
          '.git',
        },
      },
    },
  }),
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      if vim.tbl_contains({ 'fuzzy_path' }, entry.source.name) then
        local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
        if icon then
          vim_item.kind = icon
          vim_item.kind_hl_group = hl_group
        else
          vim_item.kind = ' '
        end
      elseif vim.tbl_contains({ 'cmdline' }, entry.source.name) then
        vim_item.kind = ' '
        vim_item.dup = true
      end

      return lspkind.cmp_format()(entry, vim_item)
    end
  },
})

vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
  callback = function()
    cmp.setup({
      enabled = true,
    })
  end
})
vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
  callback = function()
    cmp.setup({
      enabled = not vim.g.enable_coc,
    })
  end
})

vim.api.nvim_create_autocmd({ 'CmdWinEnter' }, {
  callback = function()
    cmp.setup.buffer({
      enabled = true,
      mapping = mapping,
    })
  end
})

require('cmp.utils.misc').redraw.incsearch_redraw_keys = '<C-r><BS>'

require('lspkind').init({
  preset = 'codicons',
  symbol_map = {
    Text          = ' ',
    Method        = ' ',
    Function      = ' ',
    Constructor   = ' ',
    Field         = ' ',
    Variable      = ' ',
    Class         = ' ',
    Interface     = ' ',
    Module        = ' ',
    Property      = ' ',
    Unit          = ' ',
    Value         = ' ',
    Enum          = ' ',
    Keyword       = ' ',
    Snippet       = ' ',
    Color         = ' ',
    File          = ' ',
    Reference     = ' ',
    Folder        = ' ',
    EnumMember    = ' ',
    Constant      = ' ',
    Struct        = ' ',
    Event         = ' ',
    Operator      = ' ',
    TypeParameter = ' ',
    Copilot       = ' ',
  },
})

require('copilot').setup()
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
    "lua",
    "json",
    "yaml",
    "markdown",
    "dockerfile",
    "html",
    "css",
    "comment",
    "regex",
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
  yati = {
    enable = true,
  },
  matchup = {
    enable = true,
    disable_virtual_text = true,
  },
}

-- require('treesitter-unit').enable_highlighting()

require('indent_blankline').setup({
  show_current_context       = true,
  show_current_context_start = true,
})

require('treesitter-context').setup()
-- require('leap').opts.safe_labels = {}
EOF
  AutoCmd VimEnter * lua require('hlargs').setup()

  " function! s:leap_fold() abort
  "   lua require('leap-ast').leap()
  " endfunction
  " Keymap n <silent> zf zf<Cmd>call <SID>leap_fold()<CR>
  " AutoCmd User LeapEnter lua require('hlargs').disable()
  " AutoCmd User LeapLeave lua require('hlargs').enable()

  function! s:fold_treehopper() abort
    lua require('hlargs').disable()
    lua pcall(function() require('tsht').nodes() vim.cmd('normal! zf') end)
    lua require('hlargs').enable()
  endfunction
  Keymap n <silent> zf <Cmd>call <SID>fold_treehopper()<CR>

  Keymap ox <silent> <Plug>(textobj-treesitter-unit-i) :lua require('treesitter-unit').select()<CR>
  Keymap ox <silent> <Plug>(textobj-treesitter-unit-a) :lua require('treesitter-unit').select(true)<CR>

  Keymap ox <silent> iu <Plug>(textobj-treesitter-unit-i)
  Keymap ox <silent> au <Plug>(textobj-treesitter-unit-a)

  let g:indent_blankline_enabled = v:false
  Keymap n <silent> <Leader>i <Cmd>IndentBlanklineToggle!<CR>

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
    Keymap n <silent> <expr> <buffer>          i       denite#do_map('open_filter_buffer')
    Keymap n <silent> <expr> <buffer>          <CR>    denite#do_map('do_action')
    Keymap n <silent> <expr> <buffer>          <Tab>   denite#do_map('choose_action')
    Keymap n <silent> <expr> <buffer>          <C-g>   denite#do_map('quit')
    Keymap n <silent> <expr> <buffer>          q       denite#do_map('quit')
    Keymap n <silent> <expr> <buffer>          ZQ      denite#do_map('quit')
    Keymap n <silent>        <buffer>          <C-n>   j
    Keymap n <silent>        <buffer>          <C-p>   k
    Keymap n <silent> <expr> <buffer> <nowait> <Space> denite#do_map('toggle_select') . 'j'
    Keymap n <silent> <expr> <buffer>          d       denite#do_map('do_action', 'delete')
    Keymap n <silent> <expr> <buffer>          p       denite#do_map('do_action', 'preview')
  endfunction

  function! s:denite_filter_settings() abort
    Keymap n <silent> <expr> <buffer> <C-g> denite#do_map('quit')
    Keymap n <silent> <expr> <buffer> q     denite#do_map('quit')
    Keymap n <silent> <expr> <buffer> ZQ    denite#do_map('quit')
    Keymap i <silent>        <buffer> <C-g> <Esc>
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
  let g:fzf_layout        = { 'window': { 'width': 0.9, 'height': 0.9 } }
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
  " let g:fzf_preview_direct_window_option = { 'width': 0.3, 'height': 0.3 }
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

  Keymap n <silent> <Plug>(fzf-p)r     <Cmd>FzfPreviewProjectMruFilesRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)w     <Cmd>FzfPreviewProjectMrwFilesRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)a     <Cmd>FzfPreviewFromResourcesRpc --experimental-fast project_mru git<CR>
  Keymap n <silent> <Plug>(fzf-p)s     <Cmd>FzfPreviewGitStatusRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)gg    <Cmd>FzfPreviewGitActionsRpc<CR>
  Keymap n <silent> <Plug>(fzf-p)b     <Cmd>FzfPreviewBuffersRpc<CR>
  Keymap n <silent> <Plug>(fzf-p)B     <Cmd>FzfPreviewAllBuffersRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)<C-o> <Cmd>FzfPreviewJumpsRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)g;    <Cmd>FzfPreviewChangesRpc<CR>
  Keymap n <silent> <Plug>(fzf-p)/     <Cmd>FzfPreviewLinesRpc --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  Keymap n <silent> <Plug>(fzf-p)/     :<C-u>FzfPreviewProjectGrepRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort . <C-r>=expand('%')<CR><CR>
  Keymap n <silent> <Plug>(fzf-p)*     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
  Keymap x <silent> <Plug>(fzf-p)*     "sy:FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--exact --add-fzf-arg=--query="<C-r>=substitute(@s, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
  Keymap n <silent> <Plug>(fzf-p)n     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="<C-r>=substitute(@/, '\(^\\v\)\\|\\\(<\\|>\)', '', 'g')<CR>"<CR>
  Keymap n <silent> <Plug>(fzf-p)?     <Cmd>FzfPreviewBufferLinesRpc --resume --add-fzf-arg=--no-sort<CR>
  Keymap n <silent> <Plug>(fzf-p)q     <Cmd>FzfPreviewQuickFixRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)l     <Cmd>FzfPreviewLocationListRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p):     <Cmd>FzfPreviewCommandPaletteRpc --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)m     <Cmd>FzfPreviewBookmarksRpc --resume --experimental-fast<CR>
  Keymap n <silent> <Plug>(fzf-p)<C-]> :<C-u>FzfPreviewVistaCtagsRpc --experimental-fast --add-fzf-arg=--query="<C-r>=expand('<cword>')<CR>"<CR>
  Keymap n <silent> <Plug>(fzf-p)o     <Cmd>FzfPreviewVistaBufferCtagsRpc --experimental-fast<CR>

  Keymap n          <Plug>(fzf-p)f :<C-u>FzfPreviewProjectGrepRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>
  Keymap x          <Plug>(fzf-p)f "sy:FzfPreviewProjectGrepRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
  Keymap n <silent> <Plug>(fzf-p)F <Cmd>FzfPreviewProjectGrepRecallRpc --experimental-fast --resume --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  Keymap n          <Plug>(fzf-p)h :<C-u>FzfPreviewGrepHelpRpc --experimental-fast --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>

  if dein#tap('coc.nvim')
    Keymap n <silent> <Plug>(fzf-p)p <Cmd>CocCommand fzf-preview.Yankround --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  else
    Keymap n <silent> <Plug>(fzf-p)p <Cmd>FzfPreviewYankroundRpc --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  endif

  Keymap n <silent> <Plug>(lsp)q  <Cmd>CocCommand fzf-preview.CocCurrentDiagnostics<CR>
  Keymap n <silent> <Plug>(lsp)Q  <Cmd>CocCommand fzf-preview.CocDiagnostics<CR>
  Keymap n <silent> <Plug>(lsp)rf <Cmd>CocCommand fzf-preview.CocReferences<CR>
  Keymap n <silent> <Plug>(lsp)d  <Cmd>CocCommand fzf-preview.CocDefinition<CR>
  Keymap n <silent> <Plug>(lsp)t  <Cmd>CocCommand fzf-preview.CocTypeDefinition<CR>
  Keymap n <silent> <Plug>(lsp)i  <Cmd>CocCommand fzf-preview.CocImplementations<CR>
  Keymap n <silent> <Plug>(lsp)o  <Cmd>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>
  Keymap n <silent> <Plug>(lsp)s  <Cmd>CocCommand fzf-preview.CocTsServerSourceDefinition<CR>

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
  lua require('telescope').setup()
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

  Keymap n <silent> gm <Cmd>GitMessenger<CR>
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
  Keymap n <silent> gp <Cmd>lua require('gitsigns').prev_hunk()<CR>
  Keymap n <silent> gn <Cmd>lua require('gitsigns').next_hunk()<CR>
  Keymap n <silent> gh <Cmd>lua require('gitsigns').preview_hunk()<CR>

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

  Keymap n <silent> <Leader><Leader>e :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft<CR>
  Keymap n <silent> <Leader><Leader>E :Defx -columns=mark:git:indent:icons:filename:type -split=vertical -winwidth=40 -direction=topleft -search=`expand('%:p')`<CR>

  let g:defx_ignore_filtype = ['denite', 'defx']

  function! s:defx_settings() abort
    Keymap n <silent> <buffer> <expr> <nowait> j       line('.') == line('$') ? 'gg' : 'j'
    Keymap n <silent> <buffer> <expr> <nowait> k       line('.') == 1 ? 'G' : 'k'
    Keymap n <silent> <buffer> <expr> <nowait> t       defx#do_action('open_or_close_tree')
    Keymap n <silent> <buffer> <expr> <nowait> h       defx#do_action('cd', ['..'])
    Keymap n <silent> <buffer> <expr> <nowait> l       defx#is_directory() ? defx#do_action('open_tree') : 0
    Keymap n <silent> <buffer> <expr> <nowait> L       defx#do_action('open_tree_recursive')
    Keymap n <silent> <buffer> <expr> <nowait> .       defx#do_action('toggle_ignored_files')
    Keymap n <silent> <buffer> <expr> <nowait> ~       defx#do_action('cd')

    Keymap n <silent> <buffer> <expr> <nowait> <CR>    defx#is_directory() ? 0 : defx#do_action('open', 'choose')
    Keymap n <silent> <buffer> <expr> <nowait> x       defx#do_action('toggle_select') . 'j'
    Keymap n <silent> <buffer> <expr> <nowait> <Space> defx#do_action('toggle_select') . 'j'
    Keymap n <silent> <buffer> <expr> <nowait> *       defx#do_action('toggle_select_all')
    Keymap n <silent> <buffer> <expr> <nowait> N       defx#do_action('new_file')
    Keymap n <silent> <buffer> <expr> <nowait> N       defx#do_action('new_multiple_files')
    Keymap n <silent> <buffer> <expr> <nowait> K       defx#do_action('new_directory')
    Keymap n <silent> <buffer> <expr> <nowait> c       defx#do_action('copy')
    Keymap n <silent> <buffer> <expr> <nowait> m       defx#do_action('move')
    Keymap n <silent> <buffer> <expr> <nowait> p       defx#do_action('paste')
    Keymap n <silent> <buffer> <expr> <nowait> d       defx#do_action('remove')
    Keymap n <silent> <buffer> <expr> <nowait> r       defx#do_action('rename')
    Keymap n <silent> <buffer> <expr> <nowait> yy      defx#do_action('yank_path')

    Keymap n <silent> <buffer> <expr> <nowait> q       defx#do_action('quit')
    Keymap n <silent> <buffer> <expr> <nowait> R       defx#do_action('redraw')
    Keymap n <silent> <buffer> <expr> <nowait> <C-g>   defx#do_action('print')

    Keymap n <silent> <buffer> <expr> <nowait> p       defx#do_action('preview')
  endfunction

  AutoCmd FileType defx call <SID>defx_settings()
endif
" }}}3

" fern {{{3
if dein#tap('fern.vim')
  function! s:fern_reveal(dict) abort
    execute 'FernReveal' a:dict.relative_path
  endfunction

  let g:fern#disable_default_mappings  = 1
  let g:fern#drawer_width              = 40
  let g:fern#renderer                  = 'nerdfont'
  let g:fern#renderer#nerdfont#padding = '  '
  let g:fern#hide_cursor               = 1
  let g:fern#window_selector_use_popup = 1
  let g:fern_preview_window_highlight  = 'Normal:Normal,FloatBorder:Normal'

  function! s:fern_preview_width() abort
    return min([float2nr(&columns * 0.8), 200])
  endfunction

  let g:fern_preview_window_calculator = {
  \ 'width': function('s:fern_preview_width')
  \ }

  Keymap n <silent> <Leader>e <Cmd>Fern . -drawer<CR><C-w>=
  Keymap n <silent> <Leader>E <Cmd>Fern . -drawer -reveal=%<CR><C-w>=

  function! s:fern_settings() abort
    nnoremap <silent>        <buffer> <Plug>(fern-page-down-wrapper) <C-d>
    nnoremap <silent>        <buffer> <Plug>(fern-page-up-wrapper)   <C-u>
    nnoremap <silent> <expr> <buffer> <Plug>(fern-page-down-or-scroll-down-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
    nnoremap <silent> <expr> <buffer> <Plug>(fern-page-down-or-scroll-up-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")

    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-expand-or-collapse)               fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")
    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-open-system-or-open-file)         fern#smart#leaf("\<Plug>(fern-action-open:select)", "\<Plug>(fern-action-open:system)")
    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-quit-or-close-preview)            fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":q\<CR>")
    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-wipe-or-close-preview)            fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":bwipe!\<CR>")
    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-page-down-or-scroll-down-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
    Keymap n <silent> <expr> <buffer> <Plug>(fern-action-page-down-or-scroll-up-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")

    Keymap n  <silent>        <buffer> <nowait> a       <Plug>(fern-action-choice)
    Keymap n  <silent>        <buffer> <nowait> <CR>    <Plug>(fern-action-open-system-or-open-file)
    Keymap n  <silent>        <buffer> <nowait> t       <Plug>(fern-action-expand-or-collapse)
    Keymap n  <silent>        <buffer> <nowait> l       <Plug>(fern-action-open-or-enter)
    Keymap n  <silent>        <buffer> <nowait> h       <Plug>(fern-action-leave)
    Keymap nx <silent>        <buffer> <nowait> x       <Plug>(fern-action-mark:toggle)j
    Keymap nx <silent>        <buffer> <nowait> <Space> <Plug>(fern-action-mark:toggle)j
    Keymap n  <silent> <expr> <buffer> <nowait> N       v:hlsearch ? 'N' : '<Plug>(fern-action-new-file)'
    Keymap n  <silent>        <buffer> <nowait> K       <Plug>(fern-action-new-dir)
    Keymap n  <silent>        <buffer> <nowait> d       <Plug>(fern-action-trash)
    Keymap n  <silent>        <buffer> <nowait> r       <Plug>(fern-action-rename)
    Keymap n  <silent>        <buffer> <nowait> c       <Plug>(fern-action-copy)
    Keymap n  <silent>        <buffer> <nowait> C       <Plug>(fern-action-clipboard-copy)
    Keymap n  <silent>        <buffer> <nowait> m       <Plug>(fern-action-move)
    Keymap n  <silent>        <buffer> <nowait> M       <Plug>(fern-action-clipboard-move)
    Keymap n  <silent>        <buffer> <nowait> P       <Plug>(fern-action-clipboard-paste)
    Keymap n  <silent>        <buffer> <nowait> !       <Plug>(fern-action-hidden:toggle)
    Keymap n  <silent>        <buffer> <nowait> y       <Plug>(fern-action-yank)
    Keymap n  <silent>        <buffer> <nowait> <C-g>   <Plug>(fern-action-debug)
    Keymap n  <silent>        <buffer> <nowait> ?       <Plug>(fern-action-help)
    Keymap n  <silent>        <buffer> <nowait> <C-c>   <Plug>(fern-action-cancel)
    Keymap n  <silent>        <buffer> <nowait> .       <Plug>(fern-repeat)
    Keymap n  <silent>        <buffer> <nowait> q       <Plug>(fern-action-quit-or-close-preview)
    Keymap n  <silent>        <buffer> <nowait> Q       <Plug>(fern-action-wipe-or-close-preview)
    Keymap n  <silent>        <buffer> <nowait> p       <Plug>(fern-action-preview:toggle)
    Keymap n  <silent>        <buffer> <nowait> <C-p>   <Plug>(fern-action-preview:auto:toggle)
    Keymap n  <silent>        <buffer> <nowait> <C-d>   <Plug>(fern-action-page-down-or-scroll-down-preview)
    Keymap n  <silent>        <buffer> <nowait> <C-u>   <Plug>(fern-action-page-down-or-scroll-up-preview)
    Keymap n  <silent>        <buffer> <nowait> R       <Plug>(fern-action-reload:all)

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

  Keymap o i=h <Plug>(operator-lhs)
  Keymap x i=h <Plug>(visual-lhs)
  Keymap o i=l <Plug>(operator-rhs)
  Keymap x i=l <Plug>(visual-rhs)
endif
" }}}3

" operator-convert-case {{{3
if dein#tap('vim-operator-convert-case')
  Keymap n cy <Plug>(operator-convert-case-loop)iw
endif
" }}}3

" operator-replace {{{3
if dein#tap('vim-operator-replace')
  Keymap nx _ <Plug>(operator-replace)
endif
" }}}3

" swap {{{3
if dein#tap('vim-swap')
  Keymap n g< <Plug>(swap-prev)
  Keymap n g> <Plug>(swap-next)
  Keymap n gs <Plug>(swap-interactive)

  Keymap ox i, <Plug>(swap-textobject-i)
  Keymap ox a, <Plug>(swap-textobject-a)
endif
" }}}3

" textobj-between {{{3
if dein#tap('vim-textobj-between')
  let g:textobj_between_no_default_key_mappings = 1

  Keymap ox i/ <Plug>(textobj-between-i)/
  Keymap ox a/ <Plug>(textobj-between-a)/
  Keymap ox i_ <Plug>(textobj-between-i)_
  Keymap ox a_ <Plug>(textobj-between-a)_
  Keymap ox i- <Plug>(textobj-between-i)-
  Keymap ox a- <Plug>(textobj-between-a)-
endif
" }}}3

" textobj-cursor-context {{{3
if dein#tap('vim-textobj-cursor-context')
  let g:textobj_cursorcontext_no_default_key_mappings = 1

  Keymap ox ic <Plug>(textobj-cursorcontext-i)
  Keymap ox ac <Plug>(textobj-cursorcontext-a)
endif
" }}}3

" textobj-entire {{{3
if dein#tap('vim-textobj-entire')
  let g:textobj_entire_no_default_key_mappings = 1

  Keymap ox ie <Plug>(textobj-entire-i)
  Keymap ox ae <Plug>(textobj-entire-a)
endif
" }}}3

" textobj-functioncall {{{3
if dein#tap('vim-textobj-functioncall')
  let g:textobj_functioncall_no_default_key_mappings = 1

  Keymap ox if <Plug>(textobj-functioncall-i)
  Keymap ox af <Plug>(textobj-functioncall-a)
endif
" }}}3

" textobj-indent {{{3
if dein#tap('vim-textobj-indent')
  let g:textobj_indent_no_default_key_mappings = 1

  Keymap ox ii <Plug>(textobj-indent-i)
  Keymap ox ai <Plug>(textobj-indent-a)
endif
" }}}3

" textobj-line {{{3
if dein#tap('vim-textobj-line')
  let g:textobj_line_no_default_key_mappings = 1

  Keymap ox il <Plug>(textobj-line-i)
  Keymap ox al <Plug>(textobj-line-a)
endif
" }}}3

" textobj-url {{{3
if dein#tap('vim-textobj-url')
  let g:textobj_url_no_default_key_mappings = 1

  Keymap ox iu <Plug>(textobj-url-i)
  Keymap ox au <Plug>(textobj-url-a)
endif
" }}}3

" }}}2

" Edit & Move & Search {{{2

" accelerated-jk {{{3
if dein#tap('accelerated-jk')
  Keymap n j <Plug>(accelerated_jk_j)
  Keymap n k <Plug>(accelerated_jk_k)
endif
" }}}3

" hlslens & asterisk & anzu & searchx {{{3
if dein#tap('nvim-hlslens') &&
   \ dein#tap('vim-asterisk') &&
   \ dein#tap('vim-anzu') &&
   \ dein#tap('vim-searchx') &&
   \ has('nvim')
  lua require('hlslens').setup({ auto_enable = true })

  let g:searchx             = {}
  let g:searchx.auto_accept = v:false
  let g:searchx.markers     = split('ASDFGHJKLQWERTYUIOPZXCVBNM', '.\zs')
  let g:searchx.scrolloff   = &scrolloff

  function! g:searchx.convert(input) abort
    if a:input !~# '\k'
      return '\V' .. a:input
    endif

    if dein#tap('fuzzy-motion.vim') && a:input =~# ';'
      let max_score = 0
      let fuzzy_input = ''

      for q in s:fuzzy_query(a:input)
        let targets = fuzzy_motion#targets(q)

        if len(targets) > 0 && targets[0].score > max_score
          let max_score = targets[0].score
          let fuzzy_input = join(split(q, ' '), '.\{-}')
        endif
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

  Keymap nox /          <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 1})<CR>
  Keymap nox ?          <Cmd>call SearchInfo(0, 0)<CR><Cmd>call searchx#start({'dir': 0})<CR>
  Keymap nox <silent> n <Cmd>call searchx#next_dir()<CR><Cmd>call SearchInfo(1, 1)<CR>zzzv
  Keymap nox <silent> N <Cmd>call searchx#prev_dir()<CR><Cmd>call SearchInfo(1, 1)<CR>zzzv

  Keymap nx <silent> *  <Cmd>call Asterisk(1)<CR><Cmd>call SearchInfo(1, 1)<CR>
  Keymap nx <silent> g* <Cmd>call Asterisk(0)<CR><Cmd>call SearchInfo(1, 1)<CR>

  Keymap n          '     <Cmd>call searchx#select()<CR>
  Keymap c <silent> <C-j> <Cmd>call searchx#next_dir()<CR>
  Keymap c <silent> <C-k> <Cmd>call searchx#prev_dir()<CR>

  function! SearchInfo(hlslens_start, anzu_update) abort
    if a:hlslens_start
      lua require('hlslens').enable()
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
    " lua require('hlslens').start(true)

    Keymap c <C-s> <Cmd>call <SID>change_fuzzy_motion()<CR>
  endfunction

  function! s:search_leave() abort
    lua require('hlslens').enable()
    lua require('hlslens').start()

    normal! zv
    AnzuUpdateSearchStatus

    try
      cunmap <C-s>
    catch /.*/
    endtry
  endfunction

  function! s:search_cancel() abort
    lua require('hlslens').disable()
    AnzuClearSearchStatus

    try
      cunmap <C-s>
    catch /.*/
    endtry
  endfunction

  function! s:search_accept() abort
    call feedkeys("\<Cmd>set hlsearch\<CR>", 'n')
  endfunction

  AutoCmd User SearchxEnter                      call <SID>search_enter()
  AutoCmd User SearchxLeave                      call <SID>search_leave()
  AutoCmd User SearchxCancel                     call <SID>search_cancel()
  AutoCmd User SearchxAccept,SearchxAcceptReturn call <SID>search_accept()
endif
" }}}3

" hlslens & asterisk & anzu & !searchx {{{3
if dein#tap('nvim-hlslens') &&
   \ dein#tap('vim-asterisk') &&
   \ dein#tap('vim-anzu') &&
   \ !dein#tap('vim-searchx') &&
   \ has('nvim')
  lua require('hlslens').setup({ calm_down = true })

  Keymap n           /  <Cmd>lua require('hlslens').enable()<CR>/
  Keymap n           ?  <Cmd>lua require('hlslens').enable()<CR>?
  Keymap n  <silent> n  <Cmd>lua require('hlslens').enable()<CR><Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)zzzv
  Keymap n  <silent> N  <Cmd>lua require('hlslens').enable()<CR><Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)zzzv
  Keymap nx <silent> *  <Cmd>lua require('hlslens').enable()<CR><Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)
  Keymap nx <silent> #  <Cmd>lua require('hlslens').enable()<CR><Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)
  Keymap nx <silent> g* <Cmd>lua require('hlslens').enable()<CR><Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)
  Keymap nx <silent> g# <Cmd>lua require('hlslens').enable()<CR><Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR><Plug>(anzu-update-search-status)
endif
" }}}3

" BackAndForward {{{3
if dein#tap('BackAndForward.vim')
  Keymap n <C-b> <Plug>(backandforward-back)
  Keymap n <C-f> <Plug>(backandforward-forward)
endif
" }}}3

" bookmarks {{{3
if dein#tap('vim-bookmarks')
  let g:bookmark_no_default_key_mappings = 1
  let g:bookmark_save_per_working_dir    = 1

  Keymap n <silent> <Plug>(bookmark)m <Cmd>BookmarkToggle<CR>
  Keymap n <silent> <Plug>(bookmark)i <Cmd>BookmarkAnnotate<CR>
  Keymap n <silent> <Plug>(bookmark)n <Cmd>BookmarkNext<CR>
  Keymap n <silent> <Plug>(bookmark)p <Cmd>BookmarkPrev<CR>
  Keymap n <silent> <Plug>(bookmark)a <Cmd>BookmarkShowAll<CR>
  Keymap n <silent> <Plug>(bookmark)c <Cmd>BookmarkClear<CR>
  Keymap n <silent> <Plug>(bookmark)x <Cmd>BookmarkClearAll<CR>

  function! g:BMWorkDirFileLocation() abort
    let filename = 'bookmarks'
    let location = ''

    if isdirectory('.git')
      let location = getcwd() . '/.git'
      return location . '/' . filename
    endif
  endfunction
endif
" }}}3

" caw {{{3
if dein#tap('caw.vim')
  let g:caw_no_default_keymappings = 1
  " let g:caw_integrated_plugin = 'ts_context_commentstring'

  omap <Plug>(line) <Cmd>normal! v^og_<CR><Cmd>normal! 0<CR>

  Keymap! n  <silent> <expr> gcc <SID>caw_hatpos_toggle() . '<Plug>(line)'
  Keymap! nx <silent> <expr> gc  <SID>caw_hatpos_toggle()
  Keymap! n  <silent> <expr> gww <SID>caw_wrap_toggle() . '<Plug>(line)'
  Keymap! nx <silent> <expr> gw  <SID>caw_wrap_toggle()

  function! s:caw_hatpos_toggle() abort
    if dein#tap('nvim-ts-context-commentstring')
      lua require('ts_context_commentstring.internal').update_commentstring()
      call caw#update_comments_from_commentstring(&commentstring)
    endif

    return "\<Plug>(caw:hatpos:toggle:operator)"
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

    return "\<Plug>(caw:wrap:toggle:operator)"
  endfunction
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

" deindent-yank {{{3
if dein#tap('deindent-yank.vim')
  Keymap n <silent> gy <Plug>(deindent-yank-normal)
  Keymap x <silent> gy <Plug>(deindent-yank-visual)
endif
" }}}3

" dps-dial {{{3
if dein#tap('dps-dial.vim')
  Keymap nx <C-a>  <Plug>(dps-dial-increment)
  Keymap nx <C-a>  <Plug>(dps-dial-increment)
  Keymap nx <C-x>  <Plug>(dps-dial-decrement)
  Keymap nx <C-x>  <Plug>(dps-dial-decrement)

  function! s:dps_dial_settings() abort
    let g:dps_dial#augends = ['decimal-integer', 'boolean', 'and_or', 'const_let', 'date', 'date-slash', 'color']
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
  Keymap x ga <Plug>(EasyAlign)

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

  Keymap n  <silent> S  <Plug>(easymotion-overwin-f)
  Keymap ox <silent> S  <Plug>(easymotion-bd-f)
  Keymap n  <silent> ss <Plug>(easymotion-overwin-w)
  Keymap ox <silent> ss <Plug>(easymotion-bd-w)
endif
" }}}3

" eft {{{3
if dein#tap('vim-eft')
  let g:eft_enable = v:true
  Keymap n <Leader>f <Cmd>EftToggle<CR>

  function! s:eft_toggle() abort
    if g:eft_enable
      let g:eft_enable = v:false
      call <SID>eft_disable()
    else
      let g:eft_enable = v:true
      call <SID>eft_enable()
    endif
  endfunction
  command! EftToggle call <SID>eft_toggle()

  function! s:eft_enable() abort
    Keymap nox ;; <Plug>(eft-repeat)

    Keymap nox f <Plug>(eft-f)
    Keymap nox F <Plug>(eft-F)
    Keymap ox  t <Plug>(eft-t)
    Keymap ox  T <Plug>(eft-T)
  endfunction

  function! s:eft_disable() abort
    Keymap n ;; ;
    Keymap n ;; ;

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

" emcl {{{3
if dein#tap('emcl.nvim')
  lua require('emcl').setup({})
endif
" }}}3

" exchange {{{3
if dein#tap('vim-exchange')
  Keymap x <silent> X <Plug>(Exchange)
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

  Keymap x v <Plug>(expand_region_expand)
  Keymap x V <Plug>(expand_region_shrink)
endif
" }}}3

" edgemotion {{{3
if dein#tap('vim-edgemotion')
  Keymap n  <silent> <expr> <Leader>j 'm`' . edgemotion#move(1)
  Keymap ox <silent> <expr> <Leader>j edgemotion#move(1)
  Keymap n  <silent> <expr> <Leader>k 'm`' . edgemotion#move(0)
  Keymap ox <silent> <expr> <Leader>k edgemotion#move(0)
endif
" }}}3

" fuzzy-motion {{{3
if dein#tap('fuzzy-motion.vim')
  let g:fuzzy_motion_word_regexp_list = ['[0-9a-zA-Z_-]+', '([0-9a-zA-Z_-]|[.])+', '([0-9a-zA-Z]|[()<>.-_#''"]|(\s=+\s)|(,\s)|(:\s)|(\s=>\s))+']

  Keymap nx <silent> ss <Cmd>FuzzyMotion<CR>
endif
" }}}3

" gomove {{{3
if dein#tap('nvim-gomove')
  function! SetupGomove() abort
    lua require("gomove").setup { map_defaults = true, reindent_mode = 'none' }
  endfunction

  Keymap x <silent> <C-h> <Plug>GoVSMLeft
  Keymap x <silent> <C-k> <Plug>GoVSMUp
  Keymap x <silent> <C-j> <Plug>GoVSMDown
  Keymap x <silent> <C-l> <Plug>GoVSMRight
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

  Keymap n <silent> <Leader>g <Cmd>GrepperRg<CR>
endif
" }}}3

" hop {{{3
if dein#tap('hop.nvim')
lua << EOF
require'hop'.setup()
EOF
  Keymap n <silent> S  <Cmd>HopWord<CR>
  Keymap n <silent> ss <Cmd>HopWord<CR>
endif
" }}}3

" jplus {{{3
if dein#tap('vim-jplus')
  Keymap nx <silent> J         <Plug>(jplus)
  Keymap nx <silent> <Leader>J <Plug>(jplus-input)
endif
" }}}3

" kommentary {{{3
if dein#tap('kommentary')
  let g:kommentary_create_default_mappings = v:false

  Keymap n <silent> <Leader>cc <Plug>kommentary_line_default
  Keymap n <silent> <Leader>c  <Plug>kommentary_motion_default
  Keymap x <silent> <Leader>cc <Plug>kommentary_visual_default

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
    \ { 'char': '<C-f>',                                 'input': '<C-g>U<Right>' },
    \ { 'char': '<C-f>', 'at': '\%#\s*)',  'leave': ')',                          },
    \ { 'char': '<C-f>', 'at': '\%#\s*\}', 'leave': '}',                          },
    \ { 'char': '<C-f>', 'at': '\%#\s*\]', 'leave': ']',                          },
    \ { 'char': '<C-f>', 'at': '\%#\s*''', 'leave': '''',                         },
    \ { 'char': '<C-f>', 'at': '\%#\s*"',  'leave': '"',                          },
    \ { 'char': '<C-f>', 'at': '\%#\s*`',  'leave': '`',                          },
    \ ]

    "" Insert semicolon at the end of the line
    let s:rules += [
    \ { 'char': ';', 'at': '(.*;\%#)$',   'input': '<BS><C-g>U<Right>;' },
    \ { 'char': ';', 'at': '^\s*;\%#)$',  'input': '<BS><C-g>U<Right>;' },
    \ { 'char': ';', 'at': '(.*;\%#\}$',  'input': '<BS><C-g>U<Right>;' },
    \ { 'char': ';', 'at': '^\s*;\%#\}$', 'input': '<BS><C-g>U<Right>;' },
    \ ]

    "" Surround function
    let s:rules += [
    \ { 'char': '>', 'at': ')>\%#', 'input': '<BS><BS><C-o>:normal! f(<CR><C-o>:normal %<CR>)' },
    \ ]

    "" TypeScript
    let s:rules += [
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\.[a-zA-Z]\+([a-zA-Z,]*>\%#)',       'input': '<BS> => {', 'input_after': '}'                           },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '\.[a-zA-Z]\+(([a-zA-Z, :<>]*>\%#))', 'input': '<BS><C-g>U<Right> => {', 'input_after': '}'              },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '([a-zA-Z, :<>]*>\%#)',               'input': '<BS><C-g>U<Right> => {', 'input_after': '}'              },
    \ { 'filetype': ['typescript', 'typescriptreact', 'javascript'], 'char': '>', 'at': '({[a-zA-Z, :<>]\+>\%#\s\?})',        'input': '<BS><C-o>:normal! f)<CR><C-g>U<Right> => {}<C-g>U<Left>' },
    \ ]

    "" TSX with nvim-ts-autotag
    if dein#tap('nvim-ts-autotag')
      let s:rules += [
      \ { 'filetype': ['typescriptreact'], 'char': '>', 'at': '<[a-zA-Z.]\+\(\s\)\?.*\%#', 'input': '><Esc>:lua require(''nvim-ts-autotag.internal'').close_tag()<CR>a', },
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
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#',        'input': '=<Space><C-g>U<Right>',           'input_after': '<Space>%>',                 },
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\s\%#\s%>',  'input': '<C-g>U<Left>=<C-g>U<Right>',                                                  },
    \ { 'filetype': 'eruby', 'char': '=',     'at': '<%\%#.\+%>',                                                                           'priority': 10, },
    \ { 'filetype': 'eruby', 'char': '<C-h>', 'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
    \ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%\s\%#\s%>',  'input': '<BS><BS><BS><Del><Del><Del>',                                                 },
    \ { 'filetype': 'eruby', 'char': '<C-h>', 'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
    \ { 'filetype': 'eruby', 'char': '<BS>',  'at': '<%=\s\%#\s%>', 'input': '<BS><BS><BS><BS><Del><Del><Del>',                                             },
    \ ]

    "" markdown
    let s:rules += [
    \ { 'filetype': 'markdown', 'char': '#',       'at': '^\%#\%(#\)\@!',                  'input': '#<Space>'                           },
    \ { 'filetype': 'markdown', 'char': '#',       'at': '#\s\%#',                         'input': '<BS>#<Space>',                      },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^#\s\%#',                        'input': '<BS><BS>'                           },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '##\s\%#',                        'input': '<BS><BS><Space>',                   },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^#\s\%#',                        'input': '<BS><BS>'                           },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '##\s\%#',                        'input': '<BS><BS><Space>',                   },
    \ { 'filetype': 'markdown', 'char': '-',       'at': '^\s*\%#',                        'input': '-<Space>',                          },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\%#',                     'input': '<Home><Tab><End>',                  },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\w.*\%#',                 'input': '<Home><Tab><End>',                  },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\%#',                    'input': '<Home><Del><Del><End>',             },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\w.*\%#',                'input': '<Home><Del><Del><End>',             },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\w.*\%#',                    'input': '',                                  },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^-\s\%#',                        'input': '<C-w><BS>',                         },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><BS>',                    },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\%#',                        'input': '<C-w><BS>',                         },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><BS>',                    },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\%#',                        'input': '<C-w><CR>',                         },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\%#',                    'input': '<C-w><C-w><CR>',                    },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\w.*\%#',                 'input': '<CR>-<Space>',                      },
    \ { 'filetype': 'markdown', 'char': '[',       'at': '^\s*-\s\%#',                     'input': '<Left><Space>[]<Left>',             },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\%#\]\s',               'input': '<Home><Tab><End><Left><Left>',      },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\%#\]\s',                  'input': '',                                  },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\%#\]\s',              'input': '<Home><Del><Del><End><Left><Left>', },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s*-\s\[\%#\]',                 'input': '<BS><Del><Del>',                    },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s*-\s\[\%#\]',                 'input': '<BS><Del><Del>',                    },
    \ { 'filetype': 'markdown', 'char': '<Space>', 'at': '^\s*-\s\[\%#\]',                 'input': '<Space><End>',                      },
    \ { 'filetype': 'markdown', 'char': 'x',       'at': '^\s*-\s\[\%#\]',                 'input': 'x<End>',                            },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\%#\]',                    'input': '<End><C-w><C-w><C-w><CR>',          },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\%#\]',                'input': '<End><C-w><C-w><C-w><C-w><CR>',     },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\%#',      'input': '<Home><Tab><End>',                  },
    \ { 'filetype': 'markdown', 'char': '<Tab>',   'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<Home><Tab><End>',                  },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<Home><Del><Del><End>',             },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^\s\+-\s\[\(\s\|x\)\]\s\w.*\%#', 'input': '<Home><Del><Del><End>',             },
    \ { 'filetype': 'markdown', 'char': '<S-Tab>', 'at': '^-\s\[\(\s\|x\)\]\s\w.*\%#',     'input': '',                                  },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><BS>',               },
    \ { 'filetype': 'markdown', 'char': '<C-h>',   'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><BS>',          },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><BS>',               },
    \ { 'filetype': 'markdown', 'char': '<BS>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><BS>',          },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^-\s\[\(\s\|x\)\]\s\%#',         'input': '<C-w><C-w><C-w><CR>',               },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s\+-\s\[\(\s\|x\)\]\s\%#',     'input': '<C-w><C-w><C-w><C-w><CR>',          },
    \ { 'filetype': 'markdown', 'char': '<CR>',    'at': '^\s*-\s\[\(\s\|x\)\]\s\w.*\%#',  'input': '<CR>-<Space>[]<Space><Left><Left>', },
    \ ]

    for s:rule in s:rules
      call lexima#add_rule(s:rule)
    endfor
  endfunction

  function! s:setup_lexima_cmdline() abort
    LeximaAlterCommand ee                 e!
    LeximaAlterCommand er                 update<Space><Bar><Space>e!
    LeximaAlterCommand re                 update<Space><Bar><Space>e!
    LeximaAlterCommand dp                 diffput
    LeximaAlterCommand js\%[on]           JSON
    LeximaAlterCommand dein               Dein
    LeximaAlterCommand dre\%[cache]       call<Space>dein#recache_runtimepath()
    LeximaAlterCommand dup\%[date]        call<Space>dein#update()
    LeximaAlterCommand c\%[oc]re\%[s]     CocRestart
    LeximaAlterCommand or\%[ganizeimport] OrganizeImport
    LeximaAlterCommand todo               CocCommand<Space>fzf-preview.TodoComments
    LeximaAlterCommand memo               CocCommand<Space>fzf-preview.MemoList
    LeximaAlterCommand git                Gina
    LeximaAlterCommand gs                 Gina<Space>status
    LeximaAlterCommand gci                Gina<Space>commit<Space>--no-verify
    LeximaAlterCommand gd                 Gina<Space>diff
    LeximaAlterCommand gdc                Gina<Space>diff<Space>--cached
    LeximaAlterCommand gco                Gina<Space>checkout
    LeximaAlterCommand log                Gina<Space>log
    LeximaAlterCommand blame              Gina<Space>blame
    LeximaAlterCommand bro\%[wse]         Gina<Space>browse<Space>--exact<Space>:
    LeximaAlterCommand grep               GrepperRg
    LeximaAlterCommand qfr\%[eplace]      Qfreplace
    LeximaAlterCommand sc\%[ratch]        Scratch
    LeximaAlterCommand ss                 SaveProjectLayout
    LeximaAlterCommand sl                 LoadProjectLayout
    LeximaAlterCommand vis\%[ta]          Vista
    LeximaAlterCommand cap\%[ture]        Capture
    LeximaAlterCommand r\%[un]            QuickRun
    LeximaAlterCommand test\%[summary]    TestSummary
    LeximaAlterCommand testo\%[pen]       TestOpen

    if dein#tap('vim-ambicmd')
      Keymap c <expr> <Space> <SID>expand_command("\<Space>")
      Keymap c <expr> <CR>    <SID>expand_command("\<CR>")
    endif
  endfunction

  function! s:lexima_alter_command(original, altanative) abort
    let input_space = '<C-w>' . a:altanative . '<Space>'
    let input_cr    = '<C-w>' . a:altanative . '<CR>'

    let rule = {
    \ 'mode': ':',
    \ 'at': '^\(''<,''>\)\?' . a:original . '\%#$',
    \ }

    call lexima#add_rule(extend(rule, { 'char': '<Space>', 'input': input_space }))
    call lexima#add_rule(extend(rule, { 'char': '<CR>',    'input': input_cr    }))
  endfunction

  command! -nargs=+ LeximaAlterCommand call <SID>lexima_alter_command(<f-args>)

  function! s:expand_command(key) abort
    let key2char   = { "\<Space>": ' ', "\<CR>": "\r" }
    let key2lexima = { "\<Space>": '<Space>', "\<CR>": '<CR>' }

    let lexima = lexima#expand(key2lexima[a:key], ':')
    if lexima !=# key2char[a:key]
      return lexima
    endif

    let ambicmd = ambicmd#expand(a:key)
    if ambicmd !=# key2char[a:key]
      redraw
      return ambicmd
    endif

    return a:key
  endfunction
endif
" }}}3

" lightspeed {{{3
if dein#tap('lightspeed.nvim')
  lua require('lightspeed').setup({})

  Keymap nox <silent> ss <Plug>Lightspeed_s
  Keymap nox <silent> S  <Plug>Lightspeed_S
endif
" }}}3

" numb {{{3
if dein#tap('numb.nvim')
  function! SetupNumb() abort
    lua require('numb').setup()
  endfunction
endif
" }}}3

" pounce {{{3
if dein#tap('pounce.nvim')
  Keymap nox <silent> ss <Cmd>Pounce<CR>
endif
" }}}3

" quick-scope {{{3
" let g:qs_buftype_blacklist = ['terminal', 'nofile']
" }}}3

" ripgrep {{{3
if dein#tap('vim-ripgrep')
  command! -nargs=* -complete=file Rg call ripgrep#search(<q-args>)
endif
" }}}3

" sad {{{3
if dein#tap('sad.nvim')
  lua require('sad').setup({ vsplit = false })
endif
" }}}3

" sandwich {{{3
if dein#tap('vim-sandwich') &&
   \ dein#tap('vim-textobj-functioncall')
  let g:sandwich_no_default_key_mappings             = 1
  let g:textobj_functioncall_no_default_key_mappings = 1

  Keymap nx <silent> sa  <Plug>(sandwich-add)
  Keymap nx <silent> sd  <Plug>(sandwich-delete)
  Keymap nx <silent> sdb <Plug>(sandwich-delete-auto)
  Keymap nx <silent> sr  <Plug>(sandwich-replace)
  Keymap nx <silent> srb <Plug>(sandwich-replace-auto)

  Keymap ox <silent> ib <Plug>(textobj-sandwich-auto-i)
  Keymap ox <silent> ab <Plug>(textobj-sandwich-auto-a)

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

  Keymap ox <silent> if <Plug>(textobj-functioncall-innerparen-i)
  Keymap ox <silent> af <Plug>(textobj-functioncall-i)

  let g:sandwich#magicchar#f#patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '(',
  \   'ket'    : ')',
  \   'footer' : '',
  \ },
  \ ]

  " Keymap n <silent> srf <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)ff

  let g:textobj_functioncall_generics_patterns = [
  \ {
  \   'header' : '\<\%(\h\k*\.\)*\h\k*',
  \   'bra'    : '<',
  \   'ket'    : '>',
  \   'footer' : '',
  \ },
  \ ]

  Keymap ox <silent> <Plug>(textobj-functioncall-generics-i) :<C-u>call textobj#functioncall#ip('o', g:textobj_functioncall_generics_patterns)<CR>
  Keymap ox <silent> <Plug>(textobj-functioncall-generics-a) :<C-u>call textobj#functioncall#i('o', g:textobj_functioncall_generics_patterns)<CR>

  Keymap ox <silent> ig <Plug>(textobj-functioncall-generics-i)
  Keymap ox <silent> ag <Plug>(textobj-functioncall-generics-a)

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

  " Keymap n <silent> srg <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)gg

  let g:textobj_functioncall_ts_string_variable_patterns = [
  \ {
  \   'header' : '\$',
  \   'bra'    : '{',
  \   'ket'    : '}',
  \   'footer' : '',
  \ },
  \ ]

  Keymap ox <silent> <Plug>(textobj-functioncall-ts-string-variable-i) :<C-u>call textobj#functioncall#i('o', g:textobj_functioncall_ts_string_variable_patterns)<CR>
  Keymap ox <silent> <Plug>(textobj-functioncall-ts-string-variable-a) :<C-u>call textobj#functioncall#a('o', g:textobj_functioncall_ts_string_variable_patterns)<CR>

  Keymap ox <silent> i$ <Plug>(textobj-functioncall-ts-string-variable-i)
  Keymap ox <silent> a$ <Plug>(textobj-functioncall-ts-string-variable-a)
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
  Keymap n <silent> f <Plug>(shot-f-f)
  Keymap n <silent> F <Plug>(shot-f-F)
endif
" }}}3

" smart-cursor {{{3
if dein#tap('smart-cursor.nvim')
  Keymap n <silent> o o<Esc>:lua require('smart-cursor').indent_cursor()<CR>i
  Keymap n <silent> O O<Esc>:lua require('smart-cursor').indent_cursor()<CR>i
endif
" }}}3

" smart-word {{{3
if dein#tap('vim-smartword')
  Keymap n w  <Plug>(smartword-w)
  Keymap n b  <Plug>(smartword-b)
  Keymap n e  <Plug>(smartword-e)
  Keymap n ge <Plug>(smartword-ge)
endif
" }}}3

" tcomment {{{3
if dein#tap('tcomment_vim')
  let g:tcomment_maps = 0

  Keymap nx <silent> <Leader>cc :TComment<CR>
endif
" }}}3

" textmanip {{{3
if dein#tap('vim-textmanip')
  Keymap x <C-j> <Plug>(textmanip-move-down)
  Keymap x <C-k> <Plug>(textmanip-move-up)
  Keymap x <C-h> <Plug>(textmanip-move-left)
  Keymap x <C-l> <Plug>(textmanip-move-right)
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
  Keymap n <C-a> <Plug>(trip-increment)
  Keymap n <C-x> <Plug>(trip-decrement)
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
    Keymap n <silent> <buffer> o <Plug>(vim-backslash-o)
    Keymap n <silent> <buffer> O <Plug>(vim-backslash-O)

    if dein#tap('pum.vim') && getcmdwintype() ==# ''
      Keymap i <silent> <expr> <buffer> <CR> pum#visible() ? '<C-y>' : vim_backslash#is_continuous_cr() ? '<Plug>(vim-backslash-smart-CR-i)' : lexima#expand('<CR>', 'i')
    elseif dein#tap('coc.nvim') && getcmdwintype() ==# ''
      Keymap i <silent> <expr> <buffer> <CR> coc#pum#visible() ? coc#pum#confirm() : vim_backslash#is_continuous_cr() ? '<Plug>(vim-backslash-smart-CR-i)' : lexima#expand('<CR>', 'i')
    else
      Keymap i <silent> <expr> <buffer> <CR> pumvisible() ? '<C-y>' : vim_backslash#is_continuous_cr() ? '<Plug>(vim-backslash-smart-CR-i)' : lexima#expand('<CR>', 'i')
    endif
  endfunction

  AutoCmd BufWinEnter *.vim,.vimrc call <SID>vim_backslash_settings()
endif
" }}}3

" yankround {{{3
if dein#tap('yankround.vim')
  let g:yankround_max_history   = 1000
  let g:yankround_use_region_hl = 1
  let g:yankround_dir           = '~/.cache/vim/yankround'

  Keymap nx p <Plug>(yankround-p)
  Keymap n  P <Plug>(yankround-P)

  Keymap n <silent> <expr> <C-p> yankround#is_active() ? '<Plug>(yankround-prev)' : '<Plug>(ctrl-p)'
  Keymap n <silent> <expr> <C-n> yankround#is_active() ? '<Plug>(yankround-next)' : '<Plug>(ctrl-n)'
endif
" }}}3

" yanky {{{3
if dein#tap('yanky.nvim')
  " Keymap nx p <Plug>(yankround-p)
  " Keymap n  P <Plug>(yankround-P)

  " Keymap n <silent> <expr> <C-p> yankround#is_active() ? '<Plug>(yankround-prev)' : '<Plug>(ctrl-p)'
  " Keymap n <silent> <expr> <C-n> yankround#is_active() ? '<Plug>(yankround-next)' : '<Plug>(ctrl-n)'

  Keymap nx <silent> y  <Plug>(YankyYank)

  Keymap nx <silent> p  <Plug>(YankyPutAfter)
  Keymap nx <silent> P  <Plug>(YankyPutBefore)
  Keymap nx <silent> gp <Plug>(YankyGPutAfter)
  Keymap nx <silent> gP <Plug>(YankyGPutBefore)

  Keymap n <silent> <expr> <C-p> luaeval('require("yanky").can_cycle()') ? '<Plug>(YankyCycleForward)'  : '<Plug>(ctrl-p)'
  Keymap n <silent> <expr> <C-n> luaeval('require("yanky").can_cycle()') ? '<Plug>(YankyCycleBackward)' : '<Plug>(ctrl-n)'

lua << EOF
local utils = require('yanky.utils')
local mapping = require('yanky.telescope.mapping')

require('yanky').setup({
   ring = {
    history_length = 1000,
    sync_with_numbered_registers = false,
  },
  highlight = {
    on_yank = false,
    timer = 300,
  },
  picker = {
    telescope = {
      mappings = {
        default = mapping.set_register('p'),
        i = {
          ["<C-p>"] = mapping.put('p'),
          ["<C-k>"] = mapping.put('P'),
          ["<C-x>"] = mapping.delete(),
          ["<C-r>"] = mapping.set_register(utils.get_default_register()),
        },
        n = {
          p = mapping.put('p'),
          P = mapping.put('P'),
          d = mapping.delete(),
          r = mapping.set_register(utils.get_default_register())
        },
      }
    }
  }
})
EOF
endif
" }}}3

" zero {{{3
if dein#tap('zero.nvim')
  lua require('zero').setup()
endif
" }}}3

" }}}2

" Appearance {{{2

" aerial {{{3
if dein#tap('aerial.nvim')
  lua require('aerial').setup({ backends = { 'treesitter', 'markdown' } })
endif
" }}}3

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

" bufferline {{{3
if dein#tap('bufferline.nvim')
  Keymap n <silent> <Plug>(ctrl-n) <Cmd>BufferLineCycleNext<CR>
  Keymap n <silent> <Plug>(ctrl-p) <Cmd>BufferLineCyclePrev<CR>
lua << EOF
local black      = '#32302f'
local red        = '#ea6962'
local green      = '#a9b665'
local yellow     = '#d8a657'
local blue       = '#7daea3'
local magenta    = '#d3869b'
local cyan       = '#89b482'
local white      = '#d4be98'
local grey       = '#807569'
local background = '#1D2021'
local empty      = '#1C1C1C'
local info       = '#FFFFAF'
local vert_split = '#504945'

local coc_diagnostic_results = {}

require('bufferline').setup({
  options = {
    mode = 'tabs',
    numbers = 'ordinal',
    buffer_close_icon = '×',
    show_close_icon = false,
    diagnostics = 'coc',
    show_buffer_default_icon = false,
    separator_style = { '|', ' ' },
    modified_icon = '[+]',
    diagnostics_indicator = function(_, _, _, context)
      local success, result = pcall(function()
        local buf = vim.api.nvim_get_current_buf()
        if context.buffer.id ~= buf then
          return coc_diagnostic_results[context.buffer.id] or ''
        end

        local coc_diagnostic_info = vim.api.nvim_buf_get_var(buf, 'coc_diagnostic_info')

        local error = ''
        if coc_diagnostic_info.error ~= 0 then
          error = ' ' .. coc_diagnostic_info.error
        end

        local warning = ''
        if coc_diagnostic_info.warning ~= 0 then
          warning = ' ' .. coc_diagnostic_info.warning
        end

        local result = ''
        if error ~= '' then
          result = ' ' .. error
        end
        if warning ~= '' then
          result = ' ' .. warning
        end

        coc_diagnostic_results[buf] = result
        return result
      end)

      if success then
        return result
      else
        return ''
      end
    end,
    offsets = {
      {
        filetype = 'fern',
        text = 'Fern',
        highlight = 'Directory',
        separator = true
      },
      {
        filetype = 'vista',
        text = 'Vista',
        highlight = 'Directory',
        separator = true
      },
    },
  },
  highlights = {
    fill = {
      fg = grey,
      bg = empty,
    },
    background = {
      fg = grey,
      bg = background,
    },
    tab = {
      fg = grey,
      bg = black,
    },
    buffer = {
      fg = grey,
      bg = black,
    },
    close_button = {
      fg = grey,
      bg = background,
    },
    numbers = {
      fg = grey,
      bg = background,
    },
    separator = {
      fg = background,
      bg = background,
    },
    duplicate = {
      fg = green,
      bg = background,
      bold = false,
      italic = false,
    },
    diagnostic = {
      fg = white,
      bg = black,
    },
    error = {
      fg = grey,
      bg = background,
    },
    warning = {
      fg = grey,
      bg = background,
    },
    info = {
      fg = grey,
      bg = background,
    },
    hint = {
      fg = grey,
      bg = background,
    },
    error_diagnostic = {
      fg = red,
      bg = background,
    },
    warning_diagnostic = {
      fg = yellow,
      bg = background,
    },
    info_diagnostic = {
      fg = info,
      bg = background,
    },
    hint_diagnostic = {
      fg = white,
      bg = background,
    },
    modified = {
      fg = yellow,
      bg = background,
    },
    tab_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    buffer_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    close_button_selected = {
      fg = white,
      bg = black,
      bold = false,
      italic = false,
    },
    numbers_selected = {
      fg = white,
      bg = black,
      bold = false,
      italic = false,
    },
    indicator_selected = {
      fg = blue,
      bg = black,
      bold = true,
      italic = false,
    },
    duplicate_selected = {
      fg = green,
      bg = black,
      bold = false,
      italic = false,
    },
    error_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    warning_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    info_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    hint_selected = {
      fg = white,
      bg = black,
      bold = true,
      italic = false,
    },
    error_diagnostic_selected = {
      fg = red,
      bg = black,
      bold = false,
      italic = false,
    },
    warning_diagnostic_selected = {
      fg = yellow,
      bg = black,
      bold = false,
      italic = false,
    },
    info_diagnostic_selected = {
      fg = info,
      bg = black,
      bold = false,
      italic = false,
    },
    hint_diagnostic_selected = {
      fg = white,
      bg = black,
      bold = false,
      italic = false,
    },
    modified_selected = {
      fg = yellow,
      bg = black,
      bold = false,
      italic = false,
    },
    buffer_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    close_button_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    numbers_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    indicator_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    duplicate_visible = {
      fg = green,
      bg = background,
      bold = false,
      italic = false,
    },
    error_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    warning_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    info_visible = {
      fg = info,
      bg = background,
      bold = false,
      italic = false,
    },
    hint_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    error_diagnostic_visible = {
      fg = red,
      bg = background,
      bold = false,
      italic = false,
    },
    warning_diagnostic_visible = {
      fg = yellow,
      bg = background,
      bold = false,
      italic = false,
    },
    info_diagnostic_visible = {
      fg = info,
      bg = background,
      bold = false,
      italic = false,
    },
    hint_diagnostic_visible = {
      fg = white,
      bg = background,
      bold = false,
      italic = false,
    },
    modified_visible = {
      fg = yellow,
      bg = background,
      bold = false,
      italic = false,
    },
    offset_separator = {
      fg = vert_split,
      bg = background,
    },
  },
})
EOF
endif
" }}}3

" bufresize {{{3
if dein#tap('bufresize.nvim')
  lua require('bufresize').setup()
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
    else
      let g:comfortable_motion_enable = 1

      Keymap n <silent> <C-d> :call comfortable_motion#flick(100)<CR>
      Keymap n <silent> <C-u> :call comfortable_motion#flick(-100)<CR>
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
  Keymap nx p <Plug>(highlightedput-p)
  Keymap nx P <Plug>(highlightedput-P)
endif
" }}}3

" highlightedundo {{{3
if dein#tap('vim-highlightedundo')
  let g:highlightedundo_enable         = v:true
  let g:highlightedundo#highlight_mode = 2

  Keymap n <silent> u     <Plug>(highlightedundo-undo)
  Keymap n <silent> <C-r> <Plug>(highlightedundo-redo)

  function! s:highlightedundo_toggle() abort
    if g:highlightedundo_enable
      let g:highlightedundo_enable = v:false
      call <SID>highlightedundo_disable()
    else
      let g:highlightedundo_enable = v:true
      call <SID>highlightedundo_enable()
    endif
  endfunction
  command! HighlightedundoToggle call <SID>highlightedundo_toggle()

  function! s:highlightedundo_enable() abort
    Keymap n <silent> u     <Plug>(highlightedundo-undo)
    Keymap n <silent> <C-r> <Plug>(highlightedundo-redo)
  endfunction

  function! s:highlightedundo_disable() abort
    nunmap u
    nunmap <C-r>
  endfunction
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

" hydra {{{3
if dein#tap('hydra.nvim')
lua << EOF
local hydra = require('hydra')

hydra({
  name = 'Change list',
  mode = 'n',
  body = 'g',
  heads = {
    { ';', 'g;', { desc = '<=' } },
    { ',', 'g,', { desc = '=>' } },
  },
})

local hint = [[
        Toggle

 _n_: %{number} Number
 _q_: %{quickfix} QuickFix
 _l_: %{location_list} LocationList
 _f_: %{eft} Eft
 _u_: %{highlighted_undo} HighlightedUndo
 _R_: %{review} Review
                         _<Esc>_
]]

hydra({
  name = 'Toggle',
  hint = hint,
  mode = 'n',
  body = 'T',
  config = {
    invoke_on_body = true,
    hint = {
      position = 'middle',
      border = 'rounded',
      funcs = {
        number = function()
          if vim.o.number and vim.o.relativenumber then
            return '[r]'
          elseif vim.o.number then
            return '[n]'
          else
            return '[ ]'
          end
        end,
        quickfix = function()
          for _, win in ipairs(vim.fn.getwininfo()) do
            if win.quickfix == 1 then
              return '[x]'
            end
          end

          return '[ ]'
        end,
        location_list = function()
          for _, win in ipairs(vim.fn.getwininfo()) do
            if win.loclist == 1 then
              return '[x]'
            end
          end

          return '[ ]'
        end,
        eft = function()
          if vim.g.eft_enable then
            return '[x]'
          else
            return '[ ]'
          end
        end,
        highlighted_undo = function()
          if vim.g.highlightedundo_enable then
            return '[x]'
          else
            return '[ ]'
          end
        end,
        review = function()
          if vim.g.review_status then
            return '[x]'
          else
            return '[ ]'
          end
        end,
      },
    },
  },
  heads = {
    { 'n',     function() vim.cmd([[ToggleNumber]]) end,          { silent = true, desc = 'Number'                      } },
    { 'q',     function() vim.cmd([[QuickfixToggle]]) end,        { silent = true, desc = 'QuickFix'                    } },
    { 'l',     function() vim.cmd([[LocationListToggle]]) end,    { silent = true, desc = 'LocationList'                } },
    { 'f',     function() vim.cmd([[EftToggle]]) end,             { silent = true, desc = 'Eft'                         } },
    { 'u',     function() vim.cmd([[HighlightedundoToggle]]) end, { silent = true, desc = 'HighlightedUndo'             } },
    { 'R',     function() vim.cmd([[ReviewToggle]]) end,          { silent = true, desc = 'Review',         exit = true } },
    { '<Esc>', nil,                                               {                                         exit = true } },
  },
})
EOF
endif
" }}}3

" incline {{{3
if dein#tap('incline.nvim')
lua << EOF
require('incline').setup({
  window = {
    width = 'fit',
    placement = { horizontal = 'right', vertical = 'top' },
    margin = {
      horizontal = { left = 1, right = 0 },
      vertical = { bottom = 0, top = 1 },
    },
    padding = { left = 1, right = 1 },
    padding_char = ' ',
    winhighlight = {
      Normal = 'TreesitterContext',
    },
  },
  hide = {
    -- focused_win = true,
  },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
    local icon, color = require('nvim-web-devicons').get_icon_color(filename)
    return {
      { icon, guifg = color },
      { ' ' },
      { filename },
    }
  end
})
EOF
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
  \     ['filepath', 'filename', 'modified_buffers', 'gps'],
  \     ['special_mode', 'anzu'],
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
  \   'gps':              'LightlineNvimGps',
  \ },
  \ 'tab_component_function': {
  \   'tabwinnum': 'LightlineTabWinNum',
  \ },
  \ 'component_visible_condition': {
  \   'anzu':       "%{anzu#search_status !=# ''}",
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
  \   'tabline':    0,
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
    call map(dirs, { _, v -> v[0] })

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

  function! LightlineNvimGps() abort
    if !dein#tap('nvim-gps')
      return ''
    endif

    if !LightlineIsVisible(140)
      return ''
    endif

    return luaeval("require'nvim-gps'.is_available()") ? luaeval("require'nvim-gps'.get_location()") : ''
  endfunction

  function! NearestMethodOrFunction() abort
    if !LightlineIsVisible(140)
      return ''
    endif
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction

  AutoCmd User CocDiagnosticChange call lightline#update()

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

" matchup {{{3
if dein#tap('vim-matchup')
  let g:matchup_matchparen_status_offscreen = 0
endif
" }}}3

" modes {{{3
if dein#tap('modes.nvim')
  lua require('modes').setup()
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

" notify {{{3
if dein#tap('nvim-notify')
lua << EOF
require('notify').setup({
  background_colour = (function()
    return '#26282F'
  end)
})
EOF
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

" regexplainer {{{3
if dein#tap('nvim-regexplainer')
lua << EOF
require('regexplainer').setup({
  auto = true,
  popup = {
    border = {
      padding = { 0, 0 },
      style = 'rounded',
    },
    win_options = {
      winhighlight = 'Normal:CocFloating,FloatBorder:CocFloating',
    },
  },
})
EOF
endif
" }}}3

" scrollbar.nvim {{{3
if dein#tap('scrollbar.nvim')
  AutoCmd BufEnter    * silent! lua require('scrollbar').show()
  AutoCmd BufLeave    * silent! lua require('scrollbar').clear()

  AutoCmd CursorMoved * silent! lua require('scrollbar').show()
  AutoCmd VimResized  * silent! lua require('scrollbar').show()

  AutoCmd FocusGained * silent! lua require('scrollbar').show()
  AutoCmd FocusLost   * silent! lua require('scrollbar').clear()
endif
" }}}3

" nvim-scrollbar {{{3
if dein#tap('nvim-scrollbar')
lua << EOF
require('scrollbar').setup({
  handle = {
    color = "#3a3a3a",
  },
  handlers = {
    search = true,
    diagnostic = true,
  },
  marks = {
    Search = {
      priority = 5,
      color = "#00AFAF",
    },
    Error = {
      priority = 1,
      color = "#EA6962",
    },
    Warn = {
      priority = 2,
      color = "#FFAF60",
    },
    Info = {
      priority = 3,
      color = "#FFFFAF",
    },
    Hint = {
      priority = 4,
      color = "#7DAEA3",
    },
  },
})

local severity_map = { Error = 1, Warning = 2, Information = 3, Hint = 4 }
local lsp_handler = require('scrollbar.handlers.diagnostic').lsp_handler

local uri_diagnostics = {}
local function handler(error, diagnosticList)
  if error ~= vim.NIL then
    return
  end
  if type(diagnosticList) ~= 'table' then
    diagnosticList = {}
  end

  for uri in pairs(uri_diagnostics) do
    uri_diagnostics[uri] = {}
  end

  for _, diagnostic in ipairs(diagnosticList) do
    local uri = diagnostic.location.uri
    local diagnostics = uri_diagnostics[uri] or {}
    table.insert(diagnostics, {
      range = diagnostic.location.range,
      severity = severity_map[diagnostic.severity],
    })
    uri_diagnostics[uri] = diagnostics
  end

  for uri, diagnostics in pairs(uri_diagnostics) do
    lsp_handler(nil, { uri = uri, diagnostics = diagnostics })
    if vim.tbl_count(diagnostics) == 0 then
      uri_diagnostics[uri] = nil
    end
  end
end

vim.api.nvim_create_autocmd('User', {
  callback = function()
    vim.fn.CocActionAsync('diagnosticList', handler)
  end,
  pattern = 'CocDiagnosticChange',
})
EOF
endif
" }}}3

" smartnumber {{{3
if dein#tap('smartnumber.vim')
  let g:snumber_enable_startup = 1
  let g:snumber_enable_relative = 1
  Keymap n <Leader>n <Cmd>SNToggle<CR>

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
  lua require("todo-comments").setup { signs = false }
endif
" }}}3

" ufo {{{3
if dein#tap('nvim-ufo')
  function! UfoWidth() abort
    let width = 0
    for winnr in range(1, winnr('$'))
      let win_width = nvim_win_get_width(win_getid(winnr))
      let width = win_width > width ? win_width : width
    endfor
    return width
  endfunction

lua << EOF
local enable_file_type = { 'typescript', 'typescriptreact', 'vim', 'markdown' }

require('ufo').setup({
  open_fold_hl_timeout = 0,
  provider_selector = function(bufnr, filetype, buftype)
    if vim.tbl_contains(enable_file_type, filetype) then
      return { 'treesitter', 'indent' }
    end

    return ''
  end,
  preview = {
    win_config = {
      winhighlight = 'Normal:Normal,FloatBorder:Normal',
      winblend = 0,
    },
    mappings = {
      scrollU = '<C-u>',
      scrollD = '<C-d>',
    },
  },
  enable_fold_and_virt_text = true,
  fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
    local new_virt_text = {}
    local suffix = (' ↲ %d '):format(end_lnum - lnum)
    local suf_width = vim.fn.strdisplaywidth(suffix)
    local target_width = width - suf_width
    local cur_width = 0

    for _, chunk in ipairs(virt_text) do
      local chunk_text = chunk[1]
      local chunk_width = vim.fn.strdisplaywidth(chunk_text)
      if target_width > cur_width + chunk_width then
        table.insert(new_virt_text, chunk)
      else
        chunk_text = truncate(chunk_text, target_width - cur_width)
        local hl_group = chunk[2]
        table.insert(new_virt_text, { chunk_text, hl_group })
        chunk_width = vim.fn.strdisplaywidth(chunk_text)
        if cur_width + chunk_width < target_width then
          suffix = suffix .. ('.'):rep(target_width - cur_width - chunk_width)
        end
        break
      end
      cur_width = cur_width + chunk_width
    end

    table.insert(new_virt_text, { suffix, 'UfoFoldVirtText' })
    table.insert(new_virt_text, { ('.'):rep(vim.fn.UfoWidth()), 'Comment' })
    return new_virt_text
  end,
})
EOF
endif
" }}}3

" vista {{{3
if dein#tap('vista.vim')
  if dein#tap('coc.nvim')
    let g:vista_default_executive = 'coc'
  endif

  let g:vista_no_mappings            = 1
  let g:vista_sidebar_width          = 50
  let g:vista_echo_cursor_strategy   = 'both'
  let g:vista_update_on_text_changed = 1
  let g:vista_blink                  = [1, 100]

  Keymap n <silent> <Leader>v <Cmd>Vista<CR>

  function! s:vista_settings() abort
     Keymap n <silent> <buffer> <nowait> q    <Cmd>quit<CR>
     Keymap n <silent> <buffer>          <CR> <Cmd>call vista#cursor#FoldOrJump()<CR>
     Keymap n <silent> <buffer>          p    <Cmd>call vista#cursor#TogglePreview()<CR>
  endfunction

  AutoCmd FileType vista,vista_markdown call <SID>vista_settings()
  " AutoCmd VimEnter * call vista#RunForNearestMethodOrFunction()
endif
" }}}3

" }}}2

" tmux {{{2

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
  Keymap n <silent> <Leader>d <Cmd>Bdelete!<CR>
endif
" }}}3

" capture {{{3
if dein#tap('capture.vim')
  AutoCmd FileType capture Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
endif
" }}}3

" cmdbuf {{{3
if dein#tap('cmdbuf.nvim')
  Keymap n <silent> q:    <Cmd>lua require('cmdbuf').split_open(vim.o.cmdwinheight)<CR><Cmd>startinsert<CR>
  Keymap c <silent> <C-c> <Cmd>call <SID>cmdbuf_cedit_c()<CR>

  function! s:cmdbuf_cedit_c() abort
    for winnr in range(1, winnr('$'))
      let s:cmdbuf_winid = win_getid(winnr)
      let wininfo = getwininfo(s:cmdbuf_winid)
      let bufinfo = getbufinfo(wininfo[0].bufnr)

      if bufinfo[0].name ==# 'cmdbuf://vim/cmd-buffer'
        let s:cmdbuf_cmd = getcmdline()
        let s:cmdbuf_cmdpos = getcmdpos()
        let s:cmdbuf_pos = getcurpos(s:cmdbuf_winid)
        call feedkeys("\<Esc>", 'nit')
        autocmd CmdlineLeave * ++once call <SID>cmdbuf_reuse(s:cmdbuf_cmd, s:cmdbuf_winid, s:cmdbuf_pos[1], s:cmdbuf_cmdpos)
        return
      endif
    endfor

    lua require('cmdbuf').split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
    call feedkeys("\<C-c>\<Cmd>startinsert\<CR>", 'nit')
  endfunction

  function! s:cmdbuf_cedit_n() abort
    let cmd = getline('.')
    let pos = getcurpos('.')
    call feedkeys(':' . cmd . "\<C-r>=setcmdpos( " . pos[2] . " )[-1]\<CR>", 'nit')
  endfunction

  function! s:cmdbuf_cedit_i() abort
    let cmd = getline('.')
    let pos = getcurpos('.')
    call feedkeys("\<Esc>:" . cmd . "\<C-r>=setcmdpos( " . pos[2] . " )[-1]\<CR>", 'nit')
  endfunction

  function! s:cmdbuf_reuse(cmd, winid, lnum, col) abort
    call win_gotoid(a:winid)
    call setline(a:lnum, a:cmd)
    call setpos('.', [0, a:lnum, a:col])
    startinsert
  endfunction

  AutoCmd User CmdbufNew set bufhidden=wipe nonumber norelativenumber
  AutoCmd User CmdbufNew Keymap n <silent> <nowait> <buffer> q     <Cmd>quit<CR>
  AutoCmd User CmdbufNew Keymap n <silent>          <buffer> dd    <Cmd>lua require('cmdbuf').delete()<CR>
  AutoCmd User CmdbufNew Keymap n <silent>          <buffer> <C-c> <Cmd>call <SID>cmdbuf_cedit_n()<CR>
  AutoCmd User CmdbufNew Keymap i <silent>          <buffer> <C-c> <Cmd>call <SID>cmdbuf_cedit_i()<CR>
endif
" }}}3

" dial {{{3
if dein#tap('dial.nvim')
  nmap <C-a>  <Plug>(dial-increment)
  nmap <C-x>  <Plug>(dial-decrement)
  xmap <C-a>  <Plug>(dial-increment)
  xmap <C-x>  <Plug>(dial-decrement)
  xmap g<C-a> g<Plug>(dial-increment)
  xmap g<C-x> g<Plug>(dial-decrement)

lua << EOF
local config = require('dial.config')
local augend = require('dial.augend')

config.augends:register_group({
  default= {
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.constant.alias.bool,
    augend.constant.new({
      elements = { '&&', '||' },
      word = false,
      cyclic = true,
    }),
    augend.semver.alias.semver,
  },
})

-- dial.augends['custom#boolean'] = dial.common.enum_cyclic({
--   name = 'boolean',
--   strlist = { 'true', 'false' },
-- })
-- dial.augends['custom#and_or'] = dial.common.enum_cyclic({
--   name = 'and_or',
--   strlist = { '&&', '||' },
--   ptn_format = '\\C\\M\\(%s\\)',
-- })
-- table.insert(dial.config.searchlist.normal, 'custom#boolean')
-- table.insert(dial.config.searchlist.normal, 'custom#and_or')
EOF
endif
" }}}3

" floaterm {{{3
if dein#tap('vim-floaterm')
  let g:floaterm_width       = 0.8
  let g:floaterm_height      = 0.8
  let g:floaterm_winblend    = 15
  let g:floaterm_position    = 'center'

  Keymap n <silent> <C-s> <Cmd>FloatermToggle<CR>

  AutoCmd FileType floaterm call <SID>floaterm_settings()
  AutoCmd FileType gitrebase call <SID>set_git_rebase_settings()

  function! s:floaterm_settings() abort
    Keymap t <silent> <buffer> <C-s> <C-\><C-n>:FloatermToggle<CR>
    let b:highlight_cursor = 0
  endfunction

  function! s:set_git_rebase_settings() abort
    set winhighlight=Normal:GitRebase
    set winblend=30

    Keymap n <silent> <buffer> <Leader>d :bdelete!<Space><Bar><Space>close<CR>
  endfunction
endif
" }}}3

" memolist {{{3
if dein#tap('memolist.vim')
  let g:memolist_path = '~/.config/memolist'
endif
" }}}3

" neotest {{{3
if dein#tap('neotest')
lua << EOF
require('neotest').setup({
  adapters = {
    require('neotest-jest'),
  },
})
EOF
  Keymap n <silent> <Leader>t <Cmd>TestSummary<CR>

  command! TestSummary lua require('neotest').summary.toggle()
  command! TestOpen    lua require('neotest').output.open({ enter = true })

  AutoCmd FileType neotest-summary Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
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

" toggleterm {{{3
if dein#tap('toggleterm.nvim')
  lua require('toggleterm').setup{}

  Keymap n <silent> <C-s><C-s> :<C-u>ToggleTerm direction=float<CR>
  Keymap n <silent> <C-s>s     :<C-u>ToggleTerm direction=horizontal size=<C-r>=float2nr(&lines * 0.4)<CR><CR>
  Keymap n <silent> <C-s>v     :<C-u>ToggleTerm direction=vertical size=<C-r>=float2nr(&columns * 0.3)<CR><CR>
  Keymap n <silent> <C-s><C-v> :<C-u>ToggleTerm direction=vertical size=<C-r>=float2nr(&columns * 0.3)<CR><CR>

  function! s:toggleterm_settings() abort
    Keymap t <silent> <nowait> <buffer> <C-s> <C-\><C-n>:close<CR>
  endfunction

  AutoCmd FileType toggleterm call <SID>toggleterm_settings()
endif
" }}}3

" undotree {{{3
if dein#tap('undotree')
  Keymap n <silent> <Leader>u <Cmd>UndotreeToggle<CR>
endif
" }}}3

" which-key {{{3
if dein#tap('vim-which-key')
  Keymap n <silent> <Leader><CR>      <Cmd>WhichKey '<Leader>'<CR>
  Keymap n <silent> <Plug>(lsp)<CR>   <Cmd>WhichKey '<Plug>(lsp)'<CR>
  Keymap n <silent> <Plug>(fzf-p)<CR> <Cmd>WhichKey '<Plug>(fzf-p)'<CR>
  Keymap n <silent> <Plug>(t)<CR>     <Cmd>WhichKey '<Plug>(t)'<CR>
  Keymap n <silent> s<CR>             <Cmd>WhichKey 's'<CR>
  Keymap n <silent> <bookmark><CR>    <Cmd>WhichKey '<bookmark>'<CR>
endif
" }}}3

" wilder {{{3
if dein#tap('wilder.nvim') && !g:enable_cmp
  function! SetUpWilder() abort
    call wilder#set_option('pipeline', [
    \ wilder#branch(
    \   wilder#python_file_finder_pipeline({
    \     'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H', '--strip-cwd-prefix'] : ['fd', '-tf', '--strip-cwd-prefix']},
    \     'dir_command': ['fd', '-td'],
    \   }),
    \   wilder#cmdline_pipeline({
    \     'fuzzy': 2,
    \     'fuzzy_filter': wilder#vim_fuzzy_filter(),
    \   }),
    \   [
    \     wilder#check({_, x -> empty(x)}),
    \     wilder#history(),
    \   ],
    \   wilder#python_search_pipeline({
    \     'pattern': wilder#python_fuzzy_pattern({
    \       'start_at_boundary': 0,
    \     }),
    \   }),
    \ ),
    \ ])

    let wilder_cmd_line_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'winblend': 20,
    \ 'highlighter': wilder#basic_highlighter(),
    \ 'highlights': {
    \   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#e27878', 'bold': v:true, 'underline': v:true}]),
    \   'selected_accent': wilder#make_hl('WilderSelectedAccent', 'PmenuSel', [{}, {}, {'foreground': '#e27878', 'bold': v:true, 'underline': v:true}]),
    \ },
    \ 'left': [wilder#popupmenu_devicons({'min_width': 2}), wilder#popupmenu_buffer_flags({'flags': ' '})],
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
  Keymap n <silent> <Leader><C-w> :call WindowSwap#EasyWindowSwap()<CR>
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

  AutoCmd FileType quickrun Keymap n <silent> <nowait> <buffer> q <Cmd>quit<CR>
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

  if dein#tap('nvim-scrollbar')
    lua require('scrollbar.handlers.search').handler.hide()
  endif

  if dein#tap('vim-anzu')
    AnzuClearSearchStatus
  endif

  if dein#tap('coc.nvim')
    call coc#float#close_all()
  endif

  if dein#tap('lspsaga.nvim')
    lua require("lspsaga.window").nvim_win_try_close()
  endif

  if dein#tap('nvim-ufo')
    lua require('ufo.lib.event'):emit('onBufRemap', 1, 'close')
  endif

  if dein#tap('hlargs.nvim')
    lua require('hlargs').enable()
  endif
endfunction

command! EscEsc call <SID>esc_esc()
Keymap n <silent> <Esc><Esc> <Cmd>nohlsearch<CR><Cmd>EscEsc<CR>
" }}}2

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
AutoCmd ColorScheme gruvbox-material highlight Normal       ctermfg=233  ctermbg=NONE guifg=#d4be98 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight NormalNC     ctermfg=233  ctermbg=NONE guifg=#d4be98 guibg=#191B1D
AutoCmd ColorScheme gruvbox-material highlight NormalFloat  ctermfg=NONE ctermbg=238  guifg=NONE    guibg=#232526
AutoCmd ColorScheme gruvbox-material highlight FloatBorder  ctermfg=NONE ctermbg=238  guifg=NONE    guibg=#232526
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
AutoCmd ColorScheme gruvbox-material highlight YankyPut                ctermfg=209  ctermbg=237                       guifg=#FF875F guibg=#3A3A3A

AutoCmd ColorScheme gruvbox-material highlight CocErrorSign            ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocWarningSign          ctermfg=214  ctermbg=NONE                      guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocInfoSign             ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocErrorVirtualText     ctermfg=9    ctermbg=NONE                      guifg=#E98989 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocWarningVirtualText   ctermfg=214  ctermbg=NONE                      guifg=#FFAF60 guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocInfoVirtualText      ctermfg=229  ctermbg=NONE                      guifg=#FFFFAF guibg=NONE
AutoCmd ColorScheme gruvbox-material highlight CocFloating             ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2C3538
AutoCmd ColorScheme gruvbox-material highlight CocHoverFloating        ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocSuggestFloating      ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocSignatureFloating    ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocDiagnosticFloating   ctermfg=NONE ctermbg=238                       guifg=NONE    guibg=#2A2D2F
AutoCmd ColorScheme gruvbox-material highlight CocMenuSel              ctermfg=235  ctermbg=142                       guifg=NONE    guibg=#3C6073

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
AutoCmd ColorScheme gruvbox-material highlight HlSearchLens     ctermfg=68 ctermbg=232 guifg=#889eb5 guibg=#283642
AutoCmd ColorScheme gruvbox-material highlight HlSearchLensNear ctermfg=68 ctermbg=232 guifg=NONE    guibg=#213F72
AutoCmd ColorScheme gruvbox-material highlight HlSearchFloat    ctermfg=68 ctermbg=232 guifg=NONE    guibg=#213F72

AutoCmd ColorScheme gruvbox-material highlight ScrollView ctermbg=159 guibg=#D0D0D0

AutoCmd ColorScheme gruvbox-material highlight VistaFloat ctermbg=237 guibg=#3a3a3a

AutoCmd ColorScheme gruvbox-material highlight SearchxMarkerCurrent ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#E27878 guibg=NONE    gui=underline,bold
AutoCmd ColorScheme gruvbox-material highlight SearchxMarker        ctermfg=209  ctermbg=NONE cterm=underline,bold guifg=#FFAF60 guibg=NONE    gui=NONE

AutoCmd ColorScheme gruvbox-material highlight link SearchxIncSearch IncSearch

" TreeSitter
AutoCmd ColorScheme gruvbox-material highlight link TSPunctBracket Normal
AutoCmd ColorScheme gruvbox-material highlight link BiscuitColor   Comment
AutoCmd ColorScheme gruvbox-material highlight TSNodeKey       ctermfg=209 ctermbg=NONE cterm=underline,bold guifg=#FFAF60 guibg=NONE gui=NONE
AutoCmd ColorScheme gruvbox-material highlight UfoFoldVirtText ctermfg=109 ctermbg=NONE cterm=underline,bold guifg=#74A097 guibg=NONE gui=NONE
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
" }}}3

" }}}2

" }}}1

" vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker foldlevel=0:
