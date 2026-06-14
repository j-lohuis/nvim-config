vim.pack.add({ 'https://github.com/nvim-tree/nvim-web-devicons' })
vim.pack.add({ 'https://github.com/sindrets/diffview.nvim' })

require('nvim-web-devicons').setup()
require('diffview').setup({
  enhanced_diff_hl = true,
  view = {
    merge_tool = {
      layout = 'diff4_mixed',
    },
  },
})
vim.opt.fillchars:append { diff = "╱" }
