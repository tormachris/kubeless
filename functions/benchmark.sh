#!/bin/bash

functions=(helloget matrix)

connections=(2 5 10 20 21 50 100 200 400 500 1000)

kuberhost="node1:32764"
WRK_INSTALLED=$(which wrk)
if [ "$WRK_INSTALLED" = "" ]
then
	sudo apt-get install build-essential libssl-dev git -y
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

for function in "${functions[@]}"
do
    echo -e "Benchmarking $function\n"
    for connection in "${connections[@]}"
    do
        if [[ $connection -lt 21 ]]
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
