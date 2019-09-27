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
    6
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
    https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
LICENSE

# Fetch TTC price table before starting ESO. Set to 0 to disable.
UPDATE_TTC=${UPDATE_TTC:-0}
# Update addons before starting ESO. Set to 0 to disable.
UPDATE_ADDONS=${UPDATE_ADDONS:-0}
# Path to ESO addons folder.
ESO_ADDONS_PATH=${ESO_ADDONS_PATH:-~/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/My Documents/Elder Scrolls Online/live/AddOns}
# Command to start ESO
ESO_COMMAND=${ESO_COMMAND:-"steam steam://rungameid/306130"}
# Process name used by the ESO launcher - this is what it's called for steam, I don't know about the native launcher. Use pgrep/ps/htop/etc. to find it.
ESO_LAUNCHER_COMMAND=${ESO_LAUNCHER_COMMAND:-"/bufferselfpatchfix /steam true"}


CWD=$(dirname $(realpath $0))
if [[ $UPDATE_TTC == 1 ]] && [[ -f $CWD/ttc.sh ]]; then
	bash "$CWD/ttc.sh" "$ESO_ADDONS_PATH/TamrielTradeCentre"
fi

if [[ $UPDATE_ADDONS == 1 ]] && [[ -f $CWD/addons.sh ]]; then
	bash "$CWD/addons.sh" "$ESO_ADDONS_PATH"
fi

bash -c "$ESO_COMMAND"

# Wait for the ESO launcher to start.
while [[ $(pgrep -f "/bufferselfpatchfix /steam true") == "" ]]; do
	sleep 1
done

# Kill the launcher once the game is running - the launcher is reported to reduce game performance.
while [[ $(pgrep eso64.exe) == "" ]]; do
	# The ESO launcher was closed before starting ESO, so stop waiting for ESO to start.
	if [[ $(pgrep -f "/bufferselfpatchfix /steam true") == "" ]]; then
		exit 0
	fi
	sleep 10
done
pkill -f "/bufferselfpatchfix /steam true"

# You can do stuff here - like use xrandr to change your resolution / refresh rate before ESO starts.

# Wait until ESO is closed.
while [[ $(pgrep eso64.exe) != "" ]]; do
	sleep 30
done

# You can do stuff now that ESO is closed, like reverting your resolution / refresh rate for example.
