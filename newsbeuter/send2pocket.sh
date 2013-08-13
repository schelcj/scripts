#!/bin/sh

url="$1"
title="$2"
desc="$3"

echo $url | mutt -s $title add@getpocket.com
