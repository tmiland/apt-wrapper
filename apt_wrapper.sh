#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2181,SC2068

## Author: Tommy Miland (@tmiland) - Copyright (c) 2025


######################################################################
####                      Apt Wrapper.sh                          ####
####            A simple wrapper for apt with aliases             ####
####                   Maintained by @tmiland                     ####
######################################################################


VERSION='1.2.1'

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2025 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
## Uncomment for debugging purpose
#set -o errexit
#set -o pipefail
#set -o nounset
#set -o xtrace
# Include functions
# Get script filename
self=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_FILENAME=$(basename "$self")
SCRIPT_NAME=${SCRIPT_FILENAME}
# scolors - Color constants
# canonical source http://github.com/swelljoe/scolors

# do we have tput?
if which 'tput' > /dev/null; then
  # do we have a terminal?
  if [ -t 1 ]; then
    # does the terminal have colors?
    ncolors=$(tput colors)
    if [ "$ncolors" -ge 8 ]; then
      RED=$(tput setaf 1)
      GREEN=$(tput setaf 2)
      YELLOW=$(tput setaf 3)
      CYAN=$(tput setaf 6)
      NORMAL=$(tput sgr0)
    fi
  fi
else
  echo "tput not found, colorized output disabled."
  GREEN=''
  YELLOW=''
  CYAN=''
  NORMAL=''
fi

message() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    return
  fi
# Credit: deb-get
MESSAGE_TYPE=""
MESSAGE=""
MESSAGE_TYPE="${1}"
MESSAGE="${2}"

case ${MESSAGE_TYPE} in
  info)     echo -e "  [${GREEN}INFO:${NORMAL}] ${MESSAGE}";;
  progress) echo -en "  [${GREEN}PROGRESS:${NORMAL}] ${MESSAGE}";;
  recommend)echo -e "  [${CYAN}RECOMMENDATION:${NORMAL}] ${MESSAGE}";;
  warn)     echo -e "  [${YELLOW}WARNING!${NORMAL}] ${MESSAGE}";;
  error)    echo -e "  [${RED}ERROR!${NORMAL}] ${MESSAGE}" >&2;;
  fatal)    echo -e "  [${RED}ERROR!${NORMAL}] ${MESSAGE}" >&2
    exit 1;;
  *) echo -e "  [?] UNKNOWN: ${MESSAGE}";;
esac
}

if ((BASH_VERSINFO[0] < 4)); then
    message fatal "Sorry, you need bash 4.0 or newer to run $(basename "${0}")."
fi

if ! command -v lsb_release 1>/dev/null; then
  message fatal "lsb_release not detected. Quitting."
  message recommend "Install with 'apt install lsb-release' "
  
fi

# OS Detection
OS_ID=$(lsb_release --id --short)
case "${OS_ID}" in
  Debian) OS_ID_PRETTY="Debian";;
  Linuxmint) OS_ID_PRETTY="Linux Mint";;
  Neon) OS_ID_PRETTY="KDE Neon";;
  Pop) OS_ID_PRETTY="Pop!_OS";;
  Ubuntu) OS_ID_PRETTY="Ubuntu";;
  Zorin) OS_ID_PRETTY="Zorin OS";;
  *)
    OS_ID_PRETTY="${OS_ID}"
    message warn "${OS_ID} is not supported."
  ;;
esac

OS_CODENAME=$(lsb_release --codename --short)

if [ -e /etc/os-release ]; then
    OS_RELEASE=/etc/os-release
elif [ -e /usr/lib/os-release ]; then
    OS_RELEASE=/usr/lib/os-release
else
    message fatal "os-release not found. Quitting"
fi

ID="$(grep "^ID=" ${OS_RELEASE} | cut -d'=' -f2)"

# Fallback to ID_LIKE if ID was not 'ubuntu' or 'debian'
if [ "${ID}" != ubuntu ] && [ "${ID}" != debian ]; then
    ID_LIKE="$(grep "^ID_LIKE=" ${OS_RELEASE} | cut -d'=' -f2 | cut -d \" -f 2)"

    if [[ " ${ID_LIKE} " =~ " ubuntu " ]]; then
        ID=ubuntu
    elif [[ " ${ID_LIKE} " =~ " debian " ]]; then
        ID=debian
    else
        message fatal "${OS_ID_PRETTY} ${OS_CODENAME^} is not supported because it is not derived from a supported Debian or Ubuntu release."
    fi
fi

CODENAME=$(grep "^UBUNTU_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)

if [ -z "${CODENAME}" ]; then
    CODENAME=$(grep "^DEBIAN_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)
fi

if [ -z "${CODENAME}" ]; then
    CODENAME=$(grep "^VERSION_CODENAME=" ${OS_RELEASE} | cut -d'=' -f2)
fi

# Debian 12+
if [ -z "${CODENAME}" ] && [ -e /etc/debian_version ]; then
    CODENAME=$(cut -d / -f 1 /etc/debian_version)
fi

case "${CODENAME}" in
    buster)   RELEASE="10";;
    bullseye) RELEASE="11";;
    bookworm) RELEASE="12";;
    trixie)   RELEASE="13";;
    sid)      RELEASE="unstable";;
    trusty)   RELEASE="14.04";;
    xenial)   RELEASE="16.04";;
    bionic)   RELEASE="18.04";;
    focal)    RELEASE="20.04";;
    jammy)    RELEASE="22.04";;
    noble)    RELEASE="24.04";;
    plucky)   RELEASE="25.04";;
    *) message fatal "${OS_ID_PRETTY} ${OS_CODENAME^} is not supported because it is not derived from a supported Debian or Ubuntu release.";;
esac

# Header
header() {
  echo -e "${GREEN}\n"
  echo ' ╔═══════════════════════════════════════════════════════════════════╗'
  echo ' ║                          '"${SCRIPT_NAME}"'                           ║'
  echo ' ║               A simple wrapper for apt with aliases               ║'
  echo ' ║                      Maintained by @tmiland                       ║'
  echo ' ║                          version: '${VERSION}'                           ║'
  echo ' ╚═══════════════════════════════════════════════════════════════════╝'
  echo -e "${NORMAL}"
}

help() {
  ## shellcheck disable=SC2046
  printf "Usage: %s %s [options]" "${CYAN}" "${SCRIPT_FILENAME}${NORMAL}"
  echo
  echo "  If called without arguments, shows help."
  echo
  printf "%s\\n" "  ${YELLOW}help                   ${NORMAL}|h      ${GREEN}display this help and exit${NORMAL}"
  printf "%s\\n" "  ${YELLOW}update                 ${NORMAL}|up     ${GREEN}update package information${NORMAL}"
  printf "%s\\n" "  ${YELLOW}upgrade                ${NORMAL}|upg    ${GREEN}upgrade available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}full-upgrade           ${NORMAL}|fupg   ${GREEN}full-upgrade. See: man apt(8)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}install                ${NORMAL}|i      ${GREEN}install one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}deb-install            ${NORMAL}|di     ${GREEN}install local or remote deb package${NORMAL}"
  printf "%s\\n" "  ${YELLOW}download               ${NORMAL}|dl     ${GREEN}download deb package from repo${NORMAL}"
  printf "%s\\n" "  ${YELLOW}reinstall              ${NORMAL}|ri     ${GREEN}reinstall one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}remove                 ${NORMAL}|r      ${GREEN}remove one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}purge                  ${NORMAL}|p      ${GREEN}purge one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoremove             ${NORMAL}|ar     ${GREEN}clean up unused dependencies${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoclean              ${NORMAL}|ac     ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}clean                  ${NORMAL}|c      ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}show                   ${NORMAL}|sh     ${GREEN}Show information about package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}policy                 ${NORMAL}|pol    ${GREEN}displays information about the package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}list                   ${NORMAL}|l      ${GREEN}display a list of packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}edit-sources           ${NORMAL}|es     ${GREEN}lets you edit your sources.list${NORMAL}"
  printf "%s\\n" "  ${YELLOW}modernize-sources      ${NORMAL}|ms     ${GREEN}modernize your sources.list to new deb822 format${NORMAL}"
  printf "%s\\n" "  ${YELLOW}enable-disable-sources ${NORMAL}|eds    ${GREEN}enable or disable a sources file. *${NORMAL}"
  printf "%s\\n" "  ${YELLOW}search                 ${NORMAL}|s      ${GREEN}search for available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}find                   ${NORMAL}|f      ${GREEN}package searching utility${NORMAL}"
  printf "%s\\n" "  ${YELLOW}apt-mark               ${NORMAL}|am     ${GREEN}set/unset settings for a package${NORMAL}"
  printf "%s\\n" "  ${YELLOW}pin                    ${NORMAL}|pi     ${GREEN}add pin settings for a package or repo${NORMAL}"
  printf "%s\\n" "  ${YELLOW}add-apt-repository     ${NORMAL}|aar    ${GREEN}add apt repo from ppa.launchpad.net${NORMAL}"
  printf "%s\\n" "  ${YELLOW}ppa-purge              ${NORMAL}|ppp    ${GREEN}purge apt repo from ppa.launchpad.net${NORMAL}"
  printf "%s\\n" "  ${YELLOW}add-private-repo       ${NORMAL}|apr    ${GREEN}add private apt repo${NORMAL}"
  printf "%s\\n" "  ${YELLOW}app-install            ${NORMAL}|api    ${GREEN}add private apt repo for provided apps${NORMAL}"
  printf "%s\\n" "  ${YELLOW}deb-get                ${NORMAL}|dg     ${GREEN}manage apps with deb-get${NORMAL}"
  echo
  cat <<EOF
* Arguments for ${YELLOW}enable-disable-sources${NORMAL}: ${GREEN}enable, disable or move.${NORMAL}
  move, moves all sources files from /etc/apt/sources.list.d to /etc/apt/sources.list.disabled. (first time only)
  enable, moves the selected sources file back to /etc/apt/sources.list.d.
  disable, moves the selected sources file /etc/apt/sources.list.disabled.
EOF
  echo
  printf "%s\\n" "Script version: ${CYAN}${VERSION}${NORMAL} | Enable apt progressbar with --progress-bar"
  echo
}

about() {
  header
}

if [[ ! $(which apt) ]]; then
  message error "Error: APT Not found! \n Sorry, your OS is not supported."
  exit 1;
elif [[ ! $(which sudo) ]]; then
  message error "Error: SUDO Not found! \n Please install sudo."
  exit 1;
fi

apt="apt"
dpkg="dpkg"
sudo="sudo"
debget="./deb-get/deb-get"

deb_download() {
  # Credit: deb-get 
  URL="${1}"
  FILE="${URL##*/}"
  CACHE_DIR=/var/cache/apt/archives

  if ! ${sudo} wget --quiet --continue --show-progress --progress=bar:force:noscroll "${URL}" -O "${CACHE_DIR}/${FILE}"; then
      message error "Failed to download ${URL}. Deleting ${CACHE_DIR}/${FILE}..."
      ${sudo} rm "${CACHE_DIR}/${FILE}" 2>/dev/null
      return 1
  fi
}

deb_install() {
  URL="${1}"
  FILE="${URL##*/}"
  if [[ "$1" = "$URL" ]]; then
    deb_download "$URL"
    ${sudo} "${dpkg}" --install "${CACHE_DIR}/${FILE}"
  else
    ${sudo} "${dpkg}" --install "$@"
  fi
}

app_install() {
  install_dir="${HOME}"/.apt-wrapper
  if [[ -d $install_dir ]]; then
    lists=$install_dir/lists/
    keys=$install_dir/keyrings/
  else
    lists=./lists
    keys=./keyrings
  fi
  
  APPS=$(ls $lists/)
  case $1 in
    list|l)
      for APP in "${APPS[@]}"; do
        echo "${APP##*/}" | sed -e 's/\..*$//'
      done
      ;;
    install|i)
    APP=$2
    archive_list=/etc/apt/sources.list.d/$APP.list
      ${sudo} cp -rp $lists/${APP}.list /etc/apt/sources.list.d/
      ${sudo} chown root:root /etc/apt/sources.list.d/${APP}.list
      ${sudo} cp -rp $keys/${APP}-archive-keyring.gpg /usr/share/keyrings/
      ${sudo} chown root:root /usr/share/keyrings/${APP}-archive-keyring.gpg
      ${sudo} "${apt}" update -o Dir::Etc::sourcelist="$archive_list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" &> /dev/null
      message info "$APP repo added to your system"
      message info "Install with apt install $APP"
      ;;
    uninstall|u)
    APP=$2
    archive_list=/etc/apt/sources.list.d/$APP.list
      ${sudo} rm $archive_list
      ${sudo} rm /usr/share/keyrings/${APP}-archive-keyring.gpg
      ${sudo} apt update
      message info "$APP repo removed from your system"
      ;;
  esac
}

add_private_repo() {
  while [[ $PRIVATE_REPO != "y" && $PRIVATE_REPO != "n" ]]; do
    read -r -p "Are you ready to add a private repo? [y/n]: " PRIVATE_REPO
  done
  while :;
    do
      case $PRIVATE_REPO in
        [Yy]* )
          read -r -p "${GREEN}Name of the private repo: (e.g: git-core)${NORMAL} " REPO_NAME
          echo ""
          read -r -p "${GREEN}Please paste the link to the archive-keyring.gpg:${NORMAL} " GPG_LINK
          echo ""
          echo "${YELLOW}Repo line must contain:${NORMAL} ${RED}[signed-by=/usr/share/keyrings/$REPO_NAME-archive-keyring.gpg]${NORMAL}"
          echo "or else updating the repo will fail with missing key.${NORMAL}"
          echo ""
          read -r -p "${GREEN}Please paste the repo line (starting with deb):${NORMAL} " REPO_LINE
          echo ""
          echo -e "You entered: \n"
          echo -e " repo name: ${GREEN}$REPO_NAME${NORMAL}"
          echo -e " gpg key  : ${GREEN}$GPG_LINK${NORMAL}"
          echo -e " repo line: ${GREEN}$REPO_LINE${NORMAL}"
          echo ""
          read -n1 -r -p "Repo is ready to be installed, press any key to continue, or ctrl+c to cancel..."
          echo ""
          archive_list=/etc/apt/sources.list.d/$REPO_NAME.list
          archive_keyring="/etc/apt/keyrings/${REPO_NAME}-archive-keyring.gpg"
          wget -qO - $GPG_LINK | gpg --dearmor | ${sudo} tee $archive_keyring > /dev/null
          # Check if keyfile is the right type
          keyfiletype=$(file "$archive_keyring" | grep -c 'OpenPGP Public Key Version 4\|PGP/GPG key public ring (v4)')
          if [ "$keyfiletype" -eq 0 ]; then
            message warn "$archive_keyring is not a PGP/GPG key public ring"
            # Check tmpfile type and convert
            tmppath=/tmp
            tmpfile=$tmppath/${REPO_NAME}-archive-keyring.gpg
            ${sudo} cp -rp $archive_keyring $tmpfile
            message recommend "Trying to convert keyfile..."
            case $(file "$tmpfile") in
              # ASCII armored (old)
              *'PGP public key block Public-Key (old)')
                gpg --batch --yes --dearmor --keyring=gnupg-ring "$tmpfile"
                ;;
              # Secret key
              *'PGP public key block Secret-Key')
                gpg --batch --yes --no-default-keyring --keyring=gnupg-ring:"$tmppath/temp-keyring.gpg" --quiet --import "$tmpfile"
                gpg --batch --yes --no-default-keyring --keyring=gnupg-ring:"$tmppath/temp-keyring.gpg" --export --output "$tmpfile"
                rm "$tmppath/temp-keyring.gpg"
                [ -f "$tmppath/temp-keyring.gpg~" ] && rm "$tmppath/temp-keyring.gpg~"
                ;;
              # Public ring (v4)
              *'OpenPGP Public Key Version 4\|PGP/GPG key public ring (v4)'*)
                ${sudo} cp -rp "$tmpfile" "$archive_keyring"
                ;;
              *)
                message fatal "invalid input keyfile format"
                ;;
            esac
          fi
          if [[ ! -f $archive_keyring ]]; then
            message warn "${REPO_NAME}-archive-keyring.gpg does not exist..."
            message fatal "Something went wrong!"
          fi
          echo "$REPO_LINE" | ${sudo} tee $archive_list &> /dev/null
          ${sudo} sed -i "s|signed-by=/.*.gpg|signed-by=$archive_keyring|g" $archive_list
          if [[ "${CODENAME}" == "trixie" ]]
          then
            archive_sources=/etc/apt/sources.list.d/$REPO_NAME.sources
            message info "Modernizing sources file..."
            if ! [ -d /etc/apt/sources.list.old  ]; then
              ${sudo} mkdir -p /etc/apt/sources.list.old
            fi
            ${sudo} "${apt}" modernize-sources -o Dir::Etc::sourcelist="$archive_list" -y &> /dev/null
            ${sudo} mv /etc/apt/sources.list.d/moved-from-main.sources $archive_sources &> /dev/null
            ${sudo} mv /etc/apt/sources.list.d/${REPO_NAME}.list.bak /etc/apt/sources.list.old/${REPO_NAME}.list.bak &> /dev/null
            ${sudo} chmod 644 $archive_sources
            message info "Done."
            if [[ ! -f $archive_sources ]]; then
              message warn "$archive_sources does not exist..."
              message fatal "Something went wrong!"
            fi
          else
            if [[ ! -f $archive_list ]]; then
              message warn "$archive_list does not exist..."
              message fatal "Something went wrong!"
            fi
          fi
          ${sudo} "${apt}" update -o Dir::Etc::sourcelist="$archive_list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" &> /dev/null
          if [ -n "$archive_keyring" ]; then
            echo ""
            message info "Key added to $archive_keyring"
            echo ""
          else
            message fatal "Something went wrong!"
          fi
          message info "$REPO_NAME added to your system"
          message info "Your app is ready to install"
          exit 1
        ;;
        [Nn]* )
          break ;;
    esac
  done
}

add-apt-repository() {
  # Credits: 
  # Fetch the only corresponding apt package list immediately after added ppa repo. - https://github.com/PeterDaveHello/add-apt-ppa
  # Easily add repositories from launchpad for Debian systems. - https://github.com/timothyvanderaerden/add-apt-repository
  LAUNCHPAD=http://ppa.launchpad.net/
  INPUT=$1
  if [ -z ${2+x} ]; then
    if [[ $ID == "debian" ]]; then
      case $CODENAME in
        buster)       VERSION=jammy ;;
        bullseye)     VERSION=noble ;;
        bookworm|trixie|sid) VERSION=plucky ;;
      esac
    elif [[ $ID == "ubuntu" ]]; then
      case $CODENAME in
        focal)   VERSION=focal ;;
        jammy)   VERSION=jammy ;;
        noble)   VERSION=noble ;;
        plucky)  VERSION=plucky ;;
      esac
    else
      # Use noble as default
      VERSION=noble
    fi

    else
    # Else use provided second argument
    VERSION=$2
  fi
  if [[ $INPUT = "" ]]; then
    message fatal "No repo provided!"
  fi
  # get ppa: git-core/ppa
  PPA=$(echo "$INPUT" | cut -d ':' -f 2)
  # Cuts down to: git-core
  SOFTWARE=$(echo "$PPA" | cut -d '/' -f 1)
  URL="$LAUNCHPAD$PPA/ubuntu $VERSION main"
  TEMP_DIR=$(mktemp -d)
  TEMP_KEY=$TEMP_DIR/archive_keyring
  # Create source list file
  file=/etc/apt/sources.list.d/$SOFTWARE.list
  archive_keyring="/usr/share/keyrings/${SOFTWARE}-archive-keyring.gpg"
  ${sudo} touch "$file"
  echo "deb [signed-by=$archive_keyring] $URL
# deb-src $URL" | ${sudo} tee "$file" >/dev/null
  # Add key
  # Here we run apt update on the added repo only to get the missing key (for faster update)
  ${sudo} "${apt}" update -o Dir::Etc::sourcelist="$file" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" >> /dev/null 2> $TEMP_KEY
  KEY=$(cat $TEMP_KEY | cut -d ':' -f 6 | cut -d ' ' -f 3)
  # Here we're importing the key from keyserver, exporting to file, dearmoring and deleting when done.
  # Credit: https://github.com/Ulauncher/Ulauncher/issues/972#issuecomment-1034751651
  ${sudo} gpg --keyserver keyserver.ubuntu.com --recv $KEY &> /dev/null
  ${sudo} gpg --export --armor $KEY | ${sudo} gpg --dearmor | ${sudo} tee $archive_keyring &> /dev/null
  # Delete key without confirmation: https://stackoverflow.com/questions/9768473/gnupg-suppress-message-while-deleting-public-key
  ${sudo} gpg --batch --yes --delete-key $KEY &> /dev/null
  $sudo chmod 644 $archive_keyring &> /dev/null
  ${sudo} rm -rf $TEMP_DIR &> /dev/null
  # Update repo once more
  ${sudo} "${apt}" update -o Dir::Etc::sourcelist="$file" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" &> /dev/null
  #success message
  if [ -n "$KEY" ]; then
    echo ""
    message info "Key added to $archive_keyring"
    echo ""
  fi
  message info "$LAUNCHPAD$PPA added to your system"
  echo ""
}

ppa_purge() {
  if dpkg -s ppa-purge &>/dev/null; then
    ${sudo} ppa-purge "$@"
  else
    message fatal "ppa-purge is not installed"
  fi
}

apt_pin() {
  case $1 in
    add-repo)
      shift
      repo_name=${repo_name:-deb-tmiland-com}
      repo_pin=${repo_pin:-origin deb.tmiland.com}
      repo_priority=${repo_priority:-600}
      read -rep "  Enter repo name: " -i $repo_name repo_name
      cat <<EOF

  Options for pinning are:

      ${GREEN}From a repo:${NORMAL} ${YELLOW}origin deb.tmiland.com${NORMAL}
      ${GREEN}From repository name:${NORMAL} ${YELLOW}release o=deb.tmiland.com${NORMAL}
      
    ${GREEN}Visit for more information:${NORMAL} ${YELLOW}https://wiki.debian.org/AptConfiguration${NORMAL}

EOF
      read -rep "  Enter repo pin: " -i "$repo_pin" repo_pin
      read -rep "  Enter repo priority: " -i $repo_priority repo_priority
      ${sudo} tee "/etc/apt/preferences.d/$repo_name" > /dev/null <<EOF
Package: *
Pin: $repo_pin
Pin-Priority: $repo_priority
EOF
      if [ $? -eq 0 ]
      then
        message info "SUCCESS! The file /etc/apt/preferences.d/$repo_name has been created."
        message recommend "Run apt upd to update apt package manager."
      else
        message error "Something went wrong!"
      fi
    ;;
    add-package)
      shift
      package_name=${package_name:-package_name}
      package_pin=${package_pin:-release a=bookworm-backports}
      package_priority=${package_priority:-500}
      read -rep "  Enter package name: " -i $package_name package_name
      cat <<EOF

  Options for pinning are:

      ${GREEN}From a repo:${NORMAL} ${YELLOW}origin deb.debian.org${NORMAL}
      ${GREEN}From a release:${NORMAL} ${YELLOW}release a=bookworm-backports${NORMAL}
      ${GREEN}From repository name:${NORMAL} ${YELLOW}release o=my-custom-repo-name${NORMAL}
      
    ${GREEN}Visit for more information:${NORMAL} ${YELLOW}https://wiki.debian.org/AptConfiguration${NORMAL}

EOF
      read -rep "  Enter package pin: " -i "$package_pin" package_pin
      read -rep "  Enter package priority: " -i $package_priority package_priority
      ${sudo} tee "/etc/apt/preferences.d/$package_name" > /dev/null <<EOF
Package: $package_name
Pin: $package_pin
Pin-Priority: $package_priority
EOF
      if [ $? -eq 0 ]
      then
        message info "SUCCESS! The file /etc/apt/preferences.d/$package_name has been created."
        message recommend "Run apt upd to update apt package manager."
      else
        message error "Something went wrong!"
      fi
    ;;
    edit)
      shift
      read -rp "  Enter package or repo name: " package_or_repo_name
      ${sudo} $EDITOR /etc/apt/preferences.d/$package_or_repo_name
      if [ $? -eq 0 ]
      then
        message info "SUCCESS! The file /etc/apt/preferences.d/$package_or_repo_name has been saved."
        message recommend "Run apt upd to update apt package manager."
      else
        message error "Something went wrong!"
      fi
      exit 0
    ;;
    remove)
      shift
      read -rp "  Enter package or repo name: " package_or_repo_name
      ${sudo} rm /etc/apt/preferences.d/$package_or_repo_name
      if [ $? -eq 0 ]
      then
        message info "SUCCESS! The file /etc/apt/preferences.d/$package_or_repo_name has been deleted."
        message recommend "Run apt upd to update apt package manager."
      else
        message error "Something went wrong!"
      fi
      exit 0
    ;;
    *)
        message info "Options are: add-repo,add-package, edit or remove."
      exit 0
    ;;
  esac
}

enable_disable_sources() {
  sources_disabled_dir=/etc/apt/sources.list.disabled
  sources_enabled_dir=/etc/apt/sources.list.d

  case "$1" in
    enable)
    if [[ -d "$sources_disabled_dir" ]]
    then
      sources_file_array=$(ls "$sources_disabled_dir")
      sources_file=($sources_file_array)
      read -rp "$(
            f=0
            for l in ${sources_file[@]}
            do
              echo "$((++f)): $l"
            done
            echo -ne "Please select a sources file you wish to enable: "
      )" selection
      selected_sources_file="${sources_file[$((selection-1))]}"
      message info "You selected $selected_sources_file"
      
      if [[ -d "$sources_disabled_dir" && -f "$sources_disabled_dir/$selected_sources_file" ]]
      then
        message info "Enabling selected $selected_sources_file"
        ${sudo} mv $sources_disabled_dir/$selected_sources_file $sources_enabled_dir/$selected_sources_file || echo "ERROR! Unable to enable $selected_sources_file"
        message info "Done! $selected_sources_file has been moved to $sources_enabled_dir."
      else
        message fatal "$sources_disabled_dir or $selected_sources_file does not exist..."
      fi
    else
      message fatal "$sources_disabled_dir does not exist..."
    fi
    ;;
    disable)
    if [[ -d "$sources_disabled_dir" ]]
    then
      sources_file_array=$(ls "$sources_enabled_dir")
      sources_file=($sources_file_array)
      read -rp "$(
            f=0
            for l in ${sources_file[@]}
            do
              echo "$((++f)): $l"
            done
            echo -ne "Please select a sources file you wish to disable: "
      )" selection
      selected_sources_file="${sources_file[$((selection-1))]}"
      message info "You selected $selected_sources_file"
      
      if [[ -d "$sources_enabled_dir" && -f "$sources_enabled_dir/$selected_sources_file" ]]
      then
        message info "Disabling selected $selected_sources_file"
        ${sudo} mv $sources_enabled_dir/$selected_sources_file $sources_disabled_dir/$selected_sources_file || echo "ERROR! Unable to disable $selected_sources_file"
        message info "Done! $selected_sources_file has been moved from $sources_enabled_dir to $sources_disabled_dir."
      else
        message fatal "$sources_enabled_dir or $selected_sources_file does not exist..."
      fi
    else
      message fatal "$sources_enabled_dir does not exist..."
    fi
    ;;
    move)
    if ! [[ -d $sources_disabled_dir ]]
    then
      ${sudo} mkdir -p $sources_disabled_dir
      ${sudo} mv $sources_enabled_dir/* $sources_disabled_dir/*
    else
      message fatal "Looks like $sources_disabled_dir has been created and files moved already..."
      exit 0
    fi
    ;;
    *)
      help
      exit 1
    ;;
  esac
}

modernize_sources() {
  if [[ $(apt -v | sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p') > "2.9.26" ]]
  then
  ${sudo} "${apt}" modernize-sources || message fatal "Something went wrong..."
  if ! [ -d /etc/apt/sources.list.old  ]; then
    ${sudo} mkdir -p /etc/apt/sources.list.old || message fatal "Something went wrong..."
    message info "Moving old files to /etc/apt/sources.list.old"
    ${sudo} mv /etc/apt/sources.list.d/*.list.bak /etc/apt/sources.list.old/ || message fatal "Something went wrong..."
    message info "Done."
  fi
  else
    message warning "apt is older than 2.9.26"
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case $1 in
    install|i)
      shift
      ${sudo} "${apt}" install "$@"
      break
      ;;
    deb-install|di)
      shift
      deb_install "$@"
      break
      ;;
    download|dl)
      shift
      ${sudo} "${apt}" download "$@"
      break
      ;;
    reinstall|ri)
      shift
      ${sudo} "${apt}" reinstall "$@"
      break
      ;;
    remove|r)
      shift
      ${sudo} "${apt}" remove "$@"
      break
      ;;
    purge|p)
      shift
      ${sudo} "${apt}" purge "$@"
      break
      ;;
    search|s)
      shift
      "${apt}" search "$@"
      break
      ;;
    find|f)
      shift
      ${sudo} "${apt}"-file search "$@"
      break
      ;;
    update|upd)
      ${sudo} "${apt}" update
      break
      ;;
    upgrade|upg)
      ${sudo} "${apt}" upgrade
      break
      ;;
    full-upgrade|fupg)
      ${sudo} "${apt}" full-upgrade
      break
      ;;
    clean|c)
      ${sudo} "${apt}" clean
      break
      ;;
    autoclean|ac)
      ${sudo} "${apt}" autoclean
      break
      ;;
    autoremove|ar)
      ${sudo} "${apt}" autoremove
      break
      ;;
    list|l)
      shift
      ${sudo} "${apt}" list "$@"
      break
      ;;
    show|sh)
      shift
      ${sudo} "${apt}" show "$@"
      break
      ;;
    policy|pol)
      shift
      ${sudo} "${apt}" policy "$@"
      break
      ;;
    edit-sources|es)
      shift
      ${sudo} "${apt}" edit-sources "$@"
      break
      ;;
    modernize-sources|ms)
      shift
      modernize_sources
      ;;
    enable-disable-sources|eds)
      shift
      enable_disable_sources "$@"
      break
      ;;
    apt-mark|am)
      shift
      ${sudo} "${apt}" apt-mark "$@"
      break
      ;;
    pin|pi)
      shift
      apt_pin "$@"
      break
      ;;
    add-apt-repository|aar)
      shift
      add-apt-repository "$@"
      break
      ;;
    ppa-purge|ppp)
      shift
      ppa_purge "$@"
      break
      ;;
    add-private-repo|apr)
      shift
      add_private_repo
      break
      ;;
    app-install|api)
      shift
      app_install "$@"
      break
      ;;
    deb-get|dg)
      shift
      ${debget} "$@"
      break
      ;;
    help|-h|--help|-help)
      help
      exit 0
      ;;
    version|-v|--version)
      about
      exit 0
      ;;
    --progress-bar)
      progfile=/etc/apt/apt.conf.d/99progressbar
      ${sudo} echo 'Dpkg::Progress-Fancy "1";' > $progfile
      ${sudo} chmod 644 $progfile
      ;;
    *)
      printf "%s\\n\\n" "Unrecognized option: $1"
      help
      exit 0
      ;;
  esac
done
