return {
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    priority = 1000,
    config = function()
      require("dracula").setup({
        show_end_of_buffer = false,
        transparent_bg = false,
        italic_comment = true,
        overrides = function(colors)
          return {
            -- Window splits
            WinSeparator             = { fg = colors.selection, bg = colors.bg },
            -- Indent guides
            IblIndent                = { fg = colors.visual },
            IblScope                 = { fg = colors.comment, bold = true },
            -- nvim-tree: darker sidebar bg so it recedes visually
            NvimTreeNormal           = { bg = colors.menu },
            NvimTreeNormalNC         = { bg = colors.menu },
            NvimTreeEndOfBuffer      = { fg = colors.menu, bg = colors.menu },
            NvimTreeWinSeparator     = { fg = colors.selection, bg = colors.menu },
            NvimTreeIndentMarker     = { fg = colors.gutter_fg },
            NvimTreeFolderName       = { fg = colors.purple },
            NvimTreeOpenedFolderName = { fg = colors.pink, bold = true },
            NvimTreeEmptyFolderName  = { fg = colors.comment },
          }
        end,
      })
      vim.cmd.colorscheme("dracula")
    end,
  },
}
