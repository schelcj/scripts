#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;

use Mojo::UserAgent;

my $path = q{html body div#content table.menutable tr};
my $url  = q{http://somafm.com/playlist/};
my $ua   = Mojo::UserAgent->new();

$ua->get($url)->res->dom->find($path)->each(
  sub {
    print Dumper $_->find('td ');

  }
);

