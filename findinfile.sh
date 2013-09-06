#!/bin/bash

[ ${#} -lt 2 ] && { printf "${0} <string> <file(s)>\n";exit 1; }

str="${1}"; shift; files=( "${@}" ); h=0

for ((i=0; i < ${#files[@]}; i++)); do

   file="${files[${i}]}"; j=0; k=1; m=

   [ ${h} -lt ${#file} ] && h=${#file} || \
   [ ${h} -gt ${#file} ] && for ((l=0;l < ${h} - ${#file}; l++)); do m+=" "; done

   path_to_file="${file}${m}\r"; printf "${path_to_file}"

   [ -r "${file}" ] || \
   { printf "\e[1m${file}\e[0m is \e[31;1mnot readable\e[0m\n" && continue; } && \
   [ -d "${file}" ] || \
   while read fstr; do ((j++))

      [[ "${fstr}" =~ "${str}" ]] && \
      { [ ${k} -eq 1 ] && printf "\e[1m${file}\e[0m\n" && ((k=0)) || \
      printf "\t${j}: ${fstr/${str}/\e[32;1m${str}\e[0m}\n"; }

   done < "${file}"

done

printf "\n"
