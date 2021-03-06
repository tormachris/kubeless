#!/usr/bin/env bash
#Requirements:
#<function name without dashes>.wrk descriptor file for wrk
#<function name without dashes>.body (even if you don't need it)

#Configuration variables
functions=(isprime-scale isprime-scale-py isprime-scale-js hello-scale hello-scale-py hello-scale-js hello hello-js hello-py isprime isprime-js isprime-py)
connections=(1000)
times=(1m)
kuberhost="node1:30765"
maxthreads=40
#Wave mode configuration
wave_connection=40
wave_max_conn=160
wave_min_conn=40
wave_time="1m"
wave_loop_max=2

WRK_INSTALLED=$(command -v wrk)
if [[ $WRK_INSTALLED = "" ]]
then
        apt update
        apt install build-essential libssl-dev git -y
        git clone https://github.com/wg/wrk.git wrk
        cd wrk || exit
        cores=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
        make -j $((cores + 1))
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
    function_friendly=$(echo $function | cut - -d'-' -f1)
    echo -e "Benchmarking $function\n"
    echo -e "Output of $function is:\n"
    perl -pi -e 'chomp if eof' "$function_friendly".body
    curl --data-binary @"$function_friendly".body --header "Host: $function.kubeless" --header "Content-Type:application/json" http://$kuberhost/"$function"
    echo -e "\n"
    if [[ $* = *"--wave"* ]]
    then
        wave_loop=1
        wave_dir_up=true
        while [[ $wave_loop -lt $wave_loop_max ]]; do
                now=$(date '+%Y-%m-%d-%H-%M')
                echo -e "Connections: $wave_connection"
                echo -e "Running"
                hey -c $wave_connection -z $wave_time -m POST -o csv -host "$function.kubeless" -D "$function_friendly".body  -T "application/json" http://$kuberhost/"$function" > ./data/"$function"."$wave_connection"."$now".wave.csv
                if $wave_dir_up
                then
                        if [[ $wave_connection -lt $wave_max_conn ]]
                        then
                            echo -e "Stepping up"
                            wave_connection=$((wave_connection * 5))
                        else
                            echo -e "Not stepping"
                            wave_dir_up=false
                        fi
                else
                    if [[ $wave_connection -gt $wave_min_conn ]]
                    then
                        echo -e "Stepping down"
                        wave_connection=$((wave_connection / 5))
                    else
                        echo -e "Not stepping"
                        wave_dir_up=true
                        wave_loop=$((wave_loop + 1))
                    fi
                fi
        done
    else
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
                    if [[ $* = *"--wrk"* ]]
                    then
                        echo -e "wrk $datetime\n"
                        wrk -t$threads -c"$connection" -d"$time" -s"$function_friendly".wrk -H"Host: $function.kubeless" -H"Content-Type:application/json" --latency  http://$kuberhost/"$function" > ./data/"$function"."$connection"."$time"."$datetime".wrk.txt 2>&1
                    fi
                    if [[ $* = *"--hey"* ]]
                    then
                        echo -e "hey-summary $datetime\n"
                        hey -c "$connection" -z "$time" -m POST -host "$function.kubeless" -D "$function_firendly".body  -T "application/json" http://$kuberhost/"$function" > ./data/"$function"."$connection"."$time"."$datetime".hey.txt
                    fi
                    if [[ $* = *"--csv"* ]]
                    then
                        echo -e "hey-csv $datetime\n"
                        hey -c "$connection" -z "$time" -m POST -o csv -host "$function.kubeless" -D "$function_friendly".body  -T "application/json" http://$kuberhost/"$function" > ./data/"$function"."$connection"."$time"."$datetime".csv
                    fi
                    echo -e "Finished at $datetime"
            done
        done
    fi
done

python3 ./data/process.py > ./data/processed.txt
