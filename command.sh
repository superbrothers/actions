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
  echoinfo "$ $*"
  "$@"
}

function get_remote_url_with_token() {
  local remote="$1"
  local token="$2"

  git remote get-url "$remote" | sed -e "s#https://#https://x-access-token:${token}@#"
}
# vim: ai ts=2 sw=2 et sts=2 ft=sh
