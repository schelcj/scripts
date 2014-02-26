#!/bin/sh
sudo sh -c 'echo -17 > /proc/$(pidof dropbox)/oom_score_adj'
