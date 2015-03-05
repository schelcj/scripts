#!/bin/bash
for account in pobox umich; do
  /usr/local/bin/offlineimap -u quiet -o -a ${account^}
done
