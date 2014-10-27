#!/bin/bash
#Media Manager Automation Script Using Filebot and other tools
#created by Craig M. Rosenblum
#email address crosenblum@gmail.com

#setup variables
showselect="Yes"
mode="movies"
curdir=${PWD##*/} 
path=$PWD
pathmatch="No"
cron="No"
debug="No"

#declare debug function
debug() {

	#now show debug of settings/statue
	echo
	echo :::::::::::::::::::::::::::::::::
	echo :::::::: Debug Info :::::::::::::
	echo :::::::::::::::::::::::::::::::::
	echo
	echo "Folder: [$1]"
	echo "Mode: [$2]"
	echo "Path: [$3]"
	echo "Show Select: [$4]"
	echo "Cron Y/N: [$5]"
	echo 
}

#declare movie handling function
movies() {

	#essential variables for this to work
	video_type_list="avi,mkv,mp4,wmv,mpg,vob"

	#manually change this if needed
	filebotpath="/usr/bin/X11/filebot"

	#Quality to download. To get the accepted value run; youtube-dl -F parameter to get a list of formats
	#Multiple formats as 22/18/12
	Q=18

	#Base Url for video download
	YTB_URL="https://www.youtube.com/watch?v="

	#check if parameter is a folder
	if [[ -d $1 ]]; then
	
		#display banner of movie manager
		echo
		echo :::::::::::::::::::::::::::::::::
		echo :::::::: Movie Manager ::::::::::
		echo :::::::::::::::::::::::::::::::::
		echo

		echo "Scanning for movies..."

		#now let's do the work needed
		for f in $1/*
		do

			#look for video files inside current folder
			for type in ${video_type_list//,/ }; do
	
				#now do a find, and pipe the results to a file inside current starting folder
				find "$f" -type f -name \*.$type -print | while read f; do

					#get base folder of current folder
					root="$(dirname "$f")"
					root="$(basename "$root")"
					
					#display current movie working on
					echo "$root"

					#rename folders -script fn:renall "path/to/movies" -non-strict --db TheMovieDB --def target=folder
					#echo "--[Renaming Movie Folder]"
					$filebotpath -script fn:renall "$f" -non-strict --db TheMovieDB --def target=folder >/dev/null 2>&1

					#download artwork for movies
					#echo "--[Download FanArt / Create NFO]"
					$filebotpath -script fn:artwork.tmdb "$f" -non-strict --conflict override >/dev/null 2>&1

					#run filebot to get subtitles
					#echo "--[Download Subtitles]"
					$filebothpath -get-missing-subtitles "$f">/dev/null 2>&1
		

				done

			done

		done

		#script from https://forums.plex.tv/index.php/topic/116913-script-to-download-trailers-missing-from-your-library/
		#look for trailer named movie trailers in movie root folder
		find $1 -mindepth 2 -maxdepth 2 -type d '!' -exec sh -c 'ls -1 "{}"|egrep -i -q "trailer\.(mp4|avi)$"' ';' -print | while read dir
		do

			#get the movie id from the movie.nfo file
			ID=$(awk -F "[><]" '/trailer/{print $3}' "$dir/movie.nfo")
			
			#download the youtube trailer for this movie							
			youtube-dl -f $Q $YTB_URL$ID -o "$dir/%(title)s-trailer.%(ext)s" --restrict-filenames --console-title -f mp4 --add-metadata --sub-lang en --embed-subs --embed-thumbnail --all-subs
			
		done						
	
	fi
	
}


#check which mode we are in
if echo $curdir | grep -iq "Movies"; then

    #set mode to movies
    mode="movies"

	#set pathmatch to yes so I know that we are in the right folder
	pathmatch="Yes"
    
fi

if echo $curdir | grep -iq "TV Shows"; then

    #set mode to movies
    mode="tvshows"

	#set pathmatch to yes so I know that we are in the right folder
	pathmatch="Yes"

fi

if echo $curdir | grep -iq "TVShows"; then

    #set mode to movies
    mode="tvshows"

	#set pathmatch to yes so I know that we are in the right folder
	pathmatch="Yes"

fi

#check for parameters
if [ ! -z $1 ]; then 

	#check fi tv show or movies mode
	if echo $1 | grep -iq "m"; then
		#set mode to movies
		mode="movies"
	fi

	if echo $1 | grep -iq "t"; then
		#set mode to movies
		mode="tvshows"
	fi

fi

if [ ! -z $2 ]; then 

	#get path to be operating
	if [[ -d $2 ]]; then
	
		#set path to this parameters value
		path=$2
	
	fi
	
fi

#check if run as cron or not
if [[ $- == *i* ]]; then

	cron="Yes"
	
else

	cron="No"

fi

#show documentation intro
echo :::::::::::::::::::::::::::::::::
echo :::::::::: Media Manager ::::::::
echo :::::::::::::::::::::::::::::::::

#check if show select menu
if [ $showselect == "Yes" ]; then

	PS3='Select one: '
	options=("Movies" "TV Shows" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
		    "Movies")
		        #echo "you chose choice 1"
		        mode="movies"
		        break
		        ;;
		    "TV Shows")
		        #echo "you chose choice 2"
		        mode="tvshows"
		        break
		        ;;
		    "Quit")
		        break
		        ;;
			*) echo invalid option;;		        
		esac
	done
	
	#confirm if you want to operate in the current folder
	#from http://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
	
fi

#different options for different modes
case $mode in
	"movies")
		#execute movies mode
		movies "$path"
		;;
	"tvshows")
		#execute tvshows mode
		echo tvshows $path
		;;
	*) echo invalid option;;		        
esac

#debug="Yes"

#check if debug mode is on
if [ $debug == "Yes" ]; then

	#call debug function and pass correct parameters
	debug $curdir $mode $path $showselect $cron

fi


exit
