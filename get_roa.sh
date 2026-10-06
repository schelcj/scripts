#!/bin/sh
# curl -s https://merit-routinator01.merit.edu/json | jq '.roas[] | select(.prefix == "$1")'
curl -s https://rpki.gin.ntt.net/api/export.json | jq '.roas[] | select(.prefix == "$1")'
