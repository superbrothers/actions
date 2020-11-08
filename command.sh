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
# vim: ai ts=2 sw=2 et sts=2 ft=sh
