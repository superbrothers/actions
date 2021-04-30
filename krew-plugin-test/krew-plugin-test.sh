#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
# shellcheck source=command.sh
source "${SCRIPT_ROOT}/../command.sh"

if [[ -z "$COMMAND" ]]; then
  echoerror "Input required and not supplied: command"
  exit 1
fi

args=()
if [[ -n "$PLUGIN" ]]; then
  args+=("$PLUGIN")
fi

if [[ -n "$ARCHIVE" ]]; then
  args+=("--archive" "$ARCHIVE")
fi

if [[ -n "$MANIFEST" ]]; then
  args+=("--manifest" "$MANIFEST")
fi

if [[ -n "$MANIFEST_URL" ]]; then
  args+=("--manifest-url" "$MANIFEST_URL")
fi

exec_command kubectl krew install "${args[@]}"

IFS=" " read -r -a COMMAND <<< "$COMMAND"
exec_command "${COMMAND[@]}"
# vim: ai ts=2 sw=2 et sts=2 ft=sh
