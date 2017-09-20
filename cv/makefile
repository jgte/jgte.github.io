MAINTEXFILE:=cv_jgte
PUBLTEXFILE:=publications_jgte
SUMMTEXFILE:=summary_jgte

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

# setting executable dir
ifeq ($(UNAME), Linux)
	EXEDIR:=
	PDFLATEXOPTS:=-halt-on-error -interaction nonstopmode
endif
ifeq ($(UNAME), Darwin)
	EXEDIR:=/Library/TeX/texbin/
	PDFLATEXOPTS:=-halt-on-error -interaction nonstopmode
	export PATH := $(PATH):/usr/local/bin/
endif

LATEX:=$(EXEDIR)latex
DVIPS:=$(EXEDIR)dvips
DVIPDF:=$(EXEDIR)dvipdf
# BIB:=$(EXEDIR)biber --output-directory "$(CURDIR)" --input-directory "$(CURDIR)"
BIB:=$(EXEDIR)bibtex

PDFVIEW:=$(shell which gnome-open || which open || which evince || which gpdf || which kpdf || which acroread || which xpdf)
PDFLATEX:=$(EXEDIR)pdflatex $(PDFLATEXOPTS)
HTLATEX:=htlatex

# http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all pdf ps dvi bib clean view bibparse

all: clean pdf print publ summ

publ:
	$(PDFLATEX) $(PUBLTEXFILE)
	for i in 1 2 3 4 5 6; do $(BIB) $(PUBLTEXFILE)$$i-blx; done
	$(PDFLATEX) $(PUBLTEXFILE)

summ:
	$(PDFLATEX) $(SUMMTEXFILE)
	$(PDFLATEX) $(SUMMTEXFILE)

pdf:
	$(PDFLATEX) $(MAINTEXFILE)
	$(BIB)      $(MAINTEXFILE)
	for i in 1 2 3 4 5 6; do $(BIB) $(MAINTEXFILE)$$i-blx; done
	$(PDFLATEX) $(MAINTEXFILE)

print:
	sed 's_\togglefalse{expliciturl}_\toggletrue{expliciturl}_' $(MAINTEXFILE).tex > $(MAINTEXFILE)_print.tex
	$(PDFLATEX) $(MAINTEXFILE)_print
	for i in 1 2 3 4 5 6; do $(BIB) $(MAINTEXFILE)_print$$i-blx; done
	$(PDFLATEX) $(MAINTEXFILE)_print

view:
	$(PDFVIEW) $(MAINTEXFILE).pdf

ps:
	$(LATEX) $(MAINTEXFILE)

dvi: ps
	$(DVIPS) $(MAINTEXFILE)
	$(DVIPDF) $(MAINTEXFILE)

bib:
	cp -v ../../latex/library.bib .

clean:
	@for j in summary publications affiliation $(MAINTEXFILE) $(MAINTEXFILE)_print $(PUBLTEXFILE) $(SUMMTEXFILE); do for i in aux dvi log ps pdf toc fdb_latexmk flsm blg bbl bcf out run.xml synctex.gz 4ct 4tc css fls idv lg md tmp xref; do rm -fv $$j.$$i; done; done
	@rm -fv *-blx.bbl *-blx.bib *-blx.blg *.log *.aux

get_bib:
	open https://scholar.google.com/citations?user=k2liFwQAAAAJ
	wget '$(GOOGLESCHOLARBIBURL)' -O $(GOOGLESCHOLARBIBFILE).new
	iconv -f $(GOOGLESCHOLARBIBENCOD) -t utf-8 $(GOOGLESCHOLARBIBFILE).new > /tmp/$(GOOGLESCHOLARBIBFILE).new
	mv -f /tmp/$(GOOGLESCHOLARBIBFILE).new $(GOOGLESCHOLARBIBFILE).new
	@echo New citations:
	@bash -c "diff <( grep \@ $(GOOGLESCHOLARBIBFILE).new | awk -F'{' '{ print $2}' | sort ) <( grep \@ $(GOOGLESCHOLARBIBFILE) | awk -F'{' '{ print $2}' | sort )" || echo "End new citations."
	mv -f $(GOOGLESCHOLARBIBFILE).new $(GOOGLESCHOLARBIBFILE)

parse_bib:
	cat $(GOOGLESCHOLARBIBFILE) \
	| sed 's|\d0097|-|g' \
	| sed 's_Encarnacao_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_Encarnagao_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_Encarnac{\\~a}o_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_Encarna{\\c{c}}ao_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_da Encarna{\\c{c}}{\\~a}o_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_Da Encarna{\\c{c}}{\\~a}o_Encarna{\\c{c}}{\\~a}o_g' \
	| sed 's_de Teixeira__g' \
	| sed 's_De Teixeira__g' \
	| sed 's_Teixeira__g' \
	| sed 's_Encarna{\\c{c}}{\\~a}o, J _Encarna{\\c{c}}{\\~a}o, Jo{\\~a}o _g' \
	| sed 's_Encarna{\\c{c}}{\\~a}o, J. _Encarna{\\c{c}}{\\~a}o, Jo{\\~a}o _g' \
	| sed 's_Encarna{\\c{c}}{\\~a}o, J.G. _Encarna{\\c{c}}{\\~a}o, Jo{\\~a}o _g' \
	| sed 's_Joao_Jo{\\~a}o_g' \
	# | sed 's_Encarna{\\c{c}}{\\~a}o_\\textbf{de Teixeira da Encarna{\\c{c}}{\\~a}o}_g' \
	# | sed 's_Jo{\\~a}o_\\textbf{Jo{\\~a}o}_g' \
	| sed 's_XZQGJ_X_g' \
	| sed 's_Congres}_Congress}_g' \
	| sed 's_(scarf)_({SCARF})_g' \
	 > "$(CURDIR)/$(MAINTEXFILE).bib"
	tr '´' "'" < "$(CURDIR)/$(MAINTEXFILE).bib" | sponge "$(CURDIR)/$(MAINTEXFILE).bib"
	tr '`' "'" < "$(CURDIR)/$(MAINTEXFILE).bib" | sponge "$(CURDIR)/$(MAINTEXFILE).bib"

#Obsolete stuff




#sudo tlmgr install tex4ht
html:
	sed 's/\input{cvsection}/\input{cvsection_html}/' $(MAINTEXFILE).tex > $(MAINTEXFILE)_html.tex
	$(PDFLATEX) $(MAINTEXFILE)_html
	for j in 1 2 3 4 5 6; do $(BIB) $(MAINTEXFILE)_html$$j-blx; done
	$(PDFLATEX) $(MAINTEXFILE)_html
	$(HTLATEX) $(MAINTEXFILE)_html "xhtml, charset=utf-8" " -cunihtf -utf8"
	mv -f $(MAINTEXFILE)_html.html index.html



