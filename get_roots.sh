#!/bin/sh
dig +nocmd +nocomments +nostats|grep -v 'AAAA'|grep -v '^;'|awk {'print $5'}|grep -v 'root-servers'
