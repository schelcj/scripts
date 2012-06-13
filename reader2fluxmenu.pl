#!/usr/bin/env perl

use Modern::Perl;
use Net::Netrc;
use WebService::Google::Reader;
use HTML::Template;
use HTML::Entities;
use File::Basename;
use File::Slurp qw(write_file);
use List::MoreUtils qw(any);

my $params   = {};
my $menu     = qq[$ENV{HOME}/Dropbox/dot-files/fluxbox/menu.rss];
my @excludes = (qw(starred broadcast blogger-following));
my $template = HTML::Template->new(filehandle => \*DATA, utf8 => 1);
my $mach     = Net::Netrc->lookup('google.com');
my $reader   = WebService::Google::Reader->new(
  username => $mach->login,
  password => $mach->password,
);

for my $tag ($reader->tags) {
  my $title = basename($tag->id);
  next if any {$_ eq $title} @excludes;

  my %query_params = (tag => $title, state => 'unread');
  my $feed = $reader->search('fresh', %query_params);
  next if not $feed;

  push @{$params->{tags}}, {
    name    => decode_entities($title),
    entries => [map {
      {
        entry => decode_entities($_->title),
        url   => $_->link->href
      }
    } $feed->entries()],
  };
}

$template->param($params);
write_file($menu, $template->output());

__DATA__
<tmpl_loop name="tags">
  [submenu] (<tmpl_var name="name">)
  <tmpl_loop name="entries">
    [exec] (<tmpl_var name="entry">) {google-chrome <tmpl_var name="url">}
  </tmpl_loop>
  [end]
</tmpl_loop>
