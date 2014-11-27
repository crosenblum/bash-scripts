#!/bin/bash
#Media Manager Automation Script Using Filebot and other tools
#created by Craig M. Rosenblum
#email address crosenblum@gmail.com

#feature list for each mode
#
#movies feature list
#-download fanart
#--fanart sources
#--TheMovieDB.org
#--imdb.com
#--ofdbe.de
#--fanart.tv
#--htbackdrops.com
#--moviebackdrops.com
#--movieposterdb.com
#-download subtitles
#-download trailers
#-create xbmc compatible nfo
#-create mediaportal compatible nfo
#-rename movie and movie folder


#setup variables
showselect="Yes"
mode="movies"
curdir=${PWD##*/} 
mypath=$PWD
pathmatch="No"
cron="No"
debug="No"

#the script below is to help check if software is installed or not
#from http://stackoverflow.com/questions/20815433/how-can-i-check-in-a-bash-script-if-some-software-is-installed-or-not
iscmd() {
    command -v >&- "$@"
}

checkdeps() {
    local -i not_found
    for cmd; do
        iscmd "$cmd" || { 
        	#return 1 if not found
            return 1
        }
    done
	
	#return 0 if found
    return 0
}

read_dom () {
	local IFS=\>
	read -d \< ENTITY CONTENT
}

#declare debug function
function debug {

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

#help menu
function helpmenu {

	echo
	echo :::::::::::::::::::::::::::::::::
	echo :::::::: Help Menu  :::::::::::::
	echo :::::::::::::::::::::::::::::::::
	echo
	echo Usage: media_manager.sh [mode] [path of movie or tv show folder]
	echo
	echo Mode Reference [Used to determine how to process path specified]:
	echo t = TV Shows
	echo m = Movies
	echo
	echo Example:
	echo media_manager.sh m /folder/movies
	echo media_manager.sh t /folder/tvshows
	echo
	echo Depedencies:
	echo [1] FileBot is the ultimate tool for renaming your movies, tv shows 
	echo   or anime and downloading subtitles.
	echo [2] youtube-dl is a small command-line program to download videos 
	echo   from YouTube.com and a few more sites.
	echo
	echo
}

#download movie trailer
#download movie trailer
function trailer {

	
	#get base folder of current folder
	root="$(basename "$1")"
	f="$1"
	trailer_id=""
	
	YTB_URL="https://www.youtube.com/watch?v="

	#set trailer filename
	save_path="$f/trailer.ext"
	
	#display current movie working on
	#echo "$root"

	#check if there is a movie.nfo 		
	if [ -f "$f/movie.nfo" ]; then

		while read_dom; do
				if [[ $ENTITY = "trailer" ]]; then
		
					#extract videoid from trailer url
					trailer_id="$(echo $CONTENT | awk -F'[=&]' '{print $4}')"

				fi
			done < "$f/movie.nfo"
			
			#echo "Trailer ID: [$trailer_id]"

	fi

	#check if trailer_id is set
	if [ ! -z "$trailer_id" ]; then

		#debug info
		echo "--[Download Movie Trailer]"

		#setup youtube-dl
		#echo "$YTB_URL$trailer_id"
		#echo "$save_path"
		echo youtube-dl -f "$YTB_URL$trailer_id" -o "$save_path" --restrict-filenames --console-title -f mp4 --add-metadata --sub-lang en --embed-subs --embed-thumbnail --all-subs

	fi

}

#declare movie handling function
function do_movies {

	#essential variables for this to work
	video_type_list="avi,mkv,mp4,wmv,mpg,vob"

	#manually change this if needed
	filebotpath="/usr/bin/X11/filebot"

	#Base Url for video download
	YTB_URL="https://www.youtube.com/watch?v="
	
	#setup do count
	do_count=0

	#check if parameter is a folder
	if [[ -d $1 ]]; then
	
		#display banner of movie manager
		#echo
		#echo :::::::::::::::::::::::::::::::::
		#echo :::::::: Movie Manager ::::::::::
		#echo :::::::::::::::::::::::::::::::::
		#echo

		echo "Scanning for movies..."
		echo

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

					#check if fanart in the folder
					count=`ls -1 *.jpg 2>/dev/null | wc -l`

					if [ $count = 0 ]; then

						#download artwork for movies
						echo "--[Download FanArt / Create NFO]"
						$filebotpath -script fn:artwork.tmdb "$f" -non-strict --conflict override >/dev/null 2>&1
						do_count=$((do_count+1))

					fi

					#check if subtitles in the folder
					count=`ls -1 *.srt 2>/dev/null | wc -l`

					if [ $count != 0 ]; then

						#run filebot to get subtitles
						echo "--[Download Subtitles]"
						$filebothpath -get-missing-subtitles "$f">/dev/null 2>&1
						do_count=$((do_count+1))

					fi
					
					#check if there is a movie.nfo 		
					if [ -f "$1/$root/movie.nfo" ]; then

						#get full current path
						#echo "--[Download Movie Trailer]"
						trailer "$1/$root"
						do_count=$((do_count+1))
						
					fi
					
					#loop to end of do_count
					for i in {1..$do_count}
					do

						#delay 1 second
						sleep 2
	
						#move up one line then echo blank
						tput cuu1
						echo "                                                         "

						#move up one line and clear
						tput cuu1 cuu1 el

					done
					
				done

			done

		done

	fi
	
}

function do_tvshows {

	#essential variables for this to work
	video_type_list="avi,mkv,mp4,wmv,mpg,vob"

	#manually change this if needed
	filebotpath="/usr/bin/X11/filebot"

	#Base Url for video download
	YTB_URL="https://www.youtube.com/watch?v="

	#check if parameter is a folder
	if [[ -d $1 ]]; then
	
		#display banner of tvshows manager
		echo
		echo :::::::::::::::::::::::::::::::::
		echo ::::::: TV Shows Manager ::::::::
		echo :::::::::::::::::::::::::::::::::
		echo

		echo "Scanning for movies..."
		echo

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
					
					#display current tvshow working on
					echo "$root"

					#rename folders -script fn:renall "path/to/movies" -non-strict --db TheMovieDB --def target=folder
					#echo "--[Renaming Movie Folder]"
					$filebotpath -script fn:renall "$f" -non-strict --db TheMovieDB --def target=folder >/dev/null 2>&1

					#check if fanart in the folder
					count=`ls -1 *.jpg 2>/dev/null | wc -l`

					if [ $count = 0 ]; then

						#download artwork for movies
						echo "--[Download FanArt / Create NFO]"
						$filebotpath -script fn:artwork.tmdb "$f" -non-strict --conflict override >/dev/null 2>&1

					fi

					#check if subtitles in the folder
					count=`ls -1 *.srt 2>/dev/null | wc -l`

					if [ $count != 0 ]; then

						#run filebot to get subtitles
						echo "--[Download Subtitles]"
						$filebothpath -get-missing-subtitles "$f">/dev/null 2>&1

					fi
					
					#check if there is a movie.nfo 		
					if [ -f "$1/$root/movie.nfo" ]; then

						#get full current path
						#echo "--[Download Movie Trailer]"
						trailer "$1/$root"
						
					fi
					
				done

			done

		done

	fi

}


#check if run as cron or not
if [[ $- == *i* ]]; then

	cron="Yes"
	
else

	cron="No"

fi

#check for each paramter
for i in $*; do

	if [[ -d "${i}" ]]; then
		echo "$i is a directory"
	elif [[ -f "${i}" ]]; then
		echo "$i is a file"
	fi

	#check if this paramter is a directory
	if [[ -d "${i}" ]]; then

		#set path to this paramter
		mypath="$i"

	fi

	#check if tv show or movies mode
	if echo $i | grep -iq "m"; then

		#set mode to movies
		mode="movies"
		showselect="no"

	fi

	if echo $i | grep -iq "t"; then

		#set mode to movies
		mode="tvshows"
		showselect="no"

	fi


	#echo $i 
done

#show documentation intro
clear
echo :::::::::::::::::::::::::::::::::
echo :::::::::: Media Manager ::::::::
echo :::::::::::::::::::::::::::::::::
echo
showselect="Yes"

#check if show select menu
if [ $showselect == "Yes" ]; then

	PS3='Select one: '
	options=("Movies" "TV Shows" "Help" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
		    "Movies")
		        #echo "you chose choice 1"
		        do_movies "$mypath"
		        break
		        ;;
		    "TV Shows")
		        #echo "you chose choice 2"
		        mode="tvshows"
		        break
		        ;;
		    "Help")
		    	#echo "you choise choice 3"
		    	helpmenu
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

# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
#trap '' SIGINT SIGQUIT SIGTSTP

#debug="Yes"

#check if debug mode is on
if [ $debug == "Yes" ]; then

	#call debug and pass correct parameters
	debug $curdir $mode $mypath $showselect $cron

fi


exit
