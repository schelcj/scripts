#!/bin/bash
for i in echo {a..m}; do
  dig +nocmd +nocomments +nostats ${i}.root-servers.net|grep -v '^;'|awk {'print $5'}
done
