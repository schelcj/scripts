#!/usr/bin/env perl

use Modern::Perl;
use WWW::Google::Contacts;
use Net::Netrc;
use Class::CSV;
use System::Command;
use File::Slurp qw(write_file overwrite_file);
use File::Temp;

my $addressbook = qq[$ENV{HOME}/Dropbox/dot-files/abook/addressbook];
my $abook_cmd = q{abook --convert --outformat abook --informat csv --infile };
my @accounts  = (qw(google.com umich.google.com));
my $temp_fh   = File::Temp->new();
my $csv       = Class::CSV->new(fields => [qw(name emails)]);

foreach my $account (@accounts) {
  my $mach     = Net::Netrc->lookup($account);
  my $google   = WWW::Google::Contacts->new(username => $mach->login, password => $mach->password);
  my $contacts = $google->contacts();

  while (my $contact = $contacts->next) {
    next if not $contact->email;
    next if not $contact->full_name;

    $csv->add_line([$contact->full_name, join(q{,}, (map {$_->value} @{$contact->email}))]);
  }
}

write_file($temp_fh->filename, $csv->string);
my $abook_fh = System::Command->new($abook_cmd . $temp_fh->filename)->stdout;
overwrite_file($addressbook, <$abook_fh>);
$abook_fh->close;
