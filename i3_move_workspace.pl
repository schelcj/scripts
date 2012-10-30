#!/usr/bin/env perl

use Modern::Perl;
use English qw(-no_match_vars);
use Data::Dumper;
use AnyEvent::I3 qw(:all);

my $i3 = i3();
$i3->connect->recv or die qq{Error connecting $OS_ERROR};
my $tree = $i3->get_tree->recv;

print Dumper $tree;

