return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys  = {
      {
        "<leader>F",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Format Buffer (conform)",
      },
    },
    opts = {
      formatters_by_ft = {
        cs              = { "csharpier" },   -- dotnet tool install -g csharpier
        javascript      = { "prettier" },    -- npm install -g prettier
        javascriptreact = { "prettier" },
        typescript      = { "prettier" },
        typescriptreact = { "prettier" },
        json            = { "prettier" },
        jsonc           = { "prettier" },
        markdown        = { "prettier" },
        lua             = { "stylua" },      -- :MasonInstall stylua
      },
      format_on_save = {
        timeout_ms   = 1000,
        lsp_fallback = true,
      },
    },
  },
}
