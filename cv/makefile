MAINTEXFILE:=jgte_cv
PUBLTEXFILE:=jgte_publications
SUMMTEXFILE:=jgte_summary

GOOGLESCHOLARBIBURL:=https://scholar.googleusercontent.com/citations?view_op=export_citations&user=k2liFwQAAAAJ&citsig=AMstHGQAAAAAWTwP5LOWbyU-D_8kJPCaHzcsYYKO8zbm&hl=en
GOOGLESCHOLARBIBURL:=https://scholar.googleusercontent.com/citations?view_op=export_citations&user=k2liFwQAAAAJ&citsig=AMstHGQAAAAAWUVsJENP3Wq7ycYTfyozEl9CoKgl7lZJ&hl=en
GOOGLESCHOLARBIBURL:=https://scholar.googleusercontent.com/citations?view_op=export_citations&user=k2liFwQAAAAJ&citsig=AMstHGQAAAAAWUfKXezz05QTaki6HPT6ZrdR5kyo59-4&hl=en
GOOGLESCHOLARBIBURL:=https://scholar.googleusercontent.com/citations?view_op=export_citations&user=k2liFwQAAAAJ&citsig=AMstHGQAAAAAWYXhBeR7kgttcRsuBmyGCYNFCfKYC6pn&hl=en
GOOGLESCHOLARBIBURL:=https://scholar.googleusercontent.com/citations?view_op=export_citations&user=k2liFwQAAAAJ&citsig=AMstHGQAAAAAWcLnAw5jrZkvLAKzOEIL2cOAdcvf2gVQ&hl=en
GOOGLESCHOLARBIBFILE:=citations.bib
GOOGLESCHOLARBIBENCOD=CP1250
# CP1251
# CP1252
# CP1253
# CP1254
# CP1255
# CP1256
# CP1257
# CP1258
# GEORGIAN-ACADEMY
# GEORGIAN-PS
# KOI8-T
# CP154
# CP874
# CP1162

# determining computer
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
PDFLATEX:=pdflatex -halt-on-error -interaction nonstopmode
endif

ifeq ($(UNAME), Darwin)
PDFLATEX:=/Library/TeX/texbin/pdflatex -halt-on-error -interaction nonstopmode
endif

BIBTEX:=bibtex
PDFVIEW=$(shell which gnome-open || which open || which evince || which gpdf || which kpdf || which acroread || which xpdf)
HTLATEX:=htlatex

# http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all pdf ps dvi bib clean view

all:
	$(MAKE) pdf
	$(MAKE) bib
	$(MAKE) pdf
	$(MAKE) view

publ:
	$(PDFLATEX) $(PUBLTEXFILE)
	for i in 1 2 3 4 5 6; do $(BIB) $(PUBLTEXFILE)$$i-blx; done
	$(PDFLATEX) $(PUBLTEXFILE)

summ:
	$(PDFLATEX) $(SUMMTEXFILE)
	$(PDFLATEX) $(SUMMTEXFILE)

view:
	@echo " --- $(PDFVIEW) $(MAINTEXFILE)"
	$(PDFVIEW) $(MAINTEXFILE).pdf

pdf:
	@echo " --- $(PDFLATEX) $(MAINTEXFILE)"
	$(PDFLATEX) $(MAINTEXFILE) | egrep --colour=always 'Warning|Error'

ps:
	@echo " --- $(LATEX) $(MAINTEXFILE)"
	$(LATEX) $(MAINTEXFILE)

dvi: ps
	@echo " --- $(DVIPS) $(MAINTEXFILE)"
	$(DVIPS) $(MAINTEXFILE)
	@echo " --- $(DVIPDF) $(MAINTEXFILE)"
	$(DVIPDF) $(MAINTEXFILE)

bib:
	@echo " --- $(BIBTEX) $(MAINTEXFILE)"
	$(BIBTEX) $(MAINTEXFILE)

clean:
	@for i in -blx.bib 4ct 4tc aux bbl bcf blg brf css dvi fdb_latexmk fls flsm idv idx lg lof log lol lot nav out pdf ps run.xml snm synctex.gz tmp toc xref glo .ist glsdefs .vrb; do rm -fv *$$i; done; rm -fv *synctex*

perms:
	find . -maxdepth 1 -type f | xargs chmod -v a-x
	chmod -v u+x *.sh

install-tex:
	brew install ghostscript imagemagick
	brew cask install basictex
	sudo tlmgr update --self
	sudo tlmgr update --all
	sudo tlmgr install latexmk collection-latexrecommended collection-fontsrecommended texliveonfly ly1

#NOTICE: this will grep the packages declared explicitly in the code but fail to resolve hidden dependencies
list-packages:
	@grep \usepackage *.tex | grep -v ':%' |  awk -F'[\{\}]' '{print $$2}' | sort -u

#NOTICE: this greps the 'tlmgr install' annotations, which are incremented manually with the list of necessary packages
install-list-packages:
	@grep tlmgr *.tex | awk -F'tlmgr install' '{print $$2}' | tr ' ' '\n' | sort -u | tr '\n' ' '

install-packages:
	sudo tlmgr install `$(MAKE) install-list-packages`

install-html:
	sudo tlmgr install tex4ht

html: clean
	#https://tex.stackexchange.com/questions/185349/error-using-pgfsysdriver-with-tex4ht-only-shows-up-with-texlive-2014-ok-with-t
	[ -e pgfsys-tex4ht.def ] && echo "Found fixed pgfsys-tex4ht.def"
	sed 's/\togglefalse{html}/\toggletrue{html}/' $(MAINTEXFILE).tex > $(MAINTEXFILE)_html.tex
	$(PDFLATEX) $(MAINTEXFILE)_html
	$(BIBTEX) $(MAINTEXFILE)_html
	$(PDFLATEX) $(MAINTEXFILE)_html
	$(HTLATEX) $(MAINTEXFILE)_html "xhtml,charset=utf-8" " -utf8 -cunihtf" "" -shell-escape
	for i in html css svg png; do for j in $(MAINTEXFILE)*.$$i; do [ -e $$j ] && mv -fv $$j $(HTMLDIR) || echo No $$j; done ; done
	cp -r figures $(HTMLDIR)/

#this only works on my machine
lib:
	LIBDIR=$$HOME/cloud/common/github/jgte.github.io/cv; [ -e $$LIBDIR/library.bib ] && (rm -f library.bib && cp -fv $$LIBDIR/library.bib .)

html_pdf:
	rm -fv $(HTMLDIR)/$(MAINTEXFILE).pdf
	cp -fv $(MAINTEXFILE).pdf $(HTMLDIR)/
