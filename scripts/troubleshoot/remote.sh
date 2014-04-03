#!/usr/bin/env bash

# Time-stamp: <2014-02-21 11:52:14 Friday by ahei>

readonly PROGRAM_NAME="remote.sh"
readonly PROGRAM_VERSION="1.0"

home=`cd $(dirname "$0") && pwd`

. "$home"/util.sh

usage()
{
    code=1
    if [ $# -gt 0 ]; then
        code="$1"
    fi

    if [ "$code" != 0 ]; then
        redirect="1>&2"
    fi

    eval cat "$redirect" << EOF
usage: ${PROGRAM_NAME} [OPTIONS] <HOST> <COMMAND>
       ${PROGRAM_NAME} [OPTIONS] -H <HOST> <COMMAND>
       ${PROGRAM_NAME} [OPTIONS] -c <COMMAND> <HOSTS>
       ${PROGRAM_NAME} [OPTIONS] -f <HOSTS_FILE> <COMMAND>
       ${PROGRAM_NAME} [OPTIONS] -F <FILE> [-d <DST_FILE>] <HOSTS>

Options:
    -H <HOST>
        Add host.
    -f <HOSTS_FILE>
        Add the hosts file.
    -c <COMMAND>.
        Set command to run.
    -C <COMMAND_FILE>
        Read command from file.
    -F <LOCAL_FILE>
        Add the local file to copy.
    -d <DST_FILE>
        Set the destination file.
    -l <LOGIN_NAME>
        Specifies the user to log in as on the remote machine.
    -n  Do not really execute command, only print command to execute.
    -V  Output command to be executed to standard output.
    -s  When execute commands failed, stop execute other commands and exit.
    -g  Execute command foreground.
    -i [<INSTALL_DIR>]
        Install this shell script to your machine, INSTALL_DIR default is /usr/bin.
    -o SSH_OPTIONS
        Set ssh options.
    -V  Show verbose info.
    -v  Output version info.
    -h  Output this help.
EOF

    exit "$code"
}

isExecute=1
IFS=$'\n'
background="&"
isQuiet=1

while getopts ":hvH:f:F:d:l:nVc:sigo:C:" OPT; do
    case "$OPT" in
        H)
            hosts="$hosts\n$OPTARG"
            ;;

        f)
            if [ ! -r "$OPTARG" ]; then
                echoe "Can not read file \`$OPTARG'."
                usage
            fi
            
            hosts="$hosts\n`cat $OPTARG`"
            ;;

        F)
            if [ ! -r "$OPTARG" ]; then
                echoe "Can not read file \`$OPTARG'."
                usage
            fi

            isCopy=1
            files="$files $OPTARG"
            ;;

        d)
            dstFile="$OPTARG"
            ;;
            
        l)
            user="$OPTARG"
            ;;

        n)
            isExecute=0
            ;;

        V)
            isQuiet=0
            ;;

        c)
            command="$OPTARG"
            ;;

        C)
            command="$(cat $OPTARG)"
            ;;

        s)
            isStop=1
            ;;

        g)
            background=
            ;;

        i)
            install
            ;;

        o)
            sshOptions="$OPTARG"
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

shift $((OPTIND - 1))

sshOpts="-o StrictHostKeyChecking=no $sshOptions"
ssh="ssh $sshOpts"
scp="scp $sshOpts"

if [ -z "$isCopy" ]; then
    if [ -z "$hosts" ]; then
        if [ "$#" -lt 1 ]; then
            echoe "No host and command specify.\n"
            usage
        elif [ "$#" -lt 2 ]; then
            echoe "No command specify.\n"
            usage
        fi

        if [ -n "$command" ]; then
            for i in $@; do
                hosts="$hosts\n$i"
            done
        else
            hosts="$hosts\n$1"
            shift
            command="$@"
        fi
    else
        if [ "$#" -lt 1 -a ! "$command" ]; then
            echoe "No command specify.\n"
            usage
        fi

        if [ -n "$command" ]; then
            for i in $@; do
                hosts="$hosts\n$i"
            done
        else
            command="$@"
        fi
    fi

    commandEscaped=$(echo "$command" -n | sed 's/"/\\"/g')
    for i in `printf "$hosts"`; do
        [ -n "$user" ] && login=" -l $user"
        executeCommand "$ssh $i$login \"$commandEscaped\" 2>&1 | sed \"s/^/$i: /\" $background" "$isExecute" "$isQuiet" "$isStop"
    done

    wait
    
    exit
fi

IFS=
for i in $@; do
    hosts="$hosts\n$i"
done

IFS=$'\n'
for i in `printf "$hosts"`; do
    if [ -z "$user" ]; then
        host="$i"
    else
        host="$user@$i"
    fi

    executeCommand "$scp -r $files $host:$dstFile 2>&1 | sed \"s/^/$i: /\" $background" "$isExecute" "$isQuiet" "$isStop"
done

wait
