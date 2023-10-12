#!/bin/bash

check_dept() {
    # check command
    if ! command -v fontforge > /dev/null 2>&1; then
        echo "can't find 'fontforge'."
        exit 1
    fi

    # check curl
    if ! command -v curl > /dev/null 2>&1; then
        echo "can't find 'curl'"
        exit 1
    fi
}

check_dir() {
    # check font dir
    if [ ! -d ${font_dir} ]; then
        echo "${font_dir} not exist."
        exit 1
    fi

    # check output dir
    if [ ! -d ${out_dir} ]; then
        mkdir ${dout_dir} > /dev/null 2>&1
    fi
}

download_patcher() {
    echo "Download font patcher..."
    curl --connect-timeout 10 --speed-time 10 --speed-limit 1 --silent --location --output ${dir}/FontPatcher.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip \
        && unzip ${dir}/FontPatcher.zip -d ${dir}/FontPatcher_dir > /dev/null 2>&1 \
        && rm FontPatcher.zip > /dev/null 2>&1 \
        && return \
        || echo "download font patcher failed."
    exit 1
}

dir=$(cd $(dirname $);pwd)
font_dir="${dir}/fonts"
out_dir="${dir}/patched_font_output"

check_dept
check_dir
download_patcher

echo "Install fonts now, it may take a lots of time..."
for file in `find ${font_dir} -type f`; do
    fontforge --script ${dir}/FontPatcher_dir/font-patcher --complete ${file} -out ${out_dir} > /dev/null 2>&1 \
        || echo "patch font ${file} failed."
done
rm -rf ${dir}/FontPatcher_dir > /dev/null 2>&1

echo "All patched fonts output to ${out_dir}"

