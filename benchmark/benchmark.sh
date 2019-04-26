#!/bin/bash

functions=(isprime-scale)
connections=(50)
times=(1m)
kuberhost="node1:30765"
maxthreads=40

wave_dir_up=true
wave_connection=40
wave_max_conn=160
wave_min_conn=40
wave_time="1m"
wave_loop=1
wave_loop_max=2

WRK_INSTALLED=$(command -v wrk)
if [[ $WRK_INSTALLED = "" ]]
then
        apt update
        apt install build-essential libssl-dev git -y
        git clone https://github.com/wg/wrk.git wrk
        cd wrk || exit
        make
        cp wrk /usr/local/bin
fi

HEY_INSTALLED=$(command -v hey)
if [[ $HEY_INSTALLED = "" ]]
then
        apt update
        apt install -y golang
        go get -u github.com/rakyll/hey
        cp "$HOME"/go/bin/hey /usr/local/bin
fi

echo -e "Benchmarking functions\n"
for function in "${functions[@]}"
do
    echo -e "Benchmarking $function\n"
    if [[ $* = *"--wave"* ]]
    then
        while [[ $wave_loop -lt $wave_loop_max ]]; do
                now=$(date '+%Y-%m-%d-%H-%M')
                echo -e "Running"
                hey -c $wave_connection -z $wave_time -m POST -o csv -host "$function.kubeless" -D "$function".body  -T "application/json" http://$kuberhost/"$function" > ./"$function"."$wave_connection"."$now".wave.csv
                echo -e "Sleeping"
                sleep $wave_time
                if [[ $wave_dir_up ]]
                then
                        if [[ $wave_connection -lt $wave_max_conn ]]
                        then
                            wave_connection=$((wave_connection * 2))
                        else
                            wave_dir_up=false
                        fi
                else
                    if [[ $wave_connection -gt $wave_min_conn ]]
                    then
                        wave_connection=$((wave_connection / 2))
                    else
                        wave_dir_up=true
                        wave_loop=$((wave_loop + 1))
                    fi
                fi
        done
    else
        echo -e "Output of $function is:\n"
        perl -pi -e 'chomp if eof' "$function".body
        curl --data-binary @"$function".body --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/"$function"
       echo -e "\n"
        for connection in "${connections[@]}"
        do
            if [[ $connection -lt $((maxthreads + 1)) ]]
            then
                threads=$((connection-1))
            else
                threads=$maxthreads
            fi
            echo -e "Threads: $threads Connections $connection\n"
                for time in "${times[@]}"
            do
                    datetime=$(date '+%Y-%m-%d-%H-%M-%S')
                    echo -e "Time: $time\n"
                    echo -e "wrk\n"
                    wrk -t$threads -c"$connection" -d"$time" -s"$function".wrk -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/"$function" > ./"$function"."$connection"."$time"."$datetime".wrk.txt 2>&1
                    echo -e "hey-summary\n"
                    hey -c "$connection" -z "$time" -m POST -host "$function.kubeless" -D "$function".body  -T "application/json" http://$kuberhost/"$function" > ./"$function"."$connection"."$time"."$datetime".hey.txt
                    echo -e "hey-csv\n"
                    hey -c "$connection" -z "$time" -m POST -o csv -host "$function.kubeless" -D "$function".body  -T "application/json" http://$kuberhost/"$function" > ./"$function"."$connection"."$time"."$datetime".csv
                    echo -e "$datetime"
            done
        done
    fi
done
