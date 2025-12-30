setopt interactivecomments

if [[ ! -o interactive ]]; then
    return
fi
get_parent_dir() {
    local path="$1"
    cd "$(dirname "$path")" >/dev/null 2>&1 && pwd
}
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
    export PATH
fi
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
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config "$configRoot/oh-my-posh.yaml")"
fi
#endregion
