#!/usr/bin/env bash

# Time-stamp: <2014-01-23 11:15:47 Thursday by ahei>

# @file find-all-errors.sh
# @version 1.0
# @author ahei

# 批量调用各机器上的find-errors.sh, 并进行汇总

readonly PROGRAM_NAME="find-all-errors.sh"
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
usage: ${PROGRAM_NAME} [OPTIONS]
Find all error logs in xmpush or xmq 's modules on all machines.

Options:
    -d
        Daily mode.
    -s SYSTEM
        SYSTEM maybe xmpush、xmq, default is xmpush.
    -D [DEBUG_LEVEL]
        Set debug level, can be: TRACE, DEBUG, INFO, WARN, ERROR, FATAL, OFF.
    -v  Output version info.
    -h  Output this help.
EOF

    exit "$code"
}

isExecute=1
isStop=1

. "$home/../conf/find-errors.conf"

optInd=1
system=xmpush

while getopts ":D:ds:hv" OPT; do
    case "$OPT" in
        d)
            dailyMode=1
            let optInd++
            ;;

        s)
            system="$OPTARG"
            let optInd+=2
            ;;

        D)
            level="$OPTARG"
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
                D)
                    level="DEBUG"
                    let optInd++
                    ;;

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

sshOpts="-o StrictHostKeyChecking=no"
ssh="ssh $sshOpts"

[ "$dailyMode" ] && daily=-d
if [ "$system" = xmq ]; then
    hosts=$xmqHosts
    systemName=XMQ
else
    hosts=$xmpushHosts
    systemName=XmPush
fi
for i in $hosts; do
    command="$shellDir/find-errors.sh -s $system $daily"
    execute "$ssh $i \"$command\" 2>&1 >/dev/null | sed \"s/^/$i: /\" &" $ecArgs
done
wait

preDate=$(date -d "1 days ago" +%Y%m%d)

execute "mkdir -p $dataDir $workDir" $ecArgs

if [ "$dailyMode" ]; then
    timeFlag=$preDate
else
    timeFlag=cur
fi
allFormatErrorLogsFile=$workDir/all-format-error-logs.$systemName.$timeFlag
fullFormatErrorLogsFile=$dataDir/$formatErrorLogsFile.$systemName.$timeFlag
fullErrorLogsFile=$dataDir/$errorLogsFile.$systemName.$timeFlag

execute "rm -rf $allFormatErrorLogsFile" $ecArgs
for i in $hosts; do
    file=$workDir/$formatErrorLogsFile.$systemName.$i.$timeFlag
    execute "if scp $i:$fullFormatErrorLogsFile $file &>/dev/null; then cat $file >> $allFormatErrorLogsFile; fi &" $ecArgs
    execute "scp $i:$fullErrorLogsFile $workDir/$errorLogsFile.$systemName.$i.$timeFlag &>/dev/null || true &" $ecArgs
done
wait

if [ "$dailyMode" ]; then
    subject="Error logs of $systemName($preDate)"
else
    subject="Error logs of $systemName(pseudo realtime)"
fi

if [ ! -e "$allFormatErrorLogsFile" ]; then
    message="No error logs found."
    logger_info "$message"
    echo "$message" | mail -s "$subject" "$mailLists"
    exit
fi

execute "sort $allFormatErrorLogsFile -k1,1 -k3,3 -t \"$separator\" | awk -f $shellDir/merge-error-logs.awk | sort -k1,1 -k2,2rn -t \"$separator\" > $fullFormatErrorLogsFile" $ecArgs

echo "All machines's error logs:" > $fullErrorLogsFile
execute "awk -f $shellDir/display-format-error-logs.awk $fullFormatErrorLogsFile | tee -a $fullErrorLogsFile" $ecArgs
echo >> $fullErrorLogsFile

for i in $hosts; do
    if [ ! -e $file ]; then
        continue
    fi
    
    echo "Machine $i's error logs:" >> $fullErrorLogsFile
    execute "cat $workDir/$errorLogsFile.$systemName.$i.$timeFlag >> $fullErrorLogsFile" $ecArgs
    echo >> $fullErrorLogsFile
done

mail -s "$subject" "$mailLists" < $fullErrorLogsFile
