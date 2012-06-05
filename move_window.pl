#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;
use System::Command;

my $cmd_str = q{zenity --list --text "Select Window" --column "Title"};
my $wmctrl  = System::Command->new(q{wmctrl -l});
my $stdout  = $wmctrl->stdout();

while (<$stdout>) {
  my ($id,$desktop,$host,@title) = split(/\s+/);
  my $title = join(' ', @title);
  $cmd_str .= qq[ "$title"];
}

print Dumper $cmd_str;
