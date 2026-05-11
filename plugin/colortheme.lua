vim.pack.add({ 'https://github.com/Mofiqul/vscode.nvim' })
require('vscode').setup({
  color_overrides = {
    vscBack = '#101010'
  },
})
vim.cmd.colorscheme 'vscode'
