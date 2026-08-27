# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Finds movie name and downloads appropriate artwork from iTunes store

username="user"
cd /Volumes/Data/Add
pd=`pwd`

for f in `find $pd | grep -E '.*\.mp4|.*\.m4v'`;

do

	fileext=`echo ${f##*/}`
#echo $fileext

	filenoext=${fileext%.*}
#echo $filenoext
	filepat=`echo ${f%/*}/`
#echo $filepat
	fileshownamea=${fileext%.*}
#echo $fileshownamea a
	fileshownameb=${fileshownamea%.*}
#echo $fileshownameb b
	fileshownamec=${fileshownameb%.*}
#echo $fileshownamec c
	fileshownamed=${fileshownamec%.*}
#echo $fileshownamed d
	fileshownamee=${fileshownamed%.*}
#echo $fileshownamee e
#	fileshownamef=${fileshownamee%.*}
#echo $fileshownamef f

if [ ! "`echo $fileshownamee | grep -Eo [12][0-9]{3}`"  == "" ] ; then
	movieyear=`echo $fileshownamee | grep -Eo [0-9]{4}`
#	echo $movieyear year
fi
	fileshowname=${fileshownamee%.*}

#echo $fileshowname$'\n\n'



curl itunes.apple.com/search?term=$fileshowname\&entity=movie 2>&1 | grep -E "releaseDate\":\"$movieyear" | \
		grep -Eom 1 'artworkUrl100":"http://.*?100x100-75.jpg' | cut -c 17- | sed s/100x100/600x600/ | \
		xargs wget --output-document=/Users/$username/Desktop/$fileshowname.jpg 2&> /dev/null && echo Dowloaded $fileshowname.jpg
done
