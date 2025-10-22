vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
require('conform').setup({
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt", lsp_format = "fallback" },
    python = { "isort", "black" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
  formatters = {
    prettierd = {
      options = {
        ft_parsers = {
          javascript = "babel",
          javascriptreact = "babel",
          typescript = "typescript",
          typescriptreact = "typescript",
          vue = "vue",
          css = "css",
          scss = "scss",
          less = "less",
          html = "html",
          json = "json",
          jsonc = "json",
          yaml = "yaml",
          markdown = "markdown",
          ["markdown.mdx"] = "mdx",
          graphql = "graphql",
          handlebars = "glimmer",
        },
        prepend_args = { "--config-file", "/home/julo/.prettierrc" },
      }
    }
  }
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
