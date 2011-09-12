HSC=ghc
HSCFLAGS=-fPIC -O2 -Wall\
  -hide-all-packages\
  -package array\
  -package base\
  -package mtl\
  -package parsec-2.1.0.1\
  -package syb\
  -package WebBits
HSC2HS=hsc2hs
GTAGS=../global/gtags/gtags

.SUFFIXES: .hsc .hs .hi

all: gtagsjs.so

test: gtagsjs.so
	$(GTAGS) --gtagsconf=./gtags.conf --gtagslabel=gtagsjs

valgrind: Gtagsjs.hs Gtags/ParserParam.hs Gtags/Internal.hs
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
	find -name '*.hi' | xargs $(RM)
	find -name '*.o' | xargs $(RM)
	find -name '*~' | xargs $(RM)
	find -name '*_stub.h' | xargs $(RM)
	find -name '*_stub.c' | xargs $(RM)
	$(RM) main gtagsjs.so Gtags/Internal.hs Gtags/ParserParam.hs
	$(RM) G{PATH,RTAGS}

depend: Gtagsjs.hs
	$(HSC) -M Gtagsjs.hs

.PHONY: test valgrind gtagsjs.so clean
