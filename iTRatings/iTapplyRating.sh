#!/bin/bash
# Gets info from explicit.txt and applies ratings to music files

while read lines
do
	trkid=`echo -e "$lines" | cut -d '-' -f1 | sed 's/^ *//g' | sed 's/ *$//g'`
	diskNumber=`echo -e "$lines" | cut -d '-' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`
	trackNumber=`echo -e "$lines" | cut -d '-' -f3 | sed 's/^ *//g' | sed 's/ *$//g'`
	artistName=`echo -e "$lines" | cut -d '-' -f4 | sed 's/^ *//g' | sed 's/ *$//g'`
	albartName=`echo -e "$lines" | cut -d '-' -f5 | sed 's/^ *//g' | sed 's/ *$//g'`
	albumName=`echo -e "$lines" | cut -d '-' -f6 | sed 's/^ *//g' | sed 's/ *$//g'`
	trackName=`echo -e "$lines" | cut -d '-' -f7 | sed 's/^ *//g' | sed 's/ *$//g'`
	trackExp=`echo -e "$lines" | cut -d '-' -f8 | sed 's/^ *//g' | sed 's/ *$//g'`

	
	if [ "$trackNumber" -lt "10" ] ; then
		trackNumber=`echo 0$trackNumber`
	fi
	
	if [ "$albartName" == "" ] ; then
		albartName=`echo $artistName`
	fi

	#echo TDI $trkid
	#echo TU $trackNumber
	#echo AN $artistName
	#echo AAN $albartName
	#echo ALN $albumName
	#echo TN $trackName
	#echo TE $trackExp
	
	
	if [ "$diskNumber" == "" ] ; then
		filepat=(/Volumes/Data/iTunes/iTunes\ Media/Music/"$albartName"/"$albumName"/"$trackNumber"\ "$trackName"*)
	else
		filepat=(/Volumes/Data/iTunes/iTunes\ Media/Music/"$albartName"/"$albumName"/"$diskNumber"-"$trackNumber"\ "$trackName"*)
	fi
	

	
	if [ ! -f "$filepat" ];
	then
		#echo AtomicParsley "$filepat" --advisory $trackExp --overWrite >> ~/Desktop/error.log;
		echo "$trkid - $albartName / $albumName / $diskNumber - $trackNumber / $trackName - $trackExp"  >> ~/Desktop/error.log;
		#echo "$trkid - $artistName - $albumName - $trackName";
	else
#		echo "$albartName" - "$albumName" - "$trackName"
		AtomicParsley "$filepat" --advisory $trackExp --overWrite | grep -Eo 'Finished.*'
#		if [ $? != 0 ]; then
#			echo error $?
#		fi
	fi

done < ~/Desktop/explicit.txt
exit