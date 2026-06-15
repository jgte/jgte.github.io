#!/bin/bash -u

DIR_SINK=$(cd $(dirname $0); pwd)

function echo_debug()
{
  $DEBUG || return 0
  case $# in
    2) printf "%12s = %s\n" $1 "$2";;
    *) echo -e "$@"
  esac
}

#handle input arguments
ECHO=
DEBUG=false
REVERSE=false
LIST=false
for i in $@
do
  case $i in
    echo)    ECHO=echo ;;
    debug)   DEBUG=true;;
    reverse) REVERSE=true ;;
    list)    LIST=true;;
    *) echo "WARNING: cannot handle input '$i', ignoring..." ;;
  esac
done

for file in "$DIR_SINK/.sourcedir" "$DIR_SINK/.projectname"
do
  if [ ! -e "$file" ]
  then
    echo "ERROR: cannot find file $file. Cannot continue."
    exit 3
  fi
done

#getting source dir
DIR_SOURCE=`cat .sourcedir`
[ -d "$DIR_SOURCE" ] || DIR_SOURCE=$HOME/$DIR_SOURCE
echo_debug "DIR_SOURCE" "$DIR_SOURCE"
if [ ! -d "$DIR_SOURCE" ]; then echo "Cannot find sourcedir, cannot continue"; exit 3; fi

echo "SOURCE=$DIR_SOURCE; SINK=$DIR_SINK"

#getting project name
MAINTEX=`cat .projectname`
echo_debug "MAINTEX=$MAINTEX"
[ -e $DIR_SOURCE/.projectname ] \
  && TEMPLATE_NAME=$(cat $DIR_SOURCE/.projectname) \
  || TEMPLATE_NAME=TEMPLATE
echo_debug "TEMPLATE_NAME" "$TEMPLATE_NAME"

DIFF=${DIFF:-$(
  which diffmerge 2> /dev/null || \
  which meld      2> /dev/null || \
  which /Applications/Meld.app/Contents/MacOS/Meld 2> /dev/null || \
  which diffuse   2> /dev/null || \
  which wdiff     2> /dev/null || \
  which diff      2> /dev/null || \
)}
echo_debug "DIFF" "$DIFF"
if [ -z "$DIFF" ]; then echo "ERROR: no diff utility found. Cannot continue."; exit 3; fi

FILE_LIST=$(
for i in *.tex $DIR_SOURCE/*.tex *.sh $DIR_SOURCE/*.sh Makefile
do
  [[ "${i/TEMPLATE}" == "$i" ]] || continue
  [[ "${i/$MAINTEX}" == "$i" ]] || continue
  [ -e $DIR_SINK/sync.ignore ] && grep -q $(basename $i) $DIR_SINK/sync.ignore && continue
  basename $i
done | sort -u
)
echo_debug "FILE_LIST" "$FILE_LIST"

FILES_MISSING_AT_SOURCE=()
for i in $FILE_LIST
do
  echo_debug "============================\n$i\n============================"
  HERE="$DIR_SINK/$i"
  THERE="$DIR_SOURCE/$i"
  if $REVERSE
  then
    TMP=$HERE
    HERE=$THERE
    THERE=$TMP
  fi
  echo_debug "HERE" "$HERE"
  echo_debug "THERE" "$THERE"
  if [ -e "$HERE" ] && [ -e "$THERE" ]
  then
    FILES="$HERE $THERE"
    echo_debug "FILES" "$FILES"
    diff -qwbB -I '!TEX root' -I 'MAINTEXFILE:=' $FILES > /dev/null \
      && echo -e "NOTICE: file identical: $i" \
      || (
        echo -e "NOTICE: file differ   : $i"
        $LIST && diff $FILES | head
        $LIST || $ECHO $DIFF $FILES
      )
  elif [   -e "$HERE" ] && [ ! -e "$THERE" ] && [[ "$i" == "${i/0000}" ]]
  then
    FILES_MISSING_AT_SOURCE+=("cp -av $HERE $THERE")
  elif [ ! -e "$HERE" ] && [   -e "$THERE" ] && [[ "$i" == "${i/0000}" ]]
  then
    $ECHO cp -av $THERE $HERE
  elif [[ "$i" == "${i/0000}" ]]
  then
    echo "HERE=$HERE $([ -e "$HERE" ] && echo exists || echo missing)"
    echo "THERE=$HERE $([ -e "$THERE" ] && echo exists || echo missing)"
    echo "ERROR: this is a supposedly unreachable code location. Debug needed!"
    exit 3
  fi
done

#this handle the source templates and their corresponding sink de-templated files
for i in "$DIR_SINK/$MAINTEX"*.tex
do
  echo_debug "============================\n$i\n============================"
  HERE="$i"
  THERE="${i/$DIR_SINK\/$MAINTEX/$DIR_SOURCE/$TEMPLATE_NAME}"
  if $REVERSE
  then
    TMP=$HERE
    HERE=$THERE
    THERE=$TMP
  fi
  echo_debug "HERE" "$HERE"
  echo_debug "THERE" "$THERE"
  if [ ! -e "$THERE" ]
  then
    echo "WARNING: cannot find file $THERE"
  else
    FILES="$HERE $THERE"
    diff -qwbB -I '!TEX root' -I 'MAINTEXFILE:=' $FILES > /dev/null \
      && echo -e "NOTICE: file identical: $(basename $HERE)" \
      || (
        echo -e "NOTICE: file differ   : $(basename $HERE)"
        $LIST && diff $FILES | head
        $LIST || $ECHO $DIFF $FILES
      )
  fi
done

if [ ${#FILES_MISSING_AT_SOURCE[@]} -gt 0 ]
then
  echo "WARNING: files missing at source, copy it manually if needed:"
  printf "%s\n" "${FILES_MISSING_AT_SOURCE[@]}"
fi


$ECHO ln -sfv $DIR_SOURCE/library.bib .
$ECHO chmod -v u+x *.sh

#updating deploy records
(
  cat $DIR_SOURCE/deployed.list
  echo $DIR_SINK
) | sort -u > /tmp/deployed.list \
&& mv -f /tmp/deployed.list $DIR_SOURCE/deployed.list
