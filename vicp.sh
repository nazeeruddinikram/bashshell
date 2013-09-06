#!/bin/bash

trap "leave" EXIT HUP INT TERM KILL
export DIALOGOPTS="--backtitle \"ViCp\""

leave ()
{
#make sure all the lights are off
   if [ ! -z $DIAPID ];then
      tput cup $(($(tput lines)-1)) 0
      echo  "//@@EOF@@//" >$FIFO
   fi
   rm $FIFO 2>/dev/null
   kill -9 $CPPID $DIAPID  2>/dev/null
}

DATAARRAY=""
NOGRAPH=0
RECURSE=0
ARRAYCNT=0
DIAPID=""
TOTALFILES=0
CURRENTFILE=0
SIMULATE=0

#'cos I'm anal that way!
prettyprint ()
{
   local RETVAL="$1"

   if [ ! -z "$RETVAL" ];then
      RETVAL=${RETVAL#./}
      RETVAL="${RETVAL%/}"

      if [ "$RETVAL" = "." ];then
         RETVAL="$PWD"
      fi

      if [ "${RETVAL:0:1}" != "/" ];then
         RETVAL="$PWD/$RETVAL"
      fi
   fi
   echo "$RETVAL"
}

#check some stuff before doing the copy
sanitycheck ()
{
   if [ ${#DATAARRAY[@]} -gt 2 ] && [ ! -d ${DATAARRAY[ARRAYCNT - 1]} ];then
      echo "vicp: target is not a directory"
      exit -1
   fi

   if [ $RECURSE -eq 0 ];then

      for (( CNT=0;CNT<(( $ARRAYCNT - 1 ));CNT++ ))
         do
#non-fatal error dont copy directories unless using recurse
            if [ -d "${DATAARRAY[$CNT]}" ];then
               echo "vicp: omitting directory ${DATAARRAY[$CNT]}"
               DATAARRAY[$CNT]=""
            fi
         done
   fi

   for (( CNT=0;CNT<ARRAYCNT-1;CNT++ ))
      do
         if [ ! -e "${DATAARRAY[$CNT]}" ];then
            echo "vicp: cannot stat ${DATAARRAY[$CNT]} : No such file or directory"
            exit -1
         fi
         DATAARRAY[$CNT]=$(prettyprint "${DATAARRAY[$CNT]}")
         TOTALFILES=$((TOTALFILES+$(find "${DATAARRAY[$CNT]}" ! -type d |wc -l)))
      done

   OUT=$(prettyprint "${DATAARRAY[$CNT]}")
}

#Check command line parameters
doparams ()
{
   local PARAMS CNT

   for PARAMS in "$@"

      do
         case $PARAMS in

         -[[:alnum:]]*)
            for (( CNT=1;CNT<${#PARAMS};CNT++ ))
               do
#peel off -r and -X
                  if [ ${PARAMS:CNT:1} = "r" -o ${PARAMS:CNT:1} = "R" ];then
                     RECURSE=1
                     continue
                  fi
                  if [ ${PARAMS:CNT:1} = "X" ];then
                     NOGRAPH=1
                     continue
                  fi
#EVALSTRING is eventually passed to the "real" cp command
                  EVALSTRING="${EVALSTRING} -${PARAMS:CNT:1}"
               done
            ;;

#we do recursive
         --recursive)
            RECURSE=1
            ;;

#just checking
         --simulate)
            SIMULATE=1
            NOGRAPH=1
            ;;

         --[[:alnum:]]*)
            EVALSTRING="${EVALSTRING} ${PARAMS}"
            ;;
         
         *)
            DATAARRAY[$ARRAYCNT]="${PARAMS}"
            (( ARRAYCNT++ ))
            ;;
         esac
      done
}

#main cp routine
docp ()
{   
   local TOSIZE PERCENT

#either do a fancy dialog output
   if [ $NOGRAPH -eq 0 ];then
      while (( FROMSIZE>TOSIZE )) && ps $CPPID &>/dev/null
         do
            TOSIZE=$(stat "$2" 2>/dev/null |grep Size|awk '{print $2}')
            TOSIZE=${TOSIZE:-0}

            PERCENT=$(echo "scale=2 ;100/($FROMSIZE/($TOSIZE+1))"|bc -l 2>/dev/null )
            PERCENT=${PERCENT%.?*}
            if (( PERCENT>100 ));then
               PERCENT=100
            fi
#if only copying one file then no overall progress bar
#from file=$1 to file =$2
            if [ $TOTALFILES -gt 1 ];then
               echo "$1@$2@$TOSIZE@$FROMSIZE@$CURRENTFILE@$PERCENT" >$FIFO
            else
               echo "$1@$2@$TOSIZE@$FROMSIZE@$PERCENT" >$FIFO
            fi
         done
#or a dull command line output
   else
      while (( FROMSIZE>TOSIZE )) && ps $CPPID &>/dev/null
         do
            TOSIZE=$(stat "$2" 2>/dev/null |grep Size|awk '{print $2}')
            TOSIZE=${TOSIZE:-0}
            PERCENT=$(echo "scale=2 ;100/($FROMSIZE/($TOSIZE))"|bc -l 2>/dev/null )
            echo -en "\rCopied ${TOSIZE}B of ${FROMSIZE}B (${PERCENT%.?*}%) to $2"
         done
   fi

#just clean up command line output
   if [ $NOGRAPH -eq 1 ];then

      TOSIZE=$(stat "$2" 2>/dev/null |grep Size|awk '{print $2}')
      TOSIZE=${TOSIZE:-0}

      if [ "$FROMSIZE$TOSIZE" = "00" ];then
         PERCENT=100
      else
         PERCENT=$(echo "scale=2 ;100/($FROMSIZE/($TOSIZE))"|bc -l 2>/dev/null )
      fi

      echo -e "\rCopied ${TOSIZE}B of ${FROMSIZE}B (${PERCENT%.?*}%) to $2"
   fi
}

#the bit does the actual copying
dovicp ()
{
   local TONAME="$2"

#cp is run in the back ground

   if [ $SIMULATE -eq 1 ];then
      echo "cp $EVALSTRING \"$1\" \"$TONAME\""
      return
   else
      cp $EVALSTRING "$1" "$TONAME" &
   fi

   CPPID=$!
   FROMSIZE=$(stat "$1" 2>/dev/null |grep Size|awk '{print $2}')

   if [ -d "$2" ];then
      TONAME="$TONAME/$(basename "$1")"
   fi

   (( CURRENTFILE++ ))
   if [ $NOGRAPH -eq 1 ] && [ $TOTALFILES -gt 1 ];then
      echo "File $CURRENTFILE of $TOTALFILES"
   fi

#run the output stuff   
   docp "$1" "$TONAME"
}

#set up the overall progress bar
setupoverbar ()
{
   FROMBAR="                             "
   BAR=""

   BARSIZE=$(($(tput cols)-10))
   while (( ${#FROMBAR}<BARSIZE ))
      do
         FROMBAR="${FROMBAR}${FROMBAR}"
      done
   FROMBAR=${FROMBAR:0:$(($BARSIZE-12))}
   MID=$(((BARSIZE/2)-5))
}

#main loop takes care of recursion
main ()
{
#simple case
   if [ $RECURSE -eq 0 ] && [ $ARRAYCNT -eq 2 ];then
      dovicp "${DATAARRAY[0]}" "${DATAARRAY[1]}"
      exit 0
   fi

   for (( CNT=0;CNT<(( $ARRAYCNT - 1 ));CNT++ ))
      do

#dropped bad file name passed on command line
         if [ -z "${DATAARRAY[$CNT]}" ];then
            continue
         fi

#if its a directory then recurse
         if [ -d "${DATAARRAY[$CNT]}" ];then
            TOFOLD=$(basename "${DATAARRAY[$CNT]}")
            TOUT="${OUT}/${TOFOLD}"
            cd "${DATAARRAY[$CNT]}"
            find -mindepth 1 -type d -exec mkdir -p "${TOUT}"/'{}' \;
            while read
               do
                  FROMFILE=$(prettyprint "$REPLY")
                  TOFILE="${OUT}/$(basename "${DATAARRAY[$CNT]}")${FROMFILE##"${DATAARRAY[$CNT]}"}"
                  dovicp "$FROMFILE" "$TOFILE"
               done < <(find  ! -type d)
            cd $OLDPWD
#else just a file copy
         else
            dovicp "${DATAARRAY[$CNT]}" "$OUT/$(basename "${DATAARRAY[$CNT]}")"
         fi
      done
}

#run the dialog in the background
rundialog ()
{
#taller dialog for multifile copy
   if [ $TOTALFILES -gt 1 ];then
      HEIGHT=11
   else
      HEIGHT=8
   fi

   (
   while [ -e $FIFO ]
      do
         read <$FIFO      

#time to go
         if [ X"$REPLY" = X"//@@EOF@@//" ];then
            exit 0
         fi

#print fancy stuff in the dialog box
         echo "XXX"
         if [ $(echo "$REPLY"|awk -F "@" '{print NF }') -gt 5 ];then
            CURRENTFILE=$(echo "$REPLY"|awk -F "@" '{print $5}')

#dialog won't let me have two bars so roll my own
            TOTSLICES=$(echo "scale=2 ;($BARSIZE/$TOTALFILES*$CURRENTFILE)+0.5"|bc -l 2>/dev/null)
            TOTSLICES=${TOTSLICES%.?*}

            PERCENT=$(echo "scale=2 ;100/($TOTALFILES/$CURRENTFILE)"|bc -l 2>/dev/null )
            PERCENT=${PERCENT%.?*}
            PERCENT=${PERCENT:-0}

            BAR="${FROMBAR:0:$MID}${PERCENT}%${FROMBAR:$MID:$BARSIZE}"
            TOBAR="\Zb\Z3\Zr  ${BAR:0:$((TOTSLICES))}\Zn\Z3\Zb${BAR:$((TOTSLICES)):$(( BARSIZE-(TOTSLICES) ))}"

            echo "\Zb\Z3File \Zn$CURRENTFILE \Zb\Z3of \Zn$TOTALFILES"
            echo "\Zb\Z3Overall Progress\Zn"
            echo "$TOBAR"
         fi
         echo "$REPLY"|awk -F "@" '{print "\\Zb\\Z3From:\\Zn"$1}'
         echo "$REPLY"|awk -F "@" '{print "\\Zb\\Z3To:\\Zn"$2}'
         echo "$REPLY"|awk -F "@" '{print "\\Zb\\Z3Copied \\Zn" $3 "B \\Zb\\Z3of \\Zn" $4 "B"}'
         echo "XXX"
         echo "$REPLY"|awk -F "@" '{print $NF }'

      done |dialog --colors --title "Copying..." --no-collapse --gauge "" $HEIGHT $(($(tput cols)-10))

#run it in the background as a sub proccess
   )&
   DIAPID=$!
}

#lets get going
setterm -msg off
doparams "$@"
sanitycheck
FIFO=$(tempfile)
mkfifo $FIFO 2>/dev/null
#TOTALFILES=34
setupoverbar


if [ $NOGRAPH -eq 0 ];then
   rundialog
fi

main
leave
