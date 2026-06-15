vim.pack.add({ 'https://github.com/nvim-tree/nvim-web-devicons' })
vim.pack.add({ 'https://github.com/sindrets/diffview.nvim' })

require('nvim-web-devicons').setup()

local actions = require("diffview.actions")
require('diffview').setup({
  enhanced_diff_hl = true,
  view = {
    merge_tool = {
      layout = 'diff4_mixed',
    },
  },
  keymaps = {
    view = {
      { "n", "<leader>do",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
      { "n", "<leader>dt",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
      { "n", "<leader>db",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
      { "n", "<leader>da",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
      { "n", "dx",          actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
      { "n", "<leader>dO",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
      { "n", "<leader>dT",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
      { "n", "<leader>dB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
      { "n", "<leader>dA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
      { "n", "dX",          actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
    }
  },
})
vim.opt.fillchars:append { diff = "╱" }
