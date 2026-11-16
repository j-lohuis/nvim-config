vim.pack.add({ 'https://github.com/Mofiqul/vscode.nvim' })

-- Only override the background in dark mode. Re-run setup before every load so the
-- override follows 'background' (changing it reloads the colorscheme).
vim.api.nvim_create_autocmd('ColorSchemePre', {
  pattern = 'vscode',
  callback = function()
    require('vscode').setup({
      color_overrides = vim.o.background == 'dark' and { vscBack = '#000000' } or {},
    })
  end,
})

vim.cmd.colorscheme 'vscode'
