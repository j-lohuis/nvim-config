--- Parses a command-line string the way Bash does into an array of arguments.
--- It handles single quotes, double quotes, and backslash escapes.
--- @param str string: the command-line string to parse.
--- @return table: an array of argument strings.
local function shell_split(str)
  local words = {}       -- holds the final tokens
  local current = {}     -- holds the characters of the current token
  local in_single = false   -- are we inside a single-quoted string?
  local in_double = false   -- are we inside a double-quoted string?
  local escape = false      -- did we see a backslash?

  for i = 1, #str do
    local c = str:sub(i, i)
    if escape then
      -- When an escape is active, add the character literally
      table.insert(current, c)
      escape = false
    elseif c == "\\" then
      -- In single quotes, backslashes are literal.
      if in_single then
        table.insert(current, c)
      else
        escape = true
      end
    elseif c == "'" then
      if not in_double then
        -- Toggle single-quote state if not inside double quotes.
        in_single = not in_single
      else
        -- Inside double quotes, single quotes are literal.
        table.insert(current, c)
      end
    elseif c == '"' then
      if not in_single then
        -- Toggle double-quote state if not inside single quotes.
        in_double = not in_double
      else
        -- Inside single quotes, double quotes are literal.
        table.insert(current, c)
      end
    elseif c:match("%s") then
      if not in_single and not in_double then
        -- Outside any quotes, whitespace ends the current token.
        if #current > 0 then
          table.insert(words, table.concat(current))
          current = {}
        end
        -- (Do not insert an empty token for multiple spaces)
      else
        -- Inside quotes, preserve whitespace.
        table.insert(current, c)
      end
    else
      table.insert(current, c)
    end
  end

  -- If there's any token left at the end, add it.
  if #current > 0 then
    table.insert(words, table.concat(current))
  end

  return words
end

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
      local dap = require "dap"
      local ui = require "dapui"

      require("dapui").setup()

      require("nvim-dap-virtual-text").setup({})

      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = '/home/julo/tools/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }

      local dap_config = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description =  'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
        {
          name = "Launch file args",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
          args = function()
            local args = vim.fn.input('Arguments: ', '')
            return shell_split(args)
          end,
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description =  'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'gdb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = '/usr/bin/gdb',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          setupCommands = {
            {
              text = '-enable-pretty-printing',
              description =  'enable pretty printing',
              ignoreFailures = false
            },
          },
        },
      }
      dap.configurations.c = dap_config;
      dap.configurations.cpp = dap_config;
      dap.configurations.rust = dap_config;

      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

      -- Eval var under cursor
      vim.keymap.set("n", "<space>?", function()
        require("dapui").eval(nil, { enter = true })
      end)

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F13>", dap.restart)

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
