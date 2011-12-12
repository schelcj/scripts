#!/usr/bin/env perl

use Modern::Perl;
use Carp qw(confess);
use Readonly;
use DB_File;
use System::Command;
use File::Slurp qw(read_file read_dir write_file);
use Getopt::Compact;
use Data::Dumper;

Readonly::Scalar my $PREFIX        => qq($ENV{HOME}/.wallpapers);
Readonly::Scalar my $LOCK          => qq{$PREFIX/lock};
Readonly::Scalar my $HISTORY       => qq{$PREFIX/history};
Readonly::Scalar my $CATEGORY      => qq{$PREFIX/category};
Readonly::Scalar my $WALLPAPER_DIR => qq{$PREFIX/Wallpapers};
Readonly::Scalar my $BGSETTER      => q{fbsetbg};
Readonly::Scalar my $BGSETTER_OPTS => q{-a};
Readonly::Scalar my $DISPLAY       => qq{$PREFIX/display};
Readonly::Scalar my $SLASH         => q{/};

## no tidy
my $opts = Getopt::Compact->new(
  struct => [
    [[qw(c category)],    q(Wallpaper category),   ':s'],
    [[qw(r resolution)],  q(Wallpaper resolution), ':s'],
    [[qw(f flush-cache)], q(Flush the wallpaper cache) ],
    [[qw(d dump-cache)],  q(Dump the wallpaper cache)  ],
  ]
)->opts();
## end no tidy

my %history       = ();
my @wallpapers    = ();
my $category      = 'all';
my $wallpaper_dir = qq{$PREFIX/all};

tie %history, 'DB_File', $HISTORY; ## no critic (ProhibitTies)

if ($opts->{category}) {
  $wallpaper_dir = join($SLASH, $WALLPAPER_DIR, $opts->{category});
  confess qq{Wallpaper category ($wallpaper_dir) does not exist} if not -e $wallpaper_dir;

  $category = $opts->{category};
  write_file($CATEGORY, $category);
}

if ($opts->{resolution} and $opts->{category}) {
  $wallpaper_dir = join($SLASH, $WALLPAPER_DIR, $opts->{category}, $opts->{resolution});
  confess qq{Wallpaper resolution ($wallpaper_dir) does not exist} if not -e $wallpaper_dir;
}

if ($opts->{'flush-cache'}) {
  flush_cache(\%history);
  exit;
}

if ($opts->{'dump-cache'}) {
  print {*STDOUT} Dumper \%history;
  exit;
}

for my $wallpaper (read_dir($wallpaper_dir)) {
  push @wallpapers, join($SLASH, $wallpaper_dir, $wallpaper);
}

sub _set {
  my $set_paper = 0;
  while (my $paper = get_random_wallpaper(\@wallpapers)) {
    if (not is_cached(\%history, $paper)) {
      set_wallpaper($paper);
      cache(\%history, $paper);
      $set_paper = 1;
      last;
    }
  }

  if (not $set_paper) {
    flush_cache();
  } else {
    return;
  }

  return _set();
}

_set();

sub get_display {
  return read_file($DISPLAY);
}

sub get_bgsetter {
  return sprintf q{%s %s}, $BGSETTER, $BGSETTER_OPTS;
}

sub get_random_wallpaper {
  my ($papers) = @_;
  my $pos      = int(rand(scalar @{$papers}));
  my $paper    = $papers->[$pos];

  splice(@{$papers}, $pos, 1);

  return $papers->[$pos];
}

sub set_wallpaper {
  my ($paper) = @_;
  my $cmd_str = sprintf q{DISPLAY=%s %s %s}, get_display(), get_bgsetter(), $paper;
  my $cmd     = System::Command->new($cmd_str);
  my $stdout  = $cmd->stdout();

  while (<$stdout>) { print $_ }
  $cmd->close();

  return;
}

sub cache {
  my ($hist,$paper) = @_;
  $hist->{$paper} = 1;
  return;
}

sub is_cached {
  my ($hist,$paper) = @_;
  return exists $hist->{$paper};
}

sub flush_cache {
  my ($hist) = @_;
  %{$hist} = ();
  return;
}
