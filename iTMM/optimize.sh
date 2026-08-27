# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Optimizes videos

username="user"

if [ ! -d /Volumes/RAMDisk ]; then
diskutil erasevolume HFS+ 'RAMDisk' `hdiutil attach -nomount ram://16777217` 1> /dev/null
if [ ! -d /Volumes/RAMDisk ]; then
exit
fi
else
echo "unmount /Volumes/RAMDisk and rerun"
exit 1
fi

if [ ! -d /Volumes/E\$ ]; then
mkdir /Volumes/E\$
passwd=`security find-internet-password -s media -a $username -w`
mount_smbfs //$username:$passwd@media/E\$ /Volumes/E\$
fi

IFS=$'\n'

#cd ~/Do
cd /Volumes/E\$/Movies
clear


find `pwd` -name '*.m4v' | while read file
do
filepat=`echo "${file%/*}"/`
fileext=`echo "${file##*/}"`
#echo /"$filepat"."$fileext".
if [ ! -f /"$filepat"."$fileext". ]; then
ffmpeg -nostdin -i "$file" -movflags faststart -acodec copy -vcodec copy /Volumes/RAMDisk/"$fileext" -y

if [ "$?" -eq 0 ] ; then
	mp4art --add /"$filepat"*.jpg /Volumes/RAMDisk/"$fileext"
	mv "$file" "$filepat""2 ""$fileext"
	rsync /Volumes/RAMDisk/"$fileext" "$file" --append-verify --progress --remove-source-files
	touch /"$filepat"."$fileext".
#	rm "$file"
#	mv /Volumes/RAMDisk/"$fileext" "$file"
else
	exit 1
fi
fi
done
