#!/usr/bin/env bash

CURRENT_PATH=$(cd "$(dirname "$0")"; pwd)
if [[ $# -eq 0 ]] ; then
    COMMENT="update"
else
    COMMENT=$*
fi
cd ${CURRENT_PATH}


pre_check() {
    local status=$(git pull)
    if [[ ${status} == "Already up to date." ]]; then
        echo 'Pre-Check successfully.'
    else
        echo 'Need merge.'
        exit 1
    fi
}

compress_img() {
    local png_images=($(git status --porcelain | grep '^??' | grep '.png$' | awk '{print $2}'))
    local jpg_images=($(git status --porcelain | grep '^??' | grep '.jpg$' | awk '{print $2}'))
    
    if [[ -n "${png_images}" ]]; then
        optipng -preserve ${png_images[@]}
    fi

    if [[ -n "${jpg_images}" ]]; then
        jpegoptim --strip-all --all-progressive -preserve -o -f -m 90 ${jpg_images[@]}
    fi
}

post_push() {
    echo 'Start to push.'
    git add ./img/ || exit 1
    git commit -m "${COMMENT}" || exit 1
    git push origin master || exit 1
    echo 'Push successfully.'
}

main() {
    pre_check
    compress_img
    post_push
}

main