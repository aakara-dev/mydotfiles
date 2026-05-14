# kubernetes.zsh — kubectl, helm, k9s, kubectx

# ── kubectl completions ───────────────────────────────────────────────────────
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh 2>/dev/null) 2>/dev/null
  compdef k=kubectl
fi

# ── helm completions ─────────────────────────────────────────────────────────
command -v helm &>/dev/null && source <(helm completion zsh 2>/dev/null) 2>/dev/null

# ── kubeseal completions ─────────────────────────────────────────────────────
command -v kubeseal &>/dev/null && source <(kubeseal completion zsh 2>/dev/null) 2>/dev/null

# ── KUBECONFIG — merge multiple configs ────────────────────────────────────────
# Add additional kubeconfig files here separated by ':'
# export KUBECONFIG="$HOME/.kube/config:$HOME/.kube/config-aks-dev"

export KUBE_EDITOR="${EDITOR:-nvim}"

# ── k9s config ───────────────────────────────────────────────────────────────
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# ── kubectx / kubens completions ─────────────────────────────────────────────
# Installed via Homebrew, completions picked up automatically.
