#! /bin/sh
# File: notes
# Description: Simple Note keeping script.
# Alias to "n"  # alias n='sh /home/crouse/scripts/notes.sh'
# USAGE EXAMPLES: 
#n a "This is a note"  (adds the line enclosed in quotes)
#n d 2 (removes line 2)
#n l (lists all lines)
#n s EXPRESSION (searchs for EXPRESSION)
# Options: a=add d=delete (or r=remove) l=listall s=search
# Set your paths below - next 2 lines
FILEPATH="/home/crouse"
FILE="notes.txt"

touch ${FILEPATH}/${FILE}

if [ "$1" = "a" ] ; then
  echo $2 >> ${FILEPATH}/${FILE}
fi

if [ "$1" = "s" ] ; then
  grep -i "$2" ${FILEPATH}/${FILE} | less
fi

if [ "$1" = "d" ] || [ "$1" = "r" ] ; then
  numberoflines=`less ${FILEPATH}/${FILE} | wc -l`
  bottompartoffile=`echo $((${numberoflines}-${2}))`
  headvar=`echo $((${2}-1))`
  head -n ${headvar} ${FILEPATH}/${FILE} > /tmp/notes
  tail -n ${bottompartoffile} ${FILEPATH}/${FILE} >> /tmp/notes
  mv /tmp/notes ${FILEPATH}/${FILE}
fi

if [ "$1" = "l" ] ; then
  nl ${FILEPATH}/${FILE} | less
fi

if [ "$1" = "clear" ] ; then
  rm -f ${FILEPATH}/${FILE} #removes ALL NOTES !!
fi

exit 0
