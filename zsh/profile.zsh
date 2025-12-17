setopt interactivecomments

if [[ ! -o interactive ]]; then
    return
fi
get_parent_dir() {
    local path="$1"
    cd "$(dirname "$path")" >/dev/null 2>&1 && pwd
}
SCRIPT_DIR="${0:a:h}"
#region General options
autoload -U select-word-style
select-word-style bash # Consider select-word-style with e.g. WORDCHARS=${WORDCHARS//[\/]}
bindkey $terminfo[kLFT5] backward-word
bindkey $terminfo[kRIT5] forward-word
#endregion
#endregion
#region Prompt
function is_remote() {
    # Short circuit if possible
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        return 0
    fi

    # Step 2: Walk the process tree looking for sshd
    local pid=$$
    local ppid name

    while [[ "$pid" -ne 1 ]]; do
        # Get PPID and command name for the current PID
        read ppid name <<<"$(ps -e -o pid=,ppid=,comm= 2>/dev/null | awk -v pid="$pid" '$1 == pid { print $2, $3 }')"

        [[ -z "$ppid" ]] && break

        if [[ "$name" == "sshd" ]]; then
            return 0
        fi

        pid=$ppid
    done

    return 1
}

if is_remote; then
    IS_REMOTE=1
else
    IS_REMOTE=0
fi

if (( IS_REMOTE )); then
    title="%n@%m: %~"
    prompt_core="%F{green}%n@%m%f:%F{12}%~%f"
else
    title="%n: %~"
    prompt_core="%F{green}%n%f:%F{12}%~%f"
fi

PROMPT="%{$(print -Pn '\e]0;'${title}'\a')%}${prompt_core}%# "
#endregion
#region App options and aliases
configRoot="$(realpath "$SCRIPT_DIR/../config/")"
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi
if command -v lsd >/dev/null 2>&1; then
    alias lla='lsd -lah'
fi
if command -v rg >/dev/null 2>&1; then
    rgConfigFile="$configRoot/.ripgreprc"
    export RIPGREP_CONFIG_PATH="$rgConfigFile"
fi
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

if [[ -z ${LESSOPEN:-} ]] && [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

if command -v micro >/dev/null 2>&1; then
    export EDITOR='micro'
elif command -v nano >/dev/null 2>&1; then
    export EDITOR='nano'
fi

if command -v dircolors >/dev/null 2>&1; then
    if [[ -r /etc/dircolors ]]; then
        eval "$(dircolors -b /etc/dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi
#endregion
#region Late commands
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
#endregion
