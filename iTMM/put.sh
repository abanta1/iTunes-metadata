#!/bin/bash
#Arranges TV Shows into proper subdirs

IFS=$'\n'
username="user"

cd /Users/$username/Add/TV
clear

find `pwd` -name '*.m4v' | while read file

do
	filepat=`echo "${file%/*}"/`
	fileext=`echo "${file##*/}"`
	eid=`echo "${file##*-}" | tr -d ' '`
	#eid=`echo "${preeid%%.*}"`
	sid=`echo "${eid%%E*}" | tr -d 'S[0]'`
	show=`echo "${fileext%%-*}" | rev | cut -c 2- | rev`
	
	echo "Moving ${fileext%%.*}"
	mv "$file" /Volumes/Media/TV\ Shows/$show/Season\ $sid/"$fileext"
done