#!/usr/bin/env perl

use Modern::Perl;
use File::KeePass;
use File::Spec;
use IO::Prompt;

my $db     = prompt('Database: ');
my $pass   = prompt('Password: ', -e => '*');
my $search = prompt('Search: ');
my $k      = File::KeePass->new;

$k->load_db(File::Spec->join($ENV{HOME}, 'Dropbox/Private/keepassx', $db . q{.kdb}), $pass);
my @entries = $k->find_entries({title => $search});

$k->unlock;

say 'No matching entries found' and exit if not @entries;

map {
  say 'Title: ' . $_->{title} . ' Password: ' . $_->{password}
} @entries;
