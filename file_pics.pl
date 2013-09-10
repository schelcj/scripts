#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);
use English qw(-no_match_vars);
use Carp qw(croak);

my $CTIME = 9;
my $BASE  = '/home/schelcj/Media/Pictures';

opendir DIR, "$BASE/unfiled" or croak $ERRNO;

for (readdir(DIR)) {
  next if $ARG =~ /^\.+/m;
  my $file  = sprintf '%s/unfiled/%s', $BASE, $ARG;
  my @stats = stat $file;
  my $year  = strftime('%Y',localtime $stats[$CTIME]);
  my $month = strftime('%m',localtime $stats[$CTIME]);

  my $year_dir = sprintf '%s/%d', $BASE, $year;
  my $dir      = sprintf '%s/%.2d', $year_dir, $month;
  my $final    = sprintf '%s/%s', $dir, $ARG;

  mkdir $year_dir if not -e $year_dir;
  mkdir $dir if not -e $dir;

  print "Moving $ARG to $final - ";

  rename $file, $final or croak $ERRNO;

  print "Done\n";
}

closedir DIR or croak $ERRNO;

