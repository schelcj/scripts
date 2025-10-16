#!/bin/sh
curl -s https://merit-routinator01.merit.edu/json | jq '.roas[] | select(.prefix == "$1")'
