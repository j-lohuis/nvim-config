return {
  'echasnovski/mini.nvim',
  lazy = false,
  config = function()
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
  end,
}
