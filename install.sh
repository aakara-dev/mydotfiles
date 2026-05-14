#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YELLOW='\033[1;33m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

info()    { echo -e "${YELLOW}  [info]${NC}  $*"; }
success() { echo -e "${GREEN}  [ok]${NC}    $*"; }
error()   { echo -e "${RED}  [err]${NC}   $*" >&2; }

echo ""
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo ""

STEPS=("bootstrap" "link" "macos")

# ── Check mode: dry-run without making any changes ───────────────────────────
if [[ "${1:-all}" == "check" ]]; then
  info "Checking Brewfile packages (no install)..."
  brew bundle check --file="$DOTFILES_DIR/Brewfile" \
    && success "All Brewfile packages installed" \
    || info "Some packages missing — run: ./install.sh bootstrap"

  if [[ -f "$DOTFILES_DIR/Brewfile.local" ]]; then
    info "Checking Brewfile.local packages..."
    brew bundle check --file="$DOTFILES_DIR/Brewfile.local" \
      && success "All Brewfile.local packages installed" \
      || info "Some local packages missing — run: ./install.sh bootstrap"
  else
    info "No Brewfile.local — copy Brewfile.local.example to add machine-specific packages."
  fi

  info "Simulating symlink step (no changes)..."
  bash "$DOTFILES_DIR/scripts/link.sh" --simulate \
    && success "Symlinks look clean" \
    || error "Stow conflicts detected — resolve before running: ./install.sh link"

  exit 0
fi

for step in "${STEPS[@]}"; do
  if [[ "${1:-all}" == "all" || "${1:-all}" == "$step" ]]; then
    info "Running step: $step"
    bash "$DOTFILES_DIR/scripts/$step.sh" && success "Done: $step" || error "Failed: $step"
  fi
done

success "Dotfiles installed. Restart your terminal or run: source ~/.zshrc"
