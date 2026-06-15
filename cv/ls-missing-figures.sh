#!/bin/bash -ue

if [ $# -gt 0 ]
then
  LOG=$1.log
else
  LOG=$(cat .projectname)
  for i in '' -poster-landscape -poster-portrait -presentation
  do
    if [ -s "$LOG$i.log" ]
    then
      LOG="$LOG$i.log"
      break
    fi
  done
fi

echo "Looking at log file $LOG for missing figures:"

for i in Warning Error
do
  echo "LaTeX $i: File not found"
  awk '
/LaTeX '$i': File/ {
  x=""
  while (index(x,"not found")==0) {
    getline l;x=x l
  }
  printf("%s%s\n",$0,x)
}' $LOG \
| awk -F'LaTeX '$i': File `' '{print $2}' \
| sed "s:'.*::g"
done
