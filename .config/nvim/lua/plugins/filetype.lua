return {
  {
    'windwp/nvim-ts-autotag',
    enabled = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    ft = { 'typescriptreact' },
    config = function()
      require('nvim-ts-autotag').setup({ enable_close = false })
    end,
  },
  {
    'lambdalisue/vim-deno-cache',
    config = function()
      require('denops-lazy').load('vim-deno-cache')
    end,
  },
  -- NOTE: Too slow to build
  {
    'barrett-ruth/import-cost.nvim',
    enabled = false,
    build = 'sh install.sh yarn',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('import-cost').setup()
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('lazydev').setup({
        library = {
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          'lazy.nvim',
          'plenary.nvim',
        },
      })
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = function()
      require('markview').setup({
        preview = {
          icon_provider = 'devicons',
        },
        ---@diagnostic disable-next-line: missing-fields
        markdown = {
          ---@diagnostic disable-next-line: missing-fields
          list_items = {
            shift_width = 2,
          },
        },
      })

      local group = vim.api.nvim_create_augroup('rc_markview_conceal_fix', { clear = true })

      -- `checktime` based reload can re-trigger FileType and overwrite conceallevel to 0.
      -- Re-apply markview's expected conceallevel only when markview preview is actually enabled.
      local function restore_markview_conceallevel(bufnr)
        if type(bufnr) ~= 'number' or not vim.api.nvim_buf_is_valid(bufnr) then
          return
        elseif vim.bo[bufnr].filetype ~= 'markdown' then
          return
        end

        local ok, state = pcall(require, 'markview.state')
        if not ok or not state.enabled() or not state.buf_attached(bufnr) then
          return
        end

        local buf_state = state.get_buffer_state(bufnr, false)
        if not buf_state or not buf_state.enable then
          return
        end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end

          for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            if vim.api.nvim_win_is_valid(win) then
              vim.wo[win].conceallevel = 3
            end
          end
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'markdown',
        callback = function(args)
          restore_markview_conceallevel(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd('FileChangedShellPost', {
        group = group,
        pattern = '*',
        callback = function(args)
          restore_markview_conceallevel(args.buf)
        end,
      })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = false,
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
      html = {
        render_modes = { 'n', 'i' },
        comment = {
          conceal = false,
        },
      },
    },
  },
  { 'pantharshit00/vim-prisma', ft = { 'prisma' } },
  {
    'kchmck/vim-coffee-script',
    enabled = false,
    ft = { 'coffee' },
  },
}
