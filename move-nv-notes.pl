#!/usr/bin/env perl

use v5.38;
use Data::Dumper;
use DateTime;
use File::Basename;
use File::Spec;
use File::Stat::OO;
use IO::All;
use Mojo::Template;

my $db_dir       = File::Spec->join($ENV{HOME}, 'Dropbox');
my $note_dir     = File::Spec->join($db_dir,    'NV');
my $archive_dir  = File::Spec->join($db_dir,    'Archives', 'Notes');
my $output_dir   = File::Spec->join($ENV{HOME}, 'MigratedNotes');
my @notes        = io->dir($note_dir)->all;
my %blocks       = ();
my $current      = undef;
my $mt           = Mojo::Template->new();
my $now          = DateTime->now();
my $migrated_on  = join(' ', $now->ymd('-'), $now->day_abbr, $now->hms);
my @default_tags = (qw(vimpad));

while (<DATA>) {
  chomp;
  if (/^@@(\w+)/) {
    $current = $1;
    $blocks{$current} = '';
  } elsif (defined $current) {
    $blocks{$current} .= "$_\n";
  }
}

for my $note (@notes) {
  print 'migrating ' . $note->name;

  my $stat    = File::Stat::OO->new({use_datetime => 1});
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
  push @tags, @default_tags;

  my $vim_pad_mode = undef;
  my $vim_filetype = do {
    if ($content =~ /vim: set ft=([^:]+):/) {
      $vim_pad_mode = $1;
      $1;
    } elsif ($content =~ /vim:ft=vimwiki/) {
      $vim_pad_mode = 'vimwiki';
      'vimwiki';
    } elsif ($content =~ /mode:\h+(org|markdown)/) {
      $vim_pad_mode = $1;
      $1;
    } else {
      $vim_pad_mode = 'txt';
      'txt';
    }
  };

  my $note_content = do {
    if ($vim_filetype =~ /vimwiki/) {
      my $cmd = sprintf 'pandoc --wrap preserve %s -f vimwiki -t org -o -', $note->name;
      io->pipe($cmd)->slurp;
    } else {
      $content;
    }
  };

  my $ext = do {
    if ($vim_pad_mode =~ /vimwiki/) {
      'org';
    } elsif ($vim_pad_mode =~ /markdown/) {
      'md';
    } elsif ($vim_pad_mode =~ /org/) {
      'org';
    } else {
      $note->ext;
    }
  };

  my $denote_title = $filename;
  $denote_title =~ s/\s+/-/g;
  $denote_title =~ s/\[|\]/-/g;
  $denote_title =~ s/\-$//g;

  my $denote_filename = sprintf '%s--%s__%s.%s', $date_ident, $denote_title, join('_', @tags), $ext;

  my $params = {
    title             => $filename,
    date              => join(' ', $mtime->ymd('-'), $mtime->day_abbr, $mtime->hms),
    date_ident        => $date_ident,
    tags              => join(':', @tags),
    content           => $note_content,
    original_filename => File::Spec->join($archive_dir, $filename . $suffix),
    migrated_on       => $migrated_on,
  };

  $params->{front_matter} = do {
    if ($vim_filetype eq 'markdown') {
      $mt->vars(1)->render($blocks{'front_matter_markdown'}, $params);
    } else {
      $mt->vars(1)->render($blocks{'front_matter_org'}, $params);
    }
  };

  my $new_note_contents = $mt->vars(1)->render($blocks{'template'}, $params);
  my $new_note_file     = File::Spec->join($output_dir, $denote_filename);

  $new_note_contents > io($new_note_file);

  say ' - done';
}

__DATA__
@@front_matter_org
#+title: <%= $title %>
#+date: [<%= $date %>]
#+filetags: :<%= $tags %>:
#+identifier: <%= $date_ident %>
#+original: <%= $original_filename %>
#+migrated_on: [<%= $migrated_on %>]

@@front_matter_markdown
---
title:       "<%= $title %>"
date:        [<%= $date %>]
filetags:    [<%= join(',', map {sprintf('"%s"', $_)} split(/:/, $tags)) %>]
identifier:  "<%= $date_ident %>"
original:    "<%= $original_filename %>"
migrated_on: [<%= $migrated_on %>]
---

@@template
<%= $front_matter %>

<%= $content %>
