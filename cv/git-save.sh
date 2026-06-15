#!/bin/bash

git st || exit $?
echo "Continue and add everything and commit with message '$@'? [Y/n]"
read ANSWER
[ "$ANSWER" == "n" ] && exit

git add -u *  || exit $?
git ci -m "$1"  || exit $?


