#!/bin/bash -u

DIR_INSTALL=$(cd $(dirname $0); pwd)

for file in "$DIR_INSTALL/.sourcedir" "$DIR_INSTALL/.projectname"
do
  if [ ! -e "$file" ]
  then
    echo "ERROR: cannot find file $file. Cannot continue."
    exit 3
  fi
done

DIR_SOURCE=$HOME/`cat .sourcedir`
MAINTEX=`cat .projectname`

dir="$DIR_SOURCE"
if [ ! -e "$dir" ]
then
  echo "ERROR: cannot find latex template dir $dir. Cannot continue."
  exit 3
fi

DIFF=
for i in diff diffuse meld /Applications/Meld.app/Contents/MacOS/Meld
do
  which $i > /dev/null && DIFF=$i
done

if [ -z "$DIFF" ]
then
  echo "ERROR: diff, diffuse or meld not installed. Cannot continue."
  exit 3
fi

for i in acronyms.tex symbols.tex header.tex utils.tex flags.tex *.sh Makefile
do
  [ -e "$DIR_INSTALL/$i" ] && [ -e "$DIR_SOURCE/$i" ] && $DIFF "$DIR_INSTALL/$i" "$DIR_SOURCE/$i"
done
$DIFF "$DIR_INSTALL/$MAINTEX.tex" "$DIR_SOURCE/TEMPLATE.tex"

ln -sfv $DIR_SOURCE/library.bib .
