CWEAVE:=$(shell which cweave)
CTANGLE:=$(shell which ctangle)
DVIPS:=$(shell which dvips)
CC:=$(shell which gcc) -Wall -O2
TEX:=$(shell which tex)
PDFTEX:=$(shell which pdftex)
RM:=/bin/rm -f

.SUFFIXES:

SOURCES=Makefile dvitotxt.w integral.tex txttodvi.w txttoslides.w \
	dvitoslides.w tfm-files.txt tex CVS
%: %.o
	$(CC) -o $@ $<

%.o: %.c
	$(CC) -o $@ -c $<

%.c: %.w
	$(CTANGLE) -bhp $*

%.tex: %.w
	$(CWEAVE) -bhp $*

%.dvi: %.tex
	$(TEX) $*

%.ps: %.dvi
	$(DVIPS) $* -o

%.pdf: %.tex
	$(PDFTEX) $*

clean: 
	$(RM) $(filter-out $(SOURCES),$(shell /bin/ls))
