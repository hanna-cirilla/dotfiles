return {
  -- LSP package manager
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Bridges mason ↔ nvim-lspconfig: auto-installs servers
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "omnisharp",  -- C# / .NET
        "ts_ls",      -- TypeScript / JavaScript (requires Node)
        "eslint",     -- ESLint LSP
        "jsonls",     -- JSON with schema support
      },
      automatic_installation = true,
    },
  },

  -- Provides server definitions; actual setup uses vim.lsp.config (nvim 0.11+)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Apply capabilities to ALL servers at once (nvim 0.11+ API)
      vim.lsp.config("*", { capabilities = capabilities })

      -- OmniSharp: specify Mason-managed binary + extra settings
      vim.lsp.config("omnisharp", {
        cmd = {
          vim.fn.stdpath("data") .. "/mason/bin/OmniSharp.cmd",
          "--languageserver",
          "--hostPID", tostring(vim.fn.getpid()),
        },
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport  = true,
            EnableImportCompletion  = true,
          },
        },
      })

      -- Enable servers (replaces the old .setup() calls)
      vim.lsp.enable({ "omnisharp", "ts_ls", "eslint", "jsonls" })

      -- Keymaps + ESLint auto-fix applied on every LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,    vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,     vim.tbl_extend("force", opts, { desc = "References" }))
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Implementation" }))
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,          vim.tbl_extend("force", opts, { desc = "Hover Docs" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,         vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", opts, { desc = "Code Action" }))
          vim.keymap.set("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format Buffer" }))
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,   vim.tbl_extend("force", opts, { desc = "Prev Diagnostic" }))
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,   vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
          vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float,  vim.tbl_extend("force", opts, { desc = "Show Diagnostic" }))

          -- ESLint: auto-fix all on save
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = ev.buf,
              command = "EslintFixAll",
            })
          end
        end,
      })
    end,
  },
}

