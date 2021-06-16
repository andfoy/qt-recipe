setlocal enableextensions enabledelayedexpansion

set LIBRARY_PATHS=-I %LIBRARY_INC%

pushd %LIBRARY_INC%
for /F "usebackq delims=" %%F in (`dir /b /ad-h`) do (
    set LIBRARY_PATHS=!LIBRARY_PATHS! -I %LIBRARY_INC%\%%F
)
popd
endlocal

set PATH=%cd%\jom;%PATH%

mkdir b
pushd b

where jom

:: Set QMake prefix to LIBRARY_PREFIX
qmake -set prefix %LIBRARY_PREFIX%

qmake QMAKE_LIBDIR=%LIBRARY_LIB% ^
      INCLUDEPATH+="%LIBRARY_INC%" \
      ..

echo on

jom
jom install
