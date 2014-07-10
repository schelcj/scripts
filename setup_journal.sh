#!/bin/sh

NOW="$(date '+%Y%m%d')"
TOMORROW="$(date -d tomorrow '+%Y%m%d')"
TITLE="$(date '+%Y-%m-%d')"
CONTENT="Search: [ __created:$NOW -created:${TOMORROW}__ ]"
NOTEBOOK="03 Journal"

geeknote create --title "$TITLE" --notebook "$NOTEBOOK" --content "$CONTENT"
