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

IS_REMOTE=$(is_remote)
EXPORT IS_REMOTE

if (( IS_REMOTE )); then
    title="%n@%m: %~"
    prompt_core="%F{green}%n@%m%f:%F{12}%~%f"
else
    title="%n: %~"
    prompt_core="%F{green}%n%f:%F{12}%~%f"
fi

PROMPT="%{$(print -Pn '\e]0;'${title}'\a')%}${prompt_core}%# "
