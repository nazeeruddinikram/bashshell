#!/bin/bash
#
# Changes my desktop pic each day
# David.Stringer@ticketmaster.co.uk
#
# desktop.sh
# Copyright (C) 2007-2010  David Stringer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

# sets DEBUG=0 unless it's set to something already
# turns on logging if set to >0
# can be turned on in the parent environment like so;
# DEBUG=1 desktop.sh
DEBUG=${DEBUG:-0}

# location of pic and log
cd /home/david/scripts/desktop
LOGFILE=/home/david/scripts/logs/desktop.log

# this sort of function is normally sourced from my scripting library
# for now I have just embedded a tweaked version of it, which is why it's a bit wordy
function maylog { # writes to $LOGFILE if it can
  if [ "$DEBUG" -eq 0 ]
  then
    return 0
  fi
  if [ "$LOGFILE" != "" -a -w "$LOGFILE" -o -w "$(dirname $LOGFILE)" ]
  then
    local icount=$#
    local iloop
    for ((iloop=0; iloop < $icount; iloop++))
    do
      echo "$1" >> "$LOGFILE"
      shift 1
    done
  fi
}

maylog "Starting desktop.sh"
maylog "$(date)"

picname=`wget -q -O - http://antwrp.gsfc.nasa.gov/apod/astropix.html | grep '<IMG SRC="' | head -1 | awk -F\" '{ print $2 }' 2>>/dev/null`

maylog "  picname=$picname"

if echo $picname | egrep '.jpg' >/dev/null
then
  maylog "Grabbing $picname"
  wget -q -O downloaded.jpg http://antwrp.gsfc.nasa.gov/apod/$picname 2>>/dev/null
  mv -f downloaded.jpg desktop.jpg 2>>/dev/null
else
  maylog "No jpg today"
fi

maylog "Complete" " "
