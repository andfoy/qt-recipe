set -exou

pushd pyqt_webengine

if [[ $(uname) == "Linux" ]]; then
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

    sip-build \
    --verbose \
    --no-make

    pushd build
    CPATH=$PREFIX/include make -jCPU_COUNT
    make install
fi

if [[ $(uname) == "Darwin" ]]; then
    sip-build \
    --verbose \
    --no-make

    pushd build
    CPATH=$PREFIX/include make -j$CPU_COUNT
    make install
fi
