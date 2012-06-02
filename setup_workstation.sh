#!/bin/sh

# TODO - install various perl modules (perlcritic,ack,perltidy et al)

function install_packages() {
  sudo add-apt-repository ppa:vicox/syspeek
  sudo add-apt-repository ppa:atareao/atareao
  sudo add-apt-repository ppa:jaap.karssenberg/zim
  sudo apt-get update

  sudo apt-get remove gnome-screensaver
  sudo apt-get install \
    vim vim-gnome ctags \
    gnome-do \
    xscreensaver \
    xscreensaver-data \
    xscreensaver-gl \
    xscreensaver-gl-extra \
    xscreensaver-screensaver-bsod \
    xscreensaver-screensaver-dizzy \
    xscreensaver-screensaver-webcollage \
    zim \
    liblocal-lib-perl \
    syspeek \
    my-weather-indicator \
    tmux most dstat iotop fluxbox htop nmap \
    traceroute git \
    openvpn network-manager-openvpn
}

function setup_wallpapers() {
  mkdir ~/.wallpapers
  ln -s ~/Dropbox/Media/Pictures/Wallpapers ~/.wallpapers/Wallpapers

  echo "4walled" > ~/.wallpapers/sources
  echo "Astro" >> ~/.wallpapers/sources
  echo "deviantart" >> ~/.wallpapers/sources
  echo "digitalblasphemy" >> ~/.wallpapers/sources
  echo "Interfacelift" >> ~/.wallpapers/sources
  echo "Mandolux" >> ~/.wallpapers/sources
  echo "Misc" >> ~/.wallpapers/sources
  echo "Pics" >> ~/.wallpapers/sources
  echo "SimpleDesktops" >> ~/.wallpapers/sources
  echo "wallbase" >> ~/.wallpapers/sources
}

function setup_homedir() {
  mkdir ~/perl5 ~/src ~/projects ~/tmp

  ln -s ~/Dropbox/bin ~/
  ln -s ~/Dropbox/dot-files/fluxbox ~/.fluxbox
  ln -s ~/Dropbox/dot-files/vim ~/.vim
  ln -s ~/Dropbox/dot-files/vimrc ~/.vimrc
  ln -s ~/Dropbox/dot-files/gvimrc ~/.gvimrc
  ln -s ~/Dropbox/dot-files/tmux.conf ~/.tmux.conf
  ln -s ~/Dropbox/dot-files/todo ~/.todo
}

function setup_perl_env() {
  cpanm Modern::Perl Readonly::XS System::Command Getopt::Compact
  cpanm File::Slurp File::Find::Object
}

install_packages
setup_homedir
setup_wallpapers

# fix gnome-terminal menubar bug in ubuntu
sudo sed -i 's/export UBUNTU_MENU/echo ""; # export UBUNTU_MENU/g' /etc/X11/Xsession.d/80appmenu
sudo sed -i 's/export UBUNTU_MENU/echo ""; # export UBUNTU_MENU/g' /etc/X11/Xsession.d/80appmenu-gtk

# change the default path for the lastwallpaper to avoid dropbox traffic/popups
sudo sed -i 's/lastwallpaper="${HOME}\/.fluxbox\/lastwallpaper"/lastwallpaper="${HOME}\/.wallpapers\/last"/g' $(which fbsetbg)

echo "source ${HOME}/Dropbox/dot-files/bash/bashrc" >> ~/.bashrc
ln -s ${HOME}/.bashrc ${HOME}/.bash_profile


