#!/bin/bash
#$1=runtime
#$2=filename
#$3=function name
#$4=handler

kubeless function deploy $3 --runtime $1 --from-file $2 --handler $4
kubeless trigger kafka create $3 --function-selector created-by=kubeless,function=$3 --trigger-topic "$3-topic"

#Test from within cluster
#kubeless topic publish --topic "$3-topic" --data "Hello World!"
