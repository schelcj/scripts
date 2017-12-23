#!/usr/bin/env perl

use local::lib;
use Modern::Perl;
use DB_File;
use Data::Dumper;
use File::Find::Object;
use Getopt::Long qw(HelpMessage);
use File::Spec;
use IO::All;

my $PREFIX           = qq($ENV{HOME}/.wallpapers);
my $LOCK             = qq{$PREFIX/lock};
my $CATEGORY         = qq{$PREFIX/category};
my $WALLPAPER_DIR    = qq{$PREFIX/Wallpapers};
my $CURRENT          = qq{$PREFIX/current};
my $PREVIOUS         = qq{$PREFIX/previous};
my $SOURCES          = qq{$PREFIX/sources};
my $DEFAULT_CATEGORY = q{all};

my %history = ();
tie %history, 'DB_File', qq{$PREFIX/history};    ## no critic (ProhibitTies)

GetOptions(
  'category|c=s'  => sub {$_[1] > io($CATEGORY)},
  'clear'         => sub {unlink $CATEGORY},
  'flush-cache|f' => sub {flush_cache()},
  'lock|l'        => sub {2 > io($LOCK)},
  'unlock|u'      => sub {unlink($LOCK)},
  'previous|p'    => sub {
    set_wallpaper(io($PREVIOUS)->all);
    exit;
  },
  'image|i=s' => sub {
    set_wallpaper($_[1]);
    exit;
  },
  'dump-cache|d' => sub {
    print {*STDOUT} Dumper \%history;
    exit;
  },
  'h|help' => \&HelpMessage,
  )
  or HelpMessage(1);

exit if -e $LOCK;

set() unless -e $LOCK;

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
    $rc        = set_wallpaper($papers->[0]);
    $set_paper = 1;
  } else {
    while (my $paper = get_random_wallpaper($papers)) {
      next if exists $history{shift};
      $rc        = set_wallpaper($paper);
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

sub get_wallpaper_dirs {
  my @paths = ();
  my $category = (-e $CATEGORY) ? io($CATEGORY)->getline : $DEFAULT_CATEGORY;

  if ($category eq $DEFAULT_CATEGORY) {

    return map {File::Spec->join($WALLPAPER_DIR, $_)} io($SOURCES)->chomp->getlines;
  } else {
    push @paths, $WALLPAPER_DIR;
  }

  push @paths, $category;

  my $dir = File::Spec->join(@paths);
  die qq{Wallpaper directory ($dir) does not exist} if not -e $dir;

  return ($dir);
}

sub get_wallpapers {
  my (@dirs) = @_;
  my $tree = File::Find::Object->new({}, @dirs);
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

  my $rv = io->pipe(qq{fbsetbg -f $paper})->all;

  $history{$paper} = 1;
  rename $CURRENT, $PREVIOUS;
  shift > io($CURRENT);

  return $rv;
}

sub flush_cache {
  %history = ();
}

__END__

=head1 NAME

wallpaper.pl - Script to manage my desktop wallpapers.

=head1 SYNOPSIS

wallpaper.pl [OPTIONS]

  Options:

    -c, --category    Wallpaper category
    -f, --flush-cache Flush the wallpaper cache
    -d, --dump-cache  Dump the current wallpaper cache to STDOUT
    -l, --lock        Lock the current wallpaper
    -u, --unlock      Unlock the current wallpaper
        --clear       Clear the previous wallpaper category
    -p, --previous    Set the wallpaper to the previous paper
    -i, --image       Set image as the current wallpaper

=head1 DESCRIPTION

This sciprt is used to manage the desktop wallpaper displayed on my system.

=head1 ENVIRONMENT VARIABLES

None

=head1 VERSION

0.2

=cut
