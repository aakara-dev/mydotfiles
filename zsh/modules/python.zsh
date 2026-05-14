# python.zsh — Python, uv, pyenv

# ── pyenv ─────────────────────────────────────────────────────────────────────
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# ── uv shell completions ───────────────────────────────────────────────────────
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)" 2>/dev/null

# ── Virtual env prompt indicator (when not using Starship) ────────────────────
export VIRTUAL_ENV_DISABLE_PROMPT=1

# ── pip config — use uv by default ────────────────────────────────────────────
export PIP_REQUIRE_VIRTUALENV=true       # Prevent pip installs outside venv
export UV_SYSTEM_PYTHON=false

# ── Auto-activate .venv when entering a directory ─────────────────────────────
_auto_activate_venv() {
  if [[ -f ".venv/bin/activate" ]]; then
    if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
      source ".venv/bin/activate"
    fi
  elif [[ -n "$VIRTUAL_ENV" ]] && [[ "$PWD" != "$VIRTUAL_ENV"* ]]; then
    deactivate 2>/dev/null || true
  fi
}
add-zsh-hook chpwd _auto_activate_venv
autoload -U add-zsh-hook
