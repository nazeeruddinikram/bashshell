#!/bin/bash

# Author: Joshua Bailey
# Script: trimFilename
# *** means works
# Syntax: trimFilename "<filename>" <whatToRemove>
# Example: trimFilename "some picture.jpg"
# Will return: somepicture.jpg
# Example: trimFilename some_picture.jpg _
# Will return: somepicture.jpg
# *** Example: trimFilename --space
# Will: Remove all spaces from all filenames in the directory
# *** Example: trimFilename --underscore
# Will: Remove all underscores from all filenames in the directory

fSlash='/'
STRING=""
LENGTH=0
CHAR=''
FileName=""
dir=""
record=""
NewString=""
rmChar=''

function notAForwardSlash
{
   if [[ $1 != $fSlash ]]
        then
      return 0
        else
           return 1
        fi
}
### end notAForwardSlash ###

function getFileName
{
   STRING=$1
        LENGTH=${#STRING}
   for ((n=0;n <= $LENGTH; n++))
        do
      CHAR=${STRING:$n:1}
      if notAForwardSlash $CHAR
      then
         FileName=$FileName$CHAR
      else
         FileName=""
      fi
   done
}
### end getFileName ###

function readWriteError()
{
   echo "*** You do not have read/write access to $1! ***"
}

function getDirectory()
{
   read -p "Please enter the directory you would like to edit: " dir
   if [[ ! -e $dir ]]
   then
      echo "*** $dir does not exist! ***"
      echo "*** Aborting! ***"
      exit
   fi
   echo "*** About to edit $dir ***"
}
### end getDirectory ###

function checkReadWriteAccess()
{
   ls $1 > /dev/null
   if [[ $? -eq 1 ]]
   then
      return 1
   else
      touch $1/bob.yea\ do0d 2> /dev/null
      if [[ $? -eq 1 ]]
      then
         rm $1/bob.yea\ do0d 2> /dev/null
         return 1
      else
         rm $1/bob.yea\do0d 2> /dev/null
         return 0
      fi
      
   fi
}
### end checkReadWriteAccess ###

function rmAllUnderScores()
{
   ls *_* > uFileNames
   
   until ! read record
   do
      trimspaces "$record" '_'
      mv "$record" "$NewString"
   done < uFileNames
}
### end rmAllUnderScores ###

function rmAllSpaces()
{
   ls *\ * > sFileNames
   
   until ! read record
   do
      trimspaces "$record"
      mv "$record" "$NewString"
   done < sFileNames
}
### end rmAllSpaces
   
function trimspaces()
{
   NewString=""
   STRING="$1"
   rmChar=$2
   if [[ $rmChar = "" ]]
   then
      rmChar=' '
   fi
   for ((i=0; i<${#STRING}; i++))
   do
      CHAR=${STRING:$i:1}
      if [[ $CHAR != $rmChar ]]
      then
         NewString=$NewString$CHAR
      fi
   done
}
### end trimspaces ###

if [[ $1 != "" ]]
then
   arg="$1"
   if [[ ${arg:0:2} = "--" && $2 = "" ]]
   then
      case $arg in
         --space) getDirectory;
             if checkReadWriteAccess $dir
             then
                cd $dir;
               rmAllSpaces;
               cd ~-;
            else
               readWriteError $dir;
               exit;
            fi;
            ;;
         --underscore) getDirectory;
            if checkReadWriteAccess $dir
            then
               cd $dir;
               rmAllUnderScores;
               cd ~-;
            else
               readWriteError $dir;
               exit;
            fi;
            ;;
         *) echo "not made yet";
            ;;
      esac
   else
      arg2="$2"
      if [[ ! -e $arg2 ]]
      then
         echo "*** $arg2 does not exist! ***"
         echo "*** Aborting! ***"
         exit
      else
         getFileName "$arg2"
         #### must get directory ####
      fi
   fi
fi
### must finish single file changing ###
