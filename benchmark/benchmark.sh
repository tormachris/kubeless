#!/bin/bash

functions=(hello)
connections=(2 5 10 20 50 100 200 400 500 1000)
times=(1m)
data=(isprime)
kuberhost="node1:32764"
maxthreads=160

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
    curl --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/$function
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
        	wrk -t$threads -d$time -c$connection -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/$function > ./$function.$connection.$time.txt 2>&1
		hey -z $time -c $connection -o csv -m POST -host "$function.kubeless" -T "application/json" http://$kuberhost/$function > $function.$connection.$time.csv
        done
    done
done

echo -e "Benchmarking POST functions\n"
for function in "${data[@]}"
do
    echo -e "Benchmarking $function\n"
    echo -e "Output of $function is:\n"
    perl -pi -e 'chomp if eof' $function.body
    curl --data-binary "@$function.body" --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/$function
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
        	wrk -t$threads -d$time -c$connection -s$function.wrk -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/$function > ./$function.$connection.$time.txt 2>&1
		hey -z $time -c $connection -o csv -m POST -host "$function.kubeless" -T "application/json" -D $function.body http://$kuberhost/$function > $function.$connection.$time.csv
        done
    done
done
