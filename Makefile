#############################################################################
#
# Makefile for librf24-bcm on Raspberry Pi
#
# License: GPL (General Public License)
# Author:  Charles-Henri Hallard 
# Date:    2013/03/13 
#
# Description:
# ------------
# use make all and mak install to install the library 
# You can change the install directory by editing the LIBDIR line
#
PREFIX=/usr/local

# Library parameters
# where to put the lib
LIBDIR=$(PREFIX)/lib
# lib name 
LIB=librf24-bcm
# shared library name
LIBNAME=$(LIB).so.1.0

# Where to put the header files
HEADER_DIR=${PREFIX}/include/RF24

DRIVER_DIR=RPi

# Arch-specific compiler flags. armhf uses the Pi 1 baseline (compatible with
# every Pi ever); arm64 (Pi3/4/5 in 64-bit mode) uses armv8-a. Override by
# passing CCFLAGS=... on the make command line.
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),aarch64)
    CCFLAGS ?= -Ofast -march=armv8-a
else ifeq ($(UNAME_M),armv6l)
    CCFLAGS ?= -Ofast -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s
else ifeq ($(UNAME_M),armv7l)
    CCFLAGS ?= -Ofast -mfpu=neon-vfpv4 -mfloat-abi=hard -march=armv7-a
else
    CCFLAGS ?= -Ofast
endif

# make all
# reinstall the library after each recompilation
all: librf24-bcm

# Make the library
librf24-bcm: RF24.o bcm2835.o 
	$(CXX) -shared -Wl,-soname,$@.so.1 ${CCFLAGS} -o ${LIBNAME} $^
	
# Library parts
RF24.o: RF24.cpp
	$(CXX) -Wall -fPIC ${CCFLAGS} -c $^

bcm2835.o: ${DRIVER_DIR}/bcm2835.c
	$(CC) -Wall -fPIC ${CCFLAGS} -c $^

# clear build files
clean:
	rm -rf *.o ${LIB}.*

install: all install-libs install-headers

# Install the library to LIBPATH
install-libs: 
	@echo "[Installing Libs]"
	@if ( test ! -d $(PREFIX)/lib ) ; then mkdir -p $(PREFIX)/lib ; fi
	@install -m 0755 ${LIBNAME} ${LIBDIR}
	@ln -sf ${LIBDIR}/${LIBNAME} ${LIBDIR}/${LIB}.so.1
	@ln -sf ${LIBDIR}/${LIBNAME} ${LIBDIR}/${LIB}.so
	@ldconfig

install-headers:
	@echo "[Installing Headers]"
	@if ( test ! -d ${HEADER_DIR} ) ; then mkdir -p ${HEADER_DIR} ; fi
	@install -m 0644 *.h ${HEADER_DIR}
	@if ( test ! -d ${HEADER_DIR}/RPi ) ; then mkdir -p ${HEADER_DIR}/RPi ; fi
	@install -m 0644 ${DRIVER_DIR}/*.h ${HEADER_DIR}/${DRIVER_DIR}
