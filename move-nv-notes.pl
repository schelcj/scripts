#!/usr/bin/env perl

use v5.38;
use Data::Dumper;
use File::Basename;
use File::Stat::OO;
use IO::All;

my @notes = io->dir('/home/schelcj/Dropbox/Notes')->all;

for my $note (@notes) {
  my $stat = File::Stat::OO->new({use_datetime => 1});
  $stat->stat($note->name);

  my $date   = $stat->mtime->ymd('') . 'T' . $stat->mtime->hms('');
  my ($name) = fileparse($note->name);
  my @lines  = $note->getlines;

  if ($lines[0] =~ /^#+TITLE: (.*)$)/) {
  }

  print Dumper sprintf '%s--%s__%s.%s', $date, $name, 'foo', $note->ext;
}
