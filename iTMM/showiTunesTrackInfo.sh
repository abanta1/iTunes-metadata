#!/bin/bash
#Reads iTunes TrackID from inside iTunes files and displays relative information to the screen
#
#Usage:
#./trackid.sh < (file)

IFS=$'\n'
trkid=$(xxd -p "$@" | tr -d '\n' | grep -Eo '736f6e67.{0,8}' | cut -c 9- | echo $((0x`cat $@`)))
echo "track ID" $trkid

curl http://itunes.apple.com/lookup?id=$trkid\&country=us &> .$trkid


artistName=$(cat ./.$trkid | grep -Eo '"artistName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
collectionName=$(cat ./.$trkid | grep -Eo '"collectionCensoredName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
collectionArtName=$(cat ./.$trkid | grep -Eo '"collectionArtistName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
trackName=$(cat ./.$trkid | grep -Eo '"trackCensoredName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
primaryGenre=$(cat ./.$trkid | grep -Eo '"primaryGenreName":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)
trackExpl=$(cat ./.$trkid | grep -Eo '"trackExplicitness":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev)

discNumber=$(cat ./.$trkid | grep -Eo '"discNumber":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)
discCount=$(cat ./.$trkid | grep -Eo '"discCount":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)
trackNumber=$(cat ./.$trkid | grep -Eo '"trackNumber":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)
trackCount=$(cat ./.$trkid | grep -Eo '"trackCount":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | rev | cut -c 4- | rev)

artwk=$(cat ./.$trkid | grep -Eo '"artworkUrl100":.*?[^\\]"' | grep -Eo ':.*' | tr -d \: | cut -c 2- | rev | cut -c 2- | rev | sed s/100x100/600x600/)

rm .$trkid

echo $artistName
echo $collectionName
echo $collectionArtName
echo $trackName
echo $primaryGenre
echo $trackExpl
echo D$discNumber
echo $discCount
echo T$trackNumber
echo $trackCount

echo $artwk
#cat .$trkid