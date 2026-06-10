return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "Mofiqul/dracula.nvim" },
    event = "VeryLazy",
    opts = {
      options = {
        theme                = "dracula-nvim",
        globalstatus         = true,
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
        disabled_filetypes   = {
          statusline = { "NvimTree", "dashboard", "lazy", "mason" },
        },
      },
      sections = {
          lualine_a = {
            { "mode", separator = { left = "" }, padding = { left = 0, right = 1 } },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = " ●", readonly = "  ", unnamed = "[No Name]" },
            },
          },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then return "" end
                local names = vim.tbl_map(function(c) return c.name end, clients)
                return " " .. table.concat(names, " ")
              end,
              color = { fg = "#8BE9FD" },
            },
            { "filetype", icon_only = false },
          },
          lualine_y = { { "progress", separator = { right = "" } } },
          lualine_z = {
            { "location", separator = { right = "" }, padding = { left = 1, right = 0 } },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
    },
  },
}
