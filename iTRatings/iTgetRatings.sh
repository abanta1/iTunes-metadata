#!/bin/bash
# Prereq - oldiTunesMetaData.rb -- echo idlist to reslt\ do.txt
# Searches all iTunes stores for music tags based off of iTunes TrackID, Creates list for iTapplyRating.sh

cls

#Get ids
idList=`grep -Eo '[0-9]*' ~/Desktop/no\ it\ data.txt | sort -n | tr -s '\n' | tr '\n' ' '`

trkIter=0
trkCnt=0

#Get track count for progress
for token in $idList;
do
	trkCnt=$((trkCnt+1));
done

#Pretty description
printf "%*s\n" 0 "  Processing files..."

#For each id in the list, find track information
for f in $idList;
do
	trkid=$f
	echo $trkid
	trackName=""
	cntryIndx=0
	cntry=(US GB CA AU IT DE FR JP CN CH AE AG AI AL AM AO AR AT AZ BB BE BF BG BH BJ BM BN BO BR BS BT BW BY \
		BZ CG CL CO CR CV CY CZ DK DM DO DZ EC EE EG ES FI FJ FM GD GH GM GR GT GW GY HK HN HR HU ID IE IL IN \
		IS JM JO KE KG KH KN KR KW KY KZ LA LB LC LK LR LT LU LV MD MG MK ML MN MO MR MS MT MU MW MX MY MZ NA \
		NE NG NI NL NO NP NZ OM PA PE PG PH PK PL PT PW PY QA RO RU SA SB SC SE SG SI SK SL SN SR ST SV SZ TC \
		TD TH TJ TM TN TR TT TW TZ UA UG UY UZ VC VE VG VN YE ZA ZW)
	
	#Search all iTunes stores for match.
	while [ "$trackName" == "" ]
	do
		curl http://itunes.apple.com/lookup?id=$trkid\&country=${cntry[cntryIndx]} &> .$trkid
		trackName=$(cat ./.$trkid | grep -Eo '"trackCensoredName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
		cntryIndx=$((++cntryIndx))
	done
	
	#Get track information
	artistName=$(cat ./.$trkid | grep -Eo '"artistName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
	collectionName=$(cat ./.$trkid | grep -Eo '"collectionCensoredName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
	collectionArtName=$(cat ./.$trkid | grep -Eo '"collectionArtistName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
	trackName=$(cat ./.$trkid | grep -Eo '"trackCensoredName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
	trackExpl=$(cat ./.$trkid | grep -Eo '"trackExplicitness":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
	diskNumber=$(cat ./.$trkid | grep -Eo '"discNumber":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)
	trackNumber=$(cat ./.$trkid | grep -Eo '"trackNumber":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)

	#Remove temporary file
	rm .$trkid
	
	#Save track information to file
	echo $trkid - $discNumber - $trackNumber - $artistName - $collectionArtName - $collectionName - $trackName - $trackExpl >> ~/Desktop/explicit.txt

	#More pretty description
	printf "%79s\r" ""
	printf "%.75s\n" "     `if [ "$collectionArtName" == "" ]; then echo $artistName; else echo $collectionArtName; fi` - $trackName"
	printf "%*s\r" 0 "     $((trkIter++)) out of $trkCnt"
	printf "\e[A"

done


#~/Desktop/iTapplyRating.sh