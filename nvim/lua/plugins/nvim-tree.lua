return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup {
      hijack_netrw = true,
      view = {
        width = 32,
        side = "left",
        number = false,
        relativenumber = false,
        signcolumn = "no",
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_opened_files = "name",
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge   = "│",
            item   = "│",
            bottom = "─",
            none   = " ",
          },
        },
        icons = {
          web_devicons = { file = { enable = true }, folder = { enable = false } },
          git_placement = "after",
          diagnostics_placement = "before",
          padding = " ",
          glyphs = {
            default  = "",
            symlink  = "",
            bookmark = "󰆤",
            modified = "●",
            folder = {
              arrow_closed = "",
              arrow_open   = "",
              default      = "",
              open         = "",
              empty        = "",
              empty_open   = "",
              symlink      = "",
              symlink_open = "",
            },
            git = {
              unstaged  = "✦",
              staged    = "✓",
              unmerged  = "",
              renamed   = "➜",
              untracked = "★",
              deleted   = "",
              ignored   = "◌",
            },
          },
        },
      },
      git = { enable = true, ignore = false },
      modified = { enable = true },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
      },
      filters = { dotfiles = false },
    }

    -- Close nvim when nvim-tree is the last window standing
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local wins = vim.api.nvim_list_wins()
        local tree_wins = vim.tbl_filter(function(w)
          return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match("NvimTree_") ~= nil
        end, wins)
        if #tree_wins == #wins - 1 then
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })
  end,
}

