#!/bin/bash
##########################
# USA Linux Users Group  #
# http://www.usalug.org  #
# http://bashscripts.org #
##########################


########################################################
#     bics- bash interactive clipboard script          #
########################################################
#
#
#
#    FILE: bics.sh
# VERSION: 0.0.1
#    DATE: 09-06-2005
#
#  AUTHOR: Dave Crouse <dave NOSPAMat usalug.org>
#          PO Box 3210
#          Des Moines, IA 50316-0210
#          United States
#
# Copyright (C) 2005
# Dave Crouse <dave NOSPAMat usalug.org>
# All rights reserved.
#
########################################################


#########################################################################
#  This software is licensed under the GPL - GNU General Public License #
#########################################################################
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
# Foundation, Inc.
# 59 Temple Place, Suite 330
# Boston, MA  02111-1307  USA
#
###################################################################

######################
# Start of Variables #
######################
#
#
#########################################################
                                                       ##
bics_version="0.1.0"                                   ##
revision_date="Modified September 7, 2005"             ##
author="Created by: Dave Crouse and Joshua Bailey"     ##
                                                       ##
#########################################################
#
#
######################
# End of Variables   #
######################


######################
# Start of Functions #
######################
#
#

headerfile ()
{
clear
echo "
(B)ash (I)nteractive (C)lipboard (S)cript
bics - Version $bics_version  clipboard.clip";
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
mkdir -p ~/.bics
touch ~/.bics/clipboard.clip
touch ~/.bics/clip2.txt
nl -ba  ~/.bics/clipboard.clip
echo "";
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
}


Main_Menu ()
{
mainmenu="     a)dd  r)emove  c)lear  h)help  e)xit"
headerfile
echo -e "$mainmenu"
echo "";
read -p "Please choose one of the options above : " option

while true
do
   case $option in
      a)   read -p "Enter your text : " clippy; echo $clippy >> ~/.bics/clipboard.clip;
         ;;
      r)   rm ~/.bics/clip2.txt;
     read -p "Which line you would like to delete : " removeline;
     if [[ $removeline != "" ]]
     then
         cat ~/.bics/clipboard.clip | sed ''$removeline'd' > ~/.bics/clip2.txt;
         mv ~/.bics/clip2.txt ~/.bics/clipboard.clip
     fi
     ;;
      c)   read -p "Are you sure you want to erase the entire clipboard ? y/n: " reallycontinue
              if [ "$reallycontinue" = "y" ]
                 then
                     rm ~/.bics/clipboard.clip; echo "!! Erasing Clipboard !!" ; sleep 1;
               fi
         ;;
      h)   helpfile ;
         ;;   
      e)   option="";
         exit;
         ;;
      alias)  echo "alias bics='sh $PWD/bics.sh'" >> ~/.bashrc;
         ;;   
      *)   echo "Sorry, that isn't an option, try again. "; sleep 2;
         ;;
   esac
   headerfile
   echo -e "$mainmenu"
   echo "";   
   read -p "Please choose one of the options above : " option
done

}


helpfile ()
{
clear
echo "
(B)ash (I)nteractive (C)lipboard (S)cript
bics - Version $bics_version  clipboard.clip";
echo "";
echo "This is the help file for bics - (B)ash (I)nteractive (C)lipboard (S)cript";
echo ""
echo "Tip #1 Typing alias will set an alias into your .bashrc file. You can then start the clipboard by typing   bics ";
echo ""
read -p "Hit any key to continue" blah
}
#
#
####################
# End of Functions #
####################


###########################
# Program run starts here #
###########################
headerfile
Main_Menu
exit
