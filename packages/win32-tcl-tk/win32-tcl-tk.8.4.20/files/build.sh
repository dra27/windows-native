#!/bin/bash

PREFIX=$(cygpath -m $4)
BINDIR=$(cygpath -m $5)
LIBDIR=$(cygpath -m $6)

# Un-pack and patch Tcl (opam files can't express the build tree properly)
tar -xzf tcl$1-src.tar.gz
cd tcl$1
patch -p1 -i ../tcl$1-msvc64.patch
patch -p1 -i ../tcl$1-mingw.patch

# Build Tcl
cd win

# Alter the logic used to locate the Tcl scripts to cope with OPAM's layout
sed -i -e "s/lib\/tcl%/lib\/win32-tcl-tk\/tcl%/" tclWinInit.c

case "$2" in
  mingw)
    LDFLAGS=-static-libgcc CC=i686-w64-mingw32-gcc AR=i686-w64-mingw32-ar RANLIB=i686-w64-mingw32-ranlib RC=i686-w64-mingw32-windres ./configure --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR
    make binaries
    ;;
  mingw64)
    LDFLAGS=-static-libgcc CC=x86_64-w64-mingw32-gcc AR=x86_64-w64-mingw32-ar RANLIB=x86_64-w64-mingw32-ranlib RC=x86_64-w64-mingw32-windres ./configure --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR
    make binaries
    ;;
  msvc|msvc64)
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=.
    ;;
esac

# Build Tk
cd ../../win

case "$2" in
  mingw)
    CC=i686-w64-mingw32-gcc AR=i686-w64-mingw32-ar RANLIB=i686-w64-mingw32-ranlib RC=i686-w64-mingw32-windres ./configure --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --with-tcl=../tcl$1/win
    make binaries
    ;;
  mingw64)
    CC=x86_64-w64-mingw32-gcc AR=x86_64-w64-mingw32-ar RANLIB=x86_64-w64-mingw32-ranlib RC=x86_64-w64-mingw32-windres ./configure --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --with-tcl=../tcl$1/win
    make binaries
    ;;
  msvc|msvc64)
    # Don't install demos (not a separate target, unlike Makefile)
    sed -i -e "/demos/d" makefile.vc
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=. TCLDIR=$3\\tcl$1 BUILDDIRTOP=.
    ;;
esac
