set -exou

mkdir qt-build
pushd qt-build

USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
echo USED_BUILD_PREFIX=${BUILD_PREFIX}

ln -s ${GXX} g++ || true
ln -s ${GCC} gcc || true
ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

export LD=${GXX}
export CC=${GCC}
export CXX=${GXX}

chmod +x g++ gcc gcc-ar
export PATH=${PWD}:${PATH}

../configure -opensource -nomake examples -nomake tests -gstreamer 1.0 -skip qtwebengine -confirm-license
make -j$(nproc)
exit 1
