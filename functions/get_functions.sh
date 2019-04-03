#!/bin/bash

#TODO python3 kornyezetet hozzaadni es szukseg szerint mas kornyezeteket
# a function mappaban levo fajlokra meghivja a deploy_function.sh scriptet ugy,
# hogy a fuggveny neve a fajl neve kiterjesztes nelkul, es a handle neve a fajlban levo fuggveny neve
#TODO lehetne majd irni hozzairni hogy ha tobb func van egy fajlban akkor egy alapertelmezetett ad meg handle-kent

for x in *; do

  if [ $x = 'deploy_function.sh' ]; then 
  continue
  fi

  if [ $x = 'get_functions.sh' ]; then 
  continue
  fi

  echo "Deploying $x"
  
  ispython=$(echo $x | grep .py)
  #ispython3=$(cat $x | grep python3)
  isgolang=$(echo $x | grep .go)
  
  if [ ! $ispython = "" ]; then
	handle=$( cat $x | grep def | sed 's/def \(.*\)(.*/\1/' )	
	funcname=$( echo $x | sed 's/\(.*\)\.py/\1/')
	sh deploy_function.sh  python2.7 $x $funcname $handle
	echo "file name: $x"
	echo "function name: $funcname"
	echo "handle name: $handle"
  elif [ ! $isgolang = "" ]; then
	echo "goo handle elott: $x"
	handle=$( cat $x | grep 'func ' | sed 's/func \(.*\)(.*(.*/\1/' )
	funcname=$( echo $x | sed 's/\(.*\)\.go/\1/')
  	sh deploy_function.sh go1.10 $x $funcname $handle
	echo "file name: $x"
        echo "function name: $funcname"
        echo "handle name: $handle"
  fi
  
done

