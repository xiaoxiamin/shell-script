#!/bin/bash

#nagios exit code
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

help () {
        local command=`basename $0`
        echo "NAME
        ${command} -- check slave active number
SYNOPSIS
        ${command} [OPTION]
DESCRIPTION
        -w warning=<percent>
        -c critical=<percent>
        -m mesosIP=<percent>
USAGE:
        $0 -w 20 -c 10" 1>&2
        exit ${STATE_WARNING}
}

check_num () {
        local num_str="$1"
        echo ${num_str}|grep -E '^[0-9]+$' >/dev/null 2>&1 || local stat='not a positive integers!'
        if [ "${stat}" = 'not a positive integers!' ];then
                echo "${num_str} ${stat}" 1>&2
                exit ${STATE_WARNING}
        else
                local num_int=`echo ${num_str}*1|bc`
                if [ ${num_int} -lt 0 ];then
                        echo "${num_int} must be greater than 0!" 1>&2
                        exit ${STATE_WARNING}
                fi
        fi
}

#input
while getopts m:w:c: opt
do
        case "$opt" in
        m)
                masterIP=`echo $OPTARG |sed 's/,/\n/g'`
                for i in $masterIP
                do
                        tmpLeader=`curl http://$i:5050/registrar\(1\)/registry -s |python -m json.tool |grep master@|awk -F ':' '{print $2}'|awk -F '@' '{print $2}'`
                        if [ ! -z $tmpLeader ]
                        then mesosLeader=$tmpLeader
                        break
                        fi
                done
                slaves_num=`curl http://$mesosLeader:5050/metrics/snapshot -s| python -m json.tool|grep slaves_active|grep  -o '[0-9]\{1,3\}\.[0-9]' |awk -F '.' '{print $1}'`

        ;;
        w)
                warning=$OPTARG
                warning_num=`echo "${warning}"|sed  's/%//g'`
                check_num "${warning_num}"
        ;;
        c)
                critical=$OPTARG
                critical_num=`echo "${critical}"|sed  's/%//g'`
                check_num "${critical_num}"
        ;;
        *) help;;
        esac
done
shift $[ $OPTIND - 1 ]

[ $# -gt 0 -o -z "${warning_num}" -o -z "${critical_num}" ] && help

if [ -n "${warning_num}" -a -n "${critical_num}" ];then
        if [ ${critical_num} -gt ${warning_num} ];then
                echo "-w ${critical} must lower than -c ${warning}!" 1>&2
                exit ${STATE_UNKNOWN}
        fi
fi



message () {
local stat="$1"
echo "slave_active is ${stat} - slave_active_number : $slaves_num"
}

[ ${slaves_num} -gt ${warning_num} ] && message "OK" && exit ${STATE_OK}
[ ${slaves_num} -le ${critical_num} ] && message "Critical" && exit ${STATE_CRITICAL}
[ ${slaves_num} -le ${warning_num} ] && message "Warning" && exit ${STATE_WARNING}
