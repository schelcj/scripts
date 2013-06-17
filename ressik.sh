#!/bin/bash
mplayer -quiet -vo none -ao sdl -playlist \
  ~/Dropbox/Media/Music/Playlists/ressik-$(hostname).m3u 2>&1 \
  | dialog --progressbox 40 80
