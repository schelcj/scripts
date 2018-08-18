#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw(strftime);
use English qw(-no_match_vars);
use Carp qw(croak);
use File::Basename;
use File::Path qw(make_path);
use File::Spec;
use File::Stat;
use IO::All;
use YASF;

my $BASE     = '/home/schelcj/Media/Pictures';
my $dest_dir = YASF->new('{base}/{year}/{month}');

for my $file (io->dir("$BASE/2018/08")->all_files) {
  my $stat  = File::Stat->new($file->name);

  my $dir = $dest_dir % {
    base  => $BASE,
    year  => strftime('%Y',localtime $stat->mtime),
    month => strftime('%m',localtime $stat->mtime),
  };

  make_path($dir) unless -e $dir;
  my $final = File::Spec->join($dir, basename($file));

  next if $file eq $final;

  print "Moving $file to $final - ";

  unless (rename($file, $final)) {
    print "Failed\n";
  } else {
    print "Done\n";
  }
}
