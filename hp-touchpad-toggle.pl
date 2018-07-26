#!/usr/bin/env perl

use FindBin;
use lib qq($FindBin::Bin/../perl5/lib/perl5);

use Modern::Perl;
use IO::All;

my $file = "$ENV{HOME}/.hp-touchpad-state";
'enable' > io($file) unless -e $file;

for (io->pipe('xinput')->chomp->getlines()) {
  next unless /ALP000/;

  if (/id=([^\s]+)/) {
    my $state  = io($file)->all;
    my $toggle = ($state eq 'disable') ? 'enable' : 'disable';

    system("xinput $toggle $1");

    $toggle > io($file);
  }
}
