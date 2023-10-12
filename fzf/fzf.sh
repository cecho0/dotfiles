#!/usr/bin/env bash

RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"

FD_EXCLUDE="{.git,.idea,.nvm,.vscode,.vscode-server,.cache,.sass-cache,node_modules,build}"

export FZF_DEFAULT_COMMAND="fd -H --exclude=${FD_EXCLUDE}"
export FZF_DEFAULT_OPTS=" \
    --height 80% \
    --layout=reverse \
    --border \
    --preview \
        'ls -l {}' \
    --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
    --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
    --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
    --color=gutter:#303446"

error() {
    printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

usage() {
    printf '%s\n' "${GREEN}$*${NO_COLOR}"
}

has() {
    command -v "$1" 1>/dev/null 2>&1
}

fzf_rg() {
    if [ $# -gt 1 ]; then
        error "Param format error. Only provide one or zero param."
        usage "Usage: frg <search_path>"
        return -1
    fi

    local RG_BIN="rg"
    local RG_PATH="${*:-}"
    local RG_OPTION="--column --line-number --no-heading --color=always --smart-case"
    local INITIAL_QUERY=""

    local filename=$(FZF_DEFAULT_COMMAND="$RG_BIN $(printf %q "$INITIAL_QUERY") ${RG_PATH} ${RG_OPTION}" \
    fzf --ansi \
        --disabled \
        --bind "change:reload:$RG_BIN {q} ${RG_PATH} ${RG_OPTION} || true" \
        --prompt "rg > " \
        --delimiter : \
        --preview "bat --style=numbers --color=always {1} --theme=Nord --highlight-line {2}" \
        --preview-window "right,60%,border-bottom,+{2}+3/3,~3") \
    && echo ${filename} \
    || return -1
}


fzf_echo() {
    if [ $# -gt 1 ]; then
        error "Param format error. Only provide one or zero param."
        usage "Usage: fecho <search_path>"
        return -1
    fi

    local FD_BIN="fd ."
    local FD_DEFUALT_OPTION="-H --exclude=${FD_EXCLUDE}"
    local FD_FILE_OPTION="--type f -H --exclude=${FD_EXCLUDE}"
    local FD_DIR_OPTION="--type d -H --exclude=${FD_EXCLUDE}"
    local FD_PATH="${*:-}"
    local INITIAL_QUERY=""
    local selected=$(FZF_DEFAULT_COMMAND="${FD_BIN} ${FD_PATH} ${FD_DEFAULT_OPTION}" \
    fzf --prompt "default > " \
        --ansi \
        --query "${INITIAL_QUERY}" \
        --header "CTRL-D: Directory / CTRL-F: Files" \
        --bind "ctrl-d:change-prompt(Directories > )+reload(${FD_BIN} ${FD_PATH} ${FD_DIR_OPTION})" \
        --bind "ctrl-f:change-prompt(Files > )+reload(${FD_BIN} ${FD_PATH} ${FD_FILE_OPTION})" \
        --preview "bat --style=numbers --color=always --theme=Nord {}" \
        --preview-window "right,60%,border-bottom") \
    && echo ${selected} \
    || return -1
}

fzf_action() {
    if [ $# -gt 1 ]; then
        error "Param format error. Only provide one or zero param."
        usage "Usage: fact <search_path>"
        return -1
    fi

    selected=$(fzf_echo ${*:-})

    if [ -z $selected ]; then
        return -1
    fi

    FILE_ACTION="cat"
    if has nvim; then
        FILE_ACTION="nvim"
    elif has vim; then
        FILE_ACTION="vim"
    elif has vi; then
        FILE_ACTION="vi"
    fi
    DIR_ACTION="cd"

    if [ -d ${selected} ]; then
        ${DIR_ACTION} ${selected}
    else
        ${FILE_ACTION} ${selected}
    fi
}


alias frg="fzf_rg ${*:-}"
alias fact="fzf_action ${*:-}"
alias fecho="fzf_echo ${*:-}"

