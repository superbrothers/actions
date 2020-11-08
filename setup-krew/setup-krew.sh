#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
source "${SCRIPT_ROOT}/../command.sh"

if ! which kubectl >/dev/null 2>&1; then
  echoerror "kubectl command is required to use this action"
  exit 1
fi

if which kubectl-krew >/dev/null 2>&1; then
  echowarning "kubectl krew command is already installed"
  exit
fi

cd "$(mktemp -d)"
exec_command curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz"
exec_command tar zxvf krew.tar.gz
KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')"
exec_command "$KREW" install krew
KREW_BIN="${KREW_ROOT:-$HOME/.krew}/bin"
export PATH="$KREW_BIN:$PATH"
exec_command kubectl krew version
echo "$KREW_BIN" >> "$GITHUB_PATH"
# vim: ai ts=2 sw=2 et sts=2 ft=sh
