# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Renames tv shows to a Show.S00E00.720p.mkv format

username="user"

cd /Users/$username/Do/c
clear
for f in ` ls | grep 'mkv'`;
do

	mv $f `echo ${f%.*} | tr -ds - . | grep -io '.*\.s[0-9][0-9]\.*e[0-9][0-9]'`.720p.mkv


done
