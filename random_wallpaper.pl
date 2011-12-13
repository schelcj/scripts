#!/usr/bin/env perl

use FindBin qw($Bin);
use local::lib qq{$Bin/../perl5};
use Modern::Perl;
use Carp qw(confess);
use Readonly;
use DB_File;
use System::Command;
use File::Slurp qw(read_file read_dir write_file append_file);
use Getopt::Compact;
use Data::Dumper;

Readonly::Scalar my $PREFIX           => qq($ENV{HOME}/.wallpapers);
Readonly::Scalar my $LOCK             => qq{$PREFIX/lock};
Readonly::Scalar my $HISTORY          => qq{$PREFIX/history};
Readonly::Scalar my $CATEGORY         => qq{$PREFIX/category};
Readonly::Scalar my $WALLPAPER_DIR    => qq{$PREFIX/Wallpapers};
Readonly::Scalar my $CURRENT          => qq{$PREFIX/current};
Readonly::Scalar my $RESOLUTION       => qq{$PREFIX/resolution};
Readonly::Scalar my $LOG              => qq{$PREFIX/log};
Readonly::Scalar my $BGSETTER         => q{fbsetbg};
Readonly::Scalar my $BGSETTER_OPTS    => q{-a};
Readonly::Scalar my $SLASH            => q{/};
Readonly::Scalar my $DEFAULT_CATEGORY => q{all};

## no tidy
my $opts = Getopt::Compact->new(
  struct => [
    [[qw(c category)],    q(Wallpaper category),          ':s'],
    [[qw(r resolution)],  q(Wallpaper resolution),        ':s'],
    [[qw(f flush-cache)], q(Flush the wallpaper cache)        ],
    [[qw(d dump-cache)],  q(Dump the wallpaper cache)         ],
    [[qw(l lock)],        q(Lock the current paper)           ],
    [[qw(u unlock)],      q(Unlock the current paper)         ],
    [[qw(clear)],         q(Clear previous category/resoution)],
  ]
)->opts();
## end no tidy

exit if -e $LOCK and not $opts->{unlock};

my %history = ();
tie %history, 'DB_File', $HISTORY; ## no critic (ProhibitTies)

if ($opts->{clear}) {
  unlink $CATEGORY;
  unlink $RESOLUTION;
}

if ($opts->{category}) {
  write_file($CATEGORY, $opts->{category});
}

if ($opts->{resolution} and $opts->{category}) {
  write_file($RESOLUTION,$opts->{resolution});
}

if ($opts->{'flush-cache'}) {
  flush_cache();
  exit;
}

if ($opts->{'dump-cache'}) {
  print {*STDOUT} Dumper \%history;
  exit;
}

if ($opts->{lock}) {
  write_file($LOCK, '1');
  exit;
}

if ($opts->{unlock}) {
  unlink $LOCK;
  exit;
}

my $wallpaper_dir = get_wallpaper_dir();
my @wallpapers    = get_wallpapers($wallpaper_dir);
my $rv            = _set();

exit $rv;

sub _set {
  my $rc        = 0;
  my $set_paper = 0;

  if (scalar @wallpapers == 1) {
    $rc = set_wallpaper($wallpapers[0]);
    return $rc;
  }

  while (my $paper = get_random_wallpaper(\@wallpapers)) {
    $rc = set_wallpaper($paper);
    $set_paper = 1;
    last;
  }

  if (not $set_paper) {
    flush_cache();
  } else {
    return $rc;
  }

  return _set();
}

sub get_wallpaper_dir {
  my @paths      = ();
  my $category   = get_category();
  my $resolution = get_resolution();

  if ($category eq $DEFAULT_CATEGORY) {
    push @paths, $PREFIX;
  } else {
    push @paths, $WALLPAPER_DIR;
  }

  push @paths, $category;

  if (defined $resolution) {
    push @paths, $resolution;
  }

  my $dir = join($SLASH, @paths);
  confess qq{Wallpaper directory ($dir) does not exist} if not -e $dir;

  return $dir;
}

sub get_wallpapers {
  my ($dir)  = @_;
  my @papers = ();

  for my $wallpaper (read_dir($dir)) {
    push @papers, join($SLASH, $dir, $wallpaper);
  }

  return @papers;
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

  return if is_cached($paper);

  my $cmd_str = sprintf q{%s %s}, get_bgsetter(), $paper;
  my $cmd     = System::Command->new($cmd_str);
  my $stdout  = $cmd->stdout();
  my $stderr  = $cmd->stderr();

  while (<$stdout>) {
    append_file($LOG, $_);
  }

  while (<$stderr>) {
    append_file($LOG, $_);
  }

  $cmd->close();
  cache($paper);
  write_file($CURRENT, $paper);

  return $cmd->exit();
}

sub get_category {
  return (-e $CATEGORY) ? read_file($CATEGORY) : $DEFAULT_CATEGORY;
}

sub get_resolution {
  return (-e $RESOLUTION) ? read_file($RESOLUTION) : undef;
}

sub get_bgsetter {
  return sprintf q{%s %s}, $BGSETTER, $BGSETTER_OPTS;
}

sub cache {
  my ($paper) = @_;
  $history{$paper} = 1;
  return;
}

sub is_cached {
  my ($paper) = @_;
  return exists $history{$paper};
}

sub flush_cache {
  %history = ();
  return;
}
