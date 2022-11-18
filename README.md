# apt-wrapper
 
A simple wrapper for apt with aliases

[![GitHub release](https://img.shields.io/github/release/tmiland/apt-wrapper.svg?style=flat-square)](https://github.com/tmiland/apt-wrapper/releases)
[![licence](https://img.shields.io/github/license/tmiland/apt-wrapper.svg?style=flat-square)](https://github.com/tmiland/apt-wrapper/blob/master/LICENSE)
![Bash](https://img.shields.io/badge/Language-SH-4EAA25.svg?style=flat-square)

## Installing

Clone this repo:

`git clone https://github.com/tmiland/apt-wrapper.git $HOME/Documents/GitHub/`

Symlink script:

`sudo ln -s $HOME/Documents/GitHub/apt-wrapper/apt-wrapper.sh /usr/bin/apt-wrapper`

Add to .bashrc / .zshrc etc...

```bash
# app-wrapper alias
sudo="sudo"
apt() {
  command apt-wrapper "$@"
}
sudo() {
  if [ "$1" = "apt" ]; then
    shift
    command sudo apt-wrapper "$@"
  else
    command sudo "$@"
  fi
}
```
Now you can use `apt [options]` as cmd instead of `apt-wrapper [options]`

Help output:
```bash
apt help
Usage:  apt-wrapper [options]
  If called without arguments, shows help.

  help         |h      display this help and exit
  update       |up     update package information
  upgrade      |upg    upgrade available packages
  full-upgrade |fupg   full-upgrade. See: man apt(8)
  install      |i      install one or more packages
  reinstall    |ri     reinstall one or more packages
  remove       |r      remove one or more packages
  purge        |p      purge one or more packages
  autoremove   |ar     clean up unused dependencies
  autoclean    |ac     clears out the local repository
  clean        |c      clears out the local repository
  show         |sh     Show information about package(s)
  list         |l      display a list of packages
  policy       |p      displays information about the package(s)  
  edit-sources |es     lets you edit your sources.list
  search       |s      search for available packages
  find         |f      package searching utility
  apt-mark     |am     set/unset settings for a package

  Script version: 1.0.0 | Enable apt progressbar with --progress-bar
```

Install apt progressbar opt runs code:

```bash
  progfile=/etc/apt/apt.conf.d/99progressbar
  ${sudo} echo 'Dpkg::Progress-Fancy "1";' > $progfile
  ${sudo} chmod 644 $progfile
```
Now close and start a new terminal window.

## Uninstalling

`sudo rm /usr/bin/apt-wrapper`
`sudo rm -rf $HOME/Documents/GitHub/apt-wrapper`

## Credits

- Inspired by: [Itai-Nelken/aptpac](https://github.com/Itai-Nelken/aptpac)
- scolors [swelljoe/scolors](http://github.com/swelljoe/scolors)

## Donations
<a href="https://coindrop.to/tmiland" target="_blank"><img src="https://coindrop.to/embed-button.png" style="border-radius: 10px; height: 57px !important;width: 229px !important;" alt="Coindrop.to me"></img></a>

## Web Hosting

Sign up for web hosting using this link, and receive $200 in credit over 60 days.

<a href="https://www.digitalocean.com/?refcode=f1f2b475fca0&amp;utm_campaign=Referral_Invite&amp;utm_medium=Referral_Program&amp;utm_source=badge"><img src="https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%203.svg" alt="DigitalOcean Referral Badge"></a>

#### Disclaimer 

*** ***Use at own risk*** ***

### License

[![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://github.com/tmiland/apt-wrapper/blob/master/LICENSE)

[MIT License](https://github.com/tmiland/apt-wrapper/blob/master/LICENSE)