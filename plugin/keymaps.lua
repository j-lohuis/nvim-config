vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('v', '<leader>y', '\"+y')
vim.keymap.set('n', '<leader>Y', '\"+Y')
vim.keymap.set('n', '<M-y>', ':%y+<CR>')

vim.keymap.set('i', '<C-c>', '<Nop>')

vim.keymap.set('n', '<leader>m', vim.diagnostic.open_float, { desc = 'Show diagnostic error [M]essages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
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
vim.keymap.set('', '<C-Left>', ':vertical resize +3<CR>')
vim.keymap.set('', '<C-Right>', ':vertical resize -3<CR>')
vim.keymap.set('', '<C-Up>', ':resize +3<CR>')
vim.keymap.set('', '<C-Down>', ':resize -3<CR>')
