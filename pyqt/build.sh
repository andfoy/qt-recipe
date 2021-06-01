set -exou

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

find /usr -name libgl*

# if [[ $(arch) == "x86_64" ]]; then
#   CPATH=$PREFIX/include $PYTHON -m pip install . -vv
# fi

#if [[ $(arch) == "aarch64" ]]; then
    which make

    SITE_PKGS_PATH=$(python -c 'import site;print(site.getsitepackages()[0])')
    echo $SITE_PKGS_PATH

    sip-build \
    --verbose \
    --confirm-license \
    --target-dir $SITE_PKGS_PATH \
    --no-make

   pushd build
   CPATH=$PREFIX/include make -j$(nproc)
   make install
#fi

