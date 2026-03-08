#!/bin/bash
# Applies artwork in current dir to files (writen for iTunes Library (music))
# Uses:
# /usr/local/bin/mp4art
# mp4art --add *.jpg *.m4a
#
# iTunes:
# Clear Downloaded artwork
# Download artwork
#
# Dougscript:
# Extract artwork
#
# Usage
# ./iTembedMusicArt.sh /path/to/file1.m4a /path/to/file2.m4a ...

if [ ! -e /usr/local/bin/mp4art ]; then
	echo "mp4art is missing or not installed"
	echo "Make sure its in /usr/local/bin/mp4art"
	exit
fi

IFS=$'\n'
pd=`pwd`

for f in $@;
#for f in `find $pd | grep m4a`;
	do
	fileext=`echo ${f##*/}`
	filenoext=${fileext%.*}
	filepat=`echo ${f%/*}/`
	
	if [ ! -e `echo $filepat*.jpg` ]; then
		continue
	else
		mp4art --add `ls $filepat*.jpg` $f
	fi

done