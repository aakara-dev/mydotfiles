# digitalocean.zsh — doctl (DigitalOcean CLI)

if command -v doctl &>/dev/null; then
  source <(doctl completion zsh) 2>/dev/null
fi
# DIGITALOCEAN_TOKEN comes from exports.zsh
