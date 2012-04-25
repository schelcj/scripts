#!/bin/sh

export PERL5LIB=${HOME}/perl5/lib/perl5:${HOME}/perl5/lib/perl5/site_perl:${PERL5LIB}
export PATH=${HOME}/Dropbox/bin:${PATH}

INCLUDE_DIR="${HOME}/.ical2rem"

source ${INCLUDE_DIR}/calendars.sh

for calendar in "${CALENDARS[@]}"; do
  name="$(echo $calendar|cut -d\| -f1)"
  url="$(echo $calendar|cut -d\| -f2)"

  wget -q -O- --no-check-certificate $url | ical2rem.pl --label "Gcal" > ${INCLUDE_DIR}/${name}.rem
done
