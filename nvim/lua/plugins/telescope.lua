return {
  {
    "nvim-telescope/telescope.nvim",
    branch       = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        cond  = function() return vim.fn.executable("cmake") == 1 end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",             desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",              desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",               desc = "Recent Files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",   desc = "LSP Symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>",  desc = "Workspace Symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",            desc = "Diagnostics" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",              desc = "Help Tags" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",            desc = "Git Commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",           desc = "Git Branches" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",             desc = "Git Status" },
      -- Search in current word
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",            desc = "Search Word Under Cursor" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", "%.git/", "bin/", "obj/" },
          layout_strategy      = "horizontal",
          sorting_strategy     = "ascending",
          layout_config        = { prompt_position = "top", preview_width = 0.55 },
          preview              = { treesitter = false },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
      })

      -- Load fzf-native sorter if built successfully
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
