# ~/.zshrc — sourced by ~/.mydotfiles/scripts/link.sh
# Modular dotfiles: ~/.mydotfiles/zsh/

export DOTFILES="$HOME/.mydotfiles"

# ── Oh-my-zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  ssh-agent
  docker
  docker-compose
  kubectl
  helm
  terraform
  python
  pip
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-bat
)
# zoxide and direnv are initialized below via eval — not as omz plugins
# uv has no omz plugin; completions are loaded in zsh/modules/python.zsh

source "$ZSH/oh-my-zsh.sh" 2>/dev/null || true

# ── Load modules ──────────────────────────────────────────────────────────────
_load() { [[ -f "$1" ]] && source "$1"; }

_load "$HOME/.config/zsh/exports.zsh"          # Secrets & env vars (gitignored)
_load "$HOME/.config/zsh/path.zsh"             # PATH construction
_load "$HOME/.config/zsh/aliases.zsh"          # Aliases
_load "$HOME/.config/zsh/functions.zsh"        # Shell functions

_load "$HOME/.config/zsh/modules/git.zsh"
_load "$HOME/.config/zsh/modules/python.zsh"
_load "$HOME/.config/zsh/modules/azure.zsh"
_load "$HOME/.config/zsh/modules/databricks.zsh"
_load "$HOME/.config/zsh/modules/kubernetes.zsh"
_load "$HOME/.config/zsh/modules/terraform.zsh"
_load "$HOME/.config/zsh/modules/docker.zsh"
_load "$HOME/.config/zsh/modules/digitalocean.zsh"

# ── Completions ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── fzf ───────────────────────────────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ── zoxide (smarter cd) ───────────────────────────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── direnv ────────────────────────────────────────────────────────────────────
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ── Starship prompt ───────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY

# ── Local overrides (machine-specific, not committed) ─────────────────────────
_load "$HOME/.zshrc.local"

. "$HOME/.local/share/../bin/env"
