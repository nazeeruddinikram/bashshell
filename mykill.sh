#!/bin/bash

#File: mykill
#Copyright (C)2005 Chitlesh GOORAH

# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. */

# purpose: killing processes via their names
# with the creation of a temp file
# usage: ./mykill (process to kill)
# Author:Chitlesh GOORAH
# DEUG STPI 2 (UNIVERSITY OF LOUIS PASTEUR) (2005)

murder() {

# cutting from pts/1 00:00:00 $I

   NPID=`cat liste.$$ | grep $I | cut -dp -f1`

# testing if contains numbers

   NNPID=`echo $NPID | grep '\<[1-9]'`

# if last command is successfull then

   if [ $? -eq 0 ]

   then

      kill $NPID

      echo "mykill:Process: $I ($NPID) killed."

   else

      echo "mykill:Process: $I No Action Taken."

   fi

}

#creation of temporary file

#testing if there are more than one parameters

if [ $# -gt 0 ]

then

#sending All to temp file liste.$$

   ps > liste.$$

#processing elements passed as parameters

   for I in $*

   do

      murder

   done

#deletion of temp file liste.$$

   rm liste.$$

else echo "mykill:usage: ./mykill  (process to kill)"

fi
