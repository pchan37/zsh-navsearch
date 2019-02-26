#!/usr/bin/env zsh

NS_ENHANCD_SCRIPT_DIRECTORY=#{0:a:h}

NS_RUST_ENHANCD="$NS_ENHANCD_SCRIPT_DIRECTORY/rust-enhancd"
if command -v rust-enhancd >/dev/null 2>&1; then
    NS_RUST_ENHANCD="rust-enhancd"
fi

NS_FD="$NS_ENHANCD_SCRIPT_DIRECTORY/fd"
if command -v fd >/dev/null 2>&1; then
    NS_FD="fd"
fi

NS_SKIM="$NS_ENHANCD_SCRIPT_DIRECTORY/sk"
if command -v sk >/dev/null 2>&1; then
    NS_SKIM="sk"
fi

export NS_SKIM_NAVIGATION_TMUX_HEIGHT=15
if [ -z $NS_SKIM_GENERAL_NAVIGATION_OPTS ]; then
    export NS_SKIM_GENERAL_NAVIGATION_OPTS="--color=dark,matched:75 --bind 'alt-a:beginning-of-line,alt-e:end-of-line,ctrl-k:kill-line,alt-k:up,alt-j:down,alt-g:abort'"
fi

export NS_SKIM_NAVIGATION_OPTS="--height $NS_SKIM_NAVIGATION_TMUX_HEIGHT --reverse $SKIM_DEFAULT_OPTIONS $NS_SKIM_GENERAL_NAVIGATION_OPTS"


ns-skim-select-files-filter-and-insert(){
    local cmd
    cmd="$1"
    setopt localoptions pipefail 2>/dev/null
    eval "$cmd" | SKIM_DEFAULT_OPTIONS="--prompt 'insert: ' $NS_SKIM_NAVIGATION_OPTS" $NS_SKIM -m | while read item; do
        echo -n "${(q)item} "
    done
    local err=$?
    echo
    return $err
}

ns-skim-select-files-from-home(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    if [ -z $NS_SKIM_ALT_S_COMMAND ]; then
        export NS_SKIM_ALT_S_COMMAND="command $NS_FD --hidden --no-ignore --full-path '.*' $HOME --exclude .git"
    fi
    ns-skim-select-files-filter-and-insert "$NS_SKIM_ALT_S_COMMAND"
}

ns-skim-select-files-from-root(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    if [ -z $NS_SKIM_CTRL_S_COMMAND ]; then
        export NS_SKIM_CTRL_S_COMMAND="command $NS_FD --hidden --no-ignore --full-path '.*' / --exclude .git"
    fi
    ns-skim-select-files-filter-and-insert "$NS_SKIM_CTRL_S_COMMAND"
}

ns-skim-insert-from-home(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    LBUFFER="${LBUFFER}$(ns-skim-select-files-from-home)"
    local err=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $err
}

ns-skim-insert-from-root(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    LBUFFER="${LBUFFER}$(ns-skim-select-files-from-root)"
    local err=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $err
}

zle -N ns-skim-insert-from-home
zle -N ns-skim-insert-from-root
bindkey '\cs' ns-skim-insert-from-root
bindkey '\cS' ns-skim-insert-from-root
bindkey '\es' ns-skim-insert-from-home
bindkey '\eS' ns-skim-insert-from-home

ns-skim-open-files-from-pwd(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    local get_files_cmd="$NS_FD --hidden --no-ignore --full-path --exclude .git --type f '\.*' ."
    local selected_files=$(eval "$get_files_cmd" | env SKIM_DEFAULT_OPTIONS="--prompt 'Open: ' -m $NS_SKIM_NAVIGATION_OPTS" $NS_SKIM)
    if [ -n "$selected_files" ]; then
       emacs "$selected_files" -nw < /dev/tty
    fi
    local err=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $err
}

ns-skim-open-files-from-root(){
    if ! command -v $NS_FD >/dev/null 2>&1; then
        echo "fd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    local get_files_cmd="$NS_FD --hidden --no-ignore --full-path --exclude .git --type f '\.*' /"
    local selected_files=$(eval "$get_files_cmd" | env SKIM_DEFAULT_OPTIONS="--prompt 'Open: ' -m $NS_SKIM_NAVIGATION_OPTS" $NS_SKIM)
    if [ -n "$selected_files" ]; then
       sudo emacs "$selected_files" -nw < /dev/tty
    fi
    local err=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $err
}

zle -N ns-skim-open-files-from-pwd
zle -N ns-skim-open-files-from-root
bindkey '\co' ns-skim-open-files-from-root
bindkey '\cO' ns-skim-open-files-from-root
bindkey '\eo' ns-skim-open-files-from-pwd
bindkey '\eO' ns-skim-open-files-from-pwd

ns-skim-change-directory(){
    if ! command -v $NS_RUST_ENHANCD >/dev/null 2>&1; then
        echo "rust-enhancd is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    if ! command -v $NS_SKIM >/dev/null 2>&1; then
        echo "skim/sk is not installed.  Please read the README on where you can find it."
        echo
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
        return 1
    fi

    setopt localoptions pipefail 2>/dev/null
    local get_dir_cmd="$NS_RUST_ENHANCD getkeys"
    local selected_dir=$(eval "$get_dir_cmd" | SKIM_DEFAULT_OPTIONS="--prompt 'Switch to: ' $NS_SKIM_NAVIGATION_OPTS" $NS_SKIM)
    if [ -n "$selected_dir" ]; then
        $NS_RUST_ENHANCD update "$selected_dir"
        cd "$selected_dir"
    fi
    local err=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $err
}

zle -N ns-skim-change-directory
bindkey '\ec' ns-skim-change-directory
bindkey '\eC' ns-skim-change-directory

ns-skim-insert-history(){
    local history_line num skim
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    history_line=( $(fc -l 1 | SKIM_DEFAULT_OPTIONS="-n2..,.. --tac --query=${(q)LBUFFER} $SKIM_NAVIGATION_OPTS" $NS_SKIM))
    local err=$?
    if [ -n "$history_line" ]; then
        num=$history_line[1]
        if [ -n "$num" ]; then
            zle vi-fetch-history -n $num
        fi
    fi
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
        return $err
}

zle -N ns-skim-insert-history
bindkey '\er' ns-skim-insert-history
bindkey '\eR' ns-skim-insert-history
