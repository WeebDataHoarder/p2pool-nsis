#!/bin/bash

set -ex

export P2POOL_VERSION="v1.5"
export MONERO_VERSION="v0.17.3.0"

export SOURCE_DATE_EPOCH="$(date +%s)"
export GIT_HASH="0000000"

if [[ "${1}" != "" ]]; then
    export SOURCE_DATE_EPOCH="${1}"
fi

if [[ "${2}" != "" ]]; then
    export GIT_HASH="${2}"
fi

if [[ "${3}" != "" ]]; then
    export P2POOL_VERSION="${3}"
fi

rm -rvf /build/*

mkdir output

FOLDER_NAME="p2pool-${P2POOL_VERSION}-windows-x64"
MONERO_FILE_NAME="monero-win-x64-${MONERO_VERSION}.zip"
MONERO_FOLDER_NAME="monero-x86_64-w64-mingw32-${MONERO_VERSION}"

curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/${FOLDER_NAME}.zip" --location --output "${FOLDER_NAME}.zip"
curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/sha256sums.txt.asc" --location --output "sha256sums.txt.asc"
curl "https://downloads.getmonero.org/cli/${MONERO_FILE_NAME}" --location --output "${MONERO_FILE_NAME}"

gpg --verify "sha256sums.txt.asc"

if [[ $(grep -iF $(sha256sum "${FOLDER_NAME}.zip"  | awk '{print $1}') sha256sums.txt.asc) == "" ]]; then
  echo "P2Pool Signatures do not match (got $(sha256sum "${FOLDER_NAME}".zip))"
  exit 1
fi

gpg --verify "/hashes.txt"

if [[ $(grep -iF $(sha256sum "${MONERO_FILE_NAME}"  | awk '{print $1}') /hashes.txt) == "" ]]; then
  echo "Monero Signatures do not match"
  exit 1
fi

unzip "${FOLDER_NAME}.zip"

pushd "${FOLDER_NAME}"
cp p2pool.exe ../output/

popd
curl "https://raw.githubusercontent.com/SChernykh/p2pool/${P2POOL_VERSION}/LICENSE" --location --output "output/p2pool.LICENSE"


unzip "${MONERO_FILE_NAME}"

pushd "${MONERO_FOLDER_NAME}"
cp monerod.exe ../output/
cp LICENSE ../output/monero.LICENSE

popd

pushd output

cp /start.ps1 ./
cp /header.bmp ./
cp /welcome.bmp ./
cp /icon.ico ./
cp /p2pool.nsi ./
cp -r /config ./

#Set mtime for reproducible builds
for f in ./*; do
  touch --date="@${SOURCE_DATE_EPOCH}" "$f"
done

makensis -V4 "p2pool.nsi"

cp "${FOLDER_NAME}-installer_${GIT_HASH}.exe" /build/