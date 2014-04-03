#!/usr/bin/env bash

# Time-stamp: <2014-02-21 11:37:55 Friday by ahei>

# @version 1.0
# @author ahei

version()
{
    echo "${PROGRAM_NAME} ${PROGRAM_VERSION}"
    exit 1
}

# echo to stdout
echoo()
{
    echo "$*"
}

# echo to stderr
echoe()
{
    echo "$*" 1>&2
}

executeCommand()
{
    local _command="$1"
    local _isExecute="$2"
    local _isQuiet="$3"
    local _isStop="$4"
    
    [ "$_isQuiet" != 1 ] && echoo "Executing command \`${_command}' ..."
    if [ "${_isExecute}" != "0" ]; then
        eval "${_command}"
        if [ $? != 0 ]; then
            echoo "Execute command \`${_command}' failed."
            if [ "$_isStop" = 1 ]; then
                exit 1
            fi
        fi
    fi
}

# execute command and print log
# 
# $1: command
# $2: really execute command or not
# $3: when execute command fail stop or not
# $4: mail lists(optional)
#
# use environment variable:
# 1. LOG_FUNCTION
# 2. RECORD_TIME
execute()
{
    local ret
    local logFun=$LOG_FUNCTION
    local timeStart timeEnd
    local optInd=1
    local recordTime
    
    [ -z "$logFun" ] && logFun=logger_info

    OPTIND=1
    
    while getopts ":t" OPT; do
        case "$OPT" in
            t)
                recordTime=1
                let optInd++
                ;;
        esac
    done
    
    shift $((optInd - 1))

    local command="$1"
    local isExecute="$2"
    local isStop="$3"
    local mailLists="${@:4}"

    $logFun "Executing command \`${command}' ..."
    if [ "${isExecute}" = "0" ]; then
        return 0
    fi

    timeStart=$(date +%s)
    
    eval "${command}"
    ret="$?"

    timeEnd=$(date +%s)

    if [ "$RECORD_TIME" = 1 ] || [ "$recordTime" = 1 ]; then
        $logFun "Time used: $((timeEnd - timeStart))s"
    fi

    if [ "$ret" != 0 ]; then
        local subject
        local message
        
        if ((`expr length "$command"` > 15)); then
            subject="Execute command failed!"
            message="Execute command \`${command}' failed."
        else
            subject="Execute command \`${command}' failed."
            message=""
        fi
        mailEcho "$subject" "$message" "$mailLists" "error" $LOG_FUNCTION
        if [ "$isStop" = 1 ]; then
            exit 1
        fi

        return "$ret"
    fi
}

# echo and mail
# 
# $1: subject
# $2: message
# $3: mail lists(optional)
# $4: log level (optional, default is WARN)
# $5: log function (optional)
mailEcho()
{
    local subject="$1"
    local message="$2"
    local mailLists="$3"
    local info="$message"
    local level="$4"
    local logFun="$5"

    [ -z "$info" ] && info="$subject"

    level=`echo $level | tr '[a-z]' '[A-Z]'`

    [ -z "$level" ] && level="WARN"

    if [ -z "$logFun" ]; then
        case "$level" in
            INFO)
                logFun=logger_info
                ;;

            WARN)
                logFun=logger_warn
                ;;

            ERROR)
                logFun=logger_error
                ;;
        esac
    fi
    
    "$logFun" "$info"
    [ -n "$mailLists" ] && echo "$message" | mail -s "[$level] $subject" "$mailLists"
}

resolveLink()
{
    this="$1"

    while [[ -L "$this" && -r "$this" ]]; do
        link=$(readlink "$this")

        dir=$(dirname "$link")
        if [[ "$dir" != "." ]]; then
            link=$dir/$(basename "$link")
        else
            link=$(basename "$link")
        fi
        
        if [[ "${link:0:1}" = "/" ]]; then
            this="$link"
        else
            dir=$(dirname "$this")
            if [[ "$dir" != "." ]]; then
                this="$dir/$link"
            else
                this="$link"
            fi
        fi
    done

    echo "$this"
}

killProcessByPattern()
{
    local pattern="$*"

    pids=`ps -ef | grep -E "$pattern" | grep -v grep | awk '{print $2}'`
    if [ -z "$pids" ]; then
        return
    fi

    kill -9 $pids
}

killProcess()
{
    local pidFile="$1"
    local pattern="$2"
    
    if [ ! -e "$pidFile" ]; then
        if [ -n "$pattern" ]; then
            killProcessByPattern "$pattern"
        fi
        return
    fi

    pid=`cat "$pidFile"`
    if ! ps -p "$pid" >/dev/null 2>&1; then
        logger_warn "Unknown pid $pid."
        if [ -n "$pattern" ]; then
            killProcessByPattern "$pattern"
        fi
        return
    fi
    
    if kill -9 `cat "$pidFile"`; then
        rm -rf "$pidFile"
        return
    fi

    if [ -n "$pattern" ]; then
        killProcessByPattern "$pattern"
    fi
}

isLocalHost()
{
    local ip="$1"

    if [ "$ip" = "localhost" -o "$ip" = "l" ]; then
        return 0
    fi

    LANG= /sbin/ifconfig | grep -E "inet[[:space:]]+addr" | awk -F"[ :]+" '{print $4}' | grep "$ip" -xsq
}

joinPath()
{
    local path="$1"
    local name="$2"

    if [[ "${path:-1:1}" = "/" ]]; then
        echo "${path}${name}"
    else
        echo "${path}/${name}"
    fi
}

normalizePath()
{
    local path="$1"

    if [ -d "$path" ]; then
        echo "$(cd $path && pwd)"
        return
    fi

    local dir=$(dirname "$path")
    local basename=$(basename "$path")

    if [ -r "$dir" ]; then
        dir="$(cd $dir && pwd)"
    fi

    if [[ "$basename" != "." ]]; then
        path="$(joinPath $dir $basename)"
    else
        path="$dir"
    fi

    echo "$path"
}

# $1: path
toAbsPath()
{
    local path="$1"
    if [ "${path:0:1}" != "/" ]; then
        path=$(pwd)/"$path"
    fi

    normalizePath "$path"
}

# judge two paths equal or not
# $1: path 1
# $2: path 2
pathEqual()
{
    [ $(normalizePath "$1") = $(normalizePath "$2") ]
}

# download file
# 
# $1: file to download
# $2: output file
# $3: check md5 or not
# $4: retry times
# $5: backup or not
# $6: download multi files or not
# $7: wget option
#
# use environment variable:
# 1. DOWNLOAD_RATE
#
# return value:
# 0 - download success
# 1 - download fail
# 2 - file to download is up-to-date
download()
{
    local file="$1"
    local outputFile="$2"
    local checkMd5="$3"
    local retryTimes="$4"
    local backup="$5"
    local multi="$6"
    local wgetOption="$7"
    local rate

    [ -n "$DOWNLOAD_RATE" ] && rate="--limit-rate=$DOWNLOAD_RATE"

    logger_info "Downloading file \`$file' ..."

    [ -z "$outputFile" ] && outputFile=`basename "$file"`
    [ -z "retryTimes" ] && retryTimes=1
    
    local md5File="$file".md5
    local md5OutputFile="$outputFile".md5

    # temp files
    [ -z "$multi" ] && local tempOutputFile=`maketemp "$outputFile".XXXXXX`
    [ -z "$multi" ] && local tempMd5OutputFile="$tempOutputFile".md5

    local dateTime=`date +%Y%m%d-%k%M%S`
    local ret=0
    local options
    
    retryTimes=5
    
    for ((i = 0; i < retryTimes; i++)); do
        logger_debug "Retry time: $i"

        if [ -n "$checkMd5" ] && [ -z "$multi" ]; then
            if ! execute "wget \"$md5File\" -O \"$tempMd5OutputFile\" $wgetOption"; then
                ret=1
                continue
            fi

            if [ -f "$md5OutputFile" ] && diff "$md5OutputFile" "$tempMd5OutputFile" &>/dev/null; then
                logger_info "File \"$md5OutputFile\" is up-to-date, not need to update."
                ret=2
                break
            fi
        fi

        options="$wgetOption"
        [ -z "$multi" ] && options="-O \"$tempOutputFile\" $options"

        if ! execute "wget \"$file\" $rate $options"; then
            ret=1
            continue
        fi

        if [ -z "$multi" ]; then
            if [ -f "$outputFile" ] && diff "$outputFile" "$tempOutputFile" &>/dev/null; then
                logger_info "File \"$outputFile\" is up-to-date, not need to update."
                ret=2
                break
            fi
        fi

        break
    done

    if [ -n "$multi" ]; then
        return "$ret"
    fi
    
    if ((ret != 0)); then
        execute "rm -rf \"$tempMd5OutputFile\" \"$tempOutputFile\"" $ecArgs
        return "$ret"
    fi

    # check md5 and backup
    if [ -n "$checkMd5" ]; then
        if ! execute "cd $(dirname $tempOutputFile) && sed \"s/$(basename $file)/$(basename $tempOutputFile)/g\" $tempMd5OutputFile | md5sum -c &>/dev/null; cd -"; then
            logger_error "Md5sum file \"$tempMd5OutputFile\" is not match file \"$tempOutputFile\"!"
            execute "rm -rf \"$tempMd5OutputFile\" \"$tempOutputFile\"" $ecArgs
            return 1
        fi

        [ -n "$backup" ] && execute "[ -e \"$md5OutputFile\" ] && cp \"$md5OutputFile\" \"$md5OutputFile.$dateTime\"" $ecArgs
        execute "mv \"$tempMd5OutputFile\" \"$md5OutputFile\"" $ecArgs
    fi
    
    [ -n "$backup" ] && execute "[ -e \"$outputFile\" ] && cp \"$outputFile\" \"$outputFile.$dateTime\"" $ecArgs
    execute "mv \"$tempOutputFile\" \"$outputFile\"" $ecArgs
}

isLocalHost()
{
    local ip="$1"

    if [ "$ip" = "localhost" -o "$ip" = "l" ]; then
        return 0
    fi

    LANG= /sbin/ifconfig | grep -E "inet[[:space:]]+addr" | awk -F"[ :]+" '{print $4}' | grep "$ip" -xsq
}

# inplace sort
# $1: file
# $2: arguments
# $3: options
inplaceSort()
{
    local optInd=1
    local sortCommand="sort"

    OPTIND=1
    
    while getopts ":s:" OPT; do
        case "$OPT" in
            s)
                sortCommand="$OPTARG"
                let optInd+=2
                ;;
        esac
    done
    
    shift $((optInd - 1))

    local file="$1"
    local arguments="$2"
    local options="${@:3}"

    local tempFile=$(maketemp "$file".XXXXXX)

    execute "$sortCommand $options \"$file\" $arguments > $tempFile" $ecArgs
    execute "mv $tempFile $file" $ecArgs
}

# mktemp and set read permission
maketemp()
{
    local file=$(mktemp "$@")

    chmod a+r "$file" 2>/dev/null
    echo "$file"
}

# unset function definition of log4sh
unsetLog4sh()
{
    for i in debug info warn error; do
        eval "logger_$i() { :; }"
    done
}

setDirectories()
{
    home=$1
    
    rootDir=$(toAbsPath "$home"/..)
    dataDir="$rootDir"/data
    confDir="$rootDir"/conf
    shellDir="$rootDir"/shell
    binDir="$rootDir"/bin
    workDir="$rootDir"/work
    shareDir="$rootDir"/share
    publicDir="$rootDir"/public
}

# run java class
# usage: runjava -p PATH CLASS [ARGUMENTS]
# -p JAR_FILE | JAR_PATH
runjava()
{
    local optInd=1
    local paths
    local classpath
    
    OPTIND=1
    
    while getopts ":p:" OPT; do
        case "$OPT" in
            p)
                paths="$OPTARG"
                let optInd+=2
                ;;
        esac
    done

    if [ "$paths" ]; then
        for p in $paths; do
            # jar目录
            for jar in $(ls $p/*.jar 2>/dev/null); do
                classpath=$classpath:$jar
            done
            classpath=$classpath:$p
        done
    fi
    
    shift $((optInd - 1))

    local class="$1"
    local command="java"

    if [ "$classpath" ]; then
        command="$command -cp $classpath"
    fi

    $command $@
}

# $1: subject
# $2: body
# $3: mailLists
sendMail()
{
    local subject=$1
    local body=$(awk '{print $ 0 "<br>"}' <<< "$2")
    local mailLists=$3
    local mail
    
    for mail in $mailLists; do
        curl -d "subject=$subject&body=$body&to=$mail&s=xiaomi.commiliao" http://operation.chat.xiaomi.net/m123 &>/dev/null
    done
}
