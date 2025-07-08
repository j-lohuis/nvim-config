return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = { PATH = "append" } },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method('textDocument/inlayHint') then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Helper function to check if a command is available in PATH
    local function is_executable(cmd)
      return vim.fn.executable(cmd) == 1
    end

    -- Helper function to get Mason path for a server
    local function get_mason_path(server_name)
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed(server_name) then
        local pkg = mason_registry.get_package(server_name)
        return pkg:get_install_path()
      end
      return nil
    end

    local rust_analyzer = { checkOnSave = { command = "clippy" } }
    local servers = {
      clangd = {
        -- Prefer system clangd, fallback to Mason
        cmd = function()
          if is_executable("clangd") then
            return { "clangd", "--header-insertion=never", "--completion-style=detailed", "--log=verbose" }
          else
            local mason_path = get_mason_path("clangd")
            if mason_path then
              return { mason_path .. "/bin/clangd", "--header-insertion=never", "--completion-style=detailed", "--log=verbose" }
            end
            return { "clangd", "--header-insertion=never", "--completion-style=detailed", "--log=verbose" } -- fallback
          end
        end,
      },
      rust_analyzer = {
        -- Prefer system rust-analyzer, fallback to Mason
        cmd = function()
          if is_executable("rust-analyzer") then
            return { "rust-analyzer" }
          else
            local mason_path = get_mason_path("rust-analyzer")
            if mason_path then
              return { mason_path .. "/bin/rust-analyzer" }
            end
            return { "rust-analyzer" } -- fallback
          end
        end,
        settings = { ["rust-analyzer"] = rust_analyzer },
      },
      lua_ls = {
        -- Mason-only for lua_ls since system versions are often outdated
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = { '${3rd}/luv/library', unpack(vim.api.nvim_get_runtime_file('', true)) },
            },
            telemetry = { enable = false },
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
      pyright = {
        settings = {}
      },
      ts_ls = {}
    }

    require('mason').setup()

    -- Conditional installation - only install what's not available system-wide
    local ensure_installed = {}

    -- Always install lua_ls and stylua via Mason (system versions often problematic)
    table.insert(ensure_installed, 'lua-language-server')
    table.insert(ensure_installed, 'stylua')

    -- Only install language servers if not available system-wide
    if not is_executable("clangd") then
      table.insert(ensure_installed, 'clangd')
    end
    if not is_executable("rust-analyzer") then
      table.insert(ensure_installed, 'rust-analyzer')
    end

    -- Always install codelldb via Mason (system versions rarely work well)
    table.insert(ensure_installed, 'codelldb')

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- Setup LSP servers with hybrid approach
    for server_name, server_config in pairs(servers) do
      local config = {
        settings = server_config.settings,
        filetypes = server_config.filetypes,
        capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {}),
      }

      -- Set command if it's a function (system/Mason detection)
      if type(server_config.cmd) == "function" then
        config.cmd = server_config.cmd()
      elseif server_config.cmd then
        config.cmd = server_config.cmd
      end

      require('lspconfig')[server_name].setup(config)
    end

    -- Still use mason-lspconfig for any additional servers Mason installs
    require('mason-lspconfig').setup {
      automatic_enable = false,
      handlers = {
        function(server_name)
          -- Skip servers we've already configured above
          if servers[server_name] then
            return
          end

          -- Auto-setup any other Mason-installed servers
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
          }
        end,
      },
    }
  end,
}
