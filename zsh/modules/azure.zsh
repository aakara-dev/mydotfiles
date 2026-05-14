# azure.zsh — Azure CLI configuration and completions

# ── az completions ────────────────────────────────────────────────────────────
if command -v az &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit 2>/dev/null
  source /opt/homebrew/etc/bash_completion.d/az 2>/dev/null || true
fi

# ── Azure defaults ────────────────────────────────────────────────────────────
export AZURE_CORE_COLLECT_TELEMETRY=false
export AZURE_CORE_OUTPUT=table          # Default output format (override with -o)

# ── Terraform Azure provider ─────────────────────────────────────────────────
# ARM_* vars are read from exports.zsh
