HSC=ghc
HSCFLAGS=-Wall
HSC2HS=hsc2hs
GTAGS=../global/gtags/gtags

.SUFFIXES: .hsc .hs .hi

all: gtagsjs.so

test: gtagsjs.so
	$(GTAGS) --gtagsconf=./gtags.conf --gtagslabel=gtagsjs

valgrind:
	$(HSC) $(HSCFLAGS) --make -c Gtagsjs.hs
	$(HSC) $(HSCFLAGS) --make -no-hs-main -o main Gtagsjs.hs gtagsjs.c main.c
	valgrind ./main

gtagsjs.so: Gtagsjs.hs Gtags/ParserParam.hs Gtags/Internal.hs
	$(HSC) $(HSCFLAGS) --make -c Gtagsjs.hs
	$(HSC) $(HSCFLAGS) --make -no-hs-main -optl-shared -o $@ Gtagsjs.hs gtagsjs.c

gtagsjs.c: parser.h Gtagsjs_stub.h

.hsc.hs:
	$(HSC2HS) $<

clean:
	$(RM) *.{hi,o} main gtagsjs.so *_stub.{h,c} *~

depend: Gtagsjs.hs
	$(HSC) -M Gtagsjs.hs

.PHONY: test valgrind gtagsjs.so clean
