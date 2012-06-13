#!/bin/sh
export PATH=${HOME}/bin:${PATH}
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
todo.sh recur
