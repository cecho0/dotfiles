#!/usr/bin/env bash

is_wsl() {
    rc=$(uname -r | grep WSL > /dev/null 2>&1) || \
        return 1

    return 0
}

proxy_new() {
    export http_proxy="http://$1:$2"
    export https_proxy="http://$1:$2"
    # socks5
    #export http_proxy="socks5://$1:$2"
    #export https_proxy="socks5://$1:$2"
    export all_proxy="socks5://$1:$2"
}

proxy_kill() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
}

hostip="localhost"
port="7890"
if [ ! $is_wsl ]; then
    hostip=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\ ).*')
fi

alias proxy.n="proxy_new ${hostip} ${port}"
alias proxy.k="proxy_kill ${hostip} ${port}"

