#!/usr/bin/env bash

# Time-stamp: <2013-12-19 20:45:55 Thursday by ahei>

# @file run.sh
# @version 1.0
# @author ahei

# 该脚步可以运行我们项目中的任何类
# 使用方法:　./run.sh 类名 参数

readonly PROGRAM_NAME="run.sh"
readonly PROGRAM_VERSION="1.0.0"

home=`cd $(dirname "$0") && pwd`

. "$home"/util.sh

usage()
{
    local code=1
    local redirect
    
    if [ $# -gt 0 ]; then
        code="$1"
    fi

    if [ "$code" != 0 ]; then
        redirect="1>&2"
    fi

    eval cat "$redirect" << EOF
usage: ${PROGRAM_NAME} [OPTIONS] CLASS [ARGUMENTS]

Options:
    -v  Output version info.
    -h  Output this help.
EOF

    exit "$code"
}

optInd=1

while getopts ":hv" OPT; do
    case "$OPT" in
        v)
            version
            ;;

        h)
            usage 0
            ;;

        :)
            case "${OPTARG}" in
                ?)
                    echoe "Option \`-${OPTARG}' need argument.\n"
                    usage
            esac
            ;;

        ?)
            echoe "Invalid option \`-${OPTARG}'.\n"
            usage
            ;;
    esac
done

shift $((optInd - 1))

if [ $# -lt 1 ]; then
    usage
fi

runjava -p "$home/configuration $home/classes $home/library" $@
