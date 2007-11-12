# Makefile to build the garbage collector D library for Posix
# Designed to work with GNU make
# Targets:
#	make
#		Same as make all
#	make lib
#		Build the garbage collector library
#   make doc
#       Generate documentation
#	make clean
#		Delete unneeded files created by build process

LIB_TARGET=libtango-gc-basic.a
LIB_MASK=libtango-gc-basic*.a

CP=cp -f
RM=rm -f
MD=mkdir -p

ADD_CFLAGS=
ADD_DFLAGS=

CFLAGS=-O -m32 $(ADD_CFLAGS)
#CFLAGS=-g -m32 $(ADD_CFLAGS)

### warnings disabled because gcx has issues ###

DFLAGS=-release -O -inline -version=Posix $(ADD_DFLAGS)
#DFLAGS=-g -version=Posix $(ADD_DFLAGS)

TFLAGS=-O -inline -version=Posix $(ADD_DFLAGS)
#TFLAGS=-g -version=Posix $(ADD_DFLAGS)

DOCFLAGS=-version=DDoc -version=Posix

CC=gcc
LC=$(AR) -qsv
DC=dmd

LIB_DEST=..

.SUFFIXES: .s .S .c .cpp .d .html .o

.s.o:
	$(CC) -c $(CFLAGS) $< -o$@

.S.o:
	$(CC) -c $(CFLAGS) $< -o$@

.c.o:
	$(CC) -c $(CFLAGS) $< -o$@

.cpp.o:
	g++ -c $(CFLAGS) $< -o$@

.d.o:
	$(DC) -c $(DFLAGS) $< -of$@

.d.html:
	$(DC) -c -o- $(DOCFLAGS) -Df$*.html $<
#	$(DC) -c -o- $(DOCFLAGS) -Df$*.html dmd.ddoc $<

targets : lib doc
all     : lib doc
lib     : basic.lib
doc     : basic.doc

######################################################

ALL_OBJS= \
    gc.o \
    gcalloc.o \
    gcbits.o \
    gcstats.o \
    gcx.o

######################################################

ALL_DOCS=

######################################################

basic.lib : $(LIB_TARGET)

$(LIB_TARGET) : $(ALL_OBJS)
	$(RM) $@
	$(LC) $@ $(ALL_OBJS)

basic.doc : $(ALL_DOCS)
	echo No documentation available.

######################################################

clean :
	find . -name "*.di" | xargs $(RM)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_DOCS)
	$(RM) $(LIB_MASK)

install :
	$(MD) $(LIB_DEST)
	$(CP) $(LIB_MASK) $(LIB_DEST)/.
