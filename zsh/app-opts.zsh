SCRIPT_DIR="${0:a:h}"
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
