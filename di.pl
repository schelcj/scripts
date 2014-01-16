#!/usr/bin/perl

use Modern::Perl;
use Mojo::UserAgent;
use Mojo::DOM;
use IPC::System::Simple qw(run);
use File::Temp;
use File::Slurp qw(read_file);
use Try::Tiny;
use URI;

my $di_url             = q{http://www.di.fm/};
my $di_fm_url          = q{http://pub1.di.fm:80};
my $backtitle          = q{Digitally Imported: Addictive Electronic Music};
my $title              = q{Select a channel to listen to};
my $radiolist_title    = q{Select a channel to listen to};
my $dialog_geom        = q{20 60};
my $dialog_list_height = q{24};
my @channels           = get_channels($di_url);


while (1) {
  play(get_station_selection());
}

sub play {
  my ($station) = @_;

  my $url = sprintf qq{$di_fm_url/di_%s}, $station;
  my $mplayer_cmd = sprintf q{mplayer -quiet -vo none -ao sdl -input file=/tmp/mplayer %s 2>&1}, $url;

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

sub get_channels {
  my ($url)    = @_;
  my $agent    = Mojo::UserAgent->new();
  my $dom      = Mojo::DOM->new($agent->get($url)->res->body);
  my @channels = ();

  $dom->find('div.lists ul li')->each(
    sub {
      my $node          = shift;
      (my $channel_url   = URI->new($node->at('span.play')->attr('data-tunein-url'))->path()) =~ s/\///g;
      my $channel_title = $node->at('a span')->text();

      push @channels, [$channel_title, $channel_url];
    }
  );

  return @channels;
}
