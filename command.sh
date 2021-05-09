#!/usr/bin/env bash

function echoinfo() {
  echo -e "\u001b[38;5;6m$*\033[0m"
}

function echoerror() {
  echo -e "::error::$*"
}

function echowarning() {
  echo -e "::warning::$*"
}

function exec_command() {
  echo -e "\u001b[93;5;6m$ $*\033[0m"
  "$@"
}

function get_remote_url_with_token() {
  local remote="$1"
  local token="$2"

  git remote get-url "$remote" | sed -e "s#https://#https://x-access-token:${token}@#"
}

function yaml2json() {
  if ! which python3 >/dev/null 2>&1; then
    echo "$0 requires python3" >&2
    exit 1
  fi

  cat | python3 -c 'import sys, yaml, json; y=yaml.safe_load(sys.stdin.read()); print(json.dumps(y))'
}
# vim: ai ts=2 sw=2 et sts=2 ft=sh
