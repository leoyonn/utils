#!/usr/bin/env bash

# Time-stamp: <2014-02-19 16:32:03 Wednesday by ahei>

# @file find-errors.sh
# @version 1.0
# @author ahei

# 发现各模块的错误日志

readonly PROGRAM_NAME="find-errors.sh"
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
usage: ${PROGRAM_NAME} [OPTIONS] [MODULE]
Find all error logs in xmpush or xmq 's modules.

MODULE can be one of \`${allModules[xmpush]}' or \`${allModules[xmq]}'.

Options:
    -d
        Daily mode.
    -m
        Mail result.
    -s SYSTEM
        SYSTEM maybe xmpush、xmq, default is xmpush.
    -v  Output version info.
    -h  Output this help.
EOF

    exit "$code"
}

find-all-modules-errors()
{
    local preDate=$(date -d "1 days ago" +%Y%m%d)
    
    rm -rf $fullFormatErrorLogsFile
    
    local result=$(_find-all-modules-errors)

    if [ ! "$result" ]; then
        return
    fi
    
    local subject

    echo "$result" > $fullErrorLogsFile
    
    if [ ! "$isMail" ]; then
        return
    fi
    
    if [ "$dailyMode" ]; then
        subject="Error logs of $systemName($preDate) - $(hostname)"
    else
        subject="Error logs of $systemName(pseudo realtime) - $(hostname)"
    fi
    sendMail "$subject" "$result" "$mailLists"
}

_find-all-modules-errors()
{
    for i in ${allModules[$system]}; do
        find-module-errors "$i"
    done
}

# find module $1's error logs
find-module-errors()
{
    local module=$1
    local result=$(_find-module-errors "$module")

    if [ ! "$result" ]; then
        return
    fi
    
    echo "Error logs of module \`$module':"
    echo "$result"

    logger_info "Error logs of module \`$module':"
    logger_info "$result"

    awk "BEGIN{OFS=\"\t\"} {printf \"%s%s%s%s\", \"$module\", OFS, $ 1, OFS; for (i = 2; i <= NF; i++) printf \"%s \", $ i; printf \"\n\"}" <<< "$result" >> $fullFormatErrorLogsFile
}

# find module $1's error logs
_find-module-errors()
{
    local module=$1

    logger_info "Finding module \`$module''s error logs ..."
    
    case "$module" in
        msgquota|presence)
            find-module-instance-errors "$module"1
            find-module-instance-errors "$module"2
            ;;

        xmq*)
            cd $xmqLogRootDir
            for i in $(ls xmq-xmpush* -d 2>/dev/null); do
                find-module-instance-errors $module $i
            done
            cd - >/dev/null
            ;;
        
        *)
            find-module-instance-errors "$module"
            ;;
    esac
}

# find one instance of module $1's error logs
# $1: module
# $2: module directory name
find-module-instance-errors()
{
    local module=$1
    local moduleDirName=$2
    local logFile
    local realLogFile

    [ "$moduleDirName" ] || moduleDirName=$module
    
    if [ "$module" = "xmpush-frontend" ]; then
        logFile="$xmpushLogRootDir/$module/$module.stdout.log $xmpushLogRootDir/$module/$module.log"
    elif [ "$module" = xmq ] || [ "$module" = xmq-sasl ]; then
        logFile="$xmqLogRootDir/$moduleDirName/$module.log"
    else
        logFile="$xmpushLogRootDir/$module/$module.log"
    fi

    if [ "$dailyMode" ]; then
        for i in $logFile; do
            realLogFile="$realLogFile $i.$preDate*"
        done
    else
        realLogFile=$logFile
    fi

    if [ "$system" = xmpush ]; then
        execute "egrep '\<\w+$xmpushErrorPattern\>' $realLogFile -oh 2>/dev/null | sort | uniq -c | sort -k1,1rn | head -10" $ecArgs
        return
    fi

    if [ "$module" = xmq-sasl ]; then
        execute "fgrep '$xmqSaslErrorPattern' $realLogFile -oh 2>/dev/null | uniq -c" $ecArgs
        return
    fi

    local curDate=`date +%Y-%m-%d`
    execute "fgrep '$curDate' $realLogFile 2>/dev/null | grep '$xmqErrorPattern' | sed -r 's/.*$xmqErrorPattern[[:space:]]+<[[:digit:].]+>[[:space:]]*([^[:space:]]*).*/\1/g' | sort | uniq -c | sort -k1,1rn | head -10" $ecArgs
}

declare -A allModules

isExecute=1
isStop=1

. "$home/../conf/find-errors.conf"

optInd=1
dailyMode=
system=xmpush

while getopts ":hvdms:" OPT; do
    case "$OPT" in
        d)
            dailyMode=1
            let optInd++
            ;;
        
        m)
            isMail=1
            let optInd++
            ;;

        s)
            system="$OPTARG"
            let optInd+=2
            ;;
        
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

LOG4SH_CONFIGURATION="$home/../conf/log4sh.properties" . "$home/../shell/log4sh"

if [ -n "$level" ]; then
    level=`tr '[a-z]' '[A-Z]' <<< "$level"`
    appender_setLevel "CONSOLE" "$level"
fi

ecArgs="$isExecute $isStop $mailLists"

execute "mkdir -p $dataDir" $ecArgs

module=$1

if [ "$system" = xmq ]; then
    systemName=XMQ
else
    systemName=XmPush
fi

preDate=`date -d "1 days ago" +%Y%m%d`
 
if [ "$dailyMode" ]; then
    timeFlag=$preDate
else
    timeFlag=cur
fi
fullFormatErrorLogsFile=$dataDir/$formatErrorLogsFile.$systemName.$timeFlag
fullErrorLogsFile=$dataDir/$errorLogsFile.$systemName.$timeFlag

if [ "$module" ]; then
    find-module-errors "$module"
    exit $?
fi

find-all-modules-errors
if [ ! -e "$fullFormatErrorLogsFile" ]; then
    logger_info "No error logs found."
    exit
fi
oldFormatFile=$fullFormatErrorLogsFile.old
execute "mv $fullFormatErrorLogsFile $oldFormatFile" $ecArgs
execute "sort $oldFormatFile -k1,1 -k3,3 -t \"$separator\" | awk -f $shellDir/merge-error-logs.awk | sort -k1,1 -k2,2rn -t \"$separator\" > $fullFormatErrorLogsFile" $ecArgs
execute "rm -rf $oldFormatFile" $ecArgs
execute "awk -f $shellDir/display-format-error-logs.awk $fullFormatErrorLogsFile | tee $fullErrorLogsFile" $ecArgs
