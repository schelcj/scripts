#!/usr/bin/perl

use Modern::Perl;
use Mojo::UserAgent;
use Mojo::DOM;
use IPC::System::Simple qw(run);
use File::Temp;
use File::Slurp qw(read_file write_file append_file);
use Try::Tiny;
use URI;

my $di_url             = q{http://www.di.fm/};
my $di_fm_url          = q{http://pub%d.di.fm:80/di_%s};
my $backtitle          = q{Digitally Imported: Addictive Electronic Music};
my $title              = q{Select a channel to listen to};
my $radiolist_title    = q{Select a channel to listen to};
my $dialog_geom        = q{20 60};
my $dialog_list_height = q{24};
my $di_fm_pub_range    = 6;
my @channels           = get_channels($di_url);
my $mplayer_opts       = q{-prefer-ipv4 -nolirc -quiet -vo none -ao sdl -input file=/tmp/mplayer};

while (1) {
  play(get_station_selection());
}

sub play {
  my ($station) = @_;

  my $temp = File::Temp->new(SUFFIX => '.pls', UNLINK => 1);
  build_playlist($station, $di_fm_pub_range, $temp->filename);

  my $mplayer_cmd = qq{mplayer $mplayer_opts -playlist } . $temp->filename . q{ 2>&1};

  run(qq{$mplayer_cmd | dialog --progressbox $dialog_geom});

  return;
}

sub get_station_selection {
  my $temp   = File::Temp->new();
  my $dialog = build_station_selection_dialog($temp->filename);

  try {
    run($dialog);
  }
  catch {
    exit;
  };

  return read_file($temp->filename);
}

sub build_station_selection_dialog {
  my ($temp_file) = @_;

  my $cmd = qq{dialog --backtitle "$backtitle" };
  $cmd .= qq{--title "$title" --clear --radiolist };
  $cmd .= qq{"$radiolist_title" $dialog_geom $dialog_list_height };

  map {$cmd .= qq{"$_->[1]" "$_->[0]" off }} @channels;

  return qq{$cmd 2> $temp_file};
}

sub build_playlist {
  my ($station, $range, $file) = @_;

  write_file($file, qq{[playlist]\n});
  append_file($file, qq{NumberOfEntries=$range\n});

  for (1..$range) {
    my $url = sprintf $di_fm_url, $_, $station;

    append_file($file, qq{File$_=$url\n});
    append_file($file, qq{Title$_=$station\n});
    append_file($file, qq{Length$_=-1\n});
  }
}

sub get_channels {
  my ($url)    = @_;
  my $agent    = Mojo::UserAgent->new();
  my $dom      = Mojo::DOM->new($agent->get($url)->res->body);
  my @channels = ();

  $dom->find('div.lists ul li')->each(
    sub {
      my $node = shift;
      (my $channel_url = URI->new($node->at('span.play')->attr('data-tunein-url'))->path()) =~ s/\///g;
      my $channel_title = $node->at('a span')->text();

      push @channels, [$channel_title, $channel_url];
    }
  );

  return @channels;
}
