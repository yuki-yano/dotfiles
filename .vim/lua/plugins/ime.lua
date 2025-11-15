return {
  {
    'vim-skk/skkeleton',
    enabled = false,
    dependencies = {
      { 'vim-denops/denops.vim' },
      { 'yuki-yano/denops-lazy.nvim' },
      { 'skk-dev/dict', lazy = true },
      { 'delphinus/skkeleton_indicator.nvim' },
    },
    event = { 'InsertEnter' },
    init = function()
      vim.keymap.set({ 'i' }, '<C-j>', '<Plug>(skkeleton-toggle)')
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'skkeleton-initialize-pre' },
        callback = function()
          vim.fn['skkeleton#config']({
            eggLikeNewline = true,
            globalDictionaries = {
              vim.fn.stdpath('cache') .. '/lazy/dict/SKK-JISYO.L',
            },
          })
        end,
      })
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'DenopsPluginPost:skkeleton' },
        callback = function()
          vim.fn['skkeleton#initialize']()
        end,
      })
    end,
    config = function()
      require('denops-lazy').load('skkeleton', { wait_load = false })
      require('skkeleton_indicator').setup({
        border = 'rounded',
        eijiHlName = 'LineNr',
        hiraHlName = 'String',
        kataHlName = 'Todo',
        hankataHlName = 'Special',
        zenkakuHlName = 'LineNr',
      })
    end,
  },
}
