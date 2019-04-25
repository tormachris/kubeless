#!/bin/bash

functions=(hello isprime hello-scale isprime-scale)
connections=(50)
times=(5m)
kuberhost="node1:30765"
maxthreads=40

WRK_INSTALLED=$(which wrk)
if [ "$WRK_INSTALLED" = "" ]
then
        apt update
        apt install build-essential libssl-dev git -y
        git clone https://github.com/wg/wrk.git wrk
        cd wrk
        make
        cp wrk /usr/local/bin
fi

HEY_INSTALLED=$(which hey)
if [ "$HEY_INSTALLED" = "" ]
then
        apt update
        apt install -y golang
        go get -u github.com/rakyll/hey
        cp $HOME/go/bin/hey /usr/local/bin
fi

echo -e "Benchmarking functions\n"
for function in "${functions[@]}"
do
    echo -e "Benchmarking $function\n"
    echo -e "Output of $function is:\n"
    perl -pi -e 'chomp if eof' $function.body
    curl --data-binary @$function.body --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/$function
    echo -e "\n"
    for connection in "${connections[@]}"
    do
        if [[ $connection -lt $(($maxthreads + 1)) ]]
        then
            threads=$(($connection-1))
        else
            threads=$maxthreads
        fi
        echo -e "Threads: $threads Connections $connection\n"
        for time in "${times[@]}"
        do
                datetime=$(date '+%Y-%m-%d-%H-%M-%S')
                if [[ $@ -eq *"--wave"* ]]
                then
                        while true; do
                                $now=$(date '+%Y-%m-%d-%H-%M')
                                hey -c $connection -z $time -m POST -o csv -host "$function.kubeless" -D $function.body  -T "application/json" http://$kuberhost/$function > ./$function.$connection.$time.$now.heywave.txt
                                sleep $time
                        done
                else
                        echo -e "Time: $time\n"
                        echo -e "wrk\n"
                        wrk -t$threads -c$connection -d$time -s$function.wrk -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/$function > ./$function.$connection.$time.$datetime.wrk.txt 2>&1
                        echo -e "hey-summary\n"
                        hey -c $connection -z $time -m POST -host "$function.kubeless" -D $function.body  -T "application/json" http://$kuberhost/$function > ./$function.$connection.$time.$datetime.hey.txt
                        echo -e "hey-csv\n"
                        hey -c $connection -z $time -m POST -o csv -host "$function.kubeless" -D $function.body  -T "application/json" http://$kuberhost/$function > ./$function.$connection.$time.$datetime.csv
                        echo -e "$datetime"
                fi
        done
    done
done
