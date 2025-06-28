#!/usr/bin/env perl

use v5.38;
use Data::Dumper;
use DateTime;
use File::Basename;
use File::Spec;
use IO::All;
use Mojo::Template;

my $mt          = Mojo::Template->new();
my $template    = do {local $/; <DATA>};
my $journal_dir = File::Spec->join($ENV{HOME}, 'Dropbox', 'Wikis', 'Journal');
my $output_dir  = File::Spec->join($ENV{HOME}, 'MigratedJournal');
my $archive_dir = File::Spec->join($ENV{HOME}, 'Dropbox', 'Archives', 'Wikis', 'Journal');
my @entries     = io->dir($journal_dir)->all;

for my $entry (@entries) {
  next if $entry->name =~ /index/;

  print 'migrating ' . $entry->name;

  my ($filename, $dirs, $suffix) = fileparse($entry->name, qr/\.[^.]*/);
  my ($year, $month, $day) = split(/-/, $filename);
  my $dt      = DateTime->new(year => $year, month => $month, day => $day);
  my $content = $entry->slurp();

  my $params = {
    dt            => $dt,
    content       => $content,
    original_file => File::Spec->join($archive_dir, $filename . $suffix),
    original_name => $filename . $suffix,
  };

  my $new_entry_content = $mt->vars(1)->render($template, $params);
  my $new_entry_file    = File::Spec->join($output_dir, $filename . '.org');

  $new_entry_content > io($new_entry_file);

  say ' - done';
}

__DATA__
* <%= $dt->day_name %>, <%= $dt->strftime('%d') %> <%= $dt->month_name %> <%= $dt->year %>

<%= $content %>

migrated_from: [[file+emacs:<%= $original_file %>][<%= $original_name %>]]
