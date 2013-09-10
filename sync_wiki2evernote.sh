#!/bin/sh
for dir in $(find Dropbox/Wiki/ -type d); do
  gnsync --path $dir --format markdown --notebook Wiki
done
