#!/bin/bash -ue

function machine_is
{
  OS=`uname -v`
  [[ ! "${OS//$1/}" == "$OS" ]] && return 0 || return 1
}

if [ $# -lt 1 ]
then
  echo "$0 <new project name, i.e. name of the main tex file>
Need one input argument."
  exit 3
fi

if [[ ! "${1//\//}" == "$1" ]]
then
  echo "$0:ERROR: found a slash character in argument 1, which should refer to the project name, not to a directory."
  exit 3
fi

#go there
DIRNOW="$(cd $(dirname $0); pwd)"
OLDPWD="$PWD"
cd "$DIRNOW"

#easier names
NEWPROJECTNAME="$1"
OLDPROJECTNAME=$(cat ".projectname")

if [[ ! "${NEWPROJECTNAME#$OLDPROJECTNAME}" == "$NEWPROJECTNAME" ]]
then
  echo "ERROR: new project name cannot start with old project name"
  exit 3
fi

if [ -z "$OLDPROJECTNAME" ]
then  
  echo "ERROR: cannot find file .projectname or it is empty."
  exit 3
fi

#get rid of the extension in case it was given
NEWPROJECTNAME="${NEWPROJECTNAME%.tex}"

if [ "$OLDPROJECTNAME" == "$NEWPROJECTNAME" ]
then
  echo "ERROR: new and old project names are the same."
  exit 3
fi

echo "Renaming project '$OLDPROJECTNAME' to '$NEWPROJECTNAME':"
for i in \
$(find . -name \*.tex) \
$(find . -name \*.sublime-\*) \
Makefile
do
  echo Renaming contents of file $i
  machine_is Darwin && sed -i '.tmp' 's/'$OLDPROJECTNAME'/'$NEWPROJECTNAME'/g' "$i"
  machine_is Ubuntu && sed -i        's/'$OLDPROJECTNAME'/'$NEWPROJECTNAME'/g' "$i"
  [[ ! "${i/$OLDPROJECTNAME/}" == "$i" ]] && mv -v "$i" "${i/$OLDPROJECTNAME/$NEWPROJECTNAME}"
done


echo "Updating project name:"
#updating project name
echo $NEWPROJECTNAME > ".projectname"
cat .projectname

echo "Cleaning up old/tmp project files:"
#clean up
rm -fv "$OLDPROJECTNAME"* *.tmp


cd "$OLDPWD"
