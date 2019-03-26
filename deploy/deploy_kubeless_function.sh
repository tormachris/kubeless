#!/bin/bash
#$1=runtime
#$2=filename
#$3=function name

FILENAME=cut $2 -d"." -c2
kubeless function deploy $3 --runtime $1 --from-file $2 --handler $FILENAME.$3
kubeless trigger http create $3--function-name $3 --path $3 --hostname $3.kubeless

#Test with curl --data '{"Another": "Echo"}' --header "Host: get-python.192.168.99.100.nip.io" --header "Content-Type:application/json" 192.168.99.100/echo
