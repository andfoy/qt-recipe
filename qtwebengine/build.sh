set -exou

git submodule init
git submodule set-url src/3rdparty "$BUILD_PREFIX"/qtwebengine-chromium
git submodule set-branch --branch 87-based src/3rdparty
git submodule update

mkdir qtwebengine-build
pushd qtwebengine-build

USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
echo USED_BUILD_PREFIX=${BUILD_PREFIX}

ln -s ${GXX} g++ || true
ln -s ${GCC} gcc || true
ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

export LD=${GXX}
export CC=${GCC}
export CXX=${GXX}

chmod +x g++ gcc gcc-ar
export PATH=$PREFIX/bin:${PWD}:${PATH}

which pkg-config
export PKG_CONFIG_EXECUTABLE=$(which pkg-config)

$(gcc -print-file-name=libc.so.6)

# Set QMake prefix to $PREFIX
qmake -set prefix $PREFIX

qmake QMAKE_LIBDIR=${PREFIX}/lib \
      QMAKE_LFLAGS+="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib" \
      INCLUDEPATH+="${PREFIX}/include" \
      PKG_CONFIG_EXECUTABLE=$(which pkg-config) \
      ..

#cat config.log
#exit 1
CPATH=$PREFIX/include:$BUILD_PREFIX/src/core/api make -j$(nproc)
make install
