# dotfiles

Personal development environment config — Neovim + PowerShell 7.

## What's inside

| Path | Description |
|---|---|
| `nvim/` | Neovim config (lazy.nvim, LSP, Copilot, Telescope, Dracula theme) |
| `powershell/Microsoft.PowerShell_profile.ps1` | pwsh 7 profile (oh-my-posh, PSReadline, git/dotnet/npm aliases, fzf) |
| `prompt/.mytheme.omp.json` | Custom Dracula oh-my-posh prompt theme |
| `install.sh` | Setup script for Linux devcontainers |

## Usage with VSCode Dev Containers

Add to your **VS Code User Settings** (`Ctrl+,` → search "dotfiles"):

```json
{
  "dotfiles.repository": "your-github-username/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "install.sh"
}
```

Every new devcontainer you open will automatically clone this repo and run `install.sh`.

## What `install.sh` installs

- **Neovim config** → `~/.config/nvim/` (symlinked)
- **PowerShell 7 profile** → `~/.config/powershell/Microsoft.PowerShell_profile.ps1` (symlinked)
- **oh-my-posh theme** → `~/.mytheme.omp.json` (symlinked)
- **oh-my-posh** binary (if missing)
- **PowerShell modules**: `posh-git`, `Terminal-Icons`, `PSFzf`
- **CLI tools** (via apt or curl): `fzf`, `ripgrep`, `bat`, `zoxide`

## Manual install

```bash
git clone https://github.com/your-github-username/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Neovim plugins (installed automatically by lazy.nvim on first launch)

- LSP: OmniSharp (C#), ts_ls, eslint, jsonls — via mason.nvim
- Completion: nvim-cmp + LuaSnip + Copilot
- Debugging: netcoredbg (C#), js-debug-adapter (Node)
- UI: Dracula, nvim-tree, Telescope, lualine, indent-blankline, which-key

## PowerShell profile features

- **Prompt**: oh-my-posh with custom Dracula theme (git branch icons, node version)
- **PSReadline**: Dracula colors, `Tab` → MenuComplete, `Ctrl+d` → exit, `Ctrl+r` → fzf history
- **Modules**: posh-git, Terminal-Icons, PSFzf, zoxide
- **Git aliases**: `gs`, `ga`, `gaa`, `gc`, `gp`, `gpl`, `gf`, `gl`, `gco`, `gcb`, `gd`, `gds`
- **dotnet aliases**: `dnr`, `dnb`, `dnt`, `dnw`, `dnwr`, `dnpub`, `dnrst`, `vs`
- **npm aliases**: `ni`, `nid`, `nr`, `nrd`, `nrb`, `nrt`, `nlg`
- **Utilities**: `which`, `touch`, `ll`, `reload`, `v.` (nvim .), `killport`, `todos`, `edit-profile`
