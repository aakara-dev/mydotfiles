# ─────────────────────────────────────────────────────────────────────────────
#  aliases.zsh
# ─────────────────────────────────────────────────────────────────────────────

# ── Navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias dots='cd $DOTFILES'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias dev='cd ~/Development'

# ── ls / eza ──────────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -lah --icons --group-directories-first --git'
  alias ll='eza -lh --icons --group-directories-first --git'
  alias la='eza -a --icons'
  alias lt='eza --tree --icons --level=2'
  alias ltt='eza --tree --icons --level=3'
else
  alias ls='ls -G'
  alias l='ls -lahG'
  alias ll='ls -lhG'
  alias la='ls -aG'
fi

# ── bat ───────────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'
  alias man='batman'
fi

# ── grep / ripgrep ────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias rg='rg --smart-case'

# ── Editor ────────────────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'
alias zed='zed .'
alias sub='open -a "Sublime Text"'
alias pycharm='open -a "PyCharm"'

# ── Dotfiles management ──────────────────────────────────────────────────────
alias dotfiles='cd $DOTFILES && $EDITOR .'
alias zshrc='$EDITOR $DOTFILES/zsh/.zshrc'
alias aliases='$EDITOR $DOTFILES/zsh/aliases.zsh'
alias functions='$EDITOR $DOTFILES/zsh/functions.zsh'
alias exports='$EDITOR $DOTFILES/zsh/exports.zsh'
alias localrc='$EDITOR ~/.zshrc.local'
alias reload='source ~/.zshrc && echo "ZSH reloaded"'

# ── Git ───────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --all'
alias gll='git log --oneline -20'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grs='git restore'
alias gf='git fetch --all --prune'
alias gm='git merge'
alias lg='lazygit'

# ── GitHub / GitLab CLI ──────────────────────────────────────────────────────
alias ghpr='gh pr create'
alias ghprl='gh pr list'
alias ghprv='gh pr view'
alias glpr='glab mr create'
alias glprl='glab mr list'

# ── Azure ─────────────────────────────────────────────────────────────────────
alias azl='az login'
alias azlsp='az login --service-principal'
alias azs='az account show'
alias azsl='az account list --output table'
alias azset='az account set --subscription'
alias azrg='az group list --output table'
alias azvm='az vm list --output table'
alias azks='az aks list --output table'
alias azst='az storage account list --output table'

# ── Terraform ─────────────────────────────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply --auto-approve'
alias tfd='terraform destroy'
alias tfda='terraform destroy --auto-approve'
alias tfo='terraform output'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
alias tfsl='terraform state list'
alias tfss='terraform state show'
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
alias tg='terragrunt'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'

# ── Databricks ────────────────────────────────────────────────────────────────
alias dbr='databricks'
alias dbrj='databricks jobs'
alias dbrjl='databricks jobs list'
alias dbrjr='databricks jobs run-now'
alias dbrc='databricks clusters'
alias dbrcl='databricks clusters list'
alias dbrf='databricks fs'
alias dbrfl='databricks fs ls'

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k='kubectl'
alias kns='kubens'
alias kctx='kubectx'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmap'
alias kgsec='kubectl get secrets'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'
alias kpf='kubectl port-forward'
alias krr='kubectl rollout restart deployment'
alias krs='kubectl rollout status deployment'
alias ksc='kubectl scale --replicas'

# ── Docker ────────────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dcl='docker compose logs -f'
alias dcb='docker compose build'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dl='docker logs -f'
alias dsp='docker system prune -f'
alias dspa='docker system prune -af --volumes'
alias dv='docker volume ls'
alias dn='docker network ls'

# ── Python / uv ───────────────────────────────────────────────────────────────
alias py='python3'
alias python='python3'
alias pip='uv pip'
alias pipi='uv pip install'
alias pipir='uv pip install -r requirements.txt'
alias pipu='uv pip install --upgrade'
alias pipf='uv pip freeze'
alias venv='uv venv'
alias uvr='uv run'
alias uva='source .venv/bin/activate'
alias uvd='deactivate'

# ── Helm ──────────────────────────────────────────────────────────────────────
alias h='helm'
alias hl='helm list'
alias hla='helm list --all-namespaces'
alias hi='helm install'
alias hu='helm upgrade'
alias hui='helm upgrade --install'
alias hd='helm delete'
alias hr='helm repo'
alias hrlu='helm repo update'

# ── DigitalOcean ──────────────────────────────────────────────────────────────
alias dctl='doctl'
alias dok='doctl kubernetes'
alias dokc='doctl kubernetes cluster'
alias dokcl='doctl kubernetes cluster list'

# ── System ────────────────────────────────────────────────────────────────────
alias cls='clear'
alias c='clear'
alias q='exit'
alias path='echo -e ${PATH//:/\\n}'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s https://ifconfig.me && echo'
alias localip='ipconfig getifaddr en0'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias pubkey='cat ~/.ssh/id_ed25519.pub | pbcopy && echo "SSH public key copied to clipboard"'
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewupg='brew update && brew upgrade --greedy && brew cleanup'
alias brewcheck='brew bundle check --file=$DOTFILES/Brewfile'
alias brewdump='brew bundle dump --file=$DOTFILES/Brewfile --force && echo "Brewfile updated"'
alias brewclean='$DOTFILES/scripts/uninstall.sh'
alias top='htop'
alias df='df -h'
alias du='du -sh'
alias free='vm_stat | perl -ne "/page size of (\d+)/ and \$s=\$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf(\"%-20s % 10.2f MB\n\",\$1,\$2*\$s/1048576);"'

# ── Network / SSH ─────────────────────────────────────────────────────────────
alias ssha='eval $(ssh-agent -s) && ssh-add ~/.ssh/id_ed25519'
alias pingcheck='ping -c 5 8.8.8.8'
alias sshconfig='$EDITOR ~/.ssh/config'

# ── Clipboard ─────────────────────────────────────────────────────────────────
alias copy='pbcopy'
alias paste='pbpaste'

# ── JSON / YAML ───────────────────────────────────────────────────────────────
alias jqp='jq . | bat -l json'
alias yqp='yq . | bat -l yaml'

# ── Misc dev ─────────────────────────────────────────────────────────────────
alias serve='python3 -m http.server 8080'
alias jwt-decode='python3 -c "import sys,base64,json; parts=sys.argv[1].split(\".\"); print(json.dumps(json.loads(base64.b64decode(parts[1]+\"==\").decode()),indent=2))"'
alias urlencode='python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))"'
alias timestamp='date +%s'
alias dateutc='date -u "+%Y-%m-%dT%H:%M:%SZ"'
alias week='date +%V'
