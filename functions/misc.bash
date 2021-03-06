#!/bin/bash

###
 # Misc Functions.
 #
 # @since 3/11/17 Move to it's own file from functions.bash.
 ##

###
 # Get kint.php from Github.
 #
 # @since 6/21/17
 ##
function get-kint() {
	if [ -e "kint.php" ]; then
		trash kint.php # Trash the existing one.
	fi

	# Get a new one.
	wget https://raw.githubusercontent.com/kint-php/kint/master/build/kint.php
}

###
 # Run ctags.
 #
 # @since 3/27/2017
 ##
function tags {
	echo 'Running ctags -R...'
	ctags -R --exclude=".git" --exclude="node_modules" --exclude="*.min*" &> /dev/null
}

###
 # Opens a new Safari instance.
 #
 # @since 4/5/16
 ##
function new-safari {
	open -n -a "Safari"
}

###
 # Remove any missing files from the repo.
 #
 # @since 2/11/17
 ##
function svn-remove {
	svn status | grep '^!' | awk '{print $2}' | xargs svn rm --force
}

###
 # Add any new files to the repo.
 #
 # @since 8/19/17
 ##
function svn-add {
	svn status | grep '^\?' | awk '{print $2}' | xargs svn add --force
}

###
 # Reset a SVN repo.
 #
 # @since 8/20/17
 ##
function svn-reset {
	svn revert --recursive .
}

###
 # Syncs trunk with a tag.
 #
 # @since 8/20/17
 ##
function svn-tag {
	if [ -n "$1" ]; then
		if [ '--help' == "$1" ]; then
			echo "Copies content from tags/$1 to trunk/"
			echo "Usage: svn-tag [+string: The tag, e.g. 1.0]"
			return;
		fi

		if [ -e "tags/$1" ]; then
			svn rm "tags/$1" --force
		fi

		svn cp trunk "tags/$1"
		svn-addremove
		svn status
	else
		svn-tag --help
	fi
}

###
 # Syncs a tag with trunk.
 #
 # @since 8/20/17
 ##
function svn-trunk {
	if [ -n "$1" ]; then
		if [ '--help' == "$1" ]; then
			echo "Syncs content from tags/$1 to trunk/"
			echo "Usage: public [+string: The project folder in ~/Local Sites.]"
			return;
		fi

		if [ -e "tags/$1" ]; then
			svn rm trunk --force
			svn cp "tags/$1" trunk
			svn-addremove
		fi
	else
		svn-sync --help
	fi
}

###
 # Add any new files, remove any deleted files from the repo.
 #
 # @since 8/19/17
 ##
function svn-addremove {
	svn-add
	svn-remove
}

###
 # Flushes DNS Cache.
 #
 # E.g.: dns-flush
 #
 # @since 4/5/16
 ##
function flush-dns {
	sudo echo "🚽"
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
	echo "Done"
}

###
 # Sudo PHP.
 #
 # E.g.: sphp script.php arg1 arg2
 ##
function sphp {
	sudo php "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
}

###
 # Create a native app from a website.
 #
 # @since 4/5/16
 #
 # E.g.: native "HipChat" "http://hipchat.com"
 ##
function app {
	curr_pwd=$(pwd)

	cd "$HOME/Applications" || return

	echo "Creating $1 from $2 in ~/Applications/..."

	# Create the native webapp...
	nativefier -n "$1" -o --insecure "$2" --flash "$3" "$4" "$5" "$6" "$7"

	# Open the application!
	echo "Done, opening ~/Applications..."
	open "$HOME/Applications"

	cd "$curr_pwd" || return
}

###
 # Gifify's a .mov file and uploads it to CloudUp
 #
 # E.g: gifup myfile.mov (Creates myfile.gif)
 #
 # @since 4/5/16
 ##
function gif-up {
	if [ -e "$1" ]; then
		gifify "$1" && up "$1".gif
	else
		echo "Couldnt find $1"
	fi
}

###
 # Quick wrapper for "npm install && bower install"
 #
 # E.g: install
 #
 # @since 4/5/16
 ##
function install {
	if [ -e 'package.json' ]; then
		echo "Running 'npm install'..."
		npm install
	else
		echo "No package.json, didn't run 'npm install'."
	fi

	if [ '--no-bower' == "$1" ] || [ 'no-bower' == "$1" ]; then
		echo "Didn't run 'bower install' since --no-bower was set."
	else
		if [ -e bower.json ]; then
			echo "Running 'bower install'..."
			bower install
		else
			echo "No bower.json present, didn't run 'bower install'."
		fi
	fi
}

###
 # Re-install.
 #
 # Will remove node_modules, package.json, package.lock and re-install.
 #
 # E.g: reinstall
 #
 # @since Wednesday, March 27, 2019
 ##
function reinstall {
	if [ -e 'node_modules' ]; then
		echo "Removing node_modules..."
		rm -Rf node_modules
	fi

	if [ -e 'package.lock' ]; then
		echo "Removing package.lock..."
		rm package.lock
	fi

	echo "Re-installing..."
	install "$@"
}

###
 # Pulls files to destination.
 #
 # @since 4/5/16
 ##
function rsync-down {
	if [ '--help' == "$1" ]; then
		echo "Usage: rsync-down username@domain:[/var/www: Remote Folder] [/var/www: Local Folder]"
		return;
	fi

	rsync -avzh --progress -e ssh "$1" "$2"
}

###
 # Sends files up to location.
 #
 # @since 4/5/16
 ##
function rsync-up {
	if [ '--help' == "$1" ]; then
		echo "Usage: rsync-up [/var/www: Local Folder] username@domain:[/var/www: Remote Folder]"
		return;
	fi

	rsync -avzh --progress "$1" -e ssh "$2"
}

###
 # Set tab title.
 #
 # @since Wednesday, January 31, 2018
 ##
function title {
	echo -ne "\033]0;$*\007"
}

###
 # PO 2 MO files conversion.
 #
 # @since Monday, March 19, 2018
 ##
function po2mo {
	if ! [ -x "$(command -v msgfmt)" ]; then
		echo "Please run: brew install gettext" && return
	fi

	if ! [ -x "$(command -v dos2unix)" ]; then
		echo "Please run: brew install dos2unix" && return
	fi

	help="Usage: cd into folder; then run po2mo";
	if [ '--help' == "$1" ]; then
		echo "$help" && return
	fi

	# Clean BOM from .po files: https://unix.stackexchange.com/questions/381230/how-can-i-remove-the-bom-from-a-utf-8-file.
	for f in *.po; do
		dos2unix "$f" &> /dev/null
	done

	# Convert .po to .mo...
	find . -name \*.po -execdir sh -c 'msgfmt "$0" -o `basename $0 .po`.mo' '{}' \;
	echo "Done!"
}

###
 # SVN Add/Remove.
 #
 # @since Friday, March 23, 2018
 ##
function svn-addremove {
	svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
}

###
 # Fix this typo.
 #
 # @since Friday, June 8, 2018
 ##
function tower. {
	gittower ./
}

###
 # Test performance of a url.
 #
 # @since Monday, June 25, 2018
 ##
function perform {
	curl -o /dev/null -s -w 'Total: %{time_total}\n' "$1"
}

###
 # Remove all composer packages.
 #
 # @since Monday, October 29, 2018
 ##
function composer-uninstall {
	php "$HOME/Repos/code/composer-uninstall/composer-uninstall.php"
}

###
 # Re-install composer assets.
 #
 # @since  Wednesday, November 7, 2018
 ##
function composer-reinstall {
	composer-uninstall
	composer clear-cache
	composer install "$1"
}

###
 # Compress video.
 #
 # @since Tuesday, November 6, 2018
 #
 # E.g:  compress-video *.mov
 ##
function compress-video {
	f=$(basename -- "$1")
	e="${f##*.}"
	/usr/local/bin/ffmpeg -i "$1" -vcodec libx264 -crf 20 -y "$1-compressed.$e"
}

###
 # Download audio from a youtube video.
 #
 # @since Wednesday, January 2, 2019
 #
 # E.g: youtube-mp3 "<video URL]"
 ##
function youtube-mp3 {
	if ! [ -x "$(command -v youtube-dl)" ]; then
		echo "Please run: brew install youtube-dl" && return
	fi

	if [ '--help' == "$1" ]; then
		echo "Usage: youtube-video <video-url>" && return
	fi

	youtube-dl --extract-audio --audio-format mp3 "$1"
}

###
 # Clear out directories where files in them don't matter.
 #
 # E.g: clear [downloads|tmp]
 #
 # @since Monday, January 14, 2019
 ##
function empty {
	if [ '' == "$1" ]; then
		echo "Clear what: all, downloads, trash, tmp?" && return;
	fi

	if [ 'tmp' = "$1" ] || [ 'all' = "$1" ]; then

		echo "Clearing ~/tmp/*..."
		nohup rm -Rf ~/tmp/* &> /dev/null &> /dev/null

		if [ 'all' != "$1" ]; then
			return;
		fi
	fi

	if [ 'downloads' = "$1" ] || [ 'all' = "$1" ]; then

		echo "Clearing ~/Downloads/*..."
		nohup rm -Rf ~/Downloads/* &> /dev/null &> /dev/null

		if [ 'all' != "$1" ]; then
			return;
		fi
	fi

	if [ 'trash' = "$1" ] || [ 'all' = "$1" ]; then

		echo "Emptying Trashes..."
		nohup empty-trash &> /dev/null &> /dev/null

		if [ 'all' != "$1" ]; then
			return;
		fi
	fi
}

###
 # Copy the current directory path.
 #
 # E.g:  cpwd
 #
 # @since Wednesday, April 3, 2019
 ##
function pwd-copy {
	pwd | pbcopy
}

###
 # Way to start MySQL.
 #
 # E.g: myup
 #
 # @since Wednesday, April 17, 2019
 ##
function mysql-up {
	brew services start mysql@5.7
}

###
 # Way to stop MySQL
 #
 # E.g: mydown
 #
 # @since Wednesday, April 17, 2019
 ##
function mysql-down {
	brew services stop mysql@5.7
}

###
 # Easy way to restart MySQL.
 #
 # E.g: myrestart
 #
 # @since Wednesday, April 17, 2019
 ##
function restart-mysql {
	brew services restart mysql@5.7
}

###
 # Easy way to restart valet and MySQL.
 #
 # E.g: restartv
 #
 # @since Wednesday, April 17, 2019
 ##
function restart-local {
	brew services restart mysql@5.7
	valet restart
}

###
 # Zip up a Valet site.
 #
 # E.g: vale-package folder-name "Notes about stuff"
 #
 # @since Tuesday, May 7, 2019
 ##
function valet-package {
	dir="$1"

	zip_dir="$HOME/Valet/$dir"

	date=$(date "+%Y-%m-%d_%H-%M-%S")

	current_dir=$(pwd)

	notes="$2"

	package_dir="$zip_dir/.packages"

	if ! [ -f "$package_dir" ]; then
		mkdir "$package_dir" &> /dev/null
	fi

	if [ -f "$zip_dir" ]; then
		echo "$zip_dir does not exist..."
		return
	fi

	zip_file="$package_dir/$date-$notes.zip"

	if [ -f "$zip_file" ]; then
		trash "$zip_file"
	fi

	cd "$zip_dir" || return
	zip -r -q "$zip_file" "./" &> /dev/null
	cd "$current_dir" || return

	echo "Done! Created $zip_file on $date"
}

###
 # Add spacer to Dock.
 #
 # E.g: dock-add-spacer
 #
 # @since Tuesday, May 14, 2019
 ##
function dock-add-spacer {
	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'; killall Dock
}
