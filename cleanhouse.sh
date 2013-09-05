#! /bin/bash
#
# CleanHouse Script V.2 By Mark Reaves (C)2006
# You may freely distribute this script as long as all comments
# remain in this file. Feel the love of Linux ;-)
#
# This script simply moves files in the users home folder (/home/user)
# to other more organised folders based on extension.
# In the variables section, $HOME will become /home/yourusername

# Please change the variables to suit your needs.
CLUTTERDIR=$HOME          # Default is /home/username. This is the cluttered directory.
MP3DIR=$HOME/Music/mp3          # Default is /home/username/Music/mp3
OGGDIR=$HOME/Music/ogg          # Default is /home/username/Music/ogg
TEXTDIR=$HOME/Texts          # Default is /home/username/Texts
VIDDIR=$HOME/Videos          # Default is /home/username/Videos
SCRIPTDIR=$HOME/Texts/Scripts  # Default is /home/username/Texts/Scripts

cd $CLUTTERDIR
mkdir -p $MP3DIR $OGGDIR $TEXTDIR $VIDDIR $SCRIPTDIR
clear

cat<<_EOF_
Script Starting.

Greetings $USER! Welcome to my cleanup script.
Depending on the speed of your computer
and how many files you have to move
and their size, this could take awhile.
If this messes up your computer,
IT'S NOT MY FAULT!

_EOF_
read -p "Are you ready (yes or no)? " ANSWER
if [[ $ANSWER = yes ]]
   then
      echo "Ok, Lets proceed.";
   else
      echo "Too bad, exiting.";
      exit
   fi
echo "Cleaning up! Please wait..."

ls | while read; do
   case $REPLY in
   (*.mp3)
       mv $REPLY $MP3DIR;;
   (*.ogg)
       mv $REPLY $OGGDIR;;
   (*.txt)
       mv $REPLY $TEXTDIR;;
   (*.doc)
       mv $REPLY $TEXTDIR;;
   (*.rtf)
       mv $REPLY $TEXTDIR;;
   (*.avi)
       mv $REPLY $VIDDIR;;
   (*.mpg)
       mv $REPLY $VIDDIR;;
   (*.mpeg)
       mv $REPLY $VIDDIR;;
   (*.asf)
       mv $REPLY $VIDDIR;;
   (*.sh)
       mv $REPLY $SCRIPTDIR;;
   
   # for any types that aren't in a case statement, they will be left alone
   esac
done

cat<<_EOF_
---------------------------------------------------------
Cleaning complete!
Thank you for using my script.
Please let me know of suggestions
ideas or bug fixes by emailing me at
motstudios@gmail.com
---------------------------------------------------------
_EOF_
