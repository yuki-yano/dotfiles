-- Keymap
-- Leader is set before lazy
vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>')
vim.keymap.set({ 'n' }, '<Plug>(tab)', '<Nop>')
vim.keymap.set({ 'n' }, 't', '<Plug>(tab)')
vim.keymap.set({ 'n', 'x' }, '<Plug>(lsp)', '<Nop>')
vim.keymap.set({ 'n', 'x' }, 'm', '<Plug>(lsp)')
vim.keymap.set({ 'n', 'x' }, '<Plug>(ff)', '<Nop>')
vim.keymap.set({ 'n', 'x' }, ';', '<Plug>(ff)')
vim.keymap.set({ 'n', 'x' }, ';;', ';')
vim.keymap.set({ 'n' }, '<Plug>(bookmark)', '<Nop>')
vim.keymap.set({ 'n' }, 'M', '<Plug>(bookmark)')
vim.keymap.set({ 'n', 'o', 'x' }, 's', '<Nop>')
vim.keymap.set({ 'n' }, '<Plug>(ctrl-n)', '<Nop>')
vim.keymap.set({ 'n' }, '<C-n>', '<Plug>(ctrl-n)')
vim.keymap.set({ 'n' }, '<Plug>(ctrl-p)', '<Nop>')
vim.keymap.set({ 'n' }, '<C-p>', '<Plug>(ctrl-p)')
