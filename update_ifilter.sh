#!/bin/bash

#setup variables
tempfolder=$HOME/Downloads
httpsite=http://www.bluetack.co.uk/config
httpfile=nipfilter.dat.gz
httpfileuncompressed=nipfilter.dat
blocklist=ipfilter.dat

echo.
echo -------------------------------------
echo         qBittorrent Blocklist Updater
echo 
echo                           version 1.0
echo         Written by Craig M. Rosenblum
echo -------------------------------------
echo .
echo ::**:: Creating temp folder and removing files

#check if tempfolder exists if not create it
if [ ! -d "$tempfolder" ]; then 
  mkdir $tempfolder
fi

#delete existing httpfile and blocklist files
if [ -d "$tempfolder/$httpfile" ]; then
	rm "$tempfolder/$httpfile"
fi

if [ -d "$tempfolder/$blocklist" ]; then
	rm "$tempfolder/$blocklist"
fi



#download the ipfilter to a local folder
echo ::**:: Downloading the blocklist
wget --no-verbose --quiet "$httpsite/$httpfile" --no-cache -O "$tempfolder/$httpfile">/dev/null

#check for wget errors
if [ $? -ne 0 ]; then
	echo ::**::        wget returned errorlevel: $?
	echo ::**:: An error occured!
	exit 1
fi

#delete previously unzipped ipfilter file
if [ -d "$tempfolder/nipfilter.dat" ]; then
	rm "$tempfolder/nipfilter.dat"
fi

#unzip the downloaded file
echo ::**:: Uncompressing "$httpfile" to "$httpfileuncompressed" 
gunzip -f "$tempfolder/$httpfile"

if [ $? -ne 0 ]; then
	echo ::**::        gunzip returned errorlevel: $?
	echo ::**:: An error occured!
	exit 1
fi

#rename the downloaded blocklist file
echo ::**:: Moving and renaming the blocklist from "$httpfileuncompressed" to "$blocklist"
mv -f "$tempfolder/$httpfileuncompressed" "$HOME/.config/qBittorrent/$blocklist"

if [ $? -ne 0 ]; then
	echo ::**::        rename returned errorlevel: $?
	echo ::**:: An error occured!
	exit 1
fi


echo ::**:: Update Complete!
exit 0
