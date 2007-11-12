# Makefile to build the composite D runtime library for Linux
# Designed to work with GNU make
# Targets:
#	make
#		Same as make all
#	make lib
#		Build the runtime library
#   make doc
#       Generate documentation
#	make clean
#		Delete unneeded files created by build process

LIB_TARGET=libtango-base-dmd.a
LIB_MASK=libtango-base-dmd*.a

DIR_CC=./common/tango
DIR_RT=./compiler/dmd
DIR_GC=./gc/basic

CP=cp -f
RM=rm -f
MD=mkdir -p

CC=gcc
LC=$(AR) -qsv
DC=dmd

ADD_CFLAGS=-m32
ADD_DFLAGS=

targets : lib doc
all     : lib doc

######################################################

ALL_OBJS=

######################################################

ALL_DOCS=

######################################################

lib : $(ALL_OBJS)
	make -C $(DIR_CC) -fposix.mak lib DC=$(DC) ADD_DFLAGS="$(ADD_DFLAGS)" ADD_CFLAGS="$(ADD_CFLAGS)"
	make -C $(DIR_RT) -fposix.mak lib
	make -C $(DIR_GC) -fposix.mak lib DC=$(DC) ADD_DFLAGS="$(ADD_DFLAGS)" ADD_CFLAGS="$(ADD_CFLAGS)"
	find . -name "libphobos*.a" | xargs $(RM)
	$(LC) $(LIB_TARGET) `find $(DIR_CC) -name "*.o" | xargs echo`
	$(LC) $(LIB_TARGET) `find $(DIR_RT) -name "*.o" | xargs echo`
	$(LC) $(LIB_TARGET) `find $(DIR_GC) -name "*.o" | xargs echo`

doc : $(ALL_DOCS)
	make -C $(DIR_CC) -fposix.mak doc
	make -C $(DIR_RT) -fposix.mak doc
	make -C $(DIR_GC) -fposix.mak doc

######################################################

clean :
	find . -name "*.di" | xargs $(RM)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_DOCS)
	make -C $(DIR_CC) -fposix.mak clean
	make -C $(DIR_RT) -fposix.mak clean
	make -C $(DIR_GC) -fposix.mak clean
#	$(RM) $(LIB_MASK)

install :
	make -C $(DIR_CC) -fposix.mak install
	make -C $(DIR_RT) -fposix.mak install
	make -C $(DIR_GC) -fposix.mak install
#	$(CP) $(LIB_MASK) $(LIB_DEST)/.
