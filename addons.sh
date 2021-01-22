#!/bin/bash

<<LICENSE
    Copyright (C) 2019  kevinlekiller
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
    https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
LICENSE

# Set to 1 if you want to force updating addons.
FORCE_UPDATE=${FORCE_UPDATE:-0}

if [[ ! -d $1 ]]; then
	echo "Pass the directory of the ESO addons folder as an argument ; ex.: ~/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/My Documents/Elder Scrolls Online/live/AddOns"
	exit 1
fi

CWD=$(dirname $(realpath $0))

if [[ ! -f "$CWD/addons.txt" ]] || [[ ! -s "$CWD/addons.txt" ]]; then
	echo "Please add your addons to addons.txt, one per line using the URL from https://www.esoui.com"
	exit 1
fi

if [[ $FORCE_UPDATE == 0 ]] && [[ -f "$CWD/.time" ]]; then
	# Only check addons max every 4 hours - to prevent load on the esoui server.
	TDIFF=$(($(date +%s) - $(cat "$CWD/.time")))
	if [[ $TDIFF -le 14400 ]]; then
		MDIFF=$(bc -l <<< $TDIFF/60 | cut -d. -f1)
		if [[ $MDIFF != "" ]]; then
			echo "Addons already checked $MDIFF minute(s) ago, skipping."
		else
			echo "Addons already checked $TDIFF second(s) ago, skipping."
		fi
		exit 0
	fi
fi

TMPDIR="/tmp/esoaddons"
mkdir -p "$TMPDIR"
rm -rf "$TMPDIR/*"

# del url name ver dirs
while read line; do
	if [[ $line == "" ]]; then
		continue
	fi

	if [[ ! $line =~ ^https:// ]]; then
		if [[ $line =~ ^del ]]; then
			echo "Deleting addon $(echo $line | cut -d\  -f3)"
			ADIRS=$(echo "$line" | cut -d\  -f5)
			for adir in $(echo "$ADIRS" | sed "s# #|#" | tr '|' '\n'); do
				rm -rf "$1/$adir"
			done
			sed -i "s#$line##" "$CWD/addons.txt"
		else
			echo "Problem parsing this addon: $line"
		fi
		continue
	fi

	AURI=$(echo "$line" | cut -d\  -f1)
	ANAME=$(echo "$line" | cut -d\  -f2)
	AVERS=$(echo "$line" | cut -d\  -f3)
	
	if [[ $ANAME == $AURI ]]; then
		ANAME=$(echo "$line" | grep -Poi "info\d+-[^.]+" | cut -d- -f2)
	fi
	if [[ $AVERS == $AURI ]]; then
		AVERS=""
	fi

	RVERS=$(curl -s $AURI 2> /dev/null | grep -Poi "<div\s+id=\"version\">Version:\s+[^<]+" | cut -d\  -f3)
	if [[ $RVERS == "" ]];  then
		echo "Error finding version of addon $ANAME on esoui.com"
		sleep 1
		continue
	fi
	
	if [[ $RVERS == $AVERS ]]; then
		echo "Addon $ANAME is up to date."
		continue
	fi

	DURI=$(curl -s $(echo "$AURI" | sed "s#/info#/download#" | sed "s#.html##") 2> /dev/null | grep -m1 -Poi "https://cdn.esoui.com/downloads/file[^\"]*")
	wget -q -O "$TMPDIR/addon.zip" "$DURI"
	unzip -o -qq -d "$TMPDIR" "$TMPDIR/addon.zip"
	rm "$TMPDIR/addon.zip"
	ADIRS=""
	for dir in $(ls -d "$TMPDIR/"*); do
		dir=$(basename "$dir")
		rm -rf "$1/$dir"
		mv -f "$TMPDIR/$dir" "$1/"
		if [[ $ADIRS == "" ]]; then
			ADIRS="$dir"
		else
			ADIRS="$ADIRS|$dir"
		fi
	done
	# del url name ver dirs
	sed -i "s#$line#$AURI $ANAME $RVERS $ADIRS#" "$CWD/addons.txt"
	echo "Updated addon $ANAME"
	sleep 1
done < "$CWD/addons.txt"

sed -i '/^$/d' "$CWD/addons.txt"
echo $(date +%s) > "$CWD/.time"
