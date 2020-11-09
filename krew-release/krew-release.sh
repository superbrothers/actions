#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
source "${SCRIPT_ROOT}/../command.sh"

# vim: ai ts=2 sw=2 et sts=2 ft=sh
