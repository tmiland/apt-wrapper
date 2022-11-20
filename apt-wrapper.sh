#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2181
## Author: Tommy Miland (@tmiland) - Copyright (c) 2022

VERSION='1.0.2'

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2022 Tommy Miland
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

exit_error() {
  echo "Error: $1"
  exit 1
}

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
  printf "%s\\n" "  ${YELLOW}help               ${NORMAL}|h      ${GREEN}display this help and exit${NORMAL}"
  printf "%s\\n" "  ${YELLOW}update             ${NORMAL}|up     ${GREEN}update package information${NORMAL}"
  printf "%s\\n" "  ${YELLOW}upgrade            ${NORMAL}|upg    ${GREEN}upgrade available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}full-upgrade       ${NORMAL}|fupg   ${GREEN}full-upgrade. See: man apt(8)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}install            ${NORMAL}|i      ${GREEN}install one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}deb-install        ${NORMAL}|di     ${GREEN}install local deb package${NORMAL}"
  printf "%s\\n" "  ${YELLOW}reinstall          ${NORMAL}|ri     ${GREEN}reinstall one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}remove             ${NORMAL}|r      ${GREEN}remove one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}purge              ${NORMAL}|p      ${GREEN}purge one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoremove         ${NORMAL}|ar     ${GREEN}clean up unused dependencies${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoclean          ${NORMAL}|ac     ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}clean              ${NORMAL}|c      ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}show               ${NORMAL}|sh     ${GREEN}Show information about package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}policy             ${NORMAL}|p      ${GREEN}displays information about the package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}list               ${NORMAL}|l      ${GREEN}display a list of packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}edit-sources       ${NORMAL}|es     ${GREEN}lets you edit your sources.list${NORMAL}"
  printf "%s\\n" "  ${YELLOW}search             ${NORMAL}|s      ${GREEN}search for available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}find               ${NORMAL}|f      ${GREEN}package searching utility${NORMAL}"
  printf "%s\\n" "  ${YELLOW}apt-mark           ${NORMAL}|am     ${GREEN}set/unset settings for a package${NORMAL}"
  printf "%s\\n" "  ${YELLOW}add-apt-repository ${NORMAL}|aar    ${GREEN}add apt repo from ppa.launchpad.net${NORMAL}"
  printf "%s\\n" "  ${YELLOW}ppa-purge          ${NORMAL}|ppp    ${GREEN}purge apt repo from ppa.launchpad.net${NORMAL}"
  printf "%s\\n" "  ${YELLOW}add-private-repo   ${NORMAL}|apr    ${GREEN}add private apt repo${NORMAL}"
  echo
  printf "%s\\n" "  Script version: ${CYAN}${VERSION}${NORMAL} | Enable apt progressbar with --progress-bar"
  echo
}

about() {
  header
}

if [[ ! $(which apt) ]]; then
  echo -e "${RED} Error: APT Not found! \n Sorry, your OS is not supported.${NORMAL}"
  exit 1;
elif [[ ! $(which sudo) ]]; then
  echo -e "${RED} Error: SUDO Not found! \n Please install sudo.${NORMAL}"
  exit 1;
fi

apt="apt"
dpkg="dpkg"
sudo="sudo"

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
          archive_keyring="/usr/share/keyrings/${REPO_NAME}-archive-keyring.gpg"
          wget -qO - $GPG_LINK | gpg --dearmor | ${sudo} tee $archive_keyring > /dev/null
          # Check if keyfile is the right type
          keyfiletype=$(file "$archive_keyring" | grep -c 'OpenPGP Public Key Version 4\|PGP/GPG key public ring (v4)')
          if [ "$keyfiletype" -eq 0 ]; then
            echo "${RED}$archive_keyring is not a PGP/GPG key public ring${NORMAL}"
            # Check tmpfile type and convert
            tmppath=/tmp
            tmpfile=$tmppath/${REPO_NAME}-archive-keyring.gpg
            ${sudo} cp -rp $archive_keyring $tmpfile
            echo "Converting keyfile..."
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
                exit_error "invalid input keyfile format"
                ;;
            esac
          fi
          if [[ ! -f $archive_keyring ]]; then
            echo "${YELLOW}${REPO_NAME}-archive-keyring.gpg does not exist...${NORMAL}"
            exit_error "${RED}Something went wrong!${NORMAL}"
          fi
          echo "$REPO_LINE" | ${sudo} tee $archive_list
          if [[ ! -f $archive_list ]]; then
            echo "${YELLOW}$archive_list does not exist...${NORMAL}"
            exit_error "${RED}Something went wrong!${NORMAL}"
          fi
          ${sudo} "${apt}" update -o Dir::Etc::sourcelist="$archive_list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" &> /dev/null
          #success message
          if [ -n "$archive_keyring" ]; then
            echo ""
            echo "Key added to $archive_keyring"
            echo ""
          else
            exit_error "${RED}Something went wrong!${NORMAL}"
          fi
          echo "$REPO_NAME added to your system"
          echo "Your app is ready to install"
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
    # Use jammy as default
    VERSION=jammy
  else
    # Else use provided second argument
    VERSION=$2
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
    echo "Key added to $archive_keyring"
    echo ""
  fi
  echo "$LAUNCHPAD$PPA added to your system"
  echo ""
}

ppa_purge() {
  if dpkg -s ppa-purge &>/dev/null; then
    ${sudo} ppa-purge "$@"
  else
    echo "ppa-purge is not installed"
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
      ${sudo} "${dpkg}" --install "$@"
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
      ${sudo} "${apt}" search "$@"
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
    policy|pl)
      shift
      ${sudo} "${apt}" policy "$@"
      break
      ;;
    edit-sources|es)
      shift
      ${sudo} "${apt}" edit-sources "$@"
      break
      ;;
    apt-mark|am)
      shift
      ${sudo} "${apt}" apt-mark "$@"
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
