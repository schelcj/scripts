#!/usr/bin/env perl

use v5.38;
use Data::Dumper;
use File::Basename;
use File::Stat::OO;
use IO::All;
use Mojo::Template;

my $template = do { local $/; <DATA> };
my @notes    = io->dir('/home/schelcj/Dropbox/Notes')->all;

for my $note (@notes) {
  print 'migrating ' . $note->name;

  my $mt   = Mojo::Template->new();
  my $stat = File::Stat::OO->new({use_datetime => 1});
  my $content = $note->slurp;

  $stat->stat($note->name);

  my $mtime      = $stat->mtime;
  my $date_ident = $mtime->ymd('') . 'T' . $mtime->hms('');
  my ($filename, $dirs, $suffix) = fileparse($note->name, qr/\.[^.]*/);

  my @tags = do {
    my @lines = $note->getlines;
    if ($lines[1] =~ /^@/) {
      map {s/@//rg} split(/\s/, $lines[1]);
    } else {
      ();
    }
  };

  push @tags, (qw(nv vimpad migrated));

  my $denote_filename = sprintf '%s--%s__%s.%s', $date_ident, $filename, join('_', @tags), $note->ext;
  my $params          = {
    title      => $filename,
    date       => join(' ', $mtime->ymd('-'), $mtime->day_abbr, $mtime->hour_12_0 . ':' . $mtime->second),
    date_ident => $date_ident,
    tags       => join(':', @tags),
    content    => $content,
  };

  my $new_note_contents = $mt->vars(1)->render($template, $params);

  $new_note_contents > io('/home/schelcj/MigratedNotes/' . $denote_filename);

  say ' - done';
}

__DATA__
#+title: <%= $title %>
##+date: [<%= $date %>]
##+filetags: :<%= $tags %>:
##+identifier: <%= $date_ident %>

<%= $content %>
