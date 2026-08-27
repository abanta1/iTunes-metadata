# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Finds all mkv/avi files in dir and encodes to m4v

IFS=$'\n'
username="user"

if [ ! -e ~/Applications/HandBrakeCLI ]; then
	echo "Handbrake CLI is missing or not installed"
	echo "Make sure its in ~/Applications/Add On/Video/HandBrakeCLI"
else

cd /Users/$username/Do
clear

#no subdirs
#for f in `ls -rRS | grep .mkv`;

#with subdirs
pd=`pwd`
filecount=`find $pd | grep '.mkv\|.avi' | wc -l | tr -d " "`
indexcount=0
for f in `find $pd | grep '.mkv\|.avi'`;

do
	indexcount=`expr $indexcount + 1`
	fileext=`echo ${f##*/}`
	filenoext=${fileext%.*}
	filepat=`echo ${f%/*}/`
	
	starth=`date +%H`;
	startm=`date +%M`;
	starts=`date +%S`;
	starttime=`date +%s`;
#nosubdir	enctxt=$(echo "Encoding for ${f%.*}" | grep -io '.*\.s[0-9][0-9]\.*e[0-9][0-9]' | tr '[.]' '\ ')
	if [ "`echo $filenoext | grep -io '.*\.s*[0-9]*\.*e[0-9][0-9]'`" == "" ] ; then
		
		if [ ! "`echo $filenoext | grep -Eo [12][0-9]{3}`" == "" ] ; then
			fileyear=`echo $filenoext | grep -Eo [12][0-9]{3} | head -1`
			filenoext=`echo $filenoext | sed "s/\.$fileyear.*//"`
		fi		

		enctxt=$(echo "Encoding for $filenoext ($fileyear)" | tr '[.]' '\ ')
	else
		enctxt=$(echo "Encoding for $filenoext" | grep -io '.*\.s*[0-9]*\.*e[0-9][0-9]' | tr '[.]' '\ ')
	fi
	
	echo $enctxt" started at $starth:$startm:$starts     "$indexcount" of "$filecount"";

#nosubdir	/Applications/HandBrakeCLI -Z "AppleTV 3" -i $f -o /Volumes/Data/Add/TV/${f%.*}.m4v 2> /dev/null;
	~/Applications/HandBrakeCLI -Z "AppleTV 3" -O -i $f -o /Users/$username/Add/Enc/$filenoext.m4v 2> /dev/null;
	mv /Users/$username/Add/Enc/$filenoext.m4v /Users/$username/Add/TV/$filenoext.m4v	
	
	
	#${f##*/}
	
	finishh=`date +%H`;
	finishm=`date +%M`;
	finishs=`date +%S`;
	finishtime=`date +%s`;
	
	totaltime=`expr $finishtime - $starttime`;
	days=0
	hours=0
	mins=0
	secs=$totaltime

	if [ "$totaltime" -gt "60" ]; then
		mins=$((totaltime/60));
		secs=$((totaltime-(mins*60)));
	fi

	if [ "$totaltime" -gt "3600" ]; then
		hours=$((totaltime/3600));
		mins=$(((totaltime-((hours*3600)))/60));
		secs=$((totaltime-((hours*3600)+(mins*60))));
	fi

	if [ "$totaltime" -gt "86400" ]; then
		days=$((totaltime/86400)); 
		hours=$(((totaltime-(days*86400))/3600));
		mins=$(((totaltime-((days*86400)+(hours*3600)))/60));
		secs=$(((totaltime-((days*86400)+(hours*3600)+(mins*60)))));
	fi



	#echo -e "Finished at $finishh:$finishm:$finishs\n";
	takes="It took "
	
	if [ "$days" -gt "1" ]; then
		takes+="$days Days, ";
	elif [ "$days" -gt "0" ]; then
		takes+="$days Day, ";
	fi
	
	if [ "$hours" -gt "1" ]; then
		takes+="$hours Hours, ";
	elif [ "$hours" -gt "0" ]; then
		takes+="$hours Hour, ";
	fi
	
	if [ "$mins" -gt "1" ]; then
		takes+="$mins Minutes and ";
	elif [ "$mins" -gt "0" ]; then
		takes+="$mins Minute and ";
	fi
	
	if [ "$secs" -gt "1" ]; then
		takes+="$secs Seconds.";
	else
		takes+="$secs Second.";
	fi


	
#	usname=`whoami`
#	uid=`id -u $usname`
#	if [ ! -e /Users/$username/.Trash/$uid ] ; then
#		mkdir /Users/$username/.Trash/$uid
#	fi
#nosubdir	mv $f /Volumes/Data/.Trashes/501/$f > /dev/null;
#	mv $f /Volumes/Data/.Trashes/501/$fileext > /dev/null;
#	mv $f /Volumes/Data/.Trashes/$uid/$fileext > /dev/null;
	mv $f ~/.Trash/$fileext > /dev/null;
	
	
	
#nosubdir	open -a Identify "/Volumes/Data/Add/TV/${f%.*}.m4v" > /dev/null;
	open -a Identify "/Users/$username/Add/TV/$filenoext.m4v" > /dev/null;

	echo "Finished at $finishh:$finishm:$finishs"
	
	echo $takes;
	
	echo $'\n';
done
fi
