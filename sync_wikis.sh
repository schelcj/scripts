#!/bin/bash

export PATH=/usr/local/bin:$PATH

LOG=~/tmp/gnsync.log
WIKI_DIR=$HOME/Dropbox/Wikis
WIKIS=(
  Default:Default-Wiki
  Labbooks:Labbooks-Wiki
  Glossary:Glossary-Wiki
)

for line in "${WIKIS[@]}"; do
  wiki=${line%:*}
  notebook=${line#*:}

  echo -n "Syncing $wiki to $notebook - "
  gnsync -p $WIKI_DIR/$wiki -f markdown -n "$notebook" -l $LOG
  echo "Done"
done
