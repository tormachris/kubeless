#!/bin/bash

functions=(hello isprime)
connections=(1000)
times=(1m)
kuberhost="node1:32631"
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

echo -e "Benchmarking GET functions\n"
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
                echo -e "Time: $time\n"
                echo -e "wrk"
                wrk -t$threads -c$connection -d$time -s$function.wrk -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/$function > ./$function.$connection.$time.wrk.txt 2>&1
                echo -e "hey"
                hey -c $connection -z $time -m POST -host "$function.kubeless" -D $function.body  -T "application/json" http://$kuberhost/$function > ./$function.$connection.$time.hey.txt
                date
        done
    done
done
