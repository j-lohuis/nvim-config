-- ~/.config/nvim/init.lua
-- Simplified Neovim configuration using lazy.nvim

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ========================================================================
-- OPTIONS
-- ========================================================================

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
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '↵' }

vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.colorcolumn = "100"

-- Indentation options (4 spaces)
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.opt.scrolloff = 10
vim.opt.wrap = false

vim.opt.diffopt:append { 'filler,algorithm:minimal,linematch:100,iwhiteall' }

-- ========================================================================
-- KEYMAPS
-- ========================================================================

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('x', '<leader>p', [["_dP]])

-- Clipboard mappings
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set('n', '<M-y>', ':%y+<CR>')

vim.keymap.set('i', '<C-c>', '<Nop>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>m', vim.diagnostic.open_float, { desc = 'Show diagnostic error [M]essages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<M-Right>', ':cn<CR>', { desc = 'Next Quickfix' })
vim.keymap.set('n', '<M-Left>', ':cp<CR>', { desc = 'Previous Quickfix' })

-- Exit terminal mode easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Navigation in wrapped lines
vim.keymap.set('n', 'j', function()
  return (vim.v.count > 4) and "m'" .. vim.v.count .. 'j' or 'gj'
end, { expr = true, noremap = true })

vim.keymap.set('n', 'k', function()
  return (vim.v.count > 4) and "m'" .. vim.v.count .. 'k' or 'gk'
end, { expr = true, noremap = true })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('', '<C-Left>', ':vertical resize +3<CR>')
vim.keymap.set('', '<C-Right>', ':vertical resize -3<CR>')
vim.keymap.set('', '<C-Up>', ':resize +3<CR>')
vim.keymap.set('', '<C-Down>', ':resize -3<CR>')

-- ========================================================================
-- AUTOCOMMANDS
-- ========================================================================

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Custom commands
vim.api.nvim_create_user_command('MakeGS', function(opts)
  local session_name = opts.args
  if session_name == '' then
    session_name = 'default'
  end
  local session_path = vim.fn.stdpath('data') .. '/session/' .. session_name .. '.vim'
  vim.fn.mkdir(vim.fn.fnamemodify(session_path, ':h'), 'p')
  vim.cmd('mksession! ' .. session_path)
  print('Session saved to ' .. session_path)
end, { nargs = '?' })

vim.api.nvim_create_user_command('WipeRegs', function()
  for i = string.byte('a'), string.byte('z') do
    vim.fn.setreg(string.char(i), '')
  end
  for i = string.byte('A'), string.byte('Z') do
    vim.fn.setreg(string.char(i), '')
  end
  for i = 0, 9 do
    vim.fn.setreg(tostring(i), '')
  end
  vim.fn.setreg('"', '')
  vim.fn.setreg('*', '')
  vim.fn.setreg('+', '')
  print('All registers cleared!')
end, {})

-- ========================================================================
-- LAZY.NVIM BOOTSTRAP
-- ========================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================
-- PLUGINS
-- ========================================================================

require("lazy").setup({
  "echasnovski/mini.nvim",
  "folke/which-key.nvim",
  "stevearc/conform.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "query", "rust", "c", "cpp" },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<M-space>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  { 
    "saghen/blink.cmp", 
    version = "v0.*",
    lazy = false,
    dependencies = 'rafamadriz/friendly-snippets',
    opts = {
      keymap = {
        preset = 'default',
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      snippets = {
        expand = function(snippet) vim.snippet.expand(snippet) end,
        active = function(filter) return vim.snippet.active(filter) end,
        jump = function(direction) vim.snippet.jump(direction) end,
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = {
          draw = { treesitter = { 'lsp' } },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = false },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
      },
    }
  },
  "lewis6991/gitsigns.nvim",
  "Mofiqul/vscode.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "neovim/nvim-lspconfig",
  "stevearc/oil.nvim",
}, {
  install = { colorscheme = { "vscode" } },
  ui = { border = "rounded" },
})

-- ========================================================================
-- PLUGIN CONFIGURATIONS
-- ========================================================================

-- VSCode Theme
require('vscode').setup({
  color_overrides = {
    vscBack = '#000000'
  }
})
vim.cmd.colorscheme('vscode')

-- Mini.nvim modules
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

-- Mini.pick (telescope replacement)
require('mini.pick').setup()
vim.keymap.set('n', '<leader>sf', function() require('mini.pick').builtin.files() end, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', function() require('mini.pick').builtin.grep_live() end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sw', function() require('mini.pick').builtin.grep({ pattern = vim.fn.expand('<cword>') }) end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader><leader>', function() require('mini.pick').builtin.buffers() end, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sn', function() require('mini.pick').builtin.files({ tool = 'rg', pattern = vim.fn.stdpath('config') }) end, { desc = '[S]earch [N]eovim files' })

-- Which-key
require('which-key').setup()
require('which-key').add({
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>s', group = '[S]earch' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  { '<leader>f', group = 'Sur[F]ound' },
})

-- Oil.nvim
require("oil").setup({
  columns = { "icon" },
  keymaps = {
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-k>"] = false,
    ["<C-j>"] = false,
    ["<M-h>"] = "actions.select_split",
  },
  view_options = { show_hidden = true },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", function() require("oil").toggle_float() end, { desc = "Toggle Oil float" })

-- Gitsigns
require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- Conform (formatting)
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

-- Blink.cmp is configured in lazy.nvim opts above

-- ========================================================================
-- LSP CONFIGURATION
-- ========================================================================

-- Neoconf setup (must be before LSP config)
require('neoconf').setup()

local lspconfig = require('lspconfig')

-- Configure LSP servers using lspconfig
lspconfig.lua_ls.setup({
  cmd = { 'lua-language-server' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim', 'require' } },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME }
      },
      telemetry = { enable = false },
    },
  },
})

lspconfig.rust_analyzer.setup({
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = true,
    },
  },
})

lspconfig.clangd.setup({
  cmd = { 'clangd' },
})

-- LSP keymaps (using builtin defaults where possible)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { desc = 'Type [D]efinition' })
vim.keymap.set('n', '<leader>ds', function() require('mini.pick').builtin.lsp({ scope = 'document_symbol' }) end, { desc = '[D]ocument [S]ymbols' })
vim.keymap.set('n', '<leader>ws', function() require('mini.pick').builtin.lsp({ scope = 'workspace_symbol' }) end, { desc = '[W]orkspace [S]ymbols' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })

