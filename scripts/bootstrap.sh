#!/usr/bin/env bash
# Installs Homebrew, Oh-my-zsh, Starship, and all Brewfile packages.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Homebrew ─────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed — updating."
  brew update || echo "brew update failed (network/SSH issue) — continuing."
fi

# ── Oh-my-zsh ────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh-my-zsh already installed."
fi

# ── Oh-my-zsh custom plugins ─────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local repo="$1" dest="$2"
  [[ -d "$dest" ]] || git clone --depth=1 "$repo" "$dest"
}

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

clone_if_missing https://github.com/zsh-users/zsh-completions \
  "$ZSH_CUSTOM/plugins/zsh-completions"

clone_if_missing https://github.com/fdellwing/zsh-bat \
  "$ZSH_CUSTOM/plugins/zsh-bat"

# ── Brewfile ─────────────────────────────────────────────────────────────────
echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile" || true

if [[ -f "$DOTFILES_DIR/Brewfile.local" ]]; then
  echo "Installing machine-specific packages from Brewfile.local..."
  brew bundle --file="$DOTFILES_DIR/Brewfile.local" || true
else
  echo "No Brewfile.local found — copy Brewfile.local.example to add machine-specific packages (e.g. docker-desktop or rancher)."
fi

# ── Starship prompt ──────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  echo "Installing Starship..."
  brew install starship
fi

# ── uv (Python package manager) ──────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "Bootstrap complete."
