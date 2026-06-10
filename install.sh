#!/usr/bin/env bash
# install.sh — dotfiles setup for Linux devcontainers
# Installs: nvim config, PowerShell 7 profile, oh-my-posh theme, and all required tools/modules
#
# Uses set -uo (undefined vars are errors, pipefail on) but NOT set -e so that
# individual tool installs can fail without aborting the whole script.
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=()

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

_APT_UPDATED=false
apt_install() {
    if command -v apt-get &>/dev/null && command -v sudo &>/dev/null; then
        if [ "$_APT_UPDATED" = false ]; then
            echo "  Running apt-get update…"
            sudo apt-get update -qq 2>/dev/null && _APT_UPDATED=true \
                || ERRORS+=("apt-get update failed")
        fi
        sudo apt-get install -y --no-install-recommends "$@" 2>/dev/null \
            || ERRORS+=("apt-get install $* failed")
    else
        echo "  [skip] apt-get/sudo not available, skipping: $*"
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

# ── 1. Neovim ─────────────────────────────────────────────────────────────────

echo "→ Neovim"
if ! command -v nvim &>/dev/null; then
    echo "  nvim not found — installing"
    _installed=false
    if command -v curl &>/dev/null && command -v apt-get &>/dev/null; then
        # Detect CPU architecture for the correct tarball
        _arch="$(uname -m)"
        case "$_arch" in
            x86_64)  _nvim_arch="x86_64" ;;
            aarch64) _nvim_arch="arm64"  ;;
            *)       _nvim_arch=""       ;;
        esac

        if [ -n "$_nvim_arch" ]; then
            NVIM_VERSION="v0.10.4"
            _url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${_nvim_arch}.tar.gz"
            if curl -fsSL "$_url" | sudo tar -xz -C /usr/local --strip-components=1; then
                echo "  Installed nvim ${NVIM_VERSION} (${_nvim_arch})"
                _installed=true
            else
                ERRORS+=("nvim: tarball install failed for ${_nvim_arch}")
            fi
        fi
    fi

    if [ "$_installed" = false ] && command -v apt-get &>/dev/null; then
        echo "  Falling back to apt-get"
        sudo apt-get install -y --no-install-recommends neovim || ERRORS+=("nvim: apt-get install failed")
    fi
fi

if command -v nvim &>/dev/null; then
    NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    link "nvim/init.lua" "$NVIM_DIR/init.lua"
    link "nvim/lua"      "$NVIM_DIR/lua"
    if [ ! -f "$NVIM_DIR/lazy-lock.json" ]; then
        cp "$DOTFILES_DIR/nvim/lazy-lock.json" "$NVIM_DIR/lazy-lock.json"
        echo "  Copied: lazy-lock.json (initial)"
    fi
    echo "  nvim config linked ($(nvim --version | head -1))"
else
    ERRORS+=("nvim: not available — config not linked")
    echo "  [skip] nvim still not available — config not linked"
fi

# ── 2. Oh My Posh theme ───────────────────────────────────────────────────────

echo "→ Oh My Posh theme"
link "prompt/.mytheme.omp.json" "$HOME/.mytheme.omp.json"

# Install oh-my-posh binary if missing (needed for the PS profile to work)
if ! command -v oh-my-posh &>/dev/null; then
    echo "→ Installing oh-my-posh"
    if command -v curl &>/dev/null; then
        # Download the binary directly from GitHub releases (avoids piping to sudo).
        _omp_arch=$(uname -m)
        case "$_omp_arch" in
            x86_64)  _omp_bin="posh-linux-amd64" ;;
            aarch64) _omp_bin="posh-linux-arm64" ;;
            *)       _omp_bin="" ;;
        esac
        if [ -n "$_omp_bin" ]; then
            _omp_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/$_omp_bin"
            _omp_dest=/usr/local/bin/oh-my-posh
            if command -v sudo &>/dev/null; then
                sudo curl -fsSL "$_omp_url" -o "$_omp_dest" \
                    && sudo chmod +x "$_omp_dest" \
                    || ERRORS+=("oh-my-posh: download from GitHub releases failed")
            else
                mkdir -p "$HOME/.local/bin"
                curl -fsSL "$_omp_url" -o "$HOME/.local/bin/oh-my-posh" \
                    && chmod +x "$HOME/.local/bin/oh-my-posh" \
                    || ERRORS+=("oh-my-posh: download from GitHub releases failed")
                export PATH="$HOME/.local/bin:$PATH"
            fi
        else
            ERRORS+=("oh-my-posh: unsupported arch $_omp_arch")
        fi
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
    # zoxide is not in all Ubuntu apt repos — prefer the official installer.
    # Install to /usr/local/bin (always on $PATH) when sudo is available.
    if command -v curl &>/dev/null; then
        if command -v sudo &>/dev/null; then
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
                | sudo sh -s -- --bin-dir /usr/local/bin \
                || ERRORS+=("zoxide: install failed")
        else
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh \
                || ERRORS+=("zoxide: install failed")
            export PATH="$HOME/.local/bin:$PATH"
        fi
    else
        apt_install zoxide
    fi
fi

echo ""
echo "✅ Dotfiles installed!"
echo ""
echo "Next steps:"
echo "  • Open nvim — lazy.nvim will auto-install all plugins on first launch"
echo "  • Start pwsh — modules (posh-git, Terminal-Icons, PSFzf) were installed above"
echo "  • 'source ~/.bashrc' or restart your shell if PATH was updated"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Some steps had non-fatal errors:"
    for e in "${ERRORS[@]}"; do
        echo "    • $e"
    done
fi
