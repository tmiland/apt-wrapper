#!/usr/bin/env bash

## Author: Tommy Miland (@tmiland) - Copyright (c) 2022

VERSION='1.0.0'

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
  printf "%s\\n" "  ${YELLOW}help         ${NORMAL}|h      ${GREEN}display this help and exit${NORMAL}"
  printf "%s\\n" "  ${YELLOW}update       ${NORMAL}|up     ${GREEN}update package information${NORMAL}"
  printf "%s\\n" "  ${YELLOW}upgrade      ${NORMAL}|upg    ${GREEN}upgrade available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}full-upgrade ${NORMAL}|fupg   ${GREEN}full-upgrade. See: man apt(8)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}install      ${NORMAL}|i      ${GREEN}install one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}reinstall    ${NORMAL}|ri     ${GREEN}reinstall one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}remove       ${NORMAL}|r      ${GREEN}remove one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}purge        ${NORMAL}|p      ${GREEN}purge one or more packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoremove   ${NORMAL}|ar     ${GREEN}clean up unused dependencies${NORMAL}"
  printf "%s\\n" "  ${YELLOW}autoclean    ${NORMAL}|ac     ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}clean        ${NORMAL}|c      ${GREEN}clears out the local repository${NORMAL}"
  printf "%s\\n" "  ${YELLOW}show         ${NORMAL}|sh     ${GREEN}Show information about package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}policy       ${NORMAL}|p      ${GREEN}displays information about the package(s)${NORMAL}"
  printf "%s\\n" "  ${YELLOW}list         ${NORMAL}|l      ${GREEN}display a list of packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}edit-sources ${NORMAL}|es     ${GREEN}lets you edit your sources.list${NORMAL}"
  printf "%s\\n" "  ${YELLOW}search       ${NORMAL}|s      ${GREEN}search for available packages${NORMAL}"
  printf "%s\\n" "  ${YELLOW}find         ${NORMAL}|f      ${GREEN}package searching utility${NORMAL}"
  printf "%s\\n" "  ${YELLOW}apt-mark     ${NORMAL}|am     ${GREEN}set/unset settings for a package${NORMAL}"
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
sudo="sudo"

while [[ $# -gt 0 ]]; do
  case $1 in
    install|i)
      shift
      ${sudo} "${apt}" install "$@"
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
    policy|p)
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
