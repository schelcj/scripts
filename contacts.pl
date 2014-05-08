#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Class::CSV;
use File::Slurp qw(append_file);

my $CONTACTS = qq{$Bin/../Dropbox/Apps/IFTTT/iOS_Contacts/any_new_contact.txt};
my $ALIASES  = qq{$Bin/../.aliases};

my $csv = Class::CSV->parse(
  filename => $CONTACTS,
  fields   => [qw(name email phone addr org title date notes)]
);

my @lines = @{$csv->lines};
shift @lines;

for my $line (sort {$a->name cmp $b->name} @lines) {
  (my $alias = $line->name) =~ s/\s+/_/g;
  my $entry  = sprintf "alias %s %s %s\n", lc($alias), $line->name, $line->email;
  append_file($ALIASES, $entry);
}
