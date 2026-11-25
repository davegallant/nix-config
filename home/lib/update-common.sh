#!/usr/bin/env bash
# Helpers sourced by the update-hashes.sh scripts. Needs GNU sed (`sed -i`) and jq.

# without this, a failed curl inside $(...) yields an empty value instead of exiting
shopt -s inherit_errexit

# current_version <package.nix>: the first `version = "...";`
current_version() {
  grep -m1 'version = ' "$1" | sed 's/.*version = "\([^"]*\)".*/\1/'
}

# skip_if_current <package.nix> <version>: exit the script when already at <version>;
# FORCE=1 refetches the hashes anyway
skip_if_current() {
  if [[ -z "${FORCE:-}" && "$(current_version "$1")" == "$2" ]]; then
    echo "already at $2, skipping (FORCE=1 to refetch hashes)"
    exit 0
  fi
}

# set_version <package.nix> <version>: rewrite the first `version = "...";`
set_version() {
  local file="$1" version="$2" current
  if [[ ! "$version" =~ ^[0-9A-Za-z._-]+$ ]]; then
    echo "refusing to set invalid version '${version}' in ${file}" >&2
    exit 1
  fi
  current=$(current_version "$file")
  if [[ "$current" != "$version" ]]; then
    echo "updating version: ${current} -> ${version}"
    sed -i "s|version = \"${current}\";|version = \"${version}\";|" "$file"
  fi
}

# github_release <owner/repo> <tag-prefix> [version]: fetch the release (latest when no
# version), setting RELEASE_JSON and VERSION (tag without the prefix)
github_release() {
  local repo="$1" prefix="$2" version="${3:-}" path=latest
  [[ -n "$version" ]] && path="tags/${prefix}${version}"
  echo "fetching release ${path} from github.com/${repo}..." >&2
  RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/${path}")
  VERSION=$(jq -er '.tag_name' <<<"$RELEASE_JSON")
  VERSION="${VERSION#"$prefix"}"
  echo "version: ${VERSION}"
}

# release_sri <asset> <url>: SRI hash from the release's published sha256 digest, so
# the asset is not downloaded; falls back to downloading when there is no digest
release_sri() {
  local asset="$1" url="$2" digest
  digest=$(jq -r --arg n "$asset" '.assets[] | select(.name == $n) | .digest // empty' <<<"$RELEASE_JSON")
  if [[ "$digest" == sha256:* ]]; then
    nix hash convert --hash-algo sha256 --to sri "${digest#sha256:}"
  else
    sri "$url"
  fi
}

# sri <url>: SRI sha256 hash of the downloaded file
sri() {
  local url="$1" hash
  echo "  downloading ${url##*/} to hash it..." >&2
  hash=$(curl -fsSL "$url" | openssl dgst -sha256 -binary | openssl base64)
  echo "sha256-${hash}"
}
