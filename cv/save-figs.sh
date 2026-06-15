#!/bin/bash -ue

ECHO=
for i in $@
do
  case $i in
    echo)      ECHO=echo       ;;
  esac
done


#get some basic parameters
DIR=$(cd $(dirname $BASH_SOURCE);pwd)
PN=$(cat $DIR/.projectname || echo error)

#sanity
if [ "$PN" == "error" ]
then
  echo "ERROR: cannot determine project name, expecting to get it from '$DIR/.projectname'."
  exit 3
fi

FLS=
for i in '' -presentation -poster
do
  if [ -e "$DIR/$PN$i.fls" ]
  then
    FLS="$DIR/$PN$i.fls"
    break
  fi
done
if [ -z "$FLS" ]
then
  echo "ERROR: cannot find any fls file '$DIR/$PN*.fls'"
  exit 3
fi

#get file list
FILE_LIST=$(
  awk '/INPUT.*(png|pdf|ps)/ {print $2}' "$FLS" \
    | grep -v texlive \
    | grep -v /dev/null \
    | sed 's:^\./::g' \
    | sort -u
)

$ECHO rsync -aH --update --times --itemize-changes $FILE_LIST $DIR/figures
