# terraform.zsh — Terraform and Terragrunt

# ── terraform completions ────────────────────────────────────────────────────
if command -v terraform &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit 2>/dev/null
  complete -o nospace -C "$(command -v terraform)" terraform
fi

# ── Plugin cache — shared across all projects ─────────────────────────────────
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
[[ -d "$TF_PLUGIN_CACHE_DIR" ]] || mkdir -p "$TF_PLUGIN_CACHE_DIR"

# ── Terragrunt ───────────────────────────────────────────────────────────────
export TERRAGRUNT_DOWNLOAD="$HOME/.terragrunt-cache"
