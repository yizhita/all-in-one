#!/bin/bash

target=(`cat /home/monitor/host`)
#log_file=./log/ping.log
pint_count=10

save() {
    printf "%-22s%-18s%-10s%-10s\n" "$(date "+[%F %T]")" $1 ${2:+ploss=$2} ${3:+rtt=$3} >>/home/monitor/log/`date +%F`.log
}

test() {
    # echo "test latency and packet loss of $1"
    local pingReturn=$(ping -f -i ${PING_ITV:-1} -q -c ${pint_count:-100} -w 10 $1 2>/dev/null)
    local pLoss=$(echo $pingReturn | grep -o "[0-9.]\+% packet loss")
    local rtt=$(echo $pingReturn | grep -o "\/[0-9.]\+\/")
    [ -n "$pLoss" ] && {
        pLoss=${pLoss%%% packet loss}
    } || {
        pLoss=100
    }
    #pLoss=1
    [ -n "$rtt" ] && {
        rtt=${rtt#/}
        rtt=${rtt%/}
    } || {
        rtt=1000
    }
    save $1 $pLoss $rtt
}

while true; do
    save "-----------------------------------"
    for host in ${target[@]}; do
        test $host &
    done
    wait
done
