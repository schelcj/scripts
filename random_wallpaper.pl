#!/usr/bin/env perl

use Modern::Perl;
use Readonly;
use DB_File;
use System::Command;
use File::Slurp qw(read_file);
use Getopt::Compact;

Readonly::Scalar my $PREFIX        => qq($ENV{HOME}/.wallpapers);
Readonly::Scalar my $LOCK          => qq{$PREFIX/lock};
Readonly::Scalar my $HISTORY       => qq{$PREFIX/history};
Readonly::Scalar my $WALLPAPER_DIR => qq{$PREFIX/Dropbox/Media/Pictures/Wallpapers};
Readonly::Scalar my $BGSETTER      => q{fbsetbg};
Readonly::Scalar my $DISPLAY       => read_file(q{$PREFIX} / display);

## no tidy
my $opts = Getopt::Compact->new(
  struct => [
    [[qw(f foo)], q(desc)],
  ]
)->opts();
## end no tidy

my %hist = ();
tie %hist, 'DB_File', $HISTORY;    ## no critic (ProhibitTies)
