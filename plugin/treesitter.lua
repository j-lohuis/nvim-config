vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
})

require('nvim-treesitter').setup()
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'bash', 'c', 'cpp', 'lua', 'vim', 'vimdoc' },
  auto_install = true,
  highlight = {
    enable = true,
    disable = { "latex", "tex" },
  },
  indent = { enable = false },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
      },
    },
    move = { enable = false },
    swap = {
      enable = true,
      swap_next = { ['<leader>a'] = '@parameter.inner' },
      swap_previous = { ['<leader>A'] = '@parameter.inner' },
    },
  },
})
require('treesitter-context').setup { enable = true, max_lines = 5 }
