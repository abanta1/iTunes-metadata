# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/bin/bash
#Creates torrent files

cd /Volumes/Passport
clear

#no subdirs
#for f in `ls -rRS | grep .mkv`;

#with subdirs
pd=`pwd`
IFS=$'\n'
for f in `find "$pd" | grep .m4v`;

do
	echo "$f"
	fileext=`echo ${f##*/}`
	filenoext=${fileext%.*}
	filepat=`echo ${f%/*}/`
	
	torname=${f#*/}
	torname=${torname#*/}
	torname=${torname#*/}
	torname=${torname#*/}
	torname=${torname#*/}
	showname=`echo ${torname%%/*} | tr ' ' '.'`
	torname=`echo $showname S${torname##*/} | tr ' ' '.' | tr '-' 'E'`
	
	epid=`echo $torname | grep -io s[0-9]e[0-9]* | sed  's/[0-9]/0&/'`
	
	if [ "$epid" = "" ]; then
		epid=`echo $torname | grep -io s[0-9]*e[0-9]*`
	fi
	
	torname=`echo $showname.$epid`
	
	starth=`date +%H`;
	startm=`date +%M`;
	starts=`date +%S`;
	starttime=`date +%s`;
	
	
#nosubdir	enctxt=$(echo "Encoding for ${f%.*}" | grep -io '.*\.s[0-9][0-9]\.*e[0-9][0-9]' | tr '[.]' '\ ')
	enctxt=$(echo Creating torrent for "$fileext")
	
	echo $enctxt" started at $starth:$startm:$starts";



	#~/Desktop/py3createtorrent-0.9.5/py3createtorrent.py -c "" -v -o $filepat $f openbt publicbt
	~/Desktop/py3createtorrent-0.9.5/py3createtorrent.py -c "" -n $torname -o ~/Desktop/tors/ $f openbt publicbt

	
	
	
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
	
#nosubdir	mv $f /Volumes/Data/.Trashes/501/$f > /dev/null;
	#mv $f /Volumes/Data/.Trashes/501/$fileext > /dev/null;
	
#nosubdir	open -a Identify "/Volumes/Data/Add/TV/${f%.*}.m4v" > /dev/null;
	#open -a Identify "/Volumes/Data/Add/TV/$filenoext.m4v" > /dev/null;

	echo "Finished at $finishh:$finishm:$finishs"
	
	echo $takes;
	
	echo $'\n';
done
