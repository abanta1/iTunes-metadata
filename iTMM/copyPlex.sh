#!/bin/bash
#Copies files to Plex Server

#$username = "user"

cd /Users/$username
clear


if [ ! -d /Volumes/E\$ ]; then
mkdir /Volumes/E\$
passwd=`security find-internet-password -s media -a $username -w`
mount_smbfs //$username:$passwd@media/E\$ /Volumes/E\$
fi

rsync Send/*.m4v /Volumes/E\$/ --append-verify --progress --remove-source-files
rsync Send/*.jpg /Volumes/E\$/ --append-verify --progress --remove-source-files
rsync Send/*.jpeg /Volumes/E\$/ --append-verify --progress --remove-source-files
#umount /Volumes/E\$