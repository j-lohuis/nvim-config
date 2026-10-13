vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', function()
  vim.cmd.nohlsearch()
  vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace('nvim.multicursor'), 0, -1)
end, { desc = 'Clear search highlight and multicursors' })

vim.keymap.set('n', 'Q', function()
  local reg = vim.fn.reg_recorded()
  return reg == '' and '' or ('@' .. reg)
end, { expr = true, desc = 'Replay last recorded macro' })
vim.keymap.set('n', '<leader>q', 'Q', { desc = 'Toggle multicursor at cursor' })
vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>w', ":w<CR>")
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.cmd.packadd('nvim.undotree')
vim.keymap.set('n', '<leader>u', vim.cmd.Undotree, { desc = 'Toggle [U]ndotree' })

vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('x', '<leader>y', '\"+y')
vim.keymap.set('n', '<leader>Y', '\"+Y')
vim.keymap.set('n', '<M-y>', ':%y+<CR>')

vim.keymap.set('i', '<C-c>', '<Nop>')

vim.keymap.set('n', '<leader>m', vim.diagnostic.open_float, { desc = 'Show diagnostic error [M]essages' })
vim.keymap.set('n', '<M-Right>', ':cn<CR>', { desc = 'Next Quickfix' })
vim.keymap.set('n', '<M-Left>', ':cp<CR>', { desc = 'Previous Quickfix' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', 'j', function()
  return (vim.v.count > 4) and "m'" .. vim.v.count .. 'j' or 'gj'
end, { expr = true, noremap = true })

vim.keymap.set('n', 'k', function()
  return (vim.v.count > 4) and "m'" .. vim.v.count .. 'k' or 'gk'
end, { expr = true, noremap = true })


vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('', '<C-Left>', '<Cmd>vertical resize +3<CR>')
vim.keymap.set('', '<C-Right>', '<Cmd>vertical resize -3<CR>')
vim.keymap.set('', '<C-Up>', '<Cmd>resize +3<CR>')
vim.keymap.set('', '<C-Down>', '<Cmd>resize -3<CR>')
