return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI with enhanced configuration
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "⏹",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      -- Setup virtual text with better formatting
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })

      -- CodeLLDB Adapter Configuration with system fallback
      dap.adapters.codelldb = function(on_adapter)
        local codelldb_path = nil
        
        -- First, try system codelldb
        if vim.fn.executable("codelldb") == 1 then
          codelldb_path = "codelldb"
        else
          -- Fallback to Mason's codelldb
          local mason_registry = require("mason-registry")
          if mason_registry.is_installed("codelldb") then
            local codelldb_package = mason_registry.get_package("codelldb")
            local install_root_dir = codelldb_package:get_install_path()
            local mason_codelldb_path = install_root_dir .. "/extension/adapter/codelldb"
            
            if vim.fn.executable(mason_codelldb_path) == 1 then
              codelldb_path = mason_codelldb_path
            end
          end
        end
        
        if not codelldb_path then
          vim.notify("CodeLLDB not found. Install system codelldb or install via Mason (:Mason)", vim.log.levels.ERROR)
          return
        end

        on_adapter({
          type = "server",
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = { "--port", "${port}" },
          }
        })
      end

      -- Enhanced C/C++ Configuration
      dap.configurations.c = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
        {
          name = "Launch with arguments",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
          runInTerminal = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = function()
            local handle = io.popen('ps -ax | grep -v grep')
            local result = handle:read('*a')
            handle:close()
            return vim.fn.input('PID: ', '', 'custom,' .. result)
          end,
          args = {},
        },
      }

      -- Copy C config to C++
      dap.configurations.cpp = dap.configurations.c

      -- Enhanced Rust Configuration with Cargo integration
      dap.configurations.rust = {
        {
          name = "Launch (Cargo)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Try to find the target binary automatically
            local cargo_metadata = vim.fn.system('cargo metadata --format-version 1 --no-deps')
            if vim.v.shell_error == 0 then
              local metadata = vim.fn.json_decode(cargo_metadata)
              if metadata and metadata.target_directory then
                local target_dir = metadata.target_directory .. "/debug/"
                return vim.fn.input('Path to executable: ', target_dir, 'file')
              end
            end
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          cargo = {
            args = { "build" },
            filter = {
              name = "rust-analyzer",
              kind = "bin"
            }
          }
        },
        {
          name = "Launch (Cargo with args)",
          type = "codelldb",
          request = "launch",
          program = function()
            local cargo_metadata = vim.fn.system('cargo metadata --format-version 1 --no-deps')
            if vim.v.shell_error == 0 then
              local metadata = vim.fn.json_decode(cargo_metadata)
              if metadata and metadata.target_directory then
                local target_dir = metadata.target_directory .. "/debug/"
                return vim.fn.input('Path to executable: ', target_dir, 'file')
              end
            end
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
          runInTerminal = false,
          cargo = {
            args = { "build" },
            filter = {
              name = "rust-analyzer",
              kind = "bin"
            }
          }
        },
        {
          name = "Launch (Release)",
          type = "codelldb",
          request = "launch",
          program = function()
            local cargo_metadata = vim.fn.system('cargo metadata --format-version 1 --no-deps')
            if vim.v.shell_error == 0 then
              local metadata = vim.fn.json_decode(cargo_metadata)
              if metadata and metadata.target_directory then
                local target_dir = metadata.target_directory .. "/release/"
                return vim.fn.input('Path to executable: ', target_dir, 'file')
              end
            end
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/release/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          cargo = {
            args = { "build", "--release" },
            filter = {
              name = "rust-analyzer",
              kind = "bin"
            }
          }
        },
        {
          name = "Launch tests",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/deps/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          cargo = {
            args = { "test", "--no-run" },
            filter = {
              name = "rust-analyzer",
              kind = "bin"
            }
          }
        },
      }

      -- VSCode-style keybindings
      vim.keymap.set("n", "<F5>", function()
        if dap.session() then
          dap.continue()
        else
          dap.continue()
        end
      end, { desc = "Debug: Start/Continue" })

      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<S-F5>", dap.restart, { desc = "Debug: Restart" })
      vim.keymap.set("n", "<C-F5>", dap.terminate, { desc = "Debug: Stop" })

      -- Additional debug shortcuts
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end, { desc = "Debug: Log Point" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })

      -- Rust-specific shortcuts
      vim.keymap.set("n", "<leader>drc", function()
        vim.fn.system('cargo build')
        dap.continue()
      end, { desc = "Debug: Cargo Build & Launch" })
      vim.keymap.set("n", "<leader>drt", function()
        vim.fn.system('cargo test --no-run')
        dap.continue()
      end, { desc = "Debug: Cargo Test Build & Launch" })

      -- Evaluation and UI
      vim.keymap.set({"n", "v"}, "<leader>dh", function()
        dapui.eval(nil, { enter = true })
      end, { desc = "Debug: Evaluate" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })

      -- Maintain legacy shortcuts for muscle memory
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor, { desc = "Debug: Run to Cursor" })
      vim.keymap.set("n", "<space>?", function()
        dapui.eval(nil, { enter = true })
      end, { desc = "Debug: Evaluate" })

      -- Automatic UI management
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Auto-highlight current line
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        desc = "prevent colorscheme clears self-defined DAP icon colors.",
        callback = function()
          vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
          vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
          vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })
        end,
      })

      -- Define breakpoint signs
      vim.fn.sign_define('DapBreakpoint', {
        text = '●',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })
      vim.fn.sign_define('DapBreakpointCondition', {
        text = '◆',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })
      vim.fn.sign_define('DapBreakpointRejected', {
        text = '○',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint'
      })
      vim.fn.sign_define('DapLogPoint', {
        text = '◉',
        texthl = 'DapLogPoint',
        linehl = 'DapLogPoint',
        numhl = 'DapLogPoint'
      })
      vim.fn.sign_define('DapStopped', {
        text = '▶',
        texthl = 'DapStopped',
        linehl = 'DapStopped',
        numhl = 'DapStopped'
      })
    end,
  },
}