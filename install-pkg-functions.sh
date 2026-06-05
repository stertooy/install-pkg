#!/bin/bash 

# Download archive and extract to folder
download_and_extract() {
  local url="$1"
  local target="$2"

  clear_dest "${target}"
  local filename
  filename=$(basename "${url}")
  echo "Extracting ${filename} to ${target}."
  
  local archive="${TMPDIR}/${filename}"
  wget -qO "${archive}" "${url}"
  mkdir -p "${target}"
  bsdtar -xf "${archive}" -C "${target}" --strip-components=1
  rm "${archive}"
}

# Create valid archive url from base url and possible formats
combine_url() {
  local base="$1"
  local formats="$2" # newline-separated list

  # Prefer .tar.gz if available
  if echo "${formats}" | grep -q "^\.tar\.gz$"; then
    archive_url="${base}.tar.gz"
  elif echo "${formats}" | grep -q "^\.tar\.bz2$"; then
    archive_url="${base}.tar.bz2"
  elif echo "${formats}" | grep -q "^\.zip$"; then
    archive_url="${base}.zip"
  else
    echo "::error::No supported archive format found"
    exit 1
  fi
}

# Get package name
get_pkg_name() {
  local base
  base=$(basename "$1")

  # Remove archive suffix
  base=$(echo "${base}" | sed -E 's/\.(tar\.gz|tar\.bz2|zip)$//')
  # Remove version suffix
  base=$(echo "${base}" | sed -E 's/-[0-9]+(\.[0-9]+)*$//')
  # Convert to lowecase
  name=$(echo "${base}" | tr '[:upper:]' '[:lower:]')
}

# Get archive URL
get_archive_url() {
  local repo="$1"
  version="$2"
  
  if [[ "${version}" = "latest" ]]; then
    echo "Fetching latest release for ${repo}"
    wget --header="${WGET_HEADER}" -qO "${TMPDIR}/release.json" "https://api.github.com/repos/${repo}/releases/latest"
  else
    echo "Selecting oldest release >= ${version}"
    wget --header="${WGET_HEADER}" -qO "${TMPDIR}/releases.json" "https://api.github.com/repos/${repo}/releases"

    local release
    release=$(jq -c --arg v "${version}" '
      map(. + {ver:(.tag_name|sub("^v";""))})
      | sort_by(.ver)
      | map(select(.ver >= $v))
      | .[0]
    ' "${TMPDIR}/releases.json")

    if [[ "${release}" = "null" ]] || [[ -z "${release}" ]]; then
      echo "::error::No release >= ${version} found"
      exit 1
    fi

    echo "${release}" > "${TMPDIR}/release.json"
    rm "${TMPDIR}/releases.json"
  fi

  local tag_name
  tag_name=$(jq -r '.tag_name' "${TMPDIR}/release.json")
  
  local asset_url
  asset_url=$(jq -r '
    .assets[]
    | select(.name=="package-info.json")
    | .browser_download_url
  ' "${TMPDIR}/release.json")
  rm "${TMPDIR}/release.json"

  local info
  local archive_base
  local formats
  if [[ -z "${asset_url}" ]] || [[ "${asset_url}" = "null" ]]; then
    echo "Using PackageInfo.g file"
    asset_url="https://raw.githubusercontent.com/${repo}/refs/tags/${tag_name}/PackageInfo.g"
    info="${TMPDIR}/PackageInfo.g"
    wget -qO "${info}" "${asset_url}"
    ${GAP} --bare -q <<GAPInput
      Read("${info}");;
      info := GAPInfo.PackageInfoCurrent;;
      PrintTo( "${TMPDIR}/formats.txt", info.ArchiveFormats );;
      PrintTo( "${TMPDIR}/archive_base.txt", info.ArchiveURL );;
      PrintTo( "${TMPDIR}/version.txt", info.Version );;
      QUIT;
GAPInput
      formats=$(tr -d '\\\n' < "${TMPDIR}"/formats.txt)
      rm "${TMPDIR}"/formats.txt
      archive_base=$(tr -d '\\\n' < "${TMPDIR}"/archive_base.txt)
      rm "${TMPDIR}"/archive_base.txt
      version=$(tr -d '\\\n' < "${TMPDIR}"/version.txt)
      rm "${TMPDIR}"/version.txt
  else
    echo "Using package-info.json asset"
    info="${TMPDIR}/package-info.json"
    wget -qO "${info}" "${asset_url}"
    archive_base=$(jq -r '.ArchiveURL' "${info}")
    formats=$(jq -r '.ArchiveFormats' "${info}")
    version=$(jq -r '.Version' "${info}")
  fi

  formats=$(echo "${formats}" | tr ' ' '\n')

  echo "Selected version ${version} from ${repo} releases"
  combine_url "${archive_base}" "${formats}"
      
  rm "${info}"
}

# Get PackageDistro information
get_package_distro() {
  if [[ ! -f "${PKG_DISTRO}" ]]; then
    echo "Downloading packages-infos.json from PackageDistro"
    local distro="${TMPDIR}/package-infos.json.gz"
    wget -qO "${distro}" "https://github.com/gap-system/PackageDistro/releases/download/latest/package-infos.json.gz"
    gunzip "${distro}"
    if [[ ! -s "${PKG_DISTRO}" ]]; then
      echo "::error::Could not download PackageDistro json"
      exit 1
    fi
  fi
}

# Get repository name from package name using PackageDistro
get_repo_from_name() {
  local name="$1"

  # Create the required file at $PKG_DISTRO
  get_package_distro

  local pkg
  pkg=$(jq -c --arg n "${name}" '.[$n]' "${PKG_DISTRO}")

  if [[ "${pkg}" = "null" ]] || [[ -z "${pkg}" ]]; then
    echo "::error::Package ${name} not found in PackageDistro"
    exit 1
  fi

  # Don't try to get URL from PackageDistro - latest version not be merged yet!
  local repo_url
  repo_url=$(echo "${pkg}" | jq -r '.SourceRepository.URL') || {
    echo "::error::Package ${name} not found in PackageDistro"
    exit 1
  }
  repo=${repo_url#https://github.com/}
}

# Use GAP to check if package-version combination is already installed
check_pkg_availability() {
  local pkg="$1"
  local ver="$2"
  gap -A -q <<GAPINPUT
    QUIT_GAP( TestPackageAvailability( "${pkg}", "${ver}" ) <> fail );
GAPINPUT
  return $?
}

# Remove existing package versions
clear_dest() {
  local dest="$1"
  rm -rf "${dest}"
  rm -rf "${dest}-*"
}
