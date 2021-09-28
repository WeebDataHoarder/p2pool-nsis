#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm -rf build/test
mkdir build/test

./build.sh
cp build/nsis/*.exe build/test/a.exe

./build.sh
cp build/nsis/*.exe build/test/b.exe

sha256sum build/test/a.exe
sha256sum build/test/b.exe

diff --speed-large-files --minimal --suppress-common-lines -y <(xxd build/test/a.exe) <(xxd build/test/b.exe)