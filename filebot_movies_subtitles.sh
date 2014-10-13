#!/bin/bash
#use filebot cmd to download subtitles
#created by Craig M. Rosenblum
#email address crosenblum@gmail.com
#/usr/bin/X11/filebot -get-missing-subtitles /your/path/movies

#setup variables
tvpath=/your/path/movies
video_type_list="avi,mkv,mp4,wmv,mpg,vob"

#step 1. loop through all video files in path
for f in $tvpath/*
do

	#look for video files inside current folder
	for type in ${video_type_list//,/ }; do
		
		#now do a find, and pipe the results to a file inside current starting folder
		find "$f" -type f -name \*.$type -print | while read f; do
			/usr/bin/X11/filebot -get-missing-subtitles "$f"
		done
	done
	
	
done
