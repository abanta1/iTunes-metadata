# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Finds moie name and downloads appropriate artwork from iTunes store

IFS=$'\n'
cd /Volumes/Data/Add
pd=`pwd`
username="user"

for f in `find $pd | grep -E '.*\.mp4|.*\.m4v'`;# | grep -Ei 'human'`;

do

#echo $f - " f"
	fileext=`echo ${f##*/}`
#echo $fileext " - fileext"

	filenoext=${fileext%.*}
#echo $filenoext " - filenoext"
	filepat=`echo ${f%/*}/`
#echo $filepat " - filepat"



# If parenthesis exist, remove them
if [ "`echo $filenoext | grep -o '('`" == "(" ] ; then
	isparent="true"
	filenoext1=`echo $filenoext | sed "s/[()]//g"`
else
	isparent="false"
	filenoext1=`echo $filenoext`
fi
#echo $isparent - " parent"
#echo $filenoext1 - " noparent"



# If there is episode ID, set episd, season number, and remove episd
if [ ! "`echo $filenoext1 | grep -Eoi '\.s?[0-9]{0,2}\.?e[0-9]{1,3}'`" == "" ] ; then
	episd=`echo $filenoext1 | grep -Eoi '\.s?[0-9]{0,2}\.?e[0-9]{1,3}' | tr -d '.'`
	fileshownameepid=`echo $filenoext1 | grep -Eoi ".*.$episd"`
#echo $fileshownameepid - " fsnepid"
	fileshowname=`echo $fileshownameepid | sed "s/.$episd//"`
	ssnnum=`echo $episd | grep -Eoi 's[0-9]{2}' | cut -c 2-`
	if [ "$ssnnum" -gt 9 ] ; then continue; else ssnnum=`echo $ssnnum | cut -c 2-` ; fi
	
	# If year, set and remove
	if [ ! "`echo $fileshowname | grep -Eo '[12][0-9]{3}'`" == "" ] ; then
		fileyear=`echo $fileshowname | grep -Eo '[12][0-9]{3}'`
		fileshowname=`echo $fileshowname | sed "s/\.$fileyear.*//"`
		fileyear=""
	else
		fileshowname=`echo $fileshowname`
	fi
else

# If year exist, set year and remove it
if [ ! "`echo $filenoext1 | grep -Eo [12][0-9]{3}`" == "" ] ; then
	fileyear=`echo $filenoext1 | grep -Eo [12][0-9]{3}`
	filenoext2=`echo $filenoext1 | sed "s/\.$fileyear.*//"`
else
	filenoext2=`echo $filenoext1`
fi
fileshowname=`echo $filenoext2`

#echo $fileyear - " fy"
#echo $filenoext2 - " noparentnoyear"


fi
#echo $fileyear - " fy"



#echo $fileshowname " - fsn"
#echo $episd " - id"

# Is it TV or Movie
if [ "$episd" == "" ] ; then entityv="movie"; else entityv="tvSeason"; fi
#echo $entityv " - tv?"

if [ "$ssnnum" == "" ] ; then
	opfile="$fileshowname.jpg"
else
	opfile="$fileshowname.$ssnnum.jpg"
fi


fileshownamenew=`sed 's/[ \.]/+/g' <<< $fileshowname`

result=`curl itunes.apple.com/search?term=$fileshownamenew\&entity=$entityv 2>&1`
rescount=`echo $result | grep -o '\"resultCount\":0'`

echo $result
echo $fileyear
echo $entityv
echo $ssnnum


if [ "$rescount" == "\"resultCount\":0" ] ; then echo "No results for $fileshownamenew"; continue; fi
		

#curl itunes.apple.com/search?term=$fileshownamenew\&entity=$entityv 2>&1 | \
echo $result | \
		if [ ! "$fileyear" == "" ] ; then grep -E "releaseDate\":\"$fileyear"; else grep ':'; fi | \
		if [ "$entityv" == "tvSeason" ] ; then grep "Season $ssnnum"; else grep ':'; fi | \
		grep -Eom 1 'artworkUrl100":"http://.*?100x100-75.jpg' | cut -c 17- | sed s/100x100/600x600/ | \
		xargs wget --output-document=/Users/$username/Desktop/$opfile 2&> /dev/null & echo Dowloaded $opfile

f=""
fileext=""
filenoext=""
filepat=""
isparent=""
fileshowname=""
fileyear=""
ssnnum=""
episd=""
entityv=""
#echo "---"
done
