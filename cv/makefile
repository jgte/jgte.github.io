MAINTEXFILE:=cv_jgte
PUBLTEXFILE:=publications_jgte
GOOGLESCHOLARBIBFILE:=citations.bib
BIBFILE:=cv_jgte.bib

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
BIBTEX:=$(EXEDIR)bibtex
BIBER:=$(EXEDIR)biber
PDFVIEW:=$(shell which gnome-open || which open || which evince || which gpdf || which kpdf || which acroread || which xpdf)
PDFLATEX:=$(EXEDIR)pdflatex $(PDFLATEXOPTS)
HTLATEX:=htlatex

# http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all pdf ps dvi bib clean view tables biber

all: clean pdf print publ html

html:
	$(HTLATEX) $(MAINTEXFILE) "xhtml, charset=utf-8" " -cunihtf -utf8"
	mv -f $(MAINTEXFILE).html index.html

print: parse_bib
	sed 's_\togglefalse{expliciturl}_\toggletrue{expliciturl}_' $(MAINTEXFILE).tex > $(MAINTEXFILE)_print.tex
	$(PDFLATEX) $(MAINTEXFILE)_print
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(MAINTEXFILE)_print
	$(PDFLATEX) $(MAINTEXFILE)_print

publ: parse_bib
	$(PDFLATEX) $(PUBLTEXFILE)
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(PUBLTEXFILE)
	$(PDFLATEX) $(PUBLTEXFILE)

pdf: parse_bib
	$(PDFLATEX) $(MAINTEXFILE)
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(MAINTEXFILE)
	$(PDFLATEX) $(MAINTEXFILE)

view:
	$(PDFVIEW) $(MAINTEXFILE).pdf

ps:
	$(LATEX) $(MAINTEXFILE)

dvi: ps
	$(DVIPS) $(MAINTEXFILE)
	$(DVIPDF) $(MAINTEXFILE)

bib:
	$(BIBTEX) $(MAINTEXFILE)
	$(BIBTEX) $(PUBLTEXFILE)

biber: parse_bib
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(MAINTEXFILE)
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(PUBLTEXFILE)
	$(BIBER) --output-directory "$(CURDIR)" --input-directory "$(CURDIR)" $(MAINTEXFILE)_print

clean:
	@for j in $(MAINTEXFILE) $(PUBLTEXFILE) $(MAINTEXFILE)_print; do for i in aux dvi log ps pdf toc fdb_latexmk flsm blg bbl bcf out run.xml synctex.gz; do rm -fv $$j.$$i; done; done

parse_bib:
	cat $(GOOGLESCHOLARBIBFILE) \
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
	| sed 's_Encarna{\\c{c}}{\\~a}o_\\textbf{de Teixeira da Encarna{\\c{c}}{\\~a}o}_g' \
	| sed 's_Jo{\\~a}o_\\textbf{Jo{\\~a}o}_g' \
	| sed 's_XZQGJ_X_g' \
	| sed 's_Congres}_Congress}_g' \
	| sed 's_(scarf)_({SCARF})_g' \
	 > "$(CURDIR)/$(MAINTEXFILE).bib"
	tr '´' "'" < "$(CURDIR)/$(MAINTEXFILE).bib" | sponge "$(CURDIR)/$(MAINTEXFILE).bib"
	tr '`' "'" < "$(CURDIR)/$(MAINTEXFILE).bib" | sponge "$(CURDIR)/$(MAINTEXFILE).bib"






