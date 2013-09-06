#!/bin/bash
#eg, echo \<div\>\<h1\>hello\</div\>|
#         html2text
#should output "hello"

main() {

exclude_tags='(!|script|style|meta|audio|[^a-zA-Z/])'
newline_tags='(tr|li|br|p)'
tab_tags='(td)'
heading_tags='/?(title|h[0-9])'
#rub="&nbsp;\|&gt;"
underline=`echo -e "\xc2\xaf"`
pre=0
nl=0
tab=`echo -ne "\t"`
indent=$tab$tab
header() { boole=${1-$boole}; $boole;};boole=false;
pt=false
if test ! -z $1;then
if test $1 = -t;then pt=true;shift;fi
if regexp ^-h\|^--h $1|| ! test -e "$*";then echo "Usage: html2text [-t] [file.html]";exit;fi
fi
echo -ne $indent
if test $# -eq 0; then cat; else cat "$*";fi  |
while read -d\< contents ; do
  IFS=">"
  p2=($contents);
  tag="${p2[0]}";
  tag=${tag%%[[:space:]]*}
  if $pt;then echo -n "{<$tag>}";fi
  if test -z $tag;then
    continue;fi
  if test ${#tag} -gt 15; then
    continue;fi
  if regexp "^$exclude_tags" $tag; then
    continue;fi
  if regexp -i "^$newline_tags$" "$tag"; then
     push '\n';nl=1; fi;
  if regexp -i "^$tab_tags$" "$tag"; then
     push '\t';fi;
  if regexp '/?pre' $tag;then pre=$((pre^1)) ;fi
  if regexp -i "^$heading_tags$" "$tag";
     then
         if test ${tag:0:1} = "/"; then :;#header true;
       else echo -ne "\n\n$indent";header true;fi;
  fi
  # if [[ $tag =~ div$ ]];  then
  #     if test ${tag:0:1} = "/" ;      then inc=`expr ${#indent} - 1`;      else inc=`expr  ${#indent} + 1`;      fi
  #     indent=`multichar $inc "$tab"`    ;
  # fi
#  if test ${tag:0:1} = "/" ;then continue;fi
#  -a $nl -eq 0 -a ! header;then continue;fi
  unset p2[0]
  inner="${p2[*]}";
  unset output;
  if $pt;then echo -n "#${#inner}-$nl";fi
  if regexp '([a-zA-Z0-9])' "$inner";then
      output=$(echo -n "$inner"  |
     sed -r 's/&.{2,5};/\`/g' |if test $pre -eq 0;then
         tr '\n' ' '; else cat;fi |
     sed -r 's/[[:cntrl:]]//g' )
      if test "$output";then
     echo -n "$output" 2>/dev/null;
     echo -n ' ';
      else
     pop true;
      fi
      if header;then
     uline=`multichar ${#output} $underline`
         echo -ne "\n$indent$uline\n$indent";header false
      fi;
  fi
  if test $nl -ne 0 -a ${#output} -gt 10;then
      while pop;do :;done;nl=0;
      echo -ne "$indent";
  fi

done
}


regexp() {
local v; if test ${1:0:1} = -;then v=$1;shift;fi
rexp=$1;shift
if test $# -eq 0;then cat ;else echo "$*";fi |
egrep $v -q -e "$rexp";
}

#
trim() {
if test $# -eq 0;then cat ;else echo "$*";fi|
tr -d ' '|tr -d "\n"|tr -d "\t"
}

multichar() {
    local a=$(seq -sx 10 `expr 10 + $1`)
    a=${a//x}
    echo "${a//??/$2}"
}


stack=();
push() {
    local n=${#stack[*]};
    if test $n -gt 3; then return;fi
    stack[$n]="$*";
}

pop()  {
    local n=${#stack[*]};n=$((n-1));
    if test $n -le 0; then return 1;fi
    if test -z $1;then echo -en "${stack[$n]}"; fi
    unset stack[$n];
}


main $*
echo
