#!/usr/bin/env bash
# Removes packages no longer listed in Brewfile, then purges the Homebrew cache.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

# ── Dry-run mode ─────────────────────────────────────────────────────────────
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "Dry-run mode — no changes will be made."
fi

# ── Show what would be removed ───────────────────────────────────────────────
echo "Packages installed via Homebrew but NOT in Brewfile:"
brew bundle cleanup --file="$BREWFILE"

if $DRY_RUN; then
  echo ""
  echo "Run without --dry-run to actually remove them and clean the cache."
  exit 0
fi

# ── Confirm before proceeding ────────────────────────────────────────────────
echo ""
read -r -p "Remove the above packages and purge the Homebrew cache? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ── Remove unlisted packages ─────────────────────────────────────────────────
echo "Removing packages not in Brewfile..."
brew bundle cleanup --file="$BREWFILE" --force

# ── Purge Homebrew cache ─────────────────────────────────────────────────────
echo "Cleaning Homebrew cache..."
brew cleanup --prune=all

echo "Done."
