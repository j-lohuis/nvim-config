vim.pack.add({ 'https://github.com/echasnovski/mini.nvim' })
require('mini.ai').setup()
require('mini.align').setup()
require('mini.move').setup()
require('mini.operators').setup()
require('mini.surround').setup({
  mappings = {
    add = '<leader>fa',
    delete = '<leader>fd',
    find = '<leader>ff',
    find_left = '<leader>fF',
    highlight = '<leader>fh',
    replace = '<leader>fr',
    update_n_lines = '<leader>fn',
  }
})
require('mini.statusline').setup()
require('mini.sessions').setup()
require('mini.starter').setup()
require('mini.pick').setup()
require('mini.extra').setup()


vim.keymap.set('n', '<leader>sh', MiniPick.builtin.help, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', MiniExtra.pickers.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', MiniPick.builtin.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', MiniPick.builtin.grep_live, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', MiniExtra.pickers.diagnostic, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', MiniPick.builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader><leader>', MiniPick.builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', {
  bg = '#555555',
  bold = true,
})
