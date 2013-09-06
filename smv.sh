#!/bin/bash
#released under the GPL v2

if [ $# -lt 1 ]; then
  /bin/echo "Usage: smv sed_expression filename"
  exit 1
fi

if [ ! -e "$2" ]; then
        echo "file [""$2""] doesnt exist.";
        exit;
fi
SEDED=$(echo $2 | sed "$1");
if [ -e "$SEDED" ]; then
        echo "file [""$2""] already exists.";
        exit;
fi
cp "$2" "$SEDED"
if [ ! -e "$SEDED" ]; then
        echo "failed to copy.";
        exit;
fi
rm "$2"
if [ -e "$2" ]; then
        echo "failed to delete.";
        exit;
fi
