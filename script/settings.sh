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

# git bash on windows: set USER from USERNAME
if [ -z "${USER:-}" ]; then
    USER="${USERNAME,,}"
fi

# shellcheck disable=SC2034
ENV=${ENV:-d}

# shellcheck disable=SC2034
STACK="${STACK:-$USER}"

# shellcheck disable=SC2034
TRY_INSTALL_REQUIREMENTS=${TRY_INSTALL_REQUIREMENTS:-0}

# shellcheck disable=SC2034
DOCKER_ORGANIZATION="${DOCKER_ORGANIZATION:-lsimons}"
# shellcheck disable=SC2034
DOCKER_IMAGE="${DOCKER_IMAGE:-${DOCKER_ORGANIZATION}/devcontainer-tsazure}"
