#!/bin/bash

#TODO golang sed nem mukodik
#TODO python3 kornyezetet hozzaadni es szukseg szerint mas kornyezeteket

for x in *; do

if [ $x != "deploy_function.sh" ]; then 
  echo "Deploying $x"
  
  ispython=$(echo $x | grep .py)
  #ispython3=$(cat $x | grep python3)
  isgolang=$(echo $x | grep .go)
  

  #if [ -n $ispython3 ]; then
  #	handle=$( cat $x | grep def | sed 's/def \(.*\)(/\1/') 
  #	funcname=$( echo $x | sed 's/\(.*\)\.py/\1/')
  #	#sh deploy_function.sh  python3.6 $x $funcname $handle
  #	echo "$x $funcname $handle"
  #     echo "python3"	
  if [ -n $ispython ]; then
	handle=$( cat $x | grep def | sed 's/def \(.*\)(.*/\1/' )	
	funcname=$( echo $x | sed 's/\(.*\)\.py/\1/')
	#sh deploy_function.sh  python2.7 $x $funcname $handle
	echo "$x $funcname $handle"
  elif [ -n $isgolang ]; then
	handle=$( cat $x | grep 'func ' | sed 's/func \(.*\)(.*/\1/') #TODO debugging
	funcname=$( echo $x | sed 's/\(.*\)\./\1/')
  	#sh deploy_function.sh go1.10 $x $funcname $handle
	echo "$x $funcname $handle"
  fi
fi  
done

