#shellcheck shell=bash

# Do nothing if not running interactively
case $- in
        *i*) ;;
            *) return;;
esac
#region General alises / functions
get_parent_dir() {
    local path="$1"
    cd "$(dirname "$path")" >/dev/null 2>&1 && pwd
}
SCRIPT_DIR="$(get_parent_dir "${BASH_SOURCE[0]}")"
#endregion
#region Prompt
is_remote() {
    # Short circuit if possible
    if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
        return 0
    fi

    # Step 2: Walk the process tree looking for sshd
    local pid=$$
    local ppid name

    while [[ $pid -ne 1 ]]; do
        # Get PPID and command name for the current PID
        read -r ppid name < <(
            ps -e -o pid=,ppid=,comm= 2>/dev/null | awk -v pid="$pid" '$1 == pid { print $2, $3 }'
        )

        [[ -z $ppid ]] && break

        if [[ $name == sshd ]]; then
            return 0
        fi

        pid=$ppid
    done

    return 1
}

IS_REMOTE=$(is_remote)

if (( IS_REMOTE )); then
    title="\u@\h: \w"
    prompt_core="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]"
    export IS_REMOTE
else
    title="\u: \w"
    prompt_core="\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]"
fi

export PS1="\[\e]0;${title}\a\]${prompt_core}\\$ "
#endregion
#region App options and aliases
configRoot="$(realpath "$SCRIPT_DIR/../config/")"
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi
export BAT_THEME="Visual Studio Dark+"

if command -v lsd >/dev/null 2>&1; then
    alias lla='lsd -lah'
fi

if command -v rg >/dev/null 2>&1; then
    rgConfigFile="$configRoot/.ripgreprc"
    export RIPGREP_CONFIG_PATH="$rgConfigFile"
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

if [[ -z $LESSOPEN ]] && [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

if command -v micro >/dev/null 2>&1; then
    export EDITOR='micro'
elif command -v nano >/dev/null 2>&1; then
    export EDITOR='nano'
fi

if [ -x /usr/bin/dircolors ]; then
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
    eval "$(zoxide init bash)"
    alias cd='z'
fi
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config "$configRoot/oh-my-posh.yaml")"
fi
#endregion
