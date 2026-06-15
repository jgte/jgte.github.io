MAINTEXFILE:=jgte_cv
PUBLTEXFILE:=jgte_publications
SUMMTEXFILE:=jgte_summary

PDFLATEXOPTS:=-halt-on-error -interaction nonstopmode
PDFVIEW=$(shell which gnome-open || which open || which evince || which gpdf || which kpdf || which acroread || which xpdf)

# determining computer
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	EXEDIR:=/Library/TeX/texbin/
	export PATH := $(PATH):/Library/TeX/texbin/
endif

LATEX:=$(EXEDIR)latex
DVIPS:=$(EXEDIR)dvips
DVIPDF:=$(EXEDIR)dvipdf
PDFLATEX:=$(EXEDIR)pdflatex
BIBTEX:=$(EXEDIR)bibtex
HTLATEX:=$(EXEDIR)htlatex
TLMGR:=$(EXEDIR)tlmgr
LATEXMK=$(EXEDIR)latexmk -pdf

.PHONY: all pdf ps dvi bib clean view

report:
	$(LATEXMK) $(MAINTEXFILE) | egrep -i --colour=always 'Warning|Error'
	$(PDFVIEW) $(MAINTEXFILE).pdf

publ:
	$(PDFLATEX) $(PUBLTEXFILE)
	for i in 1 2 3 4 5 6; do $(BIB) $(PUBLTEXFILE)$$i-blx; done
	$(PDFLATEX) $(PUBLTEXFILE)

summ:
	$(PDFLATEX) $(SUMMTEXFILE)
	$(PDFLATEX) $(SUMMTEXFILE)

poster-portrait:
	$(PDFLATEX) $(MAINTEXFILE)-poster-portrait | egrep --colour=always 'Warning|Error'
	$(BIBTEX)   $(MAINTEXFILE)-poster-portrait
	$(PDFLATEX) $(MAINTEXFILE)-poster-portrait | egrep --colour=always 'Warning|Error'
	$(PDFLATEX) $(MAINTEXFILE)-poster-portrait | egrep --colour=always 'Warning|Error'
	$(PDFVIEW)  $(MAINTEXFILE)-poster-portrait.pdf

poster-landscape:
	$(PDFLATEX) $(MAINTEXFILE)-poster-landscape | egrep --colour=always 'Warning|Error'
	$(BIBTEX)   $(MAINTEXFILE)-poster-landscape
	$(PDFLATEX) $(MAINTEXFILE)-poster-landscape | egrep --colour=always 'Warning|Error'
	$(PDFLATEX) $(MAINTEXFILE)-poster-landscape | egrep --colour=always 'Warning|Error'
	$(PDFVIEW)  $(MAINTEXFILE)-poster-landscape.pdf

presentation:
	$(PDFLATEX) -shell-escape $(MAINTEXFILE)-presentation | egrep --colour=always 'Warning|Error'
	$(BIBTEX) $(MAINTEXFILE)-presentation.aux
	$(PDFLATEX) -shell-escape $(MAINTEXFILE)-presentation | egrep --colour=always 'Warning|Error'

view:
	$(PDFVIEW) $(MAINTEXFILE).pdf

pdf:
	$(PDFLATEX) $(MAINTEXFILE) | egrep --colour=always 'Warning|Error'

ps:
	$(LATEX) $(MAINTEXFILE)

dvi: ps
	$(DVIPS)  $(MAINTEXFILE)
	$(DVIPDF) $(MAINTEXFILE)

bib:
	$(BIBTEX) $(MAINTEXFILE)

clean:
	@for i in -blx.bib 4ct 4tc aux bbl bcf blg brf css dvi fdb_latexmk fls flsm idv idx lg lof log lol lot nav out pdf ps run.xml snm synctex.gz tmp toc xref glo .ist glsdefs .vrb; do rm -fv *$$i; done; rm -fv *synctex*

perms:
	find . -maxdepth 1 -type f | xargs chmod -v a-x
	chmod -v u+x *.sh

install-tex:
	brew install ghostscript imagemagick
	brew install basictex
	sudo $(TLMGR) update --self
	sudo $(TLMGR) update --all
	sudo $(TLMGR) install latexmk collection-latexrecommended collection-fontsrecommended texliveonfly ly1

#NOTICE: this will grep the packages declared explicitly in the code but fail to resolve hidden dependencies; also some packages are not named consistently in the \usepackage and tlmgr
list-packages:
	@grep '\usepackage' *.tex | grep -v ':%' |	awk -F'[\{\}]' '{print $$2}' | sort -u

#NOTICE: this greps the 'tlmgr install' annotations, which are incremented manually with the list of necessary packages
install-list-packages:
	@grep tlmgr *.tex | awk -F'tlmgr install' '{print $$2}' | tr ' ' '\n' | sort -u | tr '\n' ' '

install-packages:
	sudo $(TLMGR) install `$(MAKE) install-list-packages`

install-html:
	sudo $(TLMGR) install tex4ht

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
	LIBDIR=$$HOME/cloud/common/github/latex; [ -e $$LIBDIR/library.bib ] && [ ! "$$PWD" == "$$LIBDIR" ] && (rm -f library.bib && cp -fv $$LIBDIR/library.bib .)

html_pdf:
	rm -fv $(HTMLDIR)/$(MAINTEXFILE).pdf
	cp -fv $(MAINTEXFILE).pdf $(HTMLDIR)/
