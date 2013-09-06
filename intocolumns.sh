#!/bin/sh
# eg, ls | col 2  #puts ls output into two columns.

main() {
if echo $1|egrep -q '(-h|--h)';then
  echo -e '\nUsage: col [-l] [n]'\
       "\n\n"Pipes input into columns. \
      '\n\n\t n\tnumber of columns.  Also set with NCOLS variable.'\
      '\n\t\tDefault, columns as will fit.'\
      '\n\n\t-l\tExpects input of one item per line.'\
      '\n\nExample:\t$ls |col 3\n'\
      '\t\t'Converts output of the ls command into 3 columns.'\n'\
      '\n\nExample:\t$ls -1|col -l 2\n'\
      '\t\t'Converts output of command, ls -1, into 2 columns.'\n';

  exit 1;
fi
if test "$1" = -l;then collines=true;shift;fi;
if test -z $NCOLS;then if test "$1"; then NCOLS=$1; fi; fi
if test -z $COLUMNS;then COLUMNS=`stty -F /dev/tty size|cut -d' ' -f2`;fi
local ellipsis_char=`echo -e "\xe2\x80\xa6"`;
if test ${#ellipsis_char} -ne 1; then BASH_BUG=true; fi
IFS=$(echo -en "\n\b ")
if test $collines;then IFS=$(echo -en "\n\b");fi
values=(`cat`)
#echo debug col. NCOLS:$NCOLS. width:$COLUMNS

longest_value=0
for value in "${values[@]}"; do
  if [[ ${#value} -gt $longest_value ]]; then
    longest_value=${#value}
  fi
done
term_width=$COLUMNS;
if test "$NCOLS";then
    ncolumns=$NCOLS;
  else
    (( ncolumns = term_width / (longest_value+1) ))
    if test $ncolumns -lt 2;then ncolumns=2; fi;
fi
(( col_width = (term_width / ncolumns) ))
#echo debug longest $longest_value, col_width:$col_width, no of cols,$ncolumns.
i=0
for value in "${values[@]}"; do
   values[$i]=`justify $((col_width-1)) $value`;
   let i=i+1;
done
curr_col=0
for value in "${values[@]}"; do
      value_len=`strlen $value`;
      echo -n "$value" 2>/dev/null
      (( spaces_missing = $col_width - $value_len  ))
#     echo -ne ""DEBUG spaces_mmissing $spaces_missing. val len $value_len
      (( curr_col++ ))
      if [[ $curr_col == $ncolumns ]]; then
       echo 2>/dev/null #in case of sigpipe
       curr_col=0
     else
        printf "%*s" $spaces_missing 2>/dev/null
      fi
  done
 
  # Make sure there is a newline at the end
  if [[ $curr_col != 0 ]]; then
      echo 2>/dev/null
  fi
#for i in $(seq 0 $term_width);do echo -n $((i%10));done;
 
}



justify() {
   local size=$1;shift
   local str=$*
   dsize=$((size/2))
      #echo -e "\n"debug: ipsummary input:$str.  wc \-c:`echo -n "$*"|wc -c`. \-gt Size:$size.  dsize:$dsize >/dev/tty
      if test ${#str} -gt $size;then
       echo -n $str 2>/dev/null|head -c $((dsize-1));
       echo -en $ellipsis_char;
       echo -n $str|tail -c $((dsize));
      else
      echo -n $str
     fi
    echo
}

strlen() {
  str="$*";
  n=${#str};
  ascii_str=`echo -n "$str"|strings -n1|tr -d "\n"`
  n2=${#ascii_str}
  if test $n -eq $n2; then
    echo -n $n;
  else
    echo -n $(( n2 + (n-n2)/2 ));
  fi;
}

main $*
