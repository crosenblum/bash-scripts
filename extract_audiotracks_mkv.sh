#!/bin/bash
# Extract non-english audio tracks and subtitles from each MKV file in the given directory

#function to grab tracknumber and from variable
extract_track_info() {

	#how to use this function
	#extract_track_info $string will create array with results and return the array to caller

	#by default set these variables
	string=${1}
	eng_id=0

	# Create an associative array
	declare -a tracks=()

	#loop through string
	while read string
	do

		#by default set these variables
		language=''
		tracknumber=''

		#get the tracknumber
		tracknumber=`echo $string | cut -c1-15 | grep -o '[0-9]*'`

		#get just the language of the track name
		language=`echo "$string" | tr " " "\n" | grep 'track_name'`
		language=${language/':'/}
		language=${language/'track_name'/}
		
		#check if language is english
		if [ $language = "english" ]; then
		
			#set eng_id to this value
			set eng_id = $tracknumber
			
		fi

		#append these to array
		tracks[1]=$tracknumber
		tracks[2]=$language
		tracks[3]=$eng_id
		
	done

	#return array
    echo ${tracks[@]}

}


# If no directory is given, work in local dir
if [ "$1" = "" ]; then
  DIR="."
else
  DIR="$1"
fi

# Get all the MKV files in this dir and its subdirs
find "$DIR" -type f -name '*.mkv' | while read filename
do

	#get movie title
	title=$(basename "$filename")
	extension="${title##*.}"
	title="${title%.*}"


	# Find out which tracks contain audio tracks
	mkvmerge -I "$filename" | grep 'audio' | while read sublime
	do

		#by default set these variables
		#eng_id=0
		#language=''
		#tracknumber=''

		#call function to get parse each line of the mkvmerge info
		tracks=$(extract_track_info $sublime)

		#display title of movie
		echo $title
		echo "Records: ${#tracks[@]}"
		echo "Track ID: $tracks[1]"
		echo "Language: $tracks[2]"

		#display results
		#echo 'Track ID: '$tracknumber
		#echo 'Language: '$language

		#create new audio track filename
		fn=$(basename "$filename")
		extension="${fn##*.}"
		fn="${fn%.*}"
		fn="$fn"."$language"."$extension"

		#if this track is english save the track_id
		#if [ $language = "english" ]; then

			#set the track id to this track number
			#eng_id=${tracknumber}
	
		#fi

		#check if language is not english
		#if [ ! $language = "english" ]; then
	
			#check if $fn does not exist
			#if [ ! -f "$fn" ]; then

				#now extract this audio track to a file just as a backup move
				#mkvextract tracks "$filename" "$tracknumber":"${fn}"

			#fi
	
			#has english id been identified
			#if [ $eng_id > 0 ]; then
	
				#now remove this audio track
				#echo mkvmerge -o "$filename" --atracks "$eng_id" "$filename"

			#fi
	
		#fi


	done
done
