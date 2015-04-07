#!/bin/bash

export PATH=/usr/local/bin:$PATH

LOG=~/tmp/gnsync.log
WIKI_DIR=$HOME/Dropbox/Wikis
WIKIS=(
  Default:Default-Wiki
  Labbooks:Labbooks-Wiki
  CSG:CSG-Wiki
  ConcertPharma:ConcertPharma-Wiki
  Flux:Flux-Wiki
  SPH:SPH-Wiki
  Biostat:Biostat-Wiki
  MyNorth:MyNorth-Wiki
)

for line in "${WIKIS[@]}"; do
  wiki=${line%:*}
  notebook=${line#*:}

  echo -n "Syncing $wiki to $notebook - "
  gnsync -p $WIKI_DIR/$wiki -f markdown -n "$notebook" -l $LOG
  echo "Done"
done
