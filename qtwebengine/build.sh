set -exou

if [[ $(arch) == "aarch64" || $(uname) == "Darwin" ]]; then
pushd qtwebengine-chromium

git config user.name 'Anonymous'
git config user.email '<>'

git add -A
git commit -m "Patches"
popd
fi

git submodule init
git submodule set-url src/3rdparty "$SRC_DIR"/qtwebengine-chromium
git submodule set-branch --branch 87-based src/3rdparty
git submodule update

pushd src/3rdparty
git checkout 87-based
git pull
popd

mkdir qtwebengine-build
pushd qtwebengine-build

USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
echo USED_BUILD_PREFIX=${BUILD_PREFIX}

if [[ $(uname) == "Linux" ]]; then
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
fi

if [[ $(uname) == "Darwin" ]]; then
    export AR=$(basename ${AR})
    export RANLIB=$(basename ${RANLIB})
    export STRIP=$(basename ${STRIP})
    export OBJDUMP=$(basename ${OBJDUMP})
    export CC=$(basename ${CC})
    export CXX=$(basename ${CXX})

    # Let Qt set its own flags and vars
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
        unset $x
    done

    # sed '54s/CONFIG = file_copies qmake_use qt warn_on release link_prl/CONFIG = file_copies qmake_use qt warn_off release link_prl/' $PREFIX/mkspecs/features/spec_pre.prf

    # echo "QMAKE_CFLAGS = \$\$replace(QMAKE_CFLAGS, \"-Werror\", \"\")" >> ../qtwebengine.pro
    # echo "QMAKE_CXXFLAGS = \$\$replace(QMAKE_CXXFLAGS, \"-Werror\", \"\")" >> ../qtwebengine.pro
    # echo "QMAKE_CFLAGS = \$\$replace(QMAKE_CFLAGS, \"-Wextra\", \"\")" >> ../qtwebengine.pro
    # echo "QMAKE_CXXFLAGS = \$\$replace(QMAKE_CXXFLAGS, \"-Wextra\", \"\")" >> ../qtwebengine.pro

    export APPLICATION_EXTENSION_API_ONLY=NO

    # Set QMake prefix to $PREFIX
    qmake -set prefix $PREFIX

    # sed -i '' -e 's/-Werror//' $PREFIX/mkspecs/features/qt_module_headers.prf

    qmake QMAKE_LIBDIR=${PREFIX}/lib \
        INCLUDEPATH+="${PREFIX}/include" \
        CONFIG+="warn_off" \
        QMAKE_CFLAGS_WARN_ON="-w" \
        QMAKE_CXXFLAGS_WARN_ON="-w" \
        QMAKE_CFLAGS+="-Wno-everything" \
        QMAKE_CXXFLAGS+="-Wno-everything" \
        QMAKE_LFLAGS+="-Wno-everything -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib" \
        PKG_CONFIG_EXECUTABLE=$(which pkg-config) \
        ..

    # find . -type f -exec sed -i '' -e 's/-Wl,-fatal_warnings//g' {} +
    # sed -i '' -e 's/-Werror//' $PREFIX/mkspecs/features/qt_module_headers.prf

    make -j$CPU_COUNT
    make install
fi
