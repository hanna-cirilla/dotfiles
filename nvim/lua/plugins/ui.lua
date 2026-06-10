return {
  -- Indent guides with scope highlighting
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        char = "│",
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "neo-tree", "NvimTree",
          "Trouble", "lazy", "mason", "notify", "toggleterm",
        },
      },
    },
  },
}
