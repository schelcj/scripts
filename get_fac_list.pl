#!/usr/bin/env perl

use Modern::Perl;
use Mojo::UserAgent;
use File::Slurp qw(read_file);
use List::MoreUtils qw(any);

my $url = q{http://www.sph.umich.edu/iscr/faculty/dept.cfm?deptID=1};
my $css = q{tr td.list a strong};
my @fac = read_file(qq[$ENV{HOME}/faculty.txt], {chomp => 1});
my $ua  = Mojo::UserAgent->new();
my $dom = $ua->get($url)->res()->dom();

$dom->find($css)->each(
  sub {
    my ($e, $i) = @_;
    my ($name)  = split(/,/, $e->text);
    return if any {lc($_) eq lc($name)} @fac;
    say $name;
  }
);
