#!/bin/sh

LOG="${HOME}/tmp/geeknote_sync.log"
DROPBOX="${HOME}/Dropbox"
WIKI="${DROPBOX}/Wiki"
NOTES="${DROPBOX}/Documents/MeetingNotes"

# Sync my vimwiki personal wiki
for dir in $(find $WIKI -type d); do
  gnsync --logpath $LOG --path $dir --format markdown --notebook Wiki
done

# sync my meeting notes that are in vimoutliner format
# format is busted though -- ENML has no tabs
# gnsync --logpath $LOG --path $NOTES --format markdown --notebook MeetingNotes
