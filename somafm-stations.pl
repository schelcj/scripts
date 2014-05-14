#!/usr/bin/env perl

use Modern::Perl;
use Mojo::UserAgent;
use Mojo::DOM;
use List::MoreUtils qw(uniq);

my $somafm_url = q{http://somafm.com};
my $agent      = Mojo::UserAgent->new();
my $dom        = Mojo::DOM->new($agent->get($somafm_url)->res->body);
my %hosts      = ();
my @stations   = ();

$dom->find('li.cbshort')->each(
  sub {
    my $node = shift;
    (my $station_name = $node->at('a:first-child')->attr('href')) =~ s/\///g;
    my $station_title = $node->at('h3')->text();

    push @stations, [$station_title, $station_name];
  }
);

for my $station (@stations) {
  my $url = sprintf qq{$somafm_url/startstream=%s.pls}, $station->[1];
  my $asset = $agent->get($url)->res->content->asset;

  my $content = $asset->slurp;
  while ($content =~ m/File\d+=(.*)/g) {
    my $uri = URI->new($1);
    push @{$hosts{$uri->host}{ports}}, $uri->port;
  }
}

for my $host (keys %hosts) {
  say $host . ': ' . join(',', uniq @{$hosts{$host}{ports}});
}
