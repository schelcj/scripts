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

my $BASE     = '/home/schelcj/Media/Home Movies';
my $dest_dir = YASF->new('{base}/{year}/{month}');

for my $file (io->dir("$BASE/unfiled")->all_files) {
  my $stat  = File::Stat->new($file->name);

  my $dir = $dest_dir % {
    base  => $BASE,
    year  => strftime('%Y',localtime $stat->ctime),
    month => strftime('%m',localtime $stat->ctime),
  };

  make_path($dir) unless -e $dir;
  my $final = File::Spec->join($dir, basename($file));

  print "Moving $file to $final - ";

  rename $file, $final or croak $ERRNO;

  print "Done\n";
}
