#!/bin/bash

LIBDIR=$(cygpath -m $5)
SERIES=${1%.*}

case "$2" in
  cc)
    cd tcl$1/win
    make TCL_LIBRARY=$LIBDIR/tcl$SERIES install-binaries install-libraries
    cd ../../win
    make TK_LIBRARY=$LIBDIR/tk$SERIES install-binaries install-libraries
    ;;
  cl)
    cd tcl$1/win
    MSDEVDIR=trick nmake -nologo -f makefile.vc install-binaries install-libraries OUT_DIR=. INSTALLDIR=$4 LIB_INSTALL_DIR=$5 INCLUDE_INSTALL_DIR=$5 SCRIPT_INSTALL_DIR=$5\\tcl$SERIES
    cd ../../win
    MSDEVDIR=trick nmake -nologo -f makefile.vc install-binaries install-libraries OUT_DIR=. INSTALLDIR=$4 TCLDIR=$3\\tcl$1 LIB_INSTALL_DIR=$5 INCLUDE_INSTALL_DIR=$5 SCRIPT_INSTALL_DIR=$5\\tk$SERIES
    ;;
esac
