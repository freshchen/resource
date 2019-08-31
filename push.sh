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
    local images=$(git status --porcelain | grep '^??' | grep -E '.png$|.jpg$' | awk '{print $2}')
    
    if [[ -n "${images}" ]]; then
        for img in ${images[@]} ; do
            jpegoptim --strip-all --all-progressive -preserve -o -f -m 90 ${img} > /dev/null 2>&1
            if [[ $? -eq 1 ]]; then
                optipng -preserve ${img} > /dev/null 2>&1
                if [[ $? -eq 1 ]] ; then
                    echo compress img failed.
                fi
            fi
        done
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
    pre_check || exit 1
    compress_img || exit 1
    post_push
}

main