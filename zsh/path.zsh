# PATH construction — order matters (first match wins)

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

typeset -U path  # deduplicate

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"                          # Rust
  "$HOME/.uv/bin"                             # uv managed tools
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/opt/homebrew/opt/python@3.12/bin"
  "/opt/homebrew/opt/postgresql@16/bin"
  "/opt/homebrew/opt/mysql-client/bin"
  "$HOME/.pyenv/bin"
  "$HOME/.pyenv/shims"
  "$HOME/go/bin"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  $path
)

export PATH
