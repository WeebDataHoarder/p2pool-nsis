#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker build --tag p2pool-nsis-builder --file ./docker/nsis/Dockerfile ./docker/nsis/
docker run --rm --tmpfs /tmp --volume "${SCRIPT_DIR}/build/nsis:/build" p2pool-nsis-builder