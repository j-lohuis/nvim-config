return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    {
      'nvim-treesitter/nvim-treesitter-context',
      opts = { enable = false }, -- Disable until 0.11 compatibility is fixed
    },
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
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
    }
    -- Treesitter-context disabled due to 0.11 compatibility issues
    -- require('treesitter-context').setup { enable = true, max_lines = 5 }
  end,
}
