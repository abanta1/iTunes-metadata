#!/bin/bash
#Arranges TV Shows into proper subdirs

IFS=$'\n'


cd /Volumes/E\$/Movies
clear

find `pwd` -name '*.m4v' | while read file

do
	filepat=`echo "${file%/*}"/`
	fileext=`echo "${file##*/}" | tr ' ' '.'`
	filenoext=`echo "${file##*/}" | rev | cut -c 5- | rev`
	mkdir "$filenoext"
	mv "$file" "$filepat$filenoext/$fileext"
done