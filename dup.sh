#!/bin/sh

#todo: files with tabs in them
function printhelp {
  echo "Usage: dup [options] [dir1] [dir2] [dir3] ..."
  echo ""
  echo " search directory [dir2], [dir3], etc for files that are ether duplicates or"
  echo " different from those in [dir1]."
  echo ""
  echo " at any time the same directory is being scanned for matched, different rules apply"
  echo " regardless of options passed. this is called single-directory mode:"
  echo " * when a duplicate is found, it's match will not be scanned for duplicates."
  echo " * -a is automatically and temporarily implied."
  echo ""
  echo " WARNING: this script treats all links like normak files/directories."
  echo " NOTE: this script so far doesn't handle files with tabs in their names."
  echo ""
  echo "Options:"
  echo "        -u  --unique        report unique files."
  echo "        -d  --duplicate     report dulpicate files. (default)"
  echo ""
  echo "        -q  --quick         quick mode. compares only the first kilobyte of each file."
  echo "                            WARNING: this mode is inacurate. it may report non-unique"
  echo "                            files in unique mode, and may not report all duplicate files."
  echo "        -e  --escape        escape spaces, double-quotes, and backslashes in output."
  echo "        -r  --recurse       recurse child directories. BE CAREFUL."
  echo "        -0  --zero          include zero byte files in matches (default is to not)"
  echo ""
  echo "        -v  --verbose"
  echo "        -vv --very-verbose"
  echo "        -h  --help"
  echo "            --version"
  echo ""
  echo "Options for Duplicate mode: (-d)"
  echo "        -a  --all           report every match for each file (by deafult, only the"
  echo "                            first match is reported). specify -v for berrer output"
  echo "        -m  --matches       report the matches instead of the files in [dir1]"
  echo "        -R  --redundant     by deafault, whenever scanning for matches inside the same"
  echo "                            directory as the current file being matched, matches are"
  echo "                            marked to not be scanned later. this option disables this."
}

function printversion {
  echo "dup - search for and manage duplicate/unique files"
  echo "version 0.2, Copyright (C) 2010 Brandon Captain. released under the terms and conditions of the GPL v2.0"
}
function print {
  thefile="$1";

  if [[ "$ESCAPE" == "1" ]] ; then
    # escape characters in file name
    if [[ "$ESCAPE" == "1" ]] ; then
      for (( l=0; $l<${#thefile}; l++ )) ; do
     if [[ "${thefile:$l:1}" == " " ]] || [[ "${thefile:$l:1}" == "\\" ]] || [[ "${thefile:$l:1}" == '\"' ]] || [[ "${thefile:$l:1}" == "'" ]]; then
       str_tail=${thefile:$l+1}
       thefile="${thefile:0:$l}""\\""${thefile:$l:1}""$str_tail"
       let l=$l+1
     fi
      done
    fi
  fi

echo "$thefile"
}

#function escape {
#  toesc="$1";
#
#  if [[ "$ESCAPE" == "1" ]] ; then
#    # escape characters in file name
#    if [[ "$ESCAPE" == "1" ]] ; then
#      for (( l=0; $l<${#toesc}; l++ )) ; do
#     if [[ "${toesc:$l:1}" == " " ]] || [[ "${toesc:$l:1}" == "\\" ]] || [[ "${toesc:$l:1}" == "\"" ]] || [[ "${toesc:$l:1}" == "'" ]]; then
#       str_tail=${toesc:$l+1}
#       toesc="${toesc:0:$l}""\\""${toesc:$l:1}""$str_tail"
#       let l=$l+1
#     fi
#      done
#    fi
#  fi
#
# echo "$toesc"
#}

ASK=0
UNIQUE=0
PARALLEL=0
START=0
atcommand=0
RECURSE=0
ZERO=0
VERBOSE=0
PRETEND=0
ESCAPE=0
ALL=0
MATCHES=0
QUICK=0
REDUNDANT=0

args=("$@")
for (( i=0; $i<$#; i++ ))
do
  opt=${args[$i]}

  if [[ "${opt:0:1}" != "-" ]] ; then
    COMMAND[${#COMMAND[*]}]="$opt"
    continue;
  fi
  let START=$START+${#opt}

  if [ "$opt" = "-h" ] || [ "$opt" = "--help" ]; then
    printversion
    printhelp
    exit 0
  elif [ "$opt" = "--version" ]; then
    printversion
    exit 0
  fi

  if [ "$opt" = "-u" ] || [ "$opt" = "--unique" ]; then
    UNIQUE=1
    continue
  fi

  if [ "$opt" = "-d" ] || [ "$opt" = "--duplicate" ]; then
    UNIQUE=0
    continue
  fi

  if [ "$opt" = "-R" ] || [ "$opt" = "--redundant" ]; then
    REDUNDANT=1
    continue
  fi

  if [ "$opt" = "-q" ] || [ "$opt" = "--quick" ]; then
    QUICK=1
    continue
  fi

  if [ "$opt" = "-r" ] || [ "$opt" = "--recurse" ]; then
    RECURSE=1
    continue
  fi

  if [ "$opt" = "-m" ] || [ "$opt" = "--matches" ]; then
    MATCHES=1
    continue
  fi

  if [ "$opt" = "-a" ] || [ "$opt" = "--all" ]; then
    ALL=1
    continue
  fi

  if [ "$opt" = "-e" ] || [ "$opt" = "--escape" ]; then
    ESCAPE=1
    continue
  fi

  if [ "$opt" = "-0" ] || [ "$opt" = "--zero" ]; then
    ZERO=1
    continue
  fi

  if [ "$opt" = "-v" ] || [ "$opt" = "--verbose" ]; then
    VERBOSE=1
    continue
  fi

  if [ "$opt" = "-vv" ] || [ "$opt" = "-very-verbose" ]; then
    VERBOSE=2
    continue
  fi

  echo "$opt is not a valid option"
  echo "exiting prematurely."
  exit 1
done

if [[ "$UNIQUE" == "1" ]] ; then
  if [[ "$MATCHES" == "1" ]] ; then
    echo "-m or --matches cannot be used with the -u option"
    echo "exiting prematurely."
    exit 1
  fi
  if [[ "$ALL" == "1" ]] ; then
    echo "-a or --all cannot be used with the -u option"
    echo "exiting prematurely."
    exit 1
  fi
  if [[ "$REUNDANT" == "1" ]] ; then
    echo "-R or --redundant cannot be used with the -u option"
    echo "exiting prematurely."
    exit 1
  fi
fi

if (( ${#COMMAND[@]} < 1 )); then
  printversion
  printhelp
  exit 0
fi

if (( ${#COMMAND[@]} == 1 )); then
  COMMAND[1]="${COMMAND[0]}"
fi

## determine if the user specified the same patch twice
#if [[ "$MULTI_DIR_MODE" == "1" ]]
#  for (( i=0; $i< ${#COMMAND[@]}; i++ )); do
#    for (( j=$i; $j< ${#COMMAND[@]}; j++ )); do
#      if [[ ${COMMAND[$i]} ${COMMAND[$j]} ]] ; then
#        SINGLE_DIR_MODE=true
#        break
#      fi
#    done
#  done
#fi

if [[ "$RECURSE" == "1" ]] ; then
  DEPTH=""
else
  DEPTH=("-mindepth" "1" "-maxdepth" "1")
fi

TMPFILE="/tmp/.dup_filelist"
for (( diridx=0; $diridx<${#COMMAND[@]}; diridx++ )) ; do
  find "${COMMAND[$diridx]}" ${DEPTH[@]} -type f > "$TMPFILE"
  elements=$(egrep $ "$TMPFILE" -c)

  for (( j=0; $j<"$elements"; j++ )); do
    let k=j+1
    eval files$diridx[$j]=\"$(cat "$TMPFILE" | sed -n "$k"p | sed 's/\"/\\\"/g' )\"
  done
done
rm "$TMPFILE"

#IFS=$'\n'
#k=0
#for (( diridx=0; $diridx<${#COMMAND[@]}; diridx++ )) ; do
# # echo eval files$diridx[$k]=$(find "${COMMAND[$diridx]}" ${DEPTH[@]} -type f | sed 's/\"/\\\"/g' | sed 's/(/\\(/g' | sed 's/)/\\)/g' | sed "s/\'/\\\'/g")
#  echo eval files$diridx[$k]=$(find "${COMMAND[$diridx]}" ${DEPTH[@]} -type f | escape)
#  let k=$k+1;
#done
#unset IFS
#
#echo ${files0[@]}
#echo ${files1[@]}
#exit

int=0
for (( i=0; i<${#files0[@]}; i++ )); do
  file1="${files0[$i]}"
  FOUNDDUPS="false"

  if [[ "$ZERO" == "0" ]] ; then
    size1=$(head -c 1 "$file1")
    if [[ "$size1" == "" ]] ; then
      if [[ "$VERBOSE" == "2" ]] ; then
        echo "skipping `print "$file2"` because it's zero length"
      fi
      continue
    fi
  fi

  found="false"
  BREAKTHROUGH="false"

  # cycle dir2,3,4...
  for (( j=1; $j<$diridx; j++ )) ; do
    eval tot=\${#files$j[@]}

    for (( k=0; k<$tot; k++ )); do
      eval file2=\${files$j[$k]}

      if [[ "$file1" == "$file2" ]] ; then
        if [[ "$VERBOSE" == "2" ]] ; then
          echo "paths are the same, ignoring: `print "$file1"` and `print "$file2"`"
        fi
        continue
      fi

      if [[ "$ZERO" == "0" ]] ; then
        size2=`head -c 1 "$file2"`
        if [[ "$size2" == "" ]] ; then
          if [[ "$VERBOSE" == "2" ]] ; then
            echo "skipping `print "$file2"` because it's zero length"
        fi
          continue
        fi
      fi

      if [[ "$VERBOSE" == "2" ]] ; then
        echo "testing: `print "$file1"` : `print $file2`"
      fi

      # first check if they're the same size, as this is the quickest way to determine 99% of unique files
      f1du=`du -b "$file1" | sed 's/^\([0-9]*\).*/\1/g'`
      f2du=`du -b "$file2" | sed 's/^\([0-9]*\).*/\1/g'`

      if (( $f1du == $f2du )) ; then
        # then diff them in binary mode
        diff -q "$file1" "$file2" 1>>/dev/null 2>>/dev/null
        num=$?
      else
        num=1;
      fi

      # DUPLICATES
      if [[ "$UNIQUE" == "0" ]] && (( $num == 0 )) ; then
        found="true"

        if [[ "$VERBOSE" -gt 0 ]]; then
          echo "`print "$file1"` == `print "$file2"`"
        else
          if [[ "$MATCHES" == "1" ]] ; then
            echo "`print "$file2"`"
          fi
        fi

   if [[ "${COMMAND[$j]}" == "${COMMAND[0]}" ]] ; then
     SINGLE_DIR_MODE=1
   else
     SINGLE_DIR_MODE=0
   fi

        # do single-dir mode stuff
   if [[ "$SINGLE_DIR_MODE" == "1" ]] && [[ "$REDUNDANT" == "0" ]] ; then
     # remove match file from list to eliminate redundancy
     for (( l=$i; $l<"${#files0[@]}"; l++ )) ; do
       if [[ "${files0[$l]}" == "$file2" ]] ; then
         # shuffle list down
         for (( ; $l<"${#files0[@]-1}"; l++ )) ; do
           files0[$l]="${files0[$l+1]}"
              done
              let newNum=${#files0[@]}-1
         unset files0[$newNum]
          if [[ "$VERBOSE" -gt 1 ]] ; then
        echo "$file2: removing from further scanning to eliminate redundancy."
      fi
       fi
     done
   fi

        # default is to find only the first match and output unless specified by -a
   if [[ "$ALL" == "0" ]] && [[ "$SINGLE_DIR_MODE" == "0" ]] ; then
         BREAKTHROUGH="true"
            break
   fi

      # UNIQUES
      elif [[ "$UNIQUE" == "1" ]] && (( $num == 0 )) ; then
        found="true"
       
     BREAKTHROUGH="true"
        break;
      fi
    done

    if [[ "$BREAKTHROUGH" == "true" ]] ; then
      break;
    fi
  done

  if [[ "$UNIQUE" == "0" ]] && [[ "$MATCHES" == "0" ]] && [[ "$VERBOSE" == "0"  ]] && [[ "$found" == "true" ]] ; then
    echo "`print "$file1"`"
  elif [[ "$UNIQUE" == "1" ]] && [[ "$found" == "false" ]] ; then
    if [[ "$VERBOSE" -gt "0" ]] && [[ "$UNIQUE" != "1" ]] ; then
      echo `print "$file1"` == `print "$file2"`
    else
      print "$file1"
    fi
  fi

done


exit 0
