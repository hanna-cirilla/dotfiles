return {
  -- Core DAP engine
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",        -- required by nvim-dap-ui
      "jay-babu/mason-nvim-dap.nvim", -- auto-installs debug adapters via mason
    },
    keys = {
      { "<F5>",       function() require("dap").continue() end,          desc = "DAP Continue" },
      { "<F10>",      function() require("dap").step_over() end,         desc = "DAP Step Over" },
      { "<F11>",      function() require("dap").step_into() end,         desc = "DAP Step Into" },
      { "<F12>",      function() require("dap").step_out() end,          desc = "DAP Step Out" },
      { "<leader>b",  function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>B",  function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "DAP UI Toggle" },
      { "<leader>dr", function() require("dap").repl.open() end,         desc = "DAP REPL" },
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Auto open/close DAP UI with debug sessions
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- ── C# / .NET Core via netcoredbg ─────────────────────────────────────
      -- Mason install: :MasonInstall netcoredbg
      dap.adapters.coreclr = {
        type    = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg.cmd",
        args    = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type    = "coreclr",
          name    = "Launch .NET (ask for dll)",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "\\bin\\Debug\\", "file")
          end,
        },
        {
          type    = "coreclr",
          name    = "Attach to running process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      -- ── Node.js via js-debug-adapter ──────────────────────────────────────
      -- Mason install: :MasonInstall js-debug-adapter
      local jsdbg = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args    = { jsdbg, "${port}" },
        },
      }

      local jsconfig = {
        { type = "pwa-node", request = "launch", name = "Launch current file", program = "${file}", cwd = "${workspaceFolder}" },
        { type = "pwa-node", request = "attach", name = "Attach to port 9229", port = 9229, cwd = "${workspaceFolder}" },
      }
      dap.configurations.javascript = jsconfig
      dap.configurations.typescript = jsconfig

      dapui.setup()
    end,
  },

  -- Auto-installs debug adapters via Mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed    = { "netcoredbg", "js" },
      automatic_installation = true,
    },
  },
}
