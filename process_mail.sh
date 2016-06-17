#!/bin/bash
for account in pobox umich; do
  /usr/bin/offlineimap -u quiet -o -a ${account^}
done
