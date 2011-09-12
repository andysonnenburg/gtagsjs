HSC=/usr/local/bin/ghc
HSCFLAGS=-O2 -Wall\
  -hide-all-packages\
  -package array\
  -package base\
  -package mtl\
  -package parsec-2.1.0.1\
  -package syb\
  -package WebBits
HSCSRCS=$(shell find . -name '*.hsc')
HSMAIN=Gtagsjs.hs
HSSRCS=$(HSMAIN) $(HSCSRCS:.hsc=.hs)
HSC2HS=hsc2hs
CSRCS=gtagsjs.c
GTAGS=../global/gtags/gtags

.SUFFIXES: .hsc .hs .hi

all: gtagsjs.so

test: gtagsjs.so
	$(GTAGS) --gtagsconf=./gtags.conf --gtagslabel=gtagsjs

valgrind: $(HSSRCS)
	$(HSC) $(HSCFLAGS) --make -no-hs-main -o main $(HSMAIN) $(CSRCS) main.c
	valgrind ./main

gtagsjs.so: $(HSSRCS)
	$(HSC) $(HSCFLAGS) --make -no-hs-main -fPIC -shared -static -o $@ $(HSMAIN) $(CSRCS)

gtagsjs.c: parser.h Gtagsjs_stub.h

.hsc.hs:
	$(HSC2HS) $<

$(shell touch depends.mk)
include depends.mk
depends:
	gcc $(CSRCS) -M -MG -MF depends.mk

clean:
	find -name '*.hi' | xargs $(RM)
	find -name '*.o' | xargs $(RM)
	find -name '*~' | xargs $(RM)
	$(RM) main gtagsjs.so Gtags/Internal.hs Gtags/ParserParam.hs
	$(RM) G{PATH,RTAGS}

.PHONY: all test valgrind gtagsjs.so clean

