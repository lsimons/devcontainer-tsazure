#!/usr/bin/env bash
#
# 2019 September 1
#
# The author disclaims copyright to this source code.  In place of
# a legal notice, here is a blessing:
#
#    May you do good and not evil.
#    May you find forgiveness for yourself and forgive others.
#    May you share freely, never taking more than you give.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR/.." || exit 127
source "script/common.sh"

# shellcheck disable=SC2034
VCS_REF=${VCS_REF:-$(git describe --tags --dirty)}

# shellcheck disable=SC2034
VERSION=${VERSION:-${VCS_REF}}

docker build \
    --build-arg "BUILD_DATE=$(date -Iseconds)" \
    --build-arg "VCS_REF=${VCS_REF}" \
    --build-arg "IMAGE_NAME=${DOCKER_IMAGE}" \
    --build-arg "IMAGE_VERSION=${VERSION}" \
    --tag "${DOCKER_IMAGE}:latest" \
    --tag "${DOCKER_IMAGE}:${VERSION}" \
    .
