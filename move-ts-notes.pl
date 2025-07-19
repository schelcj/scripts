#!/usr/bin/env perl
#
use v5.38;
use Data::Dumper;
use DateTime;
use File::Basename;
use File::Spec;
use File::Stat::OO;
use IO::All;

my $archive_dir  = File::Spec->join($ENV{HOME}, 'Dropbox', 'Archives', 'Tagspaces');
my $output_dir   = File::Spec->join($ENV{HOME}, 'MigratedNotes');
my @notes        = io->dir($archive_dir)->all;
my @default_tags = (qw(tagspaces));

for my $note (@notes) {
  print 'migrating ' . $note->name;

  my @tags    = ();
  my $stat    = File::Stat::OO->new({use_datetime => 1});
  my $content = $note->slurp;

  $stat->stat($note->name);

  my $mtime      = $stat->mtime;
  my $date_ident = $mtime->ymd('') . 'T' . $mtime->hms('');
  my ($filename, $dirs, $suffix) = fileparse($note->name, qr/\.[^.]*/);
  my $ext = $suffix =~ s/^.//gr;

  my $denote_title = do {
    if ($filename =~ /^(.*) \[ ([^\]]+) \] $/x) {
      push @tags, (split(/\s/, $2));
      $1;
    } else {
      $filename;
    }
  };

  $denote_title =~ s/\s+/-/g;
  $denote_title =~ s/\-$//g;
  $denote_title =~ s/_/-/g;
  $denote_title =~ s/,//g;
  $denote_title =~ s/[^\x00-\x7F]//g;
  $denote_title =~ s/['&!();\[\]`+=]//g;

  push @tags, @default_tags;

  my $note_content = do {
    if ($ext eq 'mhtml') {
      my $cmd = sprintf '~/go/bin/mhtml2html "%s"', $note->name;
      $ext = 'html';
      io->pipe($cmd)->slurp;
    } else {
      $content;
    }
  };

  my $denote_filename = do {
    my $tag_str = join('_', @tags);
    my $name    = sprintf '%s--%s__%s.%s', $date_ident, $denote_title, $tag_str, $ext;

    if (length($name) > 142) {
      my $tag_string = join('_', @tags);
      my $length     = length($date_ident) + length($tag_str) + length($ext) + 4;
      sprintf '%s--%s__%s.%s', $date_ident, substr($denote_title, 0, (142 - $length)), $tag_str, $ext;
    } else {
      $name;
    }
  };

  my $new_note_file = File::Spec->join($output_dir, $denote_filename);
  $note_content > io($new_note_file);
  say ' - done';
}
