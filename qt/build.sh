set -exou

mkdir qt-build
pushd qt-build


#export AR=$(basename ${AR})
#export RANLIB=$(basename ${RANLIB})
#export STRIP=$(basename ${STRIP})
#export OBJDUMP=$(basename ${OBJDUMP})
#export CC=$(basename ${CC})
#export CXX=$(basename ${CXX})


USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
echo USED_BUILD_PREFIX=${BUILD_PREFIX}

ln -s ${GXX} g++ || true
ln -s ${GCC} gcc || true
ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

export LD=${GXX}
export CC=${GCC}
export CXX=${GXX}
export PKG_CONFIG_EXECUTABLE=$(basename $(which pkg-config))

chmod +x g++ gcc gcc-ar
export PATH=${PWD}:${PATH}

../configure -prefix ${PREFIX} \
             -libdir ${PREFIX}/lib \
             -bindir ${PREFIX}/bin \
             -headerdir ${PREFIX}/include/qt \
             -archdatadir ${PREFIX} \
             -datadir ${PREFIX} \
             -I ${PREFIX}/include \
             -L ${PREFIX}/lib \
             -L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 \
             QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
             -opensource \
             -nomake examples \
             -nomake tests \
             -gstreamer 1.0 \
             -skip qtwebengine \
             -confirm-license \
             -system-libjpeg \
             -system-libpng \
             -system-zlib \

make -j$(nproc)
make install
