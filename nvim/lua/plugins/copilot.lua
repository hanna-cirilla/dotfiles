-- GitHub Copilot in nvim (lua-native, integrates with nvim-cmp)
-- Node.js required: Volta v2.0.2, Node v20.15.1 ✓
-- After :Lazy sync, run :Copilot auth
return {
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- Disable built-in suggestion/panel — using nvim-cmp source instead
        suggestion = { enabled = false },
        panel      = { enabled = false },
        filetypes  = {
          cs         = true,
          javascript = true,
          typescript = true,
          lua        = true,
          markdown   = true,
          yaml       = true,
          json       = true,
          ["*"]      = false,
        },
      })
    end,
  },

  -- Exposes Copilot as an nvim-cmp source
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
