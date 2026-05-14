#!/usr/bin/env bash
# Sensible macOS defaults for developers.
# MDM/Jamf note: settings marked [MDM-likely] are commonly managed by corporate
# MDM profiles and may be silently overridden after apply — that is expected.
set -euo pipefail

echo "Applying macOS defaults (requires sudo for some settings)..."

try() { "$@" 2>/dev/null || true; }

# ── Finder ────────────────────────────────────────────────────────────────────
try defaults write com.apple.finder AppleShowAllFiles YES
try defaults write com.apple.finder ShowPathbar -bool true
try defaults write com.apple.finder ShowStatusBar -bool true
try defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
try defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
try defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
try defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ── Dock [MDM-likely] ────────────────────────────────────────────────────────
try defaults write com.apple.dock autohide -bool true
try defaults write com.apple.dock autohide-delay -float 0
try defaults write com.apple.dock show-recents -bool false
try defaults write com.apple.dock tilesize -int 48

# ── Keyboard & input ──────────────────────────────────────────────────────────
try defaults write NSGlobalDomain KeyRepeat -int 2
try defaults write NSGlobalDomain InitialKeyRepeat -int 15
try defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
try defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
try defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
try defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ── Screenshots ───────────────────────────────────────────────────────────────
mkdir -p "$HOME/Desktop/Screenshots"
try defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
try defaults write com.apple.screencapture type -string "png"
try defaults write com.apple.screencapture disable-shadow -bool true

# ── Terminal / shell ──────────────────────────────────────────────────────────
try defaults write com.apple.terminal StringEncodings -array 4
sudo chsh -s /bin/zsh "$USER" 2>/dev/null || true

# ── Activity Monitor ──────────────────────────────────────────────────────────
try defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
try defaults write com.apple.ActivityMonitor ShowCategory -int 0

# ── Safari (dev extras — Safari sandbox may block on newer macOS) ─────────────
try defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
try defaults write com.apple.Safari IncludeDevelopMenu -bool true

# ── Misc ──────────────────────────────────────────────────────────────────────
try defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# [MDM-likely] TimeMachine and Quarantine are often MDM-controlled on managed
# machines — these will apply on personal machines and silently no-op via `try`
# on managed ones where MDM holds the policy lock.
try defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
try defaults write com.apple.LaunchServices LSQuarantine -bool false

# Restart affected apps
for app in "Finder" "Dock" "SystemUIServer"; do
  killall "$app" &>/dev/null || true
done

echo "macOS defaults applied. Some changes require a logout/reboot."
echo "Note: [MDM-likely] settings may be overridden by your organisation's MDM profile."
