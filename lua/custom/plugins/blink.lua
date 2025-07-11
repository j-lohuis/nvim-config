return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',
  opts = {
    keymap = {
      preset = 'default',
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        cmdline = {
          enabled = function()
            return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
          end
        }
      }
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
      ghost_text = { enabled = true },
    },

    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
  },
}
