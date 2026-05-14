#!/usr/bin/env bash
# Uses GNU Stow to symlink dotfile packages into $HOME.
#   --simulate   dry-run: show what would change without touching the filesystem
#   --adopt      absorb existing files into the dotfiles repo before linking
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES=(zsh git config)
# ssh is intentionally excluded — ~/.ssh/config is machine-specific; manage it manually
STOW_FLAGS=(--restow)

for arg in "$@"; do
  case "$arg" in
    --simulate|--dry-run) STOW_FLAGS+=(--simulate) ;;
    --adopt)              STOW_FLAGS+=(--adopt) ;;
  esac
done

if ! command -v stow &>/dev/null; then
  echo "stow not found — run bootstrap first."
  exit 1
fi

stow --dir="$DOTFILES_DIR" --target="$HOME" --ignore='.DS_Store' "${STOW_FLAGS[@]}" "${PACKAGES[@]}"
echo "Stow complete: ${PACKAGES[*]}"

# ── exports.zsh — copy example if no live file yet ───────────────────────────
if [[ ! -f "$DOTFILES_DIR/zsh/exports.zsh" ]]; then
  cp "$DOTFILES_DIR/zsh/exports.zsh.example" "$DOTFILES_DIR/zsh/exports.zsh"
  echo "Created zsh/exports.zsh from example — fill in your secrets."
fi

# ── ~/.zshrc.local — seed from example if not present ────────────────────────
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "Created ~/.zshrc.local from example — add machine-specific config there."
fi
