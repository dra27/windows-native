#!/bin/bash

PREFIX=$(cygpath -m $4)
BINDIR=$(cygpath -m $5)
LIBDIR=$(cygpath -m $6)

# Un-pack Tcl (opam files can't express the build tree properly)
tar -xzf tcl$1-src.tar.gz
cd tcl$1

# Build Tcl
cd win

# Alter the logic used to locate the Tcl scripts to cope with OPAM's layout
sed -i -e "s/lib\/tcl%/lib\/win32-tcl-tk\/tcl%/" tclWinInit.c

SERIES=${1%.*}

case "$2" in
  mingw)
    ./configure --build=i686-pc-cygwin --host=i686-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR
    make TCL_LIBRARY=$LIBDIR/tcl$SERIES binaries
    ;;
  mingw64)
    ./configure --build=i686-pc-cygwin --host=x86_64-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR
    make TCL_LIBRARY=$LIBDIR/tcl$SERIES binaries
    ;;
  msvc|msvc64)
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=. INSTALLDIR=$4 LIB_INSTALL_DIR=$6 INCLUDE_INSTALL_DIR=$6 SCRIPT_INSTALL_DIR=$6\\tcl$SERIES
    ;;
esac

# Build Tk
cd ../../win

case "$2" in
  mingw)
    ./configure --build=i686-pc-cygwin --host=i686-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --with-tcl=../tcl$1/win
    make binaries
    ;;
  mingw64)
    ./configure --build=i686-pc-cygwin --host=x86_64-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --with-tcl=../tcl$1/win
    make binaries
    ;;
  msvc|msvc64)
    # Don't install demos (not a separate target, unlike Makefile)
    sed -i -e "/demos/d" makefile.vc
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=. TCLDIR=$3\\tcl$1 BUILDDIRTOP=.
    ;;
esac
