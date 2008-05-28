MPOST:=$(shell which mpost)
TEX:=$(shell which tex)
DVIPS:=$(shell which dvips)

SOURCES=Makefile circle.mp circle.tex create_tfm.sh pslides.tex tfm_files

.PHONY: clean test

clean:
	/bin/rm -f $(filter-out $(SOURCES),$(shell /bin/ls))

test: circle.dvi
	../dvitoslides -i ./circle.dvi -t ./tfm_files -o ./circle1.dvi
	$(DVIPS) -t landscape circle1 -o

circle.dvi: circle.1 circle.tex pslides.tex

%.1: %.mp
	$(MPOST) $*
	
%.dvi: %.tex
	$(TEX) $*

