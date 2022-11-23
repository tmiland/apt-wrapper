# apt-wrapper
 
A simple wrapper for apt with aliases

[![GitHub release](https://img.shields.io/github/release/tmiland/apt-wrapper.svg?style=flat-square)](https://github.com/tmiland/apt-wrapper/releases)
[![licence](https://img.shields.io/github/license/tmiland/apt-wrapper.svg?style=flat-square)](https://github.com/tmiland/apt-wrapper/blob/master/LICENSE)
![Bash](https://img.shields.io/badge/Language-SH-4EAA25.svg?style=flat-square)

## Installing

Clone this repo:

`git clone --recursive https://github.com/tmiland/apt-wrapper.git $HOME/Documents/GitHub/`

Symlink script:

`sudo ln -s $HOME/Documents/GitHub/apt-wrapper/apt-wrapper.sh /usr/bin/apt-wrapper`

Add to .bashrc / .zshrc etc...

```bash
# apt-wrapper alias
source $HOME/Documents/GitHub/apt-wrapper/apt_wrapper_alias
```
Or run install script:
```bash
curl -sSL https://tmiland.github.io/apt-wrapper/install | bash
```
_**This will install and symlink scripts from `$HOME/.apt-wrapper`**_

Now you can use `apt [options]` as cmd instead of `apt-wrapper [options]`

Help output:
```bash
apt help
Usage:  apt-wrapper [options]
  If called without arguments, shows help.

  help               |h      display this help and exit
  update             |up     update package information
  upgrade            |upg    upgrade available packages
  full-upgrade       |fupg   full-upgrade. See: man apt(8)
  install            |i      install one or more packages
  deb-install        |di     install local or remote deb package
  download           |dl     download deb package from repo
  reinstall          |ri     reinstall one or more packages
  remove             |r      remove one or more packages
  purge              |p      purge one or more packages
  autoremove         |ar     clean up unused dependencies
  autoclean          |ac     clears out the local repository
  clean              |c      clears out the local repository
  show               |sh     Show information about package(s)
  policy             |p      displays information about the package(s)
  list               |l      display a list of packages
  edit-sources       |es     lets you edit your sources.list
  search             |s      search for available packages
  find               |f      package searching utility
  apt-mark           |am     set/unset settings for a package
  add-apt-repository |aar    add apt repo from ppa.launchpad.net
  ppa-purge          |ppp    purge apt repo from ppa.launchpad.net
  add-private-repo   |apr    add private apt repo
  app-install        |api    add private apt repo for provided apps
  deb-get            |dg     manage apps with deb-get  

  Script version: 1.0.0 | Enable apt progressbar with --progress-bar
```

### Install apt progressbar opt runs code

```bash
  progfile=/etc/apt/apt.conf.d/99progressbar
  ${sudo} echo 'Dpkg::Progress-Fancy "1";' > $progfile
  ${sudo} chmod 644 $progfile
```
Now close and start a new terminal window.

### deb-install

install local or remote deb package

```bash
apt di /path/to/app.deb
```
or
```bash
apt di https://url/to/app.deb
```
deb file will download to `/var/cache/apt/archives`

### add-apt-repository

Add repo from launchpad

```bash

apt aar ppa:git-core/ppa
```

### ppa-purge

Purge repo from launchpad

```bash

apt ppp ppa:git-core/ppa
```
***will revert to standard packages*** (If there are any)

### add-private-repo

Add private apt repo

```bash

apt apr
```
Looks like this:
<details><summary>*truncated* **click to view**</summary><p>

```bash
apt apr
Are you ready to add a private repo? [y/n]: y
Name of the private repo: (e.g: git-core) vscodium

Please paste the link to the archive-keyring.gpg: https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg

Repo line must contain: [signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg]
or else updating the repo will fail with missing key.

Please paste the repo line (starting with deb): deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main

You entered: 

 repo name: vscodium
 gpg key  : https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
 repo line: deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main

Repo is ready to be installed, press any key to continue, or ctrl+c to cancel...

deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main

Key added to /usr/share/keyrings/vscodium-archive-keyring.gpg

vscodium added to your system
Your app is ready to install
```
</p></details>

### app-install

add private apt repo for provided apps

To list all available apps
```bash
apt api list
```
To install repo for app
```bash
apt api install <APP>
```
To uninstall repo for app
```bash
apt api uninstall <APP>
```
_This will copy list and gpg keys to your system,
and all you have to do is to install the app._

If you want to contribute to the list of apps,
please install the repo for the app first with:

```bash
apt apr
```
Follow the promts to ensure the list and key will correspond with the **appname**.
Then you can open a pull request with the generated list and key.

Once approved, they will be added to the repo for everyone to use.

#### Note
The lists provided are used on Debian bookworm
If you use any other distro, you may need to edit the repo.
```bash
apt es <APP>
```
Will let you edit the corresponding sources list.

## Uninstalling

```bash
sudo rm /usr/bin/apt-wrapper
```
```bash
sudo rm -rf $HOME/Documents/GitHub/apt-wrapper
```
Remove what was Added to .bashrc / .zshrc etc...

## Credits

- Inspired by: [Itai-Nelken/aptpac](https://github.com/Itai-Nelken/aptpac)
- scolors [swelljoe/scolors](http://github.com/swelljoe/scolors)
- PeterDaveHello/add-apt-ppa [PeterDaveHello/add-apt-ppa](https://github.com/PeterDaveHello/add-apt-ppa)
- timothyvanderaerden/add-apt-repository [timothyvanderaerden/add-apt-repository](https://github.com/timothyvanderaerden/add-apt-repository)
- deb-get [wimpysworld/deb-get](https://github.com/wimpysworld/deb-get) ([License - MIT](https://github.com/wimpysworld/deb-get/blob/main/LICENSE))
- update git submodules [A small Bash script to update git submodules.](https://gist.github.com/gregkrsak/8812057)

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
