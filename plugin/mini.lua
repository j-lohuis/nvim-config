vim.pack.add({ 'https://github.com/echasnovski/mini.nvim' })
-- Leave `an`/`in` to Neovim's treesitter node selection
require('mini.ai').setup({ mappings = { around_next = '', inside_next = '' } })
require('mini.align').setup()
require('mini.move').setup()
-- Leave `gr*` to Neovim's LSP mappings
require('mini.operators').setup({ replace = { prefix = '' } })
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
require('mini.pick').setup()
require('mini.extra').setup()


vim.keymap.set('n', '<leader>sh', MiniPick.builtin.help, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', MiniExtra.pickers.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', MiniPick.builtin.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', MiniPick.builtin.grep_live, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sif', function()
  MiniPick.builtin.cli(
    { command = { 'rg', '--files', '--color=never', '--no-ignore', '--hidden', '--glob=!.git' } },
    { source = {
      name = 'Files (rg, incl. ignored)',
      show = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end,
    } }
  )
end, { desc = '[S]earch [I]gnored [F]iles' })
vim.keymap.set('n', '<leader>sig', function()
  MiniPick.builtin.grep_live({ globs = { '*', '!.git' } })
end, { desc = '[S]earch [I]gnored by [G]rep' })
vim.keymap.set('n', '<leader>sd', MiniExtra.pickers.diagnostic, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', MiniPick.builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader><leader>', MiniPick.builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', MiniExtra.pickers.buf_lines, { desc = '[/] Find in buffer' })

vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', {
  bg = '#555555',
  bold = true,
})
