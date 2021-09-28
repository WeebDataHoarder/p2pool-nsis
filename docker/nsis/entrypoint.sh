#!/bin/bash

set -ex

export P2POOL_VERSION="v1.0"

if [[ "${1}" != "" ]]; then
    export P2POOL_VERSION="${1}"
fi

rm -rvf /build/*

FOLDER_NAME="p2pool-${P2POOL_VERSION}-windows-x64"

curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/${FOLDER_NAME}.zip" --location --output "${FOLDER_NAME}.zip"
curl "https://github.com/SChernykh/p2pool/releases/download/${P2POOL_VERSION}/sha256sums.txt.asc" --location --output "sha256sums.txt.asc"

gpg --verify "sha256sums.txt.asc"

unzip "${FOLDER_NAME}"

pushd "${FOLDER_NAME}"


curl "https://raw.githubusercontent.com/SChernykh/p2pool/${P2POOL_VERSION}/LICENSE" --location --output "LICENSE"

cp /start.ps1 ./
cp /header.bmp ./
cp /welcome.bmp ./

makensis -NOCD -V4 "/p2pool.nsi"

cp "${FOLDER_NAME}-installer.exe" /build/