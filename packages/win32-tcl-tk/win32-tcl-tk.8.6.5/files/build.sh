#!/bin/bash

BUILDDIR=$(cygpath -m $3)
PREFIX=$(cygpath -m $4)
BINDIR=$(cygpath -m $5)
LIBDIR=$(cygpath -m $6)
ZLIBDIR=$(cygpath -m $7)
ZLIB=$(cygpath -m $7| sed -e "s/[\/&]/\\\\&/g")
ZLIB_NMAKE=$(echo $7| sed -e "s/[\/&]/\\\\&/g")

# Un-pack Tcl (opam files can't express the build tree properly)
tar -xzf tcl$1-src.tar.gz
cd tcl$1

# Build Tcl
cd win

# Patch the sqlite package so that it doesn't install the sqlite3_analyzer script
sed -i -e "/spaceanal/d" ../pkgs/sqlite3.11.0/Makefile.in

# Patch the Windows mingw Makefile to use OPAM's win32-zlib installation and also workaround a cross-compilation fault
sed -i -e "s/@LIBS@.*/@LIBS@ -L$ZLIB -lz.dll/" -e "s/@\$(TCL_EXE)/@.\/\$(TCLSH)/" Makefile.in

# Patch the Windows MSVC Makefile to use OPAM's win32-zlib installation and also pass layout options to the packages
sed -i -e "s/ws2_32.lib\$/& $ZLIB_NMAKE\\\\zdll.lib/" -e "s/=\\\$(ROOT) &/=\$(ROOT) BUILDDIRTOP=\$(BUILDDIRTOP) \\&/" -e "s/=\\\$(ROOT) install &/=\$(ROOT) INSTALLDIR=\$(LIB_INSTALL_DIR) BIN_INSTALL_DIR=\$(BIN_INSTALL_DIR) INCLUDE_INSTALL_DIR=\$(INCLUDE_INSTALL_DIR) install \\&/" makefile.vc

# Alter the logic used to locate the Tcl scripts to cope with OPAM's layout
sed -i -e "s/lib\/tcl%/lib\/win32-tcl-tk\/tcl%/" tclWinInit.c

SERIES=${1%.*}

case "$2" in
  mingw)
    ./configure --build=i686-pc-cygwin --host=i686-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --mandir=$BUILDDIR/tcl$1/win/trick
    make ZLIB_DIR=$ZLIBDIR ZLIB_DLL_FILE= TCL_LIBRARY=$LIBDIR/tcl$SERIES binaries packages
    ;;
  mingw64)
    ./configure --build=i686-pc-cygwin --host=x86_64-w64-mingw32 --prefix=$PREFIX --bindir=$BINDIR --libdir=$LIBDIR --includedir=$LIBDIR --mandir=$BUILDDIR/tcl$1/win/trick
    make ZLIB_DIR=$ZLIBDIR ZLIB_DLL_FILE= TCL_LIBRARY=$LIBDIR/tcl$SERIES binaries packages
    ;;
  msvc|msvc64)
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=. INSTALLDIR=$4 LIB_INSTALL_DIR=$6 INCLUDE_INSTALL_DIR=$6 SCRIPT_INSTALL_DIR=$6\\tcl$SERIES ZLIBOBJS= BUILDDIRTOP=. SUFX=
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
    MSDEVDIR=trick nmake -nologo -f makefile.vc release OUT_DIR=. TCLDIR=$3\\tcl$1 BUILDDIRTOP=. SUFX=
    ;;
esac
