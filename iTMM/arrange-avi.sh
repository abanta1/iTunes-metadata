# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Arranges TV Shows into proper subdirs

IFS=$'\n'
username="user"

cd /Users/$username/Done
clear

find `pwd` -name '*.avi' | while read file

do
	filepat=`echo "${file%/*}"/`
	fileext=`echo "${file##*/}" | tr ' ' '.'`
	
	mv "$file" $filepat$fileext
done


find . -name '*.avi' | while read file
do
mv "$file" ../Do/
done

cd /Users/$username/Do
clear

for f in `ls -rS | grep -i '.mkv\|.avi'`;
do

trimmed=`echo "${f%.*}" | grep -io '.*\.s[0-9][0-9]'`
trimmed=`echo "${trimmed%.*}"`

if [ "$trimmed" == "" ]; then
	continue
else
	if [ ! -d "$trimmed" ]; then
		mkdir "$trimmed"
		mv "$f" "$trimmed"/"$f"
	else
		mv "$f" "$trimmed"/"$f"
	fi
fi
done
