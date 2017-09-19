# vim: set ft=perl

use Rex -base;
use Rex::Commands::File;
use Rex::Commands::Fs;
use Rex::Commands::SCM;
use Rex::Commands::Service;

# XXX - sudo required for these tasks
task 'prereqs' => sub {
  pkg &_packages_install(), ensure => 'present';
  pkg &_packages_remove(),  ensure => 'absent';
};

task 'setup_suspend' => sub {
  file '/etc/sudoers.d/pm-suspend',
    content => '%sudo ALL = NOPASSWD: /usr/sbin/pm-suspend';
};

task 'setup_dropbox_watches', => sub {
  file "/etc/sysctl.d/20-dropbox.conf",
    content => 'fs.inotify.max_user_watches=100000';
};

task 'enable_dunst' => sub {
  run('mv /usr/share/dbus-1/services/org.freedesktop.Notifications.service{,.disabled}');
};

batch 'prepare', (
  qw(
    prereqs
    setup_suspend
    setup_dropbox_watches
    enable_dunst
  );
);

# XXX - sudo not required for these tasks
task 'setup_dropbox' => sub {
  run('wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -');

  symlink("$ENV{HOME}/Dropbox/bin", "$ENV{HOME}/bin");
  symlink("$ENV{HOME}/Dropbox/Documents", "$ENV{HOME}/Documents");
};

task 'setup_home_dir' => sub {
  for (qw(src tmp perl5 .local/share/applications .config)) {
    mkdir("$ENV{HOME}/$_"), unless => "test -d $ENV{HOME}/$_";
  }
};

task 'setup_dotfiles' => sub {
  set repository => 'dotfiles', url => 'git@github.com:schelcj/dotfiles.git', type => 'git';
  checkout 'dotfiles', path => "$ENV{HOME}/.dotfiles";
};

task 'set_defaults' => sub {
  run('xdg-mime default google-chrome.desktop text/html');
  run('xdg-mime default google-chrome.desktop x-scheme-handler/http');
  run('xdg-mime default google-chrome.desktop x-scheme-handler/https');
};

task 'setup_wallpapers' => sub {
  mkdir("$ENV{HOME}/.wallpapers");

  cron add => $ENV{USER}, {
    minute       => '*/15',
    hour         => '*',
    day_of_month => '*',
    day_of_week  => '*',
    command      => "$ENV{HOME}/bin/change-wallpaper",
  };
};

task 'setup_rtm' => sub {
  run('pip install rtm');
};

sub _packages_install {
  return [qw(
    xscreensaver
    xscreensaver-data
    xscreensaver-gl
    xscreensaver-gl-extra
    xscreensaver-screensaver-bsod
    xscreensaver-screensaver-dizzy
    xscreensaver-screensaver-webcollage
    tmux
    most
    dstat
    iotop
    htop
    powertop
    nmap
    wireshark
    traceroute
    scrot
    mc
    colortail
    openvpn
    network-manager-openvpn
    network-manager-vpnc
    cifs-utils
    libxml2-dev
    libexpat1-dev
    htmldoc
    ubuntu-restricted-extras
    git
    vim
    vim-gnome
    exuberant-ctags
    perl-doc
    liblocal-lib-perl
    libcrypt-ssleay-perl
    mosh
    feh
    aumix-gtk
    keepassx
    libxss1
    remmina
    remmina-plugin-nx
    remmina-plugin-vnc
    remmina-plugin-rdp
    libxinerama-dev
    libxft-dev
    libxss-dev
    libxdg-basedir-dev
    libpango1.0-dev
    libdbus-1-dev
    libnotify-dev
    mplayer
    libao-dev
    libmad0-dev
    libfaad-dev
    libgnutls-dev
    libjson0-dev
    libgcrypt11-dev
    smartmontools
    ruby-ronn
    stow
    mercurial
    libssl-dev
    libcurl4-gnutls-dev
    asciidoc
    evtest
    k3b
    libavfilter-dev
    libavformat-dev
    colordiff
    gpick
    python-simplejson
    python-parsedatetime
    python-vobject
    python-markdown
    python-setuptools
    python-pip
    xpad
    clipit
    weather-util
    inxi
    redshift-gtk
    rxvt-unicode
    rofi
    curl
  )];
}

sub _packages_remove {
  return [qw(
    gnome-screensaver
  )];
}
