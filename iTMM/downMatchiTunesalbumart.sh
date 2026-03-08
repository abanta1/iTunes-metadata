#!/bin/bash
#Reads iTunes TrackID from inside iTunes files and displays relative information to the screen
#
#Usage:
#./trackid.sh < (file)

username="user"
echo
echo
IFS=$'\n'
for f in $@;
	do
	#fileext=`echo ${f##*/}`
	#filenoext=${fileext%.*}
	filepat=`echo ${f%/*}/`

# Gets Track ID from inside file
fileid=`head -c 1024 "$f" | xxd -p | tr -d '\n' | grep -Eo '736f6e67.{0,8}' | cut -c 9-`
trkid=$((0x`echo $fileid`))

# Gets Info from iTunes
curl http://itunes.apple.com/lookup?id=$trkid\&country=us &> .$trkid

# Downloads artwork from iTunes
artwk=$(cat ./.$trkid | grep -Eo '"artworkUrl100":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 8- | rev | cut -c 2- | rev | sed s/100x100/600x600/ ) # | xargs wget --output-document=/Users/$username/Desktop/art.jpg)
wget $artwk --output-document=`echo $filepat`art.jpg 2&> /dev/null & echo Dowloaded cover


echo $filepat >> ~/Desktop/filepath.txt
rm .$trkid
done