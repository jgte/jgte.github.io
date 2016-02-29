#!/bin/bash

SOURCE="$HOME/cloud/Dropbox/Documents/active/pessoal/curriculum vitae/latex/cv_jgte.tex"

pandoc "$SOURCE" -f latex -t html -s -o cv.html
