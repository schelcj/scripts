#!/usr/bin/env perl

use Modern::Perl;
use IPC::System::Simple qw(capture run);

my $nb    = q{'02 My Notebook'};
my $title = q{Procrastination};

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
