#!/bin/bash

set -e

ls
cd test
ln -s ${GXX} g++
cp ../xcrun .
cp ../xcodebuild .
export PATH=${PWD}:${PATH}
# Only test that this builds
qmake qtwebengine.pro
make
