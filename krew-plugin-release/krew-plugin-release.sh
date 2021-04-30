#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
# shellcheck source=command.sh
source "${SCRIPT_ROOT}/../command.sh"

echoinfo "Tools information"
exec_command git --version
exec_command gh --version

if [[ -z "$PLUGIN_VERSION" ]]; then
  echoinfo "Detect the release version of ${PLUGIN_NAME}"
  PLUGIN_VERSION="$(cd "$GITHUB_WORKSPACE" | git describe --tag)"
  echoinfo "The release version is ${PLUGIN_NAME}"
fi

cd "$(mktemp -d)"
echoinfo "Create a fork of $KREW_INDEX_REPO and clone it"
exec_command gh repo fork "$KREW_INDEX_REPO" --clone --remote
exec_command cd krew-index
exec_command git remote remove upstream

branch_name="${PLUGIN_NAME}-${PLUGIN_VERSION}"
echoinfo "Switch to branch ${branch_name}"
exec_command git checkout -b "$branch_name"

echoinfo "Copy the manifest file"
exec_command cp "${GITHUB_WORKSPACE}/${MANIFEST_PATH}" plugins/
exec_command git --no-pager diff

echoinfo "Set git user configs"
exec_command git config user.name "$GIT_AUTHOR_NAME"
exec_command git config user.email "$GIT_AUTHOR_EMAIL"

echoinfo "Create a git commit"
exec_command git commit -a -m "Bump the version of ${PLUGIN_NAME} to ${PLUGIN_VERSION}"

echoinfo "Update git remote url with token"
remote_url_with_token="$(get_remote_url_with_token origin "$GITHUB_TOKEN")"
exec_command git remote set-url origin "$remote_url_with_token"

echoinfo "Push a git commit to the remote"
exec_command git push origin "$branch_name"

echoinfo "Create a pull request"
exec_command gh pr create \
  --title "Bump the version of ${PLUGIN_NAME} to ${PLUGIN_VERSION}" \
  --body "This PR bumps the version of ${PLUGIN_NAME} to ${PLUGIN_VERSION}." \
  --repo "$KREW_INDEX_REPO"
# vim: ai ts=2 sw=2 et sts=2 ft=sh
