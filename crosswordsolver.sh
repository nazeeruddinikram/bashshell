#!/bin/bash
##########################
# USA Linux Users Group  #
# http://www.usalug.org  #
# http://bashscripts.org #
##########################
#
#
#
#    FILE: crosswordsolver.sh
# VERSION: .0.0.1
#    DATE: 12-22-2004
#
#  AUTHOR: Dave Crouse <dave NOSPAMat usalug.org>
#          PO Box 3210
#          Des Moines, IA 50316-0210
#          United States
#
#
# Copyright (C) 2004 Dave Crouse <dave NOSPAMat usalug.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
######################################################################################
#
clear
echo "##########################################"
echo "# Grep the great Crossword Puzzle Solver #"
echo "##########################################"
echo ""
echo "This script uses the grep command to do a dictionary search for words that you know some parts of."
echo ""

# Functions starts here
searchwords ()
{
read -p "Please enter the letters you know, and use the period for the letters you don't know.  " unknowntext
grep '\<'$unknowntext'\>' /usr/share/dict/words
echo ""
}

# Program starts here
while true; do
echo "You can quit by using CTL-C to exit"
searchwords
done
exit
