#!/bin/zsh

# proxy
base_proxy=127.0.0.1:7890

# alias
alias l='ls --color'
alias ls='ls --color'
alias la='ls -a --color'
alias ll='ls -a -l --color'
alias rvim='nvim --headless --listen 0.0.0.0:6666'
alias reload="source ~/.zshrc"
alias proxy="export http_proxy=http://$base_proxy;export https_proxy=http://$base_proxy;export ALL_PROXY=socks5://$base_proxy"
alias unproxy="unset http_proxy;unset https_proxy;unset ALL_PROXY"
proxy

# path
PathAppend() { [ -d "$1" ] && PATH="$PATH:$1"; }
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_CONFIG_DIR="/etc/xdg"
export XDG_DATA_DIR="/usr/local/share/:/usr/share/"
export USER_TOOLS_HOME="$HOME/.tools"

# Antidote
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
export ANTIDOTE_HOME=${ZDOTDIR}/antidote

zsh_plugins=${ZDOTDIR}/zsh_plugins.zsh
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt
if [ ! -d ${ANTIDOTE_HOME} ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ANTIDOTE_HOME}
fi

if [ -d ${ANTIDOTE_HOME} ]; then
    fpath+=(${ANTIDOTE_HOME})
    autoload -Uz $fpath[-1]/antidote

    if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
        (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
    fi

    source $zsh_plugins
fi

# p10k
[ -d ${ANTIDOTE_HOME}/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k ] && source ${ANTIDOTE_HOME}/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k/powerlevel10k.zsh-theme

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f ${XDG_CONFIG_HOME}/zsh/p10k.zsh ] && source ${XDG_CONFIG_HOME}/zsh/p10k.zsh

# tools
[ $(command -v bat) ] && unalias -m "cat" && alias cat='bat --theme="Nord"'
[ $(command -v fzf) ] && [ -f ${XDG_CONFIG_HOME}/fzf/fzf.sh ] && source ${XDG_CONFIG_HOME}/fzf/fzf.sh
if [ "$(command -v eza)" ]; then
    unalias -m 'l'
    unalias -m 'll'
    unalias -m 'la'
    unalias -m 'ls'
    alias l='eza -G  --color auto --icons -s type'
    alias ls='eza -G  --color auto --icons -s type'
    alias la='eza -G --color always --icons -a -s type'
    alias ll='eza -l --color always --icons -a -s type'
fi

# Homebrew
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
# MacOS
#export HOMEBREW_PATH="/opt/homebrew"
# Linux
export HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
PathAppend $HOMEBREW_PATH/bin

# Rust
export CARGO_HOME="$USER_TOOLS_HOME/rust/cargo"
export RUSTUP_HOME="$USER_TOOLS_HOME/rust/rustup"
PathAppend $CARGO_HOME/bin

# Go
export GO111MODULE="on"
export GOPATH="$USER_TOOLS_HOME/go/gopackges"
export GOPROXY="https://goproxy.cn"
PathAppend $GOROOT/bin
PathAppend $GOPATH/bin

# NodeJs
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export NVM_NODEJS_ORG_MIRROR="http://npm.taobao.org/mirrors/node"
export NVM_IOJS_ORG_MIRROR="http://npm.taobao.org/mirrors/iojs"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Java
export JAVA_HOME=$USER_TOOLS_HOME/jdk-21
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
PathAppend $JAVA_HOME/bin

# XMake
[ -f $HOME/.xmake/profile ] && source $HOME/.xmake/profile

# VCPKG
[ $(command -v vcpkg) ] && export VCPKG_ROOT=$USER_TOOLS_HOME/vcpkg
[ $(command -v pgk_config) ] && export PKG_CONFIG_PATH=$VCPKG_ROOT/installed/x64-linux/lib/pkgconfig
unset PathAppend
