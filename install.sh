#!/usr/bin/env bash
# install.sh — dotfiles setup for Linux devcontainers
# Installs: nvim config, PowerShell 7 profile, oh-my-posh theme, and all required tools/modules
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Helpers ───────────────────────────────────────────────────────────────────

link() {
    local src="$DOTFILES_DIR/$1"
    local dest="${2:-$HOME/$1}"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        mv "$dest" "${dest}.bak"
        echo "  Backed up existing: $dest → ${dest}.bak"
    fi
    ln -sf "$src" "$dest"
    echo "  Linked: $dest"
}

apt_install() {
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y --no-install-recommends "$@" 2>/dev/null
    else
        echo "  [skip] apt-get not available, skipping: $*"
    fi
}

pwsh_install_module() {
    if command -v pwsh &>/dev/null; then
        pwsh -NoProfile -Command "
            if (-not (Get-Module -ListAvailable -Name '$1')) {
                Write-Host '  Installing PS module: $1'
                Install-Module '$1' -Force -Scope CurrentUser -Repository PSGallery
            } else {
                Write-Host '  PS module already installed: $1'
            }
        "
    else
        echo "  [skip] pwsh not available, skipping module: $1"
    fi
}

# ── 1. Neovim config ─────────────────────────────────────────────────────────

echo "→ Neovim config"
if command -v nvim &>/dev/null; then
    NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    link "nvim/init.lua" "$NVIM_DIR/init.lua"
    link "nvim/lua"      "$NVIM_DIR/lua"
    # lazy-lock.json: copy on first install only; let lazy.nvim manage it afterwards
    if [ ! -f "$NVIM_DIR/lazy-lock.json" ]; then
        cp "$DOTFILES_DIR/nvim/lazy-lock.json" "$NVIM_DIR/lazy-lock.json"
        echo "  Copied: lazy-lock.json (initial)"
    fi
else
    echo "  [skip] nvim not found — install it to use the nvim config"
fi

# ── 2. Oh My Posh theme ───────────────────────────────────────────────────────

echo "→ Oh My Posh theme"
link "prompt/.mytheme.omp.json" "$HOME/.mytheme.omp.json"

# Install oh-my-posh binary if missing (needed for the PS profile to work)
if ! command -v oh-my-posh &>/dev/null; then
    echo "→ Installing oh-my-posh"
    if command -v curl &>/dev/null; then
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "  [skip] curl not available — install oh-my-posh manually"
    fi
else
    echo "  oh-my-posh already installed: $(oh-my-posh --version)"
fi

# ── 3. PowerShell profile ────────────────────────────────────────────────────

echo "→ PowerShell 7 profile"
PS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/powershell"
link "powershell/Microsoft.PowerShell_profile.ps1" "$PS_CONFIG_DIR/Microsoft.PowerShell_profile.ps1"

# ── 4. PowerShell modules ─────────────────────────────────────────────────────

echo "→ PowerShell modules"
# posh-git: git status in the prompt
pwsh_install_module "posh-git"
# Terminal-Icons: file type icons in Get-ChildItem (requires Nerd Font)
pwsh_install_module "Terminal-Icons"
# PSFzf: fzf integration (Ctrl+t / Ctrl+r in the PS prompt)
pwsh_install_module "PSFzf"

# ── 5. CLI tools (apt-based Linux, e.g. Debian/Ubuntu devcontainer images) ───

echo "→ CLI tools"

# fzf — fuzzy finder (PSFzf and FZF_DEFAULT_COMMAND depend on this)
if ! command -v fzf &>/dev/null; then
    echo "  Installing fzf"
    apt_install fzf
fi

# ripgrep — fast grep; used as FZF_DEFAULT_COMMAND and by the todos() PS function
if ! command -v rg &>/dev/null; then
    echo "  Installing ripgrep"
    apt_install ripgrep
fi

# bat — syntax-highlighted cat; used in FZF_CTRL_T_OPTS preview and bdiff git alias
if ! command -v bat &>/dev/null; then
    echo "  Installing bat"
    apt_install bat
fi

# zoxide — smarter cd; initialized in the PS profile
if ! command -v zoxide &>/dev/null; then
    echo "  Installing zoxide"
    # zoxide is not in all Ubuntu apt repos — prefer the official installer
    if command -v curl &>/dev/null; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        apt_install zoxide 2>/dev/null || echo "  [skip] zoxide install failed — install manually"
    fi
fi

echo ""
echo "✅ Dotfiles installed!"
echo ""
echo "Next steps:"
echo "  • Open nvim — lazy.nvim will auto-install all plugins on first launch"
echo "  • Start pwsh — modules (posh-git, Terminal-Icons, PSFzf) were installed above"
echo "  • 'source ~/.bashrc' or restart your shell if PATH was updated"
