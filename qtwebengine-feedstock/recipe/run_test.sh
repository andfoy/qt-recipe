#!/bin/bash

set -e

ls
cd test
ln -s ${GXX} g++
export PATH=$PREFIX/bin/xc-avoidance:${PWD}:${PATH}
# Only test that this builds
qmake QMAKE_LIBDIR=${PREFIX}/lib \
      INCLUDEPATH+="${PREFIX}/include" \
      QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
      qtwebengine.pro
make
