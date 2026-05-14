# ─────────────────────────────────────────────────────────────────────────────
#  functions.zsh — reusable shell functions
# ─────────────────────────────────────────────────────────────────────────────

# ── File system ───────────────────────────────────────────────────────────────

# mkdir and cd into it
mkcd() { mkdir -p "$@" && cd "$_"; }

# Search and cd into a directory with fzf
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
}

# Find a file and open in editor
fvim() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always {}') && ${EDITOR:-nvim} "$file"
}

# Quick extract — handles many archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)  tar xjf "$1"  ;;
      *.tar.gz)   tar xzf "$1"  ;;
      *.tar.xz)   tar xJf "$1"  ;;
      *.bz2)      bunzip2 "$1"  ;;
      *.rar)      unrar x "$1"  ;;
      *.gz)       gunzip "$1"   ;;
      *.tar)      tar xf "$1"   ;;
      *.tbz2)     tar xjf "$1"  ;;
      *.tgz)      tar xzf "$1"  ;;
      *.zip)      unzip "$1"    ;;
      *.Z)        uncompress "$1" ;;
      *.7z)       7z x "$1"    ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ── Git ───────────────────────────────────────────────────────────────────────

# Interactive branch switcher using fzf (named fbr to avoid conflict with omz git plugin's gbr alias)
fbr() {
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //' | sed 's#remotes/[^/]*/##' | \
    sort -u | fzf --ansi) && git checkout "$branch"
}

# Create and push a new branch
gnew() {
  [[ -z "$1" ]] && { echo "Usage: gnew <branch-name>"; return 1; }
  git checkout -b "$1" && git push -u origin "$1"
}

# Delete merged local branches (renamed from gclean — omz git plugin owns that alias)
gprune() {
  git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Git log with fzf preview (renamed from glog — omz git plugin owns that alias)
flog() {
  git log --oneline --color=always | \
    fzf --ansi --no-sort --reverse --preview 'git show --color=always {1}' | \
    awk '{print $1}' | xargs -I{} git show {}
}

# Show which files changed between branches
gdiff() {
  git diff "${1:-main}...${2:-HEAD}" --name-only
}

# ── Azure ─────────────────────────────────────────────────────────────────────

# Switch Azure subscription interactively
azswitch() {
  local sub
  sub=$(az account list --query '[].{name:name,id:id}' -o tsv 2>/dev/null | \
    fzf --prompt="Select subscription: " | awk '{print $2}')
  [[ -n "$sub" ]] && az account set --subscription "$sub" && az account show --query name -o tsv
}

# Get a resource's details (fuzzy pick resource group then resource)
azget() {
  local rg resource
  rg=$(az group list --query '[].name' -o tsv | fzf --prompt="Resource group: ")
  [[ -z "$rg" ]] && return 1
  resource=$(az resource list -g "$rg" --query '[].{name:name,type:type}' -o tsv | \
    fzf --prompt="Resource: " | awk '{print $1}')
  [[ -n "$resource" ]] && az resource show -g "$rg" -n "$resource" --resource-type \
    "$(az resource list -g "$rg" --query "[?name=='$resource'].type" -o tsv)"
}

# Print current Azure context
azwho() {
  echo "Account : $(az account show --query name -o tsv 2>/dev/null || echo 'not logged in')"
  echo "Sub ID  : $(az account show --query id -o tsv 2>/dev/null)"
  echo "Tenant  : $(az account show --query tenantId -o tsv 2>/dev/null)"
}

# ── Kubernetes ────────────────────────────────────────────────────────────────

# Switch k8s context interactively
kswitch() {
  local ctx
  ctx=$(kubectl config get-contexts -o name | fzf --prompt="Context: ")
  [[ -n "$ctx" ]] && kubectl config use-context "$ctx"
}

# Get all pods and their statuses with fzf
kpods() {
  local ns="${1:---all-namespaces}"
  kubectl get pods $ns -o wide | fzf --header-lines=1
}

# Tail logs from a pod picked with fzf
klogs() {
  local ns="${1:-default}"
  local pod
  pod=$(kubectl get pods -n "$ns" -o name | sed 's|pod/||' | fzf --prompt="Pod: ")
  [[ -n "$pod" ]] && kubectl logs -f -n "$ns" "$pod"
}

# Port-forward a service picked with fzf
kfwd() {
  local ns="${1:-default}" local_port="${2:-8080}"
  local svc
  svc=$(kubectl get svc -n "$ns" -o name | sed 's|service/||' | fzf --prompt="Service: ")
  local svc_port
  svc_port=$(kubectl get svc -n "$ns" "$svc" -o jsonpath='{.spec.ports[0].port}')
  [[ -n "$svc" ]] && kubectl port-forward -n "$ns" "svc/$svc" "${local_port}:${svc_port}"
}

# Watch pods in a namespace
kwatch() { watch -n 2 kubectl get pods -n "${1:-default}" -o wide; }

# ── Docker ────────────────────────────────────────────────────────────────────

# Exec into a container picked with fzf
dsh() {
  local container shell="${1:-/bin/sh}"
  container=$(docker ps --format '{{.Names}}' | fzf --prompt="Container: ")
  [[ -n "$container" ]] && docker exec -it "$container" "$shell"
}

# Remove all stopped containers and dangling images
dclean() {
  docker container prune -f
  docker image prune -f
  echo "Cleaned stopped containers and dangling images."
}

# ── Terraform ─────────────────────────────────────────────────────────────────

# Switch terraform workspace interactively
tfwswitch() {
  local ws
  ws=$(terraform workspace list | tr -d ' *' | fzf --prompt="Workspace: ")
  [[ -n "$ws" ]] && terraform workspace select "$ws"
}

# Init, plan, apply shortcut with confirmation
tfup() {
  terraform init && terraform plan -out=tfplan && \
    read -r "?Apply this plan? [y/N] " confirm && \
    [[ "$confirm" =~ ^[Yy]$ ]] && terraform apply tfplan
}

# ── Python / uv ───────────────────────────────────────────────────────────────

# Create a new uv project with Python 3.12
pynew() {
  local name="${1:?Usage: pynew <project-name>}"
  uv init "$name" && cd "$name" && uv venv --python 3.12 && source .venv/bin/activate
  echo "Project $name ready. Python: $(python --version)"
}

# Activate the nearest .venv (walks up directory tree)
va() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.venv/bin/activate" ]]; then
      source "$dir/.venv/bin/activate"
      echo "Activated: $dir/.venv"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo "No .venv found in current or parent directories."
}

# Run a script in a temporary uv environment
uvx-run() {
  local pkg="${1:?Usage: uvx-run <package> [args...]}"
  shift
  uv tool run "$pkg" "$@"
}

# ── Databricks ────────────────────────────────────────────────────────────────

# Set Databricks profile interactively
dbrprofile() {
  local profile
  profile=$(databricks auth profiles 2>/dev/null | tail -n +2 | awk '{print $1}' | \
    fzf --prompt="Databricks profile: ")
  [[ -n "$profile" ]] && export DATABRICKS_CONFIG_PROFILE="$profile" && \
    echo "Active profile: $profile"
}

# ── SSH ───────────────────────────────────────────────────────────────────────

# Interactive SSH host picker from ~/.ssh/config
sshi() {
  local host
  host=$(grep -E "^Host " ~/.ssh/config 2>/dev/null | awk '{print $2}' | \
    grep -v '\*' | fzf --prompt="SSH host: ")
  [[ -n "$host" ]] && ssh "$host"
}

# Generate a new ed25519 SSH key
ssh-newkey() {
  local name="${1:?Usage: ssh-newkey <name> [comment]}"
  local comment="${2:-$name@$(hostname)}"
  ssh-keygen -t ed25519 -C "$comment" -f "$HOME/.ssh/$name"
  echo "Key created: ~/.ssh/$name"
  echo "Public key:"
  cat "$HOME/.ssh/$name.pub"
}

# ── Networking ────────────────────────────────────────────────────────────────

# Check if a host/port is reachable
check-port() {
  local host="${1:?Usage: check-port <host> <port>}" port="${2:?}"
  nc -zv "$host" "$port" 2>&1 && echo "OPEN" || echo "CLOSED"
}

# Show listening ports grouped
listening() {
  lsof -iTCP -sTCP:LISTEN -P -n | awk 'NR>1 {print $1, $9}' | sort -u | column -t
}

# ── Utility ───────────────────────────────────────────────────────────────────

# Decode a base64 string
b64d() { echo "$1" | base64 --decode; echo; }

# Encode a string to base64
b64e() { echo -n "$1" | base64; }

# Pretty-print JSON from clipboard or pipe
jsonpp() {
  if [[ -t 0 ]]; then
    pbpaste | jq . | bat -l json
  else
    jq . | bat -l json
  fi
}

# Create a .env file from a template
envcp() {
  local src="${1:-.env.example}" dst="${2:-.env}"
  [[ -f "$dst" ]] && { echo "$dst already exists. Skipping."; return 1; }
  cp "$src" "$dst" && echo "Created $dst from $src"
}

# Quick HTTP server in current directory
httpserver() {
  local port="${1:-8080}"
  echo "Serving $(pwd) at http://localhost:${port}"
  python3 -m http.server "$port"
}

# Show disk usage sorted by size
dusort() { du -sh "${1:-.}"/* | sort -rh | head -20; }

# Calculator
calc() { python3 -c "import math; print($*)"; }

# Repeat a command N times
repeat-cmd() {
  local n="${1:?Usage: repeat-cmd <n> <command...>}"
  shift
  for ((i=1; i<=n; i++)); do
    echo "--- Run $i/$n ---"
    "$@"
  done
}

# Show the dotfiles help/summary
dothelp() {
  bat "$DOTFILES/README.md" 2>/dev/null || cat "$DOTFILES/README.md"
}
