#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
# shellcheck source=command.sh
source "${SCRIPT_ROOT}/../command.sh"

echoinfo "Tools information"
exec_command git --version
exec_command gh --version

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echoerror "$MANIFEST_PATH does not exist"
  exit 1
fi
echoinfo "Detect the plugin name from the manifest file: ${MANIFEST_PATH}"
plugin_name="$(yaml2json <"$MANIFEST_PATH" | jq -r ".metadata.name")"
if [[ -z "$plugin_name" ]]; then
  echoerror "failed to detect the plugin name"
  exit 1
fi
echoinfo "The plugin name is ${plugin_name}"

if [[ -z "$PLUGIN_VERSION" ]]; then
  echoinfo "Detect the release version of ${plugin_name}"
  PLUGIN_VERSION="$(cd "$GITHUB_WORKSPACE" | git describe --tag)"
  echoinfo "The release version is ${PLUGIN_VERSION}"
fi

cd "$(mktemp -d)"
echoinfo "Create a fork of $KREW_INDEX_REPO and clone it"
exec_command gh repo fork "$KREW_INDEX_REPO" --clone --remote
exec_command cd krew-index

branch_name="${plugin_name}-${PLUGIN_VERSION}"
echoinfo "Switch to branch ${branch_name}"
exec_command git checkout -b "$branch_name" upstream/master

echoinfo "Remove the remote 'upstream'"
exec_command git remote remove upstream

echoinfo "Copy the manifest file"
exec_command cp "${GITHUB_WORKSPACE}/${MANIFEST_PATH}" plugins/
exec_command git --no-pager diff

echoinfo "Set git user configs"
exec_command git config user.name "$GIT_AUTHOR_NAME"
exec_command git config user.email "$GIT_AUTHOR_EMAIL"

echoinfo "Create a git commit"
exec_command git commit -a -m "Bump the version of ${plugin_name} to ${PLUGIN_VERSION}"

echoinfo "Update git remote url with token"
remote_url_with_token="$(get_remote_url_with_token origin "$GITHUB_TOKEN")"
exec_command git remote set-url origin "$remote_url_with_token"

echoinfo "Push a git commit to the remote"
exec_command git push origin "$branch_name"

echoinfo "Create a pull request"
exec_command gh pr create \
  --title "Bump the version of ${plugin_name} to ${PLUGIN_VERSION}" \
  --body "This PR bumps the version of ${plugin_name} to ${PLUGIN_VERSION}." \
  --repo "$KREW_INDEX_REPO"
# vim: ai ts=2 sw=2 et sts=2 ft=sh
