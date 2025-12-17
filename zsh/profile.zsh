setopt interactivecomments

if [[ ! -o interactive ]]; then
    return
fi
get_parent_dir() {
    local path="$1"
    cd "$(dirname "$path")" >/dev/null 2>&1 && pwd
}
#region Source rest of profile
SCRIPT_DIR="${0:a:h}"
source "${SCRIPT_DIR}/app-opts.zsh"
source "${SCRIPT_DIR}/prompt.zsh"
source "${SCRIPT_DIR}/shell-opts.zsh"
#endregion
#region Late commands
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
#endregion
