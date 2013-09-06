#!/bin/sh

function printhelp {
  echo "srt - compare lines from two sources and output from one or both sources depending"
  echo "on options supplied."
  echo "Licensed under the GPL v2, Copyright (C) 2010 Brandon Captain"
  echo ""
  echo "return value is 1 if any inputs do not match/dismatch as specified."
  echo ""
  echo " Usage Example: cat [src1] | list [src2]"
  echo " Usage Example: list [src2] [src1]"
  echo ""
  echo "if two files are passed as arguments, stdin is ignored."
  echo ""
  echo "Options:"
  echo "   -1 --src1       output lines from src1 only. (default)"
  echo "   -2 --src2       output lines from src2 only."
  echo "   -b --srcboth    output lines from both sources."
  echo ""
  echo "   -u --unique   output unique lines (default)"
  echo "   -d --duplicate  output duplicate lines"
  echo ""
  echo "   -i --ignore     ignore commented lines (# on first char)"
  echo ""
  echo "   -h --help   print help"
  echo "   -v --version   print version"
}

function printversion {
  echo "list"
  echo "version 0.1, Copyright (C) 2010 Brandon Captain. released under the terms and conditions of the GPL v2.0"
}

if [ -z "$1" ]; then
  printversion;
  printhelp;
  exit 1
fi

RETURN=0;
TMODE="u";
TSRC="1";
atcommand=0;
unset src1;
unset src2;
IGNORE="0";

for opt in $@; do
  if [[ "${opt:0:1}" != "-" ]] ; then
    COMMAND[${#COMMAND[*]}]="$opt"
    continue
  fi
  let START=$START+${#opt}

  if [ "$opt" = "-h" ] || [ "$opt" = "--help" ]; then
    printversion;
    printhelp;
    exit 1
  elif [ "$opt" = "-v" ] || [ "$opt" = "--version" ]; then
    printversion;
    exit 1
  fi

  if [ "$opt" = "-1" ] || [ "$opt" = "--src1" ]; then
    TSRC="1"
    continue;
  fi

  if [ "$opt" = "-i" ] || [ "$opt" = "--ignore" ]; then
    IGNORE="1"
    continue;
  fi

  if [ "$opt" = "-2" ] || [ "$opt" = "--src2" ]; then
    TSRC="2"
    continue;
  fi

  if [ "$opt" = "-b" ] || [ "$opt" = "--srcboth" ]; then
    TSRC="b"
    continue;
  fi

  if [ "$opt" = "-u" ] || [ "$opt" = "--unique" ]; then
    TMODE="u";
    continue;
  fi

  if [ "$opt" = "-d" ] || [ "$opt" = "--duplicate" ]; then
    TMODE="d";
    continue;
  fi

  echo "$opt is not a valid option"
  exit 1
done

FSR='\n'

function dochecks {
  dobreak="no"
  if [[ "$TMODE" == "d" ]] ; then
    if [[ "$line1" == "$line2" ]]; then
      echo "$line1"
      dobreak="yes"
    else
      RETURN=1;
    fi
  elif [[ "$TMODE" == "u" ]]; then
    if [[ "$line1" == "$line2" ]]; then
      RETURN=1;
      doprint="no"
      dobreak="yes"
    else
      doprint="yes"
    fi
  fi
}

function go_go_gadget_program {
    for line1 in ${src2[@]}; do
      if [[ "$IGNORE" == "1" ]] && [[ "${line1:0:1}" == "#" ]] ; then
        continue;
      fi
      doprint="yes"
        for line2 in ${src1[@]}; do
        if [[ "$IGNORE" == "1" ]] && [[ "${line2:0:1}" == "#" ]] ; then
          continue;
        fi
          dochecks
          if [[ "$dobreak" == "yes" ]] ; then
            break;
          fi
        done
      if [[ "$TMODE" == "u" ]] && [[ "$doprint" == "yes" ]] ; then
        echo "$line1"
      fi
    done
}

if [[ "${#COMMAND[@]}" -gt 2 ]] ; then
  echo "extra options not recognized: ${COMMAND[@]:2}"
  exit 1;
fi
if [[ ! -e "${COMMAND[0]}" ]] ; then
  echo "file not found: ${COMMAND[0]}"
  exit 1;
fi

if [[ "${#COMMAND[@]}" -eq 2 ]] && [[ ! -e "${COMMAND[1]}" ]] ; then
  echo "file not found: ${COMMAND[1]}"
  exit 1;
fi

if [[ "$TSRC" == "b" ]] || [[ "$TSRC" == "1" ]] ; then
  while read line; do
    src1[${#src1[@]}]=$line
  done < ${COMMAND[0]}

  if [[ "${#COMMAND[@]}" == 1  ]] ; then
    while read line; do
      src2[${#src2[@]}]=$line
    done
  elif [[ "${#COMMAND[@]}" == 2  ]] ; then
    while read line; do
      src2[${#src2[@]}]=$line
    done < ${COMMAND[1]}
  else
    printversion
    printhelp
  fi
  go_go_gadget_program
fi

if [[ "$TSRC" == "b" ]] || [[ "$TSRC" == "2" ]] ; then
  while read line; do
    src2[${#src2[@]}]=$line
  done < ${COMMAND[0]}

  if [[ "${#COMMAND[@]}" == 1  ]] ; then
    while read line; do
      src1[${#src1[@]}]=$line
    done
  elif [[ "${#COMMAND[@]}" == 2  ]] ; then
    while read line; do
      src1[${#src1[@]}]=$line
    done < ${COMMAND[1]}
  else
    printversion
    printhelp
  fi
  go_go_gadget_program
fi

exit $RETURN
