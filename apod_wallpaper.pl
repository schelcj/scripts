#!/usr/bin/env perl

use Modern::Perl;
use Mojo::UserAgent;
use System::Command;
use Data::Dumper;
use File::Slurp qw(write_file);
use Readonly;

Readonly::Scalar my $PREFIX        => qq{$ENV{HOME}};
Readonly::Scalar my $WALLPAPER_DIR => qq{$PREFIX/.wallpapers/Wallpapers/Astro};

my $url   = q{http://apod.nasa.gov/apod/};
my $css   = q{html body center p:nth-of-type(2) a};
my $ua    = Mojo::UserAgent->new();
my $img   = $ua->get($url)->res->dom->at($css)->attrs('href');
my $tx    = $ua->get(qq{${url}${img}});
my $asset = $tx->res->content->asset();
my $parts = $tx->req->url->path->parts();
my $file  = qq{$WALLPAPER_DIR/$parts->[-1]};

$asset->move_to($file);

my $cmd = System::Command->new(qq{fbsetbg -a $file});
my $stdout = $cmd->stdout();

while (<$stdout>) { print $_; };
$cmd->close();
