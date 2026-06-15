#!/bin/bash -ue

set -o errexit

if [ $# -lt 1 ]
then
  echo "$0 <project name, i.e. name of the main tex file>
Need one input argument. The installation takes place in the current directory."
  exit 3
fi

if [[ ! "${1//\//}" == "$1" ]]
then
  echo "$0:ERROR: found slash character(s) in argument 1, which should refer to the project name, not to a directory (the latex templated is deployed to the current dir)."
  exit 3
fi

#easier names
MAINTEX="$1"
DIR_NOW=$(cd "$PWD"; pwd)
DIR_INSTALL=$(cd $(dirname $0); pwd)

#get rid of the extension in case it was given
MAINTEX="${MAINTEX%.tex}"

#sublime project files
FROM="$DIR_INSTALL/latex-template.sublime-project"
TO="$DIR_NOW/$MAINTEX.sublime-project"
# echo Deploying file $FROM to $TO
cp -v "$FROM" "$TO" || echo "Skip sublime project file"

#template tex files
for FROM in `find $DIR_INSTALL -maxdepth 1 -name TEMPLATE\*.tex`
do
  TO=$(echo $FROM | sed 's/TEMPLATE/'$MAINTEX'/g')
  echo "Deploying file $FROM to $TO"
  cp -v "$FROM" "$TO"
done

#remaining tex files and Makefile
for i in `find $DIR_INSTALL -maxdepth 1 -name \*.tex -not -name TEMPLATE\*.tex` "$DIR_INSTALL/Makefile"
do
  echo "Deploying file $i to $DIR_NOW/$(basename $i)"
  sed 's/TEMPLATE/'$MAINTEX'/g' "$i" > "$DIR_NOW/$(basename $i)"
done

#remove renamed template files
rm -v "$DIR_INSTALL/$MAINTEX"* || echo "Skip removing renamed template files"

#static files
for i in $(ls $DIR_INSTALL/*.sh)
do
  # echo Deploying file $i to $DIR_NOW/$(basename $i)
  cp -v "$i" "$DIR_NOW"
done

#wildcarded files
for i in $(ls $DIR_INSTALL/*.cls $DIR_INSTALL/*.sty $DIR_INSTALL/*.bib $DIR_INSTALL/*.bst $DIR_INSTALL/*.def)
do
  # echo Deploying file $i to $DIR_NOW/$(basename $i)
  cp -v "$i" "$DIR_NOW"
done

#directories
for i in logos figures
do
  mkdir -vp "$DIR_NOW/$i"
  cp -v "$DIR_INSTALL/$i/"* "$DIR_NOW/$i/"
done

#saving source directory so that the sync.sh script works
HOME_CLEAN=${HOME//\//\\\/}
SOURCEDIR="${DIR_INSTALL/$HOME_CLEAN\/}"
echo Saving "$SOURCEDIR" to "$DIR_NOW/.sourcedir"
echo "$SOURCEDIR" > "$DIR_NOW/.sourcedir"
#saving project name so that the sync.sh script works
echo Saving "$MAINTEX" to "$DIR_NOW/.projectname"
echo "$MAINTEX" > "$DIR_NOW/.projectname"

#updating deploy records
echo $DIR_NOW >> $DIR_INSTALL/deployed.list
cat $DIR_INSTALL/deployed.list | sort -u > $DIR_INSTALL/deployed.list
