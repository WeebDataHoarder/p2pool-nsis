#!/bin/bash

set -ex

export P2POOL_VERSION="v1.2"
#export XMRIG_VERSION="6.15.1"

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

curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/${FOLDER_NAME}.zip" --location --output "${FOLDER_NAME}.zip"
curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/sha256sums.txt.asc" --location --output "sha256sums.txt.asc"

gpg --verify "sha256sums.txt.asc"

if [[ $(grep -iF $(sha256sum "${FOLDER_NAME}.zip"  | awk '{print $1}') sha256sums.txt.asc) == "" ]]; then
  echo "Signatures do not match"
  exit 1
fi

unzip "${FOLDER_NAME}.zip"

pushd "${FOLDER_NAME}"
cp p2pool.exe ../output/
cp Monero/monerod.exe ../output/
cp Monero/LICENSE ../output/monero.LICENSE

popd

curl "https://raw.githubusercontent.com/SChernykh/p2pool/${P2POOL_VERSION}/LICENSE" --location --output "output/p2pool.LICENSE"

#
#XMRIG_FOLDER_NAME="xmrig-${XMRIG_VERSION}-msvc-win64"
#curl "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/${XMRIG_FOLDER_NAME}.zip" --location --output "${XMRIG_FOLDER_NAME}.zip"
#curl "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/SHA256SUMS" --location --output "SHA256SUMS"
#curl "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/SHA256SUMS.sig" --location --output "SHA256SUMS.asc"
#gpg --verify "SHA256SUMS.sig" "SHA256SUMS"
#
#sha256sum "${XMRIG_FOLDER_NAME}.zip"
#
#if [[ $(grep $(sha256sum "${XMRIG_FOLDER_NAME}.zip"  | awk '{print $1}') SHA256SUMS) == "" ]]; then
#  echo "Signatures do not match"
#  exit 1
#fi
#
#unzip "${XMRIG_FOLDER_NAME}.zip"
#
#pushd "${XMRIG_FOLDER_NAME}"
#cp p2pool.exe ../output/
#cp Monero/monerod.exe ../output/
#cp Monero/LICENSE ../output/monero.LICENSE
#
#popd

pushd output

cp /start.ps1 ./
cp /header.bmp ./
cp /welcome.bmp ./
cp /icon.ico ./
cp /p2pool.nsi ./

#Set mtime for reproducible builds
for f in ./*; do
  touch --date="@${SOURCE_DATE_EPOCH}" "$f"
done

makensis -V4 "p2pool.nsi"

cp "${FOLDER_NAME}-installer_${GIT_HASH}.exe" /build/