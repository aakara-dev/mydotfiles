# git.zsh — Git environment config

export GIT_EDITOR="${EDITOR:-nvim}"

# delta (better diffs) — configured in ~/.gitconfig
command -v delta &>/dev/null && export GIT_PAGER="delta"

# gh completion
command -v gh &>/dev/null && eval "$(gh completion -s zsh)" 2>/dev/null

# glab completion
command -v glab &>/dev/null && eval "$(glab completion -s zsh)" 2>/dev/null
