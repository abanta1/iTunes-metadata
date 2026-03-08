#!/bin/bash
#Removes specific characters from filenames. (-- :\/*?"<>| --)

IFS=$'\n'

cd ~/OneDrive/Documents
for f in `ls -R | grep '[\\\/\:\*\?\"\<\>\|]'`;
do

	mv "$f" `echo "$f" | tr -d \: | tr -d \\ | tr -d \/ | tr -d \* | tr -d \? | tr -d \" | tr -d \< | tr -d \> | tr -d \|`


done