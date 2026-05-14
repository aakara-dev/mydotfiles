# docker.zsh — Docker and Docker Compose

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Suppress the Docker Desktop upgrade nag
export DOCKER_SCAN_SUGGEST=false

# ── Completions ───────────────────────────────────────────────────────────────
# Docker Desktop installs completions into /Applications/Docker.app
_docker_comp="/Applications/Docker.app/Contents/Resources/etc"
[[ -f "$_docker_comp/docker.zsh-completion" ]] && \
  source "$_docker_comp/docker.zsh-completion"
[[ -f "$_docker_comp/docker-compose.zsh-completion" ]] && \
  source "$_docker_comp/docker-compose.zsh-completion"
unset _docker_comp
