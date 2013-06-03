#!/bin/bash
#setup wget variables
URL="https://www.google.com/calendar/ical/your personal link here/basic.ics"
dir1="$HOME/Downloads"
dir2="$HOME/Scripts"

echo .
echo -------------------------------------
echo               Google Calendar Updater
echo 
echo                           version 1.0
echo         Written by Craig M. Rosenblum
echo -------------------------------------
echo .

#download the google calendar to a local folder
echo ::**:: Downloading the google calendar to $dir2/basic.ics
wget -c -N --no-check-certificate $URL -o "$dir1/basic.ics" >/dev/null

#mv file to new destination
echo ::**:: Moving basic.ics to downloads folder
mv -f "$dir2/basic.ics" "$dir1/basic.ics"

echo ::**:: Download Complete!
exit 0
