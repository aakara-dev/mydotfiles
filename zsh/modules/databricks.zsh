# databricks.zsh — Databricks CLI configuration

# ── Databricks completions ────────────────────────────────────────────────────
if command -v databricks &>/dev/null; then
  eval "$(databricks completion zsh)" 2>/dev/null || true
fi

# ── Config location ───────────────────────────────────────────────────────────
export DATABRICKS_CONFIG_FILE="${DATABRICKS_CONFIG_FILE:-$HOME/.databrickscfg}"

# DATABRICKS_HOST and DATABRICKS_TOKEN come from exports.zsh
# Use DATABRICKS_CONFIG_PROFILE to switch named profiles:
# export DATABRICKS_CONFIG_PROFILE="dev"
