vim.api.nvim_create_autocmd("PackChanged", {
  desc = "TSUpdate on treesitter update",
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end
})

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
})

local custom_parsers = {
  "scl",
}

local custom_extensions = {}
for _, lang in ipairs(custom_parsers) do
  custom_extensions[lang] = lang
  vim.treesitter.language.register(lang, lang)
end

vim.filetype.add({
  extension = custom_extensions
})

require('nvim-treesitter').setup()

require('nvim-treesitter').install({
  "asm",
  "bash",
  "cmake",
  "cpp",
  "css",
  "csv",
  "diff",
  "dockerfile",
  "ecma",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "html",
  "html_tags",
  "javascript",
  "json",
  "json5",
  "jsx",
  "make",
  "objdump",
  "perl",
  "rust",
  "sql",
  "ssh_config",
  "tablegen",
  "toml",
  "tsv",
  "tsx",
  "xml",
  "yaml",
});

require('treesitter-context').setup { enable = true, max_lines = 5 }

local pre_installed_parsers = {
  "c",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "vim",
  "vimdoc",
}

local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end

    if vim.list_contains(custom_parsers, lang) then
      vim.treesitter.start(args.buf, lang)
      return
    end

    local treesitter = require('nvim-treesitter')
    if vim.list_contains(treesitter.get_available(), lang) then
      if not vim.list_contains(treesitter.get_installed(), lang)
        and not vim.list_contains(pre_installed_parsers, lang) then
        treesitter.install(lang):wait()
      end
      vim.treesitter.start(args.buf, lang)
    end
  end,
  desc = "Enable nvim-treesitter and install parser if not installed"
})



