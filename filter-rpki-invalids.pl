#!/usr/bin/env perl
$/ = "\n\n";
while (<>) {
  next unless /rpki-ov-state:\h*invalid/i;
  print $_;
}
