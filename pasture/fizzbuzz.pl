#!/usr/bin/env perl
print qq{$_ - } . (($_ % 15) ? ($_ % 5) ? ($_ % 3) ? '' : 'fizz' : 'buzz' : 'fizzbuzz') . "\n" for (1..100);
