set -exou

mkdir qt-build
pushd qt-build

../configure -opensource -nomake examples -nomake tests -gstreamer 1.0 -skip qtwebengine
exit 1
