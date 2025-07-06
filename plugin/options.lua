-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse support, search, signcolumn, update times, splits, etc.
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Whitespace and listchars
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '\\u21b5' }

vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.colorcolumn = "100"

-- Indentation options (4 spaces)
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.opt.scrolloff = 10
vim.opt.wrap = false
