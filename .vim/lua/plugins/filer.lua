local color = require('rc.color')

return {
  {
    'lambdalisue/fern.vim',
    dependencies = {
      { 'LumaKernel/fern-mapping-reload-all.vim' },
      { 'lambdalisue/fern-git-status.vim' },
      { 'lambdalisue/fern-hijack.vim' },
      { 'yuki-yano/fern-preview.vim' },
      { 'yuki-yano/fern-renderer-web-devicons.nvim' },
      { 'lambdalisue/glyph-palette.vim' },
    },
    cmd = { 'Fern' },
    init = function()
      vim.g['fern#disable_default_mappings'] = true
      vim.g['fern#drawer_width'] = 40
      vim.g['fern#renderer'] = 'nvim-web-devicons'
      vim.g['fern#hide_cursor'] = true
      vim.g['fern#window_selector_use_popup'] = true
      vim.g['fern_preview_window_highlight'] = 'Normal:Normal,FloatBorder:Normal'
      vim.g['fern_preview_window_calculator'] = {
        width = function()
          return vim.fn.min({ vim.fn.float2nr(vim.o.columns * 0.8), 200 })
        end,
      }

      vim.keymap.set({ 'n' }, '<Leader>e', '<Cmd>Fern . -drawer<CR><C-w>=')
      vim.keymap.set({ 'n' }, '<Leader>E', '<Cmd>Fern . -drawer -reveal=%<CR><C-w>=')
      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        pattern = { '*' },
        callback = function()
          vim.api.nvim_set_hl(0, 'FernGitStatusWorktree', { fg = color.base().red, bg = 'NONE' })
          vim.api.nvim_set_hl(0, 'FernGitStatusIndex', { fg = color.base().green, bg = 'NONE' })
          vim.api.nvim_set_hl(0, 'FernGitStatusUnmerged', { fg = color.base().red, bg = 'NONE' })
          vim.api.nvim_set_hl(0, 'FernGitStatusUntracked', { fg = color.base().red, bg = 'NONE' })
          vim.api.nvim_set_hl(0, 'FernGitStatusIgnored', { link = 'Comment' })
        end,
      })
    end,
    config = function()
      local vimx = require('artemis')

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'fern' },
        callback = function()
          vim.cmd([[
            nnoremap <silent>        <buffer> <Plug>(fern-page-down-wrapper) <C-d>
            nnoremap <silent>        <buffer> <Plug>(fern-page-up-wrapper)   <C-u>
            nnoremap <silent> <expr> <buffer> <Plug>(fern-page-down-or-scroll-down-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-page-down-or-scroll-up-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")

            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-expand-or-collapse)               fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-open-system-or-open-file)         fern#smart#leaf("\<Plug>(fern-action-open:select)", "\<Plug>(fern-action-open:system)")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-quit-or-close-preview)            fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":q\<CR>")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-wipe-or-close-preview)            fern_preview#smart_preview("\<Plug>(fern-action-preview:close)\<Plug>(fern-action-preview:auto:disable)", ":bwipe!\<CR>")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-page-down-or-scroll-down-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:down:half)", "\<Plug>(fern-page-down-wrapper)")
            nnoremap <silent> <expr> <buffer> <Plug>(fern-action-page-down-or-scroll-up-preview)   fern_preview#smart_preview("\<Plug>(fern-action-preview:scroll:up:half)", "\<Plug>(fern-page-up-wrapper)")

            nnoremap <silent>        <buffer> <nowait> a       <Plug>(fern-action-choice)
            nnoremap <silent>        <buffer> <nowait> <CR>    <Plug>(fern-action-open-system-or-open-file)
            nnoremap <silent>        <buffer> <nowait> t       <Plug>(fern-action-expand-or-collapse)
            nnoremap <silent>        <buffer> <nowait> l       <Plug>(fern-action-open-or-enter)
            nnoremap <silent>        <buffer> <nowait> h       <Plug>(fern-action-leave)
            nnoremap <silent>        <buffer> <nowait> x       <Plug>(fern-action-mark:toggle)j
            xnoremap <silent>        <buffer> <nowait> x       <Plug>(fern-action-mark:toggle)j
            nnoremap <silent>        <buffer> <nowait> <Space> <Plug>(fern-action-mark:toggle)j
            xnoremap <silent>        <buffer> <nowait> <Space> <Plug>(fern-action-mark:toggle)j
            nnoremap <silent> <expr> <buffer> <nowait> N       v:hlsearch ? 'N' : '<Plug>(fern-action-new-file)'
            nnoremap <silent>        <buffer> <nowait> K       <Plug>(fern-action-new-dir)
            nnoremap <silent>        <buffer> <nowait> d       <Plug>(fern-action-trash)
            nnoremap <silent>        <buffer> <nowait> r       <Plug>(fern-action-rename)
            nnoremap <silent>        <buffer> <nowait> c       <Plug>(fern-action-copy)
            nnoremap <silent>        <buffer> <nowait> C       <Plug>(fern-action-clipboard-copy)
            nnoremap <silent>        <buffer> <nowait> m       <Plug>(fern-action-move)
            nnoremap <silent>        <buffer> <nowait> M       <Plug>(fern-action-clipboard-move)
            nnoremap <silent>        <buffer> <nowait> P       <Plug>(fern-action-clipboard-paste)
            nnoremap <silent>        <buffer> <nowait> !       <Plug>(fern-action-hidden:toggle)
            nnoremap <silent>        <buffer> <nowait> y       <Plug>(fern-action-yank)
            nnoremap <silent>        <buffer> <nowait> <C-g>   <Plug>(fern-action-debug)
            nnoremap <silent>        <buffer> <nowait> ?       <Plug>(fern-action-help)
            nnoremap <silent>        <buffer> <nowait> <C-c>   <Plug>(fern-action-cancel)
            nnoremap <silent>        <buffer> <nowait> .       <Plug>(fern-repeat)
            nnoremap <silent>        <buffer> <nowait> q       <Plug>(fern-action-quit-or-close-preview)
            nnoremap <silent>        <buffer> <nowait> Q       <Plug>(fern-action-wipe-or-close-preview)
            nnoremap <silent>        <buffer> <nowait> p       <Plug>(fern-action-preview:toggle)
            nnoremap <silent>        <buffer> <nowait> <C-p>   <Plug>(fern-action-preview:auto:toggle)
            nnoremap <silent>        <buffer> <nowait> <C-d>   <Plug>(fern-action-page-down-or-scroll-down-preview)
            nnoremap <silent>        <buffer> <nowait> <C-u>   <Plug>(fern-action-page-down-or-scroll-up-preview)
            nnoremap <silent>        <buffer> <nowait> R       <Plug>(fern-action-reload:all)
          ]])

          vim.opt_local.number = false
          vim.opt_local.relativenumber = false

          vimx.fn.glyph_palette.apply()
        end,
      })
    end,
  },
  {
    'lambdalisue/fern-git-status.vim',
    config = function()
      local vimx = require('artemis')
      vimx.fn.fern_git_status.init()
    end,
  },
  {
    'stevearc/oil.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    cmd = { 'Oil' },
    config = function()
      require('oil').setup()
    end,
  },
}
