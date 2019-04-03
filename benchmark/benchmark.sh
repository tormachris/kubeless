#!/bin/bash

functions=(hello)
# 5 10 20 50 100 200 400 500 1000
connections=(2)
times=(1m)
data=(isprime)
kuberhost="node1:32764"
maxthreads=160
wrk_options=(-t$threads -d$time -c$connection -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/$function)
wrk_output=$function.$connection.$time.txt
hey_options=(-c $connection -z $time -o csv -m POST -host "$function.kubeless" -T "application/json" http://$kuberhost/$function)
hey_output=$function.$connection.$time.csv

array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

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
    array_contains data function && perl -pi -e 'chomp if eof' $function.body
    curl_additional_options=$(array_contains data function && "--data-binary \"@$function.body\"")
    curl $curl_additional_options --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/$function
    echo -e "\n"
    wrk_additional_options=$(array_contains data function && "-s$function.wrk")
    hey_additional_options=$(array_contains data function && "-D $function.body")
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
        	wrk "${wrk_options[@]}" $wrk_additional_options > "${$wrk_output}" 2>&1
		hey "${hey_options[@]}" $hey_additional_options > "${$hey_output}
        done
    done
done
