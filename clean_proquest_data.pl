#!/usr/bin/env perl

use Modern::Perl;
use File::Slurp qw(read_file);
use IO::Scalar;
use Class::CSV;
use List::MoreUtils qw(firstidx none);
use Data::Dumper;

## no tidy
my @header_map = (
  [Author  => 'name'],
  [Role    => 'role'],
  [Advisor => 'committee_member'],
  [Year    => 'term'],
  [Title   => 'title'],
);
## use tidy

my $csv       = Class::CSV->new(fields => [map {$_->[1]} @header_map]);
my $separator = q{____________________________________________________________};
my @lines     = ();
my @documents = ();

{
  local $/ = $separator;
  @lines = read_file($ARGV[0]);
}

$csv->add_line({map {$_->[1] => $_->[1]} @header_map});

for my $line (@lines) {
  chomp($line);
  next if not $line;
  next if $line eq $separator;
  next if none {$line =~ /$_/} map {$_->[0]} @header_map;

  my $line_fh      = IO::Scalar->new(\$line);
  my @doc_lines    = map {$_} $line_fh->getlines;
  my $document_ref = {role => 'CHAI'};

  for my $doc_line (@doc_lines) {
    $doc_line =~ s/[\n\r]+//g;
    next if not $doc_line;
    next if $doc_line eq $separator;

    my ($name, $value) = split(/:/, $doc_line);

    $name  =~ s/^\s+//g;
    $value =~ s/^\s+//g if $value;

    if (grep {/$name/} map {$_->[0]} @header_map) {
      my $header_idx = firstidx {$_ eq $name} map {$_->[0]} @header_map;
      $document_ref->{$header_map[$header_idx]->[1]} = $value;
    }
  }

  $csv->add_line($document_ref);
}

say $csv->string();
