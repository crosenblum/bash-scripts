#!/bin/bash
#media library checker by Craig M. Rosenblum

#the purpose of this program is to scan folders, and give statistics on movies and tvshows

#setup path variables
movie_path="/folder/movies"
tvshow_path="/folder/TVShows"

function percentage() {

	#1st paramter is current value
	cur=$1

	#2nd paramter is the total in comparrison
	tot=$2
	
	per=$((100*cur/tot))
	
	echo $per

}



function tvshow_statistics {

	#tvshow statistics to gather
	#-fanart for show/season/episode
	#-nfo show/season/episode
	#-theme.mp3
	
	#setup variables
	fanart=0
	nfo=0
	tune=0
	count=0
	tvtotal=0

	# copy 1st parameter to movie_path
	tvshow_path="$1"
	
	#now let's do the work needed
	for f in $tvshow_path/*
	do

		#get base folder of current folder
		root="$(basename "$f")"

		#display current movie working on
		#echo "$root"

		#step 1. check for fanart
		count=$(find "$tvshow_path/$root" -maxdepth 1 -iname "*.jpg" | wc -l)
		if [ $count -gt 0 ]; then
			fanart=$((fanart+1))
		fi
		count=0

		#step 2. check for nfo
		count=$(find "$tvshow_path/$root" -maxdepth 1 -iname "*.nfo" | wc -l)
		if [ $count -gt 0 ]; then
			nfo=$((nfo+1))
		fi
		count=0

		#step 3. check for tv tune
		count=$(find "$tvshow_path/$root" -maxdepth 1 -iname "theme.mp3" | wc -l)
		if [ $count -gt 0 ]; then
			tune=$((tune+1))
		fi
		count=0
		
		tvtotal=$((tvtotal+1))

	done
	
	#show results
	echo
	echo "Total TV Show: [$tvtotal]"
	echo
	echo "Fanart: $(percentage $fanart $tvtotal)% [$fanart]"
	echo "NFO: $(percentage $nfo $tvtotal)% [$nfo]"
	echo "TV Theme Song: $(percentage $tune $tvtotal)% [$tune]"
	echo
}

function movie_statistics {

	#movie statistics to gather
	#-fanart
	#-subtitle
	#-trailer
	#-kodi.nfo
	#-media portal nfo
	#-imdb url

	#setup movie statistic variables
	fanart=0
	subtitle=0
	trailer=0
	kodi=0
	mediaportal=0
	imdburl=0
	movietotal=0
	count=0

	# copy 1st parameter to movie_path
	movie_path="$1"

	#now let's do the work needed
	for f in $movie_path/*
	do

		#get base folder of current folder
		root="$(basename "$f")"
	
		#display current movie working on
		#echo "$root"
	
		#step 1. check for fanart
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "*.jpg" | wc -l)
		if [ $count -gt 0 ]; then
			fanart=$((fanart+1))
		fi
		count=0

		#step 2. check for subtitles
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "*.srt" | wc -l)
		if [ $count -gt 0 ]; then
			subtitle=$((subtitle+1))
		fi
		count=0

		#step 3. check for trailer
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "trailer.ext" | wc -l)
		if [ $count -gt 0 ]; then
			trailer=$((trailer+1))
		fi
		count=0

		#step 4. check for kodi movie.nfo
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "movie.nfo" | wc -l)
		if [ $count -gt 0 ]; then
			kodi=$((kodi+1))
		fi
		count=0

		#step 5. check for mediaportal nfo
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "$root.nfo" | wc -l)
		if [ $count -gt 0 ]; then
			mediaportal=$((mediaportal+1))
		fi
		count=0
	
		#step 6. check for imdb url
		count=$(find "$movie_path/$root" -maxdepth 1 -iname "imdb.url" | wc -l)
		if [ $count -gt 0 ]; then
			imdburl=$((imdburl+1))
		fi
		count=0

		movietotal=$((movietotal+1))
	
	done

	#show results
	echo
	echo "Total Movies: [$movietotal]"
	echo
	echo "Fanart: $(percentage $fanart $movietotal)% [$fanart]"
	echo "Subtitle: $(percentage $subtitle $movietotal)% [$subtitle]"
	echo "Trailer: $(percentage $trailer $movietotal)% [$trailer]"
	echo "Kodi NFO: $(percentage $kodi $movietotal)% [$kodi]"
	echo "MediaPortal NFO: $(percentage $mediaportal $movietotal)% [$mediaportal]"
	echo "Imdb Url: $(percentage $imdburl $movietotal)% [$imdburl]"
	echo

}

#call each stats function
movie_statistics "$movie_path"

tvshow_statistics "$tvshow_path"
