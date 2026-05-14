# dotfiles

Modular, git-tracked dotfiles for macOS (Apple Silicon) — built for Python, Azure, Kubernetes, CI/CD, Databricks, and Data Engineering workflows.

---

## Table of contents

- [Directory structure](#directory-structure)
- [Setup — new machine](#setup--new-machine)
- [Setup — existing machine](#setup--existing-machine)
- [Setup — Jamf-managed work machine](#setup--jamf-managed-work-machine)
- [install.sh reference](#installsh-reference)
- [Homebrew management](#homebrew-management)
- [Machine-local config](#machine-local-config)
- [exports.zsh — environment variables](#exportszsh--environment-variables)
- [Aliases](#aliases)
- [Functions](#functions)
- [Shell modules](#shell-modules)
- [Git config](#git-config)
- [SSH config](#ssh-config)
- [Starship prompt](#starship-prompt)
- [Adding a new tool](#adding-a-new-tool)
- [Maintenance](#maintenance)

---

## Directory structure

```
~/.mydotfiles/
├── install.sh                  # Entry point — runs bootstrap → link → macos
├── Brewfile                    # Shared Homebrew packages and casks
├── Brewfile.local.example      # Template for machine-specific packages (container runtime etc.)
├── .gitignore
│
├── scripts/
│   ├── bootstrap.sh            # Installs Homebrew, oh-my-zsh, plugins, Brewfile packages
│   ├── link.sh                 # Symlinks dotfiles into $HOME via GNU Stow
│   ├── macos.sh                # Applies sensible macOS defaults
│   └── uninstall.sh            # Removes packages not in Brewfile and purges brew cache
│
├── zsh/
│   ├── .zshrc                  # Main shell entry point — sources all modules below
│   ├── path.zsh                # PATH construction (Homebrew, pyenv, cargo, uv, go …)
│   ├── aliases.zsh             # All aliases grouped by tool
│   ├── functions.zsh           # Interactive shell functions (fzf pickers, helpers …)
│   ├── exports.zsh.example     # Committed env-var template
│   ├── exports.zsh             # YOUR secrets and env vars — gitignored, fill this in
│   ├── .zshrc.local.example    # Template for machine-specific shell config
│   └── modules/
│       ├── git.zsh             # Git editor, delta pager, gh/glab completions
│       ├── python.zsh          # pyenv init, uv completions, venv auto-activate
│       ├── azure.zsh           # az completions, telemetry off, default output format
│       ├── databricks.zsh      # databricks completions, config path
│       ├── kubernetes.zsh      # kubectl/helm/kubeseal completions, KUBE_EDITOR
│       ├── terraform.zsh       # terraform completions, plugin cache, terragrunt cache
│       ├── docker.zsh          # BuildKit env vars, Docker Desktop completions
│       └── digitalocean.zsh    # doctl completions
│
├── git/
│   ├── .gitconfig              # Git identity, delta diffs, aliases, pull/push defaults
│   └── .gitignore_global       # Global gitignore (macOS, editors, Terraform, Python …)
│
├── ssh/
│   └── config.example          # SSH config template — copy to ~/.ssh/config manually
│
└── config/
    └── starship.toml           # Starship prompt config
```

---

## Setup — new machine

```bash
# 1. Clone
git clone git@github.com:YOURUSER/dotfiles.git ~/.mydotfiles
cd ~/.mydotfiles
chmod +x install.sh scripts/*.sh

# 2. Create your machine-local package file (pick container runtime)
cp Brewfile.local.example Brewfile.local
# Edit Brewfile.local — uncomment docker-desktop or rancher

# 3. Full install (bootstrap → link → macos)
./install.sh all

# 4. Fill in your secrets
$EDITOR zsh/exports.zsh           # tokens, subscription IDs, etc.
$EDITOR ~/.zshrc.local            # directory aliases, kubectl context, az subscription

# 5. SSH setup
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cp ssh/config.example ~/.ssh/config
chmod 600 ~/.ssh/config
$EDITOR ~/.ssh/config             # replace placeholder hosts/IPs

# 6. Reload
source ~/.zshrc
```

---

## Setup — existing machine

On an existing machine your dotfiles (`~/.zshrc`, `~/.gitconfig`, etc.) exist as regular
files. Stow will refuse to overwrite them without `--adopt`, which first moves them into
the repo so you can diff and keep what you want.

```bash
cd ~/.mydotfiles
chmod +x install.sh scripts/*.sh

# Step 1 — dry-run: see what's missing and what would conflict
./install.sh check

# Step 2 — adopt existing dotfiles into the repo, then symlink
./scripts/link.sh --adopt

# Step 3 — diff to make sure your existing configs weren't lost
git diff

# Step 4 — if everything looks good, install missing packages
./install.sh bootstrap

# Step 5 — apply macOS defaults (safe to skip if you prefer your current settings)
./install.sh macos

# Step 6 — reload
source ~/.zshrc
```

> **What `--adopt` does:** Stow moves the existing file (e.g. `~/.zshrc`) into the
> dotfiles package dir and creates a symlink in its place. If the existing file differs
> from the one in the repo, `git diff` will show the difference — commit or discard as
> needed before pushing.

---

## Setup — Jamf-managed work machine

Jamf manages certain apps and system settings centrally. This setup is designed to be
safe: every `defaults write` is wrapped in `|| true`, and `brew bundle` skips packages
that are already installed or blocked by policy.

```bash
cd ~/.mydotfiles
chmod +x install.sh scripts/*.sh

# 1. Dry-run first
./install.sh check

# 2. Create a work-specific local Brewfile
cp Brewfile.local.example Brewfile.local
# Edit Brewfile.local:
#   - Pick rancher (or docker-desktop if IT allows it)
#   - Comment out any casks Jamf already installs (Chrome, Zoom, Slack, etc.)

# 3. Install packages (brew skips Jamf-managed ones gracefully)
./install.sh bootstrap

# 4. Link dotfiles
./scripts/link.sh --adopt
git diff                          # review any conflicts

# 5. Apply macOS defaults
#    Settings marked [MDM-likely] in macos.sh may be overridden by your MDM profile.
#    Running macos.sh is still safe — it won't break anything.
./install.sh macos

# 6. Machine-local config
$EDITOR ~/.zshrc.local            # set your work az subscription, kubectl context, etc.
source ~/.zshrc
```

**Casks that may be Jamf-managed on your work machine:**

| Cask | Note |
|---|---|
| `google-chrome` | Often pre-deployed by IT |
| `rectangle` | Requires Accessibility — needs PPPC profile from IT |
| `alt-tab` | Requires Accessibility — needs PPPC profile from IT |
| `whatsapp` / `telegram` | Personal-only; comment these out in `Brewfile.local` |

---

## install.sh reference

```
Usage: ./install.sh [command]
```

| Command | What it does |
|---|---|
| `./install.sh` or `./install.sh all` | Full install: bootstrap → link → macos |
| `./install.sh check` | Dry-run: checks brew packages + simulates stow, no changes made |
| `./install.sh bootstrap` | Homebrew, oh-my-zsh, plugins, Brewfile + Brewfile.local packages |
| `./install.sh link` | Symlinks dotfiles into `$HOME` via stow |
| `./install.sh macos` | Applies macOS `defaults write` settings |

### scripts/link.sh flags

| Flag | Effect |
|---|---|
| _(none)_ | Restow packages — refreshes symlinks, errors on conflicts |
| `--simulate` | Dry-run — shows what would change, nothing is written |
| `--adopt` | Absorbs existing files into the repo before linking (use on first run on existing machines) |

### scripts/uninstall.sh

Removes Homebrew packages that are no longer in the Brewfile and purges the cache.

```bash
./scripts/uninstall.sh             # interactive — lists and confirms removals
./scripts/uninstall.sh --dry-run   # shows what would be removed without doing it
```

---

## Homebrew management

### Brew aliases

| Alias | Command | When to use |
|---|---|---|
| `brewup` | `brew update && brew upgrade && brew cleanup` | Update formulae only |
| `brewupg` | `brew update && brew upgrade --greedy && brew cleanup` | Update everything including auto-update casks |
| `brewcheck` | `brew bundle check --file=$DOTFILES/Brewfile` | See which Brewfile packages are not installed |
| `brewdump` | `brew bundle dump --file=$DOTFILES/Brewfile --force` | Overwrite Brewfile with currently installed packages |
| `brewclean` | `./scripts/uninstall.sh` | Remove packages not in Brewfile |

### Machine-specific packages (Brewfile.local)

`Brewfile.local` is gitignored — each machine has its own copy.

```bash
cp Brewfile.local.example Brewfile.local
$EDITOR Brewfile.local
```

`bootstrap.sh` automatically picks it up if present. Use it for:
- Container runtime: `docker-desktop` or `rancher`
- Work-machine additions or exclusions
- Any app you only want on one machine

---

## Machine-local config

Two gitignored files hold everything that varies between machines:

### `~/.zshrc.local`

Sourced last by `.zshrc` — can override anything. Created from `zsh/.zshrc.local.example`
on first `./install.sh link`. Edit it with the `localrc` alias.

```zsh
# ~/.zshrc.local  — machine-specific, never committed

# Azure default subscription
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 2>/dev/null

# kubectl default context / namespace
kubectl config use-context my-cluster 2>/dev/null
kubectl config set-context --current --namespace my-namespace 2>/dev/null

# Directory shortcuts
alias proj='cd ~/Work/my-project'
alias infra='cd ~/Work/infra'

# Machine-specific env vars
export WORK_EMAIL="you@company.com"
```

| Alias | Opens |
|---|---|
| `localrc` | `~/.zshrc.local` in `$EDITOR` |

### `zsh/exports.zsh`

Holds secrets and personal env vars. Created from `exports.zsh.example` automatically.
Edit with the `exports` alias. See [exports.zsh reference](#exportszsh--environment-variables) below.

---

## exports.zsh — environment variables

`zsh/exports.zsh` is gitignored. `exports.zsh.example` is the committed template.
Fill in your values after cloning:

```bash
exports    # opens zsh/exports.zsh in $EDITOR
```

| Variable | Purpose |
|---|---|
| `EDITOR` / `VISUAL` | Default editor (`nvim`) |
| `PAGER` | Default pager (`bat`) |
| `LANG` / `LC_ALL` | Locale (`en_US.UTF-8`) |
| `XDG_CONFIG_HOME` | `~/.config` |
| **Azure** | |
| `AZURE_SUBSCRIPTION_ID` | Default subscription UUID |
| `AZURE_TENANT_ID` | Azure AD tenant UUID |
| `AZURE_CLIENT_ID` | Service principal app ID (optional) |
| `AZURE_CLIENT_SECRET` | Service principal secret (optional) |
| `ARM_SUBSCRIPTION_ID` | Mirrors `AZURE_SUBSCRIPTION_ID` for Terraform |
| `ARM_TENANT_ID` | Mirrors `AZURE_TENANT_ID` for Terraform |
| **Databricks** | |
| `DATABRICKS_HOST` | Workspace URL (`https://adb-XXX.azuredatabricks.net`) |
| `DATABRICKS_TOKEN` | Personal access token |
| `DATABRICKS_CONFIG_FILE` | Config file path (default `~/.databrickscfg`) |
| **Terraform** | |
| `TF_LOG` | Log level (`DEBUG` \| `INFO` \| `WARN` \| `ERROR`) |
| `TF_LOG_PATH` | Log output path |
| **Python** | |
| `UV_PYTHON` | Default Python version for uv (`3.12`) |
| `PYENV_ROOT` | pyenv installation root |
| `PIP_REQUIRE_VIRTUALENV` | Prevent bare `pip install` outside a venv |
| `PYTHONDONTWRITEBYTECODE` | Suppress `.pyc` files |
| **Docker** | |
| `DOCKER_BUILDKIT` | Enable BuildKit (`1`) |
| `COMPOSE_DOCKER_CLI_BUILD` | Use BuildKit for Compose (`1`) |
| `DOCKER_SCAN_SUGGEST` | Suppress upgrade nag (`false`) |
| **Kubernetes** | |
| `KUBE_EDITOR` | Editor used by `kubectl edit` (`nvim`) |
| `KUBECONFIG` | Colon-separated list of kubeconfig files (set in `.zshrc.local`) |
| **Git / VCS** | |
| `GITHUB_TOKEN` | Used by `gh` CLI |
| `GITLAB_TOKEN` | Used by `glab` CLI |
| **DigitalOcean** | |
| `DIGITALOCEAN_TOKEN` | Used by `doctl` |
| **SSH / GPG** | |
| `SSH_KEY_PATH` | Default key path (`~/.ssh/id_ed25519`) |
| `GPG_TTY` | Required for GPG signing in terminal |

---

## Aliases

### Navigation

| Alias | Expands to |
|---|---|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `~` | `cd ~` |
| `-` | `cd -` (previous directory) |
| `dots` | `cd $DOTFILES` |
| `dl` | `cd ~/Downloads` |
| `dt` | `cd ~/Desktop` |
| `dev` | `cd ~/Development` |

### File listing (eza)

| Alias | Description |
|---|---|
| `ls` | eza with icons, directories first |
| `l` | Long list with git status, icons, hidden files |
| `ll` | Long list with git status, icons (no hidden) |
| `la` | All files with icons |
| `lt` | Tree view, 2 levels |
| `ltt` | Tree view, 3 levels |

Falls back to standard `ls -G` flags if eza is not installed.

### bat

| Alias | Description |
|---|---|
| `cat` | `bat --paging=never` (syntax-highlighted, no pager) |
| `catp` | `bat` (with pager) |
| `man` | `batman` (man pages via bat) |

### Dotfiles management

| Alias | Description |
|---|---|
| `dotfiles` | Open dotfiles dir in `$EDITOR` |
| `zshrc` | Edit `.zshrc` |
| `aliases` | Edit `aliases.zsh` |
| `functions` | Edit `functions.zsh` |
| `exports` | Edit `exports.zsh` (secrets) |
| `localrc` | Edit `~/.zshrc.local` (machine-specific) |
| `reload` | `source ~/.zshrc` |

### Homebrew

| Alias | Command |
|---|---|
| `brewup` | `brew update && brew upgrade && brew cleanup` |
| `brewupg` | `brew update && brew upgrade --greedy && brew cleanup` |
| `brewcheck` | `brew bundle check --file=$DOTFILES/Brewfile` |
| `brewdump` | Overwrite Brewfile with currently installed packages |
| `brewclean` | Run `uninstall.sh` (removes packages not in Brewfile) |

### Git

| Alias | Command |
|---|---|
| `g` | `git` |
| `gs` | `git status -sb` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gc` | `git commit -v` |
| `gcm` | `git commit -m` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gl` | `git log --oneline --graph --decorate --all` |
| `gll` | `git log --oneline -20` |
| `gp` | `git push` |
| `gpf` | `git push --force-with-lease` |
| `gpl` | `git pull --rebase` |
| `gst` | `git stash` |
| `gstp` | `git stash pop` |
| `gstl` | `git stash list` |
| `grb` | `git rebase` |
| `grbi` | `git rebase -i` |
| `grs` | `git restore` |
| `gf` | `git fetch --all --prune` |
| `gm` | `git merge` |
| `lg` | `lazygit` (TUI git client) |

### GitHub / GitLab

| Alias | Command |
|---|---|
| `ghpr` | `gh pr create` |
| `ghprl` | `gh pr list` |
| `ghprv` | `gh pr view` |
| `glpr` | `glab mr create` |
| `glprl` | `glab mr list` |

### Azure

| Alias | Command |
|---|---|
| `azl` | `az login` |
| `azlsp` | `az login --service-principal` |
| `azs` | `az account show` |
| `azsl` | `az account list --output table` |
| `azset` | `az account set --subscription` |
| `azrg` | `az group list --output table` |
| `azvm` | `az vm list --output table` |
| `azks` | `az aks list --output table` |
| `azst` | `az storage account list --output table` |

### Terraform / Terragrunt

| Alias | Command |
|---|---|
| `tf` | `terraform` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |
| `tfaa` | `terraform apply --auto-approve` |
| `tfd` | `terraform destroy` |
| `tfda` | `terraform destroy --auto-approve` |
| `tfo` | `terraform output` |
| `tfv` | `terraform validate` |
| `tff` | `terraform fmt -recursive` |
| `tfsl` | `terraform state list` |
| `tfss` | `terraform state show` |
| `tfw` | `terraform workspace` |
| `tfwl` | `terraform workspace list` |
| `tfws` | `terraform workspace select` |
| `tg` | `terragrunt` |
| `tgp` | `terragrunt plan` |
| `tga` | `terragrunt apply` |

### Databricks

| Alias | Command |
|---|---|
| `dbr` | `databricks` |
| `dbrj` | `databricks jobs` |
| `dbrjl` | `databricks jobs list` |
| `dbrjr` | `databricks jobs run-now` |
| `dbrc` | `databricks clusters` |
| `dbrcl` | `databricks clusters list` |
| `dbrf` | `databricks fs` |
| `dbrfl` | `databricks fs ls` |

### Kubernetes

| Alias | Command |
|---|---|
| `k` | `kubectl` |
| `kns` | `kubens` (switch namespace) |
| `kctx` | `kubectx` (switch context) |
| `kg` | `kubectl get` |
| `kgp` | `kubectl get pods` |
| `kgpa` | `kubectl get pods --all-namespaces` |
| `kgd` | `kubectl get deployments` |
| `kgs` | `kubectl get services` |
| `kgn` | `kubectl get nodes` |
| `kgi` | `kubectl get ingress` |
| `kgcm` | `kubectl get configmap` |
| `kgsec` | `kubectl get secrets` |
| `kd` | `kubectl describe` |
| `kdp` | `kubectl describe pod` |
| `kdd` | `kubectl describe deployment` |
| `kl` | `kubectl logs` |
| `klf` | `kubectl logs -f` |
| `ke` | `kubectl exec -it` |
| `ka` | `kubectl apply -f` |
| `kdel` | `kubectl delete` |
| `kdelf` | `kubectl delete -f` |
| `kpf` | `kubectl port-forward` |
| `krr` | `kubectl rollout restart deployment` |
| `krs` | `kubectl rollout status deployment` |
| `ksc` | `kubectl scale --replicas` |

### Docker

| Alias | Command |
|---|---|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcr` | `docker compose restart` |
| `dcl` | `docker compose logs -f` |
| `dcb` | `docker compose build` |
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `di` | `docker images` |
| `drm` | `docker rm` |
| `drmi` | `docker rmi` |
| `dex` | `docker exec -it` |
| `dl` | `docker logs -f` |
| `dsp` | `docker system prune -f` |
| `dspa` | `docker system prune -af --volumes` |
| `dv` | `docker volume ls` |
| `dn` | `docker network ls` |

### Helm

| Alias | Command |
|---|---|
| `h` | `helm` |
| `hl` | `helm list` |
| `hla` | `helm list --all-namespaces` |
| `hi` | `helm install` |
| `hu` | `helm upgrade` |
| `hui` | `helm upgrade --install` |
| `hd` | `helm delete` |
| `hr` | `helm repo` |
| `hrlu` | `helm repo update` |

### Python / uv

| Alias | Command |
|---|---|
| `py` | `python3` |
| `python` | `python3` |
| `pip` | `uv pip` |
| `pipi` | `uv pip install` |
| `pipir` | `uv pip install -r requirements.txt` |
| `pipu` | `uv pip install --upgrade` |
| `pipf` | `uv pip freeze` |
| `venv` | `uv venv` |
| `uvr` | `uv run` |
| `uva` | `source .venv/bin/activate` |
| `uvd` | `deactivate` |

### DigitalOcean

| Alias | Command |
|---|---|
| `dctl` | `doctl` |
| `dok` | `doctl kubernetes` |
| `dokc` | `doctl kubernetes cluster` |
| `dokcl` | `doctl kubernetes cluster list` |

### System

| Alias | Command |
|---|---|
| `cls` / `c` | `clear` |
| `q` | `exit` |
| `top` | `htop` |
| `df` | `df -h` |
| `du` | `du -sh` |
| `free` | Show memory usage (macOS vm_stat) |
| `path` | Print PATH entries one per line |
| `ports` | List all listening ports (`lsof`) |
| `myip` | Show public IP via ifconfig.me |
| `localip` | Show local IP (`en0`) |
| `flushdns` | Flush macOS DNS cache |
| `pubkey` | Copy `~/.ssh/id_ed25519.pub` to clipboard |

### Network / SSH

| Alias | Command |
|---|---|
| `ssha` | Start ssh-agent and add default key |
| `pingcheck` | `ping -c 5 8.8.8.8` |
| `sshconfig` | Edit `~/.ssh/config` |

### Clipboard

| Alias | Command |
|---|---|
| `copy` | `pbcopy` |
| `paste` | `pbpaste` |

### JSON / YAML

| Alias | Command |
|---|---|
| `jqp` | Pretty-print JSON with bat syntax highlighting |
| `yqp` | Pretty-print YAML with bat syntax highlighting |

### Misc dev

| Alias | Command |
|---|---|
| `serve` | `python3 -m http.server 8080` |
| `jwt-decode` | Decode a JWT payload (pass token as arg) |
| `urlencode` | URL-encode a string |
| `timestamp` | Print Unix timestamp |
| `dateutc` | Print UTC datetime in ISO 8601 format |
| `week` | Print current ISO week number |

---

## Functions

All functions are defined in `zsh/functions.zsh`. Functions that use `fzf` require fzf
to be installed (included in Brewfile).

### File system

| Function | Usage | Description |
|---|---|---|
| `mkcd` | `mkcd my-dir` | `mkdir -p` and `cd` in one step |
| `fcd` | `fcd` | Fuzzy-pick a directory with fzf and cd into it |
| `fvim` | `fvim` | Fuzzy-find a file and open in `$EDITOR` |
| `extract` | `extract archive.tar.gz` | Extract any archive format (tar, zip, gz, bz2, 7z, rar …) |
| `dusort` | `dusort [dir]` | Show disk usage sorted by size, top 20 entries |
| `httpserver` | `httpserver [port]` | Serve current directory over HTTP (default port 8080) |

### Git

| Function | Usage | Description |
|---|---|---|
| `fbr` | `fbr` | Fuzzy-pick a local or remote branch and check it out |
| `gnew` | `gnew my-feature` | Create a branch and push it with `-u origin` |
| `gprune` | `gprune` | Delete all local branches already merged into current branch |
| `flog` | `flog` | Interactive git log with side-by-side diff preview (fzf) |
| `gdiff` | `gdiff [base] [head]` | List files changed between two refs (default `main…HEAD`) |

### Azure

| Function | Usage | Description |
|---|---|---|
| `azswitch` | `azswitch` | Fuzzy-pick an Azure subscription and set it as active |
| `azwho` | `azwho` | Print current account name, subscription ID, and tenant ID |
| `azget` | `azget` | Fuzzy-pick a resource group then a resource and show its details |

### Kubernetes

| Function | Usage | Description |
|---|---|---|
| `kswitch` | `kswitch` | Fuzzy-pick a kubectl context and switch to it |
| `kpods` | `kpods [namespace]` | Browse pods with fzf (default: all namespaces) |
| `klogs` | `klogs [namespace]` | Fuzzy-pick a pod and tail its logs |
| `kfwd` | `kfwd [ns] [local-port]` | Fuzzy-pick a service and port-forward it |
| `kwatch` | `kwatch [namespace]` | `watch -n2` over pods in a namespace |

### Docker

| Function | Usage | Description |
|---|---|---|
| `dsh` | `dsh [shell]` | Fuzzy-pick a running container and exec into it (default `/bin/sh`) |
| `dclean` | `dclean` | Prune stopped containers and dangling images |

### Terraform

| Function | Usage | Description |
|---|---|---|
| `tfwswitch` | `tfwswitch` | Fuzzy-pick a Terraform workspace and select it |
| `tfup` | `tfup` | `init` → `plan` → confirm prompt → `apply` |

### Python / uv

| Function | Usage | Description |
|---|---|---|
| `pynew` | `pynew my-project` | `uv init` + `uv venv --python 3.12` + activate |
| `va` | `va` | Activate the nearest `.venv` (walks up the directory tree) |
| `uvx-run` | `uvx-run ruff .` | Run a package in a temporary uv environment |

Note: `.venv` directories are also **auto-activated** when you `cd` into a project (via the `_auto_activate_venv` hook in `modules/python.zsh`).

### Databricks

| Function | Usage | Description |
|---|---|---|
| `dbrprofile` | `dbrprofile` | Fuzzy-pick a Databricks named profile and export it as `DATABRICKS_CONFIG_PROFILE` |

### SSH

| Function | Usage | Description |
|---|---|---|
| `sshi` | `sshi` | Fuzzy-pick a host from `~/.ssh/config` and connect |
| `ssh-newkey` | `ssh-newkey github [comment]` | Generate a new ed25519 key pair with optional comment |

### Networking

| Function | Usage | Description |
|---|---|---|
| `check-port` | `check-port host.com 5432` | Test TCP connectivity to a host/port |
| `listening` | `listening` | List all listening TCP ports in a clean table |

### Utilities

| Function | Usage | Description |
|---|---|---|
| `b64e` | `b64e "hello"` | Base64-encode a string |
| `b64d` | `b64d "aGVsbG8="` | Base64-decode a string |
| `jsonpp` | `cat file.json \| jsonpp` or `jsonpp` (clipboard) | Pretty-print JSON via jq + bat |
| `envcp` | `envcp [src] [dst]` | Copy `.env.example` → `.env`, skips if dst exists |
| `calc` | `calc "2 ** 10"` | Quick math expression via Python (supports `math.*`) |
| `repeat-cmd` | `repeat-cmd 3 curl ...` | Run a command N times with a run counter |
| `dothelp` | `dothelp` | Display this README in the terminal via bat |

---

## Shell modules

Modules live in `zsh/modules/` and are sourced by `.zshrc`. Each module is guarded
with `command -v` checks so it does nothing if the tool is not installed.

| Module | What it sets up |
|---|---|
| `git.zsh` | `GIT_EDITOR`, `GIT_PAGER` (delta), `gh` and `glab` completions |
| `python.zsh` | pyenv init, uv completions, `PIP_REQUIRE_VIRTUALENV`, venv auto-activate hook |
| `azure.zsh` | az bash completions, `AZURE_CORE_COLLECT_TELEMETRY=false`, default output to `table` |
| `databricks.zsh` | databricks completions, `DATABRICKS_CONFIG_FILE` |
| `kubernetes.zsh` | kubectl/helm/kubeseal completions, `KUBE_EDITOR`, `K9S_CONFIG_DIR` |
| `terraform.zsh` | terraform completions, `TF_PLUGIN_CACHE_DIR`, `TERRAGRUNT_DOWNLOAD` |
| `docker.zsh` | `DOCKER_BUILDKIT=1`, `DOCKER_SCAN_SUGGEST=false`, Docker Desktop completions |
| `digitalocean.zsh` | doctl completions |

---

## Git config

`git/.gitconfig` is symlinked to `~/.gitconfig`. Notable settings:

| Setting | Value |
|---|---|
| Default branch | `main` |
| Pull strategy | `rebase` (no merge commits on pull) |
| Push | `current` — pushes current branch, auto-creates remote tracking |
| Merge | `ff only` — no accidental merge commits |
| Diff algorithm | `histogram` (better for code) |
| Diff pager | `delta` with side-by-side, line numbers, Dracula theme |
| Conflict style | `zdiff3` (shows base in conflicts) |
| Rebase | `autosquash` + `autostash` enabled |
| HTTPS → SSH | `github.com` URLs rewritten to `git@github.com:` |

**Git aliases** (used as `git <alias>`):

| Alias | Command |
|---|---|
| `git st` | `status -sb` |
| `git undo` | Soft reset last commit (keeps changes staged) |
| `git amend` | Amend last commit without editing the message |
| `git lg` | Pretty oneline graph log |
| `git last` | Show last commit with stat |
| `git who` | List contributors by commit count |
| `git find <msg>` | Search commits by message |
| `git recap` | Diff of last commit |
| `git ss` | Stash with a message |
| `git sl` | Pretty stash list |

---

## SSH config

`ssh/config.example` is a committed template. The actual `~/.ssh/config` is
**never committed** (it may contain internal hostnames and IPs).

```bash
cp ssh/config.example ~/.ssh/config
chmod 600 ~/.ssh/config
$EDITOR ~/.ssh/config
```

The template configures:
- **Global defaults** — agent forwarding, keepalive, connection multiplexing (`ControlMaster`)
- **GitHub** — dedicated key `id_ed25519_github`
- **GitLab** — dedicated key `id_ed25519_gitlab`
- **Azure bastion** — jump host pattern for private VMs
- **DigitalOcean** — droplet example

> On a **Jamf-managed machine** the SSH agent may already be managed by company policy.
> Check with IT before enabling `AddKeysToAgent yes` globally.

---

## Starship prompt

Config is at `config/starship.toml`, symlinked to `~/.config/starship.toml`.

The prompt shows (left to right):

| Segment | Shows |
|---|---|
| Directory | Current path, truncated to 3 components |
| Git | Branch name, staged (`+`), modified (`!`), untracked (`?`), ahead/behind |
| Python | Version + virtualenv name when a venv is active |
| Terraform | Workspace name when inside a Terraform directory |
| Kubernetes | Context + namespace |
| Azure | Active subscription name |
| Docker | Active context |
| Duration | Execution time for commands that take > 2 s |

Requires a **Nerd Font** — `JetBrains Mono Nerd Font`, `Fira Code Nerd Font`, and
`Meslo LG Nerd Font` are all installed by the Brewfile.

---

## Adding a new tool

1. Add packages to `Brewfile` (or `Brewfile.local` for machine-specific ones)
2. Create `zsh/modules/mytool.zsh` for completions and env vars
3. Source it in `zsh/.zshrc` under the "Load modules" block
4. Add aliases to `zsh/aliases.zsh`
5. Add functions to `zsh/functions.zsh`
6. Add env vars to `zsh/exports.zsh.example`
7. Commit and push — pull on other machines with `cd ~/.mydotfiles && git pull && reload`

---

## Maintenance

### Sync after pulling changes

```bash
cd ~/.mydotfiles
git pull
brew bundle --file=Brewfile           # install any newly added packages
./install.sh link                     # refresh symlinks if new dotfiles were added
reload
```

### Save current brew state to Brewfile

```bash
brewdump    # alias for: brew bundle dump --file=$DOTFILES/Brewfile --force
```

### Check what's missing vs Brewfile

```bash
./install.sh check    # checks brew + stow, no changes
brewcheck             # brew only
```

### Refresh symlinks after adding a new dotfile

```bash
./install.sh link     # safe to run anytime — restow refreshes all links
```
