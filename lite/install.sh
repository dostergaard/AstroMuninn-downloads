#!/usr/bin/env bash

set -euo pipefail

APP_NAME="AstroMuninn Lite"
APP_ASSET_PREFIX="AstroMuninn-Lite"
DOWNLOADS_REPO="dostergaard/AstroMuninn-downloads"
DOWNLOADS_BRANCH="main"
LATEST_METADATA_URL="https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/latest.json"
DEFAULT_METADATA_DIR="${HOME}/.local/share/ravensky/astromuninn-lite"

usage() {
  cat <<EOF
Install ${APP_NAME} from ${DOWNLOADS_REPO}.

Usage: install-lite.sh [options]

Options:
  --version <tag>       Install a specific version, for example lite-v0.2.0 or v0.2.0
  --install-dir <dir>   Install into this directory (default: ~/Applications on macOS, ~/.local/bin on Linux)
  --no-modify-path      Do not update shell profile PATH entries on Linux installs
  --uninstall           Remove the installed app or AppImage wrapper
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
      platform="macos"
      case "$arch" in
        arm64|aarch64)
          asset_name="${APP_ASSET_PREFIX}-VERSION-macos-apple-silicon.dmg"
          default_install_dir="${HOME}/Applications"
          ;;
        *)
          fail "${APP_NAME} currently supports only Apple Silicon on macOS."
          ;;
      esac
      need_cmd hdiutil
      need_cmd ditto
      ;;
    Linux)
      platform="linux"
      case "$arch" in
        x86_64|amd64)
          asset_name="${APP_ASSET_PREFIX}-VERSION-linux-x86_64.AppImage"
          default_install_dir="${HOME}/.local/bin"
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
  [[ -n "$version_tag" ]] || fail "Unable to resolve the latest Lite release metadata from ${LATEST_METADATA_URL}"
}

release_tag_to_public_tag() {
  local release_tag="$1"
  case "$release_tag" in
    lite-v*) printf 'v%s\n' "${release_tag#lite-v}" ;;
    v*) printf '%s\n' "$release_tag" ;;
    *)
      fail "Unsupported AstroMuninn Lite release tag: $release_tag"
      ;;
  esac
}

normalize_version_tag() {
  if [[ -z "${version_tag:-}" ]]; then
    latest_release_tag
    return
  fi

  case "$version_tag" in
    lite-v*|v*) ;;
    *)
      version_tag="v${version_tag}"
      ;;
  esac

  if [[ "$version_tag" == v* ]]; then
    version_tag="lite-${version_tag}"
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
    printf 'Add this directory to PATH before launching %s from a shell.\n' "$APP_NAME"
    return 0
  fi

  touch "$profile_file"
  if ! grep -Fqs "$export_line" "$profile_file"; then
    printf '\n# Added by AstroMuninn Lite installer\n%s\n' "$export_line" >> "$profile_file"
  fi

  printf 'Updated %s to add %s to PATH.\n' "$profile_file" "$dir"
}

cleanup_mount() {
  if [[ -n "${mounted_device:-}" ]]; then
    hdiutil detach "$mounted_device" >/dev/null 2>&1 || true
    mounted_device=""
  fi
}

install_macos_app() {
  local dmg_path="$1"
  local target_dir="$2"
  local attach_output mount_dir source_app target_app

  mkdir -p "$target_dir" "$metadata_dir"

  attach_output="$(hdiutil attach "$dmg_path" -nobrowse -readonly)"
  mounted_device="$(printf '%s\n' "$attach_output" | awk -F '\t' '/^\/dev\// { device=$1 } END { print device }')"
  mount_dir="$(printf '%s\n' "$attach_output" | awk -F '\t' '/^\/dev\// { volume=$NF } END { print volume }')"

  [[ -n "$mounted_device" && -n "$mount_dir" ]] || fail "Unable to mount ${dmg_path}"

  source_app="$(find "$mount_dir" -maxdepth 1 -type d -name '*.app' | head -n 1)"
  [[ -n "$source_app" ]] || fail "Unable to locate the .app bundle in the mounted disk image"

  target_app="${target_dir}/$(basename "$source_app")"
  rm -rf "$target_app"
  ditto "$source_app" "$target_app"

  if command -v xattr >/dev/null 2>&1; then
    xattr -dr com.apple.quarantine "$target_app" >/dev/null 2>&1 || true
  fi

  cleanup_mount

  cat > "${metadata_dir}/install-info.txt" <<EOF
version=${public_version_tag}
release_tag=${version_tag}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
install_dir=${target_dir}
downloads_repo=${DOWNLOADS_REPO}
EOF

  printf '%s installed to %s\n' "${APP_NAME}" "$target_app"
  printf 'Launch it from Finder or run:\n'
  printf '  open "%s"\n' "$target_app"
}

install_linux_appimage() {
  local appimage_path="$1"
  local target_dir="$2"
  local target_path="${target_dir}/astromuninn-lite"

  mkdir -p "$target_dir" "$metadata_dir"
  cp "$appimage_path" "$target_path"
  chmod +x "$target_path"

  cat > "${metadata_dir}/install-info.txt" <<EOF
version=${public_version_tag}
release_tag=${version_tag}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
install_dir=${target_dir}
downloads_repo=${DOWNLOADS_REPO}
EOF

  ensure_path_entry "$target_dir"

  printf '%s installed to %s\n' "${APP_NAME}" "$target_path"
  printf 'Launch it with:\n'
  printf '  astromuninn-lite\n'
}

uninstall_target() {
  case "$platform" in
    macos)
      local target_app="${install_dir}/${APP_NAME}.app"
      rm -rf "$target_app"
      ;;
    linux)
      rm -f "${install_dir}/astromuninn-lite"
      ;;
  esac

  rm -rf "$metadata_dir"
  printf 'Removed %s from %s\n' "${APP_NAME}" "$install_dir"
  printf 'The shared AstroMuninn config file is not removed automatically.\n'
}

version_tag=""
install_dir=""
metadata_dir="$DEFAULT_METADATA_DIR"
modify_path="1"
uninstall="0"
platform=""
asset_name=""
default_install_dir=""
mounted_device=""

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

trap cleanup_mount EXIT

need_cmd curl
detect_hash_cmd
detect_os_arch

if [[ -z "$install_dir" ]]; then
  install_dir="$default_install_dir"
fi

if [[ "$uninstall" == "1" ]]; then
  uninstall_target
  exit 0
fi

normalize_version_tag
public_version_tag="$(release_tag_to_public_tag "$version_tag")"
asset_name="${asset_name/VERSION/${public_version_tag}}"

release_base="https://github.com/${DOWNLOADS_REPO}/releases/download/${version_tag}"
archive_url="${release_base}/${asset_name}"
checksum_url="${release_base}/SHA256SUMS.txt"

tmpdir="$(mktemp -d)"
trap 'cleanup_mount; rm -rf "$tmpdir"' EXIT

archive_path="${tmpdir}/${asset_name}"
checksum_path="${tmpdir}/SHA256SUMS.txt"

printf 'Downloading %s %s\n' "${APP_NAME}" "${version_tag}"
download_file "$checksum_url" "$checksum_path"
download_file "$archive_url" "$archive_path"

expected_sha="$(expected_sha_for_asset "$checksum_path" "$asset_name")"
[[ -n "$expected_sha" ]] || fail "Unable to find checksum for ${asset_name}"

actual_sha="$(actual_sha_for_file "$archive_path")"
[[ "$expected_sha" == "$actual_sha" ]] || fail "SHA256 mismatch for ${asset_name}"

case "$platform" in
  macos)
    install_macos_app "$archive_path" "$install_dir"
    ;;
  linux)
    install_linux_appimage "$archive_path" "$install_dir"
    ;;
esac
