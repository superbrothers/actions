#!/usr/bin/env bash

set -e -o pipefail; [[ -n "$DEBUG" ]] && set -x

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd)"
source "${SCRIPT_ROOT}/../command.sh"

if [[ -z "$TOKEN" ]]; then
  echoerror "Input required and not supplied: token"
  exit 1
fi

if [[ -z "$MANIFEST" ]]; then
  echoerror "Input required and not supplied: manifest"
  exit 1
fi

if [[ -z "$VERSION" ]];then
  echoerror "Input required and not supplied: version"
  exit 1
fi
# If GITHUB_REF is used, the git tag name is used as as the version.
# refs/tags/v1.0.0 => v1.0.0
VERSION="${VERSION##*/}"

if [[ -f "$MANIFEST" ]]; then
  echoerror "$MANIFEST does not exist"
  exit 1
fi

if [[ -z "$COMMITTER_NAME" ]]; then
  echoerror "Input required and not supplied: committer_name"
  exit 1
fi

if [[ -z "$COMMITTER_EMAIL" ]]; then
  echoerror "Input required and not supplied: committer_email"
  exit 1
fi

if [[ -z "$AUTHOR_NAME" ]]; then
  echoinfo "'author_name' is not supplied, so 'committer_name' is used"
  AUTHOR_NAME="$COMMITTER_NAME"
fi

if [[ -z "$AUTHOR_EMAIL" ]]; then
  echoinfo "'author_email' is not supplied, so 'committer_email' is used"
  AUTHOR_EMAIL="$COMMITTER_EMAIL"
fi

plugin_name="$(basename "$MANIFEST" .yaml)"

# Display the information
echoinfo "The plugin name is '${plugin_name}'"
echoinfo "The plugin version is ${VERSION}"
echoinfo "The git upstream repository is ${UPSTREAM}."
echoinfo "The git committer is ${COMMITTER_NAME} <${COMMITTER_EMAIL}>"
echoinfo "The git author is ${AUTHOR_NAME} <${AUTHOR_EMAIL}>"

# The absolute path of the plugin manifest file
abs_manifest="$(cd "$(dirname "$MANIFEST")"; pwd)/$(basename "$MANIFEST")"

cd "$(mktemp -d)"
echoinfo "Fork and clone the upstream repository..."
exec_command "gh repo fork ${UPSTREAM} --clone=true"

# Change the working directory to the cloned git repository
repo_dir="$(basename "$UPSTREAM" .git)"
exec_command "cd ${repo_dir}"

# Set The git committer and author
exec_command "git config --add user.name '${COMMITTER_NAME}'"
exec_command "git config --add user.email '${COMMITTER_EMAIL}'"

# Change the git branch
branch_name="${plugin_name}-${VERSION}"
exec_command "git checkout -b ${branch_name}"


KREW_PLUGINS_DIR="plugins"

# Copy the plugin manifest file to the plugins directory
exec_command "mkdir -p ${KREW_PLUGINS_DIR}"
exec_command "cp ${abs_manifest} ${KREW_PLUGINS_DIR}"

# Display the difference from the upstream repository
exec_command "git --no-pager diff"

# Create a git commit
commit_msg="Bump the version of ${plugin_name} to ${VERSION}"
exec_command "git add ${KREW_PLUGINS_DIR}"
exec_command "git commit --message '${commit_msg}' --author '${AUTHOR_NAME} <${AUTHOR_EMAIL}>'"

# Push the git commit to the origin repository
exec_command "git push origin ${branch_name}"

# Create a Pull Request
# TODO
# vim: ai ts=2 sw=2 et sts=2 ft=sh
