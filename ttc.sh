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

if [[ ! -f $1/TamrielTradeCentre.lua ]]; then
	echo "Pass the directory of the TTC folder as an argument ; ex.: ~/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/My Documents/Elder Scrolls Online/live/AddOns/TamrielTradeCenter"
	exit 1
fi

DOWNLOADPT=0
if [[ ! -f $1/PriceTable.lua ]]; then
	DOWNLOADPT=1
else
	mtime=$(ls --time-style=+%s -l "$1/PriceTable.lua" | cut -d\  -f 6)
	ctime=$(date +%s)
	tdiff=$(($ctime - $mtime))
	if [[ $tdiff -ge 43200 ]]; then
		DOWNLOADPT=1
	fi
fi

if [[ $DOWNLOADPT == 0 ]]; then
	echo "TTC Price Table is up to date."
	exit 0
fi

echo "Downloading new TTC Price Table."
wget -q -nv -O /tmp/PriceTable.zip https://us.tamrieltradecentre.com/download/PriceTable
if [[ -f /tmp/PriceTable.zip ]]; then
	unzip -qq -o -d "$1" /tmp/PriceTable.zip
	rm -f /tmp/PriceTable.zip
fi
