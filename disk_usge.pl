#!/usr/bin/env perl

use Modern::Perl;
use Number::Bytes::Human qw(format_bytes);
use File::Slurp qw(read_dir);
use Filesys::DiskUsage qw(du);

my @dirs  = map {qq{/home/$_}} read_dir('/home');
my %sizes = du({'make-hash' => 1}, @dirs);

say "Size\tDirectory";
map {say format_bytes($sizes{$_}) . "\t" . $_} reverse sort {$sizes{$a} <=> $sizes{$b}} keys %sizes;
