#!/bin/bash
#desktop wallpaper icon synch between linux and windows xp

#useful functions
function find_wallpaper () {

	# save it
	OLDIFS="$IFS"

	# don't split on any white space
	IFS="" 

	vms[0]=$1
	tmp=$(echo "${vms[0]}")

	#get the right image
	PIC=$(ls "$tmp" -R | grep -E '(png|jpg)$' | sort -R | tail -1)

	#search for folder	
	fullpath=$(find "$tmp" -name "$PIC")
	export DIR=${fullpath%/*};

	# restore IFS	# first select random image recursively
	IFS=$OLDIFS 

	# save result
	file="$DIR/$PIC"

	eval 'file=$file'
}

function copyfile() {

	#check if wallpaper.jpg and wallpaper.png exist

	#create blank temporary file first
	#> "$2"

	#echo "$1"

	#https://stackoverflow.com/questions/20936531/error-cp-cannot-create-regular-file-no-such-file-or-directory
    cp "$1" "$2"
    #chmod 644 "$2" 
}

function copy_dropbox() {

	#get the file extension
	file="$1"
	filename=$(basename "$1")
	extension="${filename##*.}"

	#check if dropbox folder exists
	if [ -d "$HOME/Dropbox" ]; then

		#check if Desktop Folder exists
		if [ ! -d "$HOME/Dropbox/Desktop" ]; then

			#create this folder then
			mkdir "$HOME/Dropbox/Desktop"

		fi

		#erase contents of dropbox/desktop folder
		rm -rf  $HOME/Dropbox/Desktop/*

		#copy the file to the dropbox wallpaper folder
		copyfile "$file" "$HOME/Dropbox/Desktop/wallpaper.$extension"

		#https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
		#check if imagemagick is installed
		if hash convert 2>/dev/null; then

			#convert the file in here to a bmp
			convert "$HOME/Dropbox/Desktop/wallpaper.$extension" "$HOME/Dropbox/Desktop/wallpaper.bmp"

			#erase the old file
			rm -rf "$HOME/Dropbox/Desktop/wallpaper.$extension"

		fi

	fi

}

function change_wallpaper() {

	#get the file
	file="$1"

	#change wall paper for gnome2
	/usr/bin/gconftool-2 --type string --set /desktop/gnome/background/picture_filename "$file"

	#change wallpaper for gnome3
	gsettings set org.gnome.desktop.background picture-uri "file://$file"
	gsettings set org.gnome.desktop.background picture-options "stretched"

}


# Directory Containing Pictures
DIR="/media/Backup/My Wallpapers"
file=''

#step 1. given a folder, select one random image from a given specific folder
find_wallpaper "$DIR";

#step 2. change wallpaper accordingly
change_wallpaper "$file";

#step 3. copy the wallpaper image file to /dropbox/desktop/wallpaper.png
copy_dropbox "$file";

#step 4. extract ico files from linux desktop to /dropbox/desktop/*.ico

