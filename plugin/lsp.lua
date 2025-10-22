vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/j-hui/fidget.nvim',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
})

require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-l>'] = { 'snippet_forward', 'fallback' },
    ['<C-h>'] = { 'snippet_backward', 'fallback' },
  },

  sources = {
    default = { 'lsp', 'path', 'buffer' },
  },

  -- snippets = {
  --   expand = function(snippet) vim.snippet.expand(snippet) end,
  --   active = function(filter) return vim.snippet.active(filter) end,
  --   jump = function(direction) vim.snippet.jump(direction) end,
  -- },

  completion = {
    accept = {
      -- dot_repeat = true,
      auto_brackets = {
        enabled = false,
      },
    },
    menu = {
      draw = { treesitter = { 'lsp' } },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = false },
  },

  signature = {
    enabled = true,
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = 'mono',
  },
})

local capabilities = require('blink.cmp').get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false;
vim.lsp.config('*', {
  capabilities = capabilities
})

require('fidget').setup({})
require('mason').setup()
require('mason-lspconfig').setup()

vim.lsp.enable('rust_analyzer');

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method('textDocument/inlayHint') then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end

    local function lsp_pick(scope)
      return function()
        MiniExtra.pickers.lsp({scope = scope})
      end
    end

    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    -- map('gd', lsp_pick('definition'), '[G]oto [D]efinition')
    map('gr', lsp_pick('references'), '[G]oto [R]eferences')
    map('<leader>ds', lsp_pick('document_symbol'), '[D]ocument [S]ymbols')
    map('<leader>ws', lsp_pick('document_symbol'), '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  end,
})
