#!/bin/sh
T=`mktemp` && curl -so $T https://plan.cat/~$USER && $EDITOR $T && curl -su $USER -F "plan=<$T" https://plan.cat/stdin
