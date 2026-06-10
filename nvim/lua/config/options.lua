local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.wrap           = false
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.termguicolors  = true
opt.colorcolumn    = "120"   -- C# / .NET common line-length guide
opt.laststatus     = 3       -- single global statusline (cleaner with splits)
opt.winborder      = "rounded"  -- rounded borders on all floating windows
opt.fillchars      = {
  horiz     = "─",
  horizup   = "┴",
  horizdown = "┬",
  vert      = "│",
  vertleft  = "┤",
  vertright = "├",
  verthoriz = "┼",
  diff      = "╱",
  eob       = " ",  -- hide ~ at end of buffer
}

-- Indentation (C# and JavaScript/TypeScript standard = 4 spaces)
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true

-- Search
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.incsearch      = true

-- Files
opt.undofile       = true
opt.swapfile       = false
opt.backup         = false
opt.updatetime     = 250
opt.timeoutlen     = 300
opt.encoding       = "utf-8"
opt.fileencoding   = "utf-8"

-- Splits open right and below (more natural)
opt.splitright     = true
opt.splitbelow     = true

-- Windows: use pwsh as the shell inside nvim (for :! commands, toggleterm, etc.)
if vim.fn.has("win32") == 1 then
  opt.shell        = "pwsh"
  opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  opt.shellxquote  = ""
  opt.shellquote   = ""
  opt.shellpipe    = "| Out-File -Encoding UTF8 %s"
  opt.shellredir   = "| Out-File -Encoding UTF8 %s"
end
