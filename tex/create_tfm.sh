#!/bin/bash

if [ -e ./temp ]
then
	echo "./temp already exists!"
	exit 0
fi

while [ 0 ]
do
	read i
	if [ "$i" == "" ] 
	then
		break
	fi
	j=${i##*/}
	k=${j%.*}
	echo "$k:$i"
done
