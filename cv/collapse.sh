#!/bin/bash -ue

if [ $# -lt 1 ]
then
  echo "ERROR: need one input argument: output directory name (cannot exist)"
  exit 3
fi

ECHO=
NOSUBDIRS=true
ZIP=true
MAKE=true
RESOLVE_INPUTS=true
for i in ${@:2}
do
  case $i in
    echo)      ECHO=echo       ;;
    subdirs)   NOSUBDIRS=false ;;
    nozip)     ZIP=false       ;;
    nomake)    MAKE=false      ;;
    noresolveinputs) RESOLVE_INPUTS=false ;;
  esac
done


#get some basic parameters
DIR=$(cd $(dirname $BASH_SOURCE);pwd)
PN=$(cat $DIR/.projectname || echo error)
FLS=$DIR/$PN.fls

#sanity
if [ "$PN" == "error" ]
then
  echo "ERROR: cannot determine project name, expecting to get it from '$DIR/.projectname'."
  exit 3
fi
if [ ! -e "$FLS" ]
then
  echo "ERROR: cannot find fls file '$FLS'"
  exit 3
fi

#get file list
FILE_LIST=$(
  awk '/INPUT/ {print $2}' "$FLS" \
    | grep -v texlive \
    | grep -v /dev/null \
    | sed 's:^\./::g' \
    | sort -u;
  ls *.bib *.bst
)

#make sink dir
if ! mkdir -p "$1"
then
  echo "ERROR: cannot create directory '$1'"
  exit 3
fi

function filenamecollapse()
{
  echo "$1" \
    | sed 's:\.\./::' \
    | sed 's:\./::' \
    | sed 's:/:_:g'  
}

FIGCOUNTERFILE=/tmp/$PN.$(basename $BASH_SOURCE).figcounter
[ -e $FIGCOUNTERFILE ] && echo 0 > $FIGCOUNTERFILE
function figrename()
{
  local FIGCOUNTER=$(cat $FIGCOUNTERFILE)
  FIGCOUNTER=$((FIGCOUNTER+1))
  local EXT=${1##*.}
  printf "f%02d.$EXT" $FIGCOUNTER
  echo $FIGCOUNTER > $FIGCOUNTERFILE
}

FIGURE_EXTENSION_LIST=(png pdf)
function isfig()
{
  local i
  for i in ${FIGURE_EXTENSION_LIST[@]} 
  do
    [[ "$i" == "${1##*.}" ]] && return 0
  done
  return 1
}

function filerename()
{
  isfig $1 \
    && figrename $1 \
    || filenamecollapse $1
}

#build filename renaming table
for i in $FILE_LIST
do
  echo "$i:$1/$(filerename "$i")"
done > $1/file_rename.table
[ -z "$ECHO" ] || cat $1/file_rename.table

#copy all files to sink dir
while IFS= read -r line; do
  SOURCE=$(echo $line | awk -F: '{print $1}')
    SINK=$(echo $line | awk -F: '{print $2}')
  $ECHO cp -anL $SOURCE $SINK
done < $1/file_rename.table

#collapse references to files in sub-dirs
IMPLICIT_FILE_LIST=()
for i in $FILE_LIST
do
  #ignore files in this dir
  [ "$i" == "$(basename $i)" ] && continue
  #assume this is an implicit file
  IMPLICIT_FILE=true
  #loop over all tex files
  for j in $(ls "$1"/*.tex )
  do
    #strip extension
    OLD="${i%.*}"
    #check if this file is explicitly mentioned in this tex document
    if grep -q "$OLD" "$j"
    then
      #retrieve new filename
      NEW="$(grep "$OLD" $1/file_rename.table | awk -F: ' {print $2}' )"
      #strip extension and dir
      NEW="$(basename ${NEW%.*})"
      #inform
      echo "--- Editing $j from '$OLD' to '$NEW':"
      #sed to tmp file
      sed 's:'${OLD}':'${NEW}':' "$j" > "/tmp/$(basename $j)"
      #wait for the buffers to flush
      sleep 0.5
      #show the diff between old and new
      diff "/tmp/$(basename $j)" "$j" || true
      #retrieve updated file
      $ECHO mv -f "/tmp/$(basename $j)" "$j"
      #set flag
      IMPLICIT_FILE=false
    fi
  done
  #collect files referenced implicitly into nice array
  $IMPLICIT_FILE && IMPLICIT_FILE_LIST+=($i)
done

#copy makefile to sink dir
cp $DIR/Makefile $1/

#check if all files are handled
if [ ${#IMPLICIT_FILE_LIST[@]} -gt 0 ]
then
  #these files are not explicitly mentionded, 
  #they are probably built with \commands
  #nothing to do except maintain their directory structure
  for i in ${IMPLICIT_FILE_LIST[@]}
  do
    case ${i:0:3} in
      \./?)  NEW=$1/${i:2}    ;; #relative path ./
      \.\./)
        echo "ERROR: cannot handle files with names such as '$i'. Consider linking one of its parent dirs to $DIR"
        exit 3
      ;;
      /??)   NEW=${i/$DIR/$1} ;; #absolute path (good luck!)
      *)     NEW=$1/$i        ;; #relative path with no parent dir
    esac
    #retrieve name of file previously copied to $1 assuming it could be resolved in the latex files
    SINK="$(grep "$i" $1/file_rename.table | awk -F: '{print $2}')"
    #skip if this file does not exist or it cannot be found in the records (it was already dealt with)
    ( [ ! -z "$SINK" ] && [ -e "$SINK" ] ) && $ECHO rm -f $SINK || continue
    #create this file's subdir
    $ECHO mkdir -p $(dirname $NEW)
    #copy it there
    $ECHO cp -anL "$i" "$NEW" || true
    #rename entry in records
    sed -i.tmp 's:'$SINK':'$NEW':' $1/file_rename.table 
    #inform
    echo "--- Could not resolve $(basename $i) : copied to $(dirname $NEW)"
  done
fi

#turn off showing plot filenames
sed -i.tmp 's:\\let\\showplotnames:% \\let\\showplotnames:' $1/$PN.tex

if $NOSUBDIRS && [ ! -z "$(find $1 -mindepth 2 -type f)" ]
then
  mv -v $(find $1 -mindepth 2 -type f) $1/
  rm -frv $(find $1 -mindepth 1 -type d)
fi

if $RESOLVE_INPUTS
then
  INPUTS=($(awk -F'[\{\}]' '/\\input\{/ {print $2}' $1/$PN.tex | sort -u))
  if [ ${#INPUTS[@]} -eq 0 ]
  then
    echo "NOTICE: no \input commands found, nothing to resolve."
  else
    for i in ${INPUTS[@]}
    do
      #build filename with tex extension
      j=${i%%.tex}.tex
      #contemplate nosubdirs
      $NOSUBDIRS && j=$(basename $j)
      #skip if this file is unavailable in $1
      [ ! -e $1/$j ] && continue
      #build tex \input command
      k="\input{$i}"
      #replace contents
      #NOTICE: need all \input'ed files to end with a new line
      sed -i.tmp -e "/${k//\//\\/}/r $1/$j" -e "/${k//\//\\/}/d" $1/$PN.tex
      #delete redundant file
      rm -f $1/$j
      #grep \input to be sure
      if grep -e "$k" $1/$PN.tex
      then
        echo "ERROR: failed to replace $k with contents of file $j"
      else
        #notify
        echo "Replaced calls to $k with contents of file $j"
      fi
    done
  fi
fi

#remove tmp files
rm -fv $1/*.tmp

if $ZIP
then
  rm -f $1.zip
  zip --no-dir-entries $1.zip $(find $1 -type f)
fi

if $MAKE
then
  make -C $1
  make -C $DIR
  which diff-pdf 2>/dev/null && diff-pdf --view $1/$PN.pdf $DIR/$PN.pdf
fi
