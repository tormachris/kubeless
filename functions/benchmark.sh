#!/bin/bash

functions=(helloget matrix)

connections=(2 5 10 20 21 50 100 200 400 500 1000)

kuberhost=""

for function in "${functions[@]}"
do
    echo -e "Benchmarking $function\n"
    for connection in "${connections[@]}"
    do
        if [[ $connection -lt 20 ]]
        then
            threads=$(($connection-1))
        else
            threads=20
        fi
        echo -e "Threads: $threads Connections $connection\n"
        wrk -t$threads -d1m -c$connection -H"Host: $function.cucc" -H"Content-Type:application/json" --latency  http://$kuberhost/$function > ./$function.$connection.txt 2>&1
        hey -n 10000 -c $connection -o csv -m GET -host "$function.kubeless" -T "application/json" http://$kuberhost/$function > $function.$connection.csv
    done
done
