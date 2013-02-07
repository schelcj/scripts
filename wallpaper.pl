#!/usr/bin/env perl

use local::lib;
use Modern::Perl;
use Carp qw(confess);
use Readonly;
use DB_File;
use System::Command;
use File::Slurp qw(read_file write_file append_file);
use Getopt::Compact;
use Data::Dumper;
use File::Find::Object;
use File::Flock::Tiny;
use Proc::Daemon;

Readonly::Scalar my $PREFIX           => qq($ENV{HOME}/.wallpapers);
Readonly::Scalar my $TMPDIR           => qq($ENV{HOME}/tmp);
Readonly::Scalar my $LOCK             => qq{$PREFIX/lock};
Readonly::Scalar my $HISTORY          => qq{$PREFIX/history};
Readonly::Scalar my $CATEGORY         => qq{$PREFIX/category};
Readonly::Scalar my $WALLPAPER_DIR    => qq{$PREFIX/Wallpapers};
Readonly::Scalar my $CURRENT          => qq{$PREFIX/current};
Readonly::Scalar my $RESOLUTION       => qq{$PREFIX/resolution};
Readonly::Scalar my $PREVIOUS         => qq{$PREFIX/previous};
Readonly::Scalar my $LOG              => qq{$PREFIX/log};
Readonly::Scalar my $SOURCES          => qq{$PREFIX/sources};
Readonly::Scalar my $PIDFILE          => qq{$PREFIX/wallpaper.pid};
Readonly::Scalar my $SLEEP_INTERVAL   => 60*60;
Readonly::Scalar my $BGSETTER         => q{fbsetbg};
Readonly::Scalar my $BGSETTER_OPTS    => q{-a};
Readonly::Scalar my $SLASH            => q{/};
Readonly::Scalar my $DEFAULT_CATEGORY => q{all};

## no tidy
my $opts = Getopt::Compact->new(
  struct => [
    [[qw(c category)],    q(Wallpaper category),                                ':s'],
    [[qw(r resolution)],  q(Wallpaper resolution),                              ':s'],
    [[qw(f flush-cache)], q(Flush the wallpaper cache)                              ],
    [[qw(d dump-cache)],  q(Dump the wallpaper cache)                               ],
    [[qw(l lock)],        q(Lock the current paper)                                 ],
    [[qw(u unlock)],      q(Unlock the current paper)                               ],
    [[qw(clear)],         q(Clear previous category/resoution)                      ],
    [[qw(p previous)],    q(Set wallpaper to previous paper)                        ],
    [[qw(s sleep)],       q(How long to sleep, in seconds, if run as a daemon), ':i'],
    [[qw(D daemon)],      q(Background process for a slide show effect)             ],
    [[qw(stop)],          q(Stop a running daemon)                                  ],
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

if ($opts->{previous}) {
  my $paper = read_file($PREVIOUS);
  set_wallpaper($paper);
  exit;
}

if ($opts->{stop}) {
  my $pid = read_file($PIDFILE);
  kill 9, $pid;
  unlink $PIDFILE;
  exit;
}

# TODO - this isn't working as i want
my $lock = File::Flock::Tiny->write_pid($PIDFILE) or die q{Another wallpaper.pl process is running};

if ($opts->{daemon}) {
    my $daemon = Proc::Daemon->new(work_dir => $TMPDIR);
    my $pid    = $daemon->Init;

    if (not $pid) {
      while (1) {
        set(); 
        sleep($opts->{sleep}||$SLEEP_INTERVAL);
      }
    }

    $daemon->Kill_Daemon();
} else {
  set();
}

$lock->release();

sub set {
    my @wallpaper_dirs = get_wallpaper_dirs();
    my @wallpapers     = get_wallpapers(@wallpaper_dirs);
    return _set(\@wallpapers);
}

sub _set {
  my ($papers)  = @_;
  my $rc        = 0;
  my $set_paper = 0;

  if (scalar @{$papers} == 1) {
    $rc = set_wallpaper($papers->[0]);
    $set_paper = 1;
  } else {
    while (my $paper = get_random_wallpaper($papers)) {
      next if is_cached($paper);
      $rc = set_wallpaper($paper);
      $set_paper = 1;
      last;
    }
  }

  if (not $set_paper) {
    flush_cache();
  } else {
    return $rc;
  }

  return _set($papers);
}

sub _build_path {
  my ($dir) = @_;
  chomp $dir;
  return qq{$WALLPAPER_DIR/$dir};
}

sub get_wallpaper_dirs {
  my @paths = ();
  my $category = get_category();
  my $resolution = get_resolution();

  if ($category eq $DEFAULT_CATEGORY) {
    return map {_build_path($_)} read_file($SOURCES);
  } else {
    push @paths, $WALLPAPER_DIR;
  }

  push @paths, $category;

  if (defined $resolution) {
    push @paths, $resolution;
  }

  my $dir = join($SLASH, @paths);
  confess qq{Wallpaper directory ($dir) does not exist} if not -e $dir;

  return ($dir);
}

sub get_wallpapers {
  my (@dirs) = @_;
  my $tree   = File::Find::Object->new({}, @dirs);
  my @papers = ();

  while (my $leaf = $tree->next()) {
    push @papers, $leaf if not -d $leaf;
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

  my $cmd_str = sprintf q{%s '%s'}, get_bgsetter(), $paper;
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
  set_current($paper);

  return $cmd->exit();
}

sub set_current {
  my ($paper) = @_;
  rename $CURRENT, $PREVIOUS;
  write_file($CURRENT, $paper);
  return;
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
