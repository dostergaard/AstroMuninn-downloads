#!/usr/bin/env bash

set -euo pipefail

APP_NAME="AstroMuninn"
BIN_NAME="astromuninn"
DOWNLOADS_REPO="dostergaard/AstroMuninn-downloads"
DOWNLOADS_BRANCH="main"
LATEST_METADATA_URL="https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/latest.json"
DEFAULT_INSTALL_DIR="${HOME}/.local/bin"
DEFAULT_METADATA_DIR="${HOME}/.local/share/ravensky/astromuninn"

usage() {
  cat <<EOF
Install ${APP_NAME} from ${DOWNLOADS_REPO}.

Usage: install.sh [options]

Options:
  --version <tag>       Install a specific version, for example v0.9.1 or cli-v0.9.1
  --install-dir <dir>   Install the binary into this directory
  --no-modify-path      Do not update shell profile PATH entries
  --uninstall           Remove the installed binary and metadata
  -h, --help            Show this help
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

detect_os_arch() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin)
      case "$arch" in
        arm64|aarch64)
          asset_name="${APP_NAME}-VERSION-macos-apple-silicon.tar.gz"
          ;;
        *)
          fail "${APP_NAME} currently supports only Apple Silicon on macOS."
          ;;
      esac
      ;;
    Linux)
      case "$arch" in
        x86_64|amd64)
          asset_name="${APP_NAME}-VERSION-linux-x86_64.tar.gz"
          ;;
        *)
          fail "${APP_NAME} currently supports only x86_64 on Linux."
          ;;
      esac
      ;;
    *)
      fail "Unsupported operating system: $os"
      ;;
  esac
}

detect_hash_cmd() {
  if command -v shasum >/dev/null 2>&1; then
    hash_cmd="shasum -a 256"
  elif command -v sha256sum >/dev/null 2>&1; then
    hash_cmd="sha256sum"
  elif command -v openssl >/dev/null 2>&1; then
    hash_cmd="openssl dgst -sha256"
  else
    fail "No SHA256 tool found. Install shasum, sha256sum, or openssl."
  fi
}

latest_release_tag() {
  local metadata_json
  metadata_json="$(curl -fsSL "$LATEST_METADATA_URL" | tr -d '\n')"
  version_tag="$(printf '%s' "$metadata_json" | sed -n 's/.*"tag"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  [[ -n "$version_tag" ]] || fail "Unable to resolve the latest CLI release metadata from ${LATEST_METADATA_URL}"
}

release_tag_to_public_tag() {
  local release_tag="$1"
  case "$release_tag" in
    cli-v*) printf 'v%s\n' "${release_tag#cli-v}" ;;
    v*) printf '%s\n' "$release_tag" ;;
    *)
      fail "Unsupported AstroMuninn CLI release tag: $release_tag"
      ;;
  esac
}

normalize_version_tag() {
  if [[ -z "${version_tag:-}" ]]; then
    latest_release_tag
  elif [[ "${version_tag}" != v* && "${version_tag}" != cli-v* ]]; then
    version_tag="v${version_tag}"
  fi
}

download_file() {
  local url="$1"
  local destination="$2"
  curl -fsSL --retry 3 --retry-delay 1 -o "$destination" "$url"
}

expected_sha_for_asset() {
  local checksum_file="$1"
  local asset="$2"
  awk -v asset="$asset" '$2 == asset { print $1; exit }' "$checksum_file"
}

actual_sha_for_file() {
  local file="$1"
  case "$hash_cmd" in
    "shasum -a 256")
      shasum -a 256 "$file" | awk '{print $1}'
      ;;
    "sha256sum")
      sha256sum "$file" | awk '{print $1}'
      ;;
    *)
      openssl dgst -sha256 "$file" | awk '{print $NF}'
      ;;
  esac
}

choose_profile() {
  case "${SHELL##*/}" in
    zsh) profile_file="${HOME}/.zprofile" ;;
    bash)
      if [[ "$(uname -s)" == "Darwin" ]]; then
        profile_file="${HOME}/.bash_profile"
      else
        profile_file="${HOME}/.profile"
      fi
      ;;
    *)
      profile_file="${HOME}/.profile"
      ;;
  esac
}

ensure_path_entry() {
  local dir="$1"
  choose_profile
  local export_line="export PATH=\"${dir}:\$PATH\""

  if [[ ":$PATH:" == *":${dir}:"* ]]; then
    return 0
  fi

  if [[ "${modify_path}" == "0" ]]; then
    printf '%s was installed to %s.\n' "${APP_NAME}" "$dir"
    printf 'Add this directory to PATH before running %s.\n' "$BIN_NAME"
    return 0
  fi

  touch "$profile_file"
  if ! grep -Fqs "$export_line" "$profile_file"; then
    printf '\n# Added by AstroMuninn installer\n%s\n' "$export_line" >> "$profile_file"
  fi

  printf 'Updated %s to add %s to PATH.\n' "$profile_file" "$dir"
}

find_binary() {
  local root="$1"
  find "$root" -type f -name "$BIN_NAME" | head -n 1
}

uninstall_binary() {
  local target="${install_dir}/${BIN_NAME}"
  rm -f "$target"
  rm -rf "$metadata_dir"
  printf 'Removed %s from %s\n' "${APP_NAME}" "$target"
  printf 'If you no longer want %s on PATH, remove %s from your shell profile manually.\n' "$install_dir" "$install_dir"
}

version_tag=""
install_dir="$DEFAULT_INSTALL_DIR"
metadata_dir="$DEFAULT_METADATA_DIR"
modify_path="1"
uninstall="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      version_tag="$2"
      shift 2
      ;;
    --install-dir)
      install_dir="$2"
      shift 2
      ;;
    --no-modify-path)
      modify_path="0"
      shift
      ;;
    --uninstall)
      uninstall="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

need_cmd curl
need_cmd tar
detect_hash_cmd

if [[ "$uninstall" == "1" ]]; then
  uninstall_binary
  exit 0
fi

normalize_version_tag
public_version_tag="$(release_tag_to_public_tag "$version_tag")"
detect_os_arch
asset_name="${asset_name/VERSION/${public_version_tag}}"

release_base="https://github.com/${DOWNLOADS_REPO}/releases/download/${version_tag}"
archive_url="${release_base}/${asset_name}"
checksum_url="${release_base}/SHA256SUMS.txt"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

archive_path="${tmpdir}/${asset_name}"
checksum_path="${tmpdir}/SHA256SUMS.txt"
extract_dir="${tmpdir}/extract"

mkdir -p "$extract_dir" "$install_dir" "$metadata_dir"

printf 'Downloading %s %s\n' "${APP_NAME}" "${version_tag}"
download_file "$checksum_url" "$checksum_path"
download_file "$archive_url" "$archive_path"

expected_sha="$(expected_sha_for_asset "$checksum_path" "$asset_name")"
[[ -n "$expected_sha" ]] || fail "Unable to find checksum for ${asset_name}"

actual_sha="$(actual_sha_for_file "$archive_path")"
[[ "$expected_sha" == "$actual_sha" ]] || fail "SHA256 mismatch for ${asset_name}"

tar -xzf "$archive_path" -C "$extract_dir"
binary_path="$(find_binary "$extract_dir")"
[[ -n "$binary_path" ]] || fail "Unable to locate ${BIN_NAME} after extracting ${asset_name}"

install_path="${install_dir}/${BIN_NAME}"
cp "$binary_path" "$install_path"
chmod 0755 "$install_path"

cat > "${metadata_dir}/install-info.txt" <<EOF
version=${public_version_tag}
release_tag=${version_tag}
installed_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
install_dir=${install_dir}
downloads_repo=${DOWNLOADS_REPO}
EOF

ensure_path_entry "$install_dir"

printf '%s installed to %s\n' "${APP_NAME}" "$install_path"
printf 'Run `%s --help` to verify the install.\n' "$BIN_NAME"
