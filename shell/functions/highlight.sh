#!/bin/bash
# -*- mode: shell-script -*-

# Taken from https://miraiverse.xyz/notice/AfVJZHlvMU3o2r5HO4

.highlight() {
    if test $# -ne 1;
    then
        echo "Usage: $0 PATTERN"
        echo "Highlights and bolds PATTERN in standard input."
        exit 1
    fi

    ESC=`printf '\033'`

    sed "s/$1/$ESC[1;33;41m&$ESC[0m/g"
}
