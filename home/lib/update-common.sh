#!/usr/bin/env bash
# Helpers sourced by the update-hashes.sh scripts. Needs GNU sed (`sed -i`).

# latest_github_tag <owner/repo> <tag-prefix>: latest release tag without the prefix
latest_github_tag() {
  local repo="$1" prefix="$2"
  echo "fetching latest release from github.com/${repo}..." >&2
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name"' \
    | sed "s/.*\"tag_name\": *\"\(${prefix}\)\?\([^\"]*\)\".*/\2/"
}

# sri <url>: SRI sha256 hash of the downloaded file
sri() {
  local url="$1" hash
  echo "  fetching ${url##*/}..." >&2
  hash=$(curl -fsSL "$url" | openssl dgst -sha256 -binary | openssl base64)
  echo "sha256-${hash}"
}

# set_version <package.nix> <version>: rewrite the first `version = "...";`
set_version() {
  local file="$1" version="$2" current
  current=$(grep 'version = ' "$file" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
  if [[ "$current" == "$version" ]]; then
    echo "version unchanged (${version}), updating hashes only"
  else
    echo "updating version: ${current} -> ${version}"
    sed -i "s|version = \"${current}\";|version = \"${version}\";|" "$file"
  fi
}
