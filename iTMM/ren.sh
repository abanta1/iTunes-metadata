# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Renames TV Shows from iTunes (1-02 Title.m4v) into standard (Show - S01E01.m4v)

IFS=$'\n'


cd /Volumes/Media/TV\ Shows
clear

find "`pwd`" -name '*.m4v' | while read file

do
	fileext=`echo "${file##*/}"`		#1-02 Blah.m4v
	isdone=`expr "$fileext" : '.*\(S[0-9][0-9]E[0-9][0-9]\).*'`
	if [ -n "$isdone" ]
		then
		echo "Skipping "$fileext
		continue
	fi
	
	ext=`echo "${fileext##*.}"`			#m4v
	filepat=`echo "${file%/*}"/`		#.../Arrow/Season 1/
	sfilepat=`echo "${file%/*}"`		#.../Arrow/Season 1
	ssfilepat=`echo "${sfilepat%/*}"`	#.../Arrow

	seas=`echo "${sfilepat##*/}"`		# Season 1
	snum=`echo $seas | cut -c 8-`		# 1
	if test $snum -lt 10; then snum="0"$snum; fi
	show=`echo "${ssfilepat##*/}"`		# Arrow
	
	eptit=`echo "${fileext#*-}"`		#02 Blah.m4v

	epnum=`echo "${eptit%% *}"`			# 02
	
	echo "Renaming ${fileext%%.*}"
	mv "$file" "$filepat$show - S$snum""E$epnum.m4v"
	
done

echo "Done"
