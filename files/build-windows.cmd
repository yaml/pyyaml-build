
set ver=%1
set arch=%2

set "path=%path%;C:\Python\%ver%\%arch%\Scripts"
set "path=%path%;C:\Program Files\Mercurial"
set "path=%path%;C:\Program Files (x86)\CMake\bin"

cd C:\Users\vagrant\build

mkdir %ver%\%arch%
cd %ver%\%arch%

virtualenv --system-site-packages .
call Scripts\activate.bat

hg clone /vagrant/libyaml
hg clone /vagrant/pyyaml

cd libyaml
mkdir build
cd build

if "%ver%"=="27" (
    set msvc=msvc9
)

if "%ver%"=="34" (
    set msvc=msvc10
)

if "%ver%"=="35" (
    set msvc=msvc14
)

if "%msvc%"=="msvc9" (
    set "path=%path%;C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin"
    set "generator=NMake Makefiles"
)

if "%msvc%"=="msvc10" (
    set "path=%path%;C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin"
    set "generator=Visual Studio 10 2010"
)

if "%msvc%"=="msvc14" (
    set "generator=Visual Studio 14 2015"
)

if "%arch%"=="x86" (
    set target=x86
)

if "%arch%"=="amd64" (
    set target=x64
    if not "%msvc%"=="msvc9" (
        set "generator=%generator% Win64"
    )
)

if not "%msvc%"=="msvc14" (
    set DISTUTILS_USE_SDK=1
    setlocal enableextensions
    setlocal enabledelayedexpansion
    call SetEnv.Cmd "/%target%" "/Release"
)

cmake.exe -G "%generator%" -D CMAKE_BUILD_TYPE=Release ..
cmake.exe --build . --config Release

cd ..\..\pyyaml

python setup.py --with-libyaml build_ext -I ..\libyaml\include -L ..\libyaml\build;..\libyaml\build\Release -D YAML_DECLARE_STATIC build test bdist_wininst bdist_wheel

copy dist\* C:\vagrant\dist\windows

