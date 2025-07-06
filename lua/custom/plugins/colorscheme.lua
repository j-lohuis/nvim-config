return {
  'Mofiqul/vscode.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('vscode').setup({
      color_overrides = {
        vscBack = '#000000'
      }
    })
    vim.cmd.colorscheme 'vscode'
  end,
}
