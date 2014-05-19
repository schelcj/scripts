#!/usr/bin/env perl

use Modern::Perl;
use IPC::System::Simple qw(capture run);
use Time::Piece;

my $nb    = q{'03 Journal'};
my $now   = Time::Piece->new();
my $title = $now->strftime('%Y-%m-%d');

given (capture(qq{geeknote find --search $title --notebooks $nb --exact-entry})) {
  when (/Total found: 0/) {
    run(qq{geeknote create --title $title --notebook $nb --content WRITE});
  }

  when (/Total found: 1/) {
    run(qq{geeknote edit --note $title});
  }

  default {
    say 'ACK, too many matches! Bailing out!';
    exit 1;
  }
}
